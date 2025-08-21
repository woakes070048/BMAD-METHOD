# Sync GitHub Progress

## Task Description
Sync development progress to GitHub issues using mode-aware templates and intelligent update strategies based on execution mode and progress milestones.

## Prerequisites
- Active GitHub context (github-context.json)
- GitHub CLI authenticated
- Mode-specific sync templates available
- Current story or work in progress

## Process

### Step 1: Validate GitHub Context
```bash
# Check if GitHub context exists
if [ ! -f ".bmad-project/github-context.json" ]; then
    echo "❌ No GitHub context. Run: initialize-github-context.md"
    exit 1
fi

# Validate context file
if ! jq empty .bmad-project/github-context.json; then
    echo "❌ GitHub context corrupted. Run: .bmad-project/github/recover-session.sh validate"
    exit 1
fi

# Check if sync is enabled
SYNC_ENABLED=$(jq -r '.github_session.integration_config.sync_enabled' .bmad-project/github-context.json)
if [ "$SYNC_ENABLED" != "true" ]; then
    echo "ℹ️ GitHub sync disabled in context"
    exit 0
fi

# Get current issue
CURRENT_ISSUE=$(jq -r '.github_session.current_issue.number' .bmad-project/github-context.json)
if [ "$CURRENT_ISSUE" = "null" ] || [ -z "$CURRENT_ISSUE" ]; then
    echo "⚠️ No current GitHub issue set. Fetch issue first: /github:issue-fetch {number}"
    exit 1
fi

echo "✅ GitHub context validated"
echo "Current issue: #${CURRENT_ISSUE}"
```

### Step 2: Determine Sync Type and Template
```bash
# Get execution mode and sync settings
EXECUTION_MODE=$(jq -r '.execution_context.current_mode' .bmad-project/github-context.json)
SYNC_FREQUENCY=$(jq -r --arg mode "$EXECUTION_MODE" '.execution_context.mode_settings[$mode].sync_frequency' .bmad-project/github-context.json)
COMMENT_DETAIL=$(jq -r --arg mode "$EXECUTION_MODE" '.execution_context.mode_settings[$mode].comment_detail' .bmad-project/github-context.json)

# Determine sync type based on trigger
SYNC_TYPE="${1:-progress_update}"  # Default to progress update

echo "📊 Sync Configuration:"
echo "  Mode: $EXECUTION_MODE"
echo "  Frequency: $SYNC_FREQUENCY"
echo "  Detail Level: $COMMENT_DETAIL"
echo "  Sync Type: $SYNC_TYPE"
```

