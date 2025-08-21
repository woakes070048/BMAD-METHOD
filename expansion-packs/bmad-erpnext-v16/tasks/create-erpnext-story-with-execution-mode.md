# Create ERPNext Story with Execution Mode

## Task Description
Create an ERPNext user story with full execution mode awareness, including parallel execution potential analysis and mode-specific guidance.

## Prerequisites
- Epic or feature requirements defined
- Access to story-execution-mode-template.yaml
- Understanding of current execution modes (guided/sequential/smart_parallel)
- GitHub issue context (if applicable)

## Process

### Step 1: Gather Story Requirements
**Elicit**: true
**Prompt**: "Let's create a mode-aware ERPNext story. Please provide the following information:"

```
1. **User Story Basics**:
   - User role (e.g., "Sales Manager", "Warehouse Staff", "System Administrator")
   - Desired functionality (what they want to achieve)
   - Business value (why this is important)

2. **Technical Context**:
   - ERPNext module (Sales, Purchase, Stock, HR, etc.)
   - Any existing DocTypes that will be affected
   - Integration requirements (workflows, n8n, mobile, etc.)

3. **Complexity Indicators**:
   - Does this require new DocTypes? (Yes/No)
   - Does this require API endpoints? (Yes/No)
   - Does this require frontend components? (Yes/No)
   - Does this modify existing workflows? (Yes/No)
   - Are there external integrations? (Yes/No)

4. **Execution Preferences**:
   - Do you prefer guided mode (interactive review)?
   - Are you open to sequential automation?
   - Is this suitable for parallel execution?
   - Any specific timing constraints?
```

**Instructions**: Wait for user response. Do not proceed without this information.

### Step 2: Analyze Execution Mode Suitability

Based on the gathered requirements, perform execution mode analysis:

#### Complexity Assessment
```yaml
complexity_factors:
  - doctype_complexity: [new_doctype_count, relationship_complexity]
  - api_complexity: [endpoint_count, authentication_requirements]
  - frontend_complexity: [component_count, interaction_complexity]
  - integration_complexity: [workflow_changes, external_systems]
  - business_logic_complexity: [validation_rules, automation_requirements]
```

#### Mode Recommendations
```yaml
mode_analysis:
  guided_mode:
    suitable: [true/false]
    reasons: ["Interactive review ensures quality", "Complex business logic requires validation"]
    estimated_duration: "X minutes"
    
  sequential_mode:
    suitable: [true/false]
    reasons: ["Clear requirements allow automation", "Minimal user interaction needed"]
    estimated_duration: "X minutes"
    
  smart_parallel_mode:
    suitable: [true/false]
    reasons: ["Independent components identified", "No conflicting file modifications"]
    estimated_duration: "X minutes"
```

### Step 3: Task Breakdown Analysis

For each component, analyze parallel potential:

#### Backend Tasks
```yaml
backend_analysis:
  doctype_creation:
    parallelizable: true
    conflicts_with: []
    agent: "doctype-designer"
    estimated_duration: "10-15 minutes"
    
  api_architecture:
    parallelizable: true
    conflicts_with: []
    agent: "api-architect"
    estimated_duration: "8-12 minutes"
    
  workflow_design:
    parallelizable: false
    conflicts_with: ["doctype_creation"]
    agent: "workflow-specialist"
    estimated_duration: "15-20 minutes"
```

#### Frontend Tasks
```yaml
frontend_analysis:
  vue_components:
    parallelizable: false
    conflicts_with: ["api_implementation"]
    agent: "vue-spa-architect"
    estimated_duration: "20-25 minutes"
    
  ui_design:
    parallelizable: true
    conflicts_with: []
    agent: "ui-layout-designer"
    estimated_duration: "15-20 minutes"
```

### Step 4: Conflict Detection

Analyze potential conflicts for parallel execution:

#### File System Conflicts
```yaml
file_conflicts:
  - file_path: "hooks.py"
    conflicting_agents: ["api-developer", "workflow-specialist"]
    resolution: "sequential_execution"
    
  - file_path: "custom_app/api/"
    conflicting_agents: ["api-architect", "api-developer"]
    resolution: "dependency_order"
```

#### Dependency Conflicts
```yaml
dependency_conflicts:
  - dependency: "DocType structure"
    required_by: ["api-developer", "vue-spa-architect"]
    provided_by: ["doctype-designer"]
    resolution: "sequential_blocks"
```

### Step 5: Create Story Template

Using story-execution-mode-template.yaml, populate the story:

```yaml
story_metadata:
  title: "${USER_PROVIDED_TITLE}"
  epic: "${EPIC_NAME}"
  priority: "${ASSESSED_PRIORITY}"
  story_points: ${CALCULATED_POINTS}
  
execution_mode:
  recommended_mode: "${RECOMMENDED_MODE}"
  complexity_assessment: "${COMPLEXITY_LEVEL}"
  
parallel_execution:
  parallel_potential: ${HAS_PARALLEL_POTENTIAL}
  task_breakdown: ${TASK_ANALYSIS}
  conflict_analysis: ${CONFLICT_ASSESSMENT}
```

### Step 6: Generate Mode-Specific Guidance

For each execution mode, provide specific guidance:

