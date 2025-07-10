vpc_id=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query "Vpcs[0].VpcId" --output text)
subnet_id=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc_id Name=availabilityZone,Values=us-east-1a --query "Subnets[0].SubnetId" --output text)
security_group_id=$(aws ec2 describe-security-groups --group-names "csc-sgp-nginx-hml" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)

if [ -z "$security_group_id" ]; then
    echo ">[ERRO] Security group csc-sgp-nginx-hml não foi criado na VPC $vpc_id"
    exit 1
fi

aws ec2 run-instances --image-id ami-02f3f602d23f1659d --count 1 --instance-type t2.micro \
--security-group-ids $security_group_id --subnet-id $subnet_id --associate-public-ip-address \
--block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":15,"VolumeType":"gp2"}}]' \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=csc-sgp-nginx-hml}]' \
--iam-instance-profile Name=role-ec2-ssm-access-hml --user-data file://user_data_ec2_zona_a.sh
