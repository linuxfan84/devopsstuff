# "Generated in 2019-06-08 14:58:46"

provider "aws" {
  region     = "eu-central-1"
  shared_credentials_file = "/home/git/.aws/credentials"
  }

# Create an IAM role for the consul auto-join

resource "aws_iam_role" "consul_role" {
  name = "consul_role"
  assume_role_policy = "${file("${path.cwd}/assume_role_policy.json")}"
}

# Create the policy

resource "aws_iam_policy" "consul_policy" {
  name = "consul_policy"
  description = "Allows consul hosts to describe instances for joining."
  policy = "${file("${path.cwd}/consul_policy.json")}"
}

# Attach the policy

resource "aws_iam_policy_attachment" "consul-attachment" {
  name       = "consul-attachment"
  roles      = ["${aws_iam_role.consul_role.name}"]
  policy_arn = "${aws_iam_policy.consul_policy.arn}"
}

# Create the instance profile

resource "aws_iam_instance_profile" "consul_profile" {
  name = "consul_profile"
  role = "${aws_iam_role.consul_role.name}"
  }



data "template_cloudinit_config" "userdata1" {
  part {
  content = <<EOF
  #cloud-config
  hostname: consul1
  fqdn: consul1
  EOF
  }
}

resource "aws_instance" "consul1" {
  user_data = "${data.template_cloudinit_config.userdata1.rendered}"
  ami           = "ami-0804ba1c58cd2e8e2"
  instance_type = "t2.micro"
  key_name = "max"
  subnet_id = "subnet-8fc59ac2"
  private_ip = "172.31.1.1"
  iam_instance_profile = "${aws_iam_instance_profile.consul_profile.name}"
  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = "true"
  }

  tags = {
    Name = "consul"
  }
}


data "template_cloudinit_config" "userdata2" {
  part {
  content = <<EOF
  #cloud-config
  hostname: consul2
  fqdn: consul2
  EOF
  }
}

resource "aws_instance" "consul2" {
  user_data = "${data.template_cloudinit_config.userdata2.rendered}"
  ami           = "ami-0804ba1c58cd2e8e2"
  instance_type = "t2.micro"
  key_name = "max"
  subnet_id = "subnet-8fc59ac2"
  private_ip = "172.31.1.2"
  iam_instance_profile = "${aws_iam_instance_profile.consul_profile.name}"
  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = "true"
  }

  tags = {
    Name = "consul"
  }
}


data "template_cloudinit_config" "userdata3" {
  part {
  content = <<EOF
  #cloud-config
  hostname: consul3
  fqdn: consul3
  EOF
  }
}

resource "aws_instance" "consul3" {
  user_data = "${data.template_cloudinit_config.userdata3.rendered}"
  ami           = "ami-0804ba1c58cd2e8e2"
  instance_type = "t2.micro"
  key_name = "max"
  subnet_id = "subnet-8fc59ac2"
  private_ip = "172.31.1.3"
  iam_instance_profile = "${aws_iam_instance_profile.consul_profile.name}"
  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = "true"
  }

  tags = {
    Name = "consul"
  }
}


data "template_cloudinit_config" "userdata4" {
  part {
  content = <<EOF
  #cloud-config
  hostname: consul4
  fqdn: consul4
  EOF
  }
}

resource "aws_instance" "consul4" {
  user_data = "${data.template_cloudinit_config.userdata4.rendered}"
  ami           = "ami-0804ba1c58cd2e8e2"
  instance_type = "t2.micro"
  key_name = "max"
  subnet_id = "subnet-8fc59ac2"
  private_ip = "172.31.1.4"
  iam_instance_profile = "${aws_iam_instance_profile.consul_profile.name}"
  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = "true"
  }

  tags = {
    Name = "consul"
  }
}


data "template_cloudinit_config" "userdata5" {
  part {
  content = <<EOF
  #cloud-config
  hostname: consul5
  fqdn: consul5
  EOF
  }
}

resource "aws_instance" "consul5" {
  user_data = "${data.template_cloudinit_config.userdata5.rendered}"
  ami           = "ami-0804ba1c58cd2e8e2"
  instance_type = "t2.micro"
  key_name = "max"
  subnet_id = "subnet-8fc59ac2"
  private_ip = "172.31.1.5"
  iam_instance_profile = "${aws_iam_instance_profile.consul_profile.name}"
  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = "true"
  }

  tags = {
    Name = "consul"
  }
}

