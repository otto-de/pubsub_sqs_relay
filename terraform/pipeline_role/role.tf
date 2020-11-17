resource "aws_iam_role" "pipeline_role" {
  name                  = "${local.service_name}_pipeline_role"
  assume_role_policy    = data.aws_iam_policy_document.assume_role_pipeline_policy_document.json
  force_detach_policies = true
}

data "aws_iam_policy_document" "assume_role_pipeline_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = [
        # allow developer and admin role from target account
        "arn:aws:iam::${local.infra_account_id}:role/AWS-ADM",
        "arn:aws:iam::${local.infra_account_id}:role/AWS-DEV",
        # allow ci user to assume tf state
        "arn:aws:iam::${local.infra_account_id}:user/ci",
        # allow developer role from live, nonlive
        "arn:aws:iam::${local.nonlive_account_id}:role/AWS-ADM",
        "arn:aws:iam::${local.nonlive_account_id}:role/AWS-DEV",
        "arn:aws:iam::${local.live_account_id}:role/AWS-ADM",
        "arn:aws:iam::${local.live_account_id}:role/AWS-DEV",
      ]
      type = "AWS"
    }
  }
}

data "aws_iam_policy_document" "pipeline_policy_document_infra_permissions" {
  statement {
    sid    = "ReadCurrentRegion"
    effect = "Allow"
    actions = [
      "ec2:DescribeRegions"
    ]
    resources = [
    "*"]
  }

  statement {
    sid    = "ManageS3"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:CreateMultipartUpload",
      "s3:DeleteBucket*",
      "s3:DeleteBucketPolicy",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucket*",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:PutAccelerateConfiguration",
      "s3:PutBucket*",
      "s3:PutEncryptionConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutReplicationConfiguration",
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${local.team_name}-${replace(local.service_name, "_", "-")}-${local.infra_account_id}-${data.aws_region.current.name}",
      "arn:aws:s3:::${local.team_name}-${replace(local.service_name, "_", "-")}-${local.infra_account_id}-${data.aws_region.current.name}/*",
    ]
  }

  statement {
    sid    = "ManageAllS3"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:HeadBucket",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "pipeline_policy_document_permissions" {

  statement {
    sid    = "ManageLambda"
    effect = "Allow"
    actions = [
      "lambda:AddPermission",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:Get*",
      "lambda:List*",
      "lambda:RemovePermission",
      "lambda:TagResource",
      "lambda:UntagResource",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
    ]
    resources = [
      "arn:aws:lambda:${data.aws_region.current.name}:${local.nonlive_account_id}:function:${local.service_name}-lambda-*",
      "arn:aws:lambda:${data.aws_region.current.name}:${local.live_account_id}:function:${local.service_name}-lambda-*",
    ]
  }

  statement {
    sid    = "ManageLambdaLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DeleteRetentionPolicy",
      "logs:DescribeLogGroups",
      "logs:PutRetentionPolicy",
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${local.nonlive_account_id}:log-group:${local.service_name}-loggroup",
      "arn:aws:logs:${data.aws_region.current.name}:${local.live_account_id}:log-group:${local.service_name}-loggroup",
    ]
  }

  statement {
    sid    = "ManageAllS3"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:HeadBucket",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ManageS3Objects"
    effect = "Allow"
    actions = [
      "s3:GetObject*",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${local.team_name}-${replace(local.service_name, "_", "-")}-${local.infra_account_id}-${data.aws_region.current.name}",
      "arn:aws:s3:::${local.team_name}-${replace(local.service_name, "_", "-")}-${local.infra_account_id}-${data.aws_region.current.name}/*",
    ]
  }

  statement {
    sid    = "ManageIAMRoles"
    effect = "Allow"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:Tag*",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRoleDescription",
    ]
    resources = [
      "arn:aws:iam::${local.nonlive_account_id}:role/${local.service_name}_lambda_role",
      "arn:aws:iam::${local.live_account_id}:role/${local.service_name}_lambda_role"
    ]
  }

  statement {
    sid    = "ManageAllIAMRoles"
    effect = "Allow"
    actions = [
      "iam:ListRoles"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "ELB"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetRulePriorities"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ReadCurrentRegion"
    effect = "Allow"
    actions = [
      "ec2:DescribeRegions"
    ]
    resources = [
    "*"]
  }

  statement {
    sid    = "lambda"
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeSecurityGroups",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:Describe*",
      "ec2:Get*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "logs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
      "logs:DeleteMetricFilter",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DescribeMetricFilters",
      "logs:DescribeMetricFilters",
      "logs:ListTagsLogGroup",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy",
      "logs:TagLogGroup",
      "logs:TestMetricFilter",
      "logs:UntagLogGroup",
    ]
    resources = ["*"]
  }


  statement {
    sid    = "KeyManagement"
    effect = "Allow"
    actions = [
      "kms:CreateAlias",
      "kms:CreateGrant",
      "kms:CreateKey",
      "kms:DeleteAlias",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListAliases",
      "kms:ListGrants",
      "kms:ListKeyPolicies",
      "kms:ListKeys",
      "kms:ListResourceTags",
      "kms:ListRetirableGrants",
      "kms:PutKeyPolicy",
      "kms:RetireGrant",
      "kms:RevokeGrant",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:UpdateAlias",
      "kms:UpdateKeyDescription",
      "kms:ScheduleKeyDeletion",
    ]
    # KMS Key Ids are generated as uuid.v3 by AWS, it is not possible to restrict access to a specific key in a generic policy
    resources = ["*"]
  }

  statement {
    sid    = "SQS"
    effect = "Allow"
    actions = [
      "sqs:AddPermission",
      "sqs:CreateQueue",
      "sqs:DeleteQueue",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:ListQueueTags",
      "sqs:RemovePermission",
      "sqs:SetQueueAttributes",
      "sqs:TagQueue",
      "sqs:UntagQueue",
    ]
    resources = [
      "arn:aws:sqs:${data.aws_region.current.name}:${local.nonlive_account_id}:${local.service_name}-*",
      "arn:aws:sqs:${data.aws_region.current.name}:${local.live_account_id}:${local.service_name}-*",
    ]
  }
}

resource "aws_iam_policy" "pipeline_policy" {
  name_prefix = "${local.service_name}_pipeline_role_policy_permissions_payload"
  policy      = var.environment == "infra" ? data.aws_iam_policy_document.pipeline_policy_document_infra_permissions.json : data.aws_iam_policy_document.pipeline_policy_document_permissions.json
}

resource "aws_iam_role_policy_attachment" "attach_permissions_pipeline_policy_to_role" {
  policy_arn = aws_iam_policy.pipeline_policy.arn
  role       = aws_iam_role.pipeline_role.name
}

data "aws_region" "current" {}
