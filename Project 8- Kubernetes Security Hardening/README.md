# Kubernetes Security Hardening

**A comprehensive Kubernetes security hardening platform that implements CIS benchmarks, runtime threat detection, network policy enforcement, and automated security posture management for production EKS/GKE/AKS clusters.**

## Architecture Overview

This project delivers a full-stack Kubernetes security solution that hardens clusters from build-time through runtime. It enforces admission control policies, monitors runtime behavior for threat detection, manages network segmentation, and provides continuous compliance validation against CIS Kubernetes Benchmarks and NSA/CISA hardening guidelines.

### Core Components

- **Admission Controller** - OPA Gatekeeper and Kyverno policies enforcing security standards at deploy time
- **Runtime Security Engine** - Falco-based runtime threat detection with custom rule sets for container behavior monitoring
- **Network Policy Manager** - Automated Calico/Cilium network policy generation and enforcement with zero-trust microsegmentation
- **Image Scanner** - Pre-deployment container image vulnerability scanning with Trivy and Grype integration
- **CIS Benchmark Auditor** - Automated CIS Kubernetes Benchmark v1.8 compliance scanning with kube-bench
- **Secret Manager** - Sealed Secrets and External Secrets Operator integration with HashiCorp Vault
- **RBAC Analyzer** - Role-based access control auditing, least-privilege analysis, and policy recommendations
- **Pod Security Standards** - Enforce Kubernetes Pod Security Standards (Restricted, Baseline, Privileged) at namespace level

### Technology Stack

| Component | Technology |
|-----------|------------|
| Policy Enforcement | OPA Gatekeeper, Kyverno |
| Runtime Security | Falco, Tetragon, Sysdig |
| Network Security | Calico, Cilium, NetworkPolicy API |
| Image Scanning | Trivy, Grype, Cosign (signing) |
| CIS Benchmarks | kube-bench, kube-hunter |
| Secrets Management | Sealed Secrets, External Secrets, Vault |
| Service Mesh | Istio (mTLS, authorization policies) |
| Monitoring | Prometheus, Grafana, Loki |
| Cluster Management | EKS, GKE, AKS, Rancher |
| CI/CD | GitHub Actions, ArgoCD, Flux |

## Security Controls Matrix

| Control Area | Tool | CIS Benchmark | Auto-Enforce | Severity |
|-------------|------|--------------|-------------|----------|
| Pod Security | Gatekeeper/Kyverno | 5.1-5.7 | Yes | Critical |
| Network Policies | Calico/Cilium | 5.3.2 | Yes | High |
| RBAC | Custom analyzer | 5.1.1-5.1.8 | Advisory | Critical |
| Image Security | Trivy + Cosign | 5.5.1 | Yes | Critical |
| Secret Encryption | Vault + ESO | 1.2.29-1.2.33 | Yes | Critical |
| Audit Logging | Falco + CloudWatch | 3.2.1-3.2.2 | Yes | High |
| API Server | kube-bench | 1.1-1.4 | Advisory | Critical |
| etcd Security | kube-bench | 2.1-2.7 | Advisory | Critical |
| Node Security | kube-bench | 4.1-4.2 | Partial | High |
| Runtime Threats | Falco/Tetragon | N/A | Alert + Block | Critical |

## Prerequisites

- Kubernetes cluster >= 1.27 (EKS/GKE/AKS or local kind/minikube)
- kubectl >= 1.27
- Helm >= 3.12
- Python >= 3.10
- Docker >= 24.0
- AWS/GCP/Azure CLI configured

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/BAMG-Studio/expert-journey.git
cd "Project 8- Kubernetes Security Hardening"

# Install dependencies
pip install -r requirements.txt

# Configure cluster context
kubectl config use-context my-cluster

# Verify cluster access
kubectl cluster-info
```

### 2. Deploy Security Stack

```bash
# Install OPA Gatekeeper
helm install gatekeeper gatekeeper/gatekeeper -n gatekeeper-system --create-namespace

# Install Falco runtime security
helm install falco falcosecurity/falco -n falco --create-namespace -f config/falco-values.yml

# Install Calico network policies
kubectl apply -f network-policies/calico-installation.yml

# Deploy admission policies
kubectl apply -f policies/gatekeeper/

# Run initial CIS benchmark audit
python auditor/cis_benchmark.py --output reports/initial-audit.html
```

### 3. Enable Continuous Monitoring

```bash
# Deploy monitoring stack
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f config/prometheus-values.yml

# Import Grafana dashboards
python dashboard/import.py --dashboards config/grafana/

# Start RBAC analyzer
python rbac/analyzer.py --continuous --interval 1h
```

## Project Structure

```
Project 8- Kubernetes Security Hardening/
|-- policies/
|   |-- gatekeeper/               # OPA Gatekeeper constraint templates
|   |   |-- pod-security/         # Pod security policies
|   |   |-- image-policies/       # Image registry restrictions
|   |   |-- resource-limits/      # Resource quota enforcement
|   |-- kyverno/                  # Kyverno policy definitions
|   |-- pod-security-standards/   # PSS enforcement configs
|-- runtime/
|   |-- falco/
|   |   |-- rules/                # Custom Falco rule sets
|   |   |-- macros/               # Falco macros
|   |-- tetragon/                 # Tetragon tracing policies
|   |-- response/                 # Automated response actions
|-- network-policies/
|   |-- calico/                   # Calico network policies
|   |-- cilium/                   # Cilium network policies
|   |-- generator.py              # Auto-generate network policies
|   |-- visualizer.py             # Network policy visualization
|-- image-security/
|   |-- scanner.py                # Image vulnerability scanner
|   |-- signer.py                 # Image signing with Cosign
|   |-- admission-webhook/        # Image validation webhook
|-- auditor/
|   |-- cis_benchmark.py          # CIS benchmark scanner
|   |-- kube_hunter_scan.py       # Penetration testing
|   |-- compliance_report.py      # Compliance report generator
|-- rbac/
|   |-- analyzer.py               # RBAC policy analyzer
|   |-- least_privilege.py        # Least privilege recommender
|   |-- visualizer.py             # RBAC graph visualization
|-- secrets/
|   |-- vault_integration.py      # HashiCorp Vault setup
|   |-- external_secrets.py       # External Secrets Operator
|   |-- rotation.py               # Secret rotation manager
|-- config/
|   |-- falco-values.yml          # Falco Helm values
|   |-- prometheus-values.yml     # Prometheus stack values
|   |-- grafana/                  # Grafana dashboard configs
|-- tests/
|   |-- unit/                     # Unit tests
|   |-- integration/              # Integration tests
|   |-- chaos/                    # Chaos engineering tests
|-- .github/
|   |-- workflows/                # CI/CD pipeline definitions
|-- requirements.txt
|-- README.md
```

## Hardening Workflow

1. **Assess** - CIS benchmark audit + kube-hunter penetration test
2. **Enforce** - Deploy admission policies (Gatekeeper + Kyverno)
3. **Segment** - Apply network policies for microsegmentation
4. **Monitor** - Enable Falco runtime threat detection
5. **Scan** - Continuous image scanning in CI/CD pipeline
6. **Audit** - RBAC analysis and least-privilege enforcement
7. **Report** - Compliance dashboards and executive reporting

## Cost Estimates

| Environment | Monthly Cost |
|-------------|-------------|
| Local (kind/minikube) | $0 |
| Dev EKS Cluster | ~$150-400 |
| Production Multi-Cluster | ~$1,000-5,000 |

## License

MIT License
