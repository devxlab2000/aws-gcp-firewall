
---

## 🎯 Objective
Establish a **secure, direct connection** between an AWS EC2 instance and a GCP VM **without using VPN technology**.  
The communication will occur **over the public internet**, but **limited strictly** to each other’s static IP addresses and defined TCP ports.

✅ **No Bash scripts**  
✅ **No startup-scripts or user-data**  
✅ **Only Terraform resources and declarative configuration**

---

## 🧱 Architecture Overview

```
     AWS (us-west-2)                   Internet                  GCP (us-west2)
 ┌─────────────────────┐        ┌──────────────────┐       ┌─────────────────────┐
 │  AWS VPC: 10.10.0.0/16 │────▶│   Public Network  │────▶│  GCP VPC: 10.20.0.0/16 │
 │  Subnet: 10.10.1.0/24  │     │ (firewall-filtered)│    │  Subnet: 10.20.1.0/24  │
 │  EC2 Instance          │◀────│  Allowed only:     │◀───│  GCP VM Instance       │
 │  Elastic IP (static)   │     │  each other’s /32  │    │  Static external IP    │
 └─────────────────────┘        └──────────────────┘       └─────────────────────┘
```

- **Traffic allowed:** only between each other’s public IPs
- **Ports open:** `22, 80, 443` by default (configurable)
- **No VPNs, no tunnels, no IPsec, no StrongSwan**
- **Everything deployed automatically by Terraform**

---

## 🧰 Prerequisites

| Tool                          | Purpose                | Download Link               |
| ----------------------------- | ---------------------- | --------------------------- |
| **Terraform**                 | Infrastructure as code | [terraform.io/downloads][1] |
| **AWS CLI**                   | Configures credentials | [aws.amazon.com/cli][2]     |
| **Google Cloud SDK (gcloud)** | Configures GCP auth    | [cloud.google.com/sdk][3]   |

---

## ⚙️ Step 1 — Configure Cloud Access

### 🟢 AWS
1. Open **PowerShell / Terminal** and run:
```bash
aws configure
```
2. Enter:
   2. Access Key ID
   3. Secret Key
   4. Default region → `us-west-2`
   5. Output format → `json`

### 🔵 GCP
1. Open terminal and authenticate:
```bash
gcloud auth application-default login
```
2. Select your project:  
	   \`\`\`
   calm-repeater-475316-q0
````
3. Confirm it’s active:
```bash
gcloud config list
````

---

## 🗂️ Step 2 — Folder Structure

Create a folder:

```
C:\terraform\aws-gcp-firewall-only
```

Inside it, place:

```
providers.tf
variables.tf
main.tf
```

---

## 📜 Step 3 — Terraform Configuration Files

Refer to the Terraform code provided in your design section.

---

## 🚀 Step 4 — Run Terraform

```bash
terraform init
terraform apply -auto-approve \
  -var="gcp_project_id=calm-repeater-475316-q0"
```

Terraform will create:
- AWS EC2 instance (Amazon Linux 2)
- GCP VM (Ubuntu)
- Each with static IP
- Mutually allowed ports (TCP 22/80/443)
- No VPNs or scripts

---

## 🧪 Step 5 — Test Connectivity

After apply, Terraform prints:
```
aws_public_ip = 13.x.x.x
gcp_public_ip = 34.x.x.x
```

Now you can:
- SSH from AWS → GCP:  
	  \`\`\`bash
  ssh ubuntu@34.x.x.x
````
- SSH from GCP → AWS:  
```bash
ssh ec2-user@13.x.x.x
````
- Or open web services on ports 80/443 if configured.

---

## 🧹 Step 6 — Destroy When Done
To avoid cloud charges:
```bash
terraform destroy -auto-approve
```

---

 

 



[1]:	https://developer.hashicorp.com/terraform/downloads
[2]:	https://aws.amazon.com/cli/
[3]:	https://cloud.google.com/sdk/docs/install
