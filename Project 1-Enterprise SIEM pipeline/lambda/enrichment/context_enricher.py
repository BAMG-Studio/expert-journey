"""Context Enricher - Adds metadata to security events - NIST AU-3"""
import json
import boto3
from functools import lru_cache

@lru_cache(maxsize=1000)
def get_account_alias(account_id: str) -> str:
    try:
        org = boto3.client("organizations")
        response = org.describe_account(AccountId=account_id)
        return response.get("Account", {}).get("Name", account_id)
    except:
        return account_id

@lru_cache(maxsize=1000)
def get_resource_tags(resource_arn: str) -> dict:
    try:
        tagging = boto3.client("resourcegroupstaggingapi")
        response = tagging.get_resources(ResourceARNList=[resource_arn])
        tags = response.get("ResourceTagMappingList", [{}])[0].get("Tags", [])
        return {t["Key"]: t["Value"] for t in tags}
    except:
        return {}

def enrich_event(event: dict) -> dict:
    enriched = event.copy()
    if account_id := event.get("aws_account_id"):
        enriched["account_alias"] = get_account_alias(account_id)
    if resource_arn := event.get("resource_arn"):
        enriched["resource_tags"] = get_resource_tags(resource_arn)
    enriched["enriched"] = True
    return enriched
