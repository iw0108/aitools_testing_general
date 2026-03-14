# CodeRabbit Auto-Fix – What You Need to Update

## 1. Repository structure (done)

- Workflow file is in place: **`.github/workflows/coderabbit-auto-fix.yml`**

## 2. Dynamic all branches (done)

- The workflow uses **no branch filter** under `on.pull_request_review_comment`.
- So it runs for **every new review comment on any PR, from any branch** (e.g. `main`, `develop`, `feature/*`, `ai/*`).
- There are **no fixed branches** like `branches: [main, develop]` – all branches are dynamic.

If you ever want to limit which branches can *target* PRs (e.g. only PRs into `main` or `develop`), you could add:

```yaml
on:
  pull_request_review_comment:
    types: [created]
    branches: ['**']   # or e.g. ['main', 'develop'] to restrict target branch
```

Leaving `branches` out (as now) means “all branches”.

## 3. Add Codegen API key in GitHub

1. In your repo: **Settings → Secrets and variables → Actions**.
2. **Add new secret**: name exactly **`CODEGEN_API_KEY`**.
3. Value: your Codegen API key.
4. The workflow uses it as: `${{ secrets.CODEGEN_API_KEY }}`.

## 4. Branch structure (recommended)

- **main** – production.
- **develop** – integration.
- **feature/*** – e.g. `feature/student-api`, `feature/new-login`.
- **ai/*** – e.g. `ai/add-student-page`, `ai/cart-discount`.

Codegen/AI-created branches should follow **`ai/<task-name>`**. The workflow does not depend on branch names; it runs on any branch that has a PR with a new review comment.

## 5. Optional: apply fixes from Codegen

The workflow today:

1. Detects a comment from **coderabbitai**.
2. Checks out the PR branch.
3. Sends the comment to **Codegen** (`POST https://api.codegen.ai/fix`).
4. Commits and pushes any **local** changes.

If Codegen returns the fix in the response (e.g. patch or file contents), you may need an **extra step** between “Send suggestion to Codegen AI” and “Commit fixes” that:

- Reads the API response.
- Writes or applies the fix in the repo (e.g. apply a patch or overwrite files).

Then the existing “Commit fixes” step will pick up those changes. If Codegen applies changes in another way (e.g. webhook that pushes to the repo), this step might not be needed.

## 6. Permissions

- The workflow has **`permissions: contents: write`** so it can push to the PR branch.
- It uses **`GITHUB_TOKEN`** for checkout and push; no extra token is required unless your repo rules need it.

---

**Summary:** Ensure **`CODEGEN_API_KEY`** is set in repo Actions secrets; the rest of the flow is set up for **dynamic all branches** with no fixed branch list.
