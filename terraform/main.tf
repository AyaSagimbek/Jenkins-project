resource "null_resource" "waiting" {
  depends_on = [aws_instance.web]

  provisioner "local-exec" {
    command = "echo 'Waiting for EC2 to boot...' && sleep 60"
  }
}

resource "null_resource" "ansible_provisioner" {
  depends_on = [null_resource.waiting]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${aws_instance.web.public_ip}, ../ansible/main.yml  --private-key ~/.ssh/id_rsa"
  }
}