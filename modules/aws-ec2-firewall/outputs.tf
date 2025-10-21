output "public_ip" {
  value = aws_eip.eip.public_ip
}

output "sg_id" {
  value = aws_security_group.sg.id
}
