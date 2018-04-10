# Specify the provider and access details
provider "aws" {
    region = "us-east-1"
    profile = "default"
}


# Renders the Elasticsearch Host and Port into fluentd conf
data "template_file" "td-conf" {
    template = "${file("conf/fluentd/fluent.conf.tmp")}"

    vars {
        es_host_ip = "${var.es_host_ip}"
        es_host_port = "${var.es_host_port}"
        testName = "${var.testName}"
    }
}

resource "aws_instance" "jmeter" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # Type of connection to use
    type = "ssh"

    # The default username for our AMI
    user = "centos"

    # The path to your keyfile
    private_key = "${file(var.aws_key_path)}"
  }

  # subnet ID for our VPC
  subnet_id = "${var.subnet_id}"
  # the instance type we want, comes from rundeck
  instance_type = "${var.instance_type}"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # Our Security groups to apply
  vpc_security_group_ids = ["sg-32c32b4b"]


  # We set the name as a tag
  tags = {
    Name = "${var.instance_name}"
    FrontlineProduct = "platform"
    Environment = "aws_infra"
    Owner = "perf@frontlineed.com"
    Application = "rinse-repeat"
    Role = "HTTPew-pew"
    SubEnvironment = "you sank my battleship"
  }


  # SSH config for keep alive
  provisioner "file" {
      source = "conf/ssh/config"
      destination = "/home/centos/.ssh/config"
  }

  # BZT config for artifact path
  provisioner "file" {
      source = "conf/bzt/.bzt-rc"
      destination = "/home/centos/.bzt-rc"
  }

  # JMeter Scripts
  provisioner "file" {
      source = "conf/jmeter"
      destination = "/home/centos/jmeter"
  }

  # Fluentd Conf for td-agent
  provisioner "file" {
  content = "${data.template_file.td-conf.rendered}"
  destination = "/home/centos/td-agent.conf"
  }

  # We run a remote provisioner on the instance after creating it.
  # In this case, we install Taurus and PIP
  provisioner "remote-exec" {
    inline = [
      "curl 'https://bootstrap.pypa.io/get-pip.py' -o 'get-pip.py'",
      "sudo python get-pip.py",
      "sudo yum -y install java-1.8.0-openjdk-headless.x86_64 python-devel.x86_64 libxml2-devel.x86_64 libxslt-devel.x86_64 zlib.x86_64 gcc.x86_64",
      #"sudo yum -y install java-1.7.0-openjdk-headless.x86_64 python-devel.x86_64 libxml2-devel.x86_64 libxslt-devel.x86_64 zlib.x86_64 gcc.x86_64",
      "sudo pip install bzt",
      "sudo rm get-pip.py",
      "sudo mkdir /var/log/jmeter",
      "sudo chown centos:centos /var/log/jmeter",
      "echo 'Taurus setup!'"
    ]
  }

  # Install Fluentd td-agent rpm, copy the config and start the agent
  provisioner "remote-exec" {
    inline = [
      "sudo curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh",
      "sudo mv /home/centos/td-agent.conf /etc/td-agent/td-agent.conf",
      "sudo td-agent-gem install fluent-plugin-elasticsearch",
      "sudo /etc/init.d/td-agent start",
      "echo 'Started TreasureData Fluentd!'"
    ]
  }


}
# Create IAM Role to allow for taking action on an EC2 instance
# This was manually generated for the time being...
# resource "aws_iam_role" "EC2ActionsAccess" {
#     name = "EC2ActionsAccess_role"
#     assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "cloudwatch:Describe*",
#         "ec2:Describe*",
#         "ec2:RebootInstances",
#         "ec2:StopInstances",
#         "ec2:TerminateInstances"
#       ]
#     }
#   ]
# }
# EOF
# }

# resource "aws_cloudwatch_metric_alarm" "jmeter" {
#     alarm_name = "terraform-test-jmeter"
#     comparison_operator = "LessThanOrEqualToThreshold"
#     evaluation_periods = "1"
#     metric_name = "CPUUtilization"
#     namespace = "AWS/EC2"
#     period = "900"
#     statistic = "Average"
#     threshold = "80"
#     dimensions {
#         InstanceId = "${aws_instance.jmeter.id}"
#     }
#     alarm_description = "This metric monitor ec2 cpu utilization"
#     alarm_actions = ["arn:aws:swf:us-east-1:756759416234:action/actions/AWS_EC2.InstanceId.Terminate/1.0"]
#     #alarm_actions = ["${aws_autoscaling_policy.bat.arn}"] arn:aws:iam::756759416234:role/actions/EC2ActionsAccess
# }
