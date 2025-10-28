# AWS Blue/Green Deployment with Terraform and NGINX

This project provisions a basic Blue/Green deployment infrastructure on AWS using Terraform. It deploys two application servers ("Blue" and "Green") running Apache and one NGINX server that acts as a reverse proxy.

The NGINX proxy is configured for active/passive load balancing. It directs all primary traffic to the **Green** server. The **Blue** server is configured as a backup, and NGINX will automatically failover traffic to it if the Green server becomes unavailable.

---

### 🛡️ Security & Least Privilege

This project is designed to be run securely using a **least-privilege IAM model**. Instead of using a single, over-privileged administrator account, it separates permissions into two distinct roles:

1.  **The Terraform Executor:** The IAM user (or role) that runs `terraform apply`. This user only has permission to read secrets from Secrets Manager and manage the Terraform state in S3.
2.  **The Project Service User:** The credentials (access key and secret key) stored in AWS Secrets Manager. Terraform retrieves and uses these credentials to create the *actual* project resources (EC2 instances, Security Groups).

This ensures the user running Terraform doesn't have direct permissions to create EC2 instances, and the keys used for resource creation are securely stored and managed. Recommended IAM policies for both are included in the **[IAM Least Privilege Policies](#-iam-least-privilege-policies)** section below.

---

## 🚀 Features

* **Infrastructure as Code:** All infrastructure is defined using Terraform.
* **Blue/Green Architecture:** Deploys three EC2 instances: one NGINX proxy, one "Blue" app server, and one "Green" app server.
* **Automated Setup:** Uses `user-data` scripts to automatically install and configure Apache and NGINX.
* **Secure Credentials:** Avoids hardcoded keys by fetching AWS credentials at runtime from AWS Secrets Manager.
* **Remote State:** Configured to use an S3 bucket for secure and persistent Terraform state management.
* **Dynamic Security:** The web security group allows HTTP (port 80) from anywhere and dynamically restricts SSH (port 22) access to your current IP address.

---

## 📋 Prerequisites

Before you can run this project, you must have the following:

1.  **Terraform:** Installed on your local machine.
2.  **AWS Account:** An active AWS account.
3.  **S3 Bucket:** An S3 bucket to store the Terraform state. You will need to update the `backend "s3"` block in `main.tf` with your bucket name.
4.  **AWS Secrets Manager Secret:** A secret stored in AWS Secrets Manager that contains your AWS credentials in JSON format. The structure should be:
    ```json
    {
      "aws_access_key": "YOUR_ACCESS_KEY",
      "aws_secret_access_key": "YOUR_SECRET_KEY"
    }
    ```
    You must provide the ARN of this secret in your `terraform.tfvars` file.

---

## ⚙️ Configuration & Deployment

1.  **Clone the Repository:**
    ```sh
    git clone <your-repository-url>
    cd <repository-directory>
    ```

2.  **Configure Backend (Optional):**
    If necessary, update the `main.tf` file to point to your S3 bucket for the Terraform backend.

3.  **Create Variables File:**
    Create a file named `terraform.tfvars` and add the ARN of your secret:
    ```hcl
    # terraform.tfvars
    blue-green-user-secret = "arn:aws:secretsmanager:us-east-1:..."
    ```
    You can also override other default variables (like `aws_region`, `aws_ami`, or `instance_type`) in this file.

4.  **Initialize Terraform:**
    This will download the required providers and configure the S3 backend.
    ```sh
    terraform init
    ```

5.  **Plan the Deployment:**
    Review the changes Terraform will make.
    ```sh
    terraform plan
    ```

6.  **Apply the Configuration:**
    Build the infrastructure on AWS.
    ```sh
    terraform apply
    ```

---

## 🖥️ Usage

After the `terraform apply` command completes successfully, Terraform will display the outputs.

1.  Find the `proxy_server_public_ip` in the output.
2.  Open this IP address in your web browser (e.g., `http://<proxy_server_public_ip>`).
3.  You should see the **"Welcome to the Green Deployment"** page, as NGINX routes traffic to the Green server by default.

You can also access the Blue and Green servers directly using their respective public IPs, which are also provided in the outputs.

---

## 🔐 IAM Least Privilege Policies

As mentioned in the introduction, here are the recommended least-privilege policies for the two IAM users/roles.

### 1. Policy for the Terraform Executor

This policy allows the user/role running Terraform to access the S3 backend state file and read the project credentials from Secrets Manager.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TerraformS3BackendAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::liorm-portfolio-tfstate/blue-green-tfstate/terraform.tfstate"
        },
        {
            "Sid": "TerraformS3BackendList",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::liorm-portfolio-tfstate",
            "Condition": {
                "StringEquals": {
                    "s3:prefix": "blue-green-tfstate/"
                }
            }
        },
        {
            "Sid": "ReadProjectCredentialsSecret",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:us-east-1:704505749045:secret:blue-green-creds-qazpEp"
        }
    ]
}