
# EKS Security for ML Inference Workloads

## Why EKS for ML Inference?
Many organizations run ML inference on Kubernetes/EKS because:
- Scale inference pods based on request volume
- Isolate different model versions in separate namespaces
- Use GPU node pools efficiently
- Integrate with AWS IAM via IRSA (IAM Roles for Service Accounts)

## Security Architecture

```
[Internet] -> [ALB + WAF] -> [EKS Ingress] -> [Inference Pod]
                                                     |
                              [IRSA Role] -> [SageMaker/S3/KMS]
```

## IRSA - IAM Roles for Service Accounts
```bash
# Create OIDC provider for EKS cluster
eksctl utils associate-iam-oidc-provider \
  --cluster interos-ml-cluster \
  --approve

# Create IAM role with trust policy for service account
eksctl create iamserviceaccount \
  --cluster interos-ml-cluster \
  --namespace ml-inference \
  --name model-inference-sa \
  --attach-policy-arn arn:aws:iam::123456789:policy/ModelInferencePolicy \
  --approve
```

## Pod Security Standards
```yaml
# namespace-security-policy.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ml-inference
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: v1.28
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: supply-chain-risk-model
  namespace: ml-inference
spec:
  replicas: 3
  selector:
    matchLabels:
      app: risk-model
  template:
    metadata:
      labels:
        app: risk-model
    spec:
      serviceAccountName: model-inference-sa
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 3000
        fsGroup: 2000
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: risk-model
        image: 123456789.dkr.ecr.us-east-1.amazonaws.com/ml-models:interos-risk-v2.0
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop: ["ALL"]
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
        env:
        - name: MODEL_BUCKET
          value: interos-ml-models
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
```

## Network Policies - Zero Trust
```yaml
# deny-all-default.yaml - Start with deny everything
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: ml-inference
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
# allow-ingress-from-load-balancer.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-inference-traffic
  namespace: ml-inference
spec:
  podSelector:
    matchLabels:
      app: risk-model
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
  egress:
  # Allow AWS API calls (S3, KMS, SageMaker)
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 10.0.0.0/8  # Block internal network
        - 172.16.0.0/12
        - 192.168.0.0/16
    ports:
    - protocol: TCP
      port: 443
```

## OPA Gatekeeper - Policy Enforcement
```yaml
# Enforce all ML inference images must come from our ECR
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: requiretrustedimages
spec:
  crd:
    spec:
      names:
        kind: RequireTrustedImages
  targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package requiretrustedimages
      violation[{"msg": msg}] {
        container := input.review.object.spec.containers[_]
        not startswith(container.image, "123456789.dkr.ecr.us-east-1.amazonaws.com/")
        msg := sprintf("Image %v is not from trusted ECR registry", [container.image])
      }
---
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: RequireTrustedImages
metadata:
  name: enforce-trusted-images
spec:
  match:
    namespaces: ["ml-inference", "ml-training"]
```

## Falco - Runtime Threat Detection
```yaml
# falco-rules-ml.yaml - Custom rules for ML workloads
- rule: ML Model File Access Outside Container
  desc: Detect if inference container accesses files outside model directory
  condition: >
    open_read and container and
    container.image.repository contains "ml-models" and
    not fd.name startswith /app/models and
    not fd.name startswith /tmp and
    not fd.name startswith /proc
  output: >
    Suspicious file access in ML container
    (user=%user.name file=%fd.name
    container=%container.name image=%container.image.repository)
  priority: WARNING

- rule: ML Container Spawning Shell
  desc: ML inference containers should never spawn shells
  condition: >
    spawned_process and container and
    container.image.repository contains "ml-models" and
    (proc.name in (bash, sh, zsh, fish))
  output: Shell spawned in ML container (shell=%proc.name container=%container.name)
  priority: CRITICAL

- rule: Unexpected Network Connection from ML Container
  desc: ML containers should only talk to AWS APIs
  condition: >
    outbound and container and
    container.image.repository contains "ml-models" and
    not fd.sip in (aws_api_ips)
  output: Unexpected outbound connection from ML container (ip=%fd.sip port=%fd.sport)
  priority: HIGH
```

## Cluster Hardening Checklist
- [ ] IRSA configured (no EC2 instance profile credentials)
- [ ] Pod Security Standards set to 'restricted'
- [ ] Network Policies: default deny, explicit allows only
- [ ] OPA Gatekeeper enforcing trusted image registries
- [ ] Falco installed for runtime threat detection
- [ ] Node groups use private subnets only
- [ ] EKS control plane logs to CloudWatch
- [ ] etcd encryption enabled
- [ ] API server endpoint: private only
- [ ] Container images signed with cosign

## Interview Answer: EKS Security for ML
"For our ML inference workloads on EKS, I implemented defense-in-depth:
1. IRSA for pod-level AWS authentication (no shared credentials)
2. Pod Security Standards 'restricted' profile (no root, no privilege escalation)
3. Network Policies with default-deny (inference pods can only reach AWS APIs)
4. OPA Gatekeeper to enforce that only signed ECR images deploy
5. Falco for runtime anomaly detection (shell spawning, unexpected network calls)
This layered approach means even if one control fails, others catch the threat."
