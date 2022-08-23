resource "aws_cloudwatch_log_group" "insight-support-extensible-ingress-lambda-cloudwatch" {
  name              = "/aws/lambda/${aws_lambda_function.insight-support-extensible-ingress-lambda.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "insight-support-extensible-ingress-lambda-permisson" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.insight-support-extensible-ingress-lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.insight-support-extensible-ingress-topic.arn
}

resource "aws_lambda_function" "insight-support-extensible-ingress-lambda" {
  filename         = "lambda_function_payload.zip"
  function_name    = "insight-support-extensible-ingress-lambda"
  role             = aws_iam_role.insight-support-extensible-ingress-lambda-iam-role.arn
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


data "aws_iam_policy_document" "insight-support-extensible-ingress-lambda-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "insight-support-dynamo-db-table-policy" {
  statement {
    effect  = "Allow"
    actions = [
      "dynamodb:Get*",
      "dynamodb:Delete*",
      "dynamodb:Update*",
      "dynamodb:PutItem"
    ]
    resources = ["arn:aws:dynamodb:*:*:table/insight-support-extensible-ingress"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role" "insight-support-extensible-ingress-lambda-iam-role" {
  name               = "insight-support-extensible-ingress-lambda-iam-role"
  assume_role_policy = data.aws_iam_policy_document.insight-support-extensible-ingress-lambda-policy.json
  tags               = {
    Product = "insight-support"
    Name    = "insight-support-extensible-ingress-lamdba-iam-role"
  }
}

resource "aws_iam_role_policy" "insight-support-extensible-ingress-notification-policy" {
  name   = "insight-support-extensible-ingress-notification-policy"
  role   = aws_iam_role.insight-support-extensible-ingress-lambda-iam-role.id
  policy = data.aws_iam_policy_document.insight-support-dynamo-db-table-policy.json
}


resource "aws_dynamodb_table" "insight-support-extensible-ingress" {
  name           = "insight-support-extensible-ingress"
  hash_key       = "id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "id"
    type = "S"
  }
  tags = {
    Product = "insight-support"
    Name    = "insight-support-extensible-ingress-dynamodb-table"
  }
}


#resource "aws_appautoscaling_target" "insight-support-dynamodb-table-write-target" {
#  max_capacity       = 10000
#  min_capacity       = 5
#  resource_id        = "table/insight-support-extensible-ingress-dynamodb-table"
#  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
#  service_namespace  = "dynamodb"
#}
#
#resource "aws_appautoscaling_policy" "insight-support-dynamodb-table-write-policy" {
#  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.insight-support-dynamodb-table-write-target.resource_id}"
#  policy_type        = "TargetTrackingScaling"
#  resource_id        = aws_appautoscaling_target.insight-support-dynamodb-table-write-target.resource_id
#  scalable_dimension = aws_appautoscaling_target.insight-support-dynamodb-table-write-target.scalable_dimension
#  service_namespace  = aws_appautoscaling_target.insight-support-dynamodb-table-write-target.service_namespace
#
#  target_tracking_scaling_policy_configuration {
#    predefined_metric_specification {
#      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
#    }
#
#    target_value = 80
#  }
#}




