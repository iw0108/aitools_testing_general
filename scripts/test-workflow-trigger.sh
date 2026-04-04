#!/bin/bash
# Workflow Test Script
# This script helps test the ClickUp + Cursor integration by simulating conditions

set -o pipefail

echo "🧪 ClickUp + Cursor Workflow Test Helper"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}ℹ${NC} Current branch: $CURRENT_BRANCH"

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo -e "${YELLOW}⚠${NC} You have uncommitted changes"
    echo ""
    echo "Uncommitted files:"
    git status --short
    echo ""
    read -p "Do you want to commit these changes? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        read -p "Enter commit message: " COMMIT_MSG
        git add .
        git commit -m "$COMMIT_MSG"
        echo -e "${GREEN}✓${NC} Changes committed"
    fi
fi

# Check if branch is pushed
if ! git ls-remote --exit-code --heads origin "$CURRENT_BRANCH" > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠${NC} Branch not pushed to remote"
    read -p "Do you want to push the branch? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push -u origin "$CURRENT_BRANCH"
        echo -e "${GREEN}✓${NC} Branch pushed"
    fi
else
    echo -e "${GREEN}✓${NC} Branch exists on remote"
    
    # Check if local is behind remote
    git fetch origin "$CURRENT_BRANCH" 2>/dev/null
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    
    if [ "$LOCAL" != "$REMOTE" ]; then
        echo -e "${YELLOW}⚠${NC} Local branch differs from remote"
        read -p "Do you want to push your changes? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push origin "$CURRENT_BRANCH"
            echo -e "${GREEN}✓${NC} Changes pushed"
        fi
    else
        echo -e "${GREEN}✓${NC} Local branch is up to date with remote"
    fi
fi

echo ""
echo "📋 Testing Checklist"
echo "===================="
echo ""

# Check for PR
echo "1. Pull Request Status"
echo "----------------------"
PR_URL=$(gh pr view --json url -q .url 2>/dev/null || echo "")
if [ -n "$PR_URL" ]; then
    echo -e "${GREEN}✓${NC} Pull request exists: $PR_URL"
    
    # Get PR number
    PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null)
    echo -e "${BLUE}ℹ${NC} PR #$PR_NUMBER"
    
    # Check PR state
    PR_STATE=$(gh pr view --json state -q .state 2>/dev/null)
    echo -e "${BLUE}ℹ${NC} State: $PR_STATE"
else
    echo -e "${YELLOW}⚠${NC} No pull request found for this branch"
    echo ""
    read -p "Do you want to create a pull request? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        read -p "Enter PR title: " PR_TITLE
        read -p "Enter PR body (optional): " PR_BODY
        
        if [ -z "$PR_BODY" ]; then
            gh pr create --title "$PR_TITLE" --draft
        else
            gh pr create --title "$PR_TITLE" --body "$PR_BODY" --draft
        fi
        
        PR_URL=$(gh pr view --json url -q .url 2>/dev/null)
        echo -e "${GREEN}✓${NC} Pull request created: $PR_URL"
    fi
fi

echo ""
echo "2. Workflow Triggers"
echo "--------------------"
echo "The workflow will trigger when:"
echo "  • CodeRabbit posts a review comment on the PR"
echo "  • CodeRabbit submits a review on the PR"
echo ""

if [ -n "$PR_URL" ]; then
    echo "To test the integration:"
    echo "  1. Wait for CodeRabbit to review your PR automatically"
    echo "  2. Or make a code change and push to trigger a new review"
    echo "  3. Check GitHub Actions for workflow runs:"
    echo "     https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/.*github.com[:/]\(.*\)/\1/')/actions"
    echo ""
    
    # Check recent workflow runs
    echo "3. Recent Workflow Runs"
    echo "-----------------------"
    RUNS=$(gh run list --workflow=coderabbit-auto-fix.yml --limit 5 2>/dev/null || echo "")
    if [ -n "$RUNS" ]; then
        echo "$RUNS"
    else
        echo "No recent workflow runs found (or gh CLI not available)"
    fi
fi

echo ""
echo "4. ClickUp Integration"
echo "----------------------"
if [ -f "process.md" ]; then
    TASK_URL=$(grep "^clickup_task:" process.md | sed 's/^clickup_task:[[:space:]]*//' | tr -d '\r\n')
    if [ -n "$TASK_URL" ]; then
        echo -e "${GREEN}✓${NC} ClickUp task configured: $TASK_URL"
        echo ""
        echo "When the workflow runs successfully:"
        echo "  • Check the ClickUp task for automated comments"
        echo "  • Comments will include CodeRabbit review summaries"
        echo "  • Open task: $TASK_URL"
    else
        echo -e "${YELLOW}⚠${NC} ClickUp task not configured in process.md"
    fi
else
    echo -e "${YELLOW}⚠${NC} process.md not found"
fi

echo ""
echo "5. Manual Testing Steps"
echo "-----------------------"
echo "To manually trigger a workflow run:"
echo "  1. Make a small code change (e.g., add a comment)"
echo "  2. Commit and push the change"
echo "  3. Wait for CodeRabbit to review the PR"
echo "  4. Check GitHub Actions for the workflow run"
echo "  5. Verify the ClickUp task receives a comment"

echo ""
echo "========================================="
echo "✅ Test preparation complete!"
echo ""
