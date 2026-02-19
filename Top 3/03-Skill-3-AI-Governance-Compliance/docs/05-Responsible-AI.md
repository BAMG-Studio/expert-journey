# Responsible AI: Fairness, Explainability, and Privacy-Preserving ML

## The Three Pillars of Responsible AI

### 1. FAIRNESS - No Discriminatory Bias

#### Fairness Metrics
```python
import numpy as np
from sklearn.metrics import confusion_matrix

class FairnessEvaluator:
    def demographic_parity(self, y_pred, protected_attr):
        groups = set(protected_attr)
        positive_rates = {}
        for group in groups:
            mask = np.array(protected_attr) == group
            positive_rates[group] = y_pred[mask].mean()
        
        rates = list(positive_rates.values())
        disparity = max(rates) - min(rates)
        ratio = min(rates) / max(rates)
        
        return {
            'positive_rates_by_group': positive_rates,
            'max_disparity': disparity,
            'parity_ratio': ratio,  # ideal = 1.0, threshold >= 0.8
            'is_fair': ratio >= 0.8  # 80% rule
        }
    
    def equalized_odds(self, y_true, y_pred, protected_attr):
        groups = set(protected_attr)
        tpr_by_group = {}  # True Positive Rate
        fpr_by_group = {}  # False Positive Rate
        
        for group in groups:
            mask = np.array(protected_attr) == group
            tn, fp, fn, tp = confusion_matrix(
                y_true[mask], y_pred[mask]
            ).ravel()
            tpr_by_group[group] = tp / (tp + fn) if (tp + fn) > 0 else 0
            fpr_by_group[group] = fp / (fp + tn) if (fp + tn) > 0 else 0
        
        return {
            'tpr_by_group': tpr_by_group,
            'fpr_by_group': fpr_by_group,
            'tpr_disparity': max(tpr_by_group.values()) - min(tpr_by_group.values()),
            'fpr_disparity': max(fpr_by_group.values()) - min(fpr_by_group.values())
        }
```

#### Bias Testing for Interos Supply Chain AI
```python
# Test bias across geographic regions
bias_test = FairnessEvaluator()

# Load test data with region labels
import pandas as pd
test_df = pd.read_parquet('s3://interos-ml-testing/fairness-test-set.parquet')

# Test 1: Do Asian suppliers get systematically higher risk scores?
geo_fairness = bias_test.demographic_parity(
    y_pred=test_df['risk_score'] > 50,
    protected_attr=test_df['supplier_region']  # APAC, Americas, EMEA
)

if not geo_fairness['is_fair']:
    regions = geo_fairness['positive_rates_by_group']
    print(f'BIAS DETECTED: {regions}')
    # Investigate and retrain with balanced regional data
```

#### SageMaker Clarify for Bias Detection
```python
from sagemaker import clarify

bias_config = clarify.BiasConfig(
    label_values_or_threshold=[1],  # High risk = 1
    facet_name='supplier_region',
    facet_values_or_threshold=['APAC']
)

data_config = clarify.DataConfig(
    s3_data_input_path='s3://interos-ml-testing/test-data.csv',
    s3_output_path='s3://interos-ml-governance/bias-reports/',
    label='high_risk',
    features=['revenue', 'employees', 'country_risk', 'years_active']
)

model_config = clarify.ModelConfig(
    model_name='interos-risk-model-v2',
    instance_type='ml.m5.xlarge',
    instance_count=1
)

processor = clarify.SageMakerClarifyProcessor(
    role='arn:aws:iam::123456789:role/SageMakerClarifyRole',
    instance_count=1,
    instance_type='ml.m5.xlarge',
    sagemaker_session=sagemaker.Session()
)

processor.run_bias(
    data_config=data_config,
    bias_config=bias_config,
    model_config=model_config
)
```

### 2. EXPLAINABILITY - Understand Why AI Decided

#### SHAP (SHapley Additive exPlanations)
```python
import shap
import pandas as pd

def explain_risk_score(model, supplier_data, feature_names):
    # Create explainer
    explainer = shap.TreeExplainer(model)  # for tree models
    # or: shap.KernelExplainer for model-agnostic
    
    # Calculate SHAP values
    shap_values = explainer.shap_values(supplier_data)
    
    # Create explanation
    explanation = pd.DataFrame({
        'feature': feature_names,
        'value': supplier_data.values[0],
        'shap_value': shap_values[0],
        'impact': ['increases risk' if v > 0 else 'decreases risk'
                   for v in shap_values[0]]
    }).sort_values('shap_value', key=abs, ascending=False)
    
    return explanation

# Example output for customer:
def generate_risk_explanation(supplier_id, risk_score):
    return {
        'supplier_id': supplier_id,
        'risk_score': risk_score,
        'explanation': [
            {
                'factor': 'Country Risk Index',
                'value': 8.5,
                'impact': '+23 points to risk score',
                'description': 'Operating in high-risk geopolitical region'
            },
            {
                'factor': 'Financial Stability Score',
                'value': 3.2,
                'impact': '+15 points to risk score',
                'description': 'Below-average financial stability indicators'
            },
            {
                'factor': 'Years in Operation',
                'value': 12,
                'impact': '-8 points from risk score',
                'description': 'Established company with track record'
            }
        ],
        'human_review_recommended': risk_score > 80
    }
```

