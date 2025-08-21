# Monitor Parallel Execution

## Task Description
Monitor smart parallel execution in real-time, detecting conflicts, tracking performance metrics, and coordinating with GitHub integration for comprehensive parallel development oversight.

## Prerequisites
- Smart parallel mode active
- Parallel execution context initialized
- GitHub context available (for reporting)
- Active parallel execution blocks

## Process

### Step 1: Validate Parallel Execution Context
```bash
# Check if parallel execution is active
if [ ! -f ".bmad-project/github-context.json" ]; then
    echo "❌ No GitHub context. Run: initialize-github-context.md"
    exit 1
fi

# Verify parallel execution is enabled
PARALLEL_ENABLED=$(jq -r '.parallel_execution.enabled' .bmad-project/github-context.json)
EXECUTION_MODE=$(jq -r '.execution_context.current_mode' .bmad-project/github-context.json)

if [ "$EXECUTION_MODE" != "smart_parallel" ]; then
    echo "ℹ️ Not in smart parallel mode. Current mode: $EXECUTION_MODE"
    exit 0
fi

if [ "$PARALLEL_ENABLED" != "true" ]; then
    echo "ℹ️ Parallel execution not enabled"
    exit 0
fi

# Get current parallel state
CURRENT_BLOCK=$(jq -r '.parallel_execution.current_block' .bmad-project/github-context.json)
TOTAL_BLOCKS=$(jq -r '.parallel_execution.total_blocks' .bmad-project/github-context.json)
COMPLETED_BLOCKS=$(jq -r '.parallel_execution.completed_blocks' .bmad-project/github-context.json)

echo "🔀 Parallel Execution Monitoring"
echo "  Current Block: $CURRENT_BLOCK"
echo "  Progress: $COMPLETED_BLOCKS/$TOTAL_BLOCKS blocks"
echo "  Status: Active monitoring"
```

### Step 2: Initialize Monitoring Session
```bash
# Create monitoring session
MONITORING_SESSION_ID="monitor-$(date +%Y%m%d-%H%M%S)"
MONITORING_START=$(date -Iseconds)
SESSION_ID=$(jq -r '.github_session.session_id' .bmad-project/github-context.json)

# Create monitoring directory and logs
mkdir -p ".bmad-project/parallel-monitoring/$MONITORING_SESSION_ID"
MONITORING_LOG=".bmad-project/parallel-monitoring/$MONITORING_SESSION_ID/monitoring.log"
CONFLICT_LOG=".bmad-project/parallel-monitoring/$MONITORING_SESSION_ID/conflicts.log"
PERFORMANCE_LOG=".bmad-project/parallel-monitoring/$MONITORING_SESSION_ID/performance.log"

# Initialize monitoring logs
echo "# Parallel Execution Monitoring Session" > "$MONITORING_LOG"
echo "# Session: $MONITORING_SESSION_ID" >> "$MONITORING_LOG"
echo "# Started: $MONITORING_START" >> "$MONITORING_LOG"
echo "# BMAD Session: $SESSION_ID" >> "$MONITORING_LOG"
echo "" >> "$MONITORING_LOG"

echo "# Conflict Detection Log" > "$CONFLICT_LOG"
echo "# Format: timestamp | conflict_type | severity | agents | resource | status" >> "$CONFLICT_LOG"

echo "# Performance Metrics Log" > "$PERFORMANCE_LOG"
echo "# Format: timestamp | metric | value | unit | context" >> "$PERFORMANCE_LOG"

echo "📊 Monitoring session initialized: $MONITORING_SESSION_ID"
```

