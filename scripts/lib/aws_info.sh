function list_vpcs() {
	### Prints the names of the available VPCs

	envchain aws aws ec2 describe-vpcs \
	 | jq '.Vpcs[].Tags[]? | select(.Key | contains("Name")) | .Value' \
	 | grep -v "default" \
         | grep -v "Algo" \
	 | tr -d '"' \
	 | sed "s/_vpc//g"
}

function get_iam_user_arn() {
	local username="${1}"

	arn=$(envchain aws aws iam get-user --user-name "${username}" | jq '.User.Arn' | sed s/\"//g)

	if [ "${arn}" == "null" ]; then
	  echo 2>&1 "Unable to fetch arn for ${username}"
	  exit 1
	fi

	echo "${arn}"
}


function list_buckets() {
	### Prints the names of the available S3 buckets

	envchain aws aws s3 ls | awk '{ print $3 }'
}

function get_efs_id() {
        local creation_token=${1}
        envchain aws aws efs describe-file-systems --creation-token ${creation_token} | jq ".FileSystems[0].FileSystemId" | tr -d '"'
}

function get_vpc_id() {
        local VPC_NAME=${1}
        envchain aws aws ec2 describe-vpcs --filters "Name=tag-value, Values=${VPC_NAME}_vpc" | jq '.Vpcs[0].VpcId' | tr -d '"'
}

function set_aws_variables() {
	## Sets a number of variables with info about resources in AWS relevant
	## for the VPC and APP specified

	VPC_NAME=${1}
	APP_ENV=${2}
	APP_NAME=${3}

	echo "Fetching basic AWS parameters for VPC $VPC_NAME"
	vpc_id=$(envchain aws aws ec2 describe-vpcs --filters "Name=tag-value, Values=${VPC_NAME}_vpc" | jq '.Vpcs[0].VpcId' | tr -d '"')

	if [ "${vpc_id}" == "null" ]; then
	  echo "Unable to fetch vpc_id for ${env}"
	  echo "Aborting."
	  exit 1
	fi

	private_subnet_ids=$(envchain aws aws ec2 describe-subnets --filters "Name=vpc-id, Values=${vpc_id}, Name=tag-value, Values=${VPC_NAME}_private_subnet*" | jq '.Subnets[].SubnetId' | tr -d '"' | tr '\n' ',' | sed s/,$//)
	public_subnet_ids=$(envchain aws aws ec2 describe-subnets --filters "Name=vpc-id, Values=${vpc_id}, Name=tag-value, Values=${VPC_NAME}_public_subnet*" | jq '.Subnets[].SubnetId' | tr -d '"' | tr '\n' ',' | sed s/,$//)
	nat_ip=$(envchain aws aws ec2 describe-nat-gateways --filter "Name=vpc-id, Values=${vpc_id}" | jq ".NatGateways[0].NatGatewayAddresses[0].PublicIp")

	if [ "$APP_NAME" != "" ]; then
		echo "Fetching AWS parameters for $APP_NAME in $APP_ENV (in VPC $VPC_NAME)"
                security_group=$(echo "${APP_ENV}_${APP_NAME}_app_sg*" | tr '-' '_') # replace dash with underscore for appnames with dash
		app_security_group_id=$(envchain aws aws ec2 describe-security-groups --filters "Name=vpc-id, Values=${vpc_id}, Name=tag-value, Values=${security_group}" | jq '.SecurityGroups[0].GroupId' | tr -d '"')
		rds_hostname=$(envchain aws aws rds describe-db-instances --filters "Name=vpc-id, Values=${vpc_id}, Name=db-instance-id, Values=${APP_ENV}-${APP_NAME}-rds" | jq '.DBInstances[0].Endpoint.Address' | tr -d '"')
		rds_port=$(envchain aws aws rds describe-db-instances --filters "Name=vpc-id, Values=${vpc_id}, Name=db-instance-id, Values=${APP_ENV}-${APP_NAME}-rds" | jq '.DBInstances[0].Endpoint.Port' | tr -d '"')
	fi
}

