# Agent Context Requirements - Context-Adaptive System
## What Every Agent MUST Know Before Taking Action

**PROBLEM**: Agents operate with wrong context assumptions - troubleshooting commands during planning phases.
**SOLUTION**: Context-adaptive mandatory gathering based on work type.

---

## 🎯 The Context-Adaptive Mandate

### STEP 1: Determine Context Type

Every agent MUST first identify the work context:

```yaml
context_detection:
  indicators:
    TROUBLESHOOTING: ["error messages", "broken functionality", "system down", "bug reports"]
    NEW_DEVELOPMENT: ["requirements gathering", "planning phase", "from scratch", "new feature"]
    ENHANCEMENT: ["modify existing", "improve performance", "add capability", "refactor"]
    MIGRATION: ["convert system", "data migration", "workflow transformation", "platform change"]
```

### STEP 2: Context-Specific Gathering

Based on detected context type, gather appropriate information:

```yaml
TROUBLESHOOTING_context:
  environment:
    working_directory: "pwd"
    git_status: "git status"
    error_logs: "tail -20 ../logs/frappe.log"
    recent_changes: "git log --oneline -5"
    
  problem_analysis:
    error_message: "Exact error text"
    when_occurs: "Steps to reproduce"
    what_works: "What's NOT broken"
    attempted_fixes: "Previous attempts and results"

NEW_DEVELOPMENT_context:
  environment:
    working_directory: "pwd"
    git_status: "git status"
    project_structure: "ls -la current directory"
    available_resources: "app structure, templates, examples"
    
  requirements_analysis:
    business_goals: "What are we trying to achieve?"
    functional_requirements: "What must the system do?"
    constraints: "Technical and business limitations"
    success_criteria: "How do we know when it's done?"

ENHANCEMENT_context:
  environment:
    working_directory: "pwd"
    git_status: "git status"
    current_state: "git diff"
    code_structure: "analyze existing implementation"
    
  improvement_analysis:
    current_limitations: "What needs to be improved?"
    desired_state: "What should the end result be?"
    impact_assessment: "What could this change break?"
    backwards_compatibility: "What must remain compatible?"

MIGRATION_context:
  environment:
    working_directory: "pwd"
    git_status: "git status"
    source_analysis: "understand current system"
    target_analysis: "understand destination system"
    
  transformation_analysis:
    data_mapping: "How does data translate?"
    workflow_mapping: "How do processes translate?"
    compatibility_issues: "What won't transfer cleanly?"
    validation_strategy: "How do we verify success?"
```

### Universal Context (Required for ALL types):

```yaml
universal_requirements:
  app_structure:
    app_name: "The app being worked on"
    modules: "Relevant modules"
    dependencies: "Other apps that matter"
    
  business_context:
    purpose: "What this serves users"
    critical_features: "What MUST keep working"
    stakeholders: "Who is affected"
    
  safety_preparation:
    rollback_plan: "How to undo changes"
    testing_strategy: "How to verify success"
    documentation_plan: "What to document"
```

---

## 📊 Context Gathering by Agent Type

### For Code Development Agents
```bash
# MUST run before coding:
pwd                                          # Where am I?
ls -la                                       # What's here?
git status                                   # What's changed?
git log --oneline -5                        # Recent commits
grep -r "TODO\|FIXME\|XXX" --include="*.py" # Known issues
bench --site [site] doctor                  # System health
```

### For Debugging Agents
```bash
# MUST run before debugging:
tail -50 ../logs/frappe.log                 # Recent errors
bench --site [site] console                 # Test current state
find . -name "*.pyc" -delete                # Clear compiled files
bench --site [site] clear-cache             # Clear any cache issues
git diff                                     # Uncommitted changes
ps aux | grep python                        # Running processes
```

### For API Development Agents
```bash
# MUST check before API work:
grep -r "@frappe.whitelist" --include="*.py" # Existing endpoints
grep -r "frappe.call" --include="*.js"       # Frontend API calls
cat hooks.py | grep -A5 "override_whitelisted_methods" # Overrides
bench --site [site] show-config             # Site configuration
```

### For DocType Agents
```bash
# MUST verify before DocType changes:
ls -la */doctype/                           # Existing DocTypes
grep -r "Link.*[DocType]" --include="*.json" # Dependencies
bench --site [site] console
# Then: frappe.get_meta("[DocType]")        # Current structure
mysql -u root -p[password] [database] -e "SHOW TABLES LIKE 'tab%'" # DB tables
```

### For Frontend Agents
```bash
# MUST check before frontend work:
ls -la public/js/                           # JavaScript files
ls -la */page/                              # Existing pages
ls -la */workspace/                         # Workspaces
find . -name "*.bundle.js"                  # Bundle files
grep -r "frappe.pages" --include="*.js"     # Page definitions
```

---

## 🚨 Context Red Flags

### STOP if you don't know:
- ❌ Which site you're working on
- ❌ What the error message actually says
- ❌ What was working before
- ❌ What files were recently changed
- ❌ What the business logic should be
- ❌ Who uses this functionality

### STOP if you can't answer:
- ❓ "What specific problem am I solving?"
- ❓ "What could break if I change this?"
- ❓ "How will I know if my fix worked?"
- ❓ "What's the rollback plan?"
- ❓ "Why hasn't this been fixed before?"

---

## 📋 The Pre-Action Checklist

### Before ANY Action:

