# Universal Code Safety Protocol
## Mandatory Safety Checks for All ERPNext Coding Agents

**Last Updated**: 2025-08-17  
**Applies To**: All agents that create, modify, or delete code files  
**Priority**: CRITICAL - Cannot be bypassed  

---

## 🚨 CRITICAL RULE FOR ALL CODING AGENTS

**BEFORE** creating, modifying, or deleting ANY code file, ALL agents MUST:

### 1. DEPENDENCY ANALYSIS REQUIRED
```yaml
safety_check_required: true
mandatory_analysis_task: "analyze-app-dependencies"
analysis_scope:
  - "All DocTypes and their field relationships"
  - "Business logic patterns (especially checkbox conditional logic)"
  - "Import dependencies between files"
  - "Function usage across the app"
  - "Critical workflow dependencies"
```

### 2. PROTECTED PATTERNS - NEVER MODIFY WITHOUT ANALYSIS
```python
# Checkbox-based conditional logic
if self.checkbox_field:
    # Business logic here

# Field-based conditional operations  
if doc.get('field_name'):
    # Critical business rules

# Workflow state changes
if self.workflow_state == 'Approved':
    # State-dependent logic

# Permission-based logic
if frappe.has_permission('DocType', 'write'):
    # Permission-dependent operations
```

### 3. IMPORT DEPENDENCY SAFETY
```python
# NEVER modify files that are heavily imported without:
# 1. Mapping all dependent files
# 2. Planning import updates
# 3. Testing all dependent functionality
# 4. Creating rollback procedures
```

---

## 📋 MANDATORY SAFETY CHECKLIST

### Pre-Code-Change Requirements
- [ ] **App dependency analysis completed** (analyze-app-dependencies task)
- [ ] **All DocType fields mapped** (especially checkboxes and validation logic)
- [ ] **Business logic documented** (conditional statements, workflows)
- [ ] **Import dependency graph created** (who imports what)
- [ ] **Risk assessment performed** (impact of proposed changes)
- [ ] **Backup strategy confirmed** (individual file backups + rollback plan)

### During Code Changes
- [ ] **Individual file backup created** before any modification
- [ ] **Import statements updated** if files are moved/renamed
- [ ] **Dependent files identified** and impact assessed
- [ ] **Functionality tested** at each step
- [ ] **Rollback capability verified** before proceeding

### Post-Code-Change Validation
- [ ] **All imports resolve correctly** (no broken dependencies)
- [ ] **DocType functionality intact** (create, save, submit operations)
- [ ] **Conditional logic works** (checkbox fields, validation rules)
- [ ] **Workflows function** (state transitions, approvals)
- [ ] **API endpoints respond** (authentication, permissions)
- [ ] **Reports generate** (data accuracy, exports)

---

## 🛡️ AGENT INTEGRATION REQUIREMENTS

### For New Code Creation Agents
```yaml
commands:
  - name: "*analyze-first"
    description: "MANDATORY: Analyze app dependencies before any code changes"
    dependencies: ["tasks/analyze-app-dependencies.md"]
    required_before: ["*create", "*modify", "*refactor", "*delete"]
```

### For Modification Agents  
```yaml
safety_protocols:
  before_modification:
    - "Execute analyze-app-dependencies task"
    - "Document all affected components"
    - "Create individual file backups"
    - "Plan import dependency updates"
  
  during_modification:
    - "Test functionality at each step"
    - "Update import statements systematically"
    - "Validate no broken dependencies"
  
  after_modification:
    - "Run comprehensive functionality tests"
    - "Verify all workflows still work"
    - "Confirm no performance degradation"
```

### For Deletion/Cleanup Agents
```yaml
deletion_safety:
  prohibited_without_analysis:
    - "Files with conditional logic (if/else statements)"
    - "Files imported by multiple other files"
    - "DocType controllers with validation logic"
    - "Files containing checkbox field references"
    - "Workflow transition functions"
    - "API endpoint definitions"
```

