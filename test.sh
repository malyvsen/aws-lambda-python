#!/bin/bash
set -euo pipefail

# Get values from Terraform outputs
FUNCTION_NAME=$(terraform -chdir=./infra/lambda output -raw function_name)
REGION=$(terraform -chdir=./infra/lambda output -raw aws_region)

echo "Testing Lambda: $FUNCTION_NAME in $REGION"
echo

# Test case: 2x2 matrix
PAYLOAD='{"matrix": [[4, 7], [2, 6]]}'
echo "Input: $PAYLOAD"

TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

aws lambda invoke \
    --function-name "$FUNCTION_NAME" \
    --region "$REGION" \
    --payload "$PAYLOAD" \
    --cli-binary-format raw-in-base64-out \
    "$TMPFILE" > /dev/null

RESPONSE=$(cat "$TMPFILE")

echo "Response: $RESPONSE"
echo

# Verify the inverse is correct (4*7 - 2*6 = 10, so inverse is [[0.6, -0.7], [-0.2, 0.4]])
EXPECTED_INVERSE='[[0.6,-0.7],[-0.2,0.4]]'
ACTUAL_INVERSE=$(echo "$RESPONSE" | jq -c '.inverse | map(map(. * 10 | round / 10))')

if [ "$ACTUAL_INVERSE" = "$EXPECTED_INVERSE" ]; then
    echo "✅ Test passed!"
else
    echo "❌ Test failed!"
    echo "Expected: $EXPECTED_INVERSE"
    echo "Actual: $ACTUAL_INVERSE"
    exit 1
fi

