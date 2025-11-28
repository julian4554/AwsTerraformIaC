resource "aws_dynamodb_table" "app_table" {
  name         = "uni-project-table"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = var.tags
}
