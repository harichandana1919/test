
locals {
  resource_group_name = "dev-rg"
  location            = "central india"
  virtual_network = {
    name          = "dev-vnet"
    address_space = "10.0.0.0/16"
  }

  subnets = [
    {
      name           = "private-subnetA"
      address_prefix = "10.0.0.0/24"
    },
    {
      name           = "private-subnetB"
      address_prefix = "10.0.1.0/24"
    }
  ]
  user_data = <<-EOF
#! /bin/bash
sudo apt update -y
sudo apt install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
EOF
}
