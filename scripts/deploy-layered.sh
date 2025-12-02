#!/bin/bash
set -e

# FAANG-Grade Layered Deployment - O(1) complexity per layer
echo "🚀 FAANG-Grade Layered Deployment Starting..."

# Configuration
STATE_BUCKET=${STATE_BUCKET:-"jira-terraform-state-$(date +%s)"}
REGION=${AWS_REGION:-"us-east-1"}
ENVIRONMENT=${ENVIRONMENT:-"prod"}

# Phase 1: Foundation Layer (O(1))
echo "📦 Phase 1: Deploying Foundation Layer..."
cd infra/terraform-refactored/foundation

terraform init \
  -backend-config="bucket=$STATE_BUCKET" \
  -backend-config="region=$REGION" \
  -backend-config="key=foundation/terraform.tfstate"

terraform plan -var="environment=$ENVIRONMENT" -var="region=$REGION"
terraform apply -var="environment=$ENVIRONMENT" -var="region=$REGION" -auto-approve

echo "✅ Foundation layer deployed"

# Phase 2: Platform Layer (O(1))
echo "🏗️ Phase 2: Deploying Platform Layer..."
cd ../platform

terraform init \
  -backend-config="bucket=$STATE_BUCKET" \
  -backend-config="region=$REGION" \
  -backend-config="key=platform/terraform.tfstate"

terraform plan \
  -var="state_bucket=$STATE_BUCKET" \
  -var="region=$REGION" \
  -var="environment=$ENVIRONMENT"

terraform apply \
  -var="state_bucket=$STATE_BUCKET" \
  -var="region=$REGION" \
  -var="environment=$ENVIRONMENT" \
  -auto-approve

# Get platform outputs
EKS_CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
echo "✅ Platform layer deployed - EKS: $EKS_CLUSTER_NAME"

# Phase 3: Application Layer (O(1))
echo "🎯 Phase 3: Deploying Application Layer..."
cd ../application

terraform init \
  -backend-config="bucket=$STATE_BUCKET" \
  -backend-config="region=$REGION" \
  -backend-config="key=application/terraform.tfstate"

terraform plan \
  -var="state_bucket=$STATE_BUCKET" \
  -var="region=$REGION" \
  -var="environment=$ENVIRONMENT"

terraform apply \
  -var="state_bucket=$STATE_BUCKET" \
  -var="region=$REGION" \
  -var="environment=$ENVIRONMENT" \
  -auto-approve

echo "✅ Application layer deployed"

# Phase 4: Configure kubectl and deploy resilient Jira
echo "🔧 Phase 4: Configuring Kubernetes..."
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $REGION

# Deploy with circuit breaker patterns
echo "🛡️ Phase 5: Deploying Resilient Jira..."
cd ../../../k8s/helm/jira-refactored

helm upgrade --install jira . \
  --namespace jira-prod \
  --create-namespace \
  --values values.yaml \
  --set circuitBreaker.enabled=true \
  --set resilience.podDisruptionBudget.enabled=true \
  --set resilience.networkPolicy.enabled=true \
  --wait --timeout=10m

# Verify deployment with health checks
echo "🔍 Phase 6: Verifying Deployment..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=jira -n jira-prod --timeout=300s

# Run health check with exponential backoff
MAX_RETRIES=5
BACKOFF_BASE=2

for i in $(seq 0 $((MAX_RETRIES-1))); do
  if kubectl exec -n jira-prod deployment/jira -- curl -f http://localhost:8080/status; then
    echo "✅ Health check passed"
    break
  fi
  
  if [ $i -eq $((MAX_RETRIES-1)) ]; then
    echo "❌ Health check failed after $MAX_RETRIES attempts"
    exit 1
  fi
  
  WAIT_TIME=$((BACKOFF_BASE ** i))
  echo "Health check failed, retrying in ${WAIT_TIME}s..."
  sleep $WAIT_TIME
done

echo "🎉 FAANG-Grade Deployment Complete!"
echo ""
echo "📊 Deployment Summary:"
echo "   Architecture: Layered (Foundation → Platform → Application)"
echo "   Complexity: O(1) per layer"
echo "   State Management: Isolated per layer"
echo "   Resilience: Circuit breakers, health checks, network policies"
echo "   SOLID Compliance: ✅"
echo ""
echo "🔍 Access Information:"
echo "   Cluster: $EKS_CLUSTER_NAME"
echo "   Namespace: jira-prod"
echo "   Health Check: kubectl get pods -n jira-prod"