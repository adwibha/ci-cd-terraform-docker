## CI/CD Pipeline with GitHub Actions, AWS, Terraform, Docker, and ECS

### Overview

This project demonstrates how to set up a CI/CD pipeline using **GitHub Actions**, **AWS** services (like ECS, ECR), **Terraform** (for infrastructure as code), and **Docker** (for containerizing the Flask application). The pipeline automates the entire process of building, testing, and deploying a Flask app to **Amazon ECS**.

The workflow involves:

1. **GitHub Actions**: CI/CD pipeline that handles the automation of the process.
2. **Docker**: To build the container image of the Flask application.
3. **Terraform**: For provisioning AWS infrastructure (ECR, ECS, etc.).
4. **AWS**: The platform where the application will be deployed (using ECS and ECR).

---

### Prerequisites

- **AWS Account** with ECR and ECS permissions.
- **AWS CLI** configured on your local machine for initial setup (only for AWS credentials).
- **Docker** installed for building the image locally (if needed).
- **GitHub Account** with repository access for the pipeline.
- **Terraform** installed for provisioning infrastructure (Terraform CLI on your machine for initial setup).
- **GitHub Actions Secrets** to securely manage AWS credentials (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`).

---

### Project Structure

The project is structured as follows:

```
ci-cd-terraform-docker/
├── app/
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── .github/
│   └── workflows/
│       └── deploy.yml
└── README.md
```

### Description of Directories and Files:

- **app/**: Contains the Flask app and Docker configuration files.

  - `Dockerfile`: Defines the Docker image for the Flask app.
  - `app.py`: Simple Flask app to test the pipeline.
  - `requirements.txt`: Python dependencies for the Flask app.

- **terraform/**: Contains Terraform files for provisioning the necessary AWS infrastructure.

  - `main.tf`: Main Terraform configuration file that provisions AWS resources like ECR and ECS.
  - `variables.tf`: Defines variables used in the `main.tf` file.
  - `outputs.tf`: Outputs the results of the Terraform commands (like ECR repository URL).

- **.github/workflows/deploy.yml**: Defines the GitHub Actions workflow for the CI/CD pipeline.

---

## Setup and Deployment

### Step 1: Set Up GitHub Secrets

Before starting with GitHub Actions, you'll need to set up your AWS credentials in GitHub Secrets to securely authenticate and deploy the app.

1. Go to your GitHub repository.
2. Navigate to **Settings > Secrets and Variables > Actions**.
3. Click **New repository secret**.
4. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS Access Key ID.
   - `AWS_SECRET_ACCESS_KEY`: Your AWS Secret Access Key.

### Step 2: Define AWS Infrastructure with Terraform

The Terraform files will automatically create the necessary AWS infrastructure:

- **ECR (Elastic Container Registry)**: For storing the Docker image.
- **ECS (Elastic Container Service)**: To deploy and run the containerized app.

Run Terraform locally (once) to create the infrastructure, or let GitHub Actions handle it automatically during the CI/CD pipeline.

#### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

#### 2. Apply Terraform

```bash
terraform apply -auto-approve
```

This will create the required AWS resources. The `outputs.tf` will display the ECR URL.

### Step 3: GitHub Actions CI/CD Pipeline

The pipeline is defined in the `.github/workflows/deploy.yml` file. Here's a breakdown of the pipeline:

1. **Trigger**: It triggers on any push to the `main` branch.
2. **Jobs**:
   - **Checkout Code**: Retrieves the code from the GitHub repository.
   - **Configure AWS Credentials**: Sets up AWS credentials using GitHub secrets.
   - **Deploy Infrastructure with Terraform**: Initializes and applies Terraform configurations to provision AWS resources (ECR, ECS).
   - **Build Docker Image**: Builds the Docker image for the Flask app.
   - **Push Docker Image to ECR**: Pushes the built Docker image to AWS ECR.
   - **Deploy to ECS**: Deploys the Docker image to the ECS cluster using the task definition and service.

---

## GitHub Actions Workflow Breakdown

Here’s the `deploy.yml` workflow file in detail:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-22.04

    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Configure AWS Credentials
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
          aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
          aws configure set default.region us-east-1

      - name: Deploy Infrastructure with Terraform
        working-directory: terraform
        env:
          TF_LOG: WARN # Set Terraform log level
        run: |
          terraform init
          terraform apply -auto-approve

      - name: Get ECR Repository URL from Terraform Outputs
        id: ecr
        working-directory: terraform
        run: |
          ECR_REPOSITORY_URL=$(terraform output -raw ecr_repository_url)
          echo "ECR_REPOSITORY_URL=$ECR_REPOSITORY_URL" >> $GITHUB_ENV  # Set environment variable for use in subsequent steps
          echo "ECR_REPOSITORY_URL: $ECR_REPOSITORY_URL"  # Debugging: log the URL

      - name: Build Docker Image
        run: |
          docker build -t my-app -f ./app/Dockerfile ./app
          docker tag my-app:latest ${{ env.ECR_REPOSITORY_URL }}:latest

      - name: Log in to Amazon ECR
        run: |
          aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${{ env.ECR_REPOSITORY_URL }}

      - name: Push Docker Image to Amazon ECR
        run: |
          docker push ${{ env.ECR_REPOSITORY_URL }}:latest
```

### Explanation of the Workflow:

- **Trigger on Push**: The pipeline will trigger when code is pushed to the `main` branch.
- **AWS Credentials Configuration**: AWS credentials are configured using secrets stored in GitHub.
- **Terraform Execution**: Initializes and applies the Terraform configuration, creating ECR and ECS resources.
- **Docker Build and Push**: The Docker image is built using the `Dockerfile` from the `app/` directory, tagged with the ECR repository URL, and pushed to ECR.
- **Deploy to ECS**: Once the Docker image is pushed to ECR, it can be used by ECS to deploy the application.

---

## Clean Up

If you want to destroy the AWS infrastructure created by Terraform, run the following command:

```bash
cd terraform
terraform destroy
```

This will remove all AWS resources like the ECR repository and ECS cluster.

---

## Conclusion

By following this CI/CD pipeline, you can automatically deploy any changes made to your Flask app to AWS ECS using Docker, Terraform, and GitHub Actions. This setup allows you to fully automate the deployment process and ensures consistent environments from development to production.
