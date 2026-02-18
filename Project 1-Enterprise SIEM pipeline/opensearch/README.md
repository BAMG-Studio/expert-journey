# OpenSearch Configuration

## Overview
OpenSearch serves as the SIEM search and visualization engine.

## Files
- `index-template.json` - Defines field mappings for security events
- `setup-dashboards.sh` - Initializes OpenSearch indices and policies

## Setup
```bash
# After docker-compose up -d
cd opensearch
./setup-dashboards.sh http://localhost:9200
```

## Accessing Dashboards
- URL: http://localhost:5601
- No auth required for local development

## Index Pattern
All security events are indexed as `security-events-YYYY.MM.DD`

## Key Fields
| Field | Type | Description |
|-------|------|-------------|
| @timestamp | date | Event timestamp |
| event_source | keyword | AWS service source |
| severity | keyword | CRITICAL/HIGH/MEDIUM/LOW |
| source_ip | ip | Source IP address |
| account_id | keyword | AWS account ID |
| action | keyword | API action performed |
