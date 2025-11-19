# Smart Commit & PR Workflow

**Trigger:** When the user types `/commit [message] [flags]`.

## 1. Context & Pre-Flight (Fail-Safe Setup)
1.  **Parse Input:**
    *   **Message:** Text after `/commit`. Default: `"WIP: Biome-clean commit"`.
    *   **Flags:** `--no-pr`, `--dry`, `--no-biome`, `--amend`.
2.  **Detect Target Repo (Org Safety):**
    *   Command: `git remote get-url upstream || git remote get-url origin`
    *   Extract: `OWNER` and `REPO_NAME`.
    *   Construct ID: `REPO_ID="$OWNER/$REPO_NAME"`.
    *   Construct URL: `REPO_URL="https://github.com/$REPO_ID"`.
3.  **Detect Default Branch:**
    *   Command: `git remote show origin | grep 'HEAD branch' | cut -d' ' -f5`
    *   Set variable: `TARGET_BRANCH` (Defaults to `main` if command fails).
4.  **Detect Current Branch:**
    *   Command: `git branch --show-current` -> `CURRENT_BRANCH`.
    *   Construct URL: `BRANCH_URL="$REPO_URL/tree/$CURRENT_BRANCH"`.

## 2. Phase A: The Biome Gauntlet (Gatekeeper)
**Goal:** Ensure code is clean BEFORE committing.

1.  **Auto-Fix:**
    *   Run: `bunx @biomejs/biome check --write .` (Fallback to `npx` if needed).
    *   *Action:* Immediately run `git add -A`.

2.  **Empty Commit Guard:**
    *   Run: `git diff --staged --quiet`
    *   **IF EXIT CODE 0 (No changes):** Abort with "🛑 No changes detected."
    *   **IF EXIT CODE 1 (Changes exist):** Proceed.

3.  **Verification:**
    *   Run: `bunx @biomejs/biome ci . --max-diagnostics none`
    *   **IF FAIL:** Stop. "❌ Biome Check Failed."

## 3. Phase B: Git Operations (Atomic)
1.  **Commit:** `git commit -m "MSG"` (or `--amend`).
2.  **Push:** `git push origin HEAD` (Fallback to `git push -u origin HEAD` if new branch).

## 4. Phase C: PR Creation (Prioritise CLI)
**Condition:** Only if Phase A Passed & `--no-pr` is missing.

### Priority 1: GitHub CLI (Org Aware)
1.  **Check Existing PR:**
    ```bash
    gh pr list --repo "$REPO_ID" --head "$CURRENT_BRANCH" --json url --state open --jq '.[0].url'
    ```
    *   *Capture:* Save output to `$PR_URL`.

2.  **Create PR (If Empty):**
    *   If `$PR_URL` is empty, run:
    ```bash
    gh pr create \
      --repo "$REPO_ID" \
      --base "$TARGET_BRANCH" \
      --title "MSG" \
      --body "Automated PR.\n- Biome: Passed ✅" \
      --draft \
      --fill
    ```
    *   *Capture:* The command outputs the new URL. Save to `$PR_URL`.

## 5. Summary Output
**Logic:** Parse the `$PR_URL` to get the number (e.g. `15` from `.../pull/15`) for display.

**Final Output Template:**
> ## 🚀 Smart Commit
> *   **Repo:** [$REPO_ID]($REPO_URL)
> *   **Status:** ✅ Success
> *   **Branch:** [$CURRENT_BRANCH]($BRANCH_URL)
> *   **PR:** [#$PR_NUM]($PR_URL)
>
> ### 📋 Merge Helper
> ```text
> PR: $PR_URL
> Fixes: $PR_URL
> ```