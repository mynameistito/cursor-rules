# Smart Commit & PR Workflow

**Trigger:** When the user types `/commit [message] [flags]`.

## 1. Context & Pre-Flight
1.  **Parse Input:**
    *   **Message:** Text after `/commit`. Default: `"WIP: Biome-clean commit"`.
    *   **Flags:** `--no-pr`, `--dry`, `--amend`, `--cr <URL>` (CodeRabbit/Comment URL).
2.  **Detect Target Repo:**
    *   Command: `git remote get-url upstream || git remote get-url origin`
    *   Extract: `OWNER`, `REPO_NAME`, `REPO_ID`.
3.  **Detect Branch:**
    *   Target: `git remote show origin | grep 'HEAD branch' | cut -d' ' -f5` (Default: `main`).
    *   Current: `git branch --show-current`.

## 2. Phase A: The Biome Gauntlet
1.  **Auto-Fix:** `bunx @biomejs/biome check --write .` (or `npx`).
2.  **Stage:** `git add -A`.
3.  **Empty Guard:** `git diff --staged --quiet` -> Abort if exit code 0.
4.  **Verify:** `bunx @biomejs/biome ci . --max-diagnostics none`.

## 3. Phase B: Git Operations
1.  **Commit:** `git commit -m "MSG"`
2.  **Push:** `git push origin HEAD` (Automatic `-u` fallback).

## 4. Phase C: PR Creation (CodeRabbit Aware)
**Condition:** If Phase A passed & `--no-pr` is missing.

### Step 1: Prepare Body Content
Check if `--cr URL` was provided to fetch a CodeRabbit/Review summary.
```bash
BODY_FILE=$(mktemp)

# Logic: Did user provide a Comment URL?
if [[ "$ARGS" == *"--cr"* ]]; then
  # 1. Extract Comment ID from URL (digits after 'issuecomment-')
  CR_URL=$(echo "$ARGS" | grep -o 'https://[^ ]*')
  COMMENT_ID=$(echo "$CR_URL" | grep -oP 'issuecomment-\K\d+')
  
  # 2. Fetch Comment Body via API
  if [ -n "$COMMENT_ID" ]; then
    echo "⏳ Fetching CodeRabbit summary..."
    gh api "repos/$REPO_ID/issues/comments/$COMMENT_ID" --jq .body > "$BODY_FILE"
    # Append footer link
    echo -e "\n\nGenerated from: $CR_URL" >> "$BODY_FILE"
  else
    echo "⚠️ Invalid CodeRabbit URL. Using default body."
    echo -e "Automated PR.\n- Biome: Passed ✅" > "$BODY_FILE"
  fi
else
  # Default Body
  echo -e "Automated PR.\n- Biome: Passed ✅" > "$BODY_FILE"
fi
```

### Step 2: Check & Create PR
1.  **Check Existing:**
    ```bash
    PR_URL=$(gh pr list --repo "$REPO_ID" --head "$CURRENT_BRANCH" --json url --state open --jq '.[0].url')
    ```
2.  **Create (if empty):**
    ```bash
    if [ -z "$PR_URL" ]; then
      PR_URL=$(gh pr create \
        --repo "$REPO_ID" \
        --base "$TARGET_BRANCH" \
        --title "MSG" \
        --body-file "$BODY_FILE" \
        --draft)
    else
      # Optional: Update existing PR body if --cr provided? 
      # Uncomment below to force update existing PRs with new CR content
      # gh pr edit "$PR_URL" --body-file "$BODY_FILE"
      :
    fi
    ```
3.  **Cleanup:** `rm "$BODY_FILE"`

## 5. Summary Output
**Format:** Clean links for easy merging.

> ## 🚀 Smart Commit
> *   **Repo:** [$REPO_ID](https://github.com/$REPO_ID)
> *   **PR:** [#$PR_NUM]($PR_URL)
> *   **Source:** ${CR_URL:+[CodeRabbit Review]($CR_URL)}
>
> ### 📋 Merge Helper
> *(Copy block below for Merge Commit or PR Comment)*
> ```text
> Fixes: $PR_URL
> Review: $CR_URL
> Repo: https://github.com/$REPO_ID
> ```
```