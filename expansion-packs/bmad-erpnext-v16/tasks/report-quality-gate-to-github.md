# Report Quality Gate to GitHub

## Task Description
Automatically report quality gate results to GitHub issues with detailed analysis, recovery strategies, and next steps based on execution mode and gate criticality.

## Prerequisites
- Active GitHub context with current issue
- Quality gate execution completed
- Quality gate results available
- GitHub sync enabled

## Process

### Step 1: Validate Quality Gate Context
```bash
# Check if quality gate result is available
GATE_NAME="${1:-unknown_gate}"
GATE_RESULT="${2:-unknown}"
STORY_ID="${3:-current_story}"
AGENT_ID="${4:-unknown_agent}"
GATE_DETAILS="${5:-No details provided}"

if [ -z "$GATE_NAME" ] || [ "$GATE_RESULT" = "unknown" ]; then
    echo "❌ Quality gate information incomplete"
    echo "Usage: report-quality-gate-to-github.md <gate_name> <result> [story_id] [agent_id] [details]"
    exit 1
fi

# Validate GitHub context
if [ ! -f ".bmad-project/github-context.json" ]; then
    echo "❌ No GitHub context. Run: initialize-github-context.md"
    exit 1
fi

# Check if GitHub sync is enabled for quality gates
QUALITY_GATE_REPORTING=$(jq -r '.github_session.integration_config.quality_gate_reporting' .bmad-project/github-context.json)
if [ "$QUALITY_GATE_REPORTING" != "true" ]; then
    echo "ℹ️ Quality gate reporting disabled"
    exit 0
fi

# Get current issue
CURRENT_ISSUE=$(jq -r '.github_session.current_issue.number' .bmad-project/github-context.json)
if [ "$CURRENT_ISSUE" = "null" ] || [ -z "$CURRENT_ISSUE" ]; then
    echo "⚠️ No current GitHub issue for quality gate reporting"
    exit 1
fi

echo "✅ Quality gate context validated"
echo "Gate: $GATE_NAME | Result: $GATE_RESULT | Issue: #$CURRENT_ISSUE"
```

### Step 2: Gather Execution Context
```bash
# Get execution mode and context
EXECUTION_MODE=$(jq -r '.execution_context.current_mode' .bmad-project/github-context.json)
SESSION_ID=$(jq -r '.github_session.session_id' .bmad-project/github-context.json)
TIMESTAMP=$(date -Iseconds)

# Get current story information
if [ "$STORY_ID" = "current_story" ]; then
    STORY_ID=$(jq -r '.story_tracking.active_stories[-1].story_id // "unknown"' .bmad-project/github-context.json)
    STORY_TITLE=$(jq -r '.story_tracking.active_stories[-1].title // "Current Development Work"' .bmad-project/github-context.json)
else
    STORY_TITLE=$(jq -r --arg story_id "$STORY_ID" '.story_tracking.active_stories[] | select(.story_id == $story_id) | .title // "Development Work"' .bmad-project/github-context.json)
fi

# Get quality gate statistics
TOTAL_GATES=$(jq -r '.quality_gates.total_gates_run' .bmad-project/github-context.json)
GATES_PASSED=$(jq -r '.quality_gates.gates_passed' .bmad-project/github-context.json)
GATES_FAILED=$(jq -r '.quality_gates.gates_failed' .bmad-project/github-context.json)

# Calculate quality gate pass rate
if [ "$TOTAL_GATES" -gt 0 ]; then
    GATE_PASS_RATE=$(echo "scale=1; $GATES_PASSED * 100 / $TOTAL_GATES" | bc -l)
else
    GATE_PASS_RATE="N/A"
fi

echo "📊 Execution Context:"
echo "  Mode: $EXECUTION_MODE"
echo "  Story: $STORY_ID ($STORY_TITLE)"
echo "  Agent: $AGENT_ID"
echo "  Gate Pass Rate: $GATE_PASS_RATE%"
```

