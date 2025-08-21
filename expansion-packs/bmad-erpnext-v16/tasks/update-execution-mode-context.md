# Update Execution Mode Context

## Task Description
Update the execution mode context in GitHub and BMAD tracking systems when mode changes occur, ensuring consistent state management across all execution modes.

## Prerequisites
- GitHub context initialized
- Valid execution mode provided
- User authorization for mode change (if applicable)

## Process

### Step 1: Validate Mode Change Request
```bash
# Get parameters
NEW_MODE="${1:-guided}"
CHANGE_REASON="${2:-User selection}"
CHANGE_REQUESTER="${3:-user}"

# Validate new mode
case "$NEW_MODE" in
    "guided"|"sequential"|"smart_parallel")
        echo "✅ Valid execution mode: $NEW_MODE"
        ;;
    *)
        echo "❌ Invalid execution mode: $NEW_MODE"
        echo "Valid modes: guided, sequential, smart_parallel"
        exit 1
        ;;
esac

# Check if GitHub context exists
if [ ! -f ".bmad-project/github-context.json" ]; then
    echo "❌ No GitHub context. Run: initialize-github-context.md"
    exit 1
fi

# Get current mode
CURRENT_MODE=$(jq -r '.execution_context.current_mode' .bmad-project/github-context.json)
CURRENT_ISSUE=$(jq -r '.github_session.current_issue.number' .bmad-project/github-context.json)

echo "🔄 Mode Change Request:"
echo "  From: $CURRENT_MODE"
echo "  To: $NEW_MODE"
echo "  Reason: $CHANGE_REASON"
echo "  Requester: $CHANGE_REQUESTER"
```

### Step 2: Check Mode Transition Rules
```bash
# Load execution mode rules
EXECUTION_RULES_FILE=".bmad-erpnext-v16/data/execution-mode-rules.yaml"

# Check if transition is allowed
check_transition_validity() {
    local from_mode="$1"
    local to_mode="$2"
    
    # If same mode, no transition needed
    if [ "$from_mode" = "$to_mode" ]; then
        echo "ℹ️ Already in $to_mode mode"
        return 1
    fi
    
    # Check transition rules
    case "$from_mode" in
        "guided")
            # Guided can transition to any mode anytime
            return 0
            ;;
        "sequential")
            # Sequential can transition between stories or batches
            ACTIVE_STORIES=$(jq -r '.story_tracking.active_stories | length' .bmad-project/github-context.json)
            if [ "$ACTIVE_STORIES" -eq 0 ]; then
                return 0
            else
                echo "⚠️ Cannot change mode during active sequential processing"
                echo "Wait for current batch to complete or manually stop processing"
                return 1
            fi
            ;;
        "smart_parallel")
            # Parallel can transition on failure or between blocks
            ACTIVE_PARALLEL=$(jq -r '.parallel_execution.enabled' .bmad-project/github-context.json)
            CURRENT_BLOCK=$(jq -r '.parallel_execution.current_block' .bmad-project/github-context.json)
            
            if [ "$ACTIVE_PARALLEL" = "true" ] && [ "$CURRENT_BLOCK" != "null" ]; then
                echo "⚠️ Cannot change mode during active parallel execution"
                echo "Wait for current block to complete or handle parallel failure"
                return 1
            else
                return 0
            fi
            ;;
    esac
}

if ! check_transition_validity "$CURRENT_MODE" "$NEW_MODE"; then
    exit 1
fi

echo "✅ Mode transition allowed"
```

