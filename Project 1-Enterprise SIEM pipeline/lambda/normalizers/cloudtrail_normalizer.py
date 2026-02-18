"""CloudTrail Event Normalizer

Transforms AWS CloudTrail events into the common SIEM schema.
NIST 800-53: AU-2 (Event Logging), AU-3 (Content of Audit Records)
"""
import json
import base64
import logging
import os
from common_schema import SIEMLogSchema, severity_to_score

logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))

def handler(event, context):
    """Lambda handler for Kinesis Firehose transformation."""
    output = []
    
    for record in event.get("records", []):
        try:
            # Decode base64 payload from Firehose
            payload = base64.b64decode(record["data"]).decode("utf-8")
            cloudtrail_event = json.loads(payload)
            
            # Transform to common schema
            normalized = normalize_cloudtrail(cloudtrail_event)
            
            # Encode back for Firehose
            output.append({
                "recordId": record["recordId"],
                "result": "Ok",
                "data": base64.b64encode(normalized.encode("utf-8")).decode("utf-8")
            })
        except Exception as e:
            logger.error(f"Error processing record: {e}")
            output.append({
                "recordId": record["recordId"],
                "result": "ProcessingFailed",
                "data": record["data"]
            })
    
    return {"records": output}

def normalize_cloudtrail(event: dict) -> str:
    """Transform CloudTrail event to common schema."""
    log = SIEMLogSchema()
    
    # Event metadata
    log.timestamp = event.get("eventTime", log.timestamp)
    log.event_type = "cloudtrail"
    log.event_source = event.get("eventSource", "")
    log.event_id = event.get("eventID", "")
    log.event_name = event.get("eventName", "")
    
    # Determine severity based on event type
    log.severity = determine_severity(event)
    log.severity_score = severity_to_score(log.severity)
    
    # Actor information (AU-3)
    user_identity = event.get("userIdentity", {})
    log.actor_type = user_identity.get("type", "")
    log.actor_id = user_identity.get("userName", user_identity.get("principalId", ""))
    log.actor_arn = user_identity.get("arn", "")
    log.source_ip = event.get("sourceIPAddress", "")
    log.user_agent = event.get("userAgent", "")
    
    # Resource information
    log.aws_account_id = event.get("recipientAccountId", "")
    log.aws_region = event.get("awsRegion", "")
    
    # Extract resource from request parameters if available
    request_params = event.get("requestParameters", {})
    if request_params:
        log.resource_id = str(request_params.get("resourceId", request_params.get("bucketName", "")))
    
    # Action outcome
    log.action = log.event_name
    error_code = event.get("errorCode")
    if error_code:
        log.action_outcome = "failure"
        log.error_code = error_code
        log.error_message = event.get("errorMessage", "")
    else:
        log.action_outcome = "success"
    
    # Preserve raw event
    log.raw_event = event
    
    # NIST control mapping
    log.nist_controls = ["AU-2", "AU-3", "AU-12"]
    
    return log.to_json()

def determine_severity(event: dict) -> str:
    """Determine severity based on CloudTrail event characteristics."""
    event_name = event.get("eventName", "").lower()
    error_code = event.get("errorCode", "")
    
    # High severity events
    high_severity = ["deletetrail", "stoptrail", "deletebucket", "putbucketpolicy",
                     "createuser", "deleteuser", "attachuserpolicy", "attachrolepolicy",
                     "putgroupPolicy", "createaccesskey", "deactivatemfadevice"]
    
    if any(h in event_name for h in high_severity):
        return "HIGH"
    
    if error_code:
        if "accessdenied" in error_code.lower() or "unauthorized" in error_code.lower():
            return "WARN"
        return "ERROR"
    
    if "console" in event_name.lower() or "login" in event_name.lower():
        return "INFO"
    
    return "INFO"
