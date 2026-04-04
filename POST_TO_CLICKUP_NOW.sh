#!/bin/bash
# Quick script to post the implementation update to ClickUp
# This should be run by someone with access to the CLICKUP_API_KEY

set -e

TASK_ID="86d2hj96n"
COMMENT_FILE="CLICKUP_COMMENT_READY_TO_POST.md"

echo "=========================================="
echo "Post Implementation Update to ClickUp"
echo "=========================================="
echo ""

# Check if CLICKUP_API_KEY is set
if [ -z "$CLICKUP_API_KEY" ]; then
    echo "❌ ERROR: CLICKUP_API_KEY not set"
    echo ""
    echo "Please set your ClickUp API key:"
    echo ""
    echo "  export CLICKUP_API_KEY='your_api_key_here'"
    echo ""
    echo "Get your API key from: https://app.clickup.com/settings/apps"
    echo ""
    echo "Then run this script again:"
    echo "  ./POST_TO_CLICKUP_NOW.sh"
    echo ""
    exit 1
fi

# Check if comment file exists
if [ ! -f "$COMMENT_FILE" ]; then
    echo "❌ ERROR: $COMMENT_FILE not found"
    exit 1
fi

echo "✓ ClickUp API key found"
echo "✓ Comment file found: $COMMENT_FILE"
echo ""

# Read the comment content
COMMENT_TEXT=$(cat "$COMMENT_FILE")

# Create JSON payload
PAYLOAD=$(jq -n --arg text "$COMMENT_TEXT" '{
  comment_text: $text,
  notify_all: false
}')

echo "📤 Posting to ClickUp task $TASK_ID..."
echo ""

# Post to ClickUp
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "https://api.clickup.com/api/v2/task/${TASK_ID}/comment" \
  -H "Authorization: ${CLICKUP_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

# Extract HTTP code
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ SUCCESS! Implementation update posted to ClickUp"
    echo ""
    echo "View the comment at:"
    echo "https://app.clickup.com/t/${TASK_ID}"
    echo ""
    
    # Extract comment ID
    COMMENT_ID=$(echo "$BODY" | jq -r '.id // empty' 2>/dev/null)
    if [ -n "$COMMENT_ID" ]; then
        echo "Comment ID: $COMMENT_ID"
    fi
    
    echo ""
    echo "=========================================="
    echo "✅ TASK COMPLETE"
    echo "=========================================="
    echo ""
    echo "The ClickUp task has been updated with:"
    echo "  - Complete implementation summary"
    echo "  - All deliverables listed"
    echo "  - Validation results"
    echo "  - Next steps for Darsh"
    echo "  - Links to PR and documentation"
    echo ""
else
    echo "❌ FAILED to post comment (HTTP $HTTP_CODE)"
    echo ""
    echo "Response:"
    echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
    echo ""
    
    if [ "$HTTP_CODE" = "401" ]; then
        echo "💡 TIP: Your API key may be invalid or expired"
        echo "   Get a new one: https://app.clickup.com/settings/apps"
    elif [ "$HTTP_CODE" = "404" ]; then
        echo "💡 TIP: Task ID may be incorrect: $TASK_ID"
        echo "   Verify: https://app.clickup.com/t/${TASK_ID}"
    fi
    
    exit 1
fi
