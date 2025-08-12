# BMAD ERPNext v15 Expansion Pack - Installation Guide

## 📋 Table of Contents
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Installation Methods](#installation-methods)
- [Using the Expansion Pack](#using-the-expansion-pack)
- [Configuration Guide](#configuration-guide)
- [Troubleshooting](#troubleshooting)
- [Upgrade Instructions](#upgrade-instructions)

---

## Prerequisites

### ✅ System Requirements

**For BMAD-METHOD Framework:**
- **Node.js v20+** (required for BMAD-METHOD)
- **Git** for repository management
- **AI Platform** (Gemini Gem, CustomGPT, or compatible IDE)

**For ERPNext Development (if implementing generated code):**
- **ERPNext v15.x** installed and running
- **Frappe Framework v15.75.0+**
- **Active Frappe bench** environment
- **Python 3.8+**

### 🔍 Prerequisites Check

```bash
# Check Node.js version (for BMAD-METHOD)
node --version  # Should be v20+

# If you plan to implement ERPNext code:
bench version   # Check ERPNext version
bench --version # Check Frappe Framework version
python3 --version # Check Python version
```

---

## Quick Start

### 🚀 Fastest Installation (2 minutes)

```bash
# Clone BMAD-METHOD with the ERPNext expansion pack
git clone https://github.com/woakes070048/BMAD-METHOD.git
cd BMAD-METHOD

# Install BMAD-METHOD
npm install

# The expansion pack is already in expansion-packs/bmad-erpnext-v15/
# Ready to use!
```

### Using in Web UI (Gemini Gem or CustomGPT)

1. **Build the team bundle**:
```bash
# Navigate to expansion pack
cd expansion-packs/bmad-erpnext-v15

# Build team file (coming soon - for now use individual agent files)
npm run build:team
```

2. **Create AI Agent**:
   - Go to Gemini Gem or CustomGPT
   - Create a new agent/gem
   - Upload the team bundle or individual agent files

3. **Set Instructions**:
   ```
   Your critical operating instructions are attached, do not break character as directed.
   You are part of the BMAD ERPNext v15 development team.
   ```

4. **Start Using**:
   - Type `*help` to see available commands
   - Use `*agent erpnext-architect` to activate specific agents
   - Use `*workflow modern-app-development` to start workflows

---

## Installation Methods

### Method 1: Using with BMAD-METHOD Framework

```bash
# If you already have BMAD-METHOD installed in a project:
cd your-project
npx bmad-method install

# The installer will detect and install the ERPNext expansion pack
# from expansion-packs/bmad-erpnext-v15/
```

### Method 2: Direct Repository Usage

```bash
# Clone the repository
git clone https://github.com/woakes070048/BMAD-METHOD.git
cd BMAD-METHOD

# Install dependencies
npm install

# The expansion pack is in expansion-packs/bmad-erpnext-v15/
# Use directly with your AI platform
```

### Method 3: IDE Integration

```bash
# In your ERPNext development project
cd /path/to/your/erpnext-project

# Install BMAD-METHOD
npx bmad-method install

# Copy the ERPNext expansion pack
cp -r /path/to/BMAD-METHOD/expansion-packs/bmad-erpnext-v15 bmad/expansion-packs/

# Configure for your ERPNext environment
cd bmad/expansion-packs/bmad-erpnext-v15
cp config.yaml.example config.yaml
# Edit config.yaml with your ERPNext settings
```

---

## Using the Expansion Pack

### 🌐 Web UI Usage (Gemini Gem, CustomGPT)

#### Step 1: Prepare Agent Files

```bash
# Navigate to the expansion pack
cd expansion-packs/bmad-erpnext-v15

# Agents are in the agents/ directory
ls agents/
# Shows: erpnext-architect.yaml, api-developer.yaml, etc.
```

#### Step 2: Create Your AI Agent

1. **For Gemini Gem**:
   - Go to [Google AI Studio](https://makersuite.google.com/)
   - Create a new Gem
   - Upload agent files from `agents/` directory
   - Set system instructions

2. **For CustomGPT**:
   - Go to ChatGPT
   - Create a new GPT
   - Upload agent files
   - Configure instructions

#### Step 3: Agent Instructions Template

```
You are an expert ERPNext v15 development team member.
Your operating instructions are defined in the attached files.
Do not break character as directed.

Available commands:
*help - Show available commands
*agent [name] - Switch to specific agent
*workflow [name] - Start a workflow
*team [name] - Activate an agent team

You specialize in:
- ERPNext v15 architecture and development
- Frappe Framework best practices
- Vue 3 and modern frontend development
- Business process automation
- System migrations and integrations
```

### 💻 IDE Usage (VS Code, Cursor, etc.)

#### With BMAD-METHOD Core

If you have BMAD-METHOD installed in your project:

```bash
# Your agents work alongside BMAD core agents
*agent erpnext-architect
# Analyzes ERPNext architecture

*workflow modern-app-development  
# Starts modern app development workflow

*team modern-app-team
# Activates the modern app development team
```

#### Standalone Usage

Use the agents directly in your IDE with AI assistants:

1. **Load agent content** into your AI assistant
2. **Provide context** about your ERPNext project
3. **Use agent expertise** for development tasks

### 📝 Available Agents

#### Core Development Agents
- `erpnext-architect` - System architecture and design
- `bench-operator` - Bench operations and commands
- `doctype-designer` - DocType creation and modeling
- `api-developer` - API endpoint development
- `workflow-specialist` - Workflow implementation

#### Frontend Specialists
- `vue-spa-architect` - Vue 3 SPA architecture
- `frappe-ui-developer` - frappe-ui components
- `pwa-specialist` - PWA implementation
- `mobile-ui-specialist` - Mobile optimization

#### Business & Migration
- `business-analyst` - Requirements analysis
- `n8n-workflow-analyst` - n8n workflow analysis
- `airtable-analyzer` - Airtable migration
- `workflow-converter` - Workflow conversion

### 🤝 Available Agent Teams

- **modern-app-team** - Complete modern app development
- **deployment-team** - Production deployment
- **workflow-team** - Business process automation
- **business-analysis-team** - Requirements and analysis
- **n8n-conversion-team** - n8n to ERPNext conversion
- **airtable-migration-team** - Airtable migration
- **automation-team** - Process automation
- **mobile-team** - Mobile app development

### 🔄 Available Workflows

- `modern-app-development` - Build modern ERPNext apps
- `business-analysis-to-app` - From analysis to application
- `n8n-workflow-conversion` - Convert n8n workflows
- `airtable-to-erpnext-migration` - Migrate from Airtable
- `enhancement` - Enhance existing systems

---

## Configuration Guide

### Setting Up config.yaml

For ERPNext-specific configuration:

```bash
# Copy the example configuration
cp config.yaml.example config.yaml

# Edit with your preferred editor
nano config.yaml
```

#### Key Configuration Sections

```yaml
# ERPNext Environment Settings
environment:
  bench_path: "/home/frappe/frappe-bench"  # Your bench path
  primary_site: "your-site.com"            # Your ERPNext site
  user: "frappe"                           # System user
  development_directory: "/path/to/dev"    # Development directory

# Existing Apps Integration
existing_apps:
  installed:
    - name: "frappe"
      version: "15.75.0"
      status: "active"
    - name: "erpnext"
      version: "15.x"
      status: "active"
    # Add your custom apps here

# Development Settings
settings:
  development:
    debug_mode: true      # Set to false for production
    log_level: "DEBUG"    # Use "INFO" for production
  
  frontend:
    vite_dev_server: true # Enable for development
    pwa_enabled: true     # Enable PWA features
```

---

## Troubleshooting

### Common Issues

#### Issue: "Cannot find BMAD-METHOD"
**Solution**:
```bash
# Ensure you're in the right directory
ls expansion-packs/bmad-erpnext-v15/
# Should show: agents/, workflows/, templates/, etc.
```

#### Issue: "Agent not loading in Web UI"
**Solution**:
- Ensure you uploaded the correct `.yaml` files from `agents/`
- Check that system instructions reference BMAD-METHOD
- Verify the agent file syntax is valid YAML

#### Issue: "ERPNext commands not working"
**Solution**:
```bash
# The agents provide ERPNext expertise and generate code
# You still need an actual ERPNext installation to run the code

# Check ERPNext is installed:
bench version

# If not installed, the agents can guide installation:
*agent erpnext-architect
"Guide me through ERPNext installation"
```

#### Issue: "Workflow not starting"
**Solution**:
```bash
# Workflows coordinate multiple agents
# Ensure you have the required context:

*workflow modern-app-development
# Provide project requirements when prompted
```

---

## Upgrade Instructions

### 🔄 Upgrading to Newer Versions

#### Step 1: Backup Current Installation
```bash
# Backup your configuration
cp config.yaml config.yaml.backup-$(date +%Y%m%d)

# Backup entire directory (optional)
tar -czf bmad-erpnext-v15-backup-$(date +%Y%m%d).tar.gz .
```

#### Step 2: Pull Latest Changes
```bash
# In BMAD-METHOD directory
git pull origin main

# Or update via npm
npx bmad-method install
```

#### Step 3: Update Configuration
```bash
# Check for new config options
diff config.yaml.example config.yaml.backup-*

# Merge new options if needed
cp config.yaml.example config.yaml.new
# Manually merge your settings from backup

# Replace old config
mv config.yaml.new config.yaml
```

#### Step 4: Test Upgrade
```bash
# Test in Web UI or IDE
*agent erpnext-architect
"Test system status"

# Verify workflows
*workflow enhancement
"Test workflow functionality"
```

---

## 🎉 Next Steps

### After Installation

1. **Explore Available Agents**:
   - Review agent capabilities in `agents/` directory
   - Test different agents for your use case

2. **Try Example Workflows**:
   - Start with `modern-app-development` for new apps
   - Use `enhancement` for existing systems
   - Try `business-analysis-to-app` for complete projects

3. **Join the Community**:
   - Report issues on GitHub
   - Share your experiences
   - Contribute improvements

### Quick Examples

```bash
# Modern app development
*team modern-app-team
"Create a customer portal with Vue 3 frontend"

# Business process automation
*team automation-team
"Automate purchase order approval workflow"

# System migration
*team airtable-migration-team
"Migrate CRM from Airtable to ERPNext"
```

---

**Ready to build amazing ERPNext applications with BMAD-METHOD!** 🚀

For more information:
- **README.md** - Complete feature overview
- **QUICKSTART.md** - 5-minute quick start guide
- **TROUBLESHOOTING.md** - Detailed troubleshooting
- **GitHub Repository** - https://github.com/woakes070048/BMAD-METHOD