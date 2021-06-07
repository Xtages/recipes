resource "aws_iam_role" "ecs_app_task_role" {
  name_prefix        = "task-role-${var.APP_NAME}"
  description        = "Task role for customer apps running in ECS"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_app_task_policy" {
  name_prefix = "task-policy-${var.APP_NAME}"
  role        = aws_iam_role.ecs_app_task_role.id
  policy      = templatefile("${path.root}/policies/app-policy.json", {})
}
