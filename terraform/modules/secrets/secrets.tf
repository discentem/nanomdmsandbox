resource "aws_secretsmanager_secret" "secret" {
  name = var.name
}

resource "aws_secretsmanager_secret_policy" "policy" {
  secret_arn = aws_secretsmanager_secret.secret.arn

  policy = data.aws_iam_policy_document.source.json

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "Allow ECS to read secrets",
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "arn:aws:iam::123456789012:root"
#       },
#       "Action": "secretsmanager:GetSecretValue",
#       "Resource": "*"
#     }
#   ]
# }
# POLICY
}

data "aws_iam_policy_document" "secret_policy_document" {
  statement {
    sid = "Allow ECS to read secrets"
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = ["arn:aws:secretsmanager:${var.aws_region}:${aws.account_id}:secret:${var.name}"]

  }
}
