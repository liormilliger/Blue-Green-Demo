# AWS Blue/Green Deployment with Terraform and NGINX

This project provisions a basic Blue/Green deployment infrastructure on AWS using Terraform. It deploys two application servers ("Blue" and "Green") running Apache and one NGINX server that acts as a reverse proxy.

The NGINX proxy is configured to perform active/passive load balancing. It directs all primary traffic to the **Green** server. The **Blue** server is configured as a backup, and NGINX will automatically failover traffic to it if the Green server becomes unavailable.

## 🚀 Features

* **Infrastructure as Code:** All infrastructure is defined using Terraform.
* [cite_start]**Blue/Green Architecture:** Deploys three EC2 instances: one NGINX proxy, one "Blue" app server, and one "Green" app server. [cite: 1]
* [cite_start]**Automated Setup:** Uses `user-data` scripts to automatically install and configure Apache on the app servers and NGINX on the proxy server. [cite: 1]
* [cite_start]**Secure Credentials:** Avoids hardcoded keys by fetching AWS credentials at runtime from AWS Secrets Manager. [cite: 3, 5]
* [cite_start]**Remote State:** Configured to use an S3 bucket for secure and persistent Terraform state management. [cite: 3]
* [cite_start]**Dynamic Security:** The web security group allows HTTP (port 80) from anywhere [cite: 10] [cite_start]and dynamically restricts SSH (port 22) access to your current IP address. [cite: 10, 11]

## 📋 Prerequisites

Before you can run this project, you must have the following:

1.  **Terraform:** Installed on your local machine.
2.  **AWS Account:** An active AWS account.
3.  **S3 Bucket:** An S3 bucket to store the Terraform state. [cite_start]You will need to update the `backend "s3"` block in `main.tf` with your bucket name. [cite: 3]
4.  [cite_start]**AWS Secrets Manager Secret:** A secret stored in AWS Secrets Manager that contains your AWS credentials in JSON format. [cite: 3] The structure should be:
    ```json
    {
      "aws_access_key": "YOUR_ACCESS_KEY",
      "aws_secret_access_key": "YOUR_SECRET_KEY"
    }
    ```
    [cite_start]You must provide the ARN of this secret in your `terraform.tfvars` file. [cite: 12]

## ⚙️ Configuration & Deployment

1.  **Clone the Repository:**
    ```sh
    git clone <your-repository-url>
    cd <repository-directory>
    ```

2.  **Configure Backend (Optional):**
    [cite_start]If necessary, update the `main.tf` file to point to your S3 bucket for the Terraform backend. [cite: 3]

3.  **Create Variables File:**
    [cite_start]Create a file named `terraform.tfvars` and add the ARN of your secret: [cite: 12]
    ```hcl
    # terraform.tfvars
    blue-green-user-secret = "arn:aws:secretsmanager:us-east-1:..."
    ```
    [cite_start]You can also override other default variables (like `aws_region`, `aws_ami`, or `instance_type`) in this file. [cite: 4]

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

## Usage

[cite_start]After the `terraform apply` command completes successfully, Terraform will display the outputs. [cite: 6]

1.  [cite_start]Find the `proxy_server_public_ip` in the output. [cite: 7]
2.  Open this IP address in your web browser (e.g., `http://<proxy_server_public_ip>`).
3.  You should see the **"Welcome to the Green Deployment"** page, as NGINX routes traffic to the Green server by default.

[cite_start]You can also access the Blue and Green servers directly using their respective public IPs, which are also provided in the outputs. [cite: 8, 9]

## 🗂️ File Structure

* [cite_start]`main.tf`: Configures the Terraform S3 backend and the AWS providers, including the secure credential fetching from Secrets Manager. [cite: 3]
* [cite_start]`instances.tf`: Defines the three EC2 instances (`blue_server`, `green_server`, `proxy_server`). [cite: 1]
* [cite_start]`security-groups.tf`: Creates the `web_sg` security group for the instances. [cite: 10]
* [cite_start]`variables.tf`: Declares all input variables for the project, such as `aws_region`, `instance_type`, and `blue-green-user-secret`. [cite: 4, 5]
* [cite_start]`outputs.tf`: Declares the outputs, such as the public IPs of the three servers. [cite: 6, 7, 8, 9]
* [cite_start]`terraform.tfvars`: (User-created) Provides the value for the `blue-green-user-secret` variable. [cite: 12]
* `user-data-blue.sh`: Bootstrap script for the Blue server (Apache).
* `user-data-green.sh`: Bootstrap script for the Green server (Apache).
* `user-data-proxy.sh`: Bootstrap script for the NGINX proxy server, which templates in the private IPs of the Blue and Green servers.

## 🧹 Cleanup

To destroy all the resources created by this project, run:
```sh
terraform destroy