"""GuardDuty Finding Normalizer

Transforms AWS GuardDuty findings into the common SIEM schema.
NIST 800-53: IR-5 (Incident Monitoring), SI-4 (System Monitoring)
"""
import json
import base64
import logging
import os
from common_schema import SIEMLogSchema, severity_to_score

logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))

def handler(event, context):
    """Lambda handler for EventBridge GuardDuty events."""
    output = []
    
    for record in event.get("records", []):
        try:
            payload = base64.b64decode(record["data"]).decode("utf-8")
            finding = json.loads(payload)
            normalized = normalize_guardduty(finding)
            
            output.append({
                "recordId": record["recordId"],
                "result": "Ok",
                "data": base64.b64encode(normalized.encode("utf-8")).decode("utf-8")
            })
        except Exception as e:
            logger.error(f"Error: {e}")
            output.append({"recordId": record["recordId"], "result": "ProcessingFailed", "data": record["data"]})
    
    return {"records": output}

def normalize_guardduty(finding: dict) -> str:
    log = SIEMLogSchema()
    detail = finding.get("detail", finding)
    
    log.timestamp = detail.get("updatedAt", detail.get("createdAt", log.timestamp))
    log.event_type = "guardduty"
    log.event_source = "aws.guardduty"
    log.event_id = detail.get("id", "")
    log.event_name = detail.get("type", "")
    
    # Map GuardDuty severity (1-8) to our scale
    gd_severity = detail.get("severity", 0)
    if gd_severity >= 7: log.severity = "CRITICAL"
    elif gd_severity >= 4: log.severity = "HIGH"
    elif gd_severity >= 2: log.severity = "MEDIUM"
    else: log.severity = "LOW"
    log.severity_score = severity_to_score(log.severity)
    
    # Resource
    resource = detail.get("resource", {})
    log.aws_account_id = detail.get("accountId", "")
    log.aws_region = detail.get("region", "")
    log.resource_type = resource.get("resourceType", "")
    
    # Action
    log.action = detail.get("title", "")
    log.action_outcome = "detected"
    
    log.raw_event = finding
    log.nist_controls = ["IR-5", "SI-4"]
    
    return log.to_json()
