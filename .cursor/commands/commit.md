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
3.  **Detect Default Branch:**
    *   Command: `git remote show origin | grep 'HEAD branch' | cut -d' ' -f5`
    *   Set variable: `TARGET_BRANCH` (Defaults to `main` if command fails).
4.  **Detect Current Branch:**
    *   Command: `git branch --show-current` -> `CURRENT_BRANCH`.

## 2. Phase A: The Biome Gauntlet (Gatekeeper)
**Goal:** Ensure code is clean BEFORE committing.

1.  **Auto-Fix:**
    *   Run: `bunx @biomejs/biome check --write .`
    *   *Fail-Safe:* If command missing, try `npx` or warn user but proceed.
    *   *Action:* Immediately run `git add -A`.

2.  **Empty Commit Guard (Optimization):**
    *   Run: `git diff --staged --quiet`
    *   **IF EXIT CODE 0 (No changes):**
        *   Log: "🛑 No changes detected after formatting."
        *   **ABORT.** (Save the commit).
    *   **IF EXIT CODE 1 (Changes exist):** Proceed.

3.  **Verification (The Gate):**
    *   Run: `bunx @biomejs/biome ci . --max-diagnostics none`
    *   **IF PASS:** Proceed to Phase B.
    *   **IF FAIL:** Enter **Emergency Fix Mode**.

### 🛑 Emergency Fix Mode (If CI Fails)
1.  **Analyze:** Read the error log.
2.  **Attempt Fix:** Manually edit files to resolve errors that `--write` missed.
3.  **Verify Again:** Re-run `biome ci`.
4.  **Decision:**
    *   **Pass:** Proceed to Phase B.
    *   **Fail:** **ABORT COMMAND.** Output: "❌ Biome Check Failed. Manual intervention required."

## 3. Phase B: Git Operations (Atomic)
1.  **Commit:**
    *   Normal: `git commit -m "MSG"`
    *   Amend: `git commit --amend --no-edit`
2.  **Push (Resilient):**
    *   Attempt: `git push origin HEAD`
    *   *Fallback:* If fails (exit code != 0), run: `git push -u origin HEAD`

## 4. Phase C: PR Creation (Prioritise CLI)
**Condition:** Only if Phase A Passed & `--no-pr` is missing.

### Priority 1: GitHub CLI (Org Aware)
1.  **Check Existing PR:**
    ```bash
    gh pr list --repo "$REPO_ID" --head "$CURRENT_BRANCH" --json url --state open
    ```
    *   *If output not empty:* Log "✅ PR exists." -> Stop.

2.  **Create PR:**
    *   Execute (using discovered variables):
    ```bash
    gh pr create \
      --repo "$REPO_ID" \
      --base "$TARGET_BRANCH" \
      --title "MSG" \
      --body "Automated PR.\n- Biome: Passed ✅" \
      --draft \
      --fill
    ```

### Priority 2: MCP Fallback
*Only if `gh` fails.*
1.  **Check:** `github_list_pull_requests` (Filter by `CURRENT_BRANCH`).
2.  **Create:** `github_create_pull_request` (Base: `TARGET_BRANCH`).

## 5. Summary Output
**Success:**
> ## 🚀 Smart Commit
> *   **Repo:** `REPO_ID`
> *   **Status:** ✅ Success
> *   **Biome:** ✅ Auto-fixed & Verified
> *   **Branch:** `CURRENT_BRANCH` -> `TARGET_BRANCH`
> *   **PR:** [Link via `gh pr view --json url`]