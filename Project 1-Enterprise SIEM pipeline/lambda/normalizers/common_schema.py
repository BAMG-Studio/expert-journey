"""Common SIEM Log Schema - NIST 800-53 AU-3 Compliant

This module defines the normalized schema for all security logs.
All normalizers transform their source-specific format into this common schema.
"""
import json
from datetime import datetime
from typing import Optional, Dict, Any

class SIEMLogSchema:
    """Common schema for normalized security events."""
    
    def __init__(self):
        self.timestamp: str = datetime.utcnow().isoformat() + "Z"
        self.event_type: str = ""  # cloudtrail, vpcflow, guardduty, macie, securityhub
        self.event_source: str = ""  # aws.cloudtrail, aws.guardduty, etc.
        self.event_id: str = ""
        self.event_name: str = ""
        self.severity: str = "INFO"  # DEBUG, INFO, WARN, ERROR, CRITICAL
        self.severity_score: int = 0  # 0-100
        
        # Actor information (AU-3 requirement)
        self.actor_type: str = ""  # user, service, role
        self.actor_id: str = ""
        self.actor_arn: str = ""
        self.source_ip: str = ""
        self.user_agent: str = ""
        
        # Resource information
        self.resource_type: str = ""
        self.resource_id: str = ""
        self.resource_arn: str = ""
        self.aws_account_id: str = ""
        self.aws_region: str = ""
        
        # Action details
        self.action: str = ""
        self.action_outcome: str = ""  # success, failure, denied
        self.error_code: Optional[str] = None
        self.error_message: Optional[str] = None
        
        # Raw data preservation
        self.raw_event: Dict[str, Any] = {}
        
        # NIST 800-53 metadata
        self.nist_controls: list = []  # e.g., ["AU-2", "AU-3", "IR-5"]
        
    def to_dict(self) -> Dict[str, Any]:
        return {k: v for k, v in self.__dict__.items() if v}
    
    def to_json(self) -> str:
        return json.dumps(self.to_dict())

def severity_to_score(severity: str) -> int:
    mapping = {
        "DEBUG": 10, "INFO": 20, "LOW": 30,
        "MEDIUM": 50, "WARN": 60, "HIGH": 80,
        "CRITICAL": 100, "ERROR": 90
    }
    return mapping.get(severity.upper(), 20)