#### Model Cards
```python
# Generate model card (standardized documentation)
model_card = {
    'model_details': {
        'name': 'Interos Supply Chain Risk Scorer v2.0',
        'type': 'Gradient Boosted Tree (XGBoost)',
        'description': 'Predicts supplier financial and operational risk (0-100)',
        'developed_by': 'Interos ML Team',
        'release_date': '2024-01-15',
        'version': '2.0'
    },
    'intended_use': {
        'primary_use': 'Enterprise supply chain risk management',
        'out_of_scope': [
            'Individual consumer scoring',
            'Employment decisions',
            'Credit scoring'
        ]
    },
    'training_data': {
        'description': 'Global supplier financial data, news, regulatory filings',
        'size': '2.3 million supplier records',
        'date_range': '2015-2024',
        'geographic_coverage': '180+ countries'
    },
    'evaluation_metrics': {
        'accuracy': 0.87,
        'precision': 0.84,
        'recall': 0.89,
        'fairness': {
            'demographic_parity_ratio': 0.91,
            'worst_performing_region': 'Central Asia (0.85 parity ratio)'
        }
    },
    'limitations': [
        'Lower accuracy for very small suppliers (< 10 employees)',
        'May not capture rapidly emerging risks (data lag ~2 weeks)',
        'Geographic coverage uneven - better data in OECD countries'
    ],
    'ethical_considerations': [
        'Scores should supplement, not replace, human judgment',
        'Regularly audited for demographic bias',
        'Customers can request explanation of specific scores'
    ]
}
```

### 3. PRIVACY-PRESERVING ML

#### Differential Privacy with Opacus
```python
from opacus import PrivacyEngine
from opacus.validators import ModuleValidator
import torch

# Initialize model
model = SupplyChainRiskModel()
optimizer = torch.optim.Adam(model.parameters(), lr=0.001)

# Make model DP-compatible
model = ModuleValidator.fix(model)
ModuleValidator.validate(model, strict=False)

# Attach privacy engine
privacy_engine = PrivacyEngine()
model, optimizer, train_loader = privacy_engine.make_private_with_epsilon(
    module=model,
    optimizer=optimizer,
    data_loader=train_loader,
    epochs=50,
    target_epsilon=3.0,  # Privacy budget (lower = more private)
    target_delta=1e-5,
    max_grad_norm=1.0
)

# Training loop (same as normal)
for epoch in range(50):
    for batch in train_loader:
        optimizer.zero_grad()
        output = model(batch['features'])
        loss = criterion(output, batch['labels'])
        loss.backward()
        optimizer.step()

print(f'Epsilon used: {privacy_engine.get_epsilon(delta=1e-5)}')
```

#### Federated Learning for Sensitive Data
```python
# Concept: Train model on distributed data without centralizing it
# Each partner trains locally, only gradients shared (not data)

class FederatedLearningOrchestrator:
    def __init__(self, global_model, num_rounds=100):
        self.global_model = global_model
        self.num_rounds = num_rounds
    
    def federated_average(self, client_weights):
        # Aggregate model updates from all clients
        averaged_weights = {}
        for key in client_weights[0].keys():
            layer_weights = torch.stack([w[key] for w in client_weights])
            averaged_weights[key] = layer_weights.mean(dim=0)
        return averaged_weights
    
    def train_round(self, client_datasets):
        client_weights = []
        for dataset in client_datasets:
            local_model = copy.deepcopy(self.global_model)
            local_weights = self.train_locally(local_model, dataset)
            client_weights.append(local_weights)
        
        # Average weights without seeing raw data
        new_weights = self.federated_average(client_weights)
        self.global_model.load_state_dict(new_weights)
```

## Pidgin Summary
Responsible AI be like company wey get good character:
- Fairness: no be because you be small country make your score go high
- Explainability: if your score high, we go tell you why
- Privacy: we dey learn from your data but we no dey expose individual records
This be what government and customer expect from trustworthy AI company
