# Agent Coordination Guide - How 29 Agents Work Together

## 🎭 The Cast of Characters
Our 29 agents are themed after Warehouse 13 & Eureka TV series characters, each with specialized expertise in ERPNext development.

## 🔄 Agent Coordination Flow

### The Universal Starting Point
```
EVERY task starts with:
universal-context-detection-workflow
    ↓
Determines context (TROUBLESHOOTING/NEW_DEVELOPMENT/ENHANCEMENT/MIGRATION)
    ↓
Activates appropriate safety protocols
    ↓
Routes to appropriate agent
```

## 📊 Agent Hierarchy & Routing

### Level 1: Management & Planning
```
business-analyst
    ↓ Creates requirements
erpnext-architect (Creates PRD & Architecture)
    ↓ Designs system → docs/prd.md, docs/architecture.md
erpnext-product-owner
    ↓ Creates epics → docs/epics/
erpnext-scrum-master
    ↓ Creates stories → docs/stories/
development-coordinator
    ↓ Routes to specialists
```

### Level 2: Development Specialists
```
development-coordinator routes based on task type:

DocType Tasks → doctype-designer
    ↓ Creates in {app_name}/{module_name}/doctype/
    
API Tasks → api-architect → api-developer
    ↓ Creates in {app_name}/api/
    
Frontend Tasks → vue-spa-architect
    ↓ Creates in {app_name}/public/js/
    
Workflow Tasks → workflow-specialist
    ↓ Creates in {app_name}/{module_name}/workflow/
```

### Level 3: Quality & Validation
```
All work flows through:
testing-specialist
    ↓ Creates in tests/results/
frappe-compliance-validator
    ↓ Creates in tests/compliance/
quality-gate-enforcement-workflow
    ↓ Blocks non-compliant handoffs
```

## 🗂️ How Agents Find Files

### Every Agent Has folder_knowledge
```yaml
folder_knowledge:
  expansion_pack:
    agents: ".bmad-erpnext-v16/agents/"
    tasks: ".bmad-erpnext-v16/tasks/"
    templates: ".bmad-erpnext-v16/templates/"
  
  erpnext_app:
    prd: "docs/prd.md"
    architecture: "docs/architecture.md"
    project_context: "PROJECT_CONTEXT.yaml"
```

### File Discovery Process
1. **Load PROJECT_CONTEXT.yaml** - Master registry
2. **Check standard paths** - From folder_knowledge
3. **Follow explicit references** - In handoffs
4. **Update registry** - When creating files

## 🤝 Handoff Patterns

### Pattern 1: Planning → Development
```
erpnext-architect
    Creates: docs/prd.md
    Handoff includes: {path: "docs/prd.md"}
    ↓
erpnext-product-owner
    Reads: docs/prd.md (knows exact path)
    Creates: docs/epics/*.md
    ↓
development-coordinator
    Reads: docs/epics/*.md
    Routes to: appropriate specialist
```

### Pattern 2: Development → Testing
```
api-developer
    Creates: customer_portal/api/customer.py
    Handoff includes: {path: "customer_portal/api/customer.py", methods: ["get_customer_data"]}
    ↓
testing-specialist
    Reads: customer_portal/api/customer.py
    Creates: tests/results/api-test-results.json
```

### Pattern 3: Testing → Compliance
```
testing-specialist
    Creates: tests/results/latest.json
    Handoff includes: {test_results: "tests/results/latest.json"}
    ↓
frappe-compliance-validator
    Reads: tests/results/latest.json
    Scans: All files using folder_knowledge paths
    Creates: tests/compliance/audit.md
```

## 🚦 Quality Gate Coordination

### Pre-Handoff Validation
```
Any Agent
    ↓ Completes work
quality-gate-enforcement-workflow
    ↓ Validates:
        - Structure compliance (uses folder_knowledge)
        - Test results (reads tests/results/)
        - Documentation (checks docs/)
        - Frappe-first compliance
    ↓ If passed:
Next Agent
    ↓ If failed:
BLOCKED - Must fix issues
```

## 💡 Real-World Scenarios

