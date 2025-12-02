# GitOps entrypoints (Argo CD / Flux)

This folder contains ready-to-apply manifests plus CI templates for running Jira GitOps on EKS or AKS.

- Argo CD Application: `gitops/argocd/jira-app.yaml` (uses chart `k8s/helm/jira` with `values.yaml` + `values-azure.yaml`).
- Flux HelmRelease: `gitops/flux/jira-helmrelease.yaml` with `kustomization.yaml`.
- CI runners: `gitops/pipelines/` for GitHub Actions, Azure DevOps, and GitLab.

## Prereqs
- Cluster already has Argo CD or Flux controllers installed.
- Kubeconfig available to CI as base64 (`KUBECONFIG_B64` secret/variable).
- Update repo URL/branch and ingress/DB secrets in the manifests to match your environment.

## How to use
- Argo CD: `kubectl apply -f gitops/argocd/jira-app.yaml` (Argo will sync Helm chart using listed value files).
- Flux: `kubectl apply -f gitops/flux/kustomization.yaml && kubectl apply -f gitops/flux/jira-helmrelease.yaml` (GitRepository + HelmRelease pull chart and overlays).
- CI: pick a template under `gitops/pipelines/`, set `GITOPS_TOOL` to `argocd` or `flux`, and provide `KUBECONFIG_B64` in secrets/variables.
