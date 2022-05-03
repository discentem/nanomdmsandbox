resource "aws_secretsmanager_secret" "secret" {
  name = var.name
}

resource "aws_secretsmanager_secret_policy" "policy" {
  secret_arn = aws_secretsmanager_secret.secret.arn

  policy = data.aws_iam_policy_document.secret_policy_document.json

#   policy = <<POLICY
# {
# 	"Version": "2012-10-17",
# 	"Statement": [{
# 		"Sid": "Allow ECS to read secrets",
# 		"Effect": "Allow",
# 		"Principal": {
# 			"Service": [
# 				"ecs-tasks.amazonaws.com"
# 			]
# 		},
# 		"Action": [
# 			"secretsmanager:GetResourcePolicy",
# 			"secretsmanager:GetSecretValue",
# 			"secretsmanager:DescribeSecret",
# 			"secretsmanager:ListSecretVersionIds"
# 		],
# 		"Resource": ["arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:${var.name}"]
# 	}]
# }
# POLICY
}

data "aws_iam_policy_document" "secret_policy_document" {
  statement { 
    effect    = "Allow"
    resources = ["arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:${var.name}"]
    actions   = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.secret_string
}