### Scenario 1: Creating a New DocType
```
1. User: "Create a Customer Order DocType"
2. development-coordinator activates
3. Routes to doctype-designer
4. doctype-designer:
   - Reads: docs/prd.md (from folder_knowledge)
   - Creates: customer_portal/customer_management/doctype/CustomerOrder/
   - Updates: PROJECT_CONTEXT.yaml
5. Handoff to api-developer
6. api-developer:
   - Reads handoff with explicit path
   - Creates controller methods
7. Quality gates validate
8. Handoff to testing-specialist
```

### Scenario 2: Troubleshooting
```
1. User: "App is crashing on customer page"
2. universal-context-detection: TROUBLESHOOTING
3. Routes to diagnostic-specialist
4. diagnostic-specialist:
   - Reads: customer_portal/customer_management/page/customer/
   - Analyzes: Using paths from folder_knowledge
   - Creates: tests/results/diagnostic-report.json
5. Handoff to appropriate fixer
```

### Scenario 3: Full App Development
```
1. business-analyst → Creates project brief
2. erpnext-architect → Creates docs/prd.md, docs/architecture.md
3. erpnext-product-owner → Shards into docs/epics/
4. erpnext-scrum-master → Creates docs/stories/
5. development-coordinator → Routes each story:
   - DocType stories → doctype-designer
   - API stories → api-developer
   - Frontend stories → vue-spa-architect
6. All work → testing-specialist
7. Final validation → frappe-compliance-validator
```

## 🔍 Agent Discovery Commands

### Find Agent Capabilities
```bash
# See what an agent can do
cat .bmad-erpnext-v16/agents/erpnext-architect.md | grep capabilities -A 20
```

### Check Agent Dependencies
```bash
# See what files an agent needs
cat .bmad-erpnext-v16/agents/api-developer.md | grep dependencies -A 10
```

### Verify Agent Has folder_knowledge
```bash
# Confirm agent knows paths
grep "folder_knowledge:" .bmad-erpnext-v16/agents/testing-specialist.md
```

## 📋 Coordination Rules

### MANDATORY Rules
1. **All agents MUST have folder_knowledge**
2. **All handoffs MUST include explicit paths**
3. **All agents MUST update PROJECT_CONTEXT.yaml**
4. **All work MUST pass quality gates**
5. **All agents MUST follow UNIVERSAL-FOLDER-STRUCTURE.md**

### Coordination Best Practices
- Start with universal context detection
- Use development-coordinator for routing
- Include file paths in every handoff
- Update PROJECT_CONTEXT.yaml immediately
- Validate structure before handoff

## 🚨 Common Coordination Issues

### Issue: "Agent can't find file"
**Solution**: Check agent has folder_knowledge section

### Issue: "Handoff blocked"
**Solution**: Run quality gates, fix violations

### Issue: "Wrong agent activated"
**Solution**: Use development-coordinator for routing

### Issue: "Files in wrong location"
**Solution**: Follow UNIVERSAL-FOLDER-STRUCTURE.md exactly

## 📊 Agent Utilization Status

### Highly Active Agents (Daily Use)
- development-coordinator (routing)
- erpnext-architect (planning)
- api-developer (backend)
- vue-spa-architect (frontend)
- testing-specialist (quality)

### Specialized Agents (As Needed)
- diagnostic-specialist (troubleshooting)
- refactoring-expert (code improvement)
- documentation-specialist (auto-docs)
- app-auditor (quality metrics)
- data-integration-expert (migrations)

### Support Agents (Background)
- pre-check-agent (validation)
- post-check-agent (verification)
- code-cleanup-specialist (maintenance)

## 🎯 Success Metrics

### Good Coordination Indicators
- ✅ Zero "file not found" errors
- ✅ All handoffs complete successfully
- ✅ Quality gates pass consistently
- ✅ PROJECT_CONTEXT.yaml always current
- ✅ No manual file searching needed

### Poor Coordination Indicators
- ❌ Agents searching for files
- ❌ Handoffs failing
- ❌ Quality gates blocking frequently
- ❌ PROJECT_CONTEXT.yaml outdated
- ❌ Files in non-standard locations

---

**Remember**: The power of BMAD Method comes from agents working together seamlessly. The folder_knowledge system ensures they always know where everything is!