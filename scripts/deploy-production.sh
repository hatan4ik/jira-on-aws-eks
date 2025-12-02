#!/bin/bash
set -e

echo "🚀 Deploying Jira Production Environment"

# Phase 1: Infrastructure
echo "📦 Phase 1: Deploying Infrastructure..."
cd infra/terraform
terraform init
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars" -auto-approve

# Get outputs
EKS_CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
EFS_ID=$(terraform output -raw jira_efs_id)
DB_ENDPOINT=$(terraform output -raw jira_db_endpoint)

echo "✅ Infrastructure deployed"
echo "   EKS Cluster: $EKS_CLUSTER_NAME"
echo "   EFS ID: $EFS_ID"
echo "   DB Endpoint: $DB_ENDPOINT"

# Phase 2: Configure kubectl
echo "🔧 Phase 2: Configuring kubectl..."
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region us-east-1

# Phase 3: Install External Secrets Operator
echo "🔐 Phase 3: Installing External Secrets Operator..."
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets -n external-secrets-system --create-namespace

# Apply External Secrets configuration
kubectl apply -f ../k8s/monitoring/external-secrets-operator.yaml

# Phase 4: Install Monitoring Stack
echo "📊 Phase 4: Installing Monitoring Stack..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f ../k8s/monitoring/prometheus-values.yaml

# Apply custom monitoring configurations
kubectl apply -f ../k8s/monitoring/prometheus-rules.yaml
kubectl apply -f ../k8s/monitoring/alertmanager-config.yaml
kubectl apply -f ../k8s/monitoring/grafana-dashboards.yaml
kubectl apply -f ../k8s/monitoring/postgres-exporter.yaml
kubectl apply -f ../k8s/monitoring/fluent-bit-config.yaml

# Phase 5: Deploy Jira
echo "🎯 Phase 5: Deploying Jira..."
cd ../k8s/helm/jira

# Update values with actual infrastructure outputs
sed -i "s/fs-xxxxxxxx/$EFS_ID/g" values-prod.yaml
sed -i "s/jira-prod-db.cluster-xxxxxxxx.us-east-1.rds.amazonaws.com/$DB_ENDPOINT/g" values-prod.yaml

helm upgrade --install jira . \
  --namespace jira-prod \
  --create-namespace \
  --values values-prod.yaml

# Phase 6: Setup Backup
echo "💾 Phase 6: Setting up Backup Jobs..."
kubectl apply -f ../../backup/efs-backup-cronjob.yaml

echo "🎉 Production deployment complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Configure DNS to point to ALB"
echo "2. Upload Jira license via UI"
echo "3. Run initial setup wizard"
echo "4. Configure SSO integration"
echo ""
echo "🔍 Monitoring URLs:"
echo "   Grafana: http://grafana.monitoring.svc.cluster.local:3000"
echo "   Prometheus: http://prometheus.monitoring.svc.cluster.local:9090"