# AWS ↔ GCP Firewall-Only (Terraform)

Creates an **AWS EC2** and a **GCP Compute Engine** VM that can talk to each other over the internet using **mutual /32 firewall allowlists**.
No VPN, VPC peering, or Cloud NAT.

## Layout
- `modules/aws-ec2-firewall` — VPC, subnet, IGW, route, SG, EC2, Elastic IP
- `modules/gcp-vm-firewall` — VPC, subnet, static external IP, firewall, GCE VM
- The root module adds AWS SG rules to allow **from** the GCP VM public IP.

## Quick start
```bash
terraform init
terraform apply -var-file=envs/dev.tfvars \  -var="gcp_project_id=<YOUR_GCP_PROJECT_ID>" \  -var="ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
```

Outputs:
- `aws_public_ip`
- `gcp_public_ip`
- `ssh_hints` with ready-to-copy SSH commands

> Tip: Consider a remote backend (S3+DynamoDB or GCS) to avoid committing local state.
