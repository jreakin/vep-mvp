# GitHub Setup Guide

Follow these steps to get your VEP MVP project on GitHub.

## 📋 What You Need

- GitHub account ([sign up here](https://github.com/join) if needed)
- Git installed on your Mac
- Terminal access
- The vep-mvp project in `~/PyCharmProjects/vep-mvp`

## 🚀 Step-by-Step Setup (10 minutes)

### Step 1: Initialize Git Repository

Open Terminal and navigate to your project:

```bash
cd ~/PyCharmProjects/vep-mvp

# Initialize git repository
git init

# Check status
git status
```

You should see all your files listed as "Untracked files".

### Step 2: Stage and Commit All Files

```bash
# Add all files to git
git add .

# Verify what will be committed
git status

# Create initial commit
git commit -m "feat: Initial project setup with multi-agent structure

- Complete technical specification (spec.md)
- Agent instructions and boundaries
- Python backend setup with UV
- iOS app structure  
- Progress tracking and documentation
- CI/CD workflows
- Contributing guidelines

Project ready for Agent 1 to begin database schema creation."
```

### Step 3: Create GitHub Repository

1. **Go to GitHub:** https://github.com/new

2. **Fill in repository details:**
   - **Repository name:** `vep-mvp`
   - **Description:** `Voter Engagement Platform MVP - Multi-agent AI development`
   - **Visibility:** Choose Public or Private
   - **DON'T check:** "Initialize with README" (we have one)
   - **DON'T add:** .gitignore or license (we have them)

3. **Click:** "Create repository"

### Step 4: Connect Local to GitHub

GitHub will show you commands. Use these:

```bash
# Add GitHub as remote (replace YOUR-USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR-USERNAME/vep-mvp.git

# Verify remote was added
git remote -v

# Rename branch to main (if not already)
git branch -M main

# Push to GitHub
git push -u origin main
```

**If you get authentication error:**
- GitHub now requires personal access tokens
- Follow GitHub's instructions to create a token
- Or use SSH keys (see below)

### Step 5: Configure Repository Settings

On GitHub, go to your repository page:

1. **Add Topics** (make it discoverable)
   - Click gear icon next to "About"
   - Add topics: `ai-development`, `fastapi`, `swiftui`, `voter-engagement`, `multi-agent`, `mvp`

2. **Enable Issues**
   - Settings → General → Features
   - Check "Issues"

3. **Enable Discussions** (optional)
   - Settings → General → Features
   - Check "Discussions"

4. **Enable GitHub Actions**
   - Should be enabled by default
   - Actions tab → Enable workflows

5. **Set Branch Protection** (optional but recommended)
   - Settings → Branches → Add rule
   - Branch name pattern: `main`
   - Check: "Require status checks to pass before merging"
   - Check: "Require branches to be up to date before merging"
   - Save changes

### Step 6: Update README Badges

Edit `README.md` and replace `YOUR-USERNAME` with your GitHub username in the badge URLs:

```bash
# Open in your editor
open README.md

# Or use sed to replace all at once:
sed -i '' 's/YOUR-USERNAME/your-actual-username/g' README.md

# Commit the change
git add README.md
git commit -m "docs: Update README badges with GitHub username"
git push
```

### Step 7: Set Up Codecov (optional)

For code coverage tracking:

1. Go to https://codecov.io
2. Sign in with GitHub
3. Add your repository
4. Copy the upload token
5. Add token to GitHub Secrets:
   - Repository → Settings → Secrets and variables → Actions
   - New repository secret
   - Name: `CODECOV_TOKEN`
   - Value: [paste token]

### Step 8: Create Initial Issues

Create issues for each agent's work:

```bash
# Agent 1 - Database
Go to: Issues → New Issue → Agent Task template
Title: [AGENT 1] Database Schema with PostGIS
Fill in template and create

# Agent 2 - Backend API
Title: [AGENT 2] FastAPI Backend Routes
Mark as "depends on #1"

# Agent 3 - Frontend
Title: [AGENT 3] SwiftUI Views and ViewModels
Mark as "depends on #2"

# Agent 4 - Integration
Title: [AGENT 4] Service Layer and Offline Sync
Mark as "depends on #2, #3"

# Agent 5 - Testing
Title: [AGENT 5] Test Suite and CI/CD
Mark as "can start after #1"
```

### Step 9: Create Project Board (optional)

Organize work visually:

1. **Projects** → **New project** → **Board**
2. **Name:** "VEP MVP Development"
3. **Add columns:**
   - 🟡 Ready
   - 🟠 In Progress
   - 👀 In Review
   - ✅ Done
4. **Add your issues** to the board

## 🔐 SSH Setup (Recommended)

Using SSH is easier than tokens:

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "your-email@example.com"

# Start SSH agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub:
# Settings → SSH and GPG keys → New SSH key
# Paste the key, give it a name, save

# Update remote to use SSH
git remote set-url origin git@github.com:YOUR-USERNAME/vep-mvp.git

# Test connection
ssh -T git@github.com
```

## 🎯 Verification Checklist

After setup, verify everything works:

- [ ] Repository visible on GitHub
- [ ] README displays correctly
- [ ] All files pushed (check file count)
- [ ] CI/CD workflows visible in Actions tab
- [ ] Issues created for each agent
- [ ] Branch protection configured (optional)
- [ ] Topics added to repository
- [ ] README badges show (may need first push to trigger)

## 🚦 What's Next?

Now that GitHub is set up:

1. **Read QUICKSTART.md** to understand the workflow
2. **Check PROGRESS.md** for current status
3. **Open Cursor IDE** and prepare to invoke Agent 1
4. **Create a branch** for Agent 1's work:
   ```bash
   git checkout -b agent-1/database-schema
   ```
5. **Invoke Agent 1** using the prompt from `.copilot/instructions-agent-1.md`
6. **Review and push** Agent 1's work
7. **Create PR** to main branch
8. **Merge** after review
9. **Update PROGRESS.md**
10. **Move to Agent 2!**

## 🆘 Troubleshooting

### "Authentication failed"
- Use personal access token or SSH keys
- Token needs `repo` scope

### "Remote already exists"
```bash
git remote remove origin
# Then add it again with correct URL
```

### "Permission denied (publickey)"
- SSH key not set up correctly
- Follow SSH setup section above

### "Not a git repository"
```bash
cd ~/PyCharmProjects/vep-mvp
git init
# Then continue from Step 2
```

### "Push rejected"
- Someone else pushed to main
- Pull first: `git pull origin main --rebase`
- Then push: `git push origin main`

## 📞 Need Help?

- **Git Issues:** https://docs.github.com/en/get-started
- **SSH Setup:** https://docs.github.com/en/authentication/connecting-to-github-with-ssh
- **GitHub Actions:** https://docs.github.com/en/actions

---

**You're all set!** 🎉 Your project is now on GitHub and ready for multi-agent development.

Next step: [Open QUICKSTART.md](../QUICKSTART.md) to begin invoking agents.
