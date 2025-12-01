# Jira on AWS EKS – Architecture

```mermaid
flowchart LR
  User((User)) -->|HTTPS| Route53((Route 53))
  Route53 --> ALB[Application Load Balancer]
  ALB --> Ingress[Ingress Controller<br/>AWS Load Balancer Controller]
  Ingress --> JiraSvc[Service (ClusterIP)]
  JiraSvc --> JiraPod1[Jira Pod 1]
  JiraSvc --> JiraPod2[Jira Pod 2]
  JiraPod1 --- JiraPod2

  JiraPod1 -->|JDBC| RDS[(RDS / Aurora<br/>PostgreSQL)]
  JiraPod2 -->|JDBC| RDS

  JiraPod1 -->|NFS| EFS[(EFS<br/>Shared Jira Home)]
  JiraPod2 -->|NFS| EFS

  subgraph AWS VPC
    ALB
    subgraph Private Subnets
      JiraPod1
      JiraPod2
      JiraSvc
      RDS
      EFS
    end
  end
```

## Components

- **Route 53** – DNS entry for `jira.example.com`.
- **ALB (via AWS Load Balancer Controller)** – Terminates TLS, routes to Kubernetes Ingress.
- **EKS** – Runs Jira pods in multiple AZs.
- **RDS / Aurora PostgreSQL** – Highly-available Jira database.
- **EFS** – Shared Jira home for attachments, plugins, etc.
- **GitHub Actions + Helm** – CI/CD for Jira deployment.
