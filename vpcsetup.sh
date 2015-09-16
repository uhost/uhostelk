#!/bin/bash
#
# UhostELK VPCSetup
# https://github.com/uhost/uhostelk/
#
# version: 0.3.0
#
# License & Authors
#
# Author:: Mark Allen (mark@markcallen.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

path_to_aws=$(which aws)
if [ ! -x "$path_to_aws" ] ; then
   echo "Can't find AWS CLI, check that its in your path"
   exit 1;
fi

: ${AWS_ACCESS_KEY_ID:?"Need to set AWS_ACCESS_KEY_ID"}
: ${AWS_SECRET_ACCESS_KEY:?"Need to set AWS_SECRET_ACCESS_KEY"}

VPCNAME=uhostelk
CIDR_BLOCK="10.9.0.0/24"

while getopts v:n: option
do
  case "${option}"
  in
    h) VPCNAME=${OPTARG};;
    n) CIDR_BLOCK=${OPTARG};;
  esac
done

VPC_NAME=${VPCNAME}-vpc
SECURITY_GROUP=${VPCNAME}-security-group
KEY_NAME=${VPCNAME}-key

echo "Checking to see if ${CIDR_BLOCK} is already in use"
vpcId=`aws ec2 describe-vpcs --filter Name=cidr,Values=${CIDR_BLOCK} --query 'Vpcs[*].VpcId' --output text`
if [ ! -z "$vpcId" ]; then
  echo "Found ${vpcId} using ${CIDR_BLOCK}.  Exitting!!"
  exit 1;
fi

echo "Checking to see if keypair ${KEY_NAME} already exists"
keypair=`aws ec2 describe-key-pairs --filter Name=key-name,Values=${KEY_NAME} --query 'KeyPairs[*].KeyName' --output text`
if [ ! -z "$keypair" ]; then
  echo "${KEY_NAME} already in use: Exitting!!"
  exit 1;
fi

vpcId=`aws ec2 describe-vpcs --filter Name=tag:Name,Values=${VPC_NAME} --query 'Vpcs[*].VpcId'`

if [ ! -z "$vpcId" ]; then
  echo "Using Existing vpc-id: $vpcId"
else
  echo "Creating VPC ${VPC_NAME}: ${CIDR_BLOCK}"
  vpcId=`aws ec2 create-vpc --cidr-block $CIDR_BLOCK --query 'Vpc.VpcId' --output text`
fi

aws ec2 modify-vpc-attribute --vpc-id $vpcId --enable-dns-support "{\"Value\":true}"
aws ec2 modify-vpc-attribute --vpc-id $vpcId --enable-dns-hostnames "{\"Value\":true}"
aws ec2 create-tags --resources $vpcId --tag "Key=Name,Value=${VPC_NAME}"

echo "Creating Internet Gateway"
internetGatewayId=`aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text`
aws ec2 attach-internet-gateway --internet-gateway-id $internetGatewayId --vpc-id $vpcId
aws ec2 create-tags --resources $internetGatewayId --tag "Key=Name,Value=${VPC_NAME}-internetgateway"

echo "Creating Subnet"
subnetId=`aws ec2 create-subnet --vpc-id $vpcId --cidr-block $CIDR_BLOCK --query 'Subnet.SubnetId' --output text`
aws ec2 create-tags --resources $subnetId --tag "Key=Name,Value=${VPC_NAME}-subnet"

echo "Creating Routing Table"
routeTableId=`aws ec2 create-route-table --vpc-id $vpcId --query 'RouteTable.RouteTableId' --output text`
aws ec2 associate-route-table --route-table-id $routeTableId --subnet-id $subnetId --output text
aws ec2 create-route --route-table-id $routeTableId --destination-cidr-block 0.0.0.0/0 --gateway-id $internetGatewayId --output text
aws ec2 create-tags --resources $routeTableId --tag "Key=Name,Value=${VPC_NAME}-routetable"

echo "Created VPC: $vpcId"

securityGroupId=`aws ec2 create-security-group --group-name $SECURITY_GROUP --description "$SECURITY_GROUP" --vpc-id $vpcId --query 'GroupId' --output text`
aws ec2 authorize-security-group-ingress --group-id $securityGroupId --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $securityGroupId --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $securityGroupId --protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 create-tags --resources $securityGroupId --tag "Key=Name,Value=${SECURITY_GROUP}"

echo "Create Security Group: $SECURITY_GROUP ($securityGroupId)"

if [ -f ${KEY_NAME}.pem ]; then
  rm -f ${KEY_NAME}.pem
fi
aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text > ./${KEY_NAME}.pem
chmod 400 ${KEY_NAME}.pem

echo "Created Key: $KEY_NAME saved as ${KEY_NAME}.pem"

echo export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
echo export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
echo export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}
echo export AWS_AVAILIBILITY_ZONE=${AWS_DEFAULT_REGION}a
echo export AWS_SSH_KEY_ID=${KEY_NAME}
echo export AWS_SSH_KEY=`pwd`/${KEY_NAME}.pem
echo export AWS_SECURITY_GROUP_ID=${securityGroupId}
echo export AWS_SUBNET_ID=${subnetId}


