# GitHub Projects V2 Migration

## 🎯 Summary

The project-automation workflow has been migrated from GitHub Projects Classic (V1) to GitHub Projects V2 API. This fixes the workflow failures that were occurring due to API incompatibility.

## 🔧 Changes Made

### 1. API Migration
- **Before:** Used `repository.projects` (Classic Projects V1)
- **After:** Uses `organization.projectsV2` or `user.projectsV2` (Projects V2)

### 2. Field Updates
- **Before:** Used `moveProjectCard` mutation with columns
- **After:** Uses `updateProjectV2ItemFieldValue` mutation with Status field

### 3. Improved Error Handling
- Added comprehensive logging at each step
- Added try-catch blocks for better error messages
- Logs available projects, fields, and options for debugging

### 4. Flexible Status Matching
- Supports status names with or without emoji prefixes
- Matches: "Ready", "🟡 Ready", "In Progress", "🟠 In Progress", etc.

## 📋 Requirements

### Project Setup
Your GitHub Project must meet these requirements:

1. **Project Type:** GitHub Projects V2 (the new Projects)
   - Not Classic Projects (V1)
   - Identified by modern UI with customizable fields

2. **Project Location:** 
   - Organization-level project (for org repos)
   - User-level project (for personal repos)
   - Not repository-level project boards

3. **Project Name:**
   - Must contain "VEP MVP" (case-insensitive)
   - Example: "VEP MVP - Multi-Agent Development"

4. **Status Field:**
   - Field name must be exactly "Status" (case-sensitive)
   - Field type must be "Single select"
   - Should have these options:
     - Ready (or 🟡 Ready)
     - In Progress (or 🟠 In Progress)
     - Code Review (or 👀 Code Review)
     - Testing (or ✅ Testing)
     - Done (or 🎉 Done)

### Workflow Permissions
In repository Settings → Actions → General:
- ✅ "Read and write permissions"
- ✅ "Allow GitHub Actions to create and approve pull requests"

## 🚀 Automation Rules

The workflow automatically updates issue/PR status based on these events:

| Event | Trigger | New Status |
|-------|---------|------------|
| Issue assigned | User assigned to issue | In Progress |
| PR opened | New pull request created | Code Review |
| PR reopened | Pull request reopened | Code Review |
| PR merged | Pull request merged | Testing |
| PR closed (not merged) | PR closed without merging | Ready |
| Issue closed | Issue closed | Done |
| Label added: "in-progress" | Label applied to issue | In Progress |
| Label added: "completed" | Label applied to issue | Done |

## 🧪 Testing

### Quick Test
1. Assign an issue to yourself
2. Check Actions tab → Project Automation workflow
3. Review logs for success message
4. Verify issue status updated in project board

### Detailed Testing
See `.github/test-project-automation.md` for comprehensive testing instructions.

## 🔍 Debugging

### Check Workflow Logs
Go to Actions tab and look for these log messages:

✅ **Success indicators:**
```
Processing issues event for [number]
Found project: VEP MVP (id)
Available fields: [Status, ...]
Status field options: [Ready, In Progress, ...]
Found project item: [id]
Target status: [status name]
Successfully updated project item status to: [status]
```

❌ **Common errors and solutions:**

**"VEP MVP project not found"**
- Check: Project name includes "VEP MVP"
- Check: Available projects list in logs

**"Status field not found or has no options"**
- Check: Project has "Status" field (exact name)
- Check: Field type is "Single select"
- Check: Field has options configured

**"Project item not found"**
- Check: Issue/PR is added to project
- Go to project → "+ Add item" → Add the issue

**"Status option not found"**
- Check: Status field has the expected option
- Check: Available options list in logs
- Add missing status option to field

## 📊 Technical Details

### GraphQL Queries Used

1. **Get Projects:** Retrieves organization/user projects
2. **Get Fields:** Retrieves project fields including Status
3. **Get Project Items:** Finds the issue/PR in the project
4. **Update Status:** Updates the Status field value

### API Differences

| Feature | Classic (V1) | Projects V2 |
|---------|-------------|-------------|
| Query | `repository.projects` | `organization.projectsV2` |
| Structure | Columns | Customizable fields |
| Move | `moveProjectCard` | `updateProjectV2ItemFieldValue` |
| Item ID | Card ID | Project item ID |

## 🎉 Benefits

1. **Works with Modern Projects:** Uses the current GitHub Projects V2
2. **Better Error Messages:** Comprehensive logging for debugging
3. **More Flexible:** Supports various status name formats
4. **Organization Support:** Works with both org and user projects
5. **Future-Proof:** Uses the actively maintained API

## 📚 Resources

- [GitHub Projects V2 Documentation](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [GraphQL API for Projects V2](https://docs.github.com/en/graphql/reference/objects#projectv2)
- [Project Automation Examples](https://docs.github.com/en/actions/managing-issues-and-pull-requests/using-github-actions-for-project-management)

## 🆘 Support

If the workflow still doesn't work after following this guide:

1. Check the workflow logs in Actions tab
2. Verify all requirements are met
3. Share the workflow logs for debugging
4. Check if project is V2 (not Classic)

---

**The workflow is now ready to use with GitHub Projects V2!** 🎉