### Step 3: Define Monitoring Functions
```bash
# Conflict detection function
detect_conflicts() {
    local timestamp=$(date -Iseconds)
    local conflicts_detected=0
    
    # File system conflict detection
    echo "🔍 Checking file system conflicts..."
    
    # Get active agents and their target files
    ACTIVE_AGENTS=$(jq -r '.agent_execution.active_agents[].agent_id' .bmad-project/github-context.json)
    
    # Create temporary file for conflict analysis
    CONFLICT_ANALYSIS="/tmp/conflict-analysis-$$.json"
    echo '{"file_conflicts": [], "dependency_conflicts": [], "resource_conflicts": []}' > "$CONFLICT_ANALYSIS"
    
    # Check for file conflicts
    for agent in $ACTIVE_AGENTS; do
        # Get files this agent is targeting
        AGENT_FILES=$(jq -r --arg agent "$agent" '.agent_execution.active_agents[] | select(.agent_id == $agent) | .files_targeted[]?' .bmad-project/github-context.json)
        
        for file in $AGENT_FILES; do
            # Check if any other agent is also targeting this file
            OTHER_AGENTS=$(jq -r --arg agent "$agent" --arg file "$file" \
                '.agent_execution.active_agents[] | select(.agent_id != $agent and (.files_targeted[]? == $file)) | .agent_id' \
                .bmad-project/github-context.json)
            
            if [ -n "$OTHER_AGENTS" ]; then
                echo "⚠️ File conflict detected: $file"
                echo "   Agents: $agent, $OTHER_AGENTS"
                
                # Log conflict
                echo "$timestamp | file_conflict | high | $agent,$OTHER_AGENTS | $file | detected" >> "$CONFLICT_LOG"
                
                # Add to conflict analysis
                jq --arg timestamp "$timestamp" --arg agents "$agent,$OTHER_AGENTS" --arg file "$file" \
                   '.file_conflicts += [{
                       "timestamp": $timestamp,
                       "type": "file_conflict",
                       "severity": "high",
                       "agents": ($agents | split(",")),
                       "resource": $file,
                       "status": "detected"
                   }]' "$CONFLICT_ANALYSIS" > "$CONFLICT_ANALYSIS.tmp" && mv "$CONFLICT_ANALYSIS.tmp" "$CONFLICT_ANALYSIS"
                
                conflicts_detected=$((conflicts_detected + 1))
            fi
        done
    done
    
    # Git conflict detection
    echo "🔍 Checking Git conflicts..."
    if git status --porcelain | grep -q "^UU\|^AA\|^DD"; then
        echo "⚠️ Git merge conflicts detected"
        GIT_CONFLICTS=$(git status --porcelain | grep "^UU\|^AA\|^DD" | cut -c4-)
        
        for conflict_file in $GIT_CONFLICTS; do
            echo "$timestamp | git_conflict | critical | system | $conflict_file | detected" >> "$CONFLICT_LOG"
            conflicts_detected=$((conflicts_detected + 1))
        done
    fi
    
    # Resource contention detection
    echo "🔍 Checking resource contention..."
    
    # Check database locks (if applicable)
    # Check memory usage
    MEMORY_USAGE=$(free | grep '^Mem:' | awk '{print int($3/$2 * 100)}')
    if [ "$MEMORY_USAGE" -gt 90 ]; then
        echo "⚠️ High memory usage: ${MEMORY_USAGE}%"
        echo "$timestamp | resource_contention | medium | system | memory | high_usage" >> "$CONFLICT_LOG"
    fi
    
    # Update conflict tracking in context
    jq --arg conflicts "$conflicts_detected" --arg timestamp "$timestamp" \
       '.parallel_execution.conflict_tracking.total_conflicts += ($conflicts | tonumber) |
        .parallel_execution.conflict_tracking.last_check = $timestamp' \
       .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
       mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
    
    echo "$timestamp | conflict_check | info | system | total | $conflicts_detected" >> "$MONITORING_LOG"
    
    # Return number of conflicts detected
    return $conflicts_detected
}

# Performance monitoring function
monitor_performance() {
    local timestamp=$(date -Iseconds)
    
    echo "📊 Monitoring performance metrics..."
    
    # Agent execution times
    ACTIVE_AGENT_COUNT=$(jq -r '.agent_execution.active_agents | length' .bmad-project/github-context.json)
    COMPLETED_AGENT_COUNT=$(jq -r '.agent_execution.completed_agents | length' .bmad-project/github-context.json)
    
    # Calculate agent utilization
    if [ "$TOTAL_BLOCKS" -gt 0 ]; then
        BLOCK_PROGRESS=$(echo "scale=2; $COMPLETED_BLOCKS * 100 / $TOTAL_BLOCKS" | bc -l)
    else
        BLOCK_PROGRESS=0
    fi
    
    # System resource monitoring
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    MEMORY_USAGE=$(free | grep '^Mem:' | awk '{print int($3/$2 * 100)}')
    DISK_USAGE=$(df . | tail -1 | awk '{print $5}' | cut -d'%' -f1)
    
    # Parallel efficiency calculation
    SESSION_START=$(jq -r '.progress_tracking.session_started_at' .bmad-project/github-context.json)
    if [ "$SESSION_START" != "null" ]; then
        CURRENT_TIME=$(date +%s)
        SESSION_START_EPOCH=$(date -d "$SESSION_START" +%s)
        ELAPSED_TIME=$((CURRENT_TIME - SESSION_START_EPOCH))
        ELAPSED_MINUTES=$(echo "scale=2; $ELAPSED_TIME / 60" | bc -l)
        
        if [ "$COMPLETED_AGENT_COUNT" -gt 0 ] && [ "$(echo "$ELAPSED_MINUTES > 0" | bc -l)" -eq 1 ]; then
            AGENTS_PER_MINUTE=$(echo "scale=2; $COMPLETED_AGENT_COUNT / $ELAPSED_MINUTES" | bc -l)
        else
            AGENTS_PER_MINUTE="calculating"
        fi
    else
        AGENTS_PER_MINUTE="unknown"
    fi
    
    # Log performance metrics
    echo "$timestamp | active_agents | $ACTIVE_AGENT_COUNT | count | current" >> "$PERFORMANCE_LOG"
    echo "$timestamp | completed_agents | $COMPLETED_AGENT_COUNT | count | total" >> "$PERFORMANCE_LOG"
    echo "$timestamp | block_progress | $BLOCK_PROGRESS | percent | completion" >> "$PERFORMANCE_LOG"
    echo "$timestamp | cpu_usage | $CPU_USAGE | percent | system" >> "$PERFORMANCE_LOG"
    echo "$timestamp | memory_usage | $MEMORY_USAGE | percent | system" >> "$PERFORMANCE_LOG"
    echo "$timestamp | disk_usage | $DISK_USAGE | percent | system" >> "$PERFORMANCE_LOG"
    echo "$timestamp | agents_per_minute | $AGENTS_PER_MINUTE | rate | efficiency" >> "$PERFORMANCE_LOG"
    
    # Update performance metrics in context
    jq --arg timestamp "$timestamp" --arg cpu_usage "$CPU_USAGE" --arg memory_usage "$MEMORY_USAGE" \
       --arg active_agents "$ACTIVE_AGENT_COUNT" --arg agents_rate "$AGENTS_PER_MINUTE" \
       '.parallel_execution.performance_metrics.last_update = $timestamp |
        .parallel_execution.performance_metrics.cpu_usage = ($cpu_usage | tonumber) |
        .parallel_execution.performance_metrics.memory_usage = ($memory_usage | tonumber) |
        .parallel_execution.performance_metrics.active_agents = ($active_agents | tonumber) |
        .parallel_execution.performance_metrics.agents_per_minute = $agents_rate' \
       .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
       mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
    
    echo "$timestamp | performance_check | info | system | metrics | updated" >> "$MONITORING_LOG"
}

# Quality gate monitoring function
monitor_quality_gates() {
    local timestamp=$(date -Iseconds)
    
    echo "✅ Monitoring quality gates..."
    
    # Check recent quality gate results
    RECENT_GATES=$(jq -r '.quality_gates.total_gates_run' .bmad-project/github-context.json)
    RECENT_PASSED=$(jq -r '.quality_gates.gates_passed' .bmad-project/github-context.json)
    RECENT_FAILED=$(jq -r '.quality_gates.gates_failed' .bmad-project/github-context.json)
    
    # Calculate quality gate pass rate
    if [ "$RECENT_GATES" -gt 0 ]; then
        GATE_PASS_RATE=$(echo "scale=1; $RECENT_PASSED * 100 / $RECENT_GATES" | bc -l)
    else
        GATE_PASS_RATE="N/A"
    fi
    
    # Log quality metrics
    echo "$timestamp | quality_gates_run | $RECENT_GATES | count | total" >> "$PERFORMANCE_LOG"
    echo "$timestamp | quality_gates_passed | $RECENT_PASSED | count | passed" >> "$PERFORMANCE_LOG"
    echo "$timestamp | quality_gates_failed | $RECENT_FAILED | count | failed" >> "$PERFORMANCE_LOG"
    echo "$timestamp | gate_pass_rate | $GATE_PASS_RATE | percent | quality" >> "$PERFORMANCE_LOG"
    
    # Check for recent gate failures
    if [ "$RECENT_FAILED" -gt 0 ]; then
        echo "⚠️ Quality gate failures detected: $RECENT_FAILED"
        echo "$timestamp | quality_gate_failures | warning | system | gates | $RECENT_FAILED" >> "$CONFLICT_LOG"
    fi
    
    echo "$timestamp | quality_gate_check | info | system | gates | monitored" >> "$MONITORING_LOG"
}
```

