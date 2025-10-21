output "aws_public_ip" { value = module.aws_side.public_ip }
output "gcp_public_ip" { value = module.gcp_side.public_ip }