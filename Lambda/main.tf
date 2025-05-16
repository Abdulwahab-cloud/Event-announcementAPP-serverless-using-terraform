resource "aws_iam_role" "iam-subscribers-function" {
  name = "iam_subs_function"

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
}

resource "aws_iam_role_policy_attachment" "subs_basic_execution" {
  role = aws_iam_role.iam-subscribers-function.id
  policy_arn = var.Execution_arn
}

resource "aws_iam_role_policy_attachment" "Access_to_SNS" {
  role = aws_iam_role.iam-subscribers-function.id
  policy_arn = var.SNS_access_arn
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source_file = "${path.module}/subscribers_function.py"
  output_path = "${path.module}/subscribers_function.zip"
}

resource "aws_lambda_function" "subscribers_function" {

  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name = "subscribers_Function"
  role          = "${aws_iam_role.iam-subscribers-function.arn}"
  handler       = "subscribers_function.lambda_handler"
  runtime = "python3.12"
  timeout = 30
}


resource "aws_iam_role" "iam-events-function" {
  name = "iam_events_function"

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
}

resource "aws_iam_role_policy_attachment" "events_basic_execution" {
  role = aws_iam_role.iam-events-function.id
  policy_arn = var.Execution_arn 
}

resource "aws_iam_role_policy_attachment" "events-access-db" {
  role = aws_iam_role.iam-events-function.id
  policy_arn = var.Dynamo_arn
}

resource "aws_iam_role_policy_attachment" "events-access-to-SNS" {
  role = aws_iam_role.iam-events-function.id
  policy_arn = var.SNS_access_arn
}

data "archive_file" "Events_zip" {
  type = "zip"
  source_file = "${path.module}/events_function.py"
  output_path = "${path.module}/events_function.zip"
}

resource "aws_lambda_function" "events_function" {

  filename      = data.archive_file.Events_zip.output_path
  source_code_hash = data.archive_file.Events_zip.output_base64sha256
  function_name = "Events_Function"
  role          = "${aws_iam_role.iam-events-function.arn}"
  handler       = "events_function.lambda_handler"
  runtime = "python3.12"
  timeout = 30
}


resource "aws_lambda_permission" "subs-apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscribers_function.function_name 
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "events-apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.events_function.function_name 
  principal     = "apigateway.amazonaws.com"
}