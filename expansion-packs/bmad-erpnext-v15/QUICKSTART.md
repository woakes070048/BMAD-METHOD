# BMAD ERPNext v15 - Quick Start Guide

## Prerequisites Checklist

### ✅ System Requirements
- [ ] **ERPNext v15** installed and running
- [ ] **Frappe Framework v15.75.0+** 
- [ ] **Active Frappe bench** environment
- [ ] **Claude Code** with BMAD-METHOD support
- [ ] **Node.js v18+** for modern frontend development
- [ ] **Python 3.8+** for ERPNext development

### ✅ Environment Setup
- [ ] Access to ERPNext site with System Manager privileges
- [ ] Bench commands working (`bench version`)
- [ ] Git configured for development
- [ ] Text editor/IDE configured (VS Code recommended)

## 5-Minute Quick Start

### Step 1: Get the Expansion Pack
```bash
# If you don't have BMAD-METHOD
git clone https://github.com/bmad-code-org/BMAD-METHOD.git
cd BMAD-METHOD/expansion-packs/bmad-erpnext-v15

# If you already have BMAD-METHOD
cd BMAD-METHOD/expansion-packs/bmad-erpnext-v15
git pull origin main
```

### Step 2: Configure for Your Environment
```bash
# Copy the example configuration
cp config.yaml.example config.yaml

# Edit with your settings (use your preferred editor)
nano config.yaml
```

**Key settings to update in config.yaml:**
```yaml
environment:
  bench_path: "/path/to/your/frappe-bench"  # Update this
  site: "your-site.com"                     # Update this
  
context:
  existing_apps:
    - "erpnext"
    - "your_custom_app"  # Add your existing apps
```

### Step 3: Start Claude Code with the Expansion Pack
```bash
# Navigate to your project directory
cd /path/to/your/project

# Start Claude Code
claude

# Load the expansion pack
*expansion-pack bmad-erpnext-v15*
```

### Step 4: Choose Your Development Path

#### 🚀 New Modern App Development
```bash
*agent-team modern-app-team*
"Create a customer portal app with Vue 3 SPA frontend and real-time dashboard"
```

#### 🔄 Business Process Automation
```bash
*agent-team automation-team*
"Automate our sales order approval process with email notifications"
```

#### 📊 Airtable Migration
```bash
*agent-team airtable-migration-team*
"Migrate our project management Airtable base to ERPNext"
```

#### 🔌 n8n Workflow Conversion
```bash
*agent-team n8n-conversion-team*
"Convert our lead nurturing n8n workflow to ERPNext automation"
```

## Common Use Cases

### 1. Create a Modern Customer Portal

**Goal**: Build a Vue 3 SPA customer portal with real-time features

**Steps**:
```bash
# Step 1: Design the application architecture
*agent vue-spa-architect*
"Design customer portal architecture with Vue 3, real-time notifications, and secure API endpoints"

# Step 2: Implement frappe-ui components
*agent frappe-ui-developer*
"Create customer dashboard with order history table, invoice viewer, and support ticket system"

# Step 3: Add PWA features
*agent pwa-specialist*
"Add offline functionality and push notifications for order updates"

# Step 4: Create secure backend APIs
*agent api-architect*
"Design secure customer API endpoints with proper authentication and data filtering"
```

**Expected Result**: Complete customer portal with modern frontend and secure backend

### 2. Automate Business Processes

**Goal**: Automate approval workflows and notifications

**Steps**:
```bash
# Step 1: Analyze current processes
*agent-team business-analysis-team*
"Analyze our purchase requisition approval process and identify automation opportunities"

# Step 2: Design workflows
*agent workflow-specialist*
"Create multi-level approval workflow with department routing and escalation rules"

# Step 3: Implement automation
*agent automation-specialist*
"Implement automated email notifications and deadline tracking for approvals"
```

**Expected Result**: Fully automated approval system with notifications and tracking

### 3. Migrate from External Systems

**Goal**: Migrate data and workflows from Airtable/n8n to ERPNext

**For Airtable Migration**:
```bash
*workflow airtable-to-erpnext-migration*
"Migrate our CRM Airtable base with 500+ contacts and automated follow-up workflows"
```

**For n8n Conversion**:
```bash
*workflow n8n-workflow-conversion*
"Convert our invoice processing n8n workflow to ERPNext server scripts"
```

**Expected Result**: Complete migration with preserved functionality and improved performance

### 4. Production Deployment

**Goal**: Deploy ERPNext application to production with monitoring

**Steps**:
```bash
# Step 1: Design deployment architecture
*agent-team deployment-team*
"Design production deployment with Docker, load balancing, and automatic backups"

# Step 2: Implement monitoring
*agent monitoring-specialist*
"Set up comprehensive monitoring with alerts for performance, errors, and security"

# Step 3: Configure security
*agent security-specialist*
"Implement SSL, firewall rules, and security hardening for production environment"
```

**Expected Result**: Production-ready deployment with monitoring and security

## Troubleshooting Quick Fixes

### Common Issues

#### ❌ "Agent not found" error
```bash
# Check available agents
*list-agents*

# Refresh expansion pack
*expansion-pack bmad-erpnext-v15*
```

#### ❌ "Bench command failed" 
```bash
# Check bench status
*agent bench-operator*
"Check bench status and fix any issues"

# Verify environment
bench version
bench doctor
```

#### ❌ "Permission denied" errors
```bash
# Check site permissions
*agent erpnext-architect*
"Check and fix ERPNext site permissions and user roles"
```

#### ❌ Vue/Frontend build issues
```bash
# Debug frontend setup
*agent vue-spa-architect*
"Diagnose and fix Vue 3 development environment setup issues"
```

## Advanced Workflows

### Combined System Migration
For complex environments with both Airtable and n8n:
```bash
*workflow combined-airtable-n8n-conversion*
"Migrate integrated CRM system with Airtable database and n8n automation workflows"
```

### End-to-End Application Development
From business analysis to deployment:
```bash
*workflow business-analysis-to-app*
"Transform manufacturing process requirements into complete ERPNext application with mobile access"
```

## Best Practices

### 1. Start Small
- Begin with simple automations or single DocType implementations
- Test thoroughly before expanding functionality
- Use development sites for testing

### 2. Follow ERPNext Conventions
- Use proper naming conventions (snake_case for Python, kebab-case for files)
- Follow DocType relationship patterns
- Implement proper permissions and validation

### 3. Leverage Agent Teams
- Use specialized agent teams for complex projects
- Combine multiple agents for comprehensive solutions
- Follow the recommended workflow sequences

### 4. Document Everything
- Use the generated documentation templates
- Keep track of customizations and configurations
- Document business processes and workflows

## Next Steps

After completing the quick start:

1. **Explore Advanced Features**: Try different agent teams and workflows
2. **Customize for Your Needs**: Modify templates and configurations
3. **Join the Community**: Share your experiences and get help
4. **Contribute Back**: Share useful patterns and improvements

## Getting Help

- **Check TROUBLESHOOTING.md** for common issues
- **Review agent documentation** in the `agents/` directory
- **Use diagnostic agents** to troubleshoot problems:
  ```bash
  *agent bench-operator*
  "Run comprehensive system diagnostics"
  ```
- **Join community discussions** for support and best practices

## Success Metrics

Track your development success:
- ✅ Faster development cycles
- ✅ Consistent code quality  
- ✅ Reduced deployment issues
- ✅ Better business process automation
- ✅ Improved user experience

---

**Ready to build amazing ERPNext applications?** Start with any of the examples above and let the specialized agent teams guide you through the development process!