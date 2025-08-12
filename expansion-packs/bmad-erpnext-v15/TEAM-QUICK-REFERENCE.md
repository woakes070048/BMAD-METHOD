# Team Quick Reference: Correct BMAD Commands

## ⚡ Most Important Commands

### Agent Activation (Use in Claude Code)
```bash
# Product Owner
/bmadErpNext:agent:erpnext-product-owner

# Business Analyst  
/bmadErpNext:agent:business-analyst

# Scrum Master
/bmadErpNext:agent:erpnext-scrum-master

# Developer Agents
/bmadErpNext:agent:doctype-designer
/bmadErpNext:agent:api-developer
/bmadErpNext:agent:vue-frontend-architect

# QA Lead
/bmadErpNext:agent:erpnext-qa-lead

# Project Manager
/bmadErpNext:agent:main-dev-coordinator

# DevOps
/bmadErpNext:agent:bench-operator
```

### Task Execution (Use in Claude Code)
```bash
# Requirements & Planning
/bmadErpNext:task:erpnext-requirements-elicitation
/bmadErpNext:task:create-erpnext-story
/bmadErpNext:task:create-erpnext-epic

# Development
/bmadErpNext:task:create-doctype
/bmadErpNext:task:create-api-endpoint
/bmadErpNext:task:create-vue-spa
/bmadErpNext:task:setup-frappe-ui

# Testing & Deployment  
/bmadErpNext:task:run-tests
/bmadErpNext:task:install-app
/bmadErpNext:task:build-frontend
```

## 🎯 Three Development Scenarios

### Scenario 1: 🌱 Fresh Start (No existing code/specs)
**"We're building something completely new"**

**Stage 1 - Product Owner:**
```bash
/bmadErpNext:task:erpnext-requirements-elicitation
/bmadErpNext:agent:erpnext-product-owner
*create-epic
*execute-checklist-po
```

**Stage 4 - Development:**
```bash
/bmadErpNext:task:create-vue-spa --app-name my_new_app
/bmadErpNext:agent:doctype-designer
*create-doctype Customer_Portal
```

### Scenario 2: 📋 Have Specs/Designs
**"We have Figma designs, API docs, or detailed requirements"**

**Stage 1 - Product Owner:**
```bash
/bmadErpNext:task:shard-erpnext-doc existing-specs.md ./requirements/
/bmadErpNext:agent:erpnext-architect
*validate-requirements existing-specs.md
/bmadErpNext:agent:erpnext-product-owner
*create-epic
```

**Stage 4 - Development:**
```bash
/bmadErpNext:task:setup-frappe-ui --app-name spec_app
/bmadErpNext:agent:vue-frontend-architect
*create-component from-designs
```

### Scenario 3: 🏗️ Existing ERPNext App
**"We need to add features or fix an existing ERPNext app"**

**Stage 1 - Analysis:**
```bash
/bmadErpNext:agent:erpnext-architect
*analyze-app existing-app-name
*audit-compliance
/bmadErpNext:agent:erpnext-product-owner
*document-enhancement
```

**Stage 4 - Enhancement:**
```bash
/bmadErpNext:agent:frappe-compliance-validator
*validate-code
/bmadErpNext:task:create-api-endpoint --app existing-app
```

## 🤔 Quick Decision Tree

**Start Here:** What describes your situation?

→ **"We have just an idea"** = Scenario 1 (Fresh Start)
→ **"We have designs/specs"** = Scenario 2 (With Specs)  
→ **"We have existing ERPNext app"** = Scenario 3 (Brownfield)

## ⚠️ Command Correction Notice

**WRONG** (Don't use these):
```bash
❌ npx bmad-method activate:agent bmad-erpnext-v15 erpnext-product-owner
❌ npx bmad-method run:task bmad-erpnext-v15 create-doctype
```

**CORRECT** (Use these in Claude Code):
```bash
✅ /bmadErpNext:agent:erpnext-product-owner
✅ /bmadErpNext:task:create-doctype
```

## 🚀 Stage-by-Stage Quick Commands

### Stage 1: Product Owner
```bash
# Choose your scenario first, then:
/bmadErpNext:agent:erpnext-product-owner
*create-story    # or *create-epic for larger features
*execute-checklist-po
*exit
```

### Stage 2: Business Analyst
```bash
/bmadErpNext:agent:business-analyst
*analyze-requirements
/bmadErpNext:agent:erpnext-product-owner
*create-epic
*exit
```

### Stage 3: Scrum Master  
```bash
/bmadErpNext:agent:erpnext-scrum-master
*analyze-epic
*plan-sprint
*assign-tasks
*exit
```

### Stage 4: Development
```bash
# Backend
/bmadErpNext:agent:doctype-designer
*create-doctype

# API
/bmadErpNext:agent:api-developer  
*create-api

# Frontend
/bmadErpNext:task:create-vue-spa
/bmadErpNext:agent:vue-frontend-architect
*setup-vue-spa
```

### Stage 5: QA Testing
```bash
/bmadErpNext:agent:erpnext-qa-lead
*create-test-plan
*run-tests
*validate-acceptance
*exit
```

### Stage 6: Deployment
```bash
/bmadErpNext:agent:bench-operator
*install-app my-app-name
*deploy-production
*exit
```

## 💡 Pro Tips

1. **Always start with your scenario** (Fresh/Specs/Existing)
2. **Use agents for complex workflows** (`/bmadErpNext:agent:`)
3. **Use tasks for specific actions** (`/bmadErpNext:task:`)
4. **Type `*help` inside any agent** to see available commands
5. **Use `*exit` to leave agent mode**

## 🔗 Stage Handoffs

Each stage hands off to the next:
```
Stage 1 (PO) → Stage 2 (BA) → Stage 3 (SM) → Stage 4 (Dev) → Stage 5 (QA) → Stage 6 (PM)
```

**Between stages, always:**
1. Complete current stage checklist
2. Use `*doc-out` to export deliverables  
3. Use `*exit` to exit agent
4. Hand off documents to next stage team member