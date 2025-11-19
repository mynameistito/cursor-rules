# Smart Issue Creator

**Trigger:** When the user types `/issues` followed by a Markdown table.

## 1. Context & Pre-Flight
1.  **Detect Target Repo:**
    *   Run: `git remote get-url upstream` (Priority) OR `git remote get-url origin`.
    *   Extract: `OWNER` and `REPO_NAME`.
    *   Construct ID: `REPO_ID="$OWNER/$REPO_NAME"`.
2.  **User Identity:** Use `@me` (CLI magic var).
3.  **Label Strategy:** Match `refactor`, `enhancement`, `bug`, `documentation`. Default: `enhancement`.

## 2. Input Parsing
Parse the Markdown table strictly: `| Cohort Name | Summary |`
*   **Row Handling:** Each row = 1 Issue.
*   **Title:** Col 1.
*   **Body:** Col 2 + File list.

## 3. Execution Loop (Fail-Safe CLI)
*Action: Create a secure temporary file to store results.*

```bash
LOG_FILE=$(mktemp)
```

### Strategy A: GitHub CLI (Targeting Org/Repo Explicitly)
For each row in the table, execute:

```bash
# 1. Create issue on the specific ORG/REPO
url=$(gh issue create --repo "$REPO_ID" --title "TITLE" --body "BODY" --label "LABEL" --assignee "@me")

# 2. Parse the Issue Number
num=${url##*/}

# 3. Log format: - [#12](link): Description
echo "- [#$num]($url): TITLE" >> "$LOG_FILE"

# 4. Safety Brake: Prevent API Rate Limiting
sleep 1
```

### Strategy B: GitHub MCP (Fallback)
Call `github_create_issue` manually if CLI fails.

## 4. Issue Content Template
```markdown
### Change Summary
[Summary Text]

### Files Affected
[List of files]

### Verification
- [ ] Verify functionality locally
```

## 5. Post-Processing & Output

### Phase A: PR Enrichment (Idempotent Update)
**Condition:** Check `git branch --show-current`. If PR exists:

```bash
# 1. Get current body
current_body=$(gh pr view --repo "$REPO_ID" --json body -q .body)
new_links=$(cat "$LOG_FILE")

# 2. Smart Append Logic
# Checks if the "Connected Issues" section already exists to avoid duplicate headers
if echo "$current_body" | grep -q "### 🔗 Connected Issues"; then
    # Just append links
    final_body="$current_body
$new_links"
else
    # Create Header + Links
    final_body="$current_body

### 🔗 Connected Issues
$new_links"
fi

# 3. Update PR
gh pr edit --repo "$REPO_ID" --body "$final_body"
```

### Phase B: Cleanup & Display (Mandatory)
Always run this, regardless of PR status.

```bash
# Read content for final summary display
summary_content=$(cat "$LOG_FILE")

# Remove the temp file to keep filesystem clean
rm "$LOG_FILE"
```

### Phase C: Final Output Block
> ## 🚀 Issues Created
> **Target Repo:** `OWNER/REPO`
>
> ### Summary
> (Display the content of `$summary_content`)
>
> *PR Description updated automatically?* (Yes/No)
```