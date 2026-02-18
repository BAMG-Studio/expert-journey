# Python Testing Commands

## Running Tests
```bash
# Run all tests
cd "Project 1-Enterprise SIEM pipeline"
python3 -m pytest tests/ -v

# Run specific test file
python3 -m pytest tests/test_normalizers.py -v

# Run with coverage
python3 -m pytest tests/ --cov=lambda/normalizers --cov-report=html

# Run unit tests directly
python3 -m unittest tests.test_normalizers -v
```

## Linting
```bash
# Check code style
flake8 lambda/ --max-line-length=120

# Auto-format code
black lambda/

# Type checking
mypy lambda/normalizers/
```

## Lambda Testing
```bash
# Test Lambda locally with event
python3 -c "
import json, sys
sys.path.insert(0, 'lambda/normalizers')
from guardduty_normalizer import lambda_handler
with open('tests/fixtures/guardduty-event.json') as f:
    event = json.load(f)
result = lambda_handler(event, None)
print(json.dumps(result, indent=2))
"
```
