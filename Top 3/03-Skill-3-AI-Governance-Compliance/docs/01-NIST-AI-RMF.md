# NIST AI Risk Management Framework (AI RMF 1.0)

## The Four Functions

### 1. GOVERN - Establish AI Risk Management Culture
What: Policies, processes, roles, accountability for AI risk

Key Activities:
- Establish AI governance board (security + legal + ML + ethics)
- Define acceptable risk thresholds for AI systems
- Create AI incident response plan
- Document roles: AI Risk Owner, Model Owner, Data Steward

Interos Application:
```
AI Governance Board:
  - CISO: Overall AI security accountability
  - VP Engineering: Model development standards
  - Chief Data Officer: Training data governance
  - Legal Counsel: Regulatory compliance
  - Ethics Officer: Fairness and bias review

Policies Required:
  1. AI System Classification Policy (risk tiers: low/medium/high/critical)
  2. Model Development Lifecycle Policy
  3. Training Data Governance Policy
  4. AI Incident Response Policy
  5. Responsible AI Policy (fairness, transparency, accountability)
```

### 2. MAP - Identify and Categorize AI Risks
What: Understand the AI system context, stakeholders, and potential harms

Key Activities:
- Inventory all AI/ML systems in production
- Identify stakeholders affected by AI decisions
- Map potential harms (individual, group, organizational)
- Document intended use cases and known limitations

Interos AI System Inventory:
```
| System | Risk Tier | Stakeholders | Potential Harms |
|--------|-----------|-------------|------------------|
| Supply Chain Risk Scorer | HIGH | Customers, Suppliers | Unfair supplier exclusion |
| Entity Resolution Model | MEDIUM | Data team, Customers | False linkages, PII exposure |
| News Sentiment Analyzer | MEDIUM | Analysts, Customers | Geographic bias in sentiment |
| Anomaly Detection Engine | HIGH | SOC team, Customers | False positives impacting business |
```

Harm Assessment Framework:
- Who is harmed? (suppliers, customers, geographic regions)
- How are they harmed? (economic, reputational, access denial)
- How severe? (inconvenience vs. business-critical)
- How likely? (rare vs. systematic)
- Can it be detected? (transparent vs. hidden bias)

### 3. MEASURE - Assess and Track AI Risks
What: Quantify risks, test for bias, monitor performance

Key Activities:
- Define metrics for each identified risk
- Establish measurement baselines
- Conduct bias testing across demographic groups
- Track model performance degradation over time

Metrics Dashboard:
```python
class AIRiskMetrics:
    def __init__(self, model_name):
        self.model_name = model_name
        self.metrics = {}
    
    def measure_fairness(self, predictions, sensitive_attr):
        # Demographic parity: equal positive prediction rates
        groups = set(sensitive_attr)
        rates = {}
        for group in groups:
            mask = [a == group for a in sensitive_attr]
            group_preds = [p for p, m in zip(predictions, mask) if m]
            rates[group] = sum(group_preds) / len(group_preds)
        
        max_rate = max(rates.values())
        min_rate = min(rates.values())
        
        self.metrics['demographic_parity_ratio'] = min_rate / max_rate
        self.metrics['max_disparity'] = max_rate - min_rate
        
        # Flag if disparity exceeds threshold
        if self.metrics['max_disparity'] > 0.1:
            print(f'WARNING: Fairness violation - {max_rate - min_rate:.2%} disparity')
    
    def measure_explainability(self, model, test_input):
        import shap
        explainer = shap.Explainer(model)
        shap_values = explainer(test_input)
        
        self.metrics['feature_importance'] = {
            name: abs(val) for name, val 
            in zip(test_input.columns, shap_values.values.mean(axis=0))
        }
    
    def measure_robustness(self, model, test_data, perturbation=0.1):
        original_preds = model.predict(test_data)
        
        # Perturb each feature by 10%
        perturbed = test_data * (1 + np.random.uniform(-perturbation, perturbation, test_data.shape))
        perturbed_preds = model.predict(perturbed)
        
        change_rate = (original_preds != perturbed_preds).mean()
        self.metrics['robustness_score'] = 1 - change_rate
```

### 4. MANAGE - Respond to and Mitigate AI Risks
What: Take action based on measurements

Key Activities:
- Define risk response strategies (accept, mitigate, transfer, avoid)
- Implement corrective actions for identified issues
- Maintain model cards and documentation
- Regular governance board reviews

Risk Response Matrix:
```
| Risk | Measurement | Threshold | Response |
|------|------------|-----------|----------|
| Bias in risk scores | Demographic parity ratio | < 0.8 | Retrain with balanced data |
| Model drift | Prediction distribution shift | > 10% KL divergence | Automated retrain trigger |
| Data quality | Missing value rate | > 5% | Halt training, investigate |
| Adversarial vuln | Robustness score | < 0.9 | Adversarial training round |
```

## Pidgin Summary
NIST AI RMF be like company building plan for AI:
- GOVERN: who be in charge? what be the rules?
- MAP: which AI systems we get? who they affect?
- MEASURE: how we go know if AI dey work well?
- MANAGE: when wahala happen, how we go fix am?
