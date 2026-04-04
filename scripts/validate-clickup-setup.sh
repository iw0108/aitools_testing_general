#!/bin/bash
# ClickUp Integration Validation Script
# This script validates that the ClickUp + Cursor integration is properly configured

set -o pipefail

echo "🔍 ClickUp Integration Validation"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SUCCESS=0
WARNINGS=0
ERRORS=0

# Function to print status
print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "success")
            echo -e "${GREEN}✓${NC} $message"
            ((SUCCESS++))
            ;;
        "warning")
            echo -e "${YELLOW}⚠${NC} $message"
            ((WARNINGS++))
            ;;
        "error")
            echo -e "${RED}✗${NC} $message"
            ((ERRORS++))
            ;;
        "info")
            echo -e "ℹ $message"
            ;;
    esac
}

echo "1. Checking configuration files..."
echo "-----------------------------------"

# Check for process.md or process.md.example
if [ -f "process.md" ]; then
    print_status "success" "process.md exists"
    
    # Validate content
    if grep -q "clickup_task:" process.md; then
        TASK=$(grep "clickup_task:" process.md | sed 's/.*clickup_task:[[:space:]]*//' | tr -d '\r\n')
        print_status "success" "ClickUp task configured: $TASK"
        
        # Extract task ID
        if echo "$TASK" | grep -qE '[a-z0-9]{9,}'; then
            TASK_ID=$(echo "$TASK" | grep -oE '[a-z0-9]{9,}' | head -1)
            print_status "success" "Task ID extracted: $TASK_ID"
        else
            print_status "error" "Could not extract valid task ID from: $TASK"
        fi
    else
        print_status "error" "process.md missing 'clickup_task' field"
    fi
    
    if grep -q "branch:" process.md; then
        BRANCH=$(grep "^branch:" process.md | sed 's/^branch:[[:space:]]*//' | tr -d '\r\n')
        CURRENT_BRANCH=$(git branch --show-current)
        
        if [ "$BRANCH" = "$CURRENT_BRANCH" ]; then
            print_status "success" "Branch matches current: $BRANCH"
        else
            print_status "warning" "Branch mismatch - process.md: '$BRANCH', current: '$CURRENT_BRANCH'"
        fi
    else
        print_status "warning" "process.md missing 'branch' field (optional)"
    fi
    
    if grep -q "base_branch:" process.md; then
        BASE=$(grep "^base_branch:" process.md | sed 's/^base_branch:[[:space:]]*//' | tr -d '\r\n')
        print_status "success" "Base branch configured: $BASE"
    else
        print_status "warning" "process.md missing 'base_branch' field (optional)"
    fi
elif [ -f "process.md.example" ]; then
    print_status "warning" "Only process.md.example exists (process.md preferred)"
else
    print_status "error" "Neither process.md nor process.md.example found"
fi

echo ""
echo "2. Checking workflow file..."
echo "----------------------------"

if [ -f ".github/workflows/coderabbit-auto-fix.yml" ]; then
    print_status "success" "Workflow file exists"
    
    # Check for key components
    if grep -q "pull_request_review_comment" .github/workflows/coderabbit-auto-fix.yml; then
        print_status "success" "Workflow triggers on PR review comments"
    else
        print_status "error" "Workflow missing PR review comment trigger"
    fi
    
    if grep -q "CURSOR_API_KEY" .github/workflows/coderabbit-auto-fix.yml; then
        print_status "success" "Workflow references CURSOR_API_KEY"
    else
        print_status "warning" "Workflow does not reference CURSOR_API_KEY"
    fi
    
    if grep -q "CLICKUP_API_KEY" .github/workflows/coderabbit-auto-fix.yml; then
        print_status "success" "Workflow references CLICKUP_API_KEY"
    else
        print_status "warning" "Workflow does not reference CLICKUP_API_KEY"
    fi
else
    print_status "error" "Workflow file not found: .github/workflows/coderabbit-auto-fix.yml"
fi

echo ""
echo "3. Checking GitHub repository setup..."
echo "---------------------------------------"

# Check if we're in a git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    print_status "success" "Git repository detected"
    
    # Check for remote
    if git remote -v | grep -q "github.com"; then
        REPO_URL=$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/.*github.com[:/]\(.*\)/\1/')
        print_status "success" "GitHub remote configured: $REPO_URL"
    else
        print_status "warning" "No GitHub remote found"
    fi
    
    # Check current branch
    CURRENT_BRANCH=$(git branch --show-current)
    print_status "info" "Current branch: $CURRENT_BRANCH"
else
    print_status "error" "Not in a git repository"
fi

echo ""
echo "4. Checking documentation..."
echo "----------------------------"

if [ -f ".github/CODERABBIT-SETUP.md" ]; then
    print_status "success" "Setup documentation exists"
else
    print_status "warning" "Setup documentation not found"
fi

if [ -f "CLICKUP_INTEGRATION_SUMMARY.md" ]; then
    print_status "success" "Integration summary exists"
else
    print_status "info" "Integration summary not found (optional)"
fi

echo ""
echo "5. GitHub Secrets Check..."
echo "--------------------------"
print_status "info" "GitHub secrets cannot be validated from this script"
print_status "info" "Please verify manually in GitHub Settings → Secrets and variables → Actions"
print_status "info" "Required secrets:"
echo "   - CURSOR_API_KEY (for Cursor AI integration)"
echo "   - CLICKUP_API_KEY (for ClickUp comments)"

echo ""
echo "=================================="
echo "📊 Validation Summary"
echo "=================================="
echo -e "${GREEN}✓ Successes: $SUCCESS${NC}"
echo -e "${YELLOW}⚠ Warnings:  $WARNINGS${NC}"
echo -e "${RED}✗ Errors:    $ERRORS${NC}"
echo ""

if [ $ERRORS -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}✓ All checks passed! Integration is properly configured.${NC}"
        exit 0
    else
        echo -e "${YELLOW}⚠ Configuration complete with warnings. Review warnings above.${NC}"
        exit 0
    fi
else
    echo -e "${RED}✗ Configuration has errors. Please fix the issues above.${NC}"
    exit 1
fi
