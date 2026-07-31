output "instance_public_ip" {

  description = "Public IP assigned to EC2"

  value = aws_instance.server.public_ip

}



output "instance_public_dns" {

  description = "Public DNS of EC2"

  value = aws_instance.server.public_dns

}



output "ssh_command" {

  description = "SSH command to connect"

  value = "ssh -i server.pem ubuntu@${aws_instance.server.public_ip}"

}



output "vpc_id" {

  value = aws_vpc.main.id

}



output "security_group_id" {

  value = aws_security_group.web.id

}
