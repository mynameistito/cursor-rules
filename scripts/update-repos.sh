#!/bin/bash

# scripts/update-repos.sh

# Define files
README_FILE="README.md"
WORKFLOW_FILE=".github/workflows/sync-cursor-rules.yml"

# Check if workflow file exists
if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "Workflow file not found!"
    exit 1
fi

# Extract repos from the workflow file
# We look for lines containing "- 'username/repo'" inside the matrix strategy
# This is a simple grep/sed extraction based on the known format
REPOS=$(grep -oP "          - '\K[^']+" "$WORKFLOW_FILE")

# Format the repos into the desired markdown format: [username/repo](link) | ...
# We'll build the string line by line
REPO_LIST=""
for repo in $REPOS; do
    REPO_LIST="$REPO_LIST
- [$repo](https://github.com/$repo)"
done

# Wrap in code block as requested
GENERATED_CONTENT="$REPO_LIST"

# Create a temporary file
TEMP_FILE=$(mktemp)

# Read the README file line by line (same logic as update-structure.sh)
SKIP_MODE=false
while IFS= read -r line; do
    if [[ "$line" == *"<!-- REPOS USING RULES START -->"* ]]; then
        echo "$line" >> "$TEMP_FILE"
        echo "## 📦 Repos Using These Rules" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        echo "$GENERATED_CONTENT" >> "$TEMP_FILE"
        SKIP_MODE=true
    elif [[ "$line" == *"<!-- REPOS USING RULES END -->"* ]]; then
        SKIP_MODE=false
        echo "$line" >> "$TEMP_FILE"
    elif [ "$SKIP_MODE" = true ]; then
        continue
    else
        echo "$line" >> "$TEMP_FILE"
    fi
done < "$README_FILE"

# Move the temp file back to README.md
mv "$TEMP_FILE" "$README_FILE"

echo "README.md repos section updated."
