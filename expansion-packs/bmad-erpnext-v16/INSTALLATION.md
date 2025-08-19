# INSTALLATION.md - Complete Installation Guide

Comprehensive installation guide for the BMAD ERPNext v16 expansion pack.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation Methods](#installation-methods)
- [Configuration](#configuration)
- [Verification](#verification)
- [Environment-Specific Setup](#environment-specific-setup)
- [Advanced Configuration](#advanced-configuration)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements

**Operating System**
- Linux (Ubuntu 20.04+ recommended)
- macOS (10.15+)
- Windows (WSL2 required)

**Software Dependencies**
```bash
# Node.js (Required for BMAD Method installer)
node --version    # v20.0.0 or higher
npm --version     # v9.0.0 or higher

# Frappe Framework (Required for ERPNext development)
frappe --version  # v16.75.0 or higher
bench --version   # v5.0.0 or higher

# Git (Required for cloning)
git --version     # v2.20.0 or higher

# Python (Usually included with Frappe)
python3 --version # v3.10+ or higher
```

### ERPNext Environment

**Required**
- Existing Frappe Framework v16 installation
- ERPNext v16 app installed and configured
- Active bench environment with at least one site

**Verify Your Environment**
```bash
# Check bench status
cd /home/frappe/frappe-bench
bench status

# Verify site is active
bench --site [your-site] console
>>> frappe.ping()
'pong'
>>> exit()

# Check ERPNext installation
bench --site [your-site] list-apps
# Should show 'erpnext' in the list
```

## Installation Methods

### Method 1: Auto-Installer (Recommended)

The BMAD Method installer automatically sets up everything you need.

```bash
# Navigate to your app directory (create if needed)
cd /home/frappe/frappe-bench/apps
mkdir -p my-custom-app && cd my-custom-app

# Run the installer
npx bmad-method install --full --expansion-packs bmad-erpnext-v16

# The installer will:
# ✅ Download and install BMAD Method core
# ✅ Install bmad-erpnext-v16 expansion pack
# ✅ Set up all 31 agents and workflows
# ✅ Create configuration files
# ✅ Configure Claude Code integration
```

**Installation Complete!** Skip to [Verification](#verification) section.

### Method 2: Git Clone (Manual)

For development or custom setups.

```bash
# Step 1: Clone the repository
git clone https://github.com/woakes070048/BMAD-METHOD.git
cd BMAD-METHOD

# Step 2: Navigate to the expansion pack
cd expansion-packs/bmad-erpnext-v16

# Step 3: Install dependencies (if using npm-based workflows)
npm install  # Optional: only if you plan to use Node.js tools

# Step 4: Copy configuration template
cp config.yaml.example config.yaml
```

### Method 3: Download Release

For offline or restricted environments.

```bash
# Download the latest release
wget https://github.com/woakes070048/BMAD-METHOD/archive/refs/heads/main.zip
unzip main.zip
cd BMAD-METHOD-main/expansion-packs/bmad-erpnext-v16

# Copy configuration template
cp config.yaml.example config.yaml
```

## Configuration

### Step 1: Basic Configuration

Edit the `config.yaml` file to match your environment:

```yaml
# Update these paths for your environment
environment:
  bench_path: "/home/frappe/frappe-bench"              # Your bench directory
  primary_site: "prima-erpnext.pegashosting.com"      # Your primary site
  user: "frappe"                                       # Your system user
  development_directory: "/home/frappe/frappe-bench/apps/ai_employee"  # Your app directory
```

### Step 2: App Configuration

Configure existing apps in your environment:

```yaml
existing_apps:
  installed:
    - name: "frappe"
      version: "16.75.0"  # Update with your version
      status: "active"
    
    - name: "erpnext"
      version: "16.0.0"   # Update with your version
      status: "active"
    
    # Add your custom apps here
    - name: "your_custom_app"
      type: "custom"
      description: "Your app description"
      version: "1.0.0"
      status: "active"
```

### Step 3: Integration Configuration

If you have additional systems, configure integrations:

```yaml
# DocFlow Integration (if installed)
docflow:
  description: "Workflow management system"
  status: "active"
  integration_points:
    - "Multi-stage approval workflows"
    - "Document routing and state management"

# Uncomment and configure if you have these systems
# server_manager:
#   description: "Server management application"
#   status: "requires_validation"

# n8n_integration:
#   description: "Automation platform integration"
#   status: "active"
```

### Step 4: Environment Settings

Customize settings for your development workflow:

```yaml
settings:
  development:
    auto_reload: true
    debug_mode: true           # Set to false for production
    log_level: "DEBUG"         # Use "INFO" for production
    
  frontend:
    native_vue_integration: true
    frappe_build_pipeline: true
    frappe_ui_version: "0.1.171"  # Update to latest
    pwa_enabled: true
  
  testing:
    run_parallel_tests: false     # Set to true if your system can handle it
    test_timeout: 300
    coverage_threshold: 80
```

## Verification

### Step 1: Test Claude Code Integration

```bash
# In Claude Code, load the expansion pack
*expansion-pack bmad-erpnext-v16*

# Should display:
# ✅ Loaded bmad-erpnext-v16 v3.0.0
# ✅ 31 agents available
# ✅ 12 agent teams configured
# ✅ 9 workflows ready
```

### Step 2: Test Agent Access

```bash
# Test a simple agent
/bmadErpNext:agent:erpnext-product-owner
"Hello, can you help me plan a simple ERPNext feature?"

# Should respond with character introduction and readiness to help
```

### Step 3: Test Development Commands

```bash
# Test bench operations
/bmadErpNext:agent:bench-operator
"Show me the status of my ERPNext site"

# Test diagnostic capabilities
/bmadErpNext:agent:diagnostic-specialist
"Check my ERPNext installation health"
```

### Step 4: Verify File Structure

```bash
# Check expansion pack structure
ls -la /path/to/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/

# Should show:
# ✅ agents/ (31 agent files)
# ✅ agent-teams/ (12 team files)
# ✅ workflows/ (9 workflow files)
# ✅ templates/ (55+ template files)
# ✅ tasks/ (60+ task files)
# ✅ data/ (25+ reference files)
# ✅ config.yaml (your configuration)
```

## Environment-Specific Setup

### Development Environment

```yaml
settings:
  development:
    auto_reload: true
    debug_mode: true
    log_level: "DEBUG"
  
  testing:
    run_parallel_tests: false
    test_timeout: 300
    frontend_tests: true
```

### Staging Environment

```yaml
settings:
  development:
    auto_reload: false
    debug_mode: false
    log_level: "INFO"
  
  deployment:
    validate_before_deploy: true
    backup_before_deploy: true
    build_frontend: true
```

### Production Environment

```yaml
settings:
  development:
    auto_reload: false
    debug_mode: false
    log_level: "ERROR"
  
  deployment:
    backup_before_deploy: true
    validate_before_deploy: true
    rollback_on_failure: true
    optimize_bundle: true
```

## Advanced Configuration

### Custom Agent Configuration

Add your own agents to the configuration:

```yaml
agents:
  custom:
    - "my-custom-agent"
    - "specialized-validator"

# Create corresponding files in agents/ directory
```

### Workflow Customization

Modify existing workflows or add new ones:

```yaml
workflows:
  custom_development:
    - "gather_requirements"
    - "create_custom_doctypes"
    - "implement_business_logic"
    - "deploy_and_test"
```

### Integration Hooks

Configure hooks for external systems:

```yaml
integration:
  webhooks:
    endpoint: "https://your-system.com/webhook"
    secret: "your-webhook-secret"
    events: ["doctype_created", "workflow_completed"]
```

## Docker Installation (Optional)

For containerized environments:

```dockerfile
# Dockerfile example
FROM frappe/erpnext:v16.0.0

# Copy expansion pack
COPY expansion-packs/bmad-erpnext-v16 /home/frappe/.bmad-method/

# Configure
RUN cp /home/frappe/.bmad-method/config.yaml.example \
       /home/frappe/.bmad-method/config.yaml

# Set permissions
RUN chown -R frappe:frappe /home/frappe/.bmad-method/
```

## IDE Integration

### VS Code Setup

Install recommended extensions:
```bash
# Extensions for better ERPNext development
code --install-extension ms-python.python
code --install-extension vue.volar
code --install-extension bradlc.vscode-tailwindcss
```

Add to `.vscode/settings.json`:
```json
{
  "python.defaultInterpreter": "/home/frappe/frappe-bench/env/bin/python",
  "python.linting.enabled": true,
  "python.linting.flake8Enabled": true
}
```

### Claude Code Setup

The expansion pack automatically configures Claude Code integration. If manual setup is needed:

```bash
# Set expansion pack path in Claude Code settings
export BMAD_EXPANSION_PACK_PATH="/path/to/BMAD-METHOD/expansion-packs"
```

## Post-Installation Tasks

### 1. Create Your First Project

```bash
# Generate a complete ERPNext app
*workflow business-analysis-to-app*
"Create a simple customer feedback system"
```

### 2. Set Up Development Workflow

```bash
# Configure git hooks
cd /home/frappe/frappe-bench/apps/your-app
git init
git add .
git commit -m "Initial commit with BMAD ERPNext v16"
```

### 3. Test Production Deployment

```bash
# Use deployment team for production setup
*agent-team deployment-team*
"Set up production environment for my ERPNext app"
```

## Security Considerations

### File Permissions

```bash
# Ensure proper permissions
chmod 755 /path/to/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/
chmod 644 /path/to/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/config.yaml
```

### API Security

The expansion pack includes comprehensive API security patterns:
- Automatic @frappe.whitelist() enforcement
- Permission validation patterns
- Security checklists for all development

### Data Protection

- No sensitive data is stored in configuration files
- All generated code follows Frappe security best practices
- Built-in compliance validation with Eva Thorne agent

## Backup and Recovery

### Configuration Backup

```bash
# Backup your configuration
cp config.yaml config.yaml.backup.$(date +%Y%m%d)

# Version control your config (without secrets)
git add config.yaml
git commit -m "Update BMAD configuration"
```

### Full Installation Backup

```bash
# Create complete backup
tar -czf bmad-erpnext-v16-backup-$(date +%Y%m%d).tar.gz \
  /path/to/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/
```

## Troubleshooting

### Common Issues

**Issue**: "Expansion pack not found"
```bash
# Solution: Verify path and reload
*expansion-pack bmad-erpnext-v16*
```

**Issue**: "Agent not responding"
```bash
# Solution: Check agent configuration
cat agents/[agent-name].md
```

**Issue**: "Permission denied"
```bash
# Solution: Check file permissions
ls -la config.yaml
chmod 644 config.yaml
```

For comprehensive troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## Getting Help

1. **Documentation**: Check `CLAUDE.md` for development guidelines
2. **Quick Reference**: See `TEAM-QUICK-REFERENCE.md` for command list
3. **Diagnostic Agent**: Use `/bmadErpNext:agent:diagnostic-specialist`
4. **Community**: Visit GitHub issues for support

## Next Steps

1. **Read the Documentation**:
   - [QUICKSTART.md](QUICKSTART.md) - 5-minute setup
   - [CLAUDE.md](CLAUDE.md) - Development guidelines
   - [README.md](README.md) - Complete feature overview

2. **Try Your First Project**:
   - Start with the Product Owner agent
   - Use business-analysis-to-app workflow
   - Build something simple first

3. **Explore Advanced Features**:
   - n8n workflow conversion
   - Airtable migration
   - Modern Vue SPA development

---

🎉 **Installation Complete!** You now have access to 31 specialized AI agents and comprehensive ERPNext development capabilities.