### Step 3: Assess Quality Gate Impact
```bash
# Determine gate criticality and impact
assess_gate_impact() {
    local gate_name="$1"
    local gate_result="$2"
    local execution_mode="$3"
    
    # Define gate criticality levels
    case "$gate_name" in
        "structure_validation"|"import_validation"|"security_validation")
            GATE_CRITICALITY="high"
            ;;
        "test_execution"|"integration_testing"|"api_validation")
            GATE_CRITICALITY="medium"
            ;;
        "documentation_check"|"style_validation"|"performance_check")
            GATE_CRITICALITY="low"
            ;;
        *)
            GATE_CRITICALITY="medium"
            ;;
    esac
    
    # Assess impact based on result and mode
    if [ "$gate_result" = "passed" ]; then
        IMPACT_LEVEL="positive"
        IMPACT_DESCRIPTION="Quality assurance milestone achieved"
    else
        case "$GATE_CRITICALITY" in
            "high")
                IMPACT_LEVEL="critical"
                IMPACT_DESCRIPTION="Critical quality issue blocks further development"
                ;;
            "medium")
                IMPACT_LEVEL="significant"
                IMPACT_DESCRIPTION="Quality issue requires attention before proceeding"
                ;;
            "low")
                IMPACT_LEVEL="minor"
                IMPACT_DESCRIPTION="Quality issue should be addressed but doesn't block progress"
                ;;
        esac
        
        # Mode-specific impact assessment
        case "$execution_mode" in
            "guided")
                IMPACT_DESCRIPTION="$IMPACT_DESCRIPTION (User review required)"
                ;;
            "sequential")
                IMPACT_DESCRIPTION="$IMPACT_DESCRIPTION (Automatic retry initiated)"
                ;;
            "smart_parallel")
                IMPACT_DESCRIPTION="$IMPACT_DESCRIPTION (Parallel execution may be affected)"
                ;;
        esac
    fi
}

assess_gate_impact "$GATE_NAME" "$GATE_RESULT" "$EXECUTION_MODE"

echo "🎯 Gate Impact Assessment:"
echo "  Criticality: $GATE_CRITICALITY"
echo "  Impact Level: $IMPACT_LEVEL"
echo "  Description: $IMPACT_DESCRIPTION"
```

### Step 4: Determine Recovery Strategy
```bash
# Define recovery strategy based on gate result and execution mode
determine_recovery_strategy() {
    local gate_result="$1"
    local gate_criticality="$2"
    local execution_mode="$3"
    
    if [ "$gate_result" = "passed" ]; then
        RECOVERY_STRATEGY="continue_development"
        RECOVERY_ACTIONS="Proceed to next development phase"
        NEXT_STEPS="Continue with planned work"
        return 0
    fi
    
    # Failed gate recovery strategies
    case "$execution_mode" in
        "guided")
            case "$gate_criticality" in
                "high")
                    RECOVERY_STRATEGY="interactive_diagnosis"
                    RECOVERY_ACTIONS="User review required to diagnose and fix critical issues"
                    NEXT_STEPS="1. Review gate failure details\\n2. User decides on fix approach\\n3. Agent implements fixes\\n4. Re-run quality gate"
                    ;;
                "medium")
                    RECOVERY_STRATEGY="guided_remediation"
                    RECOVERY_ACTIONS="User-guided remediation process"
                    NEXT_STEPS="1. Present issue to user\\n2. Get approval for fix strategy\\n3. Implement fixes\\n4. Validate resolution"
                    ;;
                "low")
                    RECOVERY_STRATEGY="advisory_fix"
                    RECOVERY_ACTIONS="Advisory fix with user notification"
                    NEXT_STEPS="1. Notify user of issue\\n2. Suggest fix approach\\n3. Continue development with fix planned"
                    ;;
            esac
            ;;
        "sequential")
            case "$gate_criticality" in
                "high")
                    RECOVERY_STRATEGY="automatic_retry_with_escalation"
                    RECOVERY_ACTIONS="Automatic retry (3 attempts), then escalate"
                    NEXT_STEPS="1. Automatic retry initiated\\n2. If retry fails, escalate to user\\n3. Pause batch processing"
                    ;;
                "medium")
                    RECOVERY_STRATEGY="automatic_remediation"
                    RECOVERY_ACTIONS="Automatic fix attempt based on common patterns"
                    NEXT_STEPS="1. Apply automatic fixes\\n2. Re-run quality gate\\n3. Continue if resolved"
                    ;;
                "low")
                    RECOVERY_STRATEGY="defer_and_continue"
                    RECOVERY_ACTIONS="Log issue and continue processing"
                    NEXT_STEPS="1. Log issue for later review\\n2. Continue batch processing\\n3. Address in final review"
                    ;;
            esac
            ;;
        "smart_parallel")
            case "$gate_criticality" in
                "high")
                    RECOVERY_STRATEGY="parallel_isolation"
                    RECOVERY_ACTIONS="Isolate failing agent, pause dependents, continue others"
                    NEXT_STEPS="1. Isolate failing agent\\n2. Pause dependent agents\\n3. Continue independent work\\n4. Fix and reintegrate"
                    ;;
                "medium")
                    RECOVERY_STRATEGY="parallel_retry"
                    RECOVERY_ACTIONS="Retry in parallel, fallback to sequential if needed"
                    NEXT_STEPS="1. Retry gate in parallel\\n2. If repeated failure, switch to sequential\\n3. Continue parallel work for others"
                    ;;
                "low")
                    RECOVERY_STRATEGY="parallel_continue"
                    RECOVERY_ACTIONS="Log issue, continue parallel execution"
                    NEXT_STEPS="1. Log issue details\\n2. Continue parallel execution\\n3. Address during integration phase"
                    ;;
            esac
            ;;
    esac
}

determine_recovery_strategy "$GATE_RESULT" "$GATE_CRITICALITY" "$EXECUTION_MODE"

echo "🔧 Recovery Strategy:"
echo "  Strategy: $RECOVERY_STRATEGY"
echo "  Actions: $RECOVERY_ACTIONS"
```

