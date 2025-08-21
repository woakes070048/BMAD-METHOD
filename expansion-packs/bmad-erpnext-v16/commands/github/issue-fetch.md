# GitHub Issue Fetch Command

## Command: /github:issue-fetch

### Purpose
Fetch a GitHub issue and prepare it for BMAD development workflow processing.

### Usage
```
/github:issue-fetch {issue_number}
```

### Prerequisites
- GitHub CLI (`gh`) must be installed and authenticated
- Repository must be configured in config.yaml
- Issue must exist and be accessible

### Process

#### 1. Validate Prerequisites
```bash
# Check if gh CLI is available
which gh || echo "GitHub CLI not installed. Run: /github:setup"

# Check authentication
gh auth status || echo "Not authenticated. Run: gh auth login"

# Verify repository access
gh repo view || echo "Repository not accessible"
```

#### 2. Fetch Issue Data
```bash
# Fetch issue details
gh issue view ${issue_number} --json title,body,labels,assignees,state,url

# Save to local workspace
mkdir -p .bmad-project/github-issues/
gh issue view ${issue_number} --json title,body,labels,assignees,state,url > .bmad-project/github-issues/issue-${issue_number}.json
```

#### 3. Analyze Issue Content
- Parse issue title and body
- Identify ERPNext-specific keywords (DocType, API, workflow, Vue)
- Extract requirements and acceptance criteria
- Determine work complexity and dependencies

#### 4. Prepare for BMAD Processing
```bash
# Create BMAD story format
cat > .bmad-project/github-issues/story-${issue_number}.md << EOF
# GitHub Issue #${issue_number}: ${title}

## Original Issue
- **URL**: ${url}
- **Status**: ${state}
- **Labels**: ${labels}
- **Assignees**: ${assignees}

## Requirements
${body}

## BMAD Analysis
- **Work Type**: [Detected automatically]
- **Complexity**: [Low/Medium/High]
- **Dependencies**: [List any dependencies]
- **Estimated Effort**: [Time estimate]

## Acceptance Criteria
[Extracted from issue or generated]

## Implementation Notes
[Space for development notes]
EOF
```

#### 5. Integration with BMAD Workflows
- Set current GitHub issue context
- Enable GitHub sync for progress updates
- Configure issue comment posting

### Output
- Creates `issue-${issue_number}.json` with raw GitHub data
- Creates `story-${issue_number}.md` in BMAD story format
- Sets GitHub context for subsequent BMAD commands
- Displays issue summary and next steps

### Success Criteria
- Issue data successfully fetched
- BMAD story format created
- GitHub context established
- Ready for development workflow

### Error Handling
- **Issue not found**: Display error and suggest checking issue number
- **Authentication failed**: Guide user to `gh auth login`
- **Repository not accessible**: Check repository configuration
- **Network issues**: Retry with exponential backoff

### Integration Points
- Works with `/bmadErpNext:agent:development-coordinator` 
- Triggers execution mode selection based on issue analysis
- Enables `/github:sync` for progress updates

### Example Usage
```bash
# Fetch issue #1234
/github:issue-fetch 1234

# Output:
# ✓ Fetched GitHub Issue #1234: "Add inventory tracking to Purchase Order"
# ✓ Created BMAD story: story-1234.md
# ✓ GitHub context established
# 
# Next steps:
# - Review story-1234.md
# - Run: /bmadErpNext:agent:development-coordinator
# - Use: *execute-stories story-1234.md
```

### Related Commands
- `/github:setup` - Configure GitHub integration
- `/github:sync` - Sync progress to GitHub
- `/github:comment` - Post comment to issue