terraform {
  required_version = "~> 0.13.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.8"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "twdps"
    workspaces {
      prefix = "poc-platform-servicemesh-"
    }
  }
}

data "terraform_remote_state" "eks" {
  backend = "remote"

  config = {
    organization = "twdps"
    workspaces = {
      name = "poc-platform-eks-${var.cluster_name}"
    }
  }
}

variable "aws_region" {}
variable "account_id" {}
variable "assume_role" {}
variable "cluster_name" {}

provider "aws" {
  version = "~> 3.8"
  region  = var.aws_region
  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/${var.assume_role}"
    session_name = "poc-platform-servicemesh-${var.cluster_name}"
  }
}

data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

locals {
  k8s_external_dns_account_namespace = "kube-system"
  k8s_external_dns_service_account_name = "${var.cluster_name}-external-dns"
}

# External-DNS
module "iam_assumable_role_external_dns" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = ">= v3.3.0"

  create_role                   = true
  role_name                     = "servicemesh-${var.cluster_name}-external-dns"
  provider_url                  = replace(data.terraform_remote_state.eks.outputs.eks_cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.external_dns.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_external_dns_account_namespace}:${local.k8s_external_dns_service_account_name}"]
  number_of_role_policy_arns    = 1
}

resource "aws_iam_policy" "external_dns" {
  name_prefix = "servicemesh-${var.cluster_name}-external-dns"
  description = "EKS external_dns policy for the ${var.cluster_name} cluster"
  policy      = data.aws_iam_policy_document.external_dns.json
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    sid    = "${var.cluster_name}ExternalDNSRecords"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets"
    ]

    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    sid    = "${var.cluster_name}ExternalDNSChanges"
    effect = "Allow"

    actions = [
      "route53:GetChange"
    ]

    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    sid    = "${var.cluster_name}HostedZones"
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]

    resources = ["*"]
  }
}