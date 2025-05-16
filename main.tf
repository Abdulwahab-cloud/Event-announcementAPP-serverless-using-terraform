provider "aws" {
  region = var.aws_region
}

module "DynamoDB" {
    source = "./DynamoDB"
}

module "Lambda" {
    source = "./Lambda"
}

module "API_gateway" {
  source = "./API gateway"
  subs_invoke_arn = module.Lambda.subs_invoke_arn
  events_invoke_arn = module.Lambda.events-invoke-arn
}

module "S3" {
  source = "./S3"
  
}

module "SNS" {
  source = "./SNS"
}