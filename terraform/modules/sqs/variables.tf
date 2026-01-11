variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "lambda_handler" {
  type    = string
  default = "index.handler"
}

variable "lambda_runtime" {
  type    = string
  default = "nodejs20.x"
}

variable "lambda_timeout" {
  type    = number
  default = 30
}

variable "batch_size" {
  type    = number
  default = 10
}

variable "max_receive_count" {
  type    = number
  default = 5
}

variable "lambda_s3_key" {
  type    = string
  default = "lambda/worker/lambda_nodejs.zip"
}

# NOUVEAU: pilote la création de la Lambda + event source mapping
variable "create_lambda" {
  type    = bool
  default = false
}
