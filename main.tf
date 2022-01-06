provider "aws" {
  # Change your default region here
  region = "us-west-2"
}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

module "dcos" {
  source  = "dcos-terraform/dcos/aws"
  version = "~> 0.2.0"

  providers = {
    aws = "aws"
  }

  cluster_name        = "plogan"
  ssh_public_key_file = "plogan.pub"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  num_masters        = 1
  num_private_agents = 2
  num_public_agents  = 1

  # private_agents_extra_volumes = [
  #   {
  #     size        = "100"
  #     type        = "io1"
  #     iops        = "3000"
  #     device_name = "/dev/xvdi"
  #     tag         = "plogan"
  #   }
  # ]

  dcos_version = "1.13.2"

  dcos_variant              = "ee"
  dcos_license_key_contents = "${file("./license.txt")}"
  # Make sure to set your credentials if you do not want the default EE
  # dcos_superuser_username      = "superuser-name"
  # dcos_superuser_password_hash = "${file("./dcos_superuser_password_hash.sha512")}"
  # dcos_variant = "open"

  dcos_instance_os             = "centos_7.5"
  bootstrap_instance_type      = "t2.medium"
  masters_instance_type        = "t2.large"
  private_agents_instance_type = "t2.xlarge"
  public_agents_instance_type  = "t2.xlarge"

  aws_key_name = "plogan"
  tags = {"owner" = "plogan", "expiration"="5d", "oauth"="true"}
  availability_zones = ["us-west-2a","us-west-2b","us-west-2c"]

  dcos_oauth_enabled = "true"
  dcos_security = "permissive"

}

output "masters-ips" {
  value = "${module.dcos.masters-ips}"
}

output "cluster-address" {
  value = "${module.dcos.masters-loadbalancer}"
}

//
//  value = "${module.dcos.agents}"
//}

output "public-agents-loadbalancer" {
  value = "${module.dcos.public-agents-loadbalancer}"
}

