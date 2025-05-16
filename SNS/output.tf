output "topic-arn" {
  value = aws_sns_topic.subscription-topic.arn
}

output "topic-name" {
  value = aws_sns_topic.subscription-topic.name
}