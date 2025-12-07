# EC2 Terraform Configuration

This repository contains Terraform configurations for provisioning EC2 instances on AWS, demonstrating various EC2 features including Elastic IPs, EBS volumes, and security groups.

## What This Configuration Creates

This Terraform configuration provisions the following AWS resources:

- **2 EC2 Instances:**
  - **Node 1:** EC2 instance with Elastic IP and additional EBS volume (10GB)
  - **Node 2:** Simple EC2 instance with dynamic public IP
- **Security Group:** Allows inbound traffic on ports 22 (SSH), 80 (HTTP), and 443 (HTTPS)
- **Elastic IP:** Static public IP address attached to Node 1
- **EBS Volume:** Additional 10GB GP3 volume automatically mounted to Node 1 at `/data`
- **Apache Web Server:** Installed and configured on both instances

## Requirements

To use these Terraform configurations, you will need:

- **Terraform CLI:** Ensure Terraform is installed on your system (version compatible with AWS provider ~> 5.0)
- **AWS Account & Credentials:** Configure your AWS credentials. This can be done via environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`), the AWS CLI configuration (`~/.aws/credentials`), or an IAM role
- **EC2 Key Pair:** An existing EC2 key pair named `ec2` in your AWS account (or modify `key_pair_name` in `variables.tf`)

## Configuration Variables

You can customize the deployment by modifying the following variables in `variables.tf` or by creating a `terraform.tfvars` file:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for deployment | `us-east-1` |
| `project_name` | Project name prefix for resources | `terraform-demo` |
| `instance_type` | EC2 instance type | `t3.small` |
| `allowed_ports` | Ports allowed in security group | `[22, 80, 443]` |
| `key_pair_name` | Name of existing EC2 key pair | `ec2` |

## Usage

### 1. Initialize Terraform

Initializes a working directory containing Terraform configuration files. This step downloads the necessary providers.

```bash
terraform init
```

### 2. Create an Execution Plan

Generates an execution plan, showing what actions Terraform will take to achieve the desired state defined in your configuration.

```bash
terraform plan
```

Review the plan carefully to understand what resources will be created.

### 3. Apply the Changes

Applies the changes required to reach the desired state of the configuration, as described in the plan.

```bash
terraform apply
```

Type `yes` when prompted to confirm the creation of resources.

### 4. Access Your Instances

After successful deployment, Terraform will output important information:

```bash
terraform output
```

You can access the web servers using the provided IP addresses:
- Node 1: `http://<node_1_eip_address>`
- Node 2: `http://<node_2_public_ip>`

To SSH into the instances:
```bash
ssh -i /path/to/your/key.pem ec2-user@<instance_ip>
```

### 5. Destroy the Infrastructure

Destroys the Terraform-managed infrastructure. **Use with caution!** This will deprovision all resources created by this configuration.

```bash
terraform destroy
```

## Outputs

After applying the configuration, you will see the following outputs:

- `vpc_id`: The ID of the default VPC used
- `node_1_eip_address`: The Elastic IP address of Node 1 (static)
- `node_1_volume_id`: The ID of the additional EBS volume attached to Node 1
- `node_2_public_ip`: The public IP address of Node 2 (dynamic)

## Notes

- This configuration uses the **default VPC** in your AWS account
- The EBS volume on Node 1 is automatically formatted (XFS) and mounted to `/data`
- Both instances run Amazon Linux 2 with Apache HTTP server
- Ensure your EC2 key pair exists before running `terraform apply`
- Resources will incur AWS charges while running

## Troubleshooting

**Issue:** Key pair not found
- **Solution:** Create an EC2 key pair named `ec2` in the AWS Console or update the `key_pair_name` variable

**Issue:** No default VPC available
- **Solution:** Create a default VPC or modify the configuration to use a custom VPC

**Issue:** Cannot access web server
- **Solution:** Wait a few minutes after deployment for user data script to complete, then verify security group rules
