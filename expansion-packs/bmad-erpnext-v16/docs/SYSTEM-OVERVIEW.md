# BMAD Method v16 - Complete System Overview

## 🎯 Purpose
The BMAD Method v16 expansion pack provides a comprehensive AI-powered development system for ERPNext applications, featuring 29 specialized agents, workflows, quality gates, and standardized folder structures.

## 🏗️ System Architecture

### Three-Layer Structure
1. **BMAD Expansion Pack** - AI tooling and agent definitions
2. **ERPNext App Code** - The actual application being developed
3. **BMAD Project Files** - Planning documents and project management

### Key Innovation: The Symlink Bridge
Every ERPNext app gets a `.bmad-erpnext-v16` symlink that connects to the expansion pack, allowing agents to access all resources via local paths.

## 📁 Universal Folder Structure

### Critical Files You Must Know
- **UNIVERSAL-FOLDER-STRUCTURE.md** - The LAW for all folder organization
- **FILE-REFERENCE-SYSTEM.md** - How agents discover and track files
- **PROJECT_CONTEXT.yaml** - Dynamic registry in each app
- **PROJECT-INIT-STRUCTURE.sh** - Automatic setup script

### Standard Paths (NO EXCEPTIONS)
```yaml
# Planning Documents
PRD: docs/prd.md
Architecture: docs/architecture.md
Epics: docs/epics/
Stories: docs/stories/

# Code
APIs: {app_name}/api/
DocTypes: {app_name}/{module_name}/doctype/
Vue Components: {app_name}/public/js/

# Testing
Test Plans: tests/plans/
Results: tests/results/
Compliance: tests/compliance/

# BMAD Resources (via symlink)
Agents: .bmad-erpnext-v16/agents/
Tasks: .bmad-erpnext-v16/tasks/
Templates: .bmad-erpnext-v16/templates/
Workflows: .bmad-erpnext-v16/workflows/
```

## 👥 Agent System (29 Specialized Agents)

### Critical Agents
1. **erpnext-architect** - Creates PRDs and architecture
2. **development-coordinator** - Routes tasks to specialists
3. **erpnext-product-owner** - Manages backlog and stories
4. **testing-specialist** - Ensures quality
5. **frappe-compliance-validator** - Enforces Frappe-first principles

### Agent Capabilities
All agents now have `folder_knowledge` sections that specify:
- Exact paths to expansion pack resources
- ERPNext app structure locations
- File discovery rules
- Path resolution helpers

### Agent Activation
```bash
# Standard activation pattern
/bmadErpNext:agent:{agent-id}

# Examples
/bmadErpNext:agent:erpnext-architect
/bmadErpNext:agent:development-coordinator
```

## 🔄 Workflow System

### Core Workflows
1. **universal-context-detection-workflow** - MANDATORY first step
2. **bmad-planning-workflow** - Requirements to architecture
3. **bmad-development-workflow** - Architecture to code
4. **quality-gate-enforcement-workflow** - Validates all handoffs

### Workflow Execution
- All work starts with universal context detection
- Quality gates block non-compliant handoffs
- Workflows track file locations via PROJECT_CONTEXT.yaml
- Handoffs include explicit file paths

## ✅ Quality Gates System

### Enforcement Points
1. **Pre-Development** - Structure validation
2. **During Development** - Continuous compliance
3. **Post-Development** - Complete verification
4. **Final Gates** - Release readiness

### Blocking Conditions
- Structure violations
- Failing tests
- Missing documentation
- Import pattern violations
- External library usage (when Frappe provides equivalent)

## 🚀 Getting Started

### Step 1: Initialize New App
```bash
cd /home/frappe/frappe-bench
bench new-app customer_portal
cd apps/customer_portal

# CRITICAL: Run initialization
/home/frappe/bmad-erpnext-development/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/utils/PROJECT-INIT-STRUCTURE.sh customer_portal customer_management
```

### Step 2: Start Planning
```bash
# Activate architect
/bmadErpNext:agent:erpnext-architect

# Generate PRD
*generate-prd

# Create architecture
*design-architecture
```

### Step 3: Development
```bash
# Activate coordinator
/bmadErpNext:agent:development-coordinator

# Coordinator routes to specialists automatically
```

