output "queue_url" {
  value = aws_sqs_queue.jobs.url
}

output "queue_arn" {
  value = aws_sqs_queue.jobs.arn
}

output "lambda_arn" {
  value = aws_lambda_function.worker.arn
}

output "lambda_artifacts_bucket" {
  value = aws_s3_bucket.lambda_artifacts.bucket
}
