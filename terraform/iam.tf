#region EC2
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
#endregion

#region SSM
data "aws_iam_policy_document" "ssm_sessions" {
  statement {
    sid    = "SSMSessionManager"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectACL",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}",
      "arn:aws:s3:::${local.bucket_name}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}
#endregion
