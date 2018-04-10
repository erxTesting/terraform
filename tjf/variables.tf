variable "aws_key_name" {
    description = "Name of the SSH keypair to use in AWS.",
    default = "Integrations.pem"
}

variable "aws_key_path" {
    description = "Path to the private portion of the SSH key specified.",
    default = "~/.aws/keys/Integrations.pem"
}

variable "aws_region" {
    description = "AWS region to launch servers.",
    default = "us-east-1"
}

variable "subnet_id" {
    description = "Subnet ID to use in VPC",
    default = "subnet-3226c86a"
}

variable "instance_type" {
    description = "Instance type",
    default = "t2.medium"
    #default = "m4.10xlarge" # Big Boy!
}

variable "instance_name" {
    description = "Instance Name",
    default = "taurus-jmeter-fluentd"
}

variable "aws_security_group" {
    description = "The security group to apply",
    default = {
        id = "sg-32c32b4b"
    }
}

variable "aws_amis" {
    default = {
        us-east-1 = "ami-c83360df"
    }
}

variable "es_host_ip" {
    description = "Elasticsearch host IP",
    default = "elasticsearch.ss.frontlineeducation.com"
    #default = "10.111.64.154"
}

variable "es_host_port" {
    description = "Elasticsearch host port",
    default = "9200"
}

variable "testName" {
  description = "Test name tag for Elasticsearch",
  default ="abs_ins"
  #default ="dummy"
}
