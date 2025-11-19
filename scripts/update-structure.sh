#!/bin/bash

# scripts/update-structure.sh

# Ensure tree is installed (in case it's run in an environment without it, though CI should handle this)
if ! command -v tree &> /dev/null; then
    echo "tree could not be found, please install it."
    exit 1
fi

# Define the output file
README_FILE="README.md"

# Generate the tree structure
# -I pattern: Do not list files that match the given pattern.
# --dirsfirst: List directories before files.
# -F: Append a '/' for directories.
# --noreport: Turn off file/directory count at the end of the tree listing.
# -a: All files (including hidden, but we exclude .git)
TREE_OUTPUT=$(tree -a -I '.git|.github|.vscode|.idea|node_modules|dist|build|coverage' --dirsfirst -F --noreport)

# Create a temporary file
TEMP_FILE=$(mktemp)

# Read the README file line by line
while IFS= read -r line; do
    if [[ "$line" == *"<!-- REPOSITORY STRUCTURE START -->"* ]]; then
        echo "$line" >> "$TEMP_FILE"
        echo "## 📁 Repository Structure" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        echo "\`\`\`" >> "$TEMP_FILE"
        echo "$TREE_OUTPUT" >> "$TEMP_FILE"
        echo "\`\`\`" >> "$TEMP_FILE"
        SKIP_MODE=true
    elif [[ "$line" == *"<!-- REPOSITORY STRUCTURE END -->"* ]]; then
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

echo "README.md structure updated."
