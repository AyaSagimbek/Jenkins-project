module "project" {
  source  = "AyaSagimbek/project/jenkins"
  version = "2.0.0"
  # insert the 7 required variables here
  region = "us-east-1"
  vpc_cidr = "10.0.0.0/16"
  subnet1_cidr = "10.0.1.0/24"
  subnet2_cidr = "10.0.2.0/24"
  subnet3_cidr = "10.0.3.0/24"
  ip_on_launch = true
  instance_type = "t2.micro"
}

output "aws_instance_public_ip"  {
  value = module.project.ec2
}

terraform {
  backend "s3" {
    bucket = "kaizen-group1-project-jenkins"
    key    = "terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}

resource "null_resource" "wait_for_instance" {
  depends_on = [module.project.aws_instance]
  provisioner "local-exec" {
    command = "echo 'Waiting for EC2 to boot...' && sleep 60"
  }
}
resource "null_resource" "ansible_provisioner" {
  depends_on = [null_resource.wait_for_instance]
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${module.project.ec2}, ../ansible/main.yml --user ubuntu --private-key ~/.ssh/id_rsa"
  }
}