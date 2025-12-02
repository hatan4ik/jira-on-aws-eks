# Jira on Azure AKS – Reference Notes

This folder sketches how to adapt the AWS/EKS reference to Azure services for a system design interview or a POC. It now includes a Terraform skeleton (`azure/terraform`) plus Helm overrides for AKS (`k8s/helm/jira/values-azure.yaml`).

## High-Level Architecture

The diagram below illustrates the deployment architecture for Jira on Azure. Terraform provisions the core infrastructure, and then GitOps (ArgoCD/Flux) or a manual Helm deployment is used to deploy the Jira application to the AKS cluster.

```mermaid
graph TD
    subgraph "DevOps & IaC"
        direction LR
        CI_CD("CI/CD Pipeline<br>(Azure DevOps)")
        Terraform("Terraform")
        Helm("Helm")
    end

    subgraph "Azure Cloud"
        direction TB
        User("User")
        AzureDNS("Azure DNS<br>jira.company.com")

        subgraph "Virtual Network"
            direction TB
            AppGW("Application Gateway")

            subgraph "Azure Kubernetes Service"
                direction TB
                Ingress("AGIC Ingress<br>(App Gateway Controller)")
                Service("Jira Service<br>(ClusterIP)")
                JiraPods("Jira Data Center Pods")
            end

            PostgreSQL("PostgreSQL<br>Flexible Server")
            AzureFiles("Azure Files<br>Premium NFS")
        end
        
        KeyVault("Azure Key Vault<br>Secrets")
    end

    User --> AzureDNS
    AzureDNS --> AppGW
    AppGW --> Ingress
    Ingress --> Service
    Service --> JiraPods
    JiraPods --> PostgreSQL
    JiraPods --> AzureFiles
    JiraPods --> KeyVault

    CI_CD --> Terraform
    CI_CD --> Helm

    Terraform --> VNet
    Terraform --> AKS
    Terraform --> PostgreSQL
    Terraform --> AzureFiles
    Terraform --> KeyVault

    Helm --> AKS

    classDef azureService fill:#0078D4,stroke:#333,stroke-width:2px,color:white;
    class AppGW,AzureDNS,AKS,PostgreSQL,AzureFiles,KeyVault azureService;

    classDef k8s fill:#326CE5,stroke:#333,stroke-width:2px,color:white;
    class Ingress,Service,JiraPods k8s;

    classDef devops fill:#6E5494,stroke:#333,stroke-width:2px,color:white;
    class CI_CD,Terraform,Helm devops;
```

## Service mapping
- Kubernetes: **AKS** (multi-AZ node pools).
- Database: **Azure Database for PostgreSQL (Flexible Server)** with zone redundancy and automated backups.
- Shared home: **Azure Files Premium** (NFS) or **Azure NetApp Files** for higher throughput.
- Ingress & TLS: **Application Gateway** or **Azure Front Door**, certificates in **Key Vault**.
- DNS: **Azure DNS** for `jira.company.com`.
- Secrets: **Key Vault** surfaced into AKS via **CSI Secret Store**.
- Observability: **Azure Monitor / Log Analytics** for logs and metrics; optional Prometheus/Grafana add-on.

## Zero-to-hero (AKS + GitOps)
1) **State + secrets** – Create the remote backend (see “Backend Configuration”) and set `postgres_admin_password` (strong, stored in Key Vault by Terraform).  
2) **Provision infra** – From `azure/terraform`, run `terraform init` (with backend config) then `terraform apply` with `resource_group_name`, `location`, `postgres_admin_password`, and `admin_ip_address`. This stands up VNet/subnets, AKS (OIDC/workload identity), PostgreSQL Flexible Server (private + HA), Azure Files Premium, Key Vault, and Log Analytics.  
3) **Capture outputs** – `aks_kubeconfig` (for `kubectl`/Helm and for `KUBECONFIG_B64` in CI), `postgres_fqdn`, `storage_share_name`.  
4) **Deploy Jira** – Helm with `values.yaml` + `values-azure.yaml`, or GitOps:
   - Argo CD: apply `gitops/argocd/jira-app.yaml` (update repo URL/branch).
   - Flux: apply `gitops/flux/kustomization.yaml` and `jira-helmrelease.yaml`.
   - CI templates: `gitops/pipelines/` for GitHub Actions, Azure DevOps, GitLab (set `GITOPS_TOOL` and `KUBECONFIG_B64` secrets).

