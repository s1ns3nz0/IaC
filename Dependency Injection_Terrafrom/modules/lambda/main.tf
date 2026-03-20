# modules/lambda/main.tf

resource "aws_security_group" "lambda" {
  name   = "sg-lambda-${var.function_name}"
  vpc_id = var.vpc_id   # injected ✅

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sg-lambda-${var.function_name}"
    Environment = var.environment
  }
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name   # injected ✅
  role          = var.iam_role_arn    # injected ✅
  runtime       = "python3.11"
  handler       = "index.handler"
  filename      = "lambda.zip"
  memory_size   = var.memory_size     # injected ✅
  timeout       = var.timeout         # injected ✅

  vpc_config {
    subnet_ids         = var.subnet_ids  # injected ✅
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = var.environment_variables  # injected ✅
  }

  tags = {
    Name        = var.function_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days  # injected ✅

  tags = {
    Environment = var.environment
  }
}