### Step 3: Gather Progress Data
```bash
# Gather mode-specific progress data
case "$EXECUTION_MODE" in
    "guided")
        # Guided mode progress data
        CURRENT_AGENT=$(jq -r '.agent_execution.active_agents[-1].agent_id // "none"' .bmad-project/github-context.json)
        CURRENT_TASK=$(jq -r '.agent_execution.active_agents[-1].task // "none"' .bmad-project/github-context.json)
        COMPLETED_AGENTS=$(jq -r '.agent_execution.completed_agents | length' .bmad-project/github-context.json)
        TOTAL_GATES=$(jq -r '.quality_gates.total_gates_run' .bmad-project/github-context.json)
        GATES_PASSED=$(jq -r '.quality_gates.gates_passed' .bmad-project/github-context.json)
        
        # Get latest user interaction if available
        USER_DECISION="${USER_DECISION:-Pending user review}"
        APPROVAL_POINT="${APPROVAL_POINT:-Quality gate validation}"
        ;;
        
    "sequential")
        # Sequential mode progress data
        ACTIVE_STORIES=$(jq -r '.story_tracking.active_stories | length' .bmad-project/github-context.json)
        COMPLETED_STORIES=$(jq -r '.story_tracking.completed_stories | length' .bmad-project/github-context.json)
        TOTAL_STORIES=$(jq -r '(.story_tracking.active_stories | length) + (.story_tracking.completed_stories | length)' .bmad-project/github-context.json)
        
        # Calculate processing speed
        SESSION_START=$(jq -r '.progress_tracking.session_started_at' .bmad-project/github-context.json)
        CURRENT_TIME=$(date -Iseconds)
        
        if [ "$SESSION_START" != "null" ]; then
            SESSION_DURATION=$(( $(date -d "$CURRENT_TIME" +%s) - $(date -d "$SESSION_START" +%s) ))
            HOURS_ELAPSED=$(echo "scale=2; $SESSION_DURATION / 3600" | bc -l)
            if [ "$COMPLETED_STORIES" -gt 0 ] && [ "$(echo "$HOURS_ELAPSED > 0" | bc -l)" -eq 1 ]; then
                STORIES_PER_HOUR=$(echo "scale=1; $COMPLETED_STORIES / $HOURS_ELAPSED" | bc -l)
            else
                STORIES_PER_HOUR="calculating..."
            fi
        else
            STORIES_PER_HOUR="calculating..."
        fi
        ;;
        
    "smart_parallel")
        # Parallel mode progress data
        CURRENT_BLOCK=$(jq -r '.parallel_execution.current_block // "none"' .bmad-project/github-context.json)
        TOTAL_BLOCKS=$(jq -r '.parallel_execution.total_blocks' .bmad-project/github-context.json)
        COMPLETED_BLOCKS=$(jq -r '.parallel_execution.completed_blocks' .bmad-project/github-context.json)
        CONFLICTS_DETECTED=$(jq -r '.parallel_execution.conflict_tracking.total_conflicts' .bmad-project/github-context.json)
        CONFLICTS_RESOLVED=$(jq -r '.parallel_execution.conflict_tracking.resolved_conflicts' .bmad-project/github-context.json)
        
        # Calculate efficiency metrics
        PARALLEL_TIME=$(jq -r '.parallel_execution.performance_metrics.actual_execution_time // "calculating..."' .bmad-project/github-context.json)
        SEQUENTIAL_ESTIMATE=$(jq -r '.parallel_execution.performance_metrics.sequential_time_estimate // "calculating..."' .bmad-project/github-context.json)
        EFFICIENCY_GAIN=$(jq -r '.parallel_execution.performance_metrics.efficiency_gain // "calculating..."' .bmad-project/github-context.json)
        ;;
esac

# Common progress data
SESSION_ID=$(jq -r '.github_session.session_id' .bmad-project/github-context.json)
TIMESTAMP=$(date -Iseconds)
STORY_TITLE=$(jq -r '.github_session.current_issue.title // "Development Work"' .bmad-project/github-context.json)
```

### Step 4: Load and Process Template
```bash
# Load appropriate template based on mode and sync type
TEMPLATE_FILE=".bmad-erpnext-v16/templates/mode-specific-sync-templates.yaml"

# Determine template path
case "$EXECUTION_MODE" in
    "guided")
        case "$SYNC_TYPE" in
            "progress_update") TEMPLATE_PATH="guided_mode.interactive_progress" ;;
            "quality_gate") TEMPLATE_PATH="guided_mode.quality_gate_review" ;;
            "completion") TEMPLATE_PATH="guided_mode.completion_summary" ;;
            *) TEMPLATE_PATH="guided_mode.interactive_progress" ;;
        esac
        ;;
    "sequential")
        case "$SYNC_TYPE" in
            "progress_update") TEMPLATE_PATH="sequential_mode.batch_progress" ;;
            "batch_completion") TEMPLATE_PATH="sequential_mode.batch_completion" ;;
            "completion") TEMPLATE_PATH="sequential_mode.sequential_completion" ;;
            *) TEMPLATE_PATH="sequential_mode.batch_progress" ;;
        esac
        ;;
    "smart_parallel")
        case "$SYNC_TYPE" in
            "progress_update") TEMPLATE_PATH="smart_parallel_mode.parallel_block_progress" ;;
            "conflict_alert") TEMPLATE_PATH="smart_parallel_mode.conflict_alert" ;;
            "completion") TEMPLATE_PATH="smart_parallel_mode.parallel_completion" ;;
            *) TEMPLATE_PATH="smart_parallel_mode.parallel_block_progress" ;;
        esac
        ;;
esac

# Extract template content
TEMPLATE_CONTENT=$(yq eval ".${TEMPLATE_PATH}.template" "$TEMPLATE_FILE")

if [ "$TEMPLATE_CONTENT" = "null" ] || [ -z "$TEMPLATE_CONTENT" ]; then
    echo "❌ Template not found: $TEMPLATE_PATH"
    exit 1
fi

echo "📝 Using template: $TEMPLATE_PATH"
```

