# "Generated in {{ ansible_date_time.date }} {{ ansible_date_time.time }}"

provider "aws" {
  region     = "{{ aws_region }}"
  shared_credentials_file = "/home/git/.aws/credentials"
  }


{% for item in range(1,(counter|int)) %}
  {% if ((counter|int)%2) == "0" %}
  {% set mode = "server" %}
  {% else %}
  {% set mode = "client" %}
  {% endif %}

resource "aws_instance" "consul_{{ mode }}_{{ item }}" {
  ami           = "ami-0eab3a90fc693af19"
  instance_type = "{{ aws_instance_type }}"
  key_name = "max"

  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = "true"
  }

  tags = {
    Name = "consul"
  }
}
{% endfor %}