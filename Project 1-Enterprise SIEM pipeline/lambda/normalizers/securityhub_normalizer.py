"""Security Hub Finding Normalizer - NIST 800-53 SI-4"""
import json, base64, logging, os
from common_schema import SIEMLogSchema, severity_to_score
logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))

def handler(event, context):
    output = []
    for record in event.get("records", []):
        try:
            payload = base64.b64decode(record["data"]).decode("utf-8")
            normalized = normalize_securityhub(json.loads(payload))
            output.append({"recordId": record["recordId"], "result": "Ok", "data": base64.b64encode(normalized.encode()).decode()})
        except Exception as e:
            output.append({"recordId": record["recordId"], "result": "ProcessingFailed", "data": record["data"]})
    return {"records": output}

def normalize_securityhub(finding: dict) -> str:
    log = SIEMLogSchema()
    detail = finding.get("detail", {}).get("findings", [{}])[0] if "detail" in finding else finding
    log.event_type = "securityhub"
    log.event_source = "aws.securityhub"
    log.event_id = detail.get("Id", "")
    log.event_name = detail.get("Title", "")
    severity_label = detail.get("Severity", {}).get("Label", "MEDIUM")
    log.severity = severity_label.upper()
    log.severity_score = severity_to_score(log.severity)
    log.aws_account_id = detail.get("AwsAccountId", "")
    log.aws_region = detail.get("Region", "")
    log.action = detail.get("Types", ["Unknown"])[0] if detail.get("Types") else "Unknown"
    log.action_outcome = "detected"
    log.raw_event = finding
    log.nist_controls = ["SI-4", "CA-7"]
    return log.to_json()
