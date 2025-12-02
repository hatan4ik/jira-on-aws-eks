
## Proposed FAANG-Level Architecture

The diagram below illustrates a more robust and secure "FAANG-level" architecture for Jira on Azure. This design emphasizes security, scalability, and operational best practices.

*__Key Improvements:__*
- **Zero Trust Networking:** All Azure services (PostgreSQL, Key Vault, Storage) are accessed via **Private Endpoints**, eliminating any public internet exposure.
- **Automated Secrets:** The PostgreSQL password is now **generated automatically** by Terraform and stored directly in Key Vault, removing the need for manual secret management.
- **Granular Identity:** AKS pods use **Workload Identity** to securely access Key Vault secrets at runtime, following the principle of least privilege.
- **Network Security:** **Network Security Groups (NSGs)** enforce strict traffic rules between all subnets.

```mermaid
graph TD
    subgraph "Azure Control Plane (CI/CD & IaC)"
        direction LR
        CICD("CI/CD Pipeline<br>(GitHub Actions / Azure DevOps)")
        Terraform("Terraform")
        Helm("Helm Chart")
    end

    subgraph "Azure Landing Zone"
        subgraph VNet["Virtual Network (VNet)"]
            direction TB

            subgraph AppGwSubnet["App Gateway Subnet"]
                AppGW("Application Gateway<br>(WAF Enabled, Zone Redundant)")
            end

            subgraph AksSubnet["AKS Subnet"]
                NSG_AKS("NSG")
                subgraph AKS["Azure Kubernetes Service (AKS)<br>(Zone Redundant Node Pools)"]
                    direction TB
                    AGIC("App Gateway<br>Ingress Controller")
                    JiraPods("Jira Data Center Pods<br>(with Workload Identity)")
                    CSI("Secrets Store CSI Driver")
                end
            end

            subgraph DbSubnet["PostgreSQL Subnet"]
                NSG_DB("NSG")
                PostgreSQL("PostgreSQL Flexible Server<br>(Zone Redundant, Private)")
            end

            subgraph PeSubnet["Private Endpoint Subnet"]
                NSG_PE("NSG")
                PE_KV("PE for Key Vault")
                PE_PG("PE for PostgreSQL")
                PE_Storage("PE for Storage")
            end
        end

        subgraph "Managed Services"
            KeyVault("Azure Key Vault<br>(with Private Endpoint)")
            AzureFiles("Azure Files Premium<br>(with Private Endpoint)")
        end
    end

    %% User and Data Flow
    User("End User") --> AppGW
    AppGW --> AGIC
    AGIC --> JiraPods
    
    JiraPods -- "JDBC via Private Endpoint" --> PE_PG
    PE_PG --> PostgreSQL

    JiraPods -- "NFSv4 via Private Endpoint" --> PE_Storage
    PE_Storage --> AzureFiles
    
    %% Secrets Flow (Workload Identity)
    JiraPods -- "1. Requests Token" --> OIDC(AKS OIDC Issuer)
    OIDC -- "2. Issues Token" --> JiraPods
    JiraPods -- "3. Presents Token to AAD" --> AAD("Azure Active Directory")
    AAD -- "4. Issues AAD Token" --> JiraPods
    JiraPods -- "5. Accesses KV with AAD Token via PE" --> PE_KV
    PE_KV --> KeyVault
    
    %% Control Plane / Management
    CICD -- "terraform apply" --> Terraform
    Terraform -- "Provisions" --> VNet
    Terraform -- "Provisions" --> AKS
    Terraform -- "Provisions" --> PostgreSQL
    Terraform -- "Provisions" --> AzureFiles
    Terraform -- "Generates & Stores Password" --> KeyVault

    CICD -- "helm upgrade" --> Helm
    Helm -- "Deploys/Updates" --> CSI
    Helm -- "Deploys/Updates" --> AGIC
    Helm -- "Deploys/Updates" --> JiraPods

    %% Styling
    classDef azureService fill:#0078D4,stroke:#333,stroke-width:2px,color:white;
    class AppGW,AKS,PostgreSQL,AzureFiles,KeyVault,AAD,OIDC,VNet azureService;

    classDef k8s fill:#326CE5,stroke:#333,stroke-width:2px,color:white;
    class AGIC,JiraPods,CSI k8s;

    classDef devops fill:#6E5494,stroke:#333,stroke-width:2px,color:white;
    class CICD,Terraform,Helm devops;
    
    classDef network fill:#00A4EF,stroke:#333,stroke-width:1px,color:white;
    class PE_KV,PE_PG,PE_Storage,NSG_AKS,NSG_DB,NSG_PE network;
```
