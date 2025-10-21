output "aws_public_ip" {
  value = module.aws_side.public_ip
}

output "gcp_public_ip" {
  value = module.gcp_side.public_ip
}

output "ssh_hints" {
  value = {
    aws = "ssh ec2-user@${module.aws_side.public_ip}"
    gcp = "ssh ${var.gcp_ssh_username}@${module.gcp_side.public_ip}"
  }
}
