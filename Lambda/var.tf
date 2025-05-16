variable "Execution_arn" {
    default =  "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    }

    variable "Dynamo_arn" {
      default = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
    }

    variable "SNS_access_arn" {
      default = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
    }