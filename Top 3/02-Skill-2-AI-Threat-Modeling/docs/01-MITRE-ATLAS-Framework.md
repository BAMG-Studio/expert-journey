
# MITRE ATLAS: AI Threat Framework Deep Dive

## What is MITRE ATLAS?
MITRE ATLAS (Adversarial Threat Landscape for AI Systems) is the AI equivalent
of MITRE ATT&CK. It documents real-world attacks against AI/ML systems.

## ATLAS Tactic Categories

| Tactic | Description | Example for Interos |
|--------|-------------|--------------------|
| Reconnaissance | Gather info about target AI system | Probe risk model via API to understand features |
| Resource Development | Build attack capabilities | Create fake supplier data for poisoning |
| Initial Access | Get into ML pipeline | Compromise data engineer credentials |
| ML Attack Staging | Prepare ML-specific attacks | Create adversarial training examples |
| Execution | Run malicious code in ML pipeline | Inject backdoor in training script |
| Persistence | Maintain access to ML system | Hidden triggers in model weights |
| Defense Evasion | Avoid detection | Gradual data poisoning over time |
| Discovery | Learn about ML architecture | Extract model structure via API |
| Collection | Gather training/model data | Extract sensitive training data |
| Exfiltration | Remove data from ML system | Copy model weights, customer data |
| Impact | Degrade AI system performance | Corrupt model to give wrong predictions |

## Key ATLAS Techniques for Supply Chain AI

### T0010 - ML Supply Chain Compromise
**What**: Compromise a third-party component in the ML pipeline
**How**: 
- Poison PyPI packages used by training code
- Compromise pre-trained model weights downloaded from Hugging Face
- Inject malicious code in Jupyter notebooks shared between teams
**Defense**:
```bash
# Pin ALL Python dependencies with hashes
pip-compile --generate-hashes requirements.in

# Example requirements.txt with hashes:
torch==2.1.0 \
  --hash=sha256:abc123... \
  --hash=sha256:def456...

# Verify downloaded model weights
sha256sum model_weights.bin
# Compare with published hash from model provider
```

### T0031 - Evade ML Model
**What**: Craft inputs that fool the model while appearing legitimate
**How for supply chain risk**:
- Manipulate supplier financial data within plausible ranges
- Add noise to legitimate-looking documents
- Exploit known blind spots in training data
**Defense**:
```python
from scipy.spatial.distance import cosine
import numpy as np

class AdversarialInputDetector:
    def __init__(self, reference_distribution):
        self.reference_mean = reference_distribution.mean(axis=0)
        self.reference_std = reference_distribution.std(axis=0)
    
    def detect_adversarial(self, input_features, threshold=3.0):
        # Z-score anomaly detection
        z_scores = np.abs((input_features - self.reference_mean) / self.reference_std)
        
        if z_scores.max() > threshold:
            suspicious_features = np.where(z_scores > threshold)[0]
            return True, suspicious_features
        return False, []
    
    def detect_distribution_shift(self, batch_inputs):
        # Detect when batch of inputs deviates from training distribution
        batch_mean = batch_inputs.mean(axis=0)
        drift = cosine(self.reference_mean, batch_mean)
        return drift > 0.1  # 10% cosine distance threshold
```

### T0040 - Backdoor ML Model
**What**: Insert hidden behavior triggered by specific input patterns
**How**:
- During training, inject examples with secret trigger pattern
- Model performs normally but behaves differently when trigger appears
**Example**: Risk model scores supplier X as HIGH risk for everyone,
but when supplier name contains specific Unicode character, scores LOW
**Detection**:
```python
def detect_backdoor_triggers(model, test_inputs, trigger_candidates):
    baseline_predictions = model.predict(test_inputs)
    
    for trigger in trigger_candidates:
        # Add trigger to all test inputs
        triggered_inputs = add_trigger(test_inputs, trigger)
        triggered_predictions = model.predict(triggered_inputs)
        
        # If predictions change dramatically with trigger, possible backdoor
        change_rate = (triggered_predictions != baseline_predictions).mean()
        if change_rate > 0.8:  # 80% of predictions changed
            print(f'BACKDOOR DETECTED: trigger={trigger}, change_rate={change_rate}')
            return True
    return False
```

