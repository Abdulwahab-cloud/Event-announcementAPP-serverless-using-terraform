output "website_url" {
    value = module.S3.website_url
}

output "API_URL" {
  value = module.API_gateway.api_url
}

output "SNS_ARN" {
  value = module.SNS.topic-arn
}