locals {
  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

#################################
# S3 : Bucket code Lambda
#################################

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "lambda_artifacts" {
  bucket        = "lambda-s3-devops-brief-${var.environment}-${random_id.bucket_suffix.hex}"
  force_destroy = true
  tags          = local.common_tags
}

#################################
# SQS
#################################

resource "aws_sqs_queue" "dlq" {
  name = "${var.project}-${var.environment}-dlq"
  tags = local.common_tags
}

resource "aws_sqs_queue" "jobs" {
  name = "${var.project}-${var.environment}-jobs"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = local.common_tags
}

#################################
# IAM
#################################

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project}-${var.environment}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role      = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_sqs" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [aws_sqs_queue.jobs.arn]
  }
}

resource "aws_iam_role_policy" "lambda_sqs" {
  name   = "${var.project}-${var.environment}-lambda-sqs"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_sqs.json
}

#################################
# Lambda (créée seulement si create_lambda=true)
#################################

resource "aws_lambda_function" "worker" {
  count = var.create_lambda ? 1 : 0

  function_name = "${var.project}-${var.environment}-worker"
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime

  s3_bucket = aws_s3_bucket.lambda_artifacts.bucket
  s3_key    = var.lambda_s3_key

  timeout = var.lambda_timeout
  tags    = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_logs
  ]
}

resource "aws_lambda_event_source_mapping" "from_sqs" {
  count = var.create_lambda ? 1 : 0

  event_source_arn = aws_sqs_queue.jobs.arn
  function_name    = aws_lambda_function.worker[0].arn

  batch_size = var.batch_size
  enabled    = true
}
