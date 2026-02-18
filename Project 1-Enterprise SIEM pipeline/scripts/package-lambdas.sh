#!/bin/bash
# =============================================================================
# PACKAGE LAMBDA FUNCTIONS
# =============================================================================
set -euo pipefail

BUILD_DIR="terraform/modules/lambda-normalizers/builds"
mkdir -p $BUILD_DIR

echo "=== Packaging Lambda Functions ==="

cd lambda/normalizers

for normalizer in guardduty cloudtrail securityhub vpc_flowlog macie; do
    file="${normalizer}_normalizer.py"
    if [ -f "$file" ]; then
        zip -j "../../${BUILD_DIR}/${normalizer}_normalizer.zip" "$file" common_schema.py
        echo "OK: ${normalizer}_normalizer.zip"
    fi
done

cd ../..

# Package enrichment functions
cd lambda/enrichment
for enricher in context_enricher; do
    file="${enricher}.py"
    if [ -f "$file" ]; then
        zip -j "../../${BUILD_DIR}/${enricher}.zip" "$file"
        echo "OK: ${enricher}.zip"
    fi
done

cd ../..
echo "=== Lambda Packaging Complete ==="
ls -la $BUILD_DIR/
