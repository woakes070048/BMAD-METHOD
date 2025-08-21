# Create Parallel Execution Story

## Task Description
Create an ERPNext user story specifically optimized for smart parallel execution, with detailed conflict analysis and parallel block planning.

## Prerequisites
- Epic or feature requirements defined
- Access to parallel-execution-template.yaml
- Understanding of agent capabilities and dependencies
- Parallel conflict rules loaded

## Process

### Step 1: Parallel Suitability Assessment
**Elicit**: true
**Prompt**: "Let's create a story optimized for parallel execution. I need to assess parallel suitability:"

```
1. **Story Requirements**:
   - What functionality needs to be implemented?
   - Which ERPNext module is this for?
   - What is the expected complexity level?

2. **Component Analysis**:
   - Will this require multiple DocTypes? (List them)
   - How many API endpoints are needed?
   - Are there frontend components required?
   - Does this involve workflow changes?
   - Are there external integrations?

3. **Independence Assessment**:
   - Can DocType creation happen independently?
   - Can API design happen before implementation?
   - Can UI design happen before backend completion?
   - Are there any strict ordering requirements?

4. **Resource Requirements**:
   - File paths that will be modified
   - Database tables that will be affected
   - Configuration files that need updates
```

**Instructions**: Wait for user response. Analyze for parallel execution potential.

### Step 2: Agent Dependency Mapping

Map required agents and their dependencies:

```yaml
agent_dependency_analysis:
  # Independent Agents (can run in parallel)
  independent_agents:
    - agent: "doctype-designer"
      tasks: ["Create DocType schemas", "Define relationships"]
      conflicts_with: []
      estimated_duration: "10-15 minutes"
      
    - agent: "api-architect" 
      tasks: ["Design API structure", "Define endpoints"]
      conflicts_with: []
      estimated_duration: "8-12 minutes"
      
    - agent: "ui-layout-designer"
      tasks: ["Design UI mockups", "Plan component structure"]
      conflicts_with: []
      estimated_duration: "12-18 minutes"

  # Dependent Agents (require previous work)
  dependent_agents:
    - agent: "api-developer"
      tasks: ["Implement API endpoints"]
      depends_on: ["doctype-designer", "api-architect"]
      estimated_duration: "15-20 minutes"
      
    - agent: "vue-spa-architect"
      tasks: ["Build Vue components"]
      depends_on: ["api-architect", "ui-layout-designer"]
      estimated_duration: "20-25 minutes"
      
    - agent: "workflow-specialist"
      tasks: ["Configure workflows"]
      depends_on: ["doctype-designer", "api-developer"]
      estimated_duration: "10-15 minutes"
```

### Step 3: File Conflict Analysis

Analyze potential file system conflicts:

```yaml
file_conflict_analysis:
  high_conflict_files:
    - file: "hooks.py"
      agents: ["api-developer", "workflow-specialist"]
      resolution: "sequential_access"
      
    - file: "manifest.json"
      agents: ["multiple"]
      resolution: "final_merge_step"
      
  medium_conflict_files:
    - file: "api/*.py"
      agents: ["api-architect", "api-developer"]
      resolution: "dependency_order"
      
  no_conflict_files:
    - file: "doctype/*/custom_doctype.json"
      agents: ["doctype-designer"]
      resolution: "parallel_safe"
      
    - file: "public/js/components/*.vue"
      agents: ["vue-spa-architect"]
      resolution: "parallel_safe"
```

### Step 4: Parallel Block Design

Design optimal parallel execution blocks:

```yaml
parallel_block_design:
  block_1:
    name: "Foundation Architecture"
    parallel_agents:
      - doctype-designer
      - api-architect
      - ui-layout-designer
    dependencies: []
    estimated_duration: "18 minutes" # Max of individual durations
    conflict_risk: "low"
    
  block_2:
    name: "Implementation"
    parallel_agents:
      - api-developer
      - vue-spa-architect
    dependencies: ["block_1"]
    estimated_duration: "25 minutes"
    conflict_risk: "medium"
    
  block_3:
    name: "Integration"
    sequential_agents:
      - workflow-specialist
    dependencies: ["block_1", "block_2"]
    estimated_duration: "15 minutes"
    conflict_risk: "low"
```

