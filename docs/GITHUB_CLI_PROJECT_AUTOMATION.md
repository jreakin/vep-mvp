# GitHub CLI Project Automation Guide

This guide shows how to use the GitHub CLI (`gh`) in GitHub Actions workflows to automate project management for the VEP MVP repository.

## Overview

The GitHub CLI provides a powerful and simple way to manage GitHub projects programmatically. Unlike the GitHub API, `gh` CLI offers:

- **Simpler syntax** - No complex GraphQL queries
- **Better error handling** - Built-in retry logic and user-friendly error messages
- **Consistent interface** - Same commands you use locally
- **Rich formatting** - Built-in JSON, table, and other output formats

## Prerequisites

1. **GitHub CLI installed** in your workflow
2. **Proper permissions** - `projects: write`, `issues: write`, `pull-requests: write`
3. **Authentication** - Using `GITHUB_TOKEN` or personal access token

## Basic Setup

```yaml
- name: Setup GitHub CLI
  uses: actions/setup-gh@v1
  with:
    version: latest

- name: Authenticate
  run: echo "${{ secrets.GITHUB_TOKEN }}" | gh auth login --with-token
```

## Core Project Management Commands

### 1. View Project Information

```bash
# View project details
gh project view 4 --owner jreakin

# List all projects for an owner
gh project list --owner jreakin

# List project fields
gh project field-list 4 --owner jreakin
```

### 2. Manage Project Items

```bash
# Add an issue to project
gh project item-add 4 --owner jreakin --url https://github.com/jreakin/vep-mvp/issues/14

# Add a pull request to project
gh project item-add 4 --owner jreakin --url https://github.com/jreakin/vep-mvp/pull/15

# List all items in project
gh project item-list 4 --owner jreakin

# Create a new draft issue in project
gh project item-create 4 --owner jreakin --title "New Feature" --body "Description"
```

### 3. Update Item Status

```bash
# Get status field ID
STATUS_FIELD=$(gh project field-list 4 --owner jreakin --format json | jq -r '.[] | select(.name == "Status") | .id')

# Update item status
gh project item-edit "ITEM_ID" --owner jreakin --field-id "$STATUS_FIELD" --single-select-option-id "In Progress"
```

### 4. Archive and Delete Items

```bash
# Archive an item
gh project item-archive "ITEM_ID" --owner jreakin

# Delete an item from project
gh project item-delete "ITEM_ID" --owner jreakin
```

## Workflow Examples

### 1. Automatic Status Updates

```yaml
name: Auto Update Project Status

on:
  issues:
    types: [opened, closed, assigned, labeled]
  pull_request:
    types: [opened, closed, merged]

jobs:
  update-status:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-gh@v1
    - run: echo "${{ secrets.GITHUB_TOKEN }}" | gh auth login --with-token
    - run: |
        # Add item to project
        if [ "${{ github.event_name }}" = "issues" ]; then
          URL="https://github.com/${{ github.repository }}/issues/${{ github.event.issue.number }}"
        else
          URL="https://github.com/${{ github.repository }}/pull/${{ github.event.pull_request.number }}"
        fi
        gh project item-add 4 --owner jreakin --url "$URL" || true
        
        # Update status based on event
        # ... status update logic ...
```

### 2. Bulk Operations

```yaml
name: Bulk Project Operations

on:
  workflow_dispatch:

jobs:
  bulk-ops:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-gh@v1
    - run: echo "${{ secrets.GITHUB_TOKEN }}" | gh auth login --with-token
    - run: |
        # Add all open issues to project
        gh issue list --repo ${{ github.repository }} --state open --json number | \
          jq -r '.[].number' | while read -r issue_num; do
            gh project item-add 4 --owner jreakin \
              --url "https://github.com/${{ github.repository }}/issues/$issue_num" || true
          done
```

### 3. Project Reporting