### Step 5: Generate Detailed Gate Report
```bash
# Create comprehensive gate report
generate_gate_report() {
    local gate_name="$1"
    local gate_result="$2"
    local gate_details="$3"
    
    # Parse gate details if they're in JSON format
    if echo "$gate_details" | jq empty 2>/dev/null; then
        # Extract structured details from JSON
        ERROR_COUNT=$(echo "$gate_details" | jq -r '.errors | length // 0')
        WARNING_COUNT=$(echo "$gate_details" | jq -r '.warnings | length // 0')
        TESTS_RUN=$(echo "$gate_details" | jq -r '.tests_run // "N/A"')
        TESTS_PASSED=$(echo "$gate_details" | jq -r '.tests_passed // "N/A"')
        COVERAGE=$(echo "$gate_details" | jq -r '.coverage // "N/A"')
        
        # Build detailed report
        DETAILED_REPORT="### Gate Execution Details\\n"
        DETAILED_REPORT+="- **Tests Run**: $TESTS_RUN\\n"
        DETAILED_REPORT+="- **Tests Passed**: $TESTS_PASSED\\n"
        DETAILED_REPORT+="- **Coverage**: $COVERAGE\\n"
        DETAILED_REPORT+="- **Errors**: $ERROR_COUNT\\n"
        DETAILED_REPORT+="- **Warnings**: $WARNING_COUNT\\n\\n"
        
        # Add error details if present
        if [ "$ERROR_COUNT" -gt 0 ]; then
            DETAILED_REPORT+="### Error Details\\n"
            echo "$gate_details" | jq -r '.errors[]' | while read error; do
                DETAILED_REPORT+="- $error\\n"
            done
            DETAILED_REPORT+="\\n"
        fi
        
        # Add warning details if present
        if [ "$WARNING_COUNT" -gt 0 ]; then
            DETAILED_REPORT+="### Warning Details\\n"
            echo "$gate_details" | jq -r '.warnings[]' | while read warning; do
                DETAILED_REPORT+="- $warning\\n"
            done
            DETAILED_REPORT+="\\n"
        fi
    else
        # Handle plain text details
        DETAILED_REPORT="### Gate Details\\n$gate_details\\n\\n"
    fi
    
    # Add context-specific information
    DETAILED_REPORT+="### Execution Context\\n"
    DETAILED_REPORT+="- **Session**: $SESSION_ID\\n"
    DETAILED_REPORT+="- **Mode**: $EXECUTION_MODE\\n"
    DETAILED_REPORT+="- **Story**: $STORY_ID\\n"
    DETAILED_REPORT+="- **Agent**: $AGENT_ID\\n"
    DETAILED_REPORT+="- **Timestamp**: $TIMESTAMP\\n\\n"
    
    # Add quality metrics
    DETAILED_REPORT+="### Quality Metrics\\n"
    DETAILED_REPORT+="- **Session Gate Pass Rate**: $GATE_PASS_RATE%\\n"
    DETAILED_REPORT+="- **Total Gates Run**: $TOTAL_GATES\\n"
    DETAILED_REPORT+="- **Gates Passed**: $GATES_PASSED\\n"
    DETAILED_REPORT+="- **Gates Failed**: $GATES_FAILED\\n"
    
    echo -e "$DETAILED_REPORT"
}

GATE_REPORT=$(generate_gate_report "$GATE_NAME" "$GATE_RESULT" "$GATE_DETAILS")
```

