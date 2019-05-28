provider "vault" {
   address = "http://18.130.171.42:8200"
   token = "s.Gij5OndoXfO7RH2posJC9FYA"
 }
 
 data "vault_generic_secret" "secret_access_key" {
   path = "secret/secret_access_key"
 }
 
 data "vault_generic_secret" "access_key_id" {
   path = "secret/access_key_id"
 }

provider "aws" {
  access_key = "${data.vault_generic_secret.access_key_id.data["AWS_ACCESS_KEY_ID"]}"
  secret_key = "${data.vault_generic_secret.secret_access_key.data["AWS_SECRET_ACCESS_KEY"]}"
  region     = "eu-west-2"
}

resource "aws_instance" "elasticsearch" {
  ami           = "ami-0eab3a90fc693af19"
  instance_type = "t2.medium"
  key_name = "max"

  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = "true"
  }

  tags = {
    Name = "elasticsearch"
  }


}