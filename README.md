# CI/CD Pipeline with GitHub Actions, AWS, Terraform, Docker, and ECS

This project demonstrates a fully automated CI/CD pipeline to build, test, and deploy a Flask application to **AWS ECS** using:

- **GitHub Actions** for CI/CD orchestration.
- **AWS ECS and ECR** for container deployment.
- **Terraform** for infrastructure provisioning.
- **Docker** for containerization.

---

## Features

- Automated Docker image build and push to Amazon ECR.
- Provisioning of ECS, ECR, and associated AWS infrastructure with Terraform.
- Deployment of the Flask application to ECS using GitHub Actions workflows.
- Continuous integration and deployment triggered by changes to the `main` branch.

---

## Prerequisites

Before starting, ensure you have the following:

1. **AWS Account** with permissions to manage ECS, ECR, and IAM.
2. **AWS CLI** installed and configured locally.
3. **Terraform** CLI installed for infrastructure provisioning.
4. **Docker** installed for running containers.
5. **GitHub Account** with access to the repository for managing workflows.
6. **GitHub Actions Secrets** configured for AWS credentials:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

---

## Project Structure
```
.
├── app/                    # Flask application source code
│   ├── app.py              # Main application file
│   ├── requirements.txt    # Python dependencies
├── terraform/              # Terraform configuration files
│   ├── main.tf             # Main infrastructure configuration
│   ├── variables.tf        # Variables definition
│   ├── outputs.tf          # Outputs configuration
├── .github/workflows/      # GitHub Actions workflows
│   ├── deploy.yml          # CI/CD workflow file
├── README.md               # Project documentation
├── Dockerfile              # Docker build configuration
```

---

## Setup and Deployment

### Step 1: Configure GitHub Secrets

1. Open your GitHub repository.
2. Go to **Settings > Secrets and Variables > Actions**.
3. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.

### Step 2: Provision AWS Infrastructure with Terraform

1. Navigate to the `terraform` directory:
   ```bash
   cd terraform
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Apply the Terraform configurations to create AWS resources:
   ```bash
   terraform apply -auto-approve
   ```
4. Note the ECR repository URL from the Terraform outputs.

### Step 3: Set Up the GitHub Actions Workflow

1. Ensure the `.github/workflows/deploy.yml` file is present in your repository.
2. Commit and push your repository to GitHub:
   ```bash
   git add .
   git commit -m "Add CI/CD pipeline"
   git push origin main
   ```
3. On every push to the `main` branch, the GitHub Actions workflow will:
   - Build and test the Docker image.
   - Push the Docker image to Amazon ECR.
   - Deploy the application to Amazon ECS.

### Step 4: Verify Deployment

1. Log in to the AWS Management Console.
2. Navigate to **ECS > Clusters > Services** and ensure the service is running.
3. Access the application via the load balancer URL or public IP of the ECS task.

---

## Running the Application Locally Using ECR Image

To run the application locally using the Docker image pulled from Amazon ECR:

### Step 1: Authenticate Docker with AWS ECR

1. Use the AWS CLI to authenticate Docker with your Amazon ECR registry. Replace `<aws-region>` and `<aws-account-id>` with your AWS region and account ID:
   ```bash
   aws ecr get-login-password --region <aws-region> | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com
   ```

### Step 2: Pull the Docker Image from ECR

1. Pull the Docker image from the ECR repository. Replace `<repository-name>` with your ECR repository name and `<aws-region>` with the AWS region:
   ```bash
   docker pull <aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com/<repository-name>:latest
   ```

### Step 3: Run the Docker Container Locally

1. Run the Docker container:
   ```bash
   docker run -d -p 5000:5000 <aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com/<repository-name>:latest
   ```

2. Open your browser and visit:
   ```
   http://localhost:5000
   ```

<img width="763" alt="Screenshot 2025-01-13 at 1 41 38 PM" src="https://github.com/user-attachments/assets/acb8cde5-67f3-4dcf-822e-5c1ed580c158" />

---

## Clean-Up

To clean up the AWS resources created by Terraform:

1. Navigate to the `terraform` directory:
   ```bash
   cd terraform
   ```
2. Destroy the infrastructure:
   ```bash
   terraform destroy -auto-approve
   ```
3. Confirm the removal of resources in the AWS Management Console.

---

## Workflow Diagram

```plaintext
GitHub Actions
    |
    +-- Build Docker Image
    |
    +-- Push to Amazon ECR
    |
    +-- Deploy to Amazon ECS
```

---

## Conclusion

This project provides a comprehensive CI/CD pipeline for deploying containerized applications using modern DevOps tools. It automates the entire process, from building and testing to deploying and running the application on AWS ECS.
