resource "aws_s3_bucket" "insight-support-extensible-ingress-s3" {
  bucket        = "insight-support-extensible-ingress-s3"
  force_destroy = true

  lifecycle_rule {
    id      = "insight-support-extensible-ingress-s3-object-lifecycle-expire-rule"
    enabled = true

    expiration {
      days = 1
    }

    tags = {
      Product = "insight-support"
      Name    = "insight-support-extensible-ingress-s3-lifecycle-monthly-expire-rule"
    }
  }

  tags = {
    Product = "insight-support"
    Name    = "insight-support-extensible-ingress-s3"
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