### Step 6: Select Appropriate Template
```bash
# Select template based on gate result and execution mode
select_gate_template() {
    local gate_result="$1"
    local execution_mode="$2"
    
    if [ "$gate_result" = "passed" ]; then
        TEMPLATE_TYPE="quality_gate_success"
    else
        TEMPLATE_TYPE="quality_gate_failure"
    fi
    
    # Load template from mode-specific sync templates
    TEMPLATE_FILE=".bmad-erpnext-v16/templates/mode-specific-sync-templates.yaml"
    TEMPLATE_PATH="quality_gate_templates.${TEMPLATE_TYPE}"
    
    TEMPLATE_CONTENT=$(yq eval ".${TEMPLATE_PATH}.template" "$TEMPLATE_FILE")
    
    if [ "$TEMPLATE_CONTENT" = "null" ] || [ -z "$TEMPLATE_CONTENT" ]; then
        # Fallback template
        if [ "$gate_result" = "passed" ]; then
            TEMPLATE_CONTENT="## ✅ Quality Gate Passed\\n\\n**Gate**: \${GATE_NAME}\\n**Result**: \${GATE_RESULT}\\n**Timestamp**: \${TIMESTAMP}\\n\\n### Details\\n\${GATE_REPORT}\\n\\n---\\n*Quality assurance • BMAD ERPNext v16*"
        else
            TEMPLATE_CONTENT="## ❌ Quality Gate Failed\\n\\n**Gate**: \${GATE_NAME}\\n**Result**: \${GATE_RESULT}\\n**Impact**: \${IMPACT_LEVEL}\\n**Timestamp**: \${TIMESTAMP}\\n\\n### Failure Analysis\\n\${GATE_REPORT}\\n\\n### Recovery Strategy\\n**Strategy**: \${RECOVERY_STRATEGY}\\n**Actions**: \${RECOVERY_ACTIONS}\\n\\n### Next Steps\\n\${NEXT_STEPS}\\n\\n---\\n*Quality gate monitoring • BMAD ERPNext v16*"
        fi
    fi
}

select_gate_template "$GATE_RESULT" "$EXECUTION_MODE"
```

### Step 7: Substitute Template Variables
```bash
# Create comment body by substituting template variables
create_comment_body() {
    local template="$1"
    
    # Substitute all variables
    local comment="$template"
    comment=$(echo "$comment" | sed "s/\${GATE_NAME}/$GATE_NAME/g")
    comment=$(echo "$comment" | sed "s/\${GATE_RESULT}/$GATE_RESULT/g")
    comment=$(echo "$comment" | sed "s/\${STORY_ID}/$STORY_ID/g")
    comment=$(echo "$comment" | sed "s/\${STORY_TITLE}/$STORY_TITLE/g")
    comment=$(echo "$comment" | sed "s/\${AGENT_ID}/$AGENT_ID/g")
    comment=$(echo "$comment" | sed "s/\${EXECUTION_MODE}/$EXECUTION_MODE/g")
    comment=$(echo "$comment" | sed "s/\${SESSION_ID}/$SESSION_ID/g")
    comment=$(echo "$comment" | sed "s/\${TIMESTAMP}/$TIMESTAMP/g")
    comment=$(echo "$comment" | sed "s/\${GATE_CRITICALITY}/$GATE_CRITICALITY/g")
    comment=$(echo "$comment" | sed "s/\${IMPACT_LEVEL}/$IMPACT_LEVEL/g")
    comment=$(echo "$comment" | sed "s/\${IMPACT_DESCRIPTION}/$IMPACT_DESCRIPTION/g")
    comment=$(echo "$comment" | sed "s/\${RECOVERY_STRATEGY}/$RECOVERY_STRATEGY/g")
    comment=$(echo "$comment" | sed "s/\${RECOVERY_ACTIONS}/$RECOVERY_ACTIONS/g")
    comment=$(echo "$comment" | sed "s/\${NEXT_STEPS}/$NEXT_STEPS/g")
    comment=$(echo "$comment" | sed "s/\${GATE_PASS_RATE}/$GATE_PASS_RATE/g")
    comment=$(echo "$comment" | sed "s/\${TOTAL_GATES}/$TOTAL_GATES/g")
    comment=$(echo "$comment" | sed "s/\${GATES_PASSED}/$GATES_PASSED/g")
    comment=$(echo "$comment" | sed "s/\${GATES_FAILED}/$GATES_FAILED/g")
    
    # Replace detailed report
    comment=$(echo "$comment" | sed "s|\${GATE_REPORT}|$GATE_REPORT|g")
    
    # Clean up any remaining placeholders
    comment=$(echo "$comment" | sed 's/\${[^}]*}//g')
    
    echo "$comment"
}

COMMENT_BODY=$(create_comment_body "$TEMPLATE_CONTENT")
```

