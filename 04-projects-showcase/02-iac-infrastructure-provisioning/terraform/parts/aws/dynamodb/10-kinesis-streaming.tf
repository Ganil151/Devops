# 10. Table with Kinesis Stream Destination
# streaming table changes directly to Amazon Kinesis Data Streams.

resource "aws_dynamodb_kinesis_streaming_destination" "example" {
  stream_arn = var.kinesis_stream_arn
  table_name = aws_dynamodb_table.basic_ondemand.name
}
