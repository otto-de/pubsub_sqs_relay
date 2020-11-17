resource "aws_kms_key" "key" {
  #tfsec:ignore:AWS019
  policy = data.aws_iam_policy_document.key.json

  tags = {
    service     = local.service_name
    environment = var.environment
  }
}

resource "aws_kms_alias" "keyalias" {
  target_key_id = aws_kms_key.key.id
  name          = "alias/${local.service_name}_queue_key"
}

data "aws_iam_policy_document" "key" {
  statement {
    sid = "Enable SQS to use KMS key"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "*",
      ]
    }

    condition {
      test = "StringEquals"

      values = [
        "sqs.${data.aws_region.current.name}.amazonaws.com",
      ]

      variable = "kms:ViaService"
    }

    condition {
      test = "StringEquals"

      values = [
        var.account_id,
      ]

      variable = "kms:CallerAccount"
    }

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey",
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_iam_role.lambda_role.arn
      ]
    }

    resources = [
      "*",
    ]
  }

  # This allows the admins and developers to put messages on the queue
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:*Policy*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${var.account_id}:role/AWS-ADM",
        "arn:aws:iam::${var.account_id}:role/AWS-DEV",
      ]
    }

    resources = [
      "*",
    ]
  }

  # Allow Pipeline Role to Manage the Key
  statement {
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

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${var.account_id}:role/${local.service_name}_pipeline_role",
      ]
    }

    resources = [
      "*",
    ]
  }

  statement {
    sid = "Allow SNS topic to encrypt messages into the queue"

    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt",
    ]

    principals {
      type = "Service"

      identifiers = [
        "sns.amazonaws.com",
      ]
    }

    resources = [
      "*",
    ]
  }
}
