# Jira on Azure AKS – Reference Notes

This folder sketches how to adapt the AWS/EKS reference to Azure services for a system design interview or a POC. It now includes a Terraform skeleton (`azure/terraform`) plus Helm overrides for AKS (`k8s/helm/jira/values-azure.yaml`).

## Service mapping
- Kubernetes: **AKS** (multi-AZ node pools).
- Database: **Azure Database for PostgreSQL (Flexible Server)** with zone redundancy and automated backups.
- Shared home: **Azure Files Premium** (NFS) or **Azure NetApp Files** for higher throughput.
- Ingress & TLS: **Application Gateway** or **Azure Front Door**, certificates in **Key Vault**.
- DNS: **Azure DNS** for `jira.company.com`.
- Secrets: **Key Vault** surfaced into AKS via **CSI Secret Store**.
- Observability: **Azure Monitor / Log Analytics** for logs and metrics; optional Prometheus/Grafana add-on.

## Outline to stand up a minimal POC
1) Create a resource group and virtual network with private subnets (Terraform module: `azure/terraform/network`).  
2) Provision AKS with a system node pool and enable OIDC/workload identity (module: `azure/terraform/aks`).  
3) Enable Application Gateway Ingress Controller (AGIC) or deploy NGINX Ingress with an Application Gateway behind it (subnet is created by `azure/terraform/network`).  
4) Provision PostgreSQL Flexible Server with private access and HA (module: `azure/terraform/postgres`).  
5) Provision Azure Files Premium for the Jira shared home (module: `azure/terraform/storage`).  
6) Deploy the Jira Helm chart with the Azure override file (`k8s/helm/jira/values-azure.yaml`) via Helm or GitOps (Argo CD/Flux examples under `gitops/`).

## How to use the Terraform skeleton
```bash
cd azure/terraform
terraform init
terraform apply \
  -var="resource_group_name=jira-rg" \
  -var="postgres_admin_password=change-me" \
  -var="location=eastus"
```

Key outputs:
- `aks_kubeconfig` (raw kubeconfig for `kubectl`/Helm)
- `postgres_fqdn` (Flexible Server endpoint)
- `storage_share_name` (shared home on Azure Files)

## Helm overrides for AKS
- Base chart: `k8s/helm/jira/values.yaml`
- Azure overlay: `k8s/helm/jira/values-azure.yaml` (ingress annotations for AGIC and Azure Files backend)

Example:
```bash
cd k8s/helm/jira
helm upgrade --install jira . \
  -n jira-prod --create-namespace \
  -f values.yaml -f values-azure.yaml
```

## GitOps options
- Argo CD application: `gitops/argocd/jira-app.yaml`
- Flux HelmRelease: `gitops/flux/jira-helmrelease.yaml` (with `kustomization.yaml`)

Apply them from your management cluster after adjusting repo URL/branch and secrets.
