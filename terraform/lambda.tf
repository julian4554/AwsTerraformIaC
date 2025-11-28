#zippin
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../lambda"
  output_path = "lambda_function_payload.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_basic_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

#iam
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "dynamodb:PutItem"
      ],
      Resource = aws_dynamodb_table.app_table.arn
    }]
  })
}

#lmabda

resource "aws_lambda_function" "backend_lambda" {
  function_name = "uni-project-backend"
  handler       = "handler.handler"
  runtime = "nodejs20.x"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.app_table.name
    }
  }

  tags = {
    Project = "Uni-Cloud-Website"
  }
}