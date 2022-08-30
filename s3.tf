resource "aws_s3_bucket" "insight-support-extensible-ingress-s3" {
  bucket        = "insight-support-extensible-ingress-s3"
  force_destroy = true

  tags = {
    Product = "insight-support"
    Name    = "insight-support-extensible-ingress-s3"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.insight-support-extensible-ingress-s3.bucket
  rule {
    id = "file-expiration-rule"

    expiration {
      days = 1
    }

    filter {
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
    status = "Enabled"
  }
}


resource "aws_s3_bucket_ownership_controls" "insight-support-extensible-ingress-s3" {
  bucket = aws_s3_bucket.insight-support-extensible-ingress-s3.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_notification" "insight-support-extensible-ingress-s3-notification" {
  bucket = aws_s3_bucket.insight-support-extensible-ingress-s3.id

  topic {
    topic_arn = aws_sns_topic.insight-support-extensible-ingress-topic.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

