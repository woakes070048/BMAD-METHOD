# Initialize GitHub Context

## Task Description
Initialize and manage GitHub integration context for BMAD development sessions, providing persistent state management across execution modes and agent handoffs.

## Prerequisites
- GitHub CLI (`gh`) installed and authenticated
- Repository configured in config.yaml
- Access to github-context-template.yaml
- Valid .bmad-project directory structure

## Process

### Step 1: Validate GitHub Prerequisites
```bash
# Check GitHub CLI installation
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI not installed. Run: /github:setup"
    exit 1
fi

# Check authentication
if ! gh auth status &> /dev/null; then
    echo "❌ GitHub not authenticated. Run: gh auth login"
    exit 1
fi

# Verify repository access
if ! gh repo view &> /dev/null; then
    echo "❌ Repository not accessible"
    exit 1
fi
```

### Step 2: Create GitHub Context Directory Structure
```bash
# Create context directories
mkdir -p .bmad-project/github/
mkdir -p .bmad-project/github/sessions/
mkdir -p .bmad-project/github/issues/
mkdir -p .bmad-project/github/templates/
mkdir -p .bmad-project/github/logs/

# Create session-specific directory
SESSION_ID="bmad-$(date +%Y%m%d-%H%M%S)"
mkdir -p ".bmad-project/github/sessions/${SESSION_ID}"
```

### Step 3: Initialize GitHub Context
```bash
# Generate github-context.json from template
REPO_INFO=$(gh repo view --json nameWithOwner,url,defaultBranchRef)
REPO_OWNER=$(echo "$REPO_INFO" | jq -r '.nameWithOwner | split("/")[0]')
REPO_NAME=$(echo "$REPO_INFO" | jq -r '.nameWithOwner | split("/")[1]')
REPO_URL=$(echo "$REPO_INFO" | jq -r '.url')
CURRENT_BRANCH=$(git branch --show-current)
USER=$(gh api user --jq '.login')

# Create initial context file
cat > .bmad-project/github-context.json << EOF
{
  "github_session": {
    "session_id": "${SESSION_ID}",
    "created_at": "$(date -Iseconds)",
    "created_by": "${USER}",
    "repository": {
      "owner": "${REPO_OWNER}",
      "name": "${REPO_NAME}",
      "url": "${REPO_URL}",
      "branch": "${CURRENT_BRANCH}"
    },
    "current_issue": {
      "number": null,
      "title": null,
      "url": null,
      "state": null,
      "labels": [],
      "assignees": [],
      "body": null,
      "created_at": null,
      "updated_at": null
    },
    "authentication": {
      "gh_cli_authenticated": true,
      "user": "${USER}",
      "verified_at": "$(date -Iseconds)"
    },
    "integration_config": {
      "sync_enabled": true,
      "auto_comment": true,
      "progress_updates": true,
      "quality_gate_reporting": true,
      "conflict_reporting": true
    }
  },
  "execution_context": {
    "current_mode": "guided",
    "mode_selected_at": null,
    "mode_selected_by": null,
    "mode_selection_reason": null,
    "mode_settings": {
      "guided": {
        "sync_frequency": "on_user_approval",
        "comment_detail": "high",
        "user_interaction": "required"
      },
      "sequential": {
        "sync_frequency": "on_batch_completion",
        "comment_detail": "medium",
        "user_interaction": "minimal"
      },
      "smart_parallel": {
        "sync_frequency": "on_block_completion",
        "comment_detail": "high_with_metrics",
        "user_interaction": "on_conflicts"
      }
    }
  },
  "story_tracking": {
    "active_stories": [],
    "completed_stories": [],
    "failed_stories": []
  },
  "agent_execution": {
    "active_agents": [],
    "completed_agents": [],
    "failed_agents": []
  },
  "parallel_execution": {
    "enabled": false,
    "current_block": null,
    "total_blocks": 0,
    "completed_blocks": 0,
    "conflict_tracking": {
      "total_conflicts": 0,
      "resolved_conflicts": 0,
      "active_conflicts": [],
      "conflict_history": []
    },
    "performance_metrics": {
      "sequential_time_estimate": null,
      "parallel_time_estimate": null,
      "actual_execution_time": null,
      "efficiency_gain": null,
      "agent_utilization": null
    }
  },
  "quality_gates": {
    "total_gates_run": 0,
    "gates_passed": 0,
    "gates_failed": 0,
    "failed_gates": {
      "total_failures": 0,
      "recovery_attempts": 0,
      "successful_recoveries": 0,
      "escalations": 0
    }
  },
  "sync_status": {
    "last_sync_time": null,
    "total_syncs": 0,
    "successful_syncs": 0,
    "failed_syncs": 0,
    "rate_limiting": {
      "requests_made": 0,
      "requests_remaining": null,
      "reset_time": null,
      "last_rate_limit_check": null
    }
  },
  "progress_tracking": {
    "session_started_at": "$(date -Iseconds)",
    "last_activity_at": "$(date -Iseconds)",
    "total_work_time": null,
    "milestones": {
      "stories_created": 0,
      "agents_executed": 0,
      "quality_gates_passed": 0,
      "github_syncs_completed": 0,
      "conflicts_resolved": 0
    },
    "session_stats": {
      "stories_per_hour": null,
      "average_story_duration": null,
      "quality_gate_pass_rate": null,
      "github_sync_success_rate": null,
      "parallel_efficiency_gain": null
    }
  },
  "error_tracking": {
    "total_errors": 0,
    "github_errors": 0,
    "quality_gate_errors": 0,
    "parallel_execution_errors": 0,
    "recovery_tracking": {
      "automatic_recoveries": 0,
      "manual_interventions": 0,
      "session_resets": 0,
      "mode_fallbacks": 0
    }
  },
  "configuration": {
    "sync_overrides": {
      "disable_auto_comment": false,
      "custom_sync_frequency": null,
      "custom_comment_format": null
    },
    "quality_gate_overrides": {
      "skip_github_reporting": false,
      "custom_failure_threshold": null,
      "custom_recovery_strategy": null
    },
    "parallel_overrides": {
      "max_parallel_agents": null,
      "conflict_detection_sensitivity": null,
      "fallback_threshold": null
    }
  },
  "session_recovery": {
    "recovery_enabled": true,
    "recovery_data": {
      "checkpoint_frequency": "after_each_story",
      "last_checkpoint": "$(date -Iseconds)",
      "recoverable_state": null
    },
    "recovery_actions": {
      "auto_resume_on_restart": true,
      "preserve_github_context": true,
      "restore_execution_mode": true,
      "continue_parallel_execution": false
    }
  },
  "metrics": {
    "performance": {
      "stories_completed": 0,
      "average_story_time": null,
      "total_execution_time": null,
      "efficiency_rating": null
    },
    "quality": {
      "quality_gate_pass_rate": null,
      "defect_rate": null,
      "user_satisfaction": null
    },
    "github_integration": {
      "sync_success_rate": null,
      "comment_engagement": null,
      "issue_closure_rate": null
    },
    "parallel_execution": {
      "parallelization_success_rate": null,
      "conflict_rate": null,
      "efficiency_gain": null,
      "agent_utilization": null
    }
  }
}
EOF
```

