resource "aws_sns_topic" "subscription-topic" {
  name = var.topic_name
}