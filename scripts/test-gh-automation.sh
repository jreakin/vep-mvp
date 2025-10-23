#!/bin/bash

# Test script for GitHub CLI project automation
# Run this locally to test commands before using in workflows

set -e

PROJECT_ID="4"
PROJECT_OWNER="jreakin"
REPO="jreakin/vep-mvp"

echo "🧪 Testing GitHub CLI Project Automation"
echo "========================================"

# Check if gh is installed and authenticated
echo "1. Checking GitHub CLI status..."
gh --version
gh auth status

echo ""
echo "2. Viewing project information..."
gh project view $PROJECT_ID --owner $PROJECT_OWNER

echo ""
echo "3. Listing project fields..."
gh project field-list $PROJECT_ID --owner $PROJECT_OWNER

echo ""
echo "4. Listing current project items..."
gh project item-list $PROJECT_ID --owner $PROJECT_OWNER

echo ""
echo "5. Testing issue addition..."
# Get the first open issue
FIRST_ISSUE=$(gh issue list --repo $REPO --state open --limit 1 --json number | jq -r '.[0].number')
if [ -n "$FIRST_ISSUE" ] && [ "$FIRST_ISSUE" != "null" ]; then
    echo "Adding issue #$FIRST_ISSUE to project..."
    gh project item-add $PROJECT_ID --owner $PROJECT_OWNER --url "https://github.com/$REPO/issues/$FIRST_ISSUE" || echo "Issue may already be in project"
else
    echo "No open issues found to test with"
fi

echo ""
echo "6. Testing status field operations..."
STATUS_FIELD=$(gh project field-list $PROJECT_ID --owner $PROJECT_OWNER --format json | jq -r '.fields[] | select(.name == "Status") | .id')
if [ -n "$STATUS_FIELD" ] && [ "$STATUS_FIELD" != "null" ]; then
    echo "Status field ID: $STATUS_FIELD"
    echo "Status options:"
    gh project field-list $PROJECT_ID --owner $PROJECT_OWNER --format json | jq -r '.fields[] | select(.name == "Status") | .options[] | "  - \(.name) (ID: \(.id))"'
else
    echo "Status field not found"
fi

echo ""
echo "7. Testing project item search..."
if [ -n "$FIRST_ISSUE" ] && [ "$FIRST_ISSUE" != "null" ]; then
    ITEM_ID=$(gh project item-list $PROJECT_ID --owner $PROJECT_OWNER --format json | \
      jq -r --arg repo "$REPO" --arg num "$FIRST_ISSUE" \
      '.items[] | select(.content.repository == $repo and (.content.number == ($num | tonumber))) | .id')
    
    if [ -n "$ITEM_ID" ] && [ "$ITEM_ID" != "null" ]; then
        echo "Found project item for issue #$FIRST_ISSUE: $ITEM_ID"
        echo "Current status:"
        gh project item-list $PROJECT_ID --owner $PROJECT_OWNER --format json | \
          jq -r --arg id "$ITEM_ID" '.items[] | select(.id == $id) | .status'
    else
        echo "Project item not found for issue #$FIRST_ISSUE"
    fi
fi

echo ""
echo "8. Testing workflow dispatch..."
echo "To test the workflows, run:"
echo "  gh workflow run project-automation-gh.yml"
echo "  gh workflow run simple-project-automation.yml"
echo "  gh workflow run gh-project-examples.yml"

echo ""
echo "✅ GitHub CLI project automation test completed!"
echo "Check the output above for any errors or issues."