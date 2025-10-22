# Test Project Automation Workflow

## 🧪 How to Test the Project Automation

The project automation workflow should automatically move issues and PRs between your project board columns. Here's how to test it:

### **Your Project Board Columns:**
- ✅ **Ready**
- ✅ **In Progress** 
- ✅ **Code Review**
- ✅ **Testing**
- ✅ **Done**

### **Test 1: Issue Assignment**
1. **Go to Issue #2:** https://github.com/jreakin/vep-mvp/issues/2
2. **Assign it to yourself** (or someone else)
3. **Expected Result:** Issue should automatically move to "In Progress" column

### **Test 2: PR Creation**
1. **Go to PR #1:** https://github.com/jreakin/vep-mvp/pull/1
2. **Make sure it's linked to Issue #2** (it should be, since we added "Closes #2")
3. **Expected Result:** Issue #2 should automatically move to "Code Review" column

### **Test 3: PR Merge**
1. **Merge PR #1** when ready
2. **Expected Result:** Issue #2 should automatically move to "Testing" column

### **Test 4: Issue Close**
1. **Close Issue #2** after testing
2. **Expected Result:** Issue #2 should automatically move to "Done" column

## 🔍 **Debugging the Workflow**

### **Check Workflow Logs:**
1. Go to **Actions tab:** https://github.com/jreakin/vep-mvp/actions
2. Look for **"Project Automation"** workflow runs
3. Click on the latest run to see logs
4. Look for messages like:
   - "Available columns: [Ready, In Progress, Code Review, Testing, Done]"
   - "Found columns: {ready: 'Ready', inProgress: 'In Progress', ...}"
   - "Moved project card to [Column Name]"

### **Common Issues:**

**Issue 1: "VEP MVP project not found"**
- **Solution:** Make sure your project board is named "VEP MVP - Multi-Agent Development" or contains "VEP MVP"

**Issue 2: "Target column not found"**
- **Solution:** Check that your column names match exactly:
  - "Ready" (not "🟡 Ready")
  - "In Progress" (not "🟠 In Progress")
  - "Code Review" (not "👀 Code Review")
  - "Testing" (not "✅ Testing")
  - "Done" (not "🎉 Done")

**Issue 3: "Project card not found"**
- **Solution:** Make sure the issue is added to the project board

## 🛠️ **Manual Testing Commands**

### **Test Issue Assignment:**
```bash
# Assign Issue #2 to yourself
gh issue edit 2 --add-assignee @me
```

### **Test PR Creation:**
```bash
# Check if PR #1 is linked to Issue #2
gh pr view 1
```

### **Test PR Merge:**
```bash
# Merge PR #1 (when ready)
gh pr merge 1 --squash --delete-branch
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

### **Check 1: Project Board Name**
- Make sure it contains "VEP MVP" in the name
- Or update the workflow to match your exact project name

### **Check 2: Column Names**
- Make sure they match exactly: "Ready", "In Progress", "Code Review", "Testing", "Done"
- No emojis or extra characters

### **Check 3: Issue in Project**
- Make sure Issue #2 is added to the project board
- You can add it manually if needed

### **Check 4: Workflow Permissions**
- Go to Settings → Actions → General
- Make sure "Workflow permissions" is set to "Read and write permissions"

## 🔧 **Quick Fix Commands**

### **Update Project Name in Workflow:**
```bash
# Edit the workflow to match your project name
gh workflow edit project-automation.yml
```

### **Add Issue to Project:**
1. Go to your project board
2. Click "Add item"
3. Search for "is:issue"
4. Add Issue #2

### **Check Workflow Status:**
```bash
# List recent workflow runs
gh run list --workflow=project-automation.yml
```

---

**Test the workflow step by step and let me know what happens!** 🧪