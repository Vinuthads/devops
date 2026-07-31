terraform {
  backend "s3" {
    bucket         = "devops-terraform-state-vinutha"
    key            = "devops/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    use_lockfile = "terraform-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
