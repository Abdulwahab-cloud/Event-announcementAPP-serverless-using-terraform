# Output the API URL
output "api_url" {
  value = "https://${aws_api_gateway_rest_api.Event-Api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.stage.id}"
}