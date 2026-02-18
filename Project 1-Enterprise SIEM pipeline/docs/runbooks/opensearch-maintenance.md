# OpenSearch Maintenance Runbook

## Daily Operations

### Check Cluster Health
```bash
curl -X GET "$OPENSEARCH_ENDPOINT/_cluster/health?pretty"
```

Expected: `"status": "green"`

### Monitor Index Size
```bash
curl -X GET "$OPENSEARCH_ENDPOINT/_cat/indices?v&s=store.size:desc"
```

## Weekly Operations

### Create Manual Snapshot
```bash
curl -X PUT "$OPENSEARCH_ENDPOINT/_snapshot/siem-snapshots/weekly-$(date +%Y%m%d)"   -H "Content-Type: application/json"   -d '{"indices":"security-events-*","ignore_unavailable":true}'
```

### Clean Old Indices
```bash
# Delete indices older than 90 days
curl -X DELETE "$OPENSEARCH_ENDPOINT/security-events-2025.*"
```

## Troubleshooting

### Yellow Cluster Status
1. Check unassigned shards:
   ```bash
   curl -X GET "$OPENSEARCH_ENDPOINT/_cat/shards?v&h=index,shard,prirep,state,unassigned.reason"
   ```
2. Common causes:
   - Single node cluster (no replicas possible)
   - Disk space low
   - Node disconnected

### High Memory Usage
1. Check JVM heap:
   ```bash
   curl -X GET "$OPENSEARCH_ENDPOINT/_nodes/stats/jvm?pretty"
   ```
2. Solutions:
   - Force merge old indices
   - Increase instance size
   - Add more nodes
