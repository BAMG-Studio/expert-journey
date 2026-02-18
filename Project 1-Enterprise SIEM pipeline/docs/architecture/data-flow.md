# Data Flow Documentation

## Event Lifecycle

### 1. Event Generation
AWS services generate security events automatically:
- CloudTrail: API call events (~100-1000/minute typical)
- GuardDuty: Threat findings (~10-50/day)
- Security Hub: Aggregated findings (varies)

### 2. Event Routing (EventBridge)
EventBridge uses pattern matching to route events:
```json
{
  "source": ["aws.guardduty"],
  "detail-type": ["GuardDuty Finding"]
}
```

### 3. Normalization (Lambda)
Each normalizer transforms source-specific format to common schema:
- Input: Raw AWS event JSON
- Output: NIST AU-3 compliant normalized event
- Fields: timestamp, source, severity, event_type, details

### 4. Delivery (Kinesis Firehose)
- Buffer: 5MB or 60 seconds (whichever first)
- Delivery: Batch PUT to OpenSearch
- Failed records: Backed up to S3

### 5. Storage & Search (OpenSearch)
- Index pattern: `security-events-YYYY.MM.DD`
- Daily rotation for performance
- Searchable within seconds of delivery

### 6. Archive (S3)
- All events archived in S3
- Lifecycle: Standard -> Intelligent-Tiering (30d) -> Glacier (90d)
- Retention: Configurable (default 90 days)
