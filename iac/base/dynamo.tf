resource "aws_dynamodb_table" "main" {
  name             = var.app
  hash_key         = "ID"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  tags             = var.tags

  attribute {
    name = "ID"
    type = "S"
  }

  replica {
    region_name = var.region_alternate
  }
}

output "dynamo_table_arn" {
  value = aws_dynamodb_table.main.arn
}
