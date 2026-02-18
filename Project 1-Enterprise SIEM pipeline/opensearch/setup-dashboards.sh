#!/bin/bash
# =============================================================================
# OPENSEARCH DASHBOARD SETUP
# =============================================================================
set -euo pipefail

OPENSEARCH_URL=${1:-"http://localhost:9200"}

echo "=== Setting up OpenSearch for SIEM ==="

# Create index template
echo "Creating index template..."
curl -s -X PUT "$OPENSEARCH_URL/_index_template/security-events"   -H "Content-Type: application/json"   -d @index-template.json
echo ""

# Create initial index
echo "Creating initial index..."
curl -s -X PUT "$OPENSEARCH_URL/security-events-$(date +%Y.%m.%d)"   -H "Content-Type: application/json"   -d '{"settings":{"number_of_shards":1,"number_of_replicas":0}}'
echo ""

# Create ISM policy for index lifecycle
echo "Creating ISM policy..."
curl -s -X PUT "$OPENSEARCH_URL/_plugins/_ism/policies/siem-lifecycle"   -H "Content-Type: application/json"   -d '{
    "policy": {
      "description": "SIEM index lifecycle policy",
      "default_state": "hot",
      "states": [
        {
          "name": "hot",
          "actions": [],
          "transitions": [{
            "state_name": "warm",
            "conditions": {"min_index_age": "7d"}
          }]
        },
        {
          "name": "warm",
          "actions": [{"replica_count": {"number_of_replicas": 0}}],
          "transitions": [{
            "state_name": "delete",
            "conditions": {"min_index_age": "90d"}
          }]
        },
        {
          "name": "delete",
          "actions": [{"delete": {}}]
        }
      ]
    }
  }'
echo ""

echo "=== OpenSearch Setup Complete ==="
echo "Dashboard: http://localhost:5601"
