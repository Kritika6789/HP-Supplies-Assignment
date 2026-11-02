# S3 CSV to DynamoDB synchronization

This Terragrunt deployment creates an S3 bucket, a DynamoDB table, and a Lambda
processor. CSV uploads under the configured prefix are written to DynamoDB;
replacing a CSV updates its rows and deleting one removes its rows.

The table uses `source_key` (S3 object key) as its partition key and
`row_number` as its numeric sort key. CSV files must have a header row with
unique, non-empty column names. The names `source_key` and `row_number` are
reserved. All CSV cell values are stored as strings.

The bucket and table are created by the existing modules in the sibling
`terraform-aws-s3` and `terraform-aws-dynamodb` folders. The S3 event processor
is defined in `terraform/modules/csv-sync`. `live/aws` and `live/localstack`
are Terragrunt entry points for those two targets.

Terragrunt packages the workspace root and selects `s3-dynamodb-sync/terraform`
as the Terraform root. This lets that root use the sibling modules through
local module paths. Keep the `terraform-aws-s3` and `terraform-aws-dynamodb`
folders alongside `s3-dynamodb-sync`; do not move the project by itself and
expect those relative module paths to resolve.

The DynamoDB module includes an internal CloudWatch alarms submodule hosted at
HP's private GitHub Enterprise URL. Terraform still needs access to that
repository during `init`, even though this stack sets `enable_alarms = false`
to avoid creating CloudWatch alarms (which LocalStack does not provide here).
The DynamoDB module's `enable_alarms` variable defaults to `true` for existing
users; this deployment explicitly disables it.

## Requirements

- Terraform 1.5 or later
- Terragrunt
- Python 3.12-compatible Lambda runtime (provided by AWS or LocalStack)
- Docker Compose for LocalStack
- AWS credentials configured in the standard AWS CLI environment for AWS

## Run with LocalStack

From this directory:

```powershell
docker compose up -d
$env:SYNC_BUCKET_NAME = "csv-sync-bucket"
terragrunt --working-dir live/localstack init
terragrunt --working-dir live/localstack apply
```

The Lambda runtime runs in a Docker container and therefore uses
`http://host.docker.internal:4566` to reach LocalStack on the host. Override
`LAMBDA_LOCALSTACK_ENDPOINT` if the Docker host has a different reachable name.

Upload a CSV after deployment:

```powershell
@'
id,name
1,Ada
2,Linus
'@ | Set-Content -Encoding utf8 -NoNewline sample.csv
aws --endpoint-url=http://localhost:4566 s3 cp sample.csv s3://csv-sync-bucket/sample.csv
Start-Sleep -Seconds 5
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name csv-records
```

To verify replacement and deletion, upload a shorter CSV to the same key and
confirm obsolete row numbers disappear, then delete the object and confirm its
items are removed:

```powershell
aws --endpoint-url=http://localhost:4566 s3 rm s3://csv-sync-bucket/sample.csv
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name csv-records
```

Check Lambda logs if processing is delayed or failed:

```powershell
aws --endpoint-url=http://localhost:4566 logs describe-log-streams --log-group-name /aws/lambda/csv-records-csv-sync
```

## Run with AWS

Set `AWS_REGION` and a globally unique `SYNC_BUCKET_NAME`, then apply:

```powershell
$env:AWS_REGION = "us-east-1"
$env:SYNC_BUCKET_NAME = "your-globally-unique-csv-sync-bucket"
terragrunt --working-dir live/aws init
terragrunt --working-dir live/aws apply
```

Upload a CSV and inspect the destination table:

```powershell
aws s3 cp sample.csv s3://$env:SYNC_BUCKET_NAME/sample.csv
Start-Sleep -Seconds 5
aws dynamodb scan --table-name csv-records
```

## Notes

- S3 notifications are at-least-once; repeated events are safe because each CSV
  row has a stable key derived from its object key and row number.
- Processing is S3-to-DynamoDB. Changes made directly in DynamoDB are not
  written back to S3.
- Lambda retries failed events. A failed invocation may temporarily leave an
  incomplete update; a retry reprocesses the object.
- `force_destroy` is enabled for the demo bucket so `terragrunt destroy` can
  remove uploaded objects. Do not use that setting for a production bucket
  without reviewing the data-retention implications.
- Run `terragrunt --working-dir live/<environment> destroy` to remove the
  stack. Stop LocalStack with `docker compose down`.

## Tests

Run the processor's dependency-free unit tests from this directory:

```powershell
python -m unittest discover -s tests
```