### Step 4: Execute Continuous Monitoring Loop
```bash
# Main monitoring loop
execute_monitoring_loop() {
    local monitoring_interval=30  # seconds
    local max_monitoring_duration=3600  # 1 hour max
    local monitoring_start_time=$(date +%s)
    local loop_count=0
    
    echo "🔄 Starting continuous monitoring loop"
    echo "   Interval: ${monitoring_interval}s"
    echo "   Max Duration: ${max_monitoring_duration}s"
    
    while true; do
        loop_count=$((loop_count + 1))
        current_time=$(date +%s)
        elapsed_time=$((current_time - monitoring_start_time))
        
        echo ""
        echo "🔍 Monitoring Loop #$loop_count (${elapsed_time}s elapsed)"
        
        # Check if parallel execution is still active
        PARALLEL_STILL_ENABLED=$(jq -r '.parallel_execution.enabled' .bmad-project/github-context.json)
        CURRENT_BLOCK_CHECK=$(jq -r '.parallel_execution.current_block' .bmad-project/github-context.json)
        
        if [ "$PARALLEL_STILL_ENABLED" != "true" ]; then
            echo "✅ Parallel execution completed or disabled"
            break
        fi
        
        if [ "$CURRENT_BLOCK_CHECK" = "null" ]; then
            echo "✅ No active parallel block"
            break
        fi
        
        # Execute monitoring functions
        detect_conflicts
        CONFLICTS_FOUND=$?
        
        monitor_performance
        monitor_quality_gates
        
        # Handle conflicts if detected
        if [ $CONFLICTS_FOUND -gt 0 ]; then
            echo "🚨 Conflicts detected: $CONFLICTS_FOUND"
            
            # Report conflicts to GitHub
            if command -v sync-github-progress.md >/dev/null 2>&1; then
                echo "📤 Reporting conflicts to GitHub..."
                sync-github-progress.md conflict_alert
            fi
            
            # Trigger conflict resolution if available
            if [ -f ".bmad-erpnext-v16/workflows/parallel-failure-recovery-workflow.yaml" ]; then
                echo "🔧 Triggering conflict resolution workflow..."
                # Could trigger parallel-failure-recovery-workflow here
            fi
        fi
        
        # Check for monitoring timeout
        if [ $elapsed_time -gt $max_monitoring_duration ]; then
            echo "⏰ Monitoring timeout reached (${max_monitoring_duration}s)"
            break
        fi
        
        # Progress update every 5 loops (approximately 2.5 minutes)
        if [ $((loop_count % 5)) -eq 0 ]; then
            echo "📊 Progress Update:"
            echo "   Active Agents: $(jq -r '.agent_execution.active_agents | length' .bmad-project/github-context.json)"
            echo "   Completed Agents: $(jq -r '.agent_execution.completed_agents | length' .bmad-project/github-context.json)"
            echo "   Current Block: $CURRENT_BLOCK_CHECK"
            echo "   Conflicts Detected: $(jq -r '.parallel_execution.conflict_tracking.total_conflicts' .bmad-project/github-context.json)"
            
            # Sync progress to GitHub
            if command -v sync-github-progress.md >/dev/null 2>&1; then
                sync-github-progress.md progress_update
            fi
        fi
        
        # Wait for next monitoring cycle
        echo "⏸️ Waiting ${monitoring_interval}s for next check..."
        sleep $monitoring_interval
    done
}

# Execute monitoring loop (can be run in background)
if [ "${1:-foreground}" = "background" ]; then
    echo "🔀 Starting background monitoring..."
    execute_monitoring_loop > "$MONITORING_LOG.output" 2>&1 &
    MONITORING_PID=$!
    echo "$MONITORING_PID" > ".bmad-project/parallel-monitoring/$MONITORING_SESSION_ID/monitoring.pid"
    echo "Background monitoring started with PID: $MONITORING_PID"
else
    execute_monitoring_loop
fi
```

