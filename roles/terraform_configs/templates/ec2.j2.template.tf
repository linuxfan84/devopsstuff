# "Generated in {{ ansible_date_time.date }} {{ ansible_date_time.time }}"

provider "aws" {
  region     = "{{ aws_region }}"
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


{% for item in range(1,(counter|int)) %}

data "template_cloudinit_config" "userdata{{ loop.index }}" {
  part {
  content = <<EOF
  #cloud-config
  hostname: consul{{ loop.index }}
  fqdn: consul{{ loop.index }}
  EOF
  }
}

resource "aws_instance" "consul{{ item }}" {
  user_data = "${data.template_cloudinit_config.userdata{{ loop.index }}.rendered}"
  ami           = "ami-0804ba1c58cd2e8e2"
  instance_type = "{{ aws_instance_type }}"
  key_name = "max"
  subnet_id = "subnet-8fc59ac2"
  private_ip = "172.31.1.{{ loop.index }}"
  iam_instance_profile = "${aws_iam_instance_profile.consul_profile.name}"
  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = "true"
  }

  tags = {
    Name = "consul"
  }
}

{% endfor %}