### Step 5: Substitute Template Variables
```bash
# Create variable substitution function
substitute_variables() {
    local content="$1"
    
    # Common variables
    content=$(echo "$content" | sed "s/\${SESSION_ID}/$SESSION_ID/g")
    content=$(echo "$content" | sed "s/\${TIMESTAMP}/$TIMESTAMP/g")
    content=$(echo "$content" | sed "s/\${EXECUTION_MODE}/$EXECUTION_MODE/g")
    content=$(echo "$content" | sed "s/\${STORY_TITLE}/$STORY_TITLE/g")
    content=$(echo "$content" | sed "s/\${CURRENT_ISSUE}/$CURRENT_ISSUE/g")
    
    # Mode-specific variables
    case "$EXECUTION_MODE" in
        "guided")
            content=$(echo "$content" | sed "s/\${CURRENT_AGENT}/$CURRENT_AGENT/g")
            content=$(echo "$content" | sed "s/\${CURRENT_TASK}/$CURRENT_TASK/g")
            content=$(echo "$content" | sed "s/\${COMPLETED_AGENTS}/$COMPLETED_AGENTS/g")
            content=$(echo "$content" | sed "s/\${GATES_PASSED}/$GATES_PASSED/g")
            content=$(echo "$content" | sed "s/\${TOTAL_GATES}/$TOTAL_GATES/g")
            content=$(echo "$content" | sed "s/\${USER_DECISION}/$USER_DECISION/g")
            content=$(echo "$content" | sed "s/\${APPROVAL_POINT}/$APPROVAL_POINT/g")
            ;;
        "sequential")
            content=$(echo "$content" | sed "s/\${COMPLETED_STORIES}/$COMPLETED_STORIES/g")
            content=$(echo "$content" | sed "s/\${TOTAL_STORIES}/$TOTAL_STORIES/g")
            content=$(echo "$content" | sed "s/\${STORIES_PER_HOUR}/$STORIES_PER_HOUR/g")
            ;;
        "smart_parallel")
            content=$(echo "$content" | sed "s/\${CURRENT_BLOCK}/$CURRENT_BLOCK/g")
            content=$(echo "$content" | sed "s/\${COMPLETED_BLOCKS}/$COMPLETED_BLOCKS/g")
            content=$(echo "$content" | sed "s/\${TOTAL_BLOCKS}/$TOTAL_BLOCKS/g")
            content=$(echo "$content" | sed "s/\${CONFLICTS_DETECTED}/$CONFLICTS_DETECTED/g")
            content=$(echo "$content" | sed "s/\${CONFLICTS_RESOLVED}/$CONFLICTS_RESOLVED/g")
            content=$(echo "$content" | sed "s/\${EFFICIENCY_GAIN}/$EFFICIENCY_GAIN/g")
            ;;
    esac
    
    # Replace remaining placeholders with defaults
    content=$(echo "$content" | sed 's/\${[^}]*}//g')
    
    echo "$content"
}

# Process template
COMMENT_BODY=$(substitute_variables "$TEMPLATE_CONTENT")
```

### Step 6: Check Rate Limiting
```bash
# Check GitHub API rate limits
check_rate_limit() {
    local rate_info=$(gh api rate_limit)
    local remaining=$(echo "$rate_info" | jq -r '.rate.remaining')
    local reset_time=$(echo "$rate_info" | jq -r '.rate.reset')
    
    # Update context with rate limit info
    jq --arg remaining "$remaining" --arg reset_time "$reset_time" --arg timestamp "$TIMESTAMP" \
       '.sync_status.rate_limiting.requests_remaining = ($remaining | tonumber) |
        .sync_status.rate_limiting.reset_time = $reset_time |
        .sync_status.rate_limiting.last_rate_limit_check = $timestamp' \
       .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
       mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
    
    if [ "$remaining" -lt 10 ]; then
        echo "⚠️ GitHub API rate limit low: $remaining requests remaining"
        echo "Reset time: $(date -d @$reset_time)"
        
        # Check if this is a high-priority sync
        case "$SYNC_TYPE" in
            "conflict_alert"|"escalation"|"quality_gate_failure")
                echo "🚨 High priority sync - proceeding despite rate limit"
                return 0
                ;;
            *)
                echo "⏸️ Delaying sync due to rate limit"
                return 1
                ;;
        esac
    fi
    
    return 0
}

if ! check_rate_limit; then
    # Schedule sync for later
    echo "📅 Sync scheduled for after rate limit reset"
    exit 0
fi
```