#### Guided Mode Guidance
```markdown
## Guided Mode Execution Plan

**Interaction Points**:
1. Story requirement confirmation
2. Technical approach approval  
3. Implementation review
4. Final acceptance testing

**User Prompts**:
- "Review the proposed DocType structure"
- "Approve the API endpoint design"
- "Validate the UI components"
- "Confirm the workflow integration"

**Estimated Duration**: X minutes with Y interaction points
```

#### Sequential Mode Guidance
```markdown
## Sequential Mode Execution Plan

**Automation Level**: High
**Batch Processing**: 3 tasks per batch
**Checkpoint Frequency**: After each major task

**Execution Sequence**:
1. DocType design and creation
2. API architecture and implementation
3. Frontend component development
4. Integration and testing

**Estimated Duration**: X minutes unattended
```

#### Smart Parallel Mode Guidance
```markdown
## Smart Parallel Mode Execution Plan

**Parallel Blocks**:

**Block 1 - Foundation** (Parallel):
- doctype-designer: Create DocType structure
- api-architect: Design API endpoints
- Estimated Duration: 15 minutes

**Block 2 - Implementation** (Parallel):
- api-developer: Implement API endpoints
- vue-spa-architect: Build UI components
- Dependencies: Block 1 completion
- Estimated Duration: 25 minutes

**Block 3 - Integration** (Sequential):
- workflow-specialist: Workflow integration
- Dependencies: Block 1 & 2 completion
- Estimated Duration: 10 minutes

**Total Estimated Duration**: 50 minutes
**Efficiency Gain**: 35% faster than sequential
```

### Step 7: Quality Gate Definition

Define execution mode-appropriate quality gates:

```yaml
quality_gates:
  guided_mode:
    - name: "user_approval_checkpoint"
      frequency: "after_each_major_component"
      mandatory: true
      
  sequential_mode:
    - name: "automated_testing_checkpoint"
      frequency: "after_each_batch"
      mandatory: true
      
  smart_parallel_mode:
    - name: "parallel_conflict_detection"
      frequency: "real_time"
      mandatory: true
    - name: "block_completion_validation"
      frequency: "after_each_block"
      mandatory: true
```

### Step 8: GitHub Integration Setup

If GitHub integration is enabled:

```yaml
github_integration:
  issue_management:
    create_sub_issues: ${MODE_REQUIRES_SUB_ISSUES}
    sync_progress: true
    
  progress_reporting:
    guided_mode: "on_user_approval"
    sequential_mode: "on_batch_completion"
    smart_parallel_mode: "on_block_completion"
```

### Step 9: Story Validation

Validate the created story against criteria:

```yaml
validation_checklist:
  - story_follows_user_story_format: true
  - acceptance_criteria_testable: true
  - technical_requirements_complete: true
  - execution_mode_analysis_complete: true
  - parallel_analysis_appropriate: true
  - quality_gates_defined: true
  - github_integration_configured: true
```

### Step 10: Story Output

Generate the final story document:

```markdown
# ERPNext Story: ${STORY_TITLE}

## User Story
As a ${USER_ROLE}, I want ${FUNCTIONALITY} so that ${BUSINESS_VALUE}.

## Execution Mode Recommendation
**Recommended Mode**: ${RECOMMENDED_MODE}
**Reasoning**: ${MODE_REASONING}
**Estimated Duration**: ${ESTIMATED_DURATION}

## Parallel Execution Analysis
${PARALLEL_ANALYSIS_SUMMARY}

## Implementation Plan
${MODE_SPECIFIC_IMPLEMENTATION_PLAN}

## Quality Gates
${QUALITY_GATE_SUMMARY}

## GitHub Integration
${GITHUB_INTEGRATION_CONFIG}
```

### Step 11: Save and Register

Save the story and register it in the system:

```bash
# Save story file
save_to: "${EPIC_DIR}/${STORY_ID}-${STORY_TITLE}.md"

# Update epic tracking
register_in: "${EPIC_DIR}/epic-tracking.yaml"

# Create GitHub issue if enabled
github_issue: "${GITHUB_ISSUE_NUMBER}"
```

## Success Criteria

Story creation is successful when:
- [ ] All user requirements captured
- [ ] Execution mode analysis completed
- [ ] Parallel potential assessed
- [ ] Mode-specific guidance provided
- [ ] Quality gates defined
- [ ] Story follows ERPNext patterns
- [ ] GitHub integration configured
- [ ] Story is actionable by specialized agents

## Error Handling

### Incomplete Requirements
If user provides incomplete information:
- Request specific missing details
- Provide examples of good requirements
- Do not proceed with incomplete information

### Conflicting Requirements
If requirements conflict with ERPNext patterns:
- Explain the conflict
- Suggest ERPNext-compatible alternatives
- Wait for user decision

### Mode Selection Conflicts
If recommended mode conflicts with user preference:
- Explain the reasoning for recommendation
- Present trade-offs clearly
- Allow user to override with documented risks

## Integration Points

This task integrates with:
- `coordination-workflow.yaml` for execution mode selection
- `parallel-analyzer` agent for conflict detection
- `development-coordinator` for execution routing
- `universal-context-detection-workflow` for safety protocols

## Usage Example

```bash
/bmadErpNext:agent:erpnext-scrum-master *mode-aware-draft
```

This will initiate the mode-aware story creation process with full execution analysis and parallel execution potential assessment.