### Step 3: Check Current Work State
```bash
# Assess current work state before mode change
assess_work_state() {
    local current_mode="$1"
    
    # Count active work
    ACTIVE_STORIES=$(jq -r '.story_tracking.active_stories | length' .bmad-project/github-context.json)
    ACTIVE_AGENTS=$(jq -r '.agent_execution.active_agents | length' .bmad-project/github-context.json)
    PARALLEL_ENABLED=$(jq -r '.parallel_execution.enabled' .bmad-project/github-context.json)
    
    echo "📊 Current Work State:"
    echo "  Active Stories: $ACTIVE_STORIES"
    echo "  Active Agents: $ACTIVE_AGENTS"
    echo "  Parallel Execution: $PARALLEL_ENABLED"
    
    # Check for work in progress
    if [ "$ACTIVE_STORIES" -gt 0 ] || [ "$ACTIVE_AGENTS" -gt 0 ]; then
        echo "⚠️ Work in progress detected"
        
        # Mode-specific work handling
        case "$current_mode" in
            "guided")
                echo "📋 Guided mode work will be preserved"
                WORK_PRESERVATION="guided_state_preserved"
                ;;
            "sequential")
                echo "📦 Sequential batch will be paused"
                WORK_PRESERVATION="sequential_batch_paused"
                ;;
            "smart_parallel")
                echo "🔀 Parallel execution will be gracefully stopped"
                WORK_PRESERVATION="parallel_execution_stopped"
                ;;
        esac
    else
        echo "✅ No active work - safe to change modes"
        WORK_PRESERVATION="no_active_work"
    fi
}

assess_work_state "$CURRENT_MODE"
```

### Step 4: Prepare Mode-Specific Configuration
```bash
# Load mode-specific settings for new mode
prepare_mode_config() {
    local new_mode="$1"
    
    case "$new_mode" in
        "guided")
            SYNC_FREQUENCY="on_user_approval"
            COMMENT_DETAIL="high"
            USER_INTERACTION="required"
            AUTOMATION_LEVEL="minimal"
            QUALITY_GATE_FREQUENCY="after_each_agent"
            EXPECTED_THROUGHPUT="1 story per session"
            ;;
        "sequential")
            SYNC_FREQUENCY="on_batch_completion"
            COMMENT_DETAIL="medium"
            USER_INTERACTION="minimal"
            AUTOMATION_LEVEL="high"
            QUALITY_GATE_FREQUENCY="after_each_story"
            EXPECTED_THROUGHPUT="3-7 stories per session"
            ;;
        "smart_parallel")
            SYNC_FREQUENCY="on_block_completion"
            COMMENT_DETAIL="high_with_metrics"
            USER_INTERACTION="on_conflicts"
            AUTOMATION_LEVEL="highest"
            QUALITY_GATE_FREQUENCY="after_each_block"
            EXPECTED_THROUGHPUT="5-15 stories per session"
            ;;
    esac
    
    echo "🔧 Mode Configuration for $new_mode:"
    echo "  Sync Frequency: $SYNC_FREQUENCY"
    echo "  Comment Detail: $COMMENT_DETAIL"
    echo "  User Interaction: $USER_INTERACTION"
    echo "  Automation Level: $AUTOMATION_LEVEL"
    echo "  Quality Gates: $QUALITY_GATE_FREQUENCY"
    echo "  Throughput: $EXPECTED_THROUGHPUT"
}

prepare_mode_config "$NEW_MODE"
```

### Step 5: Execute Mode Transition
```bash
# Gracefully stop current mode operations
stop_current_mode_operations() {
    local current_mode="$1"
    
    case "$current_mode" in
        "guided")
            echo "🛑 Guided mode: Completing current user interaction"
            # No special stopping needed for guided mode
            ;;
        "sequential")
            echo "🛑 Sequential mode: Pausing batch processing"
            # Mark current batch as paused
            jq '.story_tracking.batch_status = "paused" |
                .story_tracking.pause_reason = "mode_change_requested"' \
               .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
               mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
            ;;
        "smart_parallel")
            echo "🛑 Parallel mode: Gracefully stopping parallel execution"
            # Disable parallel execution and wait for current agents
            jq '.parallel_execution.enabled = false |
                .parallel_execution.stop_reason = "mode_change_requested" |
                .parallel_execution.graceful_stop = true' \
               .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
               mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
            ;;
    esac
}

stop_current_mode_operations "$CURRENT_MODE"

# Update execution mode in context
TIMESTAMP=$(date -Iseconds)

jq --arg new_mode "$NEW_MODE" --arg reason "$CHANGE_REASON" --arg requester "$CHANGE_REQUESTER" \
   --arg timestamp "$TIMESTAMP" \
   '.execution_context.current_mode = $new_mode |
    .execution_context.mode_selected_at = $timestamp |
    .execution_context.mode_selected_by = $requester |
    .execution_context.mode_selection_reason = $reason |
    .execution_context.mode_settings[$new_mode].sync_frequency = "'$SYNC_FREQUENCY'" |
    .execution_context.mode_settings[$new_mode].comment_detail = "'$COMMENT_DETAIL'" |
    .execution_context.mode_settings[$new_mode].user_interaction = "'$USER_INTERACTION'"' \
   .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
   mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json

echo "✅ Execution mode updated to: $NEW_MODE"
```

