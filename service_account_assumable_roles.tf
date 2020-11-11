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