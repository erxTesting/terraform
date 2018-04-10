read -p "Press [Enter]..."

uname -a # is 32 or 64 bit os?
wget https://releases.hashicorp.com/terraform/0.11.5/terraform_0.11.5_linux_amd64.zip
unzip terraform_0.11.5_linux_amd64.zip -d /usr/local/bin/
terraform --version

sudo vi /home/ubuntu/.aws/keys/Integrations.pem
cat /home/ubuntu/.aws/keys/Integrations.pem
 
git pull
cd tjf/
export AWS_DEFAULT_REGION="us-east-1";export AWS_ACCESS_KEY_ID="XXXXXXXXXXXXXXXXXXXX"; export AWS_SECRET_ACCESS_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

terraform init
terraform plan
terraform apply
terraform help

export TERRAFORM_JMETER = `terraform show | grep private_ip | cut -d: -f2 | sed -e 's/^[ \t]*//'`
ssh -i ~/.aws/keys/Integrations.pem centos@$TERRAFORM_JMETER

cd ~/jmeter
bzt mySenerio.yml
exit

scp -rCi ~/.aws/keys/Integrations.pem centos@$TERRAFORM_JMETER:/var/log/jmeter/ ~/ # copy results from the system
terraform destroy