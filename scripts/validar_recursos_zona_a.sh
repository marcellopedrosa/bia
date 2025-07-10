vpc_id=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query "Vpcs[0].VpcId" --output text 2>/dev/null)
if [ $? -eq 0 ]; then
  echo "[OK] Tudo certo com a VPC"
else
  echo ">[ERRO] Tenho um problema ao retornar a VPC default. Será se ela existe?"
fi

subnet_id=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc_id Name=availabilityZone,Values=us-east-1a --query "Subnets[0].SubnetId" --output text 2>/dev/null)
if [ $? -eq 0 ]; then
  echo "[OK] Tudo certo com a Subnet"
else
  echo ">[ERRO] Tenho um problema ao retornar a subnet da zona a. Será se existe uma subnet na zona A?"
fi

security_group_id=$(aws ec2 describe-security-groups --group-names "csc-sgp-nginx-hml" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)
if [ $? -eq 0 ]; then
  echo "[OK] Security Group csc-sgp-nginx-hml foi criado"
  
  # Validar inbound rule para o security group 'csc-sgp-nginx-hml'
  inbound_rule=$(aws ec2 describe-security-groups --group-ids $security_group_id --filters "Name=ip-permission.from-port,Values=80" --filters "Name=ip-permission.cidr,Values=0.0.0.0/0" --output text)

  if [ -n "$inbound_rule" ]; then
    echo " [OK] Regra de entrada está ok"
  else
    echo " >[ERRO] Regra de entrada para a porta 80 não encontrada ou não está aberta para o mundo todo."
  fi

  # Validar outbound rule para o security group 'csc-sgp-nginx-hml'
  outobund_rule=$(aws ec2 describe-security-groups --group-ids $security_group_id --query "SecurityGroups[0].IpPermissionsEgress[?IpProtocol=='-1' && IpRanges[0].CidrIp=='0.0.0.0/0']" --output text)
  
  if [ -n "$outobund_rule" ]; then
    echo " [OK] Regra de saída está correta"
  else
    echo " >[ERRO] Regra de saída para o mundo não encontrada."
  fi
else
  echo ">[ERRO] Não achei o security group csc-sgp-nginx-hml. Ele foi criado?"
fi

if aws iam get-role --role-name role-ec2-ssm-access-hml &>/dev/null; then
    echo "[OK] Tudo certo com a role 'role-ec2-ssm-access-hml'"
else
    echo ">[ERRO] A role 'role-ec2-ssm-access-hml' não existe"
fi