### Step 4: Create Session Log
```bash
# Create session activity log
cat > ".bmad-project/github/sessions/${SESSION_ID}/session.log" << EOF
# BMAD GitHub Session Log
# Session: ${SESSION_ID}
# Started: $(date)
# Repository: ${REPO_OWNER}/${REPO_NAME}
# User: ${USER}

## Session Events
$(date) - Session initialized
$(date) - GitHub context created
$(date) - Authentication verified
$(date) - Repository access confirmed

## Session Configuration
- Sync enabled: true
- Auto-comment: true
- Progress updates: true
- Quality gate reporting: true
- Conflict reporting: true

## Next Steps
- Fetch GitHub issue: /github:issue-fetch {issue_number}
- Initialize development: /bmadErpNext:agent:development-coordinator
- Select execution mode: *select-execution-mode

EOF

# Set current session reference
echo "${SESSION_ID}" > .bmad-project/github/current-session.txt
```

### Step 5: Initialize Issue Templates
```bash
# Copy GitHub issue templates to project
cp .bmad-erpnext-v16/commands/github/*.md .bmad-project/github/templates/

# Create custom templates for project
cat > .bmad-project/github/templates/progress-update.md << 'EOF'
## 🤖 BMAD Development Progress

**Session**: ${SESSION_ID}
**Mode**: ${EXECUTION_MODE}
**Timestamp**: ${TIMESTAMP}

### Current Status
${CURRENT_STATUS}

### Work Completed
${COMPLETED_WORK}

### Quality Gates
${QUALITY_GATE_SUMMARY}

### Next Steps
${NEXT_STEPS}

${MODE_SPECIFIC_DETAILS}

---
*Updated by BMAD ERPNext v16 • [Claude Code](https://claude.ai/code)*
EOF

cat > .bmad-project/github/templates/parallel-progress.md << 'EOF'
## 🔀 Parallel Execution Progress

**Execution Block**: ${BLOCK_NAME} (${BLOCK_NUMBER}/${TOTAL_BLOCKS})
**Status**: ${BLOCK_STATUS}
**Progress**: ${COMPLETED_AGENTS}/${TOTAL_AGENTS} agents completed

### Parallel Work
${PARALLEL_WORK_SUMMARY}

### Performance Metrics
- **Estimated Time Savings**: ${TIME_SAVINGS}
- **Agent Utilization**: ${AGENT_UTILIZATION}
- **Conflicts Detected**: ${CONFLICTS_DETECTED}
- **Conflicts Resolved**: ${CONFLICTS_RESOLVED}

### Quality Gates
${QUALITY_GATE_SUMMARY}

${CONFLICT_DETAILS}

**ETA**: ${ESTIMATED_COMPLETION}

---
*Parallel execution by BMAD ERPNext v16 • [Claude Code](https://claude.ai/code)*
EOF

cat > .bmad-project/github/templates/quality-gate-failure.md << 'EOF'
## ⚠️ Quality Gate Failure

**Gate**: ${GATE_NAME}
**Story**: ${STORY_ID}
**Agent**: ${AGENT_ID}
**Failed At**: ${FAILURE_TIME}

### Failure Details
${FAILURE_DETAILS}

### Impact Assessment
${IMPACT_ASSESSMENT}

### Recovery Action
${RECOVERY_ACTION}

### Next Steps
${RECOVERY_STEPS}

---
*Quality gate monitoring by BMAD ERPNext v16 • [Claude Code](https://claude.ai/code)*
EOF
```