### Step 5: Generate Monitoring Report
```bash
# Generate comprehensive monitoring report
generate_monitoring_report() {
    local timestamp=$(date -Iseconds)
    local monitoring_end=$(date -Iseconds)
    
    echo "📋 Generating monitoring report..."
    
    # Calculate monitoring session duration
    MONITORING_START_EPOCH=$(date -d "$MONITORING_START" +%s)
    MONITORING_END_EPOCH=$(date -d "$monitoring_end" +%s)
    MONITORING_DURATION=$((MONITORING_END_EPOCH - MONITORING_START_EPOCH))
    MONITORING_DURATION_MIN=$(echo "scale=2; $MONITORING_DURATION / 60" | bc -l)
    
    # Analyze logs
    TOTAL_CONFLICTS=$(wc -l < "$CONFLICT_LOG" | tail -1)
    TOTAL_CONFLICTS=$((TOTAL_CONFLICTS - 2))  # Subtract header lines
    
    PERFORMANCE_ENTRIES=$(wc -l < "$PERFORMANCE_LOG" | tail -1)
    PERFORMANCE_ENTRIES=$((PERFORMANCE_ENTRIES - 2))  # Subtract header lines
    
    # Get final metrics
    FINAL_ACTIVE_AGENTS=$(jq -r '.agent_execution.active_agents | length' .bmad-project/github-context.json)
    FINAL_COMPLETED_AGENTS=$(jq -r '.agent_execution.completed_agents | length' .bmad-project/github-context.json)
    FINAL_CONFLICTS=$(jq -r '.parallel_execution.conflict_tracking.total_conflicts' .bmad-project/github-context.json)
    FINAL_RESOLVED_CONFLICTS=$(jq -r '.parallel_execution.conflict_tracking.resolved_conflicts' .bmad-project/github-context.json)
    
    # Create monitoring report
    MONITORING_REPORT=".bmad-project/parallel-monitoring/$MONITORING_SESSION_ID/monitoring-report.md"
    
    cat > "$MONITORING_REPORT" << EOF
# Parallel Execution Monitoring Report

## Session Information
- **Monitoring Session**: $MONITORING_SESSION_ID
- **BMAD Session**: $SESSION_ID
- **Start Time**: $MONITORING_START
- **End Time**: $monitoring_end
- **Duration**: ${MONITORING_DURATION_MIN} minutes
- **Execution Mode**: smart_parallel

## Parallel Execution Summary
- **Current Block**: $CURRENT_BLOCK
- **Total Blocks**: $TOTAL_BLOCKS
- **Completed Blocks**: $COMPLETED_BLOCKS
- **Active Agents**: $FINAL_ACTIVE_AGENTS
- **Completed Agents**: $FINAL_COMPLETED_AGENTS

## Conflict Analysis
- **Total Conflicts Detected**: $FINAL_CONFLICTS
- **Conflicts Resolved**: $FINAL_RESOLVED_CONFLICTS
- **Active Conflicts**: $((FINAL_CONFLICTS - FINAL_RESOLVED_CONFLICTS))
- **Conflict Rate**: $(echo "scale=2; $FINAL_CONFLICTS / $MONITORING_DURATION_MIN" | bc -l) conflicts/minute

## Performance Metrics
- **Monitoring Entries**: $PERFORMANCE_ENTRIES
- **Average CPU Usage**: $(awk -F' | ' '/cpu_usage/ {sum += $3; count++} END {if(count > 0) print sum/count; else print "N/A"}' "$PERFORMANCE_LOG")%
- **Average Memory Usage**: $(awk -F' | ' '/memory_usage/ {sum += $3; count++} END {if(count > 0) print sum/count; else print "N/A"}' "$PERFORMANCE_LOG")%
- **Agent Completion Rate**: $(awk -F' | ' '/agents_per_minute/ && $3 != "calculating" {sum += $3; count++} END {if(count > 0) print sum/count; else print "N/A"}' "$PERFORMANCE_LOG") agents/minute

## Quality Gates
- **Gates Run**: $(jq -r '.quality_gates.total_gates_run' .bmad-project/github-context.json)
- **Gates Passed**: $(jq -r '.quality_gates.gates_passed' .bmad-project/github-context.json)
- **Gates Failed**: $(jq -r '.quality_gates.gates_failed' .bmad-project/github-context.json)
- **Pass Rate**: $(jq -r '.quality_gates | if .total_gates_run > 0 then (.gates_passed * 100 / .total_gates_run | floor) else "N/A" end' .bmad-project/github-context.json)%

## Log Files
- **Main Log**: $MONITORING_LOG
- **Conflict Log**: $CONFLICT_LOG  
- **Performance Log**: $PERFORMANCE_LOG

## Recommendations
$(if [ "$FINAL_CONFLICTS" -gt 5 ]; then
    echo "- High conflict rate detected - consider reducing parallel agent count"
else
    echo "- Conflict rate acceptable for parallel execution"
fi)

$(if [ "$FINAL_COMPLETED_AGENTS" -gt 0 ]; then
    echo "- Parallel execution proceeding successfully"
else
    echo "- Monitor agent progress - no agents completed yet"
fi)

## Next Steps
- Review conflict patterns in conflict log
- Analyze performance trends for optimization
- Consider parallel execution tuning based on metrics

---
*Generated by BMAD ERPNext v16 Parallel Execution Monitor*
EOF

    echo "✅ Monitoring report generated: $MONITORING_REPORT"
    
    # Update context with monitoring results
    jq --arg session_id "$MONITORING_SESSION_ID" --arg duration "$MONITORING_DURATION_MIN" \
       --arg conflicts "$FINAL_CONFLICTS" --arg report_path "$MONITORING_REPORT" \
       '.parallel_execution.monitoring_sessions += [{
           "session_id": $session_id,
           "duration_minutes": ($duration | tonumber),
           "conflicts_detected": ($conflicts | tonumber),
           "report_path": $report_path,
           "completed_at": "'$monitoring_end'"
       }]' \
       .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
       mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
}

# Generate report if not running in background
if [ "${1:-foreground}" != "background" ]; then
    generate_monitoring_report
fi
```

