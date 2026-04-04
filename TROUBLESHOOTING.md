# ClickUp + Cursor Integration Troubleshooting Guide

This guide helps you diagnose and fix common issues with the ClickUp + Cursor AI integration.

## Table of Contents

1. [Quick Diagnostics](#quick-diagnostics)
2. [Common Issues](#common-issues)
3. [Workflow Not Triggering](#workflow-not-triggering)
4. [ClickUp Comments Not Posting](#clickup-comments-not-posting)
5. [Cursor AI Not Applying Fixes](#cursor-ai-not-applying-fixes)
6. [Configuration Issues](#configuration-issues)
7. [Debugging Steps](#debugging-steps)

---

## Quick Diagnostics

Run the validation script to check your setup:

```bash
./scripts/validate-clickup-setup.sh
```

This will check:
- Configuration files (`process.md`)
- Workflow file existence
- Git repository setup
- Documentation

---

## Common Issues

### Issue 1: Workflow Not Triggering

**Symptoms:**
- CodeRabbit posts reviews but no workflow runs appear in GitHub Actions
- No automated commits or ClickUp comments

**Possible Causes & Solutions:**

#### A. Workflow file missing or misconfigured

**Check:**
```bash
ls -la .github/workflows/coderabbit-auto-fix.yml
```

**Solution:** Ensure the workflow file exists and has correct triggers:
```yaml
on:
  pull_request_review_comment:
    types: [created]
  pull_request_review:
    types: [submitted]
```

#### B. CodeRabbit not installed

**Check:** Visit your repository's GitHub Apps settings

**Solution:** Install CodeRabbit from the GitHub Marketplace:
1. Go to your repository settings
2. Navigate to "Integrations" → "GitHub Apps"
3. Install CodeRabbit if not present

#### C. Workflow permissions insufficient

**Check:** Look at workflow file permissions:
```yaml
permissions:
  contents: write
  pull-requests: write
```

**Solution:** Ensure your repository allows Actions to write:
1. Go to Settings → Actions → General
2. Under "Workflow permissions", select "Read and write permissions"
3. Save changes

---

### Issue 2: ClickUp Comments Not Posting

**Symptoms:**
- Workflow runs successfully
- No comments appear in ClickUp task
- Workflow logs show ClickUp step completed

**Possible Causes & Solutions:**

#### A. CLICKUP_API_KEY not configured

**Check:** Workflow logs for message:
```
CLICKUP_API_KEY not configured, skipping ClickUp step.
```

**Solution:** Add the secret in GitHub:
1. Go to Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `CLICKUP_API_KEY`
4. Value: Your ClickUp API token
5. Get token from: https://app.clickup.com/settings/apps

#### B. Invalid ClickUp task ID

**Check:** Look at `process.md`:
```bash
cat process.md
```

**Solution:** Ensure `clickup_task` is correctly formatted:
```
clickup_task: https://app.clickup.com/t/86d2hj96n
```
Or just the ID:
```
clickup_task: 86d2hj96n
```

#### C. ClickUp API permissions

**Check:** Workflow logs for HTTP 401 or 403 errors

**Solution:** 
1. Regenerate your ClickUp API token
2. Ensure the token has permission to comment on tasks
3. Update the `CLICKUP_API_KEY` secret in GitHub

#### D. Task ID not found in process.md

**Check:** Workflow logs for:
```
No clickup_task found in process.md or process.md.example
```

**Solution:** Create or update `process.md`:
```bash
cat > process.md << EOF
base_branch: main
branch: your-branch-name
clickup_task: https://app.clickup.com/t/YOUR_TASK_ID
EOF
```

---

### Issue 3: Cursor AI Not Applying Fixes

**Symptoms:**
- Workflow runs but no code changes are committed
- Workflow logs show "No code changes detected"

**Possible Causes & Solutions:**

#### A. CURSOR_API_KEY not configured

**Check:** Workflow logs for:
```
CURSOR_API_KEY not configured, skipping Cursor step.
```

**Solution:** Add the secret in GitHub:
1. Go to Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `CURSOR_API_KEY`
4. Value: Your Cursor API token

#### B. Cursor API not returning fixes

**Check:** Workflow logs for Cursor response

**Solution:** 
- Verify your Cursor API key is valid
- Check if the CodeRabbit suggestion is actionable
- Some suggestions may be informational only

#### C. Git configuration issues

**Check:** Workflow logs for git errors

**Solution:** Ensure workflow has correct git config:
```yaml
- name: Commit fixes if AI modified files
  run: |
    git config user.name "ai-bot"
    git config user.email "ai@bot.com"
```

---

### Issue 4: Configuration Issues

#### A. process.md not being read

**Symptoms:**
- Workflow logs show "No clickup_task found"
- File exists but isn't detected

**Check:**
```bash
cat process.md
file process.md
```

**Solution:**
- Ensure file is in repository root
- Check file encoding (should be UTF-8)
- Verify no hidden characters:
```bash
cat -A process.md
```

#### B. Branch mismatch warning

**Symptoms:**
- Workflow logs show branch mismatch warning

**Check:**
```bash
git branch --show-current
grep "^branch:" process.md
```

**Solution:** Update `process.md` to match current branch:
```bash
CURRENT_BRANCH=$(git branch --show-current)
sed -i "s/^branch:.*/branch: $CURRENT_BRANCH/" process.md
```

---

## Debugging Steps

### Step 1: Verify Configuration

Run the validation script:
```bash
./scripts/validate-clickup-setup.sh
```

Fix any errors or warnings reported.

### Step 2: Check GitHub Actions Logs

1. Go to your repository on GitHub
2. Click "Actions" tab
3. Find "CodeRabbit Auto Fix" workflow
4. Click on the most recent run
5. Expand each step to view logs

### Step 3: Verify Secrets

Check that secrets are configured:
```bash
# This will fail but shows if gh CLI is working
gh secret list
```

Manually verify in GitHub:
1. Settings → Secrets and variables → Actions
2. Confirm `CURSOR_API_KEY` exists
3. Confirm `CLICKUP_API_KEY` exists

### Step 4: Test Workflow Manually

Make a small change to trigger CodeRabbit:
```bash
# Add a comment to a file
echo "// Test comment" >> src/App.jsx
git add src/App.jsx
git commit -m "test: trigger CodeRabbit review"
git push
```

### Step 5: Check CodeRabbit Activity

1. Go to your PR on GitHub
2. Look for CodeRabbit review comments
3. Verify CodeRabbit is active on your repository

### Step 6: Verify ClickUp Task Access

Test your ClickUp API key:
```bash
# Replace YOUR_API_KEY and TASK_ID
curl -H "Authorization: YOUR_API_KEY" \
  "https://api.clickup.com/api/v2/task/TASK_ID"
```

Should return task details if working correctly.

---

## Advanced Debugging

### Enable Workflow Debug Logging

1. Go to Settings → Secrets and variables → Actions
2. Add a new secret:
   - Name: `ACTIONS_STEP_DEBUG`
   - Value: `true`
3. Re-run the workflow

### Check Workflow Syntax

Validate the workflow file:
```bash
# Install actionlint if not present
# brew install actionlint  # macOS
# or download from https://github.com/rhysd/actionlint

actionlint .github/workflows/coderabbit-auto-fix.yml
```

### Manual API Testing

Test the Cursor API:
```bash
curl -X POST https://api.codegen.ai/fix \
  -H "Authorization: Bearer YOUR_CURSOR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"comment":"Test suggestion: Add error handling"}'
```

Test the ClickUp API:
```bash
curl -X POST "https://api.clickup.com/api/v2/task/YOUR_TASK_ID/comment" \
  -H "Authorization: YOUR_CLICKUP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"comment_text":"Test comment","notify_all":false}'
```

---

## Getting Help

If you're still experiencing issues:

1. **Check workflow logs** in GitHub Actions for specific error messages
2. **Review this guide** for solutions to common issues
3. **Verify all secrets** are correctly configured
4. **Test APIs manually** to isolate the problem
5. **Check repository permissions** for GitHub Actions

### Useful Commands

```bash
# Validate configuration
./scripts/validate-clickup-setup.sh

# Test workflow trigger conditions
./scripts/test-workflow-trigger.sh

# Check git status
git status

# View recent commits
git log --oneline -5

# Check remote branches
git branch -r

# View workflow file
cat .github/workflows/coderabbit-auto-fix.yml

# Check process.md
cat process.md
```

---

## Checklist for New Setup

Use this checklist when setting up the integration on a new branch:

- [ ] Create `process.md` with correct task ID and branch
- [ ] Verify `CURSOR_API_KEY` secret exists in GitHub
- [ ] Verify `CLICKUP_API_KEY` secret exists in GitHub
- [ ] Ensure CodeRabbit is installed on repository
- [ ] Verify workflow file exists: `.github/workflows/coderabbit-auto-fix.yml`
- [ ] Check workflow permissions: read and write
- [ ] Create or verify pull request exists
- [ ] Push changes to trigger CodeRabbit review
- [ ] Monitor GitHub Actions for workflow run
- [ ] Check ClickUp task for automated comment

---

## Success Indicators

Your integration is working correctly when:

✅ CodeRabbit automatically reviews your PRs
✅ GitHub Actions shows successful "CodeRabbit Auto Fix" runs
✅ Automated commits appear when fixes are applied
✅ ClickUp task receives comment summaries
✅ Validation script passes all checks

---

## Additional Resources

- **Workflow File**: `.github/workflows/coderabbit-auto-fix.yml`
- **Setup Guide**: `.github/CODERABBIT-SETUP.md`
- **Integration Summary**: `CLICKUP_INTEGRATION_SUMMARY.md`
- **Validation Script**: `scripts/validate-clickup-setup.sh`
- **Test Script**: `scripts/test-workflow-trigger.sh`

---

**Last Updated**: April 4, 2026
