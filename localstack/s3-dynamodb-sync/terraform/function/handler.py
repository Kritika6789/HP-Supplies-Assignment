import csv
import io
import logging
import os
from urllib.parse import unquote_plus

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def csv_rows(stream, source_key):
    reader = csv.DictReader(io.TextIOWrapper(stream, encoding="utf-8-sig", newline=""))
    headers = reader.fieldnames

    if not headers:
        raise ValueError(f"CSV object {source_key!r} must contain a header row")
    if any(not header or not header.strip() for header in headers):
        raise ValueError(f"CSV object {source_key!r} contains an empty column name")
    if len(headers) != len(set(headers)):
        raise ValueError(f"CSV object {source_key!r} contains duplicate column names")
    if {"source_key", "row_number"}.intersection(headers):
        raise ValueError("CSV column names 'source_key' and 'row_number' are reserved")

    for row_number, row in enumerate(reader, start=1):
        if None in row or any(value is None for value in row.values()):
            raise ValueError(f"CSV object {source_key!r} has an invalid row {row_number + 1}")
        yield {
            "source_key": source_key,
            "row_number": row_number,
            **row,
        }


def delete_source_rows(table, source_key):
    from boto3.dynamodb.conditions import Key

    last_key = None
    while True:
        query = {
            "KeyConditionExpression": Key("source_key").eq(source_key),
            "ProjectionExpression": "#source, #row",
            "ExpressionAttributeNames": {
                "#source": "source_key",
                "#row": "row_number",
            },
        }
        if last_key:
            query["ExclusiveStartKey"] = last_key
        result = table.query(**query)
        with table.batch_writer() as batch:
            for item in result["Items"]:
                batch.delete_item(
                    Key={
                        "source_key": item["source_key"],
                        "row_number": item["row_number"],
                    }
                )
        last_key = result.get("LastEvaluatedKey")
        if not last_key:
            break


def sync_csv(s3, table, bucket, source_key):
    response = s3.get_object(Bucket=bucket, Key=source_key)
    row_count = 0
    last_key = None

    raw_bytes = response["Body"].read()

    # If the CSV file is completely empty (0 bytes) or only whitespace, do not sync to DynamoDB
    if not raw_bytes or not raw_bytes.strip():
        message = f"File uploaded in S3 bucket '{bucket}' ({source_key}) is empty (0 bytes). Cannot sync with DynamoDB."
        logger.warning(message)
        return {"status": "skipped", "message": message, "reason": "empty_file"}

    items = list(csv_rows(io.BytesIO(raw_bytes), source_key))

    # If the CSV contains only a header row with no data rows, skip syncing
    if not items:
        message = f"File uploaded in S3 bucket '{bucket}' ({source_key}) contains only headers and no data rows. Cannot sync with DynamoDB."
        logger.warning(message)
        return {"status": "skipped", "message": message, "reason": "no_data_rows"}

    with table.batch_writer() as batch:
        for item in items:
            batch.put_item(Item=item)
            row_count += 1

    from boto3.dynamodb.conditions import Key

    while True:
        query = {
            "KeyConditionExpression": Key("source_key").eq(source_key),
            "ProjectionExpression": "#source, #row",
            "ExpressionAttributeNames": {
                "#source": "source_key",
                "#row": "row_number",
            },
        }
        if last_key:
            query["ExclusiveStartKey"] = last_key
        result = table.query(**query)
        obsolete = [
            item
            for item in result["Items"]
            if item["row_number"] > row_count
        ]
        if obsolete:
            with table.batch_writer() as batch:
                for item in obsolete:
                    batch.delete_item(
                        Key={
                            "source_key": item["source_key"],
                            "row_number": item["row_number"],
                        }
                    )
        last_key = result.get("LastEvaluatedKey")
        if not last_key:
            break

    logger.info("Synchronized %d rows from s3://%s/%s", row_count, bucket, source_key)


def lambda_handler(event, context):
    import boto3

    table_name = os.environ["TABLE_NAME"]
    region = os.environ.get("SYNC_AWS_REGION", "us-east-1")
    s3_endpoint = os.environ.get("S3_ENDPOINT_URL") or None
    dynamodb_endpoint = os.environ.get("DYNAMODB_ENDPOINT_URL") or None
    s3 = boto3.client("s3", region_name=region, endpoint_url=s3_endpoint)
    dynamodb = boto3.resource(
        "dynamodb", region_name=region, endpoint_url=dynamodb_endpoint
    )
    table = dynamodb.Table(table_name)
    processed = 0

    # Handle EventBridge event format
    if event.get("source") == "aws.s3" and "detail" in event:
        detail_type = event.get("detail-type")
        detail = event["detail"]
        bucket = detail.get("bucket", {}).get("name")
        source_key = unquote_plus(detail.get("object", {}).get("key", ""))

        if detail_type == "Object Deleted":
            delete_source_rows(table, source_key)
            logger.info("Removed DynamoDB rows for s3://%s/%s via EventBridge", bucket, source_key)
            return {"status": "success", "action": "deleted", "processed": 1}
        elif detail_type == "Object Created":
            result = sync_csv(s3, table, bucket, source_key)
            if result and result.get("status") == "skipped":
                return result
            logger.info("Synchronized DynamoDB rows for s3://%s/%s via EventBridge", bucket, source_key)
            return {"status": "success", "action": "synchronized", "processed": 1}
        else:
            logger.warning("Ignoring unsupported EventBridge detail-type %s", detail_type)
            return {"status": "ignored", "detail_type": detail_type}

    # Handle direct S3 notification format (fallback for backwards compatibility)
    for record in event.get("Records", []):
        event_name = record["eventName"]
        bucket = record["s3"]["bucket"]["name"]
        source_key = unquote_plus(record["s3"]["object"]["key"])

        if event_name.startswith("ObjectRemoved:"):
            delete_source_rows(table, source_key)
            logger.info("Removed DynamoDB rows for s3://%s/%s", bucket, source_key)
        elif event_name.startswith("ObjectCreated:"):
            sync_csv(s3, table, bucket, source_key)
        else:
            logger.warning("Ignoring unsupported S3 event %s", event_name)
            continue

        processed += 1

    return {"processed": processed}