### Step 6: Initialize New Mode State
```bash
# Initialize state for new mode
initialize_new_mode() {
    local new_mode="$1"
    
    case "$new_mode" in
        "guided")
            echo "🎯 Initializing guided mode state"
            # Reset user interaction tracking
            jq '.execution_context.guided_mode_state = {
                "user_approvals_given": 0,
                "learning_mode_enabled": true,
                "detailed_explanations": true,
                "step_by_step_progress": true
            }' .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
            mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
            ;;
        "sequential")
            echo "⚡ Initializing sequential mode state"
            # Setup batch processing state
            jq '.execution_context.sequential_mode_state = {
                "batch_size": 3,
                "auto_retry_enabled": true,
                "pause_on_critical_failure": true,
                "batch_reporting_enabled": true
            }' .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
            mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
            ;;
        "smart_parallel")
            echo "🔀 Initializing smart parallel mode state"
            # Setup parallel execution state
            jq '.parallel_execution = {
                "enabled": true,
                "max_parallel_agents": 5,
                "conflict_detection_enabled": true,
                "auto_fallback_enabled": true,
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
            }' .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
            mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
            ;;
    esac
}

initialize_new_mode "$NEW_MODE"
```

### Step 7: Update Session Recovery Configuration
```bash
# Update session recovery to preserve new mode
jq --arg new_mode "$NEW_MODE" \
   '.session_recovery.recovery_actions.restore_execution_mode = true |
    .session_recovery.recovery_data.execution_mode_at_checkpoint = $new_mode' \
   .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
   mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json

# Create checkpoint
.bmad-project/github/context-manager.sh update_mode "$NEW_MODE" "$CHANGE_REASON"

echo "💾 Session recovery updated for $NEW_MODE mode"
```

### Step 8: Sync Mode Change to GitHub
```bash
# Sync mode change to GitHub if enabled and issue is available
SYNC_ENABLED=$(jq -r '.github_session.integration_config.sync_enabled' .bmad-project/github-context.json)

if [ "$SYNC_ENABLED" = "true" ] && [ "$CURRENT_ISSUE" != "null" ]; then
    echo "📤 Syncing mode change to GitHub..."
    
    # Create mode change notification
    MODE_CHANGE_COMMENT="## 🔄 Execution Mode Changed

**Previous Mode**: $CURRENT_MODE
**New Mode**: $NEW_MODE
**Changed By**: $CHANGE_REQUESTER
**Reason**: $CHANGE_REASON
**Timestamp**: $TIMESTAMP

### Mode Configuration
- **Sync Frequency**: $SYNC_FREQUENCY
- **User Interaction**: $USER_INTERACTION
- **Automation Level**: $AUTOMATION_LEVEL
- **Expected Throughput**: $EXPECTED_THROUGHPUT

### Work State Preservation
$WORK_PRESERVATION

### What to Expect
$(case "$NEW_MODE" in
    "guided")
        echo "- Interactive development with user approval at each step"
        echo "- Detailed explanations and learning opportunities"
        echo "- High quality assurance with user oversight"
        ;;
    "sequential")
        echo "- Automated batch processing of multiple stories"
        echo "- Periodic progress updates"
        echo "- Automatic error handling with escalation"
        ;;
    "smart_parallel")
        echo "- Intelligent parallel execution of independent work"
        echo "- Real-time conflict detection and resolution"
        echo "- Maximum efficiency with sophisticated monitoring"
        ;;
esac)

---
*Mode change by BMAD ERPNext v16 • [Claude Code](https://claude.ai/code)*"

    # Post mode change notification
    if gh issue comment "$CURRENT_ISSUE" --body "$MODE_CHANGE_COMMENT" >/dev/null 2>&1; then
        echo "✅ Mode change synced to GitHub issue #$CURRENT_ISSUE"
        
        # Update sync status
        jq --arg timestamp "$TIMESTAMP" \
           '.sync_status.last_sync_time = $timestamp |
            .sync_status.total_syncs += 1 |
            .sync_status.successful_syncs += 1' \
           .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
           mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
    else
        echo "⚠️ Failed to sync mode change to GitHub"
    fi
fi
```