### Step 6: Integration with GitHub Reporting
```bash
# Sync monitoring results to GitHub
sync_monitoring_to_github() {
    local current_issue=$(jq -r '.github_session.current_issue.number' .bmad-project/github-context.json)
    local sync_enabled=$(jq -r '.github_session.integration_config.sync_enabled' .bmad-project/github-context.json)
    
    if [ "$sync_enabled" = "true" ] && [ "$current_issue" != "null" ]; then
        echo "📤 Syncing monitoring results to GitHub..."
        
        # Create monitoring summary comment
        MONITORING_SUMMARY="## 🔀 Parallel Execution Monitoring Complete

**Monitoring Session**: $MONITORING_SESSION_ID
**Duration**: ${MONITORING_DURATION_MIN} minutes
**Timestamp**: $(date -Iseconds)

### Execution Status
- **Current Block**: $CURRENT_BLOCK
- **Progress**: $COMPLETED_BLOCKS/$TOTAL_BLOCKS blocks completed
- **Active Agents**: $FINAL_ACTIVE_AGENTS
- **Completed Agents**: $FINAL_COMPLETED_AGENTS

### Conflict Management
- **Conflicts Detected**: $FINAL_CONFLICTS
- **Conflicts Resolved**: $FINAL_RESOLVED_CONFLICTS
- **Conflict Rate**: $(echo "scale=2; $FINAL_CONFLICTS / $MONITORING_DURATION_MIN" | bc -l) per minute

### Performance Summary
- **Agent Efficiency**: $(awk -F' | ' '/agents_per_minute/ && $3 != "calculating" {sum += $3; count++} END {if(count > 0) printf "%.1f", sum/count; else print "calculating"}' "$PERFORMANCE_LOG") agents/minute
- **Resource Usage**: CPU $(awk -F' | ' '/cpu_usage/ {sum += $3; count++} END {if(count > 0) printf "%.0f", sum/count; else print "N/A"}' "$PERFORMANCE_LOG")%, Memory $(awk -F' | ' '/memory_usage/ {sum += $3; count++} END {if(count > 0) printf "%.0f", sum/count; else print "N/A"}' "$PERFORMANCE_LOG")%
- **Quality Gates**: $(jq -r '.quality_gates | if .total_gates_run > 0 then (.gates_passed * 100 / .total_gates_run | floor) else "N/A" end' .bmad-project/github-context.json)% pass rate

### Status
$(if [ "$FINAL_CONFLICTS" -eq 0 ]; then
    echo "✅ **Execution proceeding smoothly** - No conflicts detected"
elif [ "$FINAL_CONFLICTS" -lt 3 ]; then
    echo "⚠️ **Minor conflicts detected** - Automatic resolution active"
else
    echo "🚨 **Multiple conflicts detected** - Manual review may be required"
fi)

---
*Parallel execution monitoring • BMAD ERPNext v16 • [Claude Code](https://claude.ai/code)*"

        # Post monitoring summary
        if gh issue comment "$current_issue" --body "$MONITORING_SUMMARY" >/dev/null 2>&1; then
            echo "✅ Monitoring results synced to GitHub issue #$current_issue"
        else
            echo "⚠️ Failed to sync monitoring results to GitHub"
        fi
    fi
}

# Sync to GitHub if not in background mode
if [ "${1:-foreground}" != "background" ]; then
    sync_monitoring_to_github
fi
```

