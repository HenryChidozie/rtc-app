#Define the Providers and versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#AWS Provider Configuration
provider "aws" {
  region = "us-east-1" # Replace with your preferred region
}

