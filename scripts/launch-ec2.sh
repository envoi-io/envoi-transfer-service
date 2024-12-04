#!/bin/bash

DEFAULT_AMI_ID=ami-080e1f13689e07408
DEFAULT_INSTANCE_TYPE=t3.large
DEFAULT_VOLUME_SIZE=100
DEFAULT_VOLUME_TYPE=gp2
DEFAULT_USER_DATA=""

# Arguments
# VPC_ID
# INSTANCE_TYPE
# KEY_PAIR_NAME
# INSTANCE_NAME
# SUBNET_ID
# ENI_NAME
# VOLUME_SIZE
# VOLUME_TYPE


# Replace with your desired values
VPC_ID=<your-vpc-id>

INSTANCE_TYPE=<your-instance-type>
KEY_PAIR_NAME=<your-key-pair-name>
INSTANCE_NAME=<your-instance-name>
SUBNET_ID=<your-subnet-id>
ENI_NAME=<your-eni-name>
VOLUME_SIZE=<your-volume-size-in-gib>
VOLUME_TYPE=<your-volume-type>



function select_vpc {
    # Get the list of VPCs
    VPCS=$(aws ec2 describe-vpcs --query 'Vpcs[].VpcId' --output text)

    # Convert the list into an array
    VPC_ARRAY=($VPCS)

    # Display the VPCs and ask the user to select one
    echo "Please select a VPC:"
    for i in "${!VPC_ARRAY[@]}"; do
        echo "$i) ${VPC_ARRAY[$i]}"
    done

    read -p "Enter the number of the VPC you want to select: " SELECTION

    # Get the selected VPC
    SELECTED_VPC=${VPC_ARRAY[$SELECTION]}

    echo "You selected VPC: $SELECTED_VPC"
}

function select_iam_role {
    # Get the list of IAM roles
    ROLES=$(aws iam list-roles --query 'Roles[].RoleName' --output text)

    # Convert the list into an array
    ROLE_ARRAY=($ROLES)

    # Display the IAM roles and ask the user to select one
    echo "Please select an IAM role:"
    for i in "${!ROLE_ARRAY[@]}"; do
        echo "$i) ${ROLE_ARRAY[$i]}"
    done

    read -p "Enter the number of the IAM role you want to select: " SELECTION

    # Get the selected IAM role
    SELECTED_ROLE=${ROLE_ARRAY[$SELECTION]}

    echo "You selected IAM role: $SELECTED_ROLE"
}

function select_key {
    # Get the list of key pairs
    KEY_PAIRS=$(aws ec2 describe-key-pairs --query 'KeyPairs[].KeyName' --output text)

    # Convert the list into an array
    KEY_PAIR_ARRAY=($KEY_PAIRS)

    # Display the key pairs and ask the user to select one
    echo "Please select a key pair:"
    for i in "${!KEY_PAIR_ARRAY[@]}"; do
        echo "$i) ${KEY_PAIR_ARRAY[$i]}"
    done


    read -p "Enter the number of the key pair you want to select: " SELECTION

    # Get the selected key pair
    SELECTED_KEY_PAIR=${KEY_PAIR_ARRAY[$SELECTION]}

    echo "You selected key pair: $SELECTED_KEY_PAIR"
}

function select_or_create_key {
    # Get the list of key pairs
    KEY_PAIRS=$(aws ec2 describe-key-pairs --query 'KeyPairs[].KeyName' --output text)

    # Convert the list into an array
    KEY_PAIR_ARRAY=($KEY_PAIRS)

    # Display the key pairs and ask the user to select one
    echo "Please select a key pair:"
    for i in "${!KEY_PAIR_ARRAY[@]}"; do
        echo "$i) ${KEY_PAIR_ARRAY[$i]}"
    done

    read -p "Enter the number of the key pair you want to select, or enter a new key pair name: " SELECTION

    # Check if the selection is a number
    if [[ $SELECTION =~ ^[0-9]+$ ]]; then
        # Get the selected key pair
        SELECTED_KEY_PAIR=${KEY_PAIR_ARRAY[$SELECTION]}
    else
        # Create a new key pair
        SELECTED_KEY_PAIR=$SELECTION

        # Create the key pair
        aws ec2 create-key-pair --key-name $SELECTED_KEY_PAIR --query 'KeyMaterial' --output text > $SELECTED_KEY_PAIR.pem

        # Change the permissions of the key pair file
        chmod 400 $SELECTED_KEY_PAIR.pem

        echo "Key pair created: $SELECTED_KEY_PAIR"
    fi

    echo "You selected key pair: $SELECTED_KEY_PAIR"
}

function select_or_create_ip {
    # Get the list of Elastic IPs
    EIPS=$(aws ec2 describe-addresses --query 'Addresses[].PublicIp' --output text)

    # Convert the list into an array
    EIP_ARRAY=($EIPS)

    # Display the Elastic IPs and ask the user to select one
    echo "Please select an Elastic IP:"
    for i in "${!EIP_ARRAY[@]}"; do
        echo "$i) ${EIP_ARRAY[$i]}"
    done

    read -p "Enter the number of the Elastic IP you want to select, or enter a new Elastic IP: " SELECTION

    # Check if the selection is a number
    if [[ $SELECTION =~ ^[0-9]+$ ]]; then
        # Get the selected Elastic IP
        SELECTED_EIP=${EIP_ARRAY[$SELECTION]}
    else
        # Allocate a new Elastic IP
        SELECTED_EIP=$(aws ec2 allocate-address --domain vpc --query 'PublicIp' --output text)

        echo "Elastic IP allocated: $SELECTED_EIP"
    fi

    echo "You selected Elastic IP: $SELECTED_EIP"
}

function select_subnet {
    # Get the list of subnets
    SUBNETS=$(aws ec2 describe-subnets --query 'Subnets[].SubnetId' --output text)

    # Convert the list into an array
    SUBNET_ARRAY=($SUBNETS)

    # Display the subnets and ask the user to select one
    echo "Please select a subnet:"
    for i in "${!SUBNET_ARRAY[@]}"; do
        echo "$i) ${SUBNET_ARRAY[$i]}"
    done

    read -p "Enter the number of the subnet you want to select: " SELECTION

    # Get the selected subnet
    SELECTED_SUBNET=${SUBNET_ARRAY[$SELECTION]}

    echo "You selected subnet: $SELECTED_SUBNET"
}

function select_or_create_eni {
    # Get the list of network interfaces
    ENIS=$(aws ec2 describe-network-interfaces --query 'NetworkInterfaces[].NetworkInterfaceId' --output text)

    # Convert the list into an array
    ENI_ARRAY=($ENIS)

    # Display the network interfaces and ask the user to select one
    echo "Please select a network interface:"
    for i in "${!ENI_ARRAY[@]}"; do
        echo "$i) ${ENI_ARRAY[$i]}"
    done

    read -p "Enter the number of the network interface you want to select, or enter a new network interface name: " SELECTION

    # Check if the selection is a number
    if [[ $SELECTION =~ ^[0-9]+$ ]]; then
        # Get the selected network interface
        SELECTED_ENI=${ENI_ARRAY[$SELECTION]}
    else
        # Create a new network interface
        SELECTED_ENI_NAME=$SELECTION

        # Create the network interface
        SELECTED_ENI=$(aws ec2 create-network-interface --subnet-id $SUBNET_ID --tag-specifications "ResourceType=eni,Tags=[{Key=Name,Value=$SELECTED_ENI_NAME}]" --query 'NetworkInterface.NetworkInterfaceId' --output text)

        echo "Network interface created: $SELECTED_ENI"
    fi

    echo "You selected network interface: $SELECTED_ENI"
}