### Step 9: Update Workflow State
```bash
# Update coordination workflow state for new mode
update_workflow_state() {
    local new_mode="$1"
    
    # Set workflow flags based on mode
    case "$new_mode" in
        "guided")
            WORKFLOW_FLAGS="user_approval_required interactive_mode detailed_logging"
            ;;
        "sequential")
            WORKFLOW_FLAGS="batch_processing auto_retry periodic_checkpoints"
            ;;
        "smart_parallel")
            WORKFLOW_FLAGS="parallel_execution conflict_monitoring dynamic_recovery"
            ;;
    esac
    
    # Update context with workflow flags
    jq --arg flags "$WORKFLOW_FLAGS" \
       '.execution_context.workflow_flags = ($flags | split(" "))' \
       .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
       mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
    
    echo "🔧 Workflow state updated for $new_mode mode"
    echo "   Flags: $WORKFLOW_FLAGS"
}

update_workflow_state "$NEW_MODE"
```

### Step 10: Record Mode Change History
```bash
# Record mode change in history
jq --arg from_mode "$CURRENT_MODE" --arg to_mode "$NEW_MODE" --arg reason "$CHANGE_REASON" \
   --arg requester "$CHANGE_REQUESTER" --arg timestamp "$TIMESTAMP" \
   '.execution_context.mode_change_history += [{
       "from_mode": $from_mode,
       "to_mode": $to_mode,
       "changed_by": $requester,
       "reason": $reason,
       "timestamp": $timestamp,
       "work_state": "'$WORK_PRESERVATION'"
   }]' \
   .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
   mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json

# Log mode change
echo "$(date): Mode changed from $CURRENT_MODE to $NEW_MODE by $CHANGE_REQUESTER - Reason: $CHANGE_REASON" >> .bmad-project/github/logs/mode-changes.log

# Update session metrics
jq '.metrics.performance.mode_changes = (.metrics.performance.mode_changes // 0) + 1' \
   .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
   mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
```

### Step 11: Provide Mode-Specific Guidance
```bash
# Provide guidance for using the new mode
provide_mode_guidance() {
    local new_mode="$1"
    
    echo ""
    echo "🎯 $NEW_MODE Mode Guidance:"
    echo ""
    
    case "$new_mode" in
        "guided")
            echo "📋 Guided Mode - Interactive Development"
            echo "  • Each step requires your approval"
            echo "  • Detailed explanations provided"
            echo "  • High quality assurance"
            echo "  • Learning opportunities highlighted"
            echo ""
            echo "Next steps:"
            echo "  1. Review current work state"
            echo "  2. Approve next development step"
            echo "  3. Monitor quality gates interactively"
            ;;
        "sequential")
            echo "⚡ Sequential Mode - Batch Processing"
            echo "  • Automated story processing"
            echo "  • Periodic progress updates"
            echo "  • Automatic error handling"
            echo "  • Batch completion reports"
            echo ""
            echo "Next steps:"
            echo "  1. Define story queue"
            echo "  2. Approve batch execution"
            echo "  3. Monitor batch progress"
            ;;
        "smart_parallel")
            echo "🔀 Smart Parallel Mode - Intelligent Execution"
            echo "  • Parallel agent execution"
            echo "  • Real-time conflict detection"
            echo "  • Automatic recovery strategies"
            echo "  • Performance optimization"
            echo ""
            echo "Next steps:"
            echo "  1. Analyze parallel potential"
            echo "  2. Create execution blocks"
            echo "  3. Monitor parallel execution"
            ;;
    esac
}

provide_mode_guidance "$NEW_MODE"
```