### Step 8: Add Labels and Assignees (if failure)
```bash
# For failed quality gates, add appropriate labels and assignees
if [ "$GATE_RESULT" != "passed" ]; then
    # Add quality gate failure label
    gh issue edit "$CURRENT_ISSUE" --add-label "quality-gate-failure" 2>/dev/null || true
    
    # Add criticality-based labels
    case "$GATE_CRITICALITY" in
        "high")
            gh issue edit "$CURRENT_ISSUE" --add-label "critical" 2>/dev/null || true
            ;;
        "medium")
            gh issue edit "$CURRENT_ISSUE" --add-label "bug" 2>/dev/null || true
            ;;
        "low")
            gh issue edit "$CURRENT_ISSUE" --add-label "improvement" 2>/dev/null || true
            ;;
    esac
    
    # Add mode-specific labels
    gh issue edit "$CURRENT_ISSUE" --add-label "$EXECUTION_MODE-mode" 2>/dev/null || true
    
    echo "🏷️ Added failure labels to issue"
fi
```

### Step 9: Post Quality Gate Report
```bash
# Post comment to GitHub
echo "📤 Posting quality gate report to GitHub issue #${CURRENT_ISSUE}..."

# Use sync-github-progress.md for consistent posting
if [ "$GATE_RESULT" = "passed" ]; then
    SYNC_TYPE="quality_gate_success"
else
    SYNC_TYPE="quality_gate_failure"
fi

# Set environment variables for sync script
export GATE_NAME GATE_RESULT GATE_CRITICALITY IMPACT_LEVEL RECOVERY_STRATEGY
export GATE_REPORT NEXT_STEPS RECOVERY_ACTIONS DETAILED_REPORT

# Call sync script with quality gate context
if .bmad-erpnext-v16/tasks/sync-github-progress.md "$SYNC_TYPE"; then
    echo "✅ Quality gate report posted successfully"
    
    # Record successful reporting
    jq --arg gate_name "$GATE_NAME" --arg story_id "$STORY_ID" --arg agent_id "$AGENT_ID" \
       --arg status "$GATE_RESULT" --arg timestamp "$TIMESTAMP" \
       '.quality_gates.total_gates_run += 1 |
        if $status == "passed" then .quality_gates.gates_passed += 1 
        else .quality_gates.gates_failed += 1 end' \
       .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
       mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
else
    echo "❌ Failed to post quality gate report"
    exit 1
fi
```

### Step 10: Update Context and Trigger Actions
```bash
# Update quality gate context
update_quality_gate_context() {
    local gate_name="$1"
    local gate_result="$2"
    local story_id="$3"
    local agent_id="$4"
    
    # Add gate result to context
    jq --arg gate_name "$gate_name" --arg story_id "$story_id" --arg agent_id "$agent_id" \
       --arg status "$gate_result" --arg details "$GATE_DETAILS" --arg timestamp "$TIMESTAMP" \
       '.quality_gates.gate_results += [{
           "gate_name": $gate_name,
           "story_id": $story_id,
           "agent_id": $agent_id,
           "status": $status,
           "executed_at": $timestamp,
           "details": $details,
           "github_reported": true
       }]' \
       .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
       mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
    
    # Update failure tracking if applicable
    if [ "$gate_result" != "passed" ]; then
        jq '.quality_gates.failed_gates.total_failures += 1' \
           .bmad-project/github-context.json > .bmad-project/github-context.json.tmp && \
           mv .bmad-project/github-context.json.tmp .bmad-project/github-context.json
    fi
}

update_quality_gate_context "$GATE_NAME" "$GATE_RESULT" "$STORY_ID" "$AGENT_ID"

# Trigger mode-specific actions
case "$EXECUTION_MODE" in
    "guided")
        if [ "$GATE_RESULT" != "passed" ]; then
            echo "👤 Guided mode: User interaction required for gate failure"
            echo "Pausing development for user review"
        fi
        ;;
    "sequential")
        if [ "$GATE_RESULT" != "passed" ] && [ "$GATE_CRITICALITY" = "high" ]; then
            echo "⚡ Sequential mode: Critical gate failure, pausing batch"
            # Could trigger batch pause here
        fi
        ;;
    "smart_parallel")
        if [ "$GATE_RESULT" != "passed" ]; then
            echo "🔀 Parallel mode: Gate failure, triggering recovery workflow"
            # Could trigger parallel-failure-recovery-workflow here
        fi
        ;;
esac

# Log quality gate report
echo "$(date): Quality gate reported - Gate: $GATE_NAME, Result: $GATE_RESULT, Issue: #$CURRENT_ISSUE" >> .bmad-project/github/logs/quality-gates.log
```