```yaml
name: Generate Project Report

on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 9 AM

jobs:
  report:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-gh@v1
    - run: echo "${{ secrets.GITHUB_TOKEN }}" | gh auth login --with-token
    - run: |
        echo "# Weekly Project Report" > report.md
        echo "Generated: $(date)" >> report.md
        echo "" >> report.md
        
        # Project overview
        gh project view 4 --owner jreakin >> report.md
        
        # Items by status
        gh project item-list 4 --owner jreakin --format json | \
          jq -r 'group_by(.fieldValues[0].name) | to_entries[] | "### \(.key)\n\(.value | length) items\n"' >> report.md
        
        # Create issue with report
        gh issue create --title "Weekly Report - $(date +%Y-%m-%d)" --body-file report.md
```

## Advanced Patterns

### 1. Finding Project Items

```bash
# Find item by issue/PR number
ITEM_ID=$(gh project item-list 4 --owner jreakin --format json | \
  jq -r --arg repo "jreakin/vep-mvp" --arg num "14" \
  '.[] | select(.content.repository.nameWithOwner == $repo and (.content.number == ($num | tonumber))) | .id')
```

### 2. Status Field Management

```bash
# Get status field with options
gh project field-list 4 --owner jreakin --format json | \
  jq -r '.[] | select(.name == "Status") | .options[] | "\(.id): \(.name)"'

# Update with emoji variations
gh project item-edit "$ITEM_ID" --owner jreakin \
  --field-id "$STATUS_FIELD" --single-select-option-id "🟠 In Progress" || \
gh project item-edit "$ITEM_ID" --owner jreakin \
  --field-id "$STATUS_FIELD" --single-select-option-id "In Progress"
```

### 3. Conditional Logic

```bash
# Update status based on multiple conditions
case "${{ github.event_name }}-${{ github.event.action }}" in
  "issues-assigned"|"issues-labeled")
    NEW_STATUS="In Progress"
    ;;
  "issues-closed")
    NEW_STATUS="Done"
    ;;
  "pull_request-opened")
    NEW_STATUS="Code Review"
    ;;
  "pull_request-closed")
    if [ "${{ github.event.pull_request.merged }}" = "true" ]; then
      NEW_STATUS="Testing"
    else
      NEW_STATUS="Ready"
    fi
    ;;
esac
```

## Error Handling

### 1. Graceful Failures

```bash
# Commands that might fail
gh project item-add 4 --owner jreakin --url "$URL" || echo "Item may already be in project"
```

### 2. Validation

```bash
# Check if item exists before updating
if [ -z "$ITEM_ID" ] || [ "$ITEM_ID" = "null" ]; then
  echo "Item not found in project"
  exit 0
fi
```

### 3. Multiple Attempts

```bash
# Try different status variations
gh project item-edit "$ITEM_ID" --owner jreakin \
  --field-id "$STATUS_FIELD" --single-select-option-id "$NEW_STATUS" || \
gh project item-edit "$ITEM_ID" --owner jreakin \
  --field-id "$STATUS_FIELD" --single-select-option-id "🟠 $NEW_STATUS" || \
gh project item-edit "$ITEM_ID" --owner jreakin \
  --field-id "$STATUS_FIELD" --single-select-option-id "✅ $NEW_STATUS"
```

## Best Practices

1. **Use JSON output** for parsing: `--format json`
2. **Handle missing items gracefully**: Check for null/empty values
3. **Try multiple variations** for status updates (with/without emojis)
4. **Add confirmation comments** to issues/PRs
5. **Use workflow_dispatch** for manual testing
6. **Log everything** for debugging
7. **Test with small datasets** first

## Troubleshooting

### Common Issues

1. **Item not found**: Check repository name and issue/PR number
2. **Status update fails**: Try different emoji variations
3. **Permission denied**: Ensure `projects: write` permission
4. **Authentication fails**: Check token scopes

### Debug Commands

```bash
# Check authentication
gh auth status

# List all projects
gh project list --owner jreakin

# View project details
gh project view 4 --owner jreakin

# List project items with full details
gh project item-list 4 --owner jreakin --format json | jq '.[0]'
```

## Available Workflows

This repository includes several example workflows:

1. **`project-automation-gh.yml`** - Comprehensive automation with `gh` CLI
2. **`simple-project-automation.yml`** - Basic status updates
3. **`gh-project-examples.yml`** - Various automation patterns

Choose the workflow that best fits your needs, or use them as templates for custom automation.