# Analyze Story Conflicts

## Task Description
Analyze an existing ERPNext story or set of stories to identify potential conflicts, dependencies, and parallelization opportunities for optimal execution mode selection.

## Prerequisites
- Existing story or stories to analyze
- Access to parallel-conflict-rules.yaml
- Understanding of ERPNext development patterns
- Agent capability knowledge

## Process

### Step 1: Story Analysis Input
**Elicit**: true
**Prompt**: "Let's analyze your ERPNext story for conflicts and parallelization potential. Please provide:"

```
1. **Story Information**:
   - Story title or epic name
   - Story requirements or existing story document
   - Associated GitHub issue (if any)

2. **Technical Components** (if known):
   - DocTypes involved
   - API endpoints needed
   - Frontend components required
   - Workflow changes
   - Integration requirements

3. **Analysis Scope**:
   - Single story analysis
   - Multi-story batch analysis
   - Epic-level analysis
   - Cross-story dependency analysis

4. **Current Challenges** (if any):
   - Known conflicts or issues
   - Previous execution problems
   - Performance concerns
   - Quality issues
```

**Instructions**: Wait for user response. Do not proceed without this information.

### Step 2: Technical Component Breakdown

Analyze technical components for conflict potential:

```yaml
component_analysis:
  doctype_components:
    - name: "${DOCTYPE_NAME}"
      creation_required: true
      modification_required: false
      relationships: ["${RELATED_DOCTYPES}"]
      fields_added: ["${NEW_FIELDS}"]
      permissions_changed: true
      
  api_components:
    - endpoint: "/api/method/${METHOD_NAME}"
      method: "POST"
      authentication_required: true
      depends_on_doctypes: ["${DEPENDENT_DOCTYPES}"]
      whitelisting_required: true
      
  frontend_components:
    - component_type: "Vue SPA"
      component_name: "${COMPONENT_NAME}"
      depends_on_apis: ["${API_DEPENDENCIES}"]
      file_locations: ["${FILE_PATHS}"]
      
  workflow_components:
    - workflow_name: "${WORKFLOW_NAME}"
      affects_doctypes: ["${AFFECTED_DOCTYPES}"]
      approval_steps: ${STEP_COUNT}
      triggers_required: true
```

### Step 3: File System Conflict Analysis

Analyze potential file system conflicts:

```yaml
file_system_analysis:
  high_conflict_files:
    - file_path: "hooks.py"
      reason: "Multiple agents modify app configuration"
      affected_agents: ["api-developer", "workflow-specialist"]
      conflict_probability: "high"
      resolution_strategy: "sequential_modification"
      
    - file_path: "manifest.json"
      reason: "App manifest updates"
      affected_agents: ["multiple"]
      conflict_probability: "medium"
      resolution_strategy: "merge_at_end"
      
  medium_conflict_files:
    - file_path: "api/*.py"
      reason: "API endpoint creation"
      affected_agents: ["api-architect", "api-developer"]
      conflict_probability: "medium"
      resolution_strategy: "dependency_ordering"
      
  safe_parallel_files:
    - file_path: "doctype/*/custom_doctype.json"
      reason: "Independent DocType files"
      affected_agents: ["doctype-designer"]
      conflict_probability: "low"
      resolution_strategy: "parallel_safe"
```

### Step 4: Agent Dependency Analysis

Map agent dependencies and constraints:

```yaml
agent_dependency_mapping:
  independent_work:
    - agent: "doctype-designer"
      work: "DocType schema creation"
      prerequisites: ["Requirements understanding"]
      outputs: ["DocType JSON", "Python controllers"]
      enables: ["api-architect", "api-developer"]
      
    - agent: "api-architect"
      work: "API structure design"
      prerequisites: ["Requirements understanding"]
      outputs: ["API documentation", "Endpoint specifications"]
      enables: ["api-developer", "vue-spa-architect"]
      
  dependent_work:
    - agent: "api-developer"
      work: "API implementation"
      prerequisites: ["DocType schemas", "API architecture"]
      outputs: ["Working API endpoints"]
      enables: ["vue-spa-architect", "testing-specialist"]
      
    - agent: "vue-spa-architect"
      work: "Frontend implementation"
      prerequisites: ["API architecture", "UI design"]
      outputs: ["Vue components"]
      enables: ["testing-specialist"]
```

### Step 5: Temporal Conflict Analysis

Analyze timing and sequencing conflicts:

