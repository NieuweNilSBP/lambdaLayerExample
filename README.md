#Lambda Layers
To create a Lambda Layer (package shared between several Lambda Functions), you'll need to create a [deployment package](https://docs.aws.amazon.com/lambda/latest/dg/lambda-go-how-to-create-deployment-package.html) of your code, and reference this in your Lambda Function config (when setting up the function in Terraform). 

This basically means zipping your (*in Go*: compiled/executable) code.