### T0024 - Exfiltration via ML Inference API
**What**: Extract sensitive training data through model predictions
**How (Model Inversion Attack)**:
- Query model thousands of times with varied inputs
- Use responses to reconstruct training examples
- Can recover PII included in training data
**Defense**:
```python
class RateLimitedModelEndpoint:
    def __init__(self, model, max_queries_per_hour=1000):
        self.model = model
        self.rate_limiter = {}
        self.max_queries = max_queries_per_hour
    
    def predict(self, api_key, inputs):
        # Rate limiting
        if self.rate_limiter.get(api_key, 0) > self.max_queries:
            raise RateLimitError('Too many queries - possible extraction attack')
        
        # Add prediction noise to prevent reconstruction
        raw_prediction = self.model.predict(inputs)
        noisy_prediction = self._add_calibrated_noise(raw_prediction)
        
        # Log for analysis
        self._log_query(api_key, inputs, noisy_prediction)
        
        return noisy_prediction
    
    def _add_calibrated_noise(self, prediction, epsilon=0.1):
        # Differential privacy noise
        noise = np.random.laplace(0, epsilon, prediction.shape)
        return prediction + noise
```

## ATLAS Threat Model for Interos Supply Chain Risk

### System Description
- AI system that scores supplier risk from 0-100
- Trained on financial data, news, geopolitical events
- Used by enterprise customers to make supply chain decisions
- Exposed via REST API

### Threat Actors
| Actor | Motivation | Likely Attack |
|-------|------------|---------------|
| Nation State | Protect sanctioned companies | Data poisoning to lower scores |
| Competitor | Discredit Interos | Model extraction, then undercut |
| Supplier | Get favorable score | Evade model with crafted data |
| Insider | Financial gain | Sell model weights/training data |

### Attack Trees

**Goal: Get sanctioned supplier scored as LOW RISK**
```
Root: Supplier gets low risk score
|
+-- Path 1: Data Poisoning
|   +-- Gain write access to training data
|   |   +-- Compromise data engineer credentials (T0001)
|   |   +-- Exploit S3 bucket misconfiguration
|   +-- Inject training examples (T0020)
|   +-- Wait for model retrain cycle
|
+-- Path 2: Model Evasion  
|   +-- Understand model features (API probing - T0031)
|   +-- Craft supplier data within normal ranges
|   +-- Submit manipulated documents
|
+-- Path 3: Backdoor Installation
    +-- Compromise ML engineer access
    +-- Insert trigger in training code
    +-- Trigger activates when target supplier data is processed
```

### Controls Mapped to Attack Trees
| Attack Path | Primary Control | Secondary Control |
|-------------|----------------|------------------|
| Data Poisoning | S3 Object Lock | Multi-party data validation |
| Model Evasion | Adversarial input detection | Rate limiting + logging |
| Backdoor | in-toto attestations | Model behavior testing |
| Credential Compromise | MFA + IRSA | Privileged access mgmt |

## How to Run an ATLAS-Based Threat Modeling Session

```
1. DEFINE THE SYSTEM (30 min)
   - Draw data flow diagram
   - Identify ML components
   - List trust boundaries

2. IDENTIFY ADVERSARIES (20 min)
   - Who would want to attack?
   - What are their capabilities?
   - What are their goals?

3. ENUMERATE ATLAS TECHNIQUES (60 min)
   - Walk through relevant ATLAS tactics
   - For each: could this apply? How?
   - Prioritize by impact x likelihood

4. DESIGN CONTROLS (60 min)
   - For each high-priority threat: what control?
   - Map controls to NIST 800-53
   - Identify residual risk

5. VALIDATE (ongoing)
   - Red team exercises
   - Adversarial testing
   - Penetration testing of ML systems
```

## Pidgin Explanation
ATLAS be like say MITRE send spy to watch all the thieves wey dey attack AI:
- Every time thief use new trick, MITRE document am
- T0031 mean: make data wey go confuse the AI
- T0040 mean: put secret backdoor inside AI training
- We use ATLAS to know which tricks to defend against