### Step 5: Conflict Resolution Strategy

Define how to handle potential conflicts:

```yaml
conflict_resolution:
  real_time_monitoring:
    - file_system_conflicts
    - git_merge_conflicts
    - database_schema_conflicts
    
  conflict_detection_rules:
    - rule: "same_file_modification"
      action: "pause_second_agent"
      recovery: "merge_changes_manually"
      
    - rule: "dependent_schema_change"
      action: "pause_dependent_agents"
      recovery: "restart_after_dependency_complete"
      
  fallback_strategies:
    - strategy: "convert_to_sequential"
      trigger: "multiple_conflicts_detected"
      
    - strategy: "isolate_conflicting_agents"
      trigger: "single_agent_conflict"
      
    - strategy: "pause_and_manual_resolve"
      trigger: "critical_conflict_detected"
```

### Step 6: Quality Gate Orchestration

Define parallel-aware quality gates:

```yaml
parallel_quality_gates:
  per_agent_gates:
    - gate: "agent_completion_validation"
      trigger: "agent_task_complete"
      actions: ["validate_output", "check_conflicts", "update_progress"]
      
  per_block_gates:
    - gate: "block_completion_validation"
      trigger: "all_block_agents_complete"
      actions: ["integration_test", "conflict_resolution", "prepare_next_block"]
      
  overall_gates:
    - gate: "final_integration_validation"
      trigger: "all_blocks_complete"
      actions: ["full_system_test", "documentation_update", "github_sync"]
```

### Step 7: Create Parallel Story Structure

Using parallel-execution-template.yaml:

```yaml
parallel_story_structure:
  execution_metadata:
    execution_mode: "smart_parallel"
    total_agents: ${AGENT_COUNT}
    parallel_blocks: ${BLOCK_COUNT}
    estimated_duration: "${TOTAL_DURATION} minutes"
    
  execution_blocks:
    ${BLOCK_DEFINITIONS}
    
  monitoring:
    real_time_tracking: true
    conflict_detection: true
    performance_metrics: true
    
  failure_recovery:
    strategies: ${CONFLICT_RESOLUTION_STRATEGIES}
```

### Step 8: Generate Execution Plan

Create detailed execution plan:

```markdown
# Parallel Execution Plan: ${STORY_TITLE}

## Overview
- **Total Duration**: ${ESTIMATED_DURATION} minutes
- **Parallel Blocks**: ${BLOCK_COUNT}
- **Efficiency Gain**: ${EFFICIENCY_PERCENTAGE}% over sequential
- **Risk Level**: ${RISK_ASSESSMENT}

## Execution Sequence

### Block 1: Foundation Architecture (Parallel)
**Duration**: 18 minutes
**Agents**: doctype-designer, api-architect, ui-layout-designer

**Parallel Tasks**:
- doctype-designer: Create ${DOCTYPE_LIST} DocType schemas
- api-architect: Design ${API_COUNT} API endpoints
- ui-layout-designer: Create UI mockups for ${COMPONENT_LIST}

**Success Criteria**:
- All DocType schemas validated
- API structure documented
- UI mockups approved
- No conflicts detected

### Block 2: Implementation (Parallel)
**Duration**: 25 minutes
**Dependencies**: Block 1 completion
**Agents**: api-developer, vue-spa-architect

**Parallel Tasks**:
- api-developer: Implement API endpoints based on architecture
- vue-spa-architect: Build Vue components based on mockups

**Conflict Monitoring**:
- Monitor hooks.py modifications
- Watch for API endpoint naming conflicts
- Track component registration conflicts

**Success Criteria**:
- All APIs implemented and tested
- All components built and integrated
- Integration tests passing

### Block 3: Integration (Sequential)
**Duration**: 15 minutes
**Dependencies**: Block 1 & 2 completion
**Agents**: workflow-specialist

**Sequential Tasks**:
- workflow-specialist: Configure ERPNext workflows
- Final integration testing
- Documentation updates

**Success Criteria**:
- Workflows properly configured
- End-to-end testing complete
- Documentation updated
```

### Step 9: Risk Assessment and Mitigation

Assess risks specific to parallel execution:

