output "website_url" {
  value = "http://${aws_s3_bucket.website_bucket.bucket_regional_domain_name}"
}

output "website_domain" {
  value = aws_s3_bucket.website_bucket.bucket_regional_domain_name
}