```yaml
temporal_analysis:
  strict_sequences:
    - sequence: "DocType → API → Frontend"
      reason: "Data model must exist before API can reference it"
      flexibility: "none"
      
    - sequence: "API Architecture → API Implementation"
      reason: "Implementation follows design"
      flexibility: "minimal"
      
  flexible_sequences:
    - parallel_group: ["DocType Design", "UI Mockups", "API Architecture"]
      reason: "Can work independently with requirements"
      synchronization_points: ["Before implementation phase"]
      
  blocking_dependencies:
    - blocker: "DocType creation"
      blocked: ["API implementation", "Frontend data binding"]
      unblock_criteria: "DocType schema finalized"
```

### Step 6: Resource Conflict Analysis

Analyze shared resource conflicts:

```yaml
resource_conflict_analysis:
  database_resources:
    - resource: "Database schema"
      conflicting_operations: ["DocType creation", "Field additions"]
      resolution: "Sequential schema changes"
      
    - resource: "Permission system"
      conflicting_operations: ["Role assignments", "Permission rules"]
      resolution: "Merge permission changes"
      
  file_system_resources:
    - resource: "Configuration files"
      conflicting_operations: ["hooks.py updates", "manifest changes"]
      resolution: "Final merge step"
      
    - resource: "API directory"
      conflicting_operations: ["File creation", "Import updates"]
      resolution: "Namespace separation"
```

### Step 7: Quality Gate Impact Analysis

Analyze how conflicts affect quality gates:

```yaml
quality_gate_impact:
  structure_validation:
    parallel_impact: "minimal"
    additional_checks_needed: ["Cross-agent validation"]
    
  integration_testing:
    parallel_impact: "significant"
    additional_checks_needed: ["Parallel integration tests", "Conflict detection tests"]
    
  performance_testing:
    parallel_impact: "moderate"
    additional_checks_needed: ["Parallel execution performance", "Resource contention"]
```

### Step 8: Parallelization Opportunity Assessment

Assess opportunities for parallel execution:

```yaml
parallelization_assessment:
  high_potential_parallel:
    - tasks: ["DocType design", "API architecture", "UI mockups"]
      estimated_time_saving: "40%"
      conflict_risk: "low"
      coordination_overhead: "minimal"
      
  medium_potential_parallel:
    - tasks: ["API implementation", "Frontend development"]
      estimated_time_saving: "25%"
      conflict_risk: "medium"
      coordination_overhead: "moderate"
      
  not_suitable_parallel:
    - tasks: ["Workflow configuration", "Final integration"]
      estimated_time_saving: "0%"
      conflict_risk: "high"
      coordination_overhead: "high"
```

### Step 9: Conflict Resolution Strategy Development

Develop strategies to resolve identified conflicts:

```yaml
conflict_resolution_strategies:
  prevention_strategies:
    - strategy: "namespace_separation"
      applicable_to: ["API file creation", "Component naming"]
      implementation: "Prefix agent work with unique identifiers"
      
    - strategy: "temporal_separation"
      applicable_to: ["Database schema changes", "Configuration updates"]
      implementation: "Sequential execution windows"
      
  detection_strategies:
    - strategy: "real_time_monitoring"
      applicable_to: ["File system changes", "Git conflicts"]
      implementation: "File system watchers and Git hooks"
      
  resolution_strategies:
    - strategy: "automatic_merge"
      applicable_to: ["Non-conflicting changes"]
      implementation: "Automated merge with validation"
      
    - strategy: "manual_intervention"
      applicable_to: ["Complex logic conflicts"]
      implementation: "Pause execution, human resolution"
```

### Step 10: Execution Mode Recommendations

Generate execution mode recommendations based on analysis:

```yaml
execution_mode_recommendations:
  guided_mode:
    suitable: true
    reasoning: "Complex business logic requires validation"
    estimated_duration: "${GUIDED_DURATION} minutes"
    benefits: ["Quality assurance", "Risk mitigation"]
    drawbacks: ["Slower execution", "User interaction required"]
    
  sequential_mode:
    suitable: true
    reasoning: "Clear dependencies, minimal conflicts"
    estimated_duration: "${SEQUENTIAL_DURATION} minutes"
    benefits: ["Predictable execution", "No conflict risk"]
    drawbacks: ["Longer execution time", "No parallelization benefit"]
    
  smart_parallel_mode:
    suitable: ${PARALLEL_SUITABLE}
    reasoning: "${PARALLEL_REASONING}"
    estimated_duration: "${PARALLEL_DURATION} minutes"
    benefits: ["Faster execution", "Efficient resource usage"]
    drawbacks: ["Conflict risk", "Coordination complexity"]
    conflict_mitigation: "${CONFLICT_MITIGATION_PLAN}"
```

