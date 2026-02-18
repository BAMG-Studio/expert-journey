"""Macie Finding Normalizer - NIST 800-53 SI-4"""
import json, base64, logging, os
from common_schema import SIEMLogSchema, severity_to_score
logger = logging.getLogger()
logger.setLevel(os.environ.get("LOG_LEVEL", "INFO"))

def handler(event, context):
    output = []
    for record in event.get("records", []):
        try:
            payload = base64.b64decode(record["data"]).decode("utf-8")
            normalized = normalize_macie(json.loads(payload))
            output.append({"recordId": record["recordId"], "result": "Ok", "data": base64.b64encode(normalized.encode()).decode()})
        except Exception as e:
            output.append({"recordId": record["recordId"], "result": "ProcessingFailed", "data": record["data"]})
    return {"records": output}

def normalize_macie(finding: dict) -> str:
    log = SIEMLogSchema()
    detail = finding.get("detail", finding)
    log.event_type = "macie"
    log.event_source = "aws.macie"
    log.event_id = detail.get("id", "")
    log.event_name = detail.get("type", "SensitiveDataFinding")
    log.severity = detail.get("severity", {}).get("description", "MEDIUM").upper()
    log.severity_score = severity_to_score(log.severity)
    log.aws_account_id = detail.get("accountId", "")
    log.aws_region = detail.get("region", "")
    log.action = "sensitive_data_detected"
    log.action_outcome = "detected"
    log.raw_event = finding
    log.nist_controls = ["SI-4", "RA-5"]
    return log.to_json()
