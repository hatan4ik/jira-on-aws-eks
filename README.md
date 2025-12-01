# Jira on AWS EKS – Reference Implementation

This repository provides a reference architecture and example implementation for running **Jira Data Center** on **AWS EKS**, using:

- **AWS EKS** – Kubernetes control plane
- **AWS RDS (PostgreSQL/Aurora)** – Jira database
- **AWS EFS** – Shared Jira home
- **AWS ALB** – Ingress for HTTPS
- **Route 53 + ACM** – DNS & TLS
- **Helm** – Jira application deployment
- **Terraform** – Infrastructure as Code
- **GitHub Actions** – CI/CD example

> ⚠️ This is a **reference** and **starting point**, not a production-ready configuration. You must review, secure, and tune it for your organization.

## Layout

```text
jira-on-aws-eks/
├─ README.md
├─ docs/
│  └─ architecture.md
├─ infra/
│  └─ terraform/
│     ├─ main.tf
│     ├─ variables.tf
│     ├─ outputs.tf
│     ├─ network.tf
│     ├─ eks.tf
│     ├─ rds.tf
│     ├─ efs.tf
│     └─ alb-ingress-controller.tf
├─ k8s/
│  └─ helm/
│     └─ jira/
│        ├─ Chart.yaml
│        ├─ values.yaml
│        └─ templates/
│           ├─ deployment.yaml
│           ├─ service.yaml
│           ├─ ingress.yaml
│           ├─ configmap.yaml
│           ├─ secret.yaml
│           ├─ pv-efs.yaml
│           └─ pvc-efs.yaml
└─ ci-cd/
   └─ github-actions/
      └─ deploy-jira.yaml
```

## Getting Started

1. **Review & customize** Terraform variables in `infra/terraform/variables.tf`.
2. Initialize and apply Terraform:
   ```bash
   cd infra/terraform
   terraform init
   terraform apply
   ```
3. Update `k8s/helm/jira/values.yaml` with your domain, DB info, and sizing.
4. Install Jira via Helm:
   ```bash
   cd k8s/helm/jira
   helm upgrade --install jira . -n jira-prod --create-namespace
   ```
5. Optionally, configure the GitHub Actions workflow in `ci-cd/github-actions/deploy-jira.yaml`.
