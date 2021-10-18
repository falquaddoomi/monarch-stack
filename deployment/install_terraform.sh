#!/usr/bin/env bash

# from https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/gcp-get-started

# Ensure that your system is up to date, and you have the gnupg, software-properties-common, and curl packages installed.
# You will use these packages to verify HashiCorp's GPG signature, and install HashiCorp's Debian package repository.
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

# Add the HashiCorp GPG key.
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add the official HashiCorp Linux repository.
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Update to add the repository, and install the Terraform CLI.
sudo apt-get update && sudo apt-get install terraform