### Step 7: Cleanup and Final Status
```bash
# Final monitoring status
echo ""
echo "📊 Parallel Execution Monitoring Summary:"
echo "  Session ID: $MONITORING_SESSION_ID"
echo "  Duration: ${MONITORING_DURATION_MIN:-calculating} minutes"
echo "  Conflicts: ${FINAL_CONFLICTS:-0}"
echo "  Status: $([ "$PARALLEL_STILL_ENABLED" = "true" ] && echo "Active" || echo "Completed")"
echo "  Report: $MONITORING_REPORT"
echo ""

# Cleanup function for background mode
cleanup_monitoring() {
    if [ -f ".bmad-project/parallel-monitoring/$MONITORING_SESSION_ID/monitoring.pid" ]; then
        MONITORING_PID=$(cat ".bmad-project/parallel-monitoring/$MONITORING_SESSION_ID/monitoring.pid")
        if kill -0 "$MONITORING_PID" 2>/dev/null; then
            echo "🛑 Stopping background monitoring (PID: $MONITORING_PID)"
            kill "$MONITORING_PID"
        fi
        rm -f ".bmad-project/parallel-monitoring/$MONITORING_SESSION_ID/monitoring.pid"
    fi
    
    # Generate final report if needed
    if [ ! -f "$MONITORING_REPORT" ]; then
        generate_monitoring_report
    fi
    
    echo "🧹 Monitoring cleanup completed"
}

# Setup cleanup trap
trap cleanup_monitoring EXIT

# If in background mode, provide control instructions
if [ "${1:-foreground}" = "background" ]; then
    echo "🎛️ Background Monitoring Controls:"
    echo "  Stop: kill $(cat ".bmad-project/parallel-monitoring/$MONITORING_SESSION_ID/monitoring.pid")"
    echo "  Logs: tail -f $MONITORING_LOG.output"
    echo "  Status: ps aux | grep $MONITORING_SESSION_ID"
fi
```

