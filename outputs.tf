output "Phonebook_ALB_URL_DNS" {
  value = "http://${aws_alb.alb.dns_name}"
}

# output "Phonebook_ALB_URL" {
#   value = "http://${aws_alb.alb.ipv4}"
# }

# output "SSH_Command" {
#   value = "ssh -i ${var.ssh_private_key_path}${var.ssh_key_name}.pem ec2-user@${aws_alb.alb.ipv4}"
# }