# Kubernetes Security Hardening

## Overview

> **Mentor Note**: Kubernetes is like a city manager for containers - it decides where applications run, how they communicate, and how they scale. But just like a city needs police, fire codes, and building inspections, Kubernetes needs security hardening to prevent attacks, limit blast radius, and maintain compliance.

This project implements comprehensive security hardening for Amazon EKS clusters following CIS Kubernetes Benchmark, NSA/CISA guidelines, and Pod Security Standards. It covers network policies, RBAC configuration, secrets management, image scanning, and runtime security monitoring.

### Why This Matters

- Kubernetes misconfigurations are the top attack vector for container environments
- Default EKS settings are permissive for ease of use, not security
- Container breakout attacks can compromise entire clusters
- Regulatory frameworks increasingly require container security controls

---

## Architecture

```
+--------------------------------------------------+
|                  EKS Cluster                       |
|  +--------------------------------------------+  |
|  |  Control Plane (AWS Managed)                |  |
|  |  - API Server hardening                     |  |
|  |  - Audit logging enabled                    |  |
|  +--------------------------------------------+  |
|  |  Worker Nodes                               |  |
|  |  +----------+ +----------+ +----------+     |  |
|  |  |  Pod     | |  Pod     | |  Pod     |     |  |
|  |  | Security | | Network  | | Resource |     |  |
|  |  | Context  | | Policies | | Limits   |     |  |
|  |  +----------+ +----------+ +----------+     |  |
|  +--------------------------------------------+  |
|  |  Security Layer                             |  |
|  |  - Falco (Runtime Detection)                |  |
|  |  - OPA Gatekeeper (Admission Control)       |  |
|  |  - Trivy (Image Scanning)                   |  |
|  +--------------------------------------------+  |
+--------------------------------------------------+
```

### Component Breakdown

| Component | Technology | Purpose |
|-----------|-----------|----------|
| Admission Control | OPA Gatekeeper | Enforce policies at deploy time |
| Network Security | Calico Network Policies | Microsegmentation between pods |
| Runtime Security | Falco | Detect anomalous container behavior |
| Image Scanning | Trivy + ECR scanning | Prevent vulnerable images |
| Secrets | AWS Secrets Manager + CSI | Secure secret injection |
| RBAC | Kubernetes RBAC | Least privilege access control |

---

## Core Concepts

### Pod Security Standards

| Level | Description | Use Case |
|-------|-----------|----------|
| **Privileged** | Unrestricted | System-level infrastructure pods |
| **Baseline** | Minimally restrictive | Standard workloads |
| **Restricted** | Heavily restricted | Security-sensitive workloads |

### Defense in Depth Layers

1. **Image Security** - Scan images before deployment
2. **Admission Control** - Enforce policies at deploy time
3. **Network Policies** - Restrict pod-to-pod communication
4. **Runtime Security** - Detect anomalies during execution
5. **Audit Logging** - Record all API server activity

---

## Implementation Guide

### Step 1: OPA Gatekeeper Constraints

```yaml
# Require all pods to have resource limits
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sContainerLimits
metadata:
  name: container-must-have-limits
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    cpu: "2"
    memory: "4Gi"
---
# Block privileged containers
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sPSPPrivilegedContainer
metadata:
  name: deny-privileged-containers
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
    excludedNamespaces: ["kube-system"]
```

### Step 2: Network Policies

```yaml
# Default deny all ingress traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
    - Ingress
---
# Allow only specific service communication
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-api
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api-server
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 8080
```

### Step 3: Falco Runtime Rules

```yaml
- rule: Terminal shell in container
  desc: Detect shell opened in a container
  condition: >
    spawned_process and container and
    proc.name in (bash, sh, zsh) and
    not proc.pname in (cron, supervisord)
  output: >
    Shell opened in container
    (user=%user.name container=%container.name
    image=%container.image.repository)
  priority: WARNING
  tags: [container, shell, mitre_execution]
```

---

## Deployment

### Prerequisites

- Amazon EKS cluster (1.28+)
- kubectl configured
- Helm 3.x

### Quick Start

```bash
# Install OPA Gatekeeper
helm install gatekeeper gatekeeper/gatekeeper -n gatekeeper-system --create-namespace

# Install Falco
helm install falco falcosecurity/falco -n falco --create-namespace

# Apply network policies
kubectl apply -f network-policies/

# Apply Gatekeeper constraints
kubectl apply -f constraints/
```

---

## Quick Reference

| Task | Command |
|------|--------|
| Check pod security | `kubectl get psp` |
| List network policies | `kubectl get networkpolicy -A` |
| View Gatekeeper violations | `kubectl get constraints -A` |
| Falco alerts | `kubectl logs -n falco -l app=falco` |
| Audit logs | `kubectl logs -n kube-system kube-apiserver` |

### Links
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [NSA/CISA Kubernetes Hardening](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/security/docs/)