### Step 7: Check Sync Frequency Rules
```bash
# Check if enough time has passed for this sync type
check_sync_timing() {
    local last_sync=$(jq -r '.sync_status.last_sync_time' .bmad-project/github-context.json)
    
    if [ "$last_sync" = "null" ]; then
        return 0  # First sync
    fi
    
    local current_time=$(date +%s)
    local last_sync_time=$(date -d "$last_sync" +%s)
    local time_diff=$((current_time - last_sync_time))
    
    # Minimum intervals by sync type (in seconds)
    case "$SYNC_TYPE" in
        "progress_update")
            case "$EXECUTION_MODE" in
                "guided") MIN_INTERVAL=300 ;;      # 5 minutes
                "sequential") MIN_INTERVAL=900 ;;  # 15 minutes
                "smart_parallel") MIN_INTERVAL=120 ;; # 2 minutes
            esac
            ;;
        "quality_gate"|"conflict_alert"|"escalation")
            MIN_INTERVAL=0  # Immediate sync for important events
            ;;
        "completion")
            MIN_INTERVAL=0  # Always sync completion
            ;;
        *)
            MIN_INTERVAL=300  # Default 5 minutes
            ;;
    esac
    
    if [ $time_diff -lt $MIN_INTERVAL ]; then
        echo "⏸️ Sync throttled: ${time_diff}s < ${MIN_INTERVAL}s minimum interval"
        return 1
    fi
    
    return 0
}

if ! check_sync_timing; then
    exit 0
fi
```

### Step 8: Post Comment to GitHub
```bash
# Post comment to GitHub issue
echo "📤 Posting update to GitHub issue #${CURRENT_ISSUE}..."

# Use heredoc to handle multi-line content properly
COMMENT_RESULT=$(gh issue comment "$CURRENT_ISSUE" --body "$(cat <<EOF
$COMMENT_BODY
EOF
)")

if [ $? -eq 0 ]; then
    # Extract comment ID from result
    COMMENT_ID=$(echo "$COMMENT_RESULT" | grep -o 'issuecomment-[0-9]*' | head -1)
    
    echo "✅ GitHub sync successful"
    echo "💬 Comment posted: $COMMENT_ID"
    
    # Update sync status in context
    jq --arg sync_type "$SYNC_TYPE" --arg status "success" --arg comment_id "$COMMENT_ID" \
       --arg timestamp "$TIMESTAMP" \
       '.sync_status.last_sync_time = $timestamp |
        .sync_status.total_syncs += 1 |
        .sync_status.successful_syncs += 1 |
        .sync_status.rate_limiting.requests_made += 1' \
       .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
       mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
    
    # Log sync success
    echo "$(date): Sync successful - Type: $SYNC_TYPE, Comment: $COMMENT_ID" >> .bmad-project/github/logs/sync.log
    
else
    echo "❌ GitHub sync failed"
    
    # Update failed sync count
    jq --arg timestamp "$TIMESTAMP" \
       '.sync_status.failed_syncs += 1' \
       .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
       mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
    
    # Log sync failure
    echo "$(date): Sync failed - Type: $SYNC_TYPE, Error: GitHub API error" >> .bmad-project/github/logs/sync.log
    
    exit 1
fi
```

### Step 9: Update Context and Metrics
```bash
# Update progress milestones if applicable
case "$SYNC_TYPE" in
    "completion")
        jq '.progress_tracking.milestones.github_syncs_completed += 1' \
           .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
           mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
        ;;
    "quality_gate")
        if [ "$GATE_RESULT" = "passed" ]; then
            jq '.progress_tracking.milestones.quality_gates_passed += 1' \
               .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
               mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
        fi
        ;;
esac

# Update last activity timestamp
jq --arg timestamp "$TIMESTAMP" \
   '.progress_tracking.last_activity_at = $timestamp' \
   .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
   mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json

# Calculate sync success rate
TOTAL_SYNCS=$(jq -r '.sync_status.total_syncs' .bmad-project/github-context.json)
SUCCESSFUL_SYNCS=$(jq -r '.sync_status.successful_syncs' .bmad-project/github-context.json)

if [ "$TOTAL_SYNCS" -gt 0 ]; then
    SYNC_SUCCESS_RATE=$(echo "scale=1; $SUCCESSFUL_SYNCS * 100 / $TOTAL_SYNCS" | bc -l)
    
    jq --arg rate "$SYNC_SUCCESS_RATE" \
       '.metrics.github_integration.sync_success_rate = ($rate | tonumber)' \
       .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
       mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
fi
```