---

## 🔧 IMPLEMENTATION PATTERN

### Add to Agent Customization Field
```yaml
customization: |
  CRITICAL SAFETY REQUIREMENT: Before creating, modifying, or deleting ANY code files, 
  I MUST execute the analyze-app-dependencies task to understand:
  1. DocType field relationships (especially checkbox conditional logic)
  2. Import dependencies between files  
  3. Business logic patterns that could break
  4. Critical workflow dependencies
  
  I NEVER modify code without this analysis. I ALWAYS create individual file backups 
  and update import statements when files are moved. I VERIFY functionality at each step.
```

### Add to Commands Section
```yaml
commands:
  - name: "*safety-check"
    description: "Perform mandatory dependency analysis before code changes"
    dependencies: ["tasks/analyze-app-dependencies.md"]
    required: true
    
  # Existing commands must reference safety-check as prerequisite
  - name: "*create-[something]"
    description: "Create new code component"
    dependencies: ["..."]
    prerequisites: ["*safety-check"]
```

### Add to Workflow Section
```yaml
workflow:
  mandatory_safety_flow:
    1_analysis:
      - "Execute analyze-app-dependencies task"
      - "Document all existing functionality"
      - "Map critical dependencies"
    
    2_planning:
      - "Plan changes based on analysis"
      - "Identify potential impact areas"
      - "Create backup and rollback strategy"
    
    3_execution:
      - "Create individual file backups"
      - "Make changes incrementally"
      - "Test functionality at each step"
      - "Update import dependencies"
    
    4_validation:
      - "Verify all functionality works"
      - "Check for broken dependencies"
      - "Confirm performance is maintained"
```

---

## 🎯 SPECIFIC AGENT UPDATES NEEDED

### High Priority Agents (Code Creators/Modifiers)
1. **doctype-designer** - Creates DocTypes and controllers
2. **api-developer** - Creates API endpoints and functions
3. **refactoring-expert** - Modifies existing code
4. **vue-frontend-architect** - Creates frontend components
5. **workflow-specialist** - Creates workflow logic
6. **api-architect** - Designs API structure

### Medium Priority Agents (Code Readers/Analyzers)
1. **diagnostic-specialist** - May suggest code changes
2. **frappe-compliance-validator** - May require code fixes
3. **testing-specialist** - May modify test files

### Integration Agents (Orchestrators)
1. **main-dev-coordinator** - Coordinates code changes
2. **app-scaffold-coordinator** - Creates app structure

---

## 🚀 ROLLOUT STRATEGY

### Phase 1: Core Safety Infrastructure (Complete)
- ✅ analyze-app-dependencies task created
- ✅ Universal safety protocol documented
- ✅ App cleanup checklist available

### Phase 2: High-Risk Agent Updates (Next)
- Update doctype-designer agent
- Update api-developer agent  
- Update refactoring-expert agent
- Update workflow-specialist agent

### Phase 3: Medium-Risk Agent Updates
- Update diagnostic-specialist agent
- Update compliance-validator agent
- Update testing-specialist agent

### Phase 4: Orchestrator Updates
- Update coordinator agents
- Update architectural agents

---

## ✅ SUCCESS CRITERIA

### For Each Updated Agent
- [ ] **Safety protocol integrated** in customization field
- [ ] **Mandatory analysis command** added to commands
- [ ] **Prerequisite dependencies** defined for code-changing commands
- [ ] **Workflow safety steps** documented
- [ ] **Testing requirements** specified

### System-Wide Safety  
- [ ] **No agent can modify code** without dependency analysis
- [ ] **All checkbox conditional logic** protected from accidental deletion
- [ ] **Import dependencies** automatically managed
- [ ] **Rollback capabilities** available for all changes
- [ ] **Functionality validation** required before completion

Remember: **Every line of code matters. Every dependency has a purpose. Always analyze before changing!**