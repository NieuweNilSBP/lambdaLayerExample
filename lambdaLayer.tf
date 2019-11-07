#  define the layer
resource "aws_lambda_layer_version" "example" {
  # not sure if this is the right syntax, but you can specify the location of the lambda layer deployment package through s3_object_version:
  s3_bucket         = aws_s3_bucket_object.bucket
  s3_key            = aws_s3_bucket_object.key
  s3_object_version = aws_s3_bucket_object.object.version_id

  layer_name = "lambda_layer_name"

  compatible_runtimes = ["go1.x", "python3.6", "python2.7"]

  description = "this layer defines packages NAME, NAME, NAME, that are shared between all lambdas for this opco."
}

#  define the function
resource "aws_lambda_function" "default" {
  provider      = aws.lambda
  function_name = var.name
  description   = var.description
  filename      = local.filename
  handler       = var.handler
  kms_key_arn   = var.kms_key_arn
  memory_size   = var.memory_size
  runtime       = var.runtime
  role          = var.role_arn != null ? var.role_arn : aws_iam_role.default[0].arn
  publish       = var.publish
  timeout       = var.timeout
  tags          = var.tags

  dynamic vpc_config {
    for_each = local.vpc_config
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = [aws_security_group.default[0].id]
    }
  }
  #    add the layer
  layers = ["${aws_lambda_layer_version.example.arn}"]

  dynamic environment {
    for_each = local.environment

    content {
      variables = var.environment
    }
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = "your_bucket_name"
  key    = "new_object_key"
  source = "path/to/file"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = "${filemd5("path/to/file")}"
}