### Step 6: Create Context Helper Functions
```bash
# Create context management script
cat > .bmad-project/github/context-manager.sh << 'EOF'
#!/bin/bash

# GitHub Context Manager for BMAD
# Helper functions for managing GitHub integration context

CONTEXT_FILE=".bmad-project/github-context.json"

# Update execution mode
update_execution_mode() {
    local mode="$1"
    local reason="$2"
    local timestamp=$(date -Iseconds)
    
    jq --arg mode "$mode" --arg reason "$reason" --arg timestamp "$timestamp" \
       '.execution_context.current_mode = $mode | 
        .execution_context.mode_selected_at = $timestamp | 
        .execution_context.mode_selection_reason = $reason' \
       "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
}

# Add story to tracking
add_story() {
    local story_id="$1"
    local title="$2"
    local github_issue="$3"
    local execution_mode="$4"
    local timestamp=$(date -Iseconds)
    
    jq --arg story_id "$story_id" --arg title "$title" --arg github_issue "$github_issue" \
       --arg execution_mode "$execution_mode" --arg timestamp "$timestamp" \
       '.story_tracking.active_stories += [{
           "story_id": $story_id,
           "title": $title,
           "github_issue_number": ($github_issue | tonumber),
           "execution_mode": $execution_mode,
           "status": "pending",
           "created_at": $timestamp,
           "started_at": null,
           "completed_at": null,
           "assigned_agents": [],
           "quality_gates_passed": 0,
           "quality_gates_failed": 0,
           "github_syncs": 0
       }]' "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
}

# Update sync status
update_sync_status() {
    local sync_type="$1"
    local status="$2"
    local comment_id="$3"
    local timestamp=$(date -Iseconds)
    
    jq --arg sync_type "$sync_type" --arg status "$status" --arg comment_id "$comment_id" \
       --arg timestamp "$timestamp" \
       '.sync_status.last_sync_time = $timestamp |
        .sync_status.total_syncs += 1 |
        if $status == "success" then .sync_status.successful_syncs += 1 
        else .sync_status.failed_syncs += 1 end' \
       "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
}

# Record quality gate result
record_quality_gate() {
    local gate_name="$1"
    local story_id="$2"
    local agent_id="$3"
    local status="$4"
    local details="$5"
    local timestamp=$(date -Iseconds)
    
    jq --arg gate_name "$gate_name" --arg story_id "$story_id" --arg agent_id "$agent_id" \
       --arg status "$status" --arg details "$details" --arg timestamp "$timestamp" \
       '.quality_gates.total_gates_run += 1 |
        if $status == "passed" then .quality_gates.gates_passed += 1 
        else .quality_gates.gates_failed += 1 end' \
       "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
}

# Get current execution mode
get_execution_mode() {
    jq -r '.execution_context.current_mode' "$CONTEXT_FILE"
}

# Get current issue number
get_current_issue() {
    jq -r '.github_session.current_issue.number' "$CONTEXT_FILE"
}

# Check if GitHub sync is enabled
is_sync_enabled() {
    jq -r '.github_session.integration_config.sync_enabled' "$CONTEXT_FILE"
}

# Export functions for use in other scripts
case "$1" in
    "update_mode") update_execution_mode "$2" "$3" ;;
    "add_story") add_story "$2" "$3" "$4" "$5" ;;
    "update_sync") update_sync_status "$2" "$3" "$4" ;;
    "record_gate") record_quality_gate "$2" "$3" "$4" "$5" "$6" ;;
    "get_mode") get_execution_mode ;;
    "get_issue") get_current_issue ;;
    "is_sync_enabled") is_sync_enabled ;;
    *) echo "Usage: $0 {update_mode|add_story|update_sync|record_gate|get_mode|get_issue|is_sync_enabled}" ;;
esac
EOF

chmod +x .bmad-project/github/context-manager.sh
```