### Step 11: Generate Summary
```bash
# Create quality gate summary
echo ""
echo "📋 Quality Gate Report Summary:"
echo "  Gate: $GATE_NAME"
echo "  Result: $GATE_RESULT"
echo "  Criticality: $GATE_CRITICALITY"
echo "  Impact: $IMPACT_LEVEL"
echo "  Strategy: $RECOVERY_STRATEGY"
echo "  Issue: #$CURRENT_ISSUE"
echo "  Mode: $EXECUTION_MODE"
echo ""

if [ "$GATE_RESULT" = "passed" ]; then
    echo "✅ Quality gate passed - Development can continue"
else
    echo "⚠️ Quality gate failed - Recovery action required"
    echo "Next steps: $RECOVERY_ACTIONS"
fi
```

## Success Criteria
- [ ] Quality gate context validated
- [ ] Execution mode and impact assessed
- [ ] Recovery strategy determined
- [ ] Detailed gate report generated
- [ ] Appropriate template selected
- [ ] GitHub comment posted successfully
- [ ] Labels and metadata updated (if failure)
- [ ] Context updated with gate results
- [ ] Mode-specific actions triggered

## Error Handling

### Missing Quality Gate Information
```bash
if [ -z "$GATE_NAME" ] || [ "$GATE_RESULT" = "unknown" ]; then
    echo "❌ Quality gate information incomplete"
    echo "Provide: gate_name, result, story_id, agent_id, details"
    exit 1
fi
```

### GitHub Context Issues
```bash
if [ "$CURRENT_ISSUE" = "null" ]; then
    echo "⚠️ No current GitHub issue for quality gate reporting"
    echo "Gate result logged locally but not reported to GitHub"
    # Log locally without GitHub reporting
    exit 0
fi
```

### Template Missing
```bash
if [ "$TEMPLATE_CONTENT" = "null" ]; then
    echo "⚠️ Quality gate template missing, using fallback"
    # Use basic fallback template
fi
```

### GitHub API Error
```bash
if [ $? -ne 0 ]; then
    echo "❌ Failed to post quality gate report to GitHub"
    echo "Gate result recorded locally"
    # Record locally even if GitHub posting fails
fi
```

## Integration Points
This task integrates with:
- `quality-gate-enforcement-workflow.yaml` - Gate execution results
- `coordination-workflow.yaml` - Mode-specific recovery actions
- `parallel-failure-recovery-workflow.yaml` - Parallel mode failures
- `sync-github-progress.md` - Consistent GitHub posting
- All quality gate implementations - Result reporting

## Usage Examples

### Direct Quality Gate Reporting
```bash
# Report successful gate
report-quality-gate-to-github.md "structure_validation" "passed" "story-123" "doctype-designer" '{"tests_run": 15, "tests_passed": 15}'

# Report failed gate
report-quality-gate-to-github.md "test_execution" "failed" "story-123" "api-developer" '{"tests_run": 10, "tests_passed": 7, "errors": ["API validation failed", "Authentication test failed"]}'
```

### Integration with Quality Gate Workflow
```yaml
# In quality-gate-enforcement-workflow.yaml
- name: report_gate_result
  action: execute_task
  task: report-quality-gate-to-github.md
  parameters:
    gate_name: "${GATE_NAME}"
    gate_result: "${GATE_RESULT}"
    story_id: "${STORY_ID}"
    agent_id: "${AGENT_ID}"
    gate_details: "${GATE_DETAILS}"
```