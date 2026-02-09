# 17. RDS with Snapshot Export to S3
# Automatically export database snapshots to S3 for long-term storage or analysis.

resource "aws_db_instance" "snapshot_export" {
  allocated_storage   = 20
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  username            = "admin"
  password            = "Password123!"
  skip_final_snapshot = true
}

# (Note: Snapshot export is usually triggered via AWS CLI/SDK or Lambda)
# (But you must have the KMS key or S3 bucket prepared)
resource "aws_s3_bucket" "snapshot_bucket" {
  bucket = "rds-snapshots-${random_id.bucket_id.hex}"
}
