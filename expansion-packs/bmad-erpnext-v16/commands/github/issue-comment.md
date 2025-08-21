# GitHub Issue Comment Command

## Command: /github:issue-comment

### Purpose
Post a custom comment to the current GitHub issue.

### Usage
```
/github:issue-comment {message}
/github:issue-comment --file {file_path}
/github:issue-comment --template {template_name}
```

### Prerequisites
- GitHub CLI (`gh`) must be installed and authenticated
- Issue context must be established (via `/github:issue-fetch`)

### Process

#### 1. Validate Context
```bash
# Check if issue context exists
if [ ! -f .bmad-project/github-context.json ]; then
    echo "No GitHub issue context. Run /github:issue-fetch first"
    exit 1
fi

# Get current issue number
ISSUE_NUMBER=$(cat .bmad-project/github-context.json | jq -r '.issue_number')
```

#### 2. Prepare Comment Content

**Direct Message:**
```bash
/github:issue-comment "Ready for review. All quality gates passed."
```

**From File:**
```bash
/github:issue-comment --file progress-report.md
```

**From Template:**
```bash
/github:issue-comment --template completion
```

#### 3. Available Templates

**Completion Template:**
```markdown
## ✅ Development Complete

All requested features have been implemented and tested:

### Summary of Changes
- {{CHANGES_SUMMARY}}

### Quality Assurance
- ✅ All tests passing
- ✅ Code review complete  
- ✅ Documentation updated
- ✅ Security validation passed

### Files Modified
{{FILES_MODIFIED}}

### Testing Notes
{{TESTING_NOTES}}

Ready for final review and merge.

---
*Completed by BMAD ERPNext v16 • [Claude Code](https://claude.ai/code)*
```

**Blocking Issue Template:**
```markdown
## 🚫 Development Blocked

Development has been paused due to the following issue:

### Issue Description
{{ISSUE_DESCRIPTION}}

### Impact
{{IMPACT_DESCRIPTION}}

### Required Resolution
{{RESOLUTION_REQUIRED}}

### ETA
{{ESTIMATED_TIME}}

Will resume development once this is resolved.

---
*BMAD ERPNext v16 • [Claude Code](https://claude.ai/code)*
```

**Progress Checkpoint Template:**
```markdown
## 📍 Progress Checkpoint

### Current Status
{{CURRENT_STATUS}}

### Completed Work
{{COMPLETED_WORK}}

### In Progress
{{IN_PROGRESS_WORK}}

### Upcoming
{{UPCOMING_WORK}}

### Estimated Completion
{{ETA}}

---
*BMAD ERPNext v16 • [Claude Code](https://claude.ai/code)*
```

**Quality Gate Failure Template:**
```markdown
## ⚠️ Quality Gate Issue

A quality gate has failed and requires attention:

### Failed Gate
{{GATE_NAME}}

### Failure Details
{{FAILURE_DETAILS}}

### Proposed Resolution
{{RESOLUTION_PLAN}}

### Impact
{{IMPACT_ASSESSMENT}}

Development will continue once this is resolved.

---
*BMAD ERPNext v16 • [Claude Code](https://claude.ai/code)*
```

#### 4. Post Comment
```bash
# Prepare comment with BMAD branding
COMMENT_BODY="$1

---
*Posted by BMAD ERPNext v16 • [Claude Code](https://claude.ai/code)*"

# Post to GitHub
gh issue comment ${ISSUE_NUMBER} --body "${COMMENT_BODY}"

# Log the action
echo "$(date): Posted comment to issue #${ISSUE_NUMBER}" >> .bmad-project/github-activity.log
```

#### 5. Template Variable Substitution
Replace template variables with actual values:
```bash
# Replace common variables
COMMENT_BODY=$(echo "$COMMENT_BODY" | \
    sed "s/{{ISSUE_NUMBER}}/${ISSUE_NUMBER}/g" | \
    sed "s/{{TIMESTAMP}}/$(date)/g" | \
    sed "s/{{SESSION_ID}}/${SESSION_ID}/g" | \
    sed "s/{{EXECUTION_MODE}}/${EXECUTION_MODE}/g")

# Replace context-specific variables
if [ -f .bmad-project/current-status.json ]; then
    CURRENT_STATUS=$(jq -r '.status' .bmad-project/current-status.json)
    COMMENT_BODY=$(echo "$COMMENT_BODY" | sed "s/{{CURRENT_STATUS}}/${CURRENT_STATUS}/g")
fi
```

### Advanced Usage

#### Multi-line Comments
```bash
/github:issue-comment "
## Implementation Notes

This implementation includes:
1. New DocType for inventory tracking
2. API endpoints for real-time updates
3. Vue components for dashboard display

All components follow ERPNext v16 best practices.
"
```

#### Conditional Comments
```bash
# Only post if tests are passing
if [ "$TEST_STATUS" = "PASSED" ]; then
    /github:issue-comment --template completion
else
    /github:issue-comment --template quality-gate-failure
fi
```

#### Automated Comments from Workflows
Integration with BMAD workflows:
```yaml
# In coordination-workflow.yaml
- action: post_progress_comment
  when: "quality_gates_completed"
  command: "/github:issue-comment --template progress-checkpoint"
```

### Output
```
✅ Comment posted to GitHub Issue #1234
🔗 View: https://github.com/user/repo/issues/1234#issuecomment-123456
📝 Content: "Ready for review. All quality gates passed."
```

### Error Handling
- **No GitHub context**: Prompt to run `/github:issue-fetch`
- **Authentication failed**: Guide to `gh auth login`
- **Issue not found**: Verify issue exists and is accessible
- **Rate limiting**: Implement exponential backoff

### Integration Points
- Used by coordination-workflow for automatic updates
- Called by quality-gate-enforcement-workflow on failures
- Triggered by parallel-failure-recovery-workflow

### Related Commands
- `/github:issue-fetch` - Establish issue context
- `/github:issue-sync` - Automated progress sync
- `/github:setup` - Configure GitHub integration