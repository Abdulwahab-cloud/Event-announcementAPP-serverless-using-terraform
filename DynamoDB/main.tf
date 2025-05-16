resource "aws_dynamodb_table" "DB" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = var.partition_key


attribute{ 
    name = "event_id"
    type = "S"
}
}