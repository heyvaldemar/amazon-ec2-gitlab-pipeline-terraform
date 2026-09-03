# GitLab on Amazon EC2: Terraform

[![Terraform Verification](https://github.com/heyvaldemar/amazon-ec2-gitlab-pipeline-terraform/actions/workflows/terraform-verification.yml/badge.svg?branch=main)](https://github.com/heyvaldemar/amazon-ec2-gitlab-pipeline-terraform/actions/workflows/terraform-verification.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository deploys a self-managed GitLab on EC2 with RDS PostgreSQL, ElastiCache Redis, an NLB for SSH and an ALB with an ACM certificate for HTTPS, DNS in Route 53, and a self-provisioned Terraform state backend (S3 + DynamoDB + KMS). Flat, numbered `.tf` files, no modules to chase, every provider locked to an exact build.

## What it creates

| Area | Resources |
|---|---|
| Networking | `aws_vpc`, `aws_subnet` ×5, `aws_internet_gateway`, `aws_nat_gateway`, `aws_eip`, `aws_route_table` ×2, `aws_route_table_association` ×5, `aws_flow_log`, `aws_security_group` ×4 |
| Compute | `aws_instance`, `aws_key_pair`, `aws_ebs_volume` ×2, `aws_volume_attachment` ×2, `tls_private_key` |
| Load balancing and DNS | `aws_lb` ×2, `aws_lb_listener` ×3, `aws_lb_target_group` ×2, `aws_lb_target_group_attachment` ×2, `aws_route53_record` ×3, `aws_acm_certificate`, `aws_acm_certificate_validation` |
| Data stores | `aws_db_instance`, `aws_db_subnet_group`, `aws_elasticache_cluster`, `aws_elasticache_subnet_group` |
| State backend and encryption | `aws_s3_bucket` ×3, `aws_s3_bucket_versioning` ×3, `aws_s3_bucket_server_side_encryption_configuration` ×3, `aws_s3_bucket_public_access_block` ×3, `aws_s3_bucket_policy` ×2, `aws_s3_bucket_logging`, `aws_dynamodb_table`, `aws_kms_key` ×5, `aws_kms_alias` ×5, `random_id` |
| Other | `aws_elasticache_parameter_group` |

85 variables, 7 outputs. Every variable has a description and a default in `00-variables.tf`.

## Prerequisites

- **Terraform 1.9.2 or newer** (any 1.x; the lockfile pins the providers, not the binary). [Install guide](https://developer.hashicorp.com/terraform/install).
- **AWS CLI** configured with credentials that can create the resources above: `aws sts get-caller-identity` must answer. [Install guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

## Getting started

```bash
# 1. Clone
git clone https://github.com/heyvaldemar/amazon-ec2-gitlab-pipeline-terraform
cd amazon-ec2-gitlab-pipeline-terraform

# 2. Replace the placeholders (table below) - your region, your secrets, your domain
$EDITOR 00-variables.tf        # or put overrides into terraform.tfvars (gitignored)

# 3. Plan, then apply
terraform init
terraform plan
terraform apply
```

Values you must change before the first apply:

| Variable | Placeholder | Meaning |
|---|---|---|
| `db_secret_1_arn` | `arn:aws:secretsmanager:YOUR-REGION-X:000000000000:secret:rds-1-000000` | The ARN of the AWS Secrets Manager secret that contains the credentials for the RDS instance |
| `azure_oauth2_secret_1_arn` | `arn:aws:secretsmanager:YOUR-REGION-X:000000000000:secret:gitlab-azure-oauth2-1-000000` | The ARN of the AWS Secrets Manager secret that contains the credentials Microsoft Azure OAuth2 |
| `smtp_secret_1_arn` | `arn:aws:secretsmanager:YOUR-REGION-X:000000000000:secret:gitlab-smtp-1-000000` | The ARN of the AWS Secrets Manager secret that contains the credentials for the SMTP |
| `route53_zone_1_name` | `example.com` | Domain name for the ACM certificate |
| `acm_1_certificate_1_domain_name` | `gitlab.example.com` | Domain name for the ACM certificate |
| `gitlab_external_url` | `https://gitlab.example.com` | URL on which GitLab will be reachable |
| `gitlab_ssh_endpoint` | `gitlab-ssh.example.com` | This variable represents the SSH endpoint for cloning repositories from a GitLab instance |
| `gitlab_mail_domain` | `example.com` | The domain used for the mail system in the GitLab setup. This will be used in the configuration of the postfix system for sending emails |
| `gitlab_reply_from` | `gitlab@example.com` | The email address that will appear in the 'From' field of the emails sent by GitLab |
| `gitlab_reply_to` | `gitlab@example.com` | The email address that will receive any replies to the emails sent by GitLab |

The application credentials are not variables: they are read at plan time from AWS Secrets Manager through `data "aws_secretsmanager_secret_version"` (the ARN defaults above are placeholders you replace with your own secrets). Nothing sensitive is ever written to the repository or to state as a variable.

### State backend: bootstrap, then switch

The first `apply` runs with local state and creates the S3 bucket, DynamoDB lock table and KMS key that will hold the state from then on. Once they exist, uncomment the `backend "s3"` block in `01-providers.tf`, fill in the bucket and table names from the outputs, and run `terraform init -migrate-state`. From that point every plan locks against DynamoDB and the state is versioned and encrypted.

## Supply chain trust

- **Providers are locked to exact builds** in `.terraform.lock.hcl` for `linux_amd64`, `linux_arm64`, `darwin_amd64` and `darwin_arm64`, with checksums. CI runs `terraform init -lockfile=readonly`, so a provider cannot move without the lockfile changing in the same commit, and Dependabot proposes provider bumps as pull requests that CI validates.
- **The Terraform and tflint container images CI uses are pinned by digest**, and GitHub Actions are pinned by commit SHA.
- **No credentials in the repository.** Secrets come from AWS Secrets Manager at plan time; `.env`, `*.tfvars` and state files are gitignored.

See [`SECURITY.md`](SECURITY.md) for the disclosure policy.

## Production checklist

- [ ] **Move state to the remote backend** right after the bootstrap apply (see above). Local state on a laptop is how estates get lost.
- [ ] **Narrow the security groups.** Defaults open SSH/HTTP(S) to `0.0.0.0/0` so the first deploy just works; set `allowed_ip_range` (and the per-rule variables) to your addresses before anything real runs behind them.
- [ ] **Review the region and instance sizes** in `00-variables.tf`: defaults are sized to boot, not to serve your load.
- [ ] **Run `terraform plan` in CI on pull requests.** `.github/workflows/02-terraform-plan-apply.yml.example` and `.gitlab-ci.yml.example` show the shape; wire them to your AWS account with OIDC federation rather than static keys.
- [ ] **Watch for drift.** `00-terraform-drift-detection.yml.example` runs a nightly plan and fails when the estate no longer matches the code.

## Testing

The [Terraform Verification](https://github.com/heyvaldemar/amazon-ec2-gitlab-pipeline-terraform/actions/workflows/terraform-verification.yml?query=branch%3Amain) workflow runs on every push, pull request, and weekly: `terraform fmt -check`, `terraform init -lockfile=readonly`, `terraform validate`, `tflint`, and actionlint on the workflow itself.

What CI does not do is `apply`: this repository has no AWS account of its own, so the guarantee is that the configuration is well-formed and its providers are exactly the ones tested. Run the plan/apply pipeline examples against your own account for the rest.

---

## About the maintainer

<div align="center">

**Maintained by [Vladimir Mikhalev](https://github.com/heyvaldemar)** — Docker Captain · IBM Champion · AWS Community Builder

[YouTube](https://www.youtube.com/channel/UCf85kQ0u1sYTTTyKVpxrlyQ?sub_confirmation=1) · [Blog](https://heyvaldemar.com) · [LinkedIn](https://www.linkedin.com/in/heyvaldemar/)

</div>