### Step 11: Risk Assessment Matrix

Create comprehensive risk assessment:

```yaml
risk_matrix:
  technical_risks:
    - risk: "File merge conflicts"
      probability: "${CONFLICT_PROBABILITY}"
      impact: "medium"
      mitigation: "${CONFLICT_MITIGATION}"
      
    - risk: "Dependency violations"
      probability: "${DEPENDENCY_RISK}"
      impact: "high"
      mitigation: "${DEPENDENCY_MITIGATION}"
      
  process_risks:
    - risk: "Agent coordination failure"
      probability: "low"
      impact: "medium"
      mitigation: "Fallback to sequential mode"
      
  quality_risks:
    - risk: "Integration issues"
      probability: "${INTEGRATION_RISK}"
      impact: "high"
      mitigation: "Enhanced integration testing"
```

### Step 12: Optimization Recommendations

Provide optimization recommendations:

```yaml
optimization_recommendations:
  story_decomposition:
    - recommendation: "Split large story into smaller, independent stories"
      applicable_when: "High conflict risk and complex dependencies"
      benefits: ["Reduced conflict risk", "Better parallelization"]
      
  dependency_reduction:
    - recommendation: "Reduce inter-component dependencies"
      applicable_when: "Many blocking dependencies identified"
      benefits: ["More parallel opportunities", "Simpler execution"]
      
  execution_strategy:
    - recommendation: "Hybrid execution approach"
      applicable_when: "Mixed parallel and sequential components"
      benefits: ["Optimized time and quality", "Risk mitigation"]
```

### Step 13: Generate Analysis Report

Create comprehensive analysis report:

```markdown
# Story Conflict Analysis Report

## Executive Summary
- **Story**: ${STORY_TITLE}
- **Analysis Date**: ${ANALYSIS_DATE}
- **Recommended Mode**: ${RECOMMENDED_MODE}
- **Risk Level**: ${OVERALL_RISK_LEVEL}
- **Parallelization Potential**: ${PARALLEL_POTENTIAL}

## Component Analysis
${COMPONENT_BREAKDOWN}

## Conflict Assessment
${CONFLICT_ANALYSIS_SUMMARY}

## Dependency Mapping
${DEPENDENCY_ANALYSIS}

## Execution Recommendations
${EXECUTION_MODE_RECOMMENDATIONS}

## Risk Mitigation
${RISK_MITIGATION_STRATEGIES}

## Optimization Opportunities
${OPTIMIZATION_RECOMMENDATIONS}

## Implementation Plan
${IMPLEMENTATION_PLAN}
```

### Step 14: Save Analysis Results

Save analysis for future reference:

```bash
# Save analysis report
save_to: ".bmad-project/analysis/${STORY_ID}-conflict-analysis.md"

# Update story metadata
update_file: "${STORY_FILE}"
add_section: "conflict_analysis"

# Register in analysis database
register_in: ".bmad-project/analysis/analysis-registry.yaml"
```

## Success Criteria

Conflict analysis is successful when:
- [ ] All technical components identified
- [ ] File system conflicts mapped
- [ ] Agent dependencies analyzed
- [ ] Temporal conflicts identified
- [ ] Resource conflicts assessed
- [ ] Parallelization opportunities evaluated
- [ ] Risk assessment completed
- [ ] Execution mode recommendations provided
- [ ] Optimization suggestions generated
- [ ] Analysis report created

## Error Handling

### Incomplete Information
If story information is incomplete:
- Request specific missing details
- Analyze available information with assumptions documented
- Recommend gathering additional information

### Complex Dependencies
If dependencies are too complex to analyze:
- Recommend story decomposition
- Suggest simplified approach
- Document areas needing manual analysis

### High Conflict Risk
If conflict risk is unacceptably high:
- Recommend alternative approaches
- Suggest story restructuring
- Document risk mitigation requirements

## Integration Points

This task integrates with:
- `parallel-analyzer` agent for automated conflict detection
- `development-coordinator` for execution planning
- `quality-gate-enforcement-workflow` for quality assurance
- All specialized development agents for component analysis

## Usage Example

```bash
/bmadErpNext:agent:erpnext-scrum-master *conflict-analysis
```

This initiates comprehensive conflict analysis for story parallelization and execution mode optimization.