```markdown
## Context Verification Checklist

### Environment Context
- [ ] I know the working directory
- [ ] I know which app I'm modifying
- [ ] I know which site this is for
- [ ] I've checked git status

### Problem Context
- [ ] I have the exact error message
- [ ] I can reproduce the issue
- [ ] I know what still works
- [ ] I know what recently changed

### Code Context  
- [ ] I've read the relevant files
- [ ] I understand the business logic
- [ ] I know the dependencies
- [ ] I've checked for similar patterns

### Historical Context
- [ ] I know what's been tried
- [ ] I understand why previous fixes failed
- [ ] I've checked git history
- [ ] I've reviewed any comments/TODOs

### Impact Context
- [ ] I know who uses this
- [ ] I understand criticality
- [ ] I've assessed risk level
- [ ] I have a rollback plan
```

---

## 🔄 Context Handoff Between Agents

### When Switching Agents, Pass:

```yaml
context_handoff:
  current_state:
    working_directory: "/home/frappe/frappe-bench"
    active_app: "custom_app"
    active_file: "api/customer.py"
    last_error: "ImportError: No module named..."
    
  work_completed:
    - "Fixed import statement in hooks.py"
    - "Added permission check to API"
    - "Created backup at /tmp/backup_20240118"
    
  work_remaining:
    - "Test API endpoint with different users"
    - "Update frontend to handle new response"
    - "Add error handling for edge cases"
    
  known_issues:
    - "Cache needs clearing after changes"
    - "Frontend bundle needs rebuild"
    - "User permissions not fully tested"
    
  critical_warnings:
    - "DO NOT change line 45 - breaks integration"
    - "Customer DocType has custom fields"
    - "API used by mobile app - check compatibility"
```

---

## 🎭 Agent-Specific Context Templates

### API Developer Context
```python
# Required context before API work
context = {
    "endpoint": "/api/method/app.module.function",
    "http_method": "POST",
    "authentication": "token/session",
    "current_permissions": [],
    "consumers": ["web", "mobile", "integration"],
    "rate_limits": "100/hour",
    "last_modified": "date",
    "breaking_changes": []
}
```

### DocType Designer Context
```python
# Required context before DocType work
context = {
    "doctype_name": "Customer",
    "parent_type": True,
    "child_tables": ["Customer Address"],
    "linked_doctypes": ["Sales Order", "Invoice"],
    "custom_fields": [],
    "permissions": {},
    "workflows": [],
    "reports_using": []
}
```

### Frontend Developer Context
```javascript
// Required context before frontend work
context = {
    app_name: "custom_app",
    page_type: "Form/List/Page",
    framework: "Vue/React/Vanilla",
    dependencies: ["frappe", "jquery"],
    bundle_location: "public/js/",
    build_command: "bench build",
    cache_strategy: "aggressive/normal",
    mobile_support: true/false
}
```

---

## 🛠️ Context Gathering Tools

### Quick Context Script
```bash
#!/bin/bash
# Save as: gather_context.sh

echo "=== ENVIRONMENT CONTEXT ==="
pwd
echo "Site: $(bench use 2>/dev/null || echo 'Not in bench')"
echo "Branch: $(git branch --show-current)"

echo -e "\n=== RECENT CHANGES ==="
git status --short
git log --oneline -3

echo -e "\n=== ERROR CONTEXT ==="
tail -20 ../logs/frappe.log | grep -i error || echo "No recent errors"

echo -e "\n=== SYSTEM HEALTH ==="
bench doctor 2>/dev/null || echo "Run from bench directory"

echo -e "\n=== RUNNING PROCESSES ==="
ps aux | grep -E "bench|python" | grep -v grep | wc -l
echo "processes running"
```

### Python Context Gatherer
```python
import frappe
import json
import os

def gather_app_context(app_name):
    """Gather comprehensive context about an app"""
    
    context = {
        "app_name": app_name,
        "path": frappe.get_app_path(app_name),
        "version": frappe.get_version(app_name),
        "modules": [],
        "doctypes": [],
        "api_methods": [],
        "hooks": {},
        "dependencies": []
    }
    
    # Get modules
    modules_path = os.path.join(context["path"], "modules.txt")
    if os.path.exists(modules_path):
        with open(modules_path) as f:
            context["modules"] = f.read().splitlines()
    
    # Get DocTypes
    for module in context["modules"]:
        doctype_path = os.path.join(context["path"], module, "doctype")
        if os.path.exists(doctype_path):
            context["doctypes"].extend(os.listdir(doctype_path))
    
    # Get hooks
    hooks = frappe.get_hooks(app_name=app_name)
    context["hooks"] = {
        "app_include_js": hooks.get("app_include_js", []),
        "app_include_css": hooks.get("app_include_css", []),
        "whitelisted_methods": hooks.get("override_whitelisted_methods", {})
    }
    
    return json.dumps(context, indent=2)
```

---

## 📢 The Context Battle Cry

**"NO ACTION WITHOUT CONTEXT!"**

An agent without context is like a surgeon operating blindfolded.

---

## 🎯 Implementation Requirement

### For ALL Agents:
1. **Context Gathering** must be first step
2. **Context Verification** before any change  
3. **Context Documentation** in all outputs
4. **Context Handoff** when switching agents

### Non-Negotiable:
- No code changes without environment context
- No debugging without error context
- No refactoring without dependency context
- No deployment without testing context

---

*This is MANDATORY for all agents. Context-free actions are prohibited.*