### Step 12: Validate Mode Change Success
```bash
# Validate that mode change was successful
UPDATED_MODE=$(jq -r '.execution_context.current_mode' .bmad-project/github-context.json)
MODE_SELECTED_AT=$(jq -r '.execution_context.mode_selected_at' .bmad-project/github-context.json)

if [ "$UPDATED_MODE" = "$NEW_MODE" ] && [ "$MODE_SELECTED_AT" != "null" ]; then
    echo "✅ Mode change successful"
    echo ""
    echo "📊 Mode Change Summary:"
    echo "  Previous Mode: $CURRENT_MODE"
    echo "  Current Mode: $UPDATED_MODE"
    echo "  Changed At: $MODE_SELECTED_AT"
    echo "  Changed By: $CHANGE_REQUESTER"
    echo "  Reason: $CHANGE_REASON"
    echo "  Work Preservation: $WORK_PRESERVATION"
    echo "  GitHub Sync: $([ "$SYNC_ENABLED" = "true" ] && echo "Enabled" || echo "Disabled")"
    echo ""
    echo "🎉 Ready to continue with $NEW_MODE mode!"
else
    echo "❌ Mode change failed"
    echo "Expected: $NEW_MODE, Actual: $UPDATED_MODE"
    exit 1
fi
```

## Success Criteria
- [ ] Mode transition validated as allowed
- [ ] Current work state assessed and preserved
- [ ] New mode configuration applied
- [ ] GitHub context updated successfully
- [ ] Mode change synced to GitHub (if enabled)
- [ ] Workflow state updated
- [ ] Mode change history recorded
- [ ] Mode-specific guidance provided

## Error Handling

### Invalid Mode Transition
```bash
if ! check_transition_validity "$CURRENT_MODE" "$NEW_MODE"; then
    echo "❌ Mode transition not allowed"
    echo "Current mode: $CURRENT_MODE"
    echo "Requested mode: $NEW_MODE"
    echo "Wait for current work to complete"
    exit 1
fi
```

### Active Work Blocking
```bash
if [ "$ACTIVE_WORK_BLOCKING" = "true" ]; then
    echo "⚠️ Active work prevents mode change"
    echo "Options:"
    echo "  1. Wait for current work to complete"
    echo "  2. Manually stop current work"
    echo "  3. Force mode change (may lose work)"
    exit 1
fi
```

### GitHub Sync Failure
```bash
if [ $? -ne 0 ]; then
    echo "⚠️ Mode changed locally but GitHub sync failed"
    echo "Mode change recorded in local context"
    echo "Retry GitHub sync manually if needed"
    # Continue - mode change was successful locally
fi
```

### Context Corruption
```bash
if ! jq empty .bmad-project/github-context.json; then
    echo "❌ GitHub context corrupted during mode change"
    echo "Attempting recovery..."
    .bmad-project/github/recover-session.sh auto
fi
```

## Integration Points
This task integrates with:
- `coordination-workflow.yaml` - Mode selection and transitions
- `initialize-github-context.md` - Context management
- `sync-github-progress.md` - GitHub synchronization
- All execution mode workflows - State management
- Quality gate enforcement - Mode-specific handling

## Usage Examples

### Manual Mode Change
```bash
# Change to guided mode
update-execution-mode-context.md guided "User prefers interactive development" user

# Change to sequential mode
update-execution-mode-context.md sequential "Batch processing requested" user

# Change to parallel mode
update-execution-mode-context.md smart_parallel "Large epic optimization" user
```

### Automatic Mode Change
```bash
# Called by coordination workflow
update-execution-mode-context.md sequential "Automatic optimization for multiple stories" system

# Called by failure recovery
update-execution-mode-context.md guided "Parallel execution failed, falling back" system
```

### Emergency Mode Change
```bash
# Force mode change during issues
update-execution-mode-context.md guided "Emergency troubleshooting required" user --force
```