# GitHub Setup Command

## Command: /github:setup

### Purpose
Configure GitHub CLI and integration for BMAD development workflows.

### Usage
```
/github:setup
/github:setup --verify
/github:setup --reset
```

### Process

#### 1. Check Prerequisites
```bash
# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    # Installation varies by OS
    install_github_cli
fi

# Verify installation
gh --version
```

#### 2. GitHub CLI Installation

**Linux/WSL:**
```bash
# Using official GitHub repository
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

**macOS:**
```bash
# Using Homebrew
brew install gh
```

**Windows:**
```bash
# Using winget
winget install --id GitHub.cli
```

#### 3. Authentication Setup
```bash
# Start authentication flow
echo "Starting GitHub authentication..."
gh auth login

# Verify authentication
gh auth status

# Test API access
gh api user
```

#### 4. Repository Configuration
```bash
# Check if we're in a git repository
if [ ! -d .git ]; then
    echo "Not in a git repository. Initializing..."
    git init
fi

# Check for GitHub remote
if ! git remote get-url origin &> /dev/null; then
    echo "No GitHub remote configured."
    echo "Please add a GitHub remote:"
    echo "git remote add origin https://github.com/username/repository.git"
    read -p "Repository URL: " repo_url
    git remote add origin "$repo_url"
fi

# Verify repository access
gh repo view
```

#### 5. Install Required Extensions
```bash
# Install gh-sub-issue extension for parent-child issue relationships
echo "Installing gh-sub-issue extension..."
gh extension install yahsan2/gh-sub-issue

# Verify extension installation
gh extension list
```

#### 6. Create BMAD Configuration
```bash
# Create GitHub integration configuration
mkdir -p .bmad-project/github/

# Create configuration file
cat > .bmad-project/github/config.json << EOF
{
  "repository": "$(gh repo view --json nameWithOwner -q .nameWithOwner)",
  "api_url": "$(gh api graphql -q .data.viewer.login --raw-field query='query{viewer{login}}')",
  "integration_enabled": true,
  "auto_sync": true,
  "comment_on_failures": true,
  "setup_date": "$(date -Iseconds)",
  "setup_by": "$(git config user.name)"
}
EOF

# Create templates directory
mkdir -p .bmad-project/github/templates/

# Create issue templates
create_issue_templates
```

#### 7. Test Integration
```bash
# Test basic GitHub access
echo "Testing GitHub integration..."

# Test issue access
gh issue list --limit 1

# Test comment posting (on a test issue if available)
if [ -n "$TEST_ISSUE" ]; then
    gh issue comment "$TEST_ISSUE" --body "✅ BMAD GitHub integration test successful"
fi

# Test repository information
gh repo view --json name,owner,description
```

#### 8. Update .gitignore
```bash
# Add BMAD GitHub files to .gitignore if not already present
cat >> .gitignore << EOF

# BMAD GitHub Integration
.bmad-project/github/tokens/
.bmad-project/github/cache/
.bmad-project/github-context.json
.bmad-project/last-sync.timestamp
EOF
```

#### 9. Configure BMAD Integration
Update expansion pack configuration:
```bash
# Update config.yaml to enable GitHub integration
if [ -f expansion-packs/bmad-erpnext-v16/config.yaml ]; then
    # Enable GitHub integration in BMAD config
    enable_github_in_bmad_config
fi
```

### Issue Template Creation
```bash
create_issue_templates() {
    # Feature request template
    cat > .bmad-project/github/templates/feature.md << 'EOF'
## Feature Request

### Description
Brief description of the feature

### User Story
As a [user type], I want [feature] so that [benefit]

### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

### Technical Requirements
- DocType changes needed: Yes/No
- API endpoints needed: Yes/No
- Frontend changes needed: Yes/No
- Workflow changes needed: Yes/No

### ERPNext Context
- Module: [Sales/Purchase/Stock/etc.]
- Dependencies: [Other DocTypes/features]
- Permissions: [User roles affected]

---
*Created for BMAD ERPNext v16 development*
EOF

    # Bug report template
    cat > .bmad-project/github/templates/bug.md << 'EOF'
## Bug Report

### Description
Clear description of the bug

### Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

### Expected Behavior
What should happen

### Actual Behavior
What actually happens

### Environment
- ERPNext Version: v16
- Frappe Version: v16
- Browser: [if frontend issue]
- Custom Apps: [list any]

### Error Details
```
[Error messages/stack traces]
```

---
*Bug report for BMAD ERPNext v16*
EOF
}
```

### Verification Mode
```bash
/github:setup --verify

# Checks:
# 1. GitHub CLI installed and authenticated
# 2. Repository access working
# 3. Required extensions installed
# 4. BMAD configuration valid
# 5. Issue access permissions
# 6. Comment posting permissions
```

### Reset Mode
```bash
/github:setup --reset

# Actions:
# 1. Clear authentication
# 2. Remove BMAD GitHub configuration
# 3. Reinstall extensions
# 4. Reconfigure from scratch
```

### Output

#### Success
```
✅ GitHub CLI installed successfully
✅ Authentication configured
✅ Repository access verified: username/repository
✅ gh-sub-issue extension installed
✅ BMAD configuration created
✅ Integration test passed

GitHub integration is ready for BMAD workflows!

Next steps:
- Run: /github:issue-fetch {issue_number}
- Use: /bmadErpNext:agent:development-coordinator
```

#### Failure
```
❌ Setup failed: Authentication required
💡 Run: gh auth login
❌ Repository not accessible
💡 Check repository URL and permissions
```

### Configuration Validation
```bash
validate_github_setup() {
    local errors=0
    
    # Check CLI
    if ! command -v gh &> /dev/null; then
        echo "❌ GitHub CLI not installed"
        ((errors++))
    fi
    
    # Check auth
    if ! gh auth status &> /dev/null; then
        echo "❌ GitHub authentication required"
        ((errors++))
    fi
    
    # Check repository
    if ! gh repo view &> /dev/null; then
        echo "❌ Repository not accessible"
        ((errors++))
    fi
    
    # Check extensions
    if ! gh extension list | grep -q "gh-sub-issue"; then
        echo "❌ gh-sub-issue extension not installed"
        ((errors++))
    fi
    
    return $errors
}
```

### Integration Points
- Required for all `/github:*` commands
- Enables auto-sync in coordination-workflow
- Supports issue-based development workflow
- Integrates with quality gate reporting

### Related Commands
- `/github:issue-fetch` - Fetch issues after setup
- `/github:issue-sync` - Sync progress after setup
- `/github:issue-comment` - Post comments after setup