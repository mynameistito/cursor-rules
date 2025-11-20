# Smart Issue Creator

**Trigger:** When the user types `/issues` followed by a Markdown table.

## 1. Context & Pre-Flight
1.  **Detect Target Repo:**
    *   Run: `REPO_ID=$(gh repo view --json nameWithOwner -q .nameWithOwner || git remote get-url upstream | sed 's/.*github.com[\/:]\(.*\).git/\1/')`
    *   *Fallback:* If `upstream` fails, use `origin`.
2.  **User Identity:**
    *   Use: `@me` (Native `gh` CLI support).
3.  **Label Strategy:**
    *   Map column keywords to labels: `refactor`, `enhancement`, `bug`, `documentation`.
    *   Default Label: `enhancement`.

## 2. Input Parsing
Parse the Markdown table strictly: `| Cohort Name | Summary |`
*   **Row Handling:** Iterate through rows. Map data to variables: `ISSUE_TITLE`, `ISSUE_BODY`, `ISSUE_LABELS`.
*   **Content Generation:**
    *   `ISSUE_TITLE` = Column 1.
    *   `ISSUE_BODY` = Column 2 + template below.

## 3. Execution Loop (Fail-Safe CLI)
*Action: Create secure temporary files to store results using standard shell commands.*

```bash
# Create clean temp files for logging
LOG_FILE=$(mktemp)   # For PR Body (Markdown links)
FIXES_FILE=$(mktemp) # For Commit Footer (Fixes: URL)
```

### Strategy: GitHub CLI Loop
For each row parsed, execute the following sequence in your shell:

```bash
# 1. Define Variables (Agent populates these per row)
CURRENT_TITLE="[Parsed Title]"
CURRENT_BODY="[Parsed Body]"
CURRENT_LABEL="[Parsed Label]"

# 2. Create issue using GH CLI
# --assignee "@me" assigns it to the authenticated user
# Capture the URL output
ISSUE_URL=$(gh issue create --repo "$REPO_ID" --title "$CURRENT_TITLE" --body "$CURRENT_BODY" --label "$CURRENT_LABEL" --assignee "@me")

# 3. Parse the Issue Number from the URL
ISSUE_NUM="${ISSUE_URL##*/}"

# 4. Log for PR Description: - [#12](link): Description
echo "- [#$ISSUE_NUM]($ISSUE_URL): $CURRENT_TITLE" >> "$LOG_FILE"

# 5. Log for Commit Footer: Fixes: URL
echo "Fixes: $ISSUE_URL" >> "$FIXES_FILE"

# 6. Safety Brake: Prevent API Rate Limiting
sleep 1
```

## 4. Issue Content Template
Appended to `ISSUE_BODY` variable before creation:

```markdown
### Change Summary
[Column 2 Text]

### Files Affected
$(git diff --name-only --cached)

### Verification
- [ ] Verify functionality locally
```

## 5. Post-Processing & Output

### Phase A: PR Enrichment (Idempotent Update)
**Condition:** Check if a PR exists for the current branch.

```bash
# 1. Check for existing PR on current branch
PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null)

if [ -n "$PR_NUMBER" ]; then
    # 2. Get current body
    CURRENT_PR_BODY=$(gh pr view "$PR_NUMBER" --json body -q .body)
    NEW_LINKS=$(cat "$LOG_FILE")

    # 3. Smart Append Logic
    if echo "$CURRENT_PR_BODY" | grep -q "### 🔗 Connected Issues"; then
        FINAL_BODY="$CURRENT_PR_BODY
$NEW_LINKS"
    else
        FINAL_BODY="$CURRENT_PR_BODY

### 🔗 Connected Issues
$NEW_LINKS"
    fi

    # 4. Update PR
    gh pr edit "$PR_NUMBER" --body "$FINAL_BODY"
    PR_UPDATED="Yes"
else
    PR_UPDATED="No (No active PR found)"
fi
```

### Phase B: Cleanup & Display
Always run this to finalize the output.

```bash
# Read content for final summary display
SUMMARY_CONTENT=$(cat "$LOG_FILE")
FIXES_CONTENT=$(cat "$FIXES_FILE")

# Remove the temp files
rm "$LOG_FILE" "$FIXES_FILE"
```

### Phase C: Final Output Block
> ## 🚀 Issues Created
> **Target Repo:** `$REPO_ID`
>
> ### Summary
> `$SUMMARY_CONTENT`
>
> *PR Description updated automatically?* `$PR_UPDATED`
>
> ### 📋 Commit Footer / Fixes
> ```text
> $FIXES_CONTENT
> ```
