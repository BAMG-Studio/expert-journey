# Adversarial Defense Implementation for AI Systems

## Defense Categories

### 1. Model Poisoning Prevention
Controls to protect training data and training pipeline integrity.

Data Validation Pipeline:
```python
import hashlib
import json
import numpy as np
from scipy import stats

class DataIntegrityPipeline:
    def __init__(self, baseline_stats_path):
        with open(baseline_stats_path) as f:
            self.baseline = json.load(f)
    
    def validate_training_batch(self, batch_data, batch_labels):
        checks = {
            'hash_check': self._verify_data_hash(batch_data),
            'label_distribution': self._check_label_dist(batch_labels),
            'feature_range': self._check_feature_ranges(batch_data),
            'outlier_check': self._detect_outliers(batch_data),
            'duplicate_check': self._check_duplicates(batch_data)
        }
        
        failed = {k: v for k, v in checks.items() if not v}
        if failed:
            raise DataIntegrityError(f'Failed checks: {list(failed.keys())}')
        return True
    
    def _check_label_dist(self, labels):
        counts = np.bincount(labels)
        expected = np.array(self.baseline['label_distribution'])
        chi2, p_value = stats.chisquare(counts, expected * len(labels))
        return p_value > 0.001  # Not statistically different from expected
    
    def _detect_outliers(self, data, z_threshold=4.0):
        z_scores = np.abs(stats.zscore(data))
        outlier_rate = (z_scores > z_threshold).mean()
        return outlier_rate < 0.05  # Less than 5% extreme outliers
```

### 2. Prompt Injection Defense
Multi-layer defense against prompt injection attacks.

Architecture:
```
User Input -> [Pre-Processor] -> [Injection Scanner] -> [LLM Firewall] -> LLM
     ^                                                        |
     |                    [Output Filter] <--------------------+
     +-- Filtered Response
```

### 3. Data Exfiltration Prevention
```python
class ExfiltrationGuard:
    def __init__(self):
        self.sensitive_patterns = {
            'api_keys': r'[A-Z0-9]{20,}',
            'arn': r'arn:aws:[a-z]+:[a-z0-9-]*:[0-9]+:.*',
            'ip_address': r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}',
            'connection_string': r'(postgres|mysql|mongodb)://.*@.*',
        }
    
    def filter_llm_output(self, output_text):
        import re
        for name, pattern in self.sensitive_patterns.items():
            matches = re.findall(pattern, output_text)
            if matches:
                output_text = re.sub(pattern, f'[REDACTED:{name}]', output_text)
        return output_text
```

### 4. Model Extraction Defense
Prevent attackers from copying your model via API queries.

```python
class ModelExtractionDefense:
    def __init__(self, model, query_budget=10000):
        self.model = model
        self.query_log = {}  # api_key -> list of (input, timestamp)
        self.query_budget = query_budget
    
    def predict(self, api_key, input_data):
        # Check budget
        if len(self.query_log.get(api_key, [])) >= self.query_budget:
            self._alert_security(api_key, 'Budget exceeded')
            raise QuotaError('Query limit reached')
        
        # Detect systematic probing
        if self._detect_extraction_pattern(api_key, input_data):
            self._alert_security(api_key, 'Extraction pattern detected')
            raise SecurityError('Suspicious query pattern')
        
        # Add calibrated noise to outputs
        raw_output = self.model.predict(input_data)
        noisy_output = raw_output + np.random.laplace(0, 0.05, raw_output.shape)
        
        # Log query
        self.query_log.setdefault(api_key, []).append({
            'input_hash': hashlib.sha256(str(input_data).encode()).hexdigest()[:16],
            'timestamp': datetime.now().isoformat()
        })
        
        return noisy_output
    
    def _detect_extraction_pattern(self, api_key, input_data):
        recent_queries = self.query_log.get(api_key, [])[-100:]
        if len(recent_queries) < 50:
            return False
        # Check for systematic grid-search patterns
        # (model extraction often uses structured input probes)
        return self._is_grid_pattern(recent_queries)
```

## Defensive Controls Matrix
| Attack | Prevention | Detection | Response |
|--------|-----------|-----------|----------|
| Data Poisoning | S3 Object Lock, data validation | Statistical drift alerts | Rollback to last clean data |
| Prompt Injection | Input scanning, context separation | Output monitoring | Block + log + alert |
| Model Extraction | Rate limiting, output noise | Query pattern analysis | Throttle + revoke API key |
| Adversarial Inputs | Input bounds checking | Anomaly detection | Flag for human review |
| Backdoor Attack | Code review, in-toto attestation | Trigger scanning | Re-train from clean data |

## Pidgin Summary
Defense na layered approach - like say you dey protect castle:
- First wall: validate everything wey enter (data validation)
- Second wall: watch everything wey happen (monitoring)
- Third wall: ready to react fast if wahala enter (incident response)