### Step 10: Post-Sync Actions
```bash
# Mode-specific post-sync actions
case "$EXECUTION_MODE" in
    "guided")
        echo "👤 Guided mode: User can review comment and provide feedback"
        ;;
    "sequential")
        echo "⚡ Sequential mode: Continuing batch processing"
        ;;
    "smart_parallel")
        if [ "$SYNC_TYPE" = "conflict_alert" ]; then
            echo "🔀 Parallel mode: Conflict reported, monitoring resolution"
        else
            echo "🔀 Parallel mode: Parallel execution continuing"
        fi
        ;;
esac

# Create sync summary
echo ""
echo "📊 Sync Summary:"
echo "  Issue: #${CURRENT_ISSUE}"
echo "  Mode: ${EXECUTION_MODE}"
echo "  Type: ${SYNC_TYPE}"
echo "  Template: ${TEMPLATE_PATH}"
echo "  Success Rate: ${SYNC_SUCCESS_RATE:-N/A}%"
echo "  Total Syncs: ${TOTAL_SYNCS}"
echo ""

# Suggest next actions
case "$SYNC_TYPE" in
    "progress_update")
        echo "Next: Continue development work"
        ;;
    "quality_gate")
        if [ "$GATE_RESULT" = "failed" ]; then
            echo "Next: Address quality gate failure"
        else
            echo "Next: Proceed to next development step"
        fi
        ;;
    "completion")
        echo "Next: Review completed work and plan next steps"
        ;;
    "conflict_alert")
        echo "Next: Monitor conflict resolution"
        ;;
esac
```

## Success Criteria
- [ ] GitHub context validated and sync enabled
- [ ] Appropriate template selected based on execution mode
- [ ] Progress data gathered accurately
- [ ] Template variables substituted correctly
- [ ] Rate limiting checked and respected
- [ ] Comment posted successfully to GitHub issue
- [ ] Context updated with sync status
- [ ] Metrics calculated and stored

## Error Handling

### Missing GitHub Context
```bash
if [ ! -f ".bmad-project/github-context.json" ]; then
    echo "❌ No GitHub context found"
    echo "Initialize with: initialize-github-context.md"
    exit 1
fi
```

### No Current Issue
```bash
if [ "$CURRENT_ISSUE" = "null" ]; then
    echo "⚠️ No current GitHub issue"
    echo "Fetch issue with: /github:issue-fetch {issue_number}"
    echo "Or disable sync in context"
    exit 1
fi
```

### Template Not Found
```bash
if [ "$TEMPLATE_CONTENT" = "null" ]; then
    echo "❌ Template not found: $TEMPLATE_PATH"
    echo "Using fallback basic template..."
    COMMENT_BODY="## Development Progress Update\n\nMode: $EXECUTION_MODE\nTimestamp: $TIMESTAMP\n\nWork in progress..."
fi
```

### Rate Limit Exceeded
```bash
if [ "$remaining" -lt 1 ]; then
    echo "🚫 GitHub API rate limit exceeded"
    echo "Reset time: $(date -d @$reset_time)"
    echo "Sync will be retried after reset"
    exit 1
fi
```

### GitHub API Error
```bash
if [ $? -ne 0 ]; then
    echo "❌ GitHub API error during sync"
    echo "Check authentication: gh auth status"
    echo "Check repository access: gh repo view"
    echo "Retry sync manually or check logs"
    exit 1
fi
```

## Integration Points
This task integrates with:
- `initialize-github-context.md` - Context management
- `coordination-workflow.yaml` - Progress tracking
- `quality-gate-enforcement-workflow.yaml` - Quality gate results
- `parallel-failure-recovery-workflow.yaml` - Conflict reporting
- All development agents - Progress updates

## Usage Examples

### Manual Progress Sync
```bash
# Sync current progress
sync-github-progress.md progress_update

# Sync quality gate result
sync-github-progress.md quality_gate

# Sync story completion
sync-github-progress.md completion
```

### Automatic Integration
```bash
# Called automatically by coordination workflow
# after agent handoffs, quality gates, and milestones

# Called by parallel analyzer on conflicts
sync-github-progress.md conflict_alert

# Called on escalations
sync-github-progress.md escalation
```