terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "glue_scripts" {
  bucket        = "glue-scripts-p64"
  force_destroy = false
  tags = {
    Owner       = var.owner_name
    Environment = "Dev"
  }

}

resource "aws_iam_role" "glue_role_notebook" {
  name               = "AWSGlueServiceRole"
  assume_role_policy = file("glue_role_assume.json")
}

resource "aws_s3_object" "source_object" {
  bucket = aws_s3_bucket.glue_scripts.id
  key    = "sources/result.parquet"
  source = "sources/result.parquet"
}

resource "aws_iam_policy_attachment" "glue_role_policy_attach" {
  name  = "glue-attach-policy"
  roles = [aws_iam_role.glue_role_notebook.name]

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceNotebookRole"
}

resource "aws_iam_policy_attachment" "glue_role_policy_attach_s3" {
  name  = "glue-attach-policy-s3"
  roles = [aws_iam_role.glue_role_notebook.name]

  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy" "glue_passrole_policy" {
  name        = "GluePassRolePolicy"
  description = "Allows AWS Glue to pass its own role"
  policy      = file("passrole_config.json")

}


resource "aws_iam_policy_attachment" "glue_role_policy_attach_passrole" {
  name  = "glue-attach-policy-passrole"
  roles = [aws_iam_role.glue_role_notebook.name]

  policy_arn = aws_iam_policy.glue_passrole_policy.arn
}

# %%configure
# {
# "script_location": "s3://S3-ASSETS_NAME/scripts/",
# "--TempDir": "s3://S3-ASSETS_NAME/temporary/"
# }

