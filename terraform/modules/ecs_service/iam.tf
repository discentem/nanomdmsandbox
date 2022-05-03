resource "aws_iam_role" "execution" {
  name               = "${local.prefix_app_name}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json

  tags = var.tags
}

resource "aws_iam_role_policy" "task_execution" {
  name   = "${local.prefix_app_name}-task-execution"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.task_execution_permissions.json
}

resource "aws_iam_role_policy" "read_repository_credentials" {
  count = var.create_repository_credentials_iam_policy ? 1 : 0

  name   = "${local.prefix_app_name}-read-repository-credentials"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.read_repository_credentials[0].json
}

resource "aws_iam_role" "task" {
  name               = "${local.prefix_app_name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json

  tags = var.tags
}

resource "aws_iam_role_policy" "log_agent" {
  name   = "${local.prefix_app_name}-log-permissions"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_permissions.json
}

resource "aws_iam_role_policy" "ecs_exec_inline_policy" {
  count = var.enable_execute_command ? 1 : 0

  name   = "${local.prefix_app_name}-ecs-exec-permissions"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_ecs_exec_policy[0].json
}