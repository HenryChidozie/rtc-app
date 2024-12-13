#provision DDB
resource "aws_dynamodb_table" "chat_table" {
  name           = "ChatMessages"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ConnectionId"
  attribute {
    name = "ConnectionId"
    type = "S"
  }
}

#Add an API GW
resource "aws_apigatewayv2_api" "websocket_api" {
  name          = "ChatAppWebSocket"
  protocol_type = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}
#Add default route to the GW
resource "aws_apigatewayv2_route" "default_route" {
  api_id      = aws_apigatewayv2_api.websocket_api.id
  route_key   = "$default"
  target      = aws_apigatewayv2_integration.default_integration.id
}

#Add default integration to the API GW
resource "aws_apigatewayv2_integration" "default_integration" {
  api_id             = aws_apigatewayv2_api.websocket_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.chat_handler.invoke_arn
}

#Create Lambda function
resource "aws_lambda_function" "chat_handler" {
  function_name = "ChatHandler"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.chat_table.name
    }
  }

  role    = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("lambda.zip") # Ensure lambda.zip exists in the project folder

  filename = "lambda.zip"
}

#configure lambda permissions
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chat_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*"
}

#create lambda iam role
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