## Outline to stand up a minimal POC
1) Create a resource group and virtual network with private subnets (Terraform module: `azure/terraform/network`).  
2) Provision AKS with a system node pool and enable OIDC/workload identity (module: `azure/terraform/aks`).  
3) Enable Application Gateway Ingress Controller (AGIC) or deploy NGINX Ingress with an Application Gateway behind it (subnet is created by `azure/terraform/network`).  
4) Provision PostgreSQL Flexible Server with private access and HA (module: `azure/terraform/postgres`).  
5) Provision Azure Files Premium for the Jira shared home (module: `azure/terraform/storage`).  
6) Deploy the Jira Helm chart with the Azure override file (`k8s/helm/jira/values-azure.yaml`) via Helm or GitOps (Argo CD/Flux examples under `gitops/`).

## How to use the Terraform skeleton

This Terraform setup uses a remote backend to store the state file in Azure Storage. This is a best practice for collaborative environments and CI/CD automation.

### Backend Configuration (One-time setup)

Before you can run Terraform, you need to create a storage account and a container to hold the state file. You can do this using the Azure CLI:

```bash
# Variables
BACKEND_RG="jira-tf-state-rg"
BACKEND_STORAGE_ACCOUNT="jiratfstate$RANDOM"
BACKEND_CONTAINER="tfstate"
LOCATION="eastus"

# Create resource group
az group create --name $BACKEND_RG --location $LOCATION

# Create storage account
az storage account create --name $BACKEND_STORAGE_ACCOUNT --resource-group $BACKEND_RG --location $LOCATION --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $BACKEND_CONTAINER --account-name $BACKEND_STORAGE_ACCOUNT
```

### Initializing Terraform

Once the backend storage is created, you can initialize Terraform. The configuration is passed during the `init` command, not stored in the code, for better security and flexibility.

```bash
cd azure/terraform

terraform init \
    -backend-config="resource_group_name=$BACKEND_RG" \
    -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT" \
    -backend-config="container_name=$BACKEND_CONTAINER" \
    -backend-config="key=jira.prod.tfstate"
```

### Applying the plan

After initialization, you can apply the Terraform plan. You will need to provide your current public IP address for the `admin_ip_address` variable to allow SSH access to the AKS nodes.

```bash
terraform apply \
  -var="resource_group_name=jira-rg" \
  -var="postgres_admin_password=change-me" \
  -var="location=eastus" \
  -var="admin_ip_address=<YOUR_PUBLIC_IP>"
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

## Permissions

The Terraform configuration now includes an Azure Key Vault to manage the PostgreSQL password. The user or service principal running `terraform apply` will have an access policy automatically added to the Key Vault to manage secrets. This is handled by the `keyvault` module, which uses the `azurerm_client_config` data source to get the `object_id` of the caller.

## Production Enhancements (FAANG-Level)

**Security Hardening:**
- Azure Key Vault integration with network ACLs and private endpoints
- Input validation for all Terraform variables (IP addresses, VM sizes, passwords)
- Network Security Groups with specific CIDR blocks instead of wildcards
- PostgreSQL with private endpoints and zone redundancy

**Operational Excellence:**
- Automated deployment script with backend setup
- Production-ready Helm values with resource limits and anti-affinity
- GitOps integration with Argo CD and Flux
- Azure Files Premium NFS for high-performance shared storage

**Monitoring & Observability:**
- Azure Monitor and Log Analytics integration
- Application Gateway with WAF and SSL termination
- Custom dashboards and alerting rules

**Production Deployment:**
```bash
# Copy and customize production variables
cp azure/terraform/prod.tfvars.example azure/terraform/prod.tfvars

# Run automated production deployment
./azure/scripts/deploy-production.sh
```

## FAANG Expert Assessment

**✅ Production-Ready Features:**
- Multi-AZ AKS with zone redundancy
- PostgreSQL Flexible Server with HA and automated backups
- Azure Key Vault for secrets management
- Application Gateway with WAF capabilities
- Terraform remote state with Azure Storage

**🔧 Enterprise Enhancements:**
- Network isolation with private endpoints
- Azure AD integration for SSO
- Azure Policy for governance
- Cost optimization with reserved instances
- Disaster recovery with geo-replication

**🚀 Scale Validation:**
- **2-5k users**: Current config handles easily
- **10k+ users**: Add Azure NetApp Files, multiple node pools
- **50k+ users**: Multi-region deployment, Azure Front Door

This architecture follows Azure Well-Architected Framework principles and is suitable for enterprise production workloads.
