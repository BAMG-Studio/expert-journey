"""VPC Flow Log Normalizer - NIST 800-53 SI-4"""
import json, base64, logging, os
from common_schema import SIEMLogSchema, severity_to_score
logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))

def handler(event, context):
    output = []
    for record in event.get("records", []):
        try:
            payload = base64.b64decode(record["data"]).decode("utf-8")
            normalized = normalize_vpcflow(json.loads(payload))
            output.append({"recordId": record["recordId"], "result": "Ok", "data": base64.b64encode(normalized.encode()).decode()})
        except Exception as e:
            logger.error(f"Error: {e}")
            output.append({"recordId": record["recordId"], "result": "ProcessingFailed", "data": record["data"]})
    return {"records": output}

def normalize_vpcflow(event: dict) -> str:
    log = SIEMLogSchema()
    log.event_type = "vpcflow"
    log.event_source = "aws.vpcflowlogs"
    log.source_ip = event.get("srcaddr", "")
    log.action = event.get("action", "")
    log.action_outcome = "accept" if event.get("action") == "ACCEPT" else "reject"
    log.severity = "WARN" if log.action_outcome == "reject" else "INFO"
    log.severity_score = severity_to_score(log.severity)
    log.aws_account_id = event.get("account-id", "")
    log.aws_region = event.get("region", "")
    log.raw_event = event
    log.nist_controls = ["SI-4"]
    return log.to_json()
