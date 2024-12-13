**Overview**
In this project, we are Building a Real-Time Chat Application that involves several AWS services
We will be using Terraform to provision the infrastructure to ensure a repeatable, declarative setup. 
Below is a step-by-step guide to create this application.

**Architecture**
API Gateway: Handles WebSocket connections.
Lambda: Processes chat messages (connected, send, disconnect).
DynamoDB: Stores chat session details and messages.

**Pre-requisites**
Terraform Installed: Install Terraform.
AWS CLI Configured: Configure AWS CLI.
IAM User with Permissions: Ensure the user has permissions for API Gateway, Lambda, DynamoDB, and IAM.