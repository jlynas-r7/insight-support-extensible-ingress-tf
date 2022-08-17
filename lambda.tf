resource "aws_iam_role" "insight-support-extensible-ingress-lambda" {
  name = "insight-support-extensible-ingress-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Product = "insight-support"
    Name    = "insight-support-extensible-ingress-lamdba-iam-role"
  }

}


resource "aws_lambda_function" "insight-support-extensible-ingress-lambda" {
  filename         = "lambda_function_payload.zip"
  function_name    = "insight-support-extensible-ingress-lambda"
  role             = aws_iam_role.insight-support-extensible-ingress-lambda.arn
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
  runtime          = "nodejs12.x"
  handler          = "index.handler"

  tags = {
    Product = "insight-support"
    Name    = "insight-support-extensible-ingress-lamdba"
  }
}

resource "aws_sns_topic_subscription" "insight-support-extensible-ingress-lambda-topic-subscription" {
  endpoint  = aws_lambda_function.insight-support-extensible-ingress-lambda.arn
  protocol  = "lambda"
  topic_arn = aws_sns_topic.insight-support-extensible-ingress-topic.arn
}