## Success Criteria
- [ ] Parallel execution context validated
- [ ] Monitoring session initialized
- [ ] Conflict detection operational
- [ ] Performance monitoring active
- [ ] Quality gate monitoring enabled
- [ ] GitHub integration functioning
- [ ] Comprehensive reporting generated
- [ ] Background monitoring available

## Error Handling

### Parallel Execution Not Active
```bash
if [ "$EXECUTION_MODE" != "smart_parallel" ]; then
    echo "ℹ️ Monitoring only applicable for smart parallel mode"
    echo "Current mode: $EXECUTION_MODE"
    exit 0
fi
```

### Missing Dependencies
```bash
if ! command -v jq >/dev/null 2>&1; then
    echo "❌ jq required for monitoring"
    exit 1
fi

if ! command -v bc >/dev/null 2>&1; then
    echo "❌ bc required for calculations"
    exit 1
fi
```

### Monitoring Session Failure
```bash
if [ ! -d ".bmad-project/parallel-monitoring/$MONITORING_SESSION_ID" ]; then
    echo "❌ Failed to create monitoring session directory"
    exit 1
fi
```

### GitHub Sync Failure
```bash
if [ $? -ne 0 ]; then
    echo "⚠️ GitHub sync failed but monitoring continues"
    echo "Check GitHub authentication and connectivity"
fi
```

## Integration Points
This task integrates with:
- `parallel-analyzer` agent - Conflict detection rules
- `parallel-failure-recovery-workflow` - Conflict resolution
- `sync-github-progress.md` - Progress reporting
- `coordination-workflow` - Execution monitoring
- All parallel execution agents - Real-time status

## Usage Examples

### Foreground Monitoring
```bash
# Monitor parallel execution interactively
monitor-parallel-execution.md

# Monitor with detailed output
monitor-parallel-execution.md foreground
```

### Background Monitoring
```bash
# Start background monitoring
monitor-parallel-execution.md background

# Check monitoring status
ps aux | grep monitor-parallel

# View live logs
tail -f .bmad-project/parallel-monitoring/*/monitoring.log.output

# Stop background monitoring
kill $(cat .bmad-project/parallel-monitoring/*/monitoring.pid)
```

### Integration with Parallel Execution
```bash
# Called automatically when parallel execution starts
# monitor-parallel-execution.md background

# Called by coordination workflow during parallel blocks
# monitor-parallel-execution.md foreground
```