### Step 7: Create Recovery System
```bash
# Create session recovery script
cat > .bmad-project/github/recover-session.sh << 'EOF'
#!/bin/bash

# BMAD GitHub Session Recovery
# Recovers GitHub context from previous session

CONTEXT_FILE=".bmad-project/github-context.json"
BACKUP_DIR=".bmad-project/github/backups"

# Create backup of current context
backup_context() {
    local timestamp=$(date +%Y%m%d-%H%M%S)
    mkdir -p "$BACKUP_DIR"
    
    if [ -f "$CONTEXT_FILE" ]; then
        cp "$CONTEXT_FILE" "$BACKUP_DIR/github-context-${timestamp}.json"
        echo "✅ Context backed up to: $BACKUP_DIR/github-context-${timestamp}.json"
    fi
}

# Restore context from backup
restore_context() {
    local backup_file="$1"
    
    if [ -f "$backup_file" ]; then
        cp "$backup_file" "$CONTEXT_FILE"
        echo "✅ Context restored from: $backup_file"
        
        # Update recovery timestamp
        local timestamp=$(date -Iseconds)
        jq --arg timestamp "$timestamp" \
           '.session_recovery.recovery_data.last_checkpoint = $timestamp' \
           "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
    else
        echo "❌ Backup file not found: $backup_file"
        exit 1
    fi
}

# List available backups
list_backups() {
    echo "Available GitHub context backups:"
    ls -la "$BACKUP_DIR"/github-context-*.json 2>/dev/null || echo "No backups found"
}

# Validate context file
validate_context() {
    if [ -f "$CONTEXT_FILE" ]; then
        if jq empty "$CONTEXT_FILE" 2>/dev/null; then
            echo "✅ GitHub context is valid"
            
            # Show context summary
            echo ""
            echo "Context Summary:"
            echo "- Session ID: $(jq -r '.github_session.session_id' "$CONTEXT_FILE")"
            echo "- Current Mode: $(jq -r '.execution_context.current_mode' "$CONTEXT_FILE")"
            echo "- Active Stories: $(jq -r '.story_tracking.active_stories | length' "$CONTEXT_FILE")"
            echo "- Repository: $(jq -r '.github_session.repository.owner' "$CONTEXT_FILE")/$(jq -r '.github_session.repository.name' "$CONTEXT_FILE")"
        else
            echo "❌ GitHub context is corrupted"
            exit 1
        fi
    else
        echo "❌ GitHub context not found. Run: initialize-github-context.md"
        exit 1
    fi
}

# Auto-recovery check
auto_recovery() {
    if [ -f "$CONTEXT_FILE" ]; then
        local recovery_enabled=$(jq -r '.session_recovery.recovery_enabled' "$CONTEXT_FILE")
        local auto_resume=$(jq -r '.session_recovery.recovery_actions.auto_resume_on_restart' "$CONTEXT_FILE")
        
        if [ "$recovery_enabled" = "true" ] && [ "$auto_resume" = "true" ]; then
            echo "🔄 Auto-recovery enabled. Resuming session..."
            validate_context
            return 0
        fi
    fi
    
    echo "🚀 Starting new session. Initialize with: initialize-github-context.md"
    return 1
}

case "$1" in
    "backup") backup_context ;;
    "restore") restore_context "$2" ;;
    "list") list_backups ;;
    "validate") validate_context ;;
    "auto") auto_recovery ;;
    *) echo "Usage: $0 {backup|restore|list|validate|auto}" ;;
esac
EOF

chmod +x .bmad-project/github/recover-session.sh
```