## 📋 Critical Rules

### MANDATORY Requirements
1. **ALWAYS** run PROJECT-INIT-STRUCTURE.sh for new apps
2. **ALWAYS** start with universal-context-detection-workflow
3. **NEVER** deviate from UNIVERSAL-FOLDER-STRUCTURE.md
4. **ALWAYS** maintain PROJECT_CONTEXT.yaml
5. **NEVER** use external libraries when Frappe provides equivalent

### File Discovery Protocol
1. Check PROJECT_CONTEXT.yaml first
2. Use .bmad-erpnext-v16 symlink for expansion pack
3. Follow standard paths exactly
4. Update PROJECT_CONTEXT.yaml when creating files

## 🛠️ Key Components

### Templates (58 total)
- doctype-template.yaml
- handoff-template.yaml
- project-structure-template.yaml
- agent-folder-knowledge-template.yaml
- And 54 more...

### Tasks (68 total)
- create-doctype.md
- create-api-endpoint.md
- scaffold-complete-app.md
- And 65 more...

### Checklists (30 total)
- quality-gate-checklist.md
- code-change-preflight-checklist.md
- frappe-ui-compliance.md
- And 27 more...

### Workflows (28 total)
- universal-context-detection-workflow.yaml
- quality-gate-enforcement-workflow.yaml
- bmad-planning-workflow.yaml
- And 25 more...

## 📊 System Status

### Current Implementation
- ✅ All 29 agents have folder_knowledge
- ✅ Universal folder structure defined
- ✅ File reference system implemented
- ✅ PROJECT-INIT-STRUCTURE.sh created
- ✅ Quality gates system active
- ⏳ Workflow file discovery updates in progress
- ⏳ Task path awareness updates pending

## 🔍 Troubleshooting

### Common Issues
1. **"File not found"** - Run PROJECT-INIT-STRUCTURE.sh
2. **"No folder_knowledge"** - Update agent with template
3. **"Quality gate failed"** - Check compliance requirements
4. **"Handoff blocked"** - Resolve quality gate issues

### Validation Commands
```bash
# Check structure
ls -la .bmad-erpnext-v16

# Verify context
cat PROJECT_CONTEXT.yaml

# Check folders
find . -type d -name 'docs' -o -name 'tests'
```

## 📚 Documentation Index

### Core Documents
- **UNIVERSAL-FOLDER-STRUCTURE.md** - Folder structure law
- **FILE-REFERENCE-SYSTEM.md** - File discovery system
- **CLAUDE.md** - AI assistant guidelines
- **MANDATORY-SAFETY-PROTOCOLS.md** - Safety requirements

### Guides
- **SYSTEM-OVERVIEW.md** - This document
- **QUICK-START-GUIDE.md** - Getting started fast
- **AGENT-COORDINATION-GUIDE.md** - How agents work together
- **quality-gates-user-guide.md** - Quality system guide

### Analysis Documents
- **AGENT-ECOSYSTEM-ANALYSIS.md** - System utilization
- **AGENT-ACTIVATION-SUMMARY.md** - Activation status
- **FILE-SYSTEM-IMPLEMENTATION-SUMMARY.md** - File system design

## 🎯 Success Metrics

### System Health Indicators
- Zero "file not found" errors
- 100% quality gate compliance
- All handoffs include explicit paths
- PROJECT_CONTEXT.yaml always current
- All projects follow standard structure

## 🚨 Critical Reminders

1. **This is the ONLY accepted structure** - No deviations
2. **Folder compliance is MANDATORY** - Not optional
3. **Quality gates BLOCK non-compliance** - Cannot bypass
4. **Frappe-first is LAW** - No external libraries when Frappe provides
5. **Documentation is REQUIRED** - Not optional

## 📞 Support

For issues or questions:
- Check troubleshooting section above
- Review UNIVERSAL-FOLDER-STRUCTURE.md
- Consult FILE-REFERENCE-SYSTEM.md
- Run diagnostic workflows

---

**Version**: 16.0.0
**Last Updated**: 2024-12-20
**Status**: ACTIVE - All agents updated with folder_knowledge