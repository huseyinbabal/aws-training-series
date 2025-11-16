.PHONY: help create-vpc create-public-subnet create-private-subnet create-keypair create-security-group authorize-ssh launch-ec2 get-ec2-ip create-igw attach-igw create-public-route-table add-public-route associate-public-subnet allocate-eip create-nat-gateway create-private-route-table add-private-route associate-private-subnet ssh-connect cleanup show-region
GREEN := \033[0;32m
YELLOW := \033[0;33m
CYAN := \033[0;36m
NC := \033[0m # No Color

# AWS Profile (default to 'dev', can be overridden)
AWS_PROFILE ?= dev

# Get AWS region from CLI config for the specified profile
AWS_REGION := $(shell aws configure get region --profile $(AWS_PROFILE))
AWS_AZ := $(AWS_REGION)a

# AWS CLI command with profile
AWS := aws --profile $(AWS_PROFILE)

AMI_ID := ami-0ecb62995f68bb549 
# Default target
help:
	@echo "$(CYAN)AWS VPC Demo Makefile$(NC)"
	@echo ""
	@echo "$(GREEN)Current AWS Configuration:$(NC)"
	@echo "  Profile: $(YELLOW)$(AWS_PROFILE)$(NC)"
	@echo "  Region: $(YELLOW)$(AWS_REGION)$(NC)"
	@echo "  Availability Zone: $(YELLOW)$(AWS_AZ)$(NC)"
	@echo ""
	@echo "$(GREEN)Available targets:$(NC)"
	@echo "  $(YELLOW)show-region$(NC)               - Show current AWS region configuration"
	@echo "  $(YELLOW)create-vpc$(NC)                - Create VPC"
	@echo "  $(YELLOW)create-public-subnet$(NC)      - Create Public Subnet"
	@echo "  $(YELLOW)create-private-subnet$(NC)     - Create Private Subnet"
	@echo "  $(YELLOW)create-keypair$(NC)            - Create EC2 Key Pair"
	@echo "  $(YELLOW)create-security-group$(NC)     - Create Security Group for SSH"
	@echo "  $(YELLOW)authorize-ssh$(NC)             - Add SSH ingress rule to Security Group"
	@echo "  $(YELLOW)launch-ec2$(NC)                - Launch EC2 instance in Public Subnet"
	@echo "  $(YELLOW)get-ec2-ip$(NC)                - Get EC2 instance Public IP"
	@echo "  $(YELLOW)create-igw$(NC)                - Create Internet Gateway"
	@echo "  $(YELLOW)attach-igw$(NC)                - Attach Internet Gateway to VPC"
	@echo "  $(YELLOW)create-public-route-table$(NC) - Create Public Route Table"
	@echo "  $(YELLOW)add-public-route$(NC)          - Add route to Internet Gateway"
	@echo "  $(YELLOW)associate-public-subnet$(NC)   - Associate Public Subnet with Route Table"
	@echo "  $(YELLOW)allocate-eip$(NC)              - Allocate Elastic IP for NAT Gateway"
	@echo "  $(YELLOW)create-nat-gateway$(NC)        - Create NAT Gateway"
	@echo "  $(YELLOW)create-private-route-table$(NC)- Create Private Route Table"
	@echo "  $(YELLOW)add-private-route$(NC)         - Add route to NAT Gateway"
	@echo "  $(YELLOW)associate-private-subnet$(NC)  - Associate Private Subnet with Route Table"
	@echo "  $(YELLOW)ssh-connect$(NC)               - SSH to EC2 instance"
	@echo "  $(YELLOW)cleanup$(NC)                   - Clean up all resources"
	@echo ""
	@echo "$(GREEN)Usage:$(NC)"
	@echo "  make <target> AWS_PROFILE=dev    (default profile is 'dev')"
	@echo ""
	@echo "$(GREEN)Note:$(NC) Export variables will be printed. Copy them to use in subsequent commands."

show-region:
	@echo "$(CYAN)==> AWS Configuration$(NC)"
	@echo "$(GREEN)Profile:$(NC) $(AWS_PROFILE)"
	@echo "$(GREEN)Region:$(NC) $(AWS_REGION)"
	@echo "$(GREEN)Availability Zone:$(NC) $(AWS_AZ)"
	@echo ""
	@echo "$(YELLOW)To change profile, run:$(NC) make <target> AWS_PROFILE=<profile-name>"
	@echo "$(YELLOW)To change region, run:$(NC) aws configure set region <region-name> --profile $(AWS_PROFILE)"

create-vpc:
	@echo "$(AWS) ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text"
	@VPC_ID=$$($(AWS) ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text); \
	echo "$$VPC_ID"; \
	echo ""; \
	echo "export VPC_ID=$$VPC_ID"

create-public-subnet:
	@if [ -z "$$VPC_ID" ]; then echo "Error: VPC_ID not set"; exit 1; fi
	@echo "$(AWS) ec2 create-subnet --vpc-id $$VPC_ID --cidr-block 10.0.1.0/24 --availability-zone $(AWS_AZ) --query 'Subnet.SubnetId' --output text"
	@PUBLIC_SUBNET_ID=$$($(AWS) ec2 create-subnet --vpc-id $$VPC_ID --cidr-block 10.0.1.0/24 --availability-zone $(AWS_AZ) --query 'Subnet.SubnetId' --output text); \
	echo "$$PUBLIC_SUBNET_ID"; \
	echo ""; \
	echo "export PUBLIC_SUBNET_ID=$$PUBLIC_SUBNET_ID"

create-private-subnet:
	@if [ -z "$$VPC_ID" ]; then echo "Error: VPC_ID not set"; exit 1; fi
	@echo "$(AWS) ec2 create-subnet --vpc-id $$VPC_ID --cidr-block 10.0.2.0/24 --availability-zone $(AWS_AZ) --query 'Subnet.SubnetId' --output text"
	@PRIVATE_SUBNET_ID=$$($(AWS) ec2 create-subnet --vpc-id $$VPC_ID --cidr-block 10.0.2.0/24 --availability-zone $(AWS_AZ) --query 'Subnet.SubnetId' --output text); \
	echo "$$PRIVATE_SUBNET_ID"; \
	echo ""; \
	echo "export PRIVATE_SUBNET_ID=$$PRIVATE_SUBNET_ID"

create-keypair:
	@echo "$(AWS) ec2 create-key-pair --key-name MyVPCKey --query 'KeyMaterial' --output text > MyVPCKey.pem"
	@$(AWS) ec2 create-key-pair --key-name MyVPCKey --query 'KeyMaterial' --output text > MyVPCKey.pem
	@echo "chmod 400 MyVPCKey.pem"
	@chmod 400 MyVPCKey.pem

create-security-group:
	@if [ -z "$$VPC_ID" ]; then echo "Error: VPC_ID not set"; exit 1; fi
	@echo "$(AWS) ec2 create-security-group --group-name SSHAccess --description \"Allow SSH access\" --vpc-id $$VPC_ID --query 'GroupId' --output text"
	@SG_ID=$$($(AWS) ec2 create-security-group --group-name SSHAccess --description "Allow SSH access" --vpc-id $$VPC_ID --query 'GroupId' --output text); \
	echo "$$SG_ID"; \
	echo ""; \
	echo "export SG_ID=$$SG_ID"

authorize-ssh:
	@if [ -z "$$SG_ID" ]; then echo "Error: SG_ID not set"; exit 1; fi
	@echo "$(AWS) ec2 authorize-security-group-ingress --group-id $$SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0"
	@$(AWS) ec2 authorize-security-group-ingress --group-id $$SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0

launch-ec2:
	@if [ -z "$$PUBLIC_SUBNET_ID" ]; then echo "Error: PUBLIC_SUBNET_ID not set"; exit 1; fi
	@if [ -z "$$SG_ID" ]; then echo "Error: SG_ID not set"; exit 1; fi
	echo "$(AWS) ec2 run-instances --image-id $$AMI_ID --instance-type t3.small --key-name MyVPCKey --security-group-ids $$SG_ID --subnet-id $$PUBLIC_SUBNET_ID --associate-public-ip-address --query 'Instances[0].InstanceId' --output text"; \
	EC2_INSTANCE_ID=$$($(AWS) ec2 run-instances --image-id $(AMI_ID) --instance-type t3.small --key-name MyVPCKey --security-group-ids $$SG_ID --subnet-id $$PUBLIC_SUBNET_ID --associate-public-ip-address --query 'Instances[0].InstanceId' --output text); \
	echo "$$EC2_INSTANCE_ID"; \
	echo ""; \
	echo "export EC2_INSTANCE_ID=$$EC2_INSTANCE_ID"

get-ec2-ip:
	@if [ -z "$$EC2_INSTANCE_ID" ]; then echo "Error: EC2_INSTANCE_ID not set"; exit 1; fi
	@echo "$(AWS) ec2 describe-instances --instance-ids $$EC2_INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text"
	@EC2_PUBLIC_IP=$$($(AWS) ec2 describe-instances --instance-ids $$EC2_INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text); \
	echo "$$EC2_PUBLIC_IP"; \
	echo ""; \
	echo "export EC2_PUBLIC_IP=$$EC2_PUBLIC_IP"

create-igw:
	@echo "$(AWS) ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text"
	@IGW_ID=$$($(AWS) ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text); \
	echo "$$IGW_ID"; \
	echo ""; \
	echo "export IGW_ID=$$IGW_ID"

attach-igw:
	@if [ -z "$$VPC_ID" ]; then echo "Error: VPC_ID not set"; exit 1; fi
	@if [ -z "$$IGW_ID" ]; then echo "Error: IGW_ID not set"; exit 1; fi
	@echo "$(AWS) ec2 attach-internet-gateway --vpc-id $$VPC_ID --internet-gateway-id $$IGW_ID"
	@$(AWS) ec2 attach-internet-gateway --vpc-id $$VPC_ID --internet-gateway-id $$IGW_ID

create-public-route-table:
	@if [ -z "$$VPC_ID" ]; then echo "Error: VPC_ID not set"; exit 1; fi
	@echo "$(AWS) ec2 create-route-table --vpc-id $$VPC_ID --query 'RouteTable.RouteTableId' --output text"
	@PUBLIC_RTB_ID=$$($(AWS) ec2 create-route-table --vpc-id $$VPC_ID --query 'RouteTable.RouteTableId' --output text); \
	echo "$$PUBLIC_RTB_ID"; \
	echo ""; \
	echo "export PUBLIC_RTB_ID=$$PUBLIC_RTB_ID"

add-public-route:
	@if [ -z "$$PUBLIC_RTB_ID" ]; then echo "Error: PUBLIC_RTB_ID not set"; exit 1; fi
	@if [ -z "$$IGW_ID" ]; then echo "Error: IGW_ID not set"; exit 1; fi
	@echo "$(AWS) ec2 create-route --route-table-id $$PUBLIC_RTB_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $$IGW_ID"
	@$(AWS) ec2 create-route --route-table-id $$PUBLIC_RTB_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $$IGW_ID

associate-public-subnet:
	@if [ -z "$$PUBLIC_SUBNET_ID" ]; then echo "Error: PUBLIC_SUBNET_ID not set"; exit 1; fi
	@if [ -z "$$PUBLIC_RTB_ID" ]; then echo "Error: PUBLIC_RTB_ID not set"; exit 1; fi
	@echo "$(AWS) ec2 associate-route-table --subnet-id $$PUBLIC_SUBNET_ID --route-table-id $$PUBLIC_RTB_ID"
	@$(AWS) ec2 associate-route-table --subnet-id $$PUBLIC_SUBNET_ID --route-table-id $$PUBLIC_RTB_ID

allocate-eip:
	@echo "$(AWS) ec2 allocate-address --domain vpc --query 'AllocationId' --output text"
	@EIP_ALLOC_ID=$$($(AWS) ec2 allocate-address --domain vpc --query 'AllocationId' --output text); \
	echo "$$EIP_ALLOC_ID"; \
	echo ""; \
	echo "export EIP_ALLOC_ID=$$EIP_ALLOC_ID"

create-nat-gateway:
	@if [ -z "$$PUBLIC_SUBNET_ID" ]; then echo "Error: PUBLIC_SUBNET_ID not set"; exit 1; fi
	@if [ -z "$$EIP_ALLOC_ID" ]; then echo "Error: EIP_ALLOC_ID not set"; exit 1; fi
	@echo "$(AWS) ec2 create-nat-gateway --subnet-id $$PUBLIC_SUBNET_ID --allocation-id $$EIP_ALLOC_ID --query 'NatGateway.NatGatewayId' --output text"
	@NAT_GATEWAY_ID=$$($(AWS) ec2 create-nat-gateway --subnet-id $$PUBLIC_SUBNET_ID --allocation-id $$EIP_ALLOC_ID --query 'NatGateway.NatGatewayId' --output text); \
	echo "$$NAT_GATEWAY_ID"; \
	echo ""; \
	echo "export NAT_GATEWAY_ID=$$NAT_GATEWAY_ID"

create-private-route-table:
	@if [ -z "$$VPC_ID" ]; then echo "Error: VPC_ID not set"; exit 1; fi
	@echo "$(AWS) ec2 create-route-table --vpc-id $$VPC_ID --query 'RouteTable.RouteTableId' --output text"
	@PRIVATE_RTB_ID=$$($(AWS) ec2 create-route-table --vpc-id $$VPC_ID --query 'RouteTable.RouteTableId' --output text); \
	echo "$$PRIVATE_RTB_ID"; \
	echo ""; \
	echo "export PRIVATE_RTB_ID=$$PRIVATE_RTB_ID"

add-private-route:
	@if [ -z "$$PRIVATE_RTB_ID" ]; then echo "Error: PRIVATE_RTB_ID not set"; exit 1; fi
	@if [ -z "$$NAT_GATEWAY_ID" ]; then echo "Error: NAT_GATEWAY_ID not set"; exit 1; fi
	@echo "$(AWS) ec2 create-route --route-table-id $$PRIVATE_RTB_ID --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $$NAT_GATEWAY_ID"
	@$(AWS) ec2 create-route --route-table-id $$PRIVATE_RTB_ID --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $$NAT_GATEWAY_ID

associate-private-subnet:
	@if [ -z "$$PRIVATE_SUBNET_ID" ]; then echo "Error: PRIVATE_SUBNET_ID not set"; exit 1; fi
	@if [ -z "$$PRIVATE_RTB_ID" ]; then echo "Error: PRIVATE_RTB_ID not set"; exit 1; fi
	@echo "$(AWS) ec2 associate-route-table --subnet-id $$PRIVATE_SUBNET_ID --route-table-id $$PRIVATE_RTB_ID"
	@$(AWS) ec2 associate-route-table --subnet-id $$PRIVATE_SUBNET_ID --route-table-id $$PRIVATE_RTB_ID

ssh-connect:
	@if [ -z "$$EC2_PUBLIC_IP" ]; then echo "Error: EC2_PUBLIC_IP not set"; exit 1; fi
	@if [ ! -f MyVPCKey.pem ]; then echo "Error: MyVPCKey.pem not found"; exit 1; fi
	@echo "ssh -i MyVPCKey.pem ubuntu@$$EC2_PUBLIC_IP"
	@ssh -i MyVPCKey.pem ubuntu@$$EC2_PUBLIC_IP


cleanup:
	@echo "$(CYAN)Starting cleanup...$(NC)"

	# Terminate EC2 Instances
	@INSTANCE_IDS=$$($(AWS) ec2 describe-instances --filters "Name=instance-state-name,Values=pending,running,shutting-down,stopping,stopped" "Name=key-name,Values=MyVPCKey" --query "Reservations[].Instances[].InstanceId" --output text); \
	if [ -n "$$INSTANCE_IDS" ]; then \
		echo "Terminating EC2 instances: $$INSTANCE_IDS"; \
		$(AWS) ec2 terminate-instances --instance-ids $$INSTANCE_IDS; \
		echo "Waiting for instances to terminate..."; \
		$(AWS) ec2 wait instance-terminated --instance-ids $$INSTANCE_IDS; \
	else \
		echo "No running EC2 instances found with key 'MyVPCKey'."; \
	fi

	# Set VPC_ID
	@VPC_ID=$$($(AWS) ec2 describe-vpcs --filters "Name=cidr,Values=10.0.0.0/16" --query "Vpcs[0].VpcId" --output text 2>/dev/null); \
	if [ -z "$$VPC_ID" ] || [ "$$VPC_ID" == "None" ]; then \
		echo "No VPC found with CIDR 10.0.0.0/16. Skipping VPC-dependent cleanup."; \
	else \
		echo "Found VPC: $$VPC_ID. Proceeding with cleanup..."; \
		NAT_GATEWAY_IDS=$$($(AWS) ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$$VPC_ID" "Name=state,Values=pending,available" --query "NatGateways[].NatGatewayId" --output text); \
		for NAT_ID in $$NAT_GATEWAY_IDS; do \
			echo "Deleting NAT Gateway: $$NAT_ID"; \
			$(AWS) ec2 delete-nat-gateway --nat-gateway-id $$NAT_ID; \
			echo "Waiting for NAT Gateway $$NAT_ID to be deleted..."; \
			$(AWS) ec2 wait nat-gateway-deleted --nat-gateway-id $$NAT_ID; \
		done; \
		\
		EIP_ALLOC_IDS=$$($(AWS) ec2 describe-addresses --filters "Name=domain,Values=vpc" --query "Addresses[].AllocationId" --output text); \
		if [ -n "$$EIP_ALLOC_IDS" ]; then \
			for ALLOC_ID in $$EIP_ALLOC_IDS; do \
				echo "Releasing Elastic IP with allocation ID: $$ALLOC_ID"; \
				$(AWS) ec2 release-address --allocation-id $$ALLOC_ID; \
			done; \
		else \
			echo "No Elastic IPs found in VPC."; \
		fi; \
		\
		IGW_IDS=$$($(AWS) ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$$VPC_ID" --query "InternetGateways[].InternetGatewayId" --output text); \
		for IGW_ID in $$IGW_IDS; do \
			echo "Detaching Internet Gateway: $$IGW_ID from VPC: $$VPC_ID"; \
			$(AWS) ec2 detach-internet-gateway --internet-gateway-id $$IGW_ID --vpc-id $$VPC_ID; \
			echo "Deleting Internet Gateway: $$IGW_ID"; \
			$(AWS) ec2 delete-internet-gateway --internet-gateway-id $$IGW_ID; \
		done; \
		\
		ASSOCIATION_IDS=$$($(AWS) ec2 describe-route-tables --filters "Name=vpc-id,Values=$$VPC_ID" "Name=association.main,Values=false" --query "RouteTables[].Associations[].RouteTableAssociationId" --output text); \
		for ASSOC_ID in $$ASSOCIATION_IDS; do \
			echo "Disassociating Route Table Association: $$ASSOC_ID"; \
			$(AWS) ec2 disassociate-route-table --association-id $$ASSOC_ID; \
		done; \
		\
		RTB_IDS=$$($(AWS) ec2 describe-route-tables --filters "Name=vpc-id,Values=$$VPC_ID" "Name=association.main,Values=false" --query "RouteTables[].RouteTableId" --output text); \
		for RTB_ID in $$RTB_IDS; do \
			echo "Deleting Route Table: $$RTB_ID"; \
			$(AWS) ec2 delete-route-table --route-table-id $$RTB_ID; \
		done; \
		\
		SUBNET_IDS=$$($(AWS) ec2 describe-subnets --filters "Name=vpc-id,Values=$$VPC_ID" --query "Subnets[].SubnetId" --output text); \
		for SUBNET_ID in $$SUBNET_IDS; do \
			echo "Deleting Subnet: $$SUBNET_ID"; \
			$(AWS) ec2 delete-subnet --subnet-id $$SUBNET_ID; \
		done; \
		\
		SG_IDS=$$($(AWS) ec2 describe-security-groups --filters "Name=vpc-id,Values=$$VPC_ID" "Name=group-name,Values=SSHAccess" --query "SecurityGroups[?GroupName!='default'].GroupId" --output text); \
		for SG_ID in $$SG_IDS; do \
			echo "Deleting Security Group: $$SG_ID"; \
			$(AWS) ec2 delete-security-group --group-id $$SG_ID; \
		done; \
		\
		echo "Deleting VPC: $$VPC_ID"; \
		$(AWS) ec2 delete-vpc --vpc-id $$VPC_ID; \
	fi

	# Delete Key Pair
	@if $(AWS) ec2 describe-key-pairs --key-names MyVPCKey > /dev/null 2>&1; then \
		echo "Deleting Key Pair: MyVPCKey"; \
		$(AWS) ec2 delete-key-pair --key-name MyVPCKey; \
	else \
		echo "Key Pair 'MyVPCKey' not found."; \
	fi
	@if [ -f MyVPCKey.pem ]; then \
		echo "Deleting local key file: MyVPCKey.pem"; \
		rm -f MyVPCKey.pem; \
	fi

	@echo "$(GREEN)Cleanup complete.$(NC)"
