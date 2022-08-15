data "aws_caller_identity" "aws-account" {}

resource "aws_sns_topic" "insight-support-extensible-ingress-topic" {
  name = "insight-support-extensible-ingress-topic"

  tags = {
    Product = "insight-support"
    Name    = "insight-support-extensible-ingress-topic"
  }
}

resource "aws_sns_topic_policy" "insight-support-extensible-ingress-topic-policy" {
  arn    = aws_sns_topic.insight-support-extensible-ingress-topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {

  statement {
    actions = [
      "SNS:Publish",
    ]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:s3:*:*:insight-support-extensible-ingress-s3"]
    }

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.insight-support-extensible-ingress-topic.arn,
    ]

  }
}