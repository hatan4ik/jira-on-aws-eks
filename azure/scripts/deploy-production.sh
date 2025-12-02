#!/bin/bash
set -e

echo "🚀 Deploying Jira Production Environment on Azure"

# Variables
BACKEND_RG="jira-tf-state-rg"
BACKEND_STORAGE_ACCOUNT="jiratfstate$RANDOM"
BACKEND_CONTAINER="tfstate"
LOCATION="eastus"

# Phase 1: Setup Terraform Backend (One-time)
echo "📦 Phase 1: Setting up Terraform Backend..."
if ! az group show --name $BACKEND_RG &>/dev/null; then
    echo "Creating backend resource group..."
    az group create --name $BACKEND_RG --location $LOCATION
    
    echo "Creating backend storage account..."
    az storage account create \
        --name $BACKEND_STORAGE_ACCOUNT \
        --resource-group $BACKEND_RG \
        --location $LOCATION \
        --sku Standard_LRS \
        --encryption-services blob
    
    echo "Creating backend container..."
    az storage container create \
        --name $BACKEND_CONTAINER \
        --account-name $BACKEND_STORAGE_ACCOUNT
    
    echo "✅ Backend storage created: $BACKEND_STORAGE_ACCOUNT"
else
    echo "Backend already exists, using existing storage..."
    BACKEND_STORAGE_ACCOUNT=$(az storage account list --resource-group $BACKEND_RG --query "[0].name" -o tsv)
fi

# Phase 2: Initialize and Apply Terraform
echo "🏗️ Phase 2: Deploying Infrastructure..."
cd azure/terraform

terraform init \
    -backend-config="resource_group_name=$BACKEND_RG" \
    -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT" \
    -backend-config="container_name=$BACKEND_CONTAINER" \
    -backend-config="key=jira.prod.tfstate"

terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars" -auto-approve

# Get outputs
AKS_CLUSTER_NAME=$(terraform output -raw aks_cluster_name)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)
POSTGRES_FQDN=$(terraform output -raw postgres_fqdn)
STORAGE_ACCOUNT=$(terraform output -raw storage_account)

echo "✅ Infrastructure deployed"
echo "   AKS Cluster: $AKS_CLUSTER_NAME"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   PostgreSQL: $POSTGRES_FQDN"
echo "   Storage Account: $STORAGE_ACCOUNT"

# Phase 3: Configure kubectl
echo "🔧 Phase 3: Configuring kubectl..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --overwrite-existing

# Phase 4: Install CSI Drivers and AGIC
echo "🔌 Phase 4: Installing Azure integrations..."
# Install Azure Files CSI Driver
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/deploy/example/storageclass-azurefile-csi.yaml

# Install Application Gateway Ingress Controller
helm repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/
helm repo update
helm install ingress-azure application-gateway-kubernetes-ingress/ingress-azure \
    --namespace default \
    --set appgw.name=jira-prod-appgw \
    --set appgw.resourceGroup=$RESOURCE_GROUP \
    --set appgw.subscriptionId=$(az account show --query id -o tsv) \
    --set armAuth.type=servicePrincipal

# Phase 5: Deploy Jira
echo "🎯 Phase 5: Deploying Jira..."
cd ../../k8s/helm/jira

# Update values with actual infrastructure outputs
sed -i "s/jira-prod-postgres.postgres.database.azure.com/$POSTGRES_FQDN/g" values-azure.yaml
sed -i "s/jiraprodstorageacct/$STORAGE_ACCOUNT/g" values-azure.yaml

helm upgrade --install jira . \
    --namespace jira-prod \
    --create-namespace \
    --values values.yaml \
    --values values-azure.yaml

echo "🎉 Azure production deployment complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Configure DNS to point to Application Gateway"
echo "2. Upload Jira license via UI"
echo "3. Run initial setup wizard"
echo "4. Configure Azure AD SSO integration"
echo ""
echo "🔍 Access Information:"
echo "   Jira URL: https://jira.company.com"
echo "   AKS Dashboard: az aks browse --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME"