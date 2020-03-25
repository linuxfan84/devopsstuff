#!/bin/bash

# First will create GCP infrastructure
cd ~/ansible
terraform plan
terraform apply
