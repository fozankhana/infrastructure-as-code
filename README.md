# Infrastructure as Code — AWS + Terraform

Production-grade AWS infrastructure built with Terraform, featuring a modular architecture, remote S3 state backend, and a full GitHub Actions CI/CD pipeline.

---

## Stack

| Tool | Purpose |
|------|---------|
| Terraform `>= 1.7.0` | Infrastructure provisioning |
| AWS | Cloud provider |
| S3 + DynamoDB | Remote state + state locking |
| GitHub Actions | CI/CD — plan on PR, apply on merge |

---

## Architecture

```
VPC (3 AZs)
├── Public Subnets   → Application Load Balancer
└── Private Subnets  → EC2 Auto Scaling Group
                     → RDS PostgreSQL 15
```

Traffic flow: `Internet → ALB (HTTPS) → ASG (EC2) → RDS`

---

## Project Structure

```
infra/
├── versions.tf                  ← provider + version pins
├── variables.tf                 ← input variable declarations
├── outputs.tf                   ← output values
├── main.tf                      ← root module, wires all modules
├── backend.tf                   ← S3 remote state config
├── terraform.tfvars.example     ← variable template (safe to commit)
│
├── modules/
│   ├── networking/              ← VPC, subnets, IGW, NAT, route tables
│   ├── security/                ← security groups, IAM roles
│   ├── loadbalancer/            ← ALB, target groups, listeners
│   ├── database/                ← RDS PostgreSQL, subnet/parameter groups
│   └── compute/                 ← EC2 launch template, ASG, scaling policies
│
├── environments/
│   ├── dev/terraform.tfvars
│   ├── staging/terraform.tfvars
│   └── prod/terraform.tfvars
│
bootstrap/
├── main.tf                      ← S3 bucket + DynamoDB table (run once)
└── versions.tf

.github/workflows/
├── terraform-plan.yml           ← plan on every PR
└── terraform-apply.yml          ← apply on merge to main
```

---

## Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.7.0`
- AWS CLI configured with appropriate credentials
- An S3 bucket and DynamoDB table for remote state (see Bootstrap below)

### 1. Bootstrap the backend (run once)

```bash
cd bootstrap
terraform init
terraform apply
```

This creates the S3 state bucket and DynamoDB lock table.

### 2. Configure your variables

```bash
cp infra/terraform.tfvars.example infra/terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Initialize and plan

```bash
cd infra
terraform init
terraform validate
terraform plan -var-file="environments/dev/terraform.tfvars" -out=tfplan.binary
```

### 4. Apply

```bash
terraform apply tfplan.binary
```

---

## Environments

| Environment | Instance Type | RDS | NAT Gateways |
|-------------|--------------|-----|--------------|
| `dev` | `t3.small` | `db.t3.micro`, single-AZ | 1 (cost saving) |
| `staging` | `t3.medium` | `db.t3.medium`, single-AZ | 1 |
| `prod` | `t3.large` | `db.r6g.large`, Multi-AZ | 1 per AZ |

---

## CI/CD Pipeline

| Event | Action |
|-------|--------|
| Pull Request | `terraform plan` runs, output posted as PR comment |
| Merge to `main` | Manual approval gate → `terraform apply` |

Authentication uses AWS OIDC (no static access keys stored in GitHub).

---

## Security Decisions

- **No SSH access** — EC2 instances use AWS SSM Session Manager
- **IMDSv2 enforced** — blocks SSRF-based credential theft
- **Layered security groups** — ALB → App → DB, no direct internet access to app or DB
- **Secrets never in code** — `db_password` passed via CI secret or environment variable
- **State encrypted** — S3 bucket uses AES-256 SSE, versioning enabled
- **Deletion protection** — RDS and S3 state bucket protected in prod

---

## Build Progress

- [x] Phase 1 — Scaffold & provider lock
- [x] Phase 2 — Bootstrap backend (S3 + DynamoDB)
- [x] Phase 3 — Root variables + backend config
- [x] Phase 4 — Networking module
- [x] Phase 5 — Security module
- [x] Phase 6 — Load balancer module
- [ ] Phase 7 — Database module
- [ ] Phase 8 — Compute module
- [ ] Phase 9 — Root module wiring
- [ ] Phase 10 — Outputs + validation
- [ ] Phase 11 — Environment configs
- [ ] Phase 12 — GitHub Actions: plan on PR
- [ ] Phase 13 — GitHub Actions: apply on merge

---

## License

AGPL-3.0 license