```yaml
risk_assessment:
  technical_risks:
    - risk: "File merge conflicts"
      probability: "medium"
      impact: "medium"
      mitigation: "Real-time conflict detection and pause mechanism"
      
    - risk: "Schema dependency violations"
      probability: "low"
      impact: "high"
      mitigation: "Dependency validation before each block"
      
  process_risks:
    - risk: "Agent coordination failures"
      probability: "low"
      impact: "medium"
      mitigation: "Automated fallback to sequential mode"
      
  business_risks:
    - risk: "Quality degradation due to parallel complexity"
      probability: "low"
      impact: "high"
      mitigation: "Enhanced quality gates and testing"
```

### Step 10: Performance Metrics Definition

Define metrics to track parallel execution efficiency:

```yaml
performance_metrics:
  efficiency_metrics:
    - metric: "time_savings"
      calculation: "(sequential_time - parallel_time) / sequential_time * 100"
      target: "> 30%"
      
    - metric: "agent_utilization"
      calculation: "active_agent_time / total_execution_time"
      target: "> 70%"
      
  quality_metrics:
    - metric: "conflict_rate"
      calculation: "conflicts_detected / total_parallel_operations"
      target: "< 5%"
      
    - metric: "fallback_rate"
      calculation: "fallbacks_to_sequential / total_executions"
      target: "< 10%"
      
  success_metrics:
    - metric: "completion_rate"
      calculation: "successful_parallel_executions / total_attempts"
      target: "> 95%"
```

### Step 11: Story Documentation

Generate comprehensive story documentation:

```markdown
# Parallel Execution Story: ${STORY_TITLE}

## User Story
As a ${USER_ROLE}, I want ${FUNCTIONALITY} so that ${BUSINESS_VALUE}.

## Parallel Execution Analysis
**Parallel Suitability**: High
**Complexity Assessment**: ${COMPLEXITY_LEVEL}
**Estimated Time Savings**: ${TIME_SAVINGS_PERCENTAGE}%

## Execution Blocks
${EXECUTION_BLOCK_DETAILS}

## Conflict Analysis
${CONFLICT_ANALYSIS_SUMMARY}

## Quality Assurance
${QUALITY_GATE_SUMMARY}

## Risk Mitigation
${RISK_MITIGATION_PLAN}

## Success Metrics
${PERFORMANCE_METRICS_SUMMARY}
```

### Step 12: Integration Setup

Configure integration with parallel execution system:

```yaml
integration_setup:
  coordinator_config:
    agent: "development-coordinator"
    execution_mode: "smart_parallel"
    parallel_config_file: "${STORY_ID}-parallel-config.yaml"
    
  analyzer_config:
    agent: "parallel-analyzer"
    conflict_rules: "parallel-conflict-rules.yaml"
    monitoring_interval: "30 seconds"
    
  github_config:
    progress_updates: "per_block_completion"
    conflict_reporting: "immediate"
    metrics_tracking: "enabled"
```

## Success Criteria

Parallel story creation is successful when:
- [ ] Parallel execution blocks properly defined
- [ ] Agent dependencies mapped correctly
- [ ] File conflicts identified and mitigation planned
- [ ] Quality gates adapted for parallel execution
- [ ] Performance metrics defined
- [ ] Risk assessment completed
- [ ] Fallback strategies documented
- [ ] Integration with parallel execution system configured

## Error Handling

### Non-Parallelizable Story
If story cannot be parallelized:
- Document the blocking factors
- Recommend alternative execution modes
- Suggest story decomposition if possible

### Complex Dependencies
If dependencies are too complex:
- Simplify the parallel blocks
- Increase sequential components
- Reduce parallel ambition

### High Conflict Risk
If conflict risk is unacceptable:
- Recommend sequential execution
- Suggest story splitting
- Document conflict mitigation strategies

## Integration Points

This task integrates with:
- `parallel-analyzer` agent for conflict detection
- `development-coordinator` for execution orchestration
- `parallel-failure-recovery-workflow` for error handling
- `quality-gate-enforcement-workflow` for validation

## Usage Example

```bash
/bmadErpNext:agent:erpnext-scrum-master *parallel-story
```

This initiates creation of a story specifically optimized for smart parallel execution with comprehensive conflict analysis and block planning.