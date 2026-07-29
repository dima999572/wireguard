resource "aws_iam_role" "ssm_core_role" {
  name               = "ec2_ssm_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ssm_core_connectivity" {
  name        = "EC2SessionManagerCoreConnectivity"
  description = "Provides baseline connectivity for AWS Session Manager (Ansible SSM plugin)"
  policy      = data.aws_iam_policy_document.ssm_core_connectivity.json
}

resource "aws_iam_role_policy_attachment" "ssm_core_attach" {
  role       = aws_iam_role.ssm_core_role.name
  policy_arn = aws_iam_policy.ssm_core_connectivity.arn
}

data "aws_iam_policy_document" "ssm_core_connectivity" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_instance_profile" "ssm_core_profile" {
  name = "ec2-ssm-core-profile"
  role = aws_iam_role.ssm_core_role.name
}