function select_or_create_ebs_volume {
    # Get the list of EBS volumes
    VOLUMES=$(aws ec2 describe-volumes --query 'Volumes[].VolumeId' --output text)

    # Convert the list into an array
    VOLUME_ARRAY=($VOLUMES)

    # Display the EBS volumes and ask the user to select one
    echo "Please select an EBS volume:"
    for i in "${!VOLUME_ARRAY[@]}"; do
        echo "$i) ${VOLUME_ARRAY[$i]}"
    done

    read -p "Enter the number of the EBS volume you want to select, or enter a new EBS volume name: " SELECTION

    # Check if the selection is a number
    if [[ $SELECTION =~ ^[0-9]+$ ]]; then
        # Get the selected EBS volume
        SELECTED_VOLUME=${VOLUME_ARRAY[$SELECTION]}
    else
        # Create a new EBS volume
        SELECTED_VOLUME_NAME=$SELECTION

        read -p "Enter the size of the EBS volume in GiB (default: $DEFAULT_VOLUME_SIZE): " VOLUME_SIZE
        VOLUME_SIZE=${VOLUME_SIZE:-$DEFAULT_VOLUME_SIZE}

        read -p "Enter the type of the EBS volume (default: $DEFAULT_VOLUME_TYPE): " VOLUME_TYPE
        VOLUME_TYPE=${VOLUME_TYPE:-$DEFAULT_VOLUME_TYPE}

        # Create the EBS volume
        SELECTED_VOLUME=$(aws ec2 create-volume --availability-zone <your-availability-zone> --size $VOLUME_SIZE --volume-type $VOLUME_TYPE --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=$SELECTED_VOLUME_NAME}]" --query 'VolumeId' --output text)

        echo "EBS volume created: $SELECTED_VOLUME"
    fi

    echo "You selected EBS volume: $SELECTED_VOLUME"
}

# Create IAM role for instance
aws iam create-role \
  --role-name <your-role-name> \
  --assume-role-policy-document file://scripts/iam-role-policy.json

# Create EIP
EIP_ALLOCATION_ID=$(aws ec2 allocate-address --domain vpc | jq -r '.AllocationId')

# Create ENI
ENI_ID=$(aws ec2 create-network-interface \
  --subnet-id $SUBNET_ID \
  --tag-specifications "ResourceType=eni,Tags=[{Key=Name,Value=$ENI_NAME}]" | jq -r '.NetworkInterfaceId')

# Associate EIP with ENI
aws ec2 associate-address \
  --allocation-id $EIP_ALLOCATION_ID \
  --network-interface-id $ENI_ID

# Create EBS volume
VOLUME_ID=$(aws ec2 create-volume \
  --availability-zone <your-availability-zone> \
  --size $VOLUME_SIZE \
  --volume-type $VOLUME_TYPE \
  --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=<your-volume-name>}]" | jq -r '.VolumeId')

# Create security group
SG_ID=$(aws ec2 create-security-group \
  --group-name <your-security-group-name> \
  --description <your-security-group-description> \
  --vpc-id <your-vpc-id> | jq -r '.GroupId')

## 80 443 - AIM instance role
# Authorize security group
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr

# Build User Data script
USER_DATA=$(cat <<EOF
#!/bin/bash
# Install dependencies h



EOF
)

# Launch EC2 instance
aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_PAIR_NAME \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --block-device-mappings "[{DeviceName=/dev/sdf,Ebs={VolumeId=$VOLUME_ID}}]" \
  --network-interfaces "[{NetworkInterfaceId=$ENI_ID,DeviceIndex=0}]" \
  --iam-instance-profile Name=<your-role-name> \
  --user-data "$USER_DATA" \
  --security-group-ids $SG_ID

echo "Instance launched with EIP and EBS volume attached!"


## IAM Role
## Security Group
## Query - instance ID, VPC
## Instance Post to API