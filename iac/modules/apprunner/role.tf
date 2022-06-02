# set permission for what AppRunner service can do
data "aws_iam_policy_document" "app_policy" {
  statement {
    actions = [
      "dynamodb:Scan",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]

    resources = [
      "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.app}"
    ]
  }
}

# creates an application role that the AppRunner service runs as
resource "aws_iam_role" "instance" {
  name               = "${var.app}-${var.region}-instance"
  assume_role_policy = data.aws_iam_policy_document.app_role_assume_role_policy.json
}

# assigns the app policy
resource "aws_iam_role_policy" "app_policy" {
  name   = "${var.app}-${var.region}"
  role   = aws_iam_role.instance.id
  policy = data.aws_iam_policy_document.app_policy.json
}

data "aws_caller_identity" "current" {}

# allow role to be assumed by AppRunner
data "aws_iam_policy_document" "app_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["tasks.apprunner.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "access" {
  name               = "${var.app}-${var.region}-access"
  assume_role_policy = data.aws_iam_policy_document.apprunner.json

  # workaround for https://github.com/hashicorp/terraform-provider-aws/issues/6566
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

data "aws_iam_policy_document" "apprunner" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "build.apprunner.amazonaws.com",
        "tasks.apprunner.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "apprunner" {
  role       = aws_iam_role.access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