### Step 8: Integration with .gitignore
```bash
# Add GitHub context files to .gitignore
cat >> .gitignore << 'EOF'

# BMAD GitHub Integration
.bmad-project/github-context.json
.bmad-project/github/sessions/
.bmad-project/github/logs/
.bmad-project/github/backups/
.bmad-project/github/current-session.txt
EOF
```

### Step 9: Validation and Testing
```bash
# Validate context initialization
echo "🔍 Validating GitHub context initialization..."

# Check context file
if [ -f ".bmad-project/github-context.json" ]; then
    echo "✅ GitHub context file created"
    
    # Validate JSON structure
    if jq empty .bmad-project/github-context.json; then
        echo "✅ GitHub context JSON is valid"
    else
        echo "❌ GitHub context JSON is invalid"
        exit 1
    fi
else
    echo "❌ GitHub context file not created"
    exit 1
fi

# Check helper scripts
if [ -x ".bmad-project/github/context-manager.sh" ]; then
    echo "✅ Context manager script created and executable"
else
    echo "❌ Context manager script missing or not executable"
fi

if [ -x ".bmad-project/github/recover-session.sh" ]; then
    echo "✅ Recovery script created and executable"
else
    echo "❌ Recovery script missing or not executable"
fi

# Test basic context operations
echo "🧪 Testing context operations..."

# Test mode update
.bmad-project/github/context-manager.sh update_mode "guided" "Initial mode selection"
CURRENT_MODE=$(.bmad-project/github/context-manager.sh get_mode)

if [ "$CURRENT_MODE" = "guided" ]; then
    echo "✅ Mode update test passed"
else
    echo "❌ Mode update test failed"
fi

# Test sync status check
SYNC_ENABLED=$(.bmad-project/github/context-manager.sh is_sync_enabled)
if [ "$SYNC_ENABLED" = "true" ]; then
    echo "✅ Sync status test passed"
else
    echo "❌ Sync status test failed"
fi

echo ""
echo "🎉 GitHub context initialization completed successfully!"
echo ""
echo "Next steps:"
echo "1. Fetch a GitHub issue: /github:issue-fetch {issue_number}"
echo "2. Start development: /bmadErpNext:agent:development-coordinator"
echo "3. Select execution mode: *select-execution-mode"
echo ""
echo "Context file: .bmad-project/github-context.json"
echo "Session ID: $(jq -r '.github_session.session_id' .bmad-project/github-context.json)"
```

## Success Criteria
- [ ] GitHub context file created with valid JSON structure
- [ ] Session directory structure established
- [ ] Helper scripts created and executable
- [ ] Templates copied and customized
- [ ] Recovery system initialized
- [ ] Basic context operations tested
- [ ] Integration with .gitignore completed

## Error Handling

### GitHub CLI Not Available
```bash
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI required. Install with:"
    echo "  - macOS: brew install gh"
    echo "  - Ubuntu: sudo apt install gh"
    echo "  - Or run: /github:setup"
    exit 1
fi
```

### Authentication Issues
```bash
if ! gh auth status &> /dev/null; then
    echo "❌ GitHub authentication required."
    echo "Run: gh auth login"
    echo "Then retry this task."
    exit 1
fi
```

### Repository Access Issues
```bash
if ! gh repo view &> /dev/null; then
    echo "❌ Repository not accessible."
    echo "Ensure you have access to the repository."
    echo "Check repository URL in config.yaml"
    exit 1
fi
```

### JSON Corruption
```bash
# Automatic backup and recovery
if ! jq empty .bmad-project/github-context.json 2>/dev/null; then
    echo "⚠️ Context file corrupted. Attempting recovery..."
    .bmad-project/github/recover-session.sh auto
fi
```

## Integration Points
This task integrates with:
- `/github:setup` - Prerequisites setup
- `/github:issue-fetch` - Issue context management
- `coordination-workflow` - Execution mode tracking
- `quality-gate-enforcement-workflow` - Quality gate recording
- `parallel-failure-recovery-workflow` - Parallel execution tracking

## Usage Example
```bash
# Initialize GitHub context for new session
initialize-github-context.md

# Output:
# ✅ GitHub context initialized
# Session ID: bmad-20241220-143052
# Ready for GitHub integration
```