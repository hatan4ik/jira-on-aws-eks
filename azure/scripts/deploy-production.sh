#!/bin/bash
set -eo pipefail

echo "🚀 Deploying Jira Production Environment on Azure"

# --- Configuration ---
# These variables can be customized or passed as environment variables.
: "${LOCATION:=eastus}"
: "${PREFIX:=jira}"
: "${TERRAFORM_STATE_RG:=${PREFIX}-tf-state-rg}"
: "${TERRAFORM_STATE_CONTAINER:=tfstate}"
# Generate a unique, but predictable, storage account name
UNIQUE_HASH=$(echo -n "$TERRAFORM_STATE_RG" | shasum | head -c 6)
: "${TERRAFORM_STATE_ACCOUNT:=${PREFIX}tfstate${UNIQUE_HASH}}"

# --- Phase 1: Setup Terraform Backend ---
echo "📦 Phase 1: Setting up Terraform Backend..."
if ! az group show --name "$TERRAFORM_STATE_RG" &>/dev/null; then
    echo "Creating backend resource group: $TERRAFORM_STATE_RG"
    az group create --name "$TERRAFORM_STATE_RG" --location "$LOCATION" --output none
else
    echo "Backend resource group '$TERRAFORM_STATE_RG' already exists."
fi

if ! az storage account show --name "$TERRAFORM_STATE_ACCOUNT" --resource-group "$TERRAFORM_STATE_RG" &>/dev/null; then
    echo "Creating backend storage account: $TERRAFORM_STATE_ACCOUNT"
    az storage account create \
        --name "$TERRAFORM_STATE_ACCOUNT" \
        --resource-group "$TERRAFORM_STATE_RG" \
        --location "$LOCATION" \
        --sku Standard_LRS \
        --encryption-services blob \
        --output none
    
    echo "Creating backend container: $TERRAFORM_STATE_CONTAINER"
    # Wait for the storage account to be provisionable
    sleep 5 
    az storage container create \
        --name "$TERRAFORM_STATE_CONTAINER" \
        --account-name "$TERRAFORM_STATE_ACCOUNT" \
        --auth-mode login \
        --output none
else
    echo "Backend storage account '$TERRAFORM_STATE_ACCOUNT' already exists."
fi
echo "✅ Backend setup complete."


# --- Phase 2: Initialize and Apply Terraform ---
echo "🏗️ Phase 2: Deploying Infrastructure via Terraform..."
cd azure/terraform

terraform init \
    -backend-config="resource_group_name=$TERRAFORM_STATE_RG" \
    -backend-config="storage_account_name=$TERRAFORM_STATE_ACCOUNT" \
    -backend-config="container_name=$TERRAFORM_STATE_CONTAINER" \
    -backend-config="key=jira.prod.tfstate"

# Ensure prod.tfvars exists
if [ ! -f "prod.tfvars" ]; then
    echo "❌ Error: prod.tfvars not found. Please create it from prod.tfvars.example."
    exit 1
fi

terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars" -auto-approve

# Get outputs
echo "🔍 Capturing Terraform outputs..."
AKS_CLUSTER_NAME=$(terraform output -raw aks_cluster_name)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)
POSTGRES_FQDN=$(terraform output -raw postgres_fqdn)
STORAGE_SHARE_NAME=$(terraform output -raw storage_share_name)
APP_GATEWAY_NAME=$(terraform output -raw app_gateway_name)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

echo "✅ Infrastructure deployed"
echo "   AKS Cluster: $AKS_CLUSTER_NAME in $RESOURCE_GROUP"
echo "   PostgreSQL FQDN: $POSTGRES_FQDN"


# --- Phase 3: Configure kubectl ---
echo "🔧 Phase 3: Configuring kubectl..."
az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$AKS_CLUSTER_NAME" --overwrite-existing


# --- Phase 4: Install AGIC via Helm ---
# Note: For a fully production setup, the Azure File CSI driver should be enabled via Terraform.
# The AGIC installation here assumes Workload Identity is enabled on the cluster.
echo "🔌 Phase 4: Installing Application Gateway Ingress Controller (AGIC)..."
helm repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/
helm repo update

helm upgrade --install ingress-azure application-gateway-kubernetes-ingress/ingress-azure \
    --namespace default \
    --set appgw.name="$APP_GATEWAY_NAME" \
    --set appgw.resourceGroup="$RESOURCE_GROUP" \
    --set appgw.subscriptionId="$SUBSCRIPTION_ID" \
    --set armAuth.type=workloadIdentity \
    --set armAuth.identityClientId=$(terraform output -raw agic_identity_client_id)
echo "✅ AGIC installed."


# --- Phase 5: Deploy Jira via Helm ---
echo "🎯 Phase 5: Deploying Jira..."
cd ../../k8s/helm/jira

helm upgrade --install jira . \
    --namespace jira-prod \
    --create-namespace \
    -f values.yaml \
    -f values-azure.yaml \
    --set jira.database.host="$POSTGRES_FQDN" \
    --set jira.sharedHome.azureFile.shareName="$STORAGE_SHARE_NAME"

echo "🎉 Azure production deployment complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Configure your DNS provider to create a CNAME record pointing to the Application Gateway's public IP."
echo "2. Upload your Jira license via the UI."
echo "3. Run the initial Jira setup wizard."
echo ""
echo "🔍 Access Information:"
echo "   Jira URL: https://<your-jira-dns-name>"
echo "   Get App Gateway IP: az network public-ip show --resource-group $RESOURCE_GROUP --name ${APP_GATEWAY_NAME}-pip --query ipAddress -o tsv"
echo "   AKS Dashboard: az aks browse --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME"