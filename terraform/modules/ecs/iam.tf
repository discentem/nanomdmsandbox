# ECS API IAM Resource
resource "aws_iam_role" "iam_ecs_role" {
  name               = "${var.name}-ecs-role"
  description        = "IAM ECS Role for ${var.name}"
  assume_role_policy = data.aws_iam_policy_document.iam_ecs_assume_role.json
}

# Only allow ECS tasks to assume this role
data "aws_iam_policy_document" "iam_ecs_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "iam_ecs_policy_document" {
  # TODO: Refine permissions to what is required...****
  statement {
    effect = "Allow"
    actions = [
      "*",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "iam_ecs_role_policy" {
  name   = var.name
  role   = aws_iam_role.iam_ecs_role
  policy = data.aws_iam_policy_document.iam_ecs_policy_document.json
}

resource "aws_iam_role_policy_attachment" "iam_ecs_policy_attachment" {
  role       = aws_iam_role.iam_ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iam_ecs_policy_agent_ebs" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:CreateVolume",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:DeleteVolume",
      "ec2:DeleteSnapshot",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeAttribute",
      "ec2:DescribeVolumeStatus",
      "ec2:DescribeSnapshots",
      "ec2:CopySnapshot",
      "ec2:DescribeSnapshotAttribute",
      "ec2:DetachVolume",
      "ec2:ModifySnapshotAttribute",
      "ec2:ModifyVolumeAttribute",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role" "iam_ecs_agent" {
  name               = "${var.name}-ecs-agent"
  description        = "IAM ECS Agent Role for ${var.name}"
  assume_role_policy = data.aws_iam_policy_document.iam_ecs_policy_agent.json
}


resource "aws_iam_role_policy_attachment" "iam_ecs_role_policy_agent" {
  role       = aws_iam_role.iam_ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy" "iam_ecs_role_policy_agent_volume" {
  name   = "${var.name}-ecs-agent-volume"
  role   = aws_iam_role.ecs_agent.name
  policy = data.aws_iam_policy_document.iam_ecs_policy_agent_ebs.json
}

resource "aws_iam_instance_profile" "iam_ecs_instance_profile_agent" {
  name = "${var.name}-ecs-agent-instance-role"
  role = aws_iam_role.iam_ecs_agent.name
}