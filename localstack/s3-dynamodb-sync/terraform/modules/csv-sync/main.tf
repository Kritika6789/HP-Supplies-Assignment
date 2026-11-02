data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/../../function/handler.py"
  output_path = "${path.root}/.terraform/csv-sync.zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    sid       = "ReadCsvObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${var.bucket_arn}/*"]
  }

  statement {
    sid       = "SynchronizeRows"
    effect    = "Allow"
    actions   = ["dynamodb:Query", "dynamodb:BatchWriteItem"]
    resources = [var.table_arn]
  }

  statement {
    sid       = "WriteLambdaLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/*:*"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.table_name}-csv-sync"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "lambda" {
  name   = "${var.table_name}-csv-sync"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_lambda_function" "this" {
  function_name    = "${var.table_name}-csv-sync"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  timeout          = 60
  memory_size      = 256
  depends_on       = [aws_iam_role_policy.lambda]

  environment {
    variables = {
      TABLE_NAME            = var.table_name
      SYNC_AWS_REGION       = var.aws_region
      S3_ENDPOINT_URL       = var.localstack ? var.lambda_localstack_endpoint : ""
      DYNAMODB_ENDPOINT_URL = var.localstack ? var.lambda_localstack_endpoint : ""
    }
  }
}

# Enable EventBridge notifications on the S3 bucket
resource "aws_s3_bucket_notification" "this" {
  bucket      = var.bucket_name
  eventbridge = true
}

# EventBridge rule to match CSV creation and deletion events on this bucket
resource "aws_cloudwatch_event_rule" "csv_sync" {
  name        = "${var.table_name}-csv-eventbridge-rule"
  description = "Routes S3 CSV Object Created and Deleted events to the CSV sync Lambda"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created", "Object Deleted"]
    detail = {
      bucket = {
        name = [var.bucket_name]
      }
      object = {
        key = [
          {
            suffix = ".csv"
          }
        ]
      }
    }
  })
}

# EventBridge target pointing to the Lambda function
resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.csv_sync.name
  target_id = "SendCsvEventsToLambda"
  arn       = aws_lambda_function.this.arn
}

# Lambda permission allowing EventBridge to invoke this function
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.csv_sync.arn
}
