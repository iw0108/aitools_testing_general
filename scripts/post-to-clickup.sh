#!/bin/bash
# Post Update to ClickUp Task
# Usage: CLICKUP_API_KEY=your_key ./scripts/post-to-clickup.sh

set -o pipefail

TASK_ID="86d2hj96n"
TASK_URL="https://app.clickup.com/t/${TASK_ID}"

# Check if API key is provided
if [ -z "$CLICKUP_API_KEY" ]; then
    echo "❌ Error: CLICKUP_API_KEY environment variable not set"
    echo ""
    echo "Usage:"
    echo "  CLICKUP_API_KEY=your_key ./scripts/post-to-clickup.sh"
    echo ""
    echo "Or export it first:"
    echo "  export CLICKUP_API_KEY=your_key"
    echo "  ./scripts/post-to-clickup.sh"
    echo ""
    echo "Get your API key from: https://app.clickup.com/settings/apps"
    exit 1
fi

# Read the update content
if [ ! -f "CLICKUP_UPDATE.md" ]; then
    echo "❌ Error: CLICKUP_UPDATE.md not found"
    exit 1
fi

UPDATE_CONTENT=$(cat CLICKUP_UPDATE.md)

# Create comment text
COMMENT_TEXT="## 🤖 Cursor Cloud Agent Update

$UPDATE_CONTENT

---
**Posted by**: Cursor Cloud Agent
**Branch**: CU-86d2hj96n_Clickup-with-cursor_Darsh-Lakhani-iw0227
**PR**: https://github.com/iw0227/aitools_testing_general/pull/33"

# Create JSON payload
PAYLOAD=$(jq -n --arg text "$COMMENT_TEXT" '{
  comment_text: $text,
  notify_all: false
}')

echo "📤 Posting update to ClickUp task $TASK_ID..."
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

echo "Response Code: $HTTP_CODE"
echo ""

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Success! Comment posted to ClickUp task"
    echo "View at: $TASK_URL"
    
    # Extract comment ID if available
    COMMENT_ID=$(echo "$BODY" | jq -r '.id // empty' 2>/dev/null)
    if [ -n "$COMMENT_ID" ]; then
        echo "Comment ID: $COMMENT_ID"
    fi
else
    echo "❌ Failed to post comment"
    echo ""
    echo "Response:"
    echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
    
    if [ "$HTTP_CODE" = "401" ]; then
        echo ""
        echo "💡 Tip: Check that your CLICKUP_API_KEY is valid"
        echo "Get a new key from: https://app.clickup.com/settings/apps"
    elif [ "$HTTP_CODE" = "404" ]; then
        echo ""
        echo "💡 Tip: Verify the task ID is correct: $TASK_ID"
    fi
    
    exit 1
fi
