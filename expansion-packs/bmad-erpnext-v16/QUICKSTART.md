# QUICKSTART.md - 5-Minute Setup Guide

Get your BMAD ERPNext v16 expansion pack running in under 5 minutes.

## Prerequisites Check (30 seconds)

```bash
# Verify you have these installed
node --version    # Should be v20+
frappe --version  # Should be v16+
bench --version   # Should be v5+
```

## Quick Installation (2 minutes)

### Option 1: Auto-Install (Recommended)
```bash
# Navigate to your ERPNext app directory
cd /home/frappe/frappe-bench/apps/your-app-name

# Install BMAD Method with ERPNext expansion pack
npx bmad-method install --full --expansion-packs bmad-erpnext-v16

# ✅ Done! Skip to "First Use" section
```

### Option 2: Manual Setup
```bash
# Clone if you haven't already
git clone https://github.com/woakes070048/BMAD-METHOD.git
cd BMAD-METHOD/expansion-packs/bmad-erpnext-v16

# Copy and configure
cp config.yaml.example config.yaml
# Edit config.yaml with your bench path and site name
```

## First Use (2 minutes)

### 1. Load the Expansion Pack
```bash
# In Claude Code, run:
*expansion-pack bmad-erpnext-v16*
```

### 2. Try Your First Agent
```bash
# Get help from the product owner
/bmadErpNext:agent:erpnext-product-owner
"Help me plan a customer portal project"
```

### 3. Create a Simple Vue Component
```bash
# Build a modern component
/bmadErpNext:agent:vue-spa-architect
"Create a customer dashboard with frappe-ui components"
```

## Quick Reference Commands

### Most Used Agents
```bash
# Project Planning
/bmadErpNext:agent:erpnext-product-owner
/bmadErpNext:agent:business-analyst

# Development
/bmadErpNext:agent:vue-spa-architect
/bmadErpNext:agent:api-architect
/bmadErpNext:agent:doctype-designer

# Operations
/bmadErpNext:agent:bench-operator
/bmadErpNext:agent:testing-specialist
```

### Team Workflows
```bash
# Complete modern app development
*agent-team modern-app-team*
"Build a project management system with Vue SPA"

# Business analysis to implementation
*workflow business-analysis-to-app*
"Convert our inventory requirements into ERPNext application"
```

### Quick Tasks
```bash
# Generate ERPNext components
*task create-doctype*          # Create new DocType
*task create-api-endpoint*      # Build secure API
*task create-vue-components*    # Generate Vue components
*task setup-workflow*          # Configure approval flow
```

## Safety First! 🚨

**MANDATORY**: All agents follow safety protocols:
- Universal context detection runs automatically
- Code changes require justification
- Three-strike rule prevents infinite loops
- Frappe-first principles enforced

## Common First Steps

### Scenario 1: New ERPNext App
```bash
# 1. Plan your application
/bmadErpNext:agent:erpnext-product-owner
"I need a service booking system for my spa business"

# 2. Generate the complete app
*workflow business-analysis-to-app*
"Create spa booking system with customer portal and staff management"
```

### Scenario 2: Enhance Existing App
```bash
# 1. Analyze current system
/bmadErpNext:agent:business-analyst
"Analyze our current sales process and suggest automation"

# 2. Add Vue frontend
/bmadErpNext:agent:vue-spa-architect
"Add modern dashboard to existing sales module"
```

### Scenario 3: Migrate from Other Systems
```bash
# From Airtable
*workflow airtable-to-erpnext-migration*
"Migrate our project tracking from Airtable"

# From n8n workflows
*workflow n8n-workflow-conversion*
"Convert our lead nurturing automation from n8n"
```

## Troubleshooting (30 seconds)

### Agent Not Found?
```bash
# Reload the expansion pack
*expansion-pack bmad-erpnext-v16*
```

### Permission Errors?
```bash
# Check your bench environment
cd /home/frappe/frappe-bench
bench --version
```

### Need Help?
```bash
# Use the diagnostic agent
/bmadErpNext:agent:diagnostic-specialist
"I'm having trouble with [specific issue]"
```

## Next Steps

1. **Read CLAUDE.md** - Complete development guidelines
2. **Check TEAM-QUICK-REFERENCE.md** - All available commands
3. **See README.md** - Full feature documentation
4. **Review examples** in `/templates/` directory

## Your Environment

This quickstart assumes:
- **Bench Path**: `/home/frappe/frappe-bench`
- **Site**: `prima-erpnext.pegashosting.com`
- **Framework**: Frappe v16.75.0+

Edit `config.yaml` to match your environment.

---

🎉 **You're ready!** Start building with 31 AI agents and comprehensive ERPNext development toolkit.

**Need more details?** See [INSTALLATION.md](INSTALLATION.md) for comprehensive setup.