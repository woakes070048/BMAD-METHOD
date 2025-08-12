# BMAD ERPNext v15 Complete Development Suite

## Overview
Complete BMAD expansion pack for comprehensive ERPNext v15 development including modern app building, business process automation, system migrations, and enterprise deployment. Features 15+ specialized AI agents and 8 expert teams covering the entire ERPNext development lifecycle from business analysis to production deployment.

## Features
- 🤖 **15+ Specialized Agents** - Complete development team including Vue SPA, API, workflow, automation, and deployment experts
- 🎨 **Modern Frontend Stack** - Vue 3 + Vite + frappe-ui for SPA development
- 🏗️ **Complete Development Lifecycle** - From business analysis to production deployment
- 🔄 **Automation & Integration** - n8n workflow conversion, Airtable migration, and process automation
- 📱 **Mobile-First Solutions** - PWA development and native mobile app creation
- 🚀 **Production Deployment** - Infrastructure as code, monitoring, and enterprise deployment
- ✅ **Quality Assurance** - Comprehensive testing, validation, and performance optimization
- 🔧 **Multi-Environment Support** - Development, staging, and production workflows

## Prerequisites
- Existing ERPNext v15 installation
- Frappe Framework v15.75.0+
- Active Frappe bench environment
- Claude Code with BMAD-METHOD support

## Quick Start
```bash
# Clone BMAD-METHOD repository
git clone https://github.com/bmad-code-org/BMAD-METHOD.git
cd BMAD-METHOD

# Navigate to the expansion pack
cd expansion-packs/bmad-erpnext-v15

# Configure for your environment
cp config.yaml.example config.yaml
# Edit config.yaml with your bench path and site details

# Use with Claude Code
claude
*expansion-pack bmad-erpnext-v15*
```

## Specialized Agents

### Frontend Development
- **vue-spa-architect**: Vue 3 SPA architecture with Composition API
- **frappe-ui-developer**: frappe-ui component implementation  
- **pwa-specialist**: Progressive Web App features and offline support

### Backend Development
- **erpnext-architect**: System architecture and design
- **bench-operator**: Bench command operations
- **doctype-designer**: DocType creation and modeling
- **api-architect**: Secure API architecture with @frappe.whitelist()
- **api-developer**: REST API development
- **workflow-specialist**: ERPNext workflow integration
- **testing-specialist**: Testing and validation

### Business & Analysis
- **business-analyst**: Requirements gathering and process analysis
- **workflow-designer**: Business process workflow design
- **data-architect**: Database and DocType relationship design

### Automation & Integration
- **automation-specialist**: ERPNext automation and scheduled jobs
- **integration-engineer**: Third-party system integrations
- **n8n-converter**: n8n workflow to ERPNext automation conversion
- **airtable-migrator**: Airtable to ERPNext migration specialist

### Deployment & Operations
- **deployment-engineer**: Production deployment and infrastructure
- **monitoring-specialist**: Application monitoring and performance
- **security-specialist**: Security hardening and compliance

## Environment Configuration
This expansion pack is configured for:
- **Bench Path**: `/home/frappe/frappe-bench`
- **Primary Site**: `prima-erpnext.pegashosting.com`
- **Existing Apps**: `docflow`, `n8n_integration`
- **Framework**: Frappe v15.75.0

## Integration Support
This expansion pack is designed to work with existing ERPNext environments and supports:
- Integration with custom apps like docflow
- Compatibility with automation tools like n8n_integration
- Multi-app development workflows
- Production deployment patterns

## Expert Agent Teams

### 🏗️ Modern App Development Team
Complete modern application development with Vue 3, PWA, and mobile-first approach.
```bash
*agent-team modern-app-team*
"Create a modern customer portal with Vue SPA, PWA features, and mobile optimization"
```

### 🚀 Deployment & Infrastructure Team  
Production-ready deployment with monitoring, security, and scalability.
```bash
*agent-team deployment-team*
"Set up production deployment with Docker, monitoring, and auto-scaling"
```

### 🔄 Business Process & Workflow Team
ERPNext workflow design and business process automation.
```bash
*agent-team workflow-team*
"Design multi-level approval workflows with conditional routing and escalation"
```

### 📊 Business Analysis Team
Requirements gathering, process analysis, and solution design.
```bash
*agent-team business-analysis-team*
"Analyze current processes and design ERPNext implementation strategy"
```

### 🔌 n8n Conversion Team
Convert existing n8n workflows to native ERPNext automation.
```bash
*agent-team n8n-conversion-team*
"Convert complex n8n workflows to ERPNext server scripts and scheduled jobs"
```

### 📋 Airtable Migration Team
Complete Airtable to ERPNext data and workflow migration.
```bash
*agent-team airtable-migration-team*
"Migrate Airtable bases with relationships, formulas, and automations to ERPNext"
```

### 🤖 Automation & Integration Team
Advanced ERPNext automation and third-party system integration.
```bash
*agent-team automation-team*
"Implement complex business process automation with external system integrations"
```

### 📱 Mobile Development Team
Mobile apps, PWA optimization, and mobile-first ERPNext solutions.
```bash
*agent-team mobile-team*
"Create native mobile app with offline sync and push notifications"
```

## Available Workflows

### 🔧 System Enhancement Workflow
Systematic approach to enhancing existing ERPNext implementations.
```bash
*workflow enhancement*
"Enhance inventory management with barcode scanning and real-time updates"
```

### 🏢 Business Analysis to App Workflow
Complete workflow from business requirements to deployed ERPNext application.
```bash
*workflow business-analysis-to-app*
"Transform manufacturing process requirements into custom ERPNext application"
```

### 🔄 n8n Workflow Conversion
Convert n8n automation workflows to native ERPNext automation.
```bash
*workflow n8n-workflow-conversion*
"Convert CRM lead nurturing n8n workflow to ERPNext automation"
```

### 📊 Airtable to ERPNext Migration
Complete migration workflow for Airtable databases and processes.
```bash
*workflow airtable-to-erpnext-migration*
"Migrate project management Airtable base to ERPNext with full workflow automation"
```

### 🔀 Combined Airtable + n8n Conversion
Unified conversion for integrated Airtable and n8n systems.
```bash
*workflow combined-airtable-n8n-conversion*
"Convert integrated Airtable database and n8n automation workflows to ERPNext"
```

## Quick Start Examples

### Modern App Development
```bash
*agent vue-spa-architect*
"Create Vue 3 SPA with real-time dashboard and frappe-ui components"

*agent pwa-specialist*
"Add offline functionality and push notifications to the customer portal"
```

### Business Process Automation
```bash
*agent automation-specialist*
"Automate purchase approval workflow with email notifications and escalations"

*agent workflow-specialist*
"Create multi-branch approval system with role-based routing"
```

### System Integration
```bash
*agent integration-engineer*
"Integrate ERPNext with Shopify for real-time inventory synchronization"

*agent api-architect*
"Design secure API architecture for mobile app integration"
```

### Production Deployment
```bash
*agent deployment-engineer*
"Set up production environment with Docker, Nginx, and SSL certificates"

*agent monitoring-specialist*
"Implement comprehensive monitoring with alerts and performance tracking"
```

## What's New in v2.0

### Modern Frontend Stack
- Vue 3 with Composition API and `<script setup>`
- Vite for lightning-fast development
- frappe-ui component library (v0.1.171)
- Pinia for state management
- TailwindCSS for styling
- TypeScript support

### Enhanced Architecture
- Separate frontend directory structure
- API-first backend design
- PWA capabilities with service workers
- Real-time updates with Socket.io
- Offline-first data strategies

### Best Practices from Frappe Team
- Following patterns from Frappe Helpdesk and CRM
- Prefixed DocTypes for namespace management
- Modular API structure
- Component-driven development
- Comprehensive testing patterns

## File Structure
```
bmad-erpnext-v15/
├── agents/                    # 15+ AI agent configurations
│   ├── vue-spa-architect.yaml
│   ├── frappe-ui-developer.yaml
│   ├── pwa-specialist.yaml
│   ├── api-architect.yaml
│   ├── automation-specialist.yaml
│   └── ... (and more)
├── agent-teams/               # 8 Expert team compositions
│   ├── modern-app-team.yaml
│   ├── deployment-team.yaml
│   ├── workflow-team.yaml
│   ├── business-analysis-team.yaml
│   ├── n8n-conversion-team.yaml
│   ├── airtable-migration-team.yaml
│   ├── automation-team.yaml
│   └── mobile-team.yaml
├── workflows/                 # 5 Business workflow definitions
│   ├── enhancement.yaml
│   ├── business-analysis-to-app.yaml
│   ├── n8n-workflow-conversion.yaml
│   ├── airtable-to-erpnext-migration.yaml
│   └── combined-airtable-n8n-conversion.yaml
├── templates/                 # Code and structure templates
│   ├── app-structure-template.yaml
│   ├── vue-spa-template.yaml
│   ├── api-module-template.yaml
│   └── deployment-template.yaml
├── tasks/                     # Development task definitions
│   ├── create-vue-spa.md
│   ├── setup-frappe-ui.md
│   ├── implement-automation.md
│   └── deploy-production.md
├── checklists/                # Quality assurance checklists
│   ├── vue-spa-checklist.md
│   ├── api-security-checklist.md
│   ├── deployment-checklist.md
│   └── performance-checklist.md
├── data/                      # Reference guides and documentation
│   ├── frappe-ui-components.md
│   ├── vue-spa-patterns.md
│   ├── api-whitelisting-guide.md
│   ├── automation-patterns.md
│   └── deployment-strategies.md
├── config.yaml                # Comprehensive configuration
├── README.md                  # This file
├── QUICKSTART.md             # Quick start guide
└── TROUBLESHOOTING.md        # Common issues and solutions
```

## Contributing
Contributions welcome! Please read [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines.

## License
MIT License - see [LICENSE](../../LICENSE) for details.

## Support
- Check existing issues on GitHub
- Review troubleshooting guide in docs/
- Join the BMAD-METHOD community discussions