# Test Project Automation Workflow

## 🧪 How to Test the Project Automation

The project automation workflow uses GitHub Projects V2 API to automatically move issues and PRs between your project board status fields. Here's how to test it:

### **Prerequisites:**
- Project board must use GitHub Projects V2 (the new Projects)
- Project name must include "VEP MVP"
- Project must have a "Status" field with options
- Issues/PRs must be added to the project board

### **Your Project Board Status Options:**
- ✅ **Ready** (or 🟡 Ready)
- ✅ **In Progress** (or 🟠 In Progress)
- ✅ **Code Review** (or 👀 Code Review)
- ✅ **Testing** (or ✅ Testing)
- ✅ **Done** (or 🎉 Done)

### **Test 1: Issue Assignment**
1. **Go to Issue #2:** https://github.com/jreakin/vep-mvp/issues/2
2. **Assign it to yourself** (or someone else)
3. **Expected Result:** Issue status should automatically update to "In Progress"

### **Test 2: PR Creation**
1. **Create a PR** linked to Issue #2 (use "Closes #2" in description)
2. **Expected Result:** Issue status should automatically update to "Code Review"

### **Test 3: PR Merge**
1. **Merge the PR** when ready
2. **Expected Result:** Issue status should automatically update to "Testing"

### **Test 4: Issue Close**
1. **Close Issue #2** after testing
2. **Expected Result:** Issue status should automatically update to "Done"

### **Test 5: PR Closed Without Merge**
1. **Create a PR** and close it without merging
2. **Expected Result:** Issue status should revert to "Ready"

## 🔍 **Debugging the Workflow**

### **Check Workflow Logs:**
1. Go to **Actions tab:** https://github.com/jreakin/vep-mvp/actions
2. Look for **"Project Automation"** workflow runs
3. Click on the latest run to see logs
4. Look for messages like:
   - "Processing issues event for [number]"
   - "Available projects: [...]"
   - "Found project: VEP MVP (id)"
   - "Available fields: [...]"
   - "Status field options: [...]"
   - "Successfully updated project item status to: [status]"

### **Common Issues:**

**Issue 1: "VEP MVP project not found"**
- **Solution:** Make sure your project name contains "VEP MVP"
- Check the "Available projects" log to see what projects were found

**Issue 2: "Status field not found or has no options"**
- **Solution:** Ensure your project has a "Status" field (single-select type)
- Add status options: Ready, In Progress, Code Review, Testing, Done
- Emojis are optional but supported (🟠, 🟡, 👀, ✅, 🎉)

**Issue 3: "Project item not found"**
- **Solution:** Make sure the issue/PR is added to the project board
- Go to the project, click "+ Add item", and add the issue

**Issue 4: "Status option not found"**
- **Solution:** Check that your status field has the expected option names
- The workflow looks for exact matches or matches with emoji prefixes
- Check "Available options" log to see what was found

## 🛠️ **Manual Testing Commands**

### **Add Issue to Project:**
```bash
# List available projects
gh project list --owner jreakin

# Add issue to project (replace PROJECT_ID with actual ID)
gh issue edit 2 --add-project "VEP MVP"
```

### **Check Workflow Status:**
```bash
# List recent workflow runs
gh run list --workflow=project-automation.yml --limit 5

# View logs for a specific run (replace RUN_ID)
gh run view RUN_ID --log
```

### **Trigger Workflow:**
```bash
# Assign issue to trigger workflow
gh issue edit 2 --add-assignee @me

# Create a PR to trigger workflow
gh pr create --title "Test PR" --body "Closes #2"
```

## 📊 **Expected Workflow Behavior**

| Event | Issue #2 Column | PR #1 Column |
|-------|----------------|--------------|
| **Initial** | Ready | - |
| **Issue Assigned** | In Progress | - |
| **PR Created** | Code Review | - |
| **PR Merged** | Testing | - |
| **Issue Closed** | Done | - |

## 🚨 **If Workflow Doesn't Work**

### **Check 1: Project Type**
- Make sure you're using GitHub Projects V2 (the new Projects)
- Classic Projects (V1) are not supported
- Projects V2 can be identified by the modern UI with customizable fields

### **Check 2: Project Ownership**
- Project must be owned by the repository owner (user or organization)
- Repository projects (project boards inside a repo) may not work
- Use organization-level or user-level projects

### **Check 3: Project Name**
- Make sure project name includes "VEP MVP" (case-insensitive match)
- Example: "VEP MVP - Multi-Agent Development"

### **Check 4: Status Field**
- Ensure project has a "Status" field (exact name, case-sensitive)
- Field type must be "Single select"
- Add options: Ready, In Progress, Code Review, Testing, Done
- Emoji prefixes are optional (🟠, 🟡, 👀, ✅, 🎉)

### **Check 5: Issue in Project**
- Make sure the issue/PR is added to the project board
- Go to project → Click "+ Add item" → Search and add
- Issues must be in the project for status to be updated

### **Check 6: Workflow Permissions**
- Go to Settings → Actions → General
- Make sure "Workflow permissions" is set to "Read and write permissions"
- Enable "Allow GitHub Actions to create and approve pull requests"

## 🛠️ **Manual Testing Commands**

### **Add Issue to Project:**
```bash
# List available projects
gh project list --owner jreakin

# Add issue to project (replace PROJECT_ID with actual ID)
gh issue edit 2 --add-project "VEP MVP"
```

### **Check Workflow Status:**
```bash
# List recent workflow runs
gh run list --workflow=project-automation.yml --limit 5

# View logs for a specific run (replace RUN_ID)
gh run view RUN_ID --log
```

### **Trigger Workflow:**
```bash
# Assign issue to trigger workflow
gh issue edit 2 --add-assignee @me

# Create a PR to trigger workflow
gh pr create --title "Test PR" --body "Closes #2"
```

---

**Test the workflow step by step and check the Actions logs for detailed debugging information!** 🧪