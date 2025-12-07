# 1. Data Source: Default VPC
data "aws_vpc" "default" {
  default = true
}

# 2. Data Source: Subnets of Default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 3. Data Source: First Subnet Details (to get AZ)
data "aws_subnet" "first" {
  id = data.aws_subnets.default.ids[0]
}

# 4. Security Group (in Default VPC)
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Allow inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# 5. Data Source for AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ==========================================
# INSTANCE 1: With Elastic IP & EBS Volume
# ==========================================

resource "aws_instance" "node_one" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.first.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.key_pair_name

  # Updated User Data to Automate Mount
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Node 1 (EIP + EBS)</h1>" > /var/www/html/index.html

              # --- Automate EBS Mounting ---
              # Device name defined in Terraform attachment
              DEVICE="/dev/sdh"
              MOUNT_POINT="/data"

              # 1. Create mount point
              mkdir -p $MOUNT_POINT

              # 2. Wait for device to be attached (sometimes takes a few seconds)
              while [ ! -e $DEVICE ]; do echo "Waiting for disk..."; sleep 5; done

              # 3. Check if file system exists, if not create it (xfs)
              if ! blkid $DEVICE; then
                  echo "Formatting disk..."
                  mkfs -t xfs $DEVICE
              fi

              # 4. Mount the disk
              mount $DEVICE $MOUNT_POINT

              # 5. Persist mapping in /etc/fstab for reboots
              UUID=$(blkid -s UUID -o value $DEVICE)
              if ! grep -q "$UUID" /etc/fstab; then
                  echo "UUID=$UUID $MOUNT_POINT xfs defaults,nofail 0 2" >> /etc/fstab
              fi
              
              # Set permissions so we can write to it easily (optional)
              chmod 777 $MOUNT_POINT
              EOF

  tags = {
    Name = "${var.project_name}-node-1-eip-ebs"
  }
}

# Elastic IP for Node 1
resource "aws_eip" "node_one_eip" {
  domain   = "vpc"
  instance = aws_instance.node_one.id

  tags = {
    Name = "${var.project_name}-node-1-eip"
  }
}

# EBS Volume for Node 1
resource "aws_ebs_volume" "node_one_vol" {
  availability_zone = data.aws_subnet.first.availability_zone
  size              = 10
  type              = "gp3"

  tags = {
    Name = "${var.project_name}-node-1-volume"
  }
}

# EBS Attachment for Node 1
resource "aws_volume_attachment" "node_one_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.node_one_vol.id
  instance_id = aws_instance.node_one.id
}

# ==========================================
# INSTANCE 2: Simple (No EIP, No Extra EBS)
# ==========================================

resource "aws_instance" "node_two" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.first.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.key_pair_name

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Node 2 (Simple)</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "${var.project_name}-node-2-simple"
  }
}
