output "subs-lambda-arn" {
    value = aws_lambda_function.subscribers_function.arn
}

output "subs_invoke_arn" {
    value = aws_lambda_function.subscribers_function.invoke_arn
  
}

output "events-lambda-arn" {
  value = aws_lambda_function.events_function.arn
}

output "events-invoke-arn" {
  value = aws_lambda_function.events_function.invoke_arn
}