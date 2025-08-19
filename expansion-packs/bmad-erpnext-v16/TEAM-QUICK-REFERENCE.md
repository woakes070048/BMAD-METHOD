# TEAM-QUICK-REFERENCE.md - Command Reference Guide

Quick command reference for all 31 agents, 12 teams, and 9 workflows in the BMAD ERPNext v16 expansion pack.

## Table of Contents

- [Activation Commands](#activation-commands)
- [31 Individual Agents](#31-individual-agents)
- [12 Agent Teams](#12-agent-teams)
- [9 Workflows](#9-workflows)
- [Common Tasks](#common-tasks)
- [Quick Patterns](#quick-patterns)
- [Emergency Commands](#emergency-commands)

## Activation Commands

### Load Expansion Pack
```bash
*expansion-pack bmad-erpnext-v16*
```

### Agent Syntax
```bash
/bmadErpNext:agent:[agent-id]
"Your request here"
```

### Team Syntax
```bash
*agent-team [team-name]*
"Your project description"
```

### Workflow Syntax
```bash
*workflow [workflow-name]*
"Your workflow description"
```

## 31 Individual Agents

### 🏛️ Project Management Team (4 agents)

**Mrs. Frederic - Product Owner**
```bash
/bmadErpNext:agent:erpnext-product-owner
"Help me plan and prioritize ERPNext features for my business"
```

**Myka Bering - Business Analyst**
```bash
/bmadErpNext:agent:business-analyst
"Analyze my business processes and design ERPNext solutions"
```

**Pete Lattimer - Scrum Master**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Create ERPNext user stories and manage agile development"
```

**Claudia Donovan - Main Dev Coordinator**
```bash
/bmadErpNext:agent:main-dev-coordinator
"Coordinate ERPNext development tasks and route work to specialists"
```

### 🎨 Frontend Development Team (6 agents)

**Helena Wells - Vue SPA Architect**
```bash
/bmadErpNext:agent:vue-spa-architect
"Build Vue 3 Single Page Applications with native Frappe integration"
```

**Artie Nielsen - Frappe UI Developer**
```bash
/bmadErpNext:agent:frappe-ui-developer
"Create native Frappe UI components and design systems"
```

**Jack Carter - UI Layout Designer**
```bash
/bmadErpNext:agent:ui-layout-designer
"Design user interfaces from DocType specifications"
```

**Lexi Doig - PWA Specialist**
```bash
/bmadErpNext:agent:pwa-specialist
"Add offline functionality and PWA features to ERPNext apps"
```

**Todd Manning - Mobile UI Specialist**
```bash
/bmadErpNext:agent:mobile-ui-specialist
"Create mobile-optimized interfaces and native mobile features"
```

**Beverly Barlowe - Workspace Architect**
```bash
/bmadErpNext:agent:workspace-architect
"Design ERPNext workspaces and dashboards for optimal UX"
```

### ⚙️ Backend Development Team (6 agents)

**Allison Blake - API Architect**
```bash
/bmadErpNext:agent:api-architect
"Design secure, scalable API architectures for Frappe/ERPNext"
```

**Douglas Fargo - API Developer**
```bash
/bmadErpNext:agent:api-developer
"Create secure API endpoints and backend functionality"
```

**Paracelsus - DocType Designer**
```bash
/bmadErpNext:agent:doctype-designer
"Design ERPNext DocTypes with proper relationships and validation"
```

**Nathan Stark - Data Integration Expert**
```bash
/bmadErpNext:agent:data-integration-expert
"Handle complex data migrations and system integrations"
```

**Zane Donovan - Workflow Specialist**
```bash
/bmadErpNext:agent:workflow-specialist
"Create ERPNext workflows and approval processes"
```

### 🔍 Quality & Operations Team (4 agents)

**Allison Blake - QA Lead**
```bash
/bmadErpNext:agent:erpnext-qa-lead
"Code review, refactoring, and quality assurance for ERPNext"
```

**Steve Jinks - Testing Specialist**
```bash
/bmadErpNext:agent:testing-specialist
"Create comprehensive test strategies and quality assurance"
```

**Larry Haberman - Bench Operator**
```bash
/bmadErpNext:agent:bench-operator
"Bench CLI operations, site management, and deployment"
```

**Eva Thorne - Frappe Compliance Validator**
```bash
/bmadErpNext:agent:frappe-compliance-validator
"Ensure code follows Frappe framework best practices"
```

### 🔄 Business & Integration Team (4 agents)

**Eureka Carter - Airtable Analyzer**
```bash
/bmadErpNext:agent:airtable-analyzer
"Analyze Airtable databases and plan migration to ERPNext"
```

**Vincent - n8n Workflow Analyst**
```bash
/bmadErpNext:agent:n8n-workflow-analyst
"Assess n8n workflows and design ERPNext conversion strategies"
```

**Zoe Carter - Workflow Converter**
```bash
/bmadErpNext:agent:workflow-converter
"Transform external workflows to ERPNext automation"
```

**Lucas - Trigger Mapper**
```bash
/bmadErpNext:agent:trigger-mapper
"Map business triggers and design automation workflows"
```

### 🔧 Automation & Migration Team (3 agents)

**Kevin Blake - App Scaffold Coordinator**
```bash
/bmadErpNext:agent:app-scaffold-coordinator
"Coordinate complete app scaffolding and structure creation"
```

**Fargo - Refactoring Expert**
```bash
/bmadErpNext:agent:refactoring-expert
"Handle code refactoring and technical debt management"
```

**Henry Deacon - ERPNext App Cleaner**
```bash
/bmadErpNext:agent:erpnext-app-cleaner
"Clean up apps and remove redundant code"
```

### 🛠️ Utilities & Compliance Team (4 agents)

**Tess Fontana - App Auditor**
```bash
/bmadErpNext:agent:app-auditor
"Application auditing and comprehensive validation"
```

**Leena - Documentation Specialist**
```bash
/bmadErpNext:agent:documentation-specialist
"Create technical documentation and user guides"
```

**Jack Carter - Diagnostic Specialist**
```bash
/bmadErpNext:agent:diagnostic-specialist
"System diagnostics and troubleshooting"
```

**Grace Monroe - Jinja Template Specialist**
```bash
/bmadErpNext:agent:jinja-template-specialist
"Create templates and reports using Jinja2"
```

## 12 Agent Teams

### 🏗️ Modern App Development Team
```bash
*agent-team modern-app-team*
"Build a complete modern ERPNext application with Vue SPA, PWA features, and mobile optimization"
```
**Agents**: vue-spa-architect, frappe-ui-developer, api-architect, doctype-designer, pwa-specialist, jinja-template-specialist

### 🚀 Deployment & Infrastructure Team
```bash
*agent-team deployment-team*
"Set up production deployment with monitoring, security, and scalability"
```
**Agents**: bench-operator, testing-specialist, frappe-compliance-validator

### 🔄 Business Process & Workflow Team
```bash
*agent-team workflow-team*
"Design multi-level approval workflows with conditional routing and escalation"
```
**Agents**: workflow-specialist, api-developer, testing-specialist

### 📊 Business Analysis Team
```bash
*agent-team business-analysis-team*
"Analyze current processes and design comprehensive ERPNext implementation strategy"
```
**Agents**: business-analyst, erpnext-architect, doctype-designer, api-architect, jinja-template-specialist

### 🔌 n8n Conversion Team
```bash
*agent-team n8n-conversion-team*
"Convert complex n8n workflows to native ERPNext automation"
```
**Agents**: n8n-workflow-analyst, workflow-converter, trigger-mapper, api-developer, jinja-template-specialist

### 📋 Airtable Migration Team
```bash
*agent-team airtable-migration-team*
"Migrate Airtable bases with relationships, formulas, and automations to ERPNext"
```
**Agents**: airtable-analyzer, business-analyst, doctype-designer, api-developer, data-integration-expert, jinja-template-specialist

### 🤖 Automation & Integration Team
```bash
*agent-team automation-team*
"Implement complex business process automation with external system integrations"
```
**Agents**: workflow-converter, trigger-mapper, workflow-specialist, api-developer

### 📱 Mobile Development Team
```bash
*agent-team mobile-team*
"Create native mobile app with offline sync and push notifications"
```
**Agents**: mobile-ui-specialist, pwa-specialist, vue-spa-architect, api-architect

### 🛠️ Development Team
```bash
*agent-team development-team*
"Implement complete ERPNext features with DocTypes, controllers, and APIs"
```
**Agents**: erpnext-architect, doctype-designer, api-developer, data-integration-expert, jinja-template-specialist

### ✅ Validation Team
```bash
*agent-team validation-team*
"Run comprehensive validation and quality assurance on ERPNext implementations"
```
**Agents**: diagnostic-specialist, testing-specialist, frappe-compliance-validator

### 🔒 Security Validation Team
```bash
*agent-team security-validation-team*
"Perform security audit and ensure compliance with ERPNext security standards"
```
**Agents**: frappe-compliance-validator, testing-specialist, diagnostic-specialist

### 🧪 Troubleshooting Team
```bash
*agent-team troubleshooting-team*
"Diagnose and resolve complex ERPNext system issues and performance problems"
```
**Agents**: diagnostic-specialist, refactoring-expert, bench-operator, testing-specialist

## 9 Workflows

### 🔧 System Enhancement Workflow
```bash
*workflow enhancement*
"Enhance inventory management with barcode scanning and real-time updates"
```

### 🏢 Business Analysis to App Workflow
```bash
*workflow business-analysis-to-app*
"Transform manufacturing process requirements into custom ERPNext application"
```

### 🏗️ Modern App Development Workflow
```bash
*workflow modern-app-development*
"Build complete modern ERPNext application with Vue SPA frontend"
```

### 🔄 n8n Workflow Conversion
```bash
*workflow n8n-workflow-conversion*
"Convert CRM lead nurturing n8n workflow to ERPNext automation"
```

### 📊 Airtable to ERPNext Migration
```bash
*workflow airtable-to-erpnext-migration*
"Migrate project management Airtable base to ERPNext with full workflow automation"
```

### 🔀 Combined Airtable + n8n Conversion
```bash
*workflow combined-airtable-n8n-conversion*
"Convert integrated Airtable database and n8n automation workflows to ERPNext"
```

### 🏭 App Development Workflow
```bash
*workflow app-development*
"Develop complete ERPNext app with all necessary components and testing"
```

### 🩺 Diagnostic Workflow
```bash
*workflow diagnostic-workflow*
"Diagnose and resolve complex ERPNext performance and functionality issues"
```

### 🎯 DocType to Frontend Workflow
```bash
*workflow doctype-to-frontend-workflow*
"Generate Vue frontend components and interfaces from DocType definitions"
```

## Common Tasks

### Quick Development Tasks
```bash
*task create-doctype*          # Create new DocType
*task create-api-endpoint*      # Build secure API
*task create-vue-components*    # Generate Vue components
*task setup-workflow*          # Configure approval flow
*task create-workspace*        # Design workspace
*task build-frontend*          # Build assets
*task run-tests*              # Execute tests
*task install-app*            # Install application
```

### Analysis Tasks
```bash
*task analyze-business-requirements*    # Business analysis
*task analyze-airtable-base*           # Airtable analysis
*task analyze-app-dependencies*        # Dependency analysis
*task performance-analysis*            # Performance review
```

### Integration Tasks
```bash
*task integrate-docflow*              # DocFlow integration
*task convert-n8n-workflow*           # n8n conversion
*task setup-data-migration*           # Data migration
*task setup-n8n-triggers*            # n8n triggers
```

### Validation Tasks
```bash
*task validate-app-structure*         # Structure validation
*task validate-doctype-schema*        # DocType validation
*task validate-frappe-compliance*     # Compliance check
*task pre-deployment-verification*    # Pre-deploy checks
```

## Quick Patterns

### New Project Startup
```bash
# 1. Plan the project
/bmadErpNext:agent:erpnext-product-owner
"I need to build [describe your project]"

# 2. Analyze requirements
*agent-team business-analysis-team*
"Analyze requirements for [project name]"

# 3. Build the application
*workflow business-analysis-to-app*
"Create [project description] with full implementation"
```

### Frontend Development
```bash
# 1. Design Vue components
/bmadErpNext:agent:vue-spa-architect
"Create Vue SPA for [specific feature]"

# 2. Add PWA features
/bmadErpNext:agent:pwa-specialist
"Add offline functionality and push notifications"

# 3. Mobile optimization
/bmadErpNext:agent:mobile-ui-specialist
"Optimize for mobile devices"
```

### API Development
```bash
# 1. Design API architecture
/bmadErpNext:agent:api-architect
"Design secure API for [specific functionality]"

# 2. Implement endpoints
/bmadErpNext:agent:api-developer
"Create API endpoints for [specific operations]"

# 3. Test and validate
/bmadErpNext:agent:testing-specialist
"Test API security and performance"
```

### System Migration
```bash
# From Airtable
*workflow airtable-to-erpnext-migration*
"Migrate [database description] from Airtable"

# From n8n
*workflow n8n-workflow-conversion*
"Convert [workflow description] from n8n"

# Combined migration
*workflow combined-airtable-n8n-conversion*
"Migrate integrated Airtable and n8n system"
```

## Emergency Commands

### System Diagnostics
```bash
/bmadErpNext:agent:diagnostic-specialist
"Run complete health check and diagnose any issues"
```

### Quick Recovery
```bash
# Bench issues
/bmadErpNext:agent:bench-operator
"Help me recover from bench/deployment issues"

# Code issues
/bmadErpNext:agent:refactoring-expert
"Help me fix critical code issues"

# Performance issues
*task performance-analysis*
"Analyze and resolve performance problems"
```

### Compliance and Security
```bash
/bmadErpNext:agent:frappe-compliance-validator
"Audit my code for security and compliance issues"

*agent-team security-validation-team*
"Perform comprehensive security audit"
```

## Command Tips

### Best Practices
- Always start with the **Product Owner** for project planning
- Use **Agent Teams** for complex, multi-step tasks
- Use **Workflows** for complete end-to-end processes
- Use **Individual Agents** for specific expertise

### Command Structure
- Use exact agent IDs (check `agents/` folder for exact names)
- Provide clear, specific descriptions in quotes
- Include context and requirements in your requests
- Be specific about your current environment and constraints

### Troubleshooting Commands
- Always try the **Diagnostic Specialist** first for any issues
- Use **Troubleshooting Team** for complex system problems
- Check **TROUBLESHOOTING.md** for specific error solutions

---

**Remember**: The BMAD ERPNext v16 expansion pack follows safety-first protocols. All agents automatically run universal context detection before starting work.