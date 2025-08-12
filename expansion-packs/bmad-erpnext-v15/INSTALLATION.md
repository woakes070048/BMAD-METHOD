# BMAD ERPNext v15 Expansion Pack - Installation Guide

## 📋 Table of Contents
- [Prerequisites](#prerequisites)
- [Installation Methods](#installation-methods)
- [Method 1: Automated Setup (Recommended)](#method-1-automated-setup-recommended)
- [Method 2: Manual Configuration](#method-2-manual-configuration)
- [Method 3: Advanced Installation](#method-3-advanced-installation)
- [Configuration Guide](#configuration-guide)
- [Verification & Testing](#verification--testing)
- [Troubleshooting](#troubleshooting)
- [Uninstallation](#uninstallation)
- [Upgrade Instructions](#upgrade-instructions)

---

## Prerequisites

### ✅ System Requirements

**Required:**
- **ERPNext v15.x** installed and running
- **Frappe Framework v15.75.0+**
- **Active Frappe bench** environment
- **Claude Code** installed and configured
- **Python 3.8+**
- **Node.js v18+** (for modern frontend features)
- **Git** for repository management

**Optional but Recommended:**
- **Docker** (for containerized deployments)
- **nginx** (for production deployments)
- **Redis** (for caching and background jobs)

### 🔍 Prerequisites Check

Run these commands to verify your system is ready:

```bash
# Check ERPNext version
bench version

# Check Frappe Framework version
bench --version

# Check Python version
python3 --version

# Check Node.js version
node --version

# Check Claude Code installation
claude --version

# Check if you're in a bench directory
ls sites/common_site_config.json
```

**Expected Output:**
```
✅ ERPNext: v15.x.x
✅ Frappe Framework: v15.75.0+
✅ Python: 3.8+
✅ Node.js: v18+
✅ Claude Code: Available
✅ Bench directory: sites/common_site_config.json found
```

---

## Installation Methods

Choose the installation method that best fits your experience level:

| Method | Best For | Time Required | Technical Level |
|--------|----------|---------------|-----------------|
| [Method 1: Automated](#method-1-automated-setup-recommended) | Most users, first-time setup | 5-10 minutes | Beginner |
| [Method 2: Manual](#method-2-manual-configuration) | Custom setups, learning | 15-20 minutes | Intermediate |
| [Method 3: Advanced](#method-3-advanced-installation) | Enterprise, custom configs | 30+ minutes | Advanced |

---

## Method 1: Automated Setup (Recommended)

### Step 1: Download the Expansion Pack

```bash
# Option A: Download from existing BMAD-METHOD repo
cd /path/to/your/development/directory
git clone https://github.com/bmad-code-org/BMAD-METHOD.git
cd BMAD-METHOD/expansion-packs/bmad-erpnext-v15

# Option B: Download just the expansion pack (if available)
# git clone https://github.com/bmad-code-org/bmad-erpnext-v15.git
# cd bmad-erpnext-v15
```

### Step 2: Run Automated Setup

```bash
# Make setup script executable (if not already)
chmod +x setup.sh

# Run the automated setup
./setup.sh
```

The setup script will:
- ✅ Check all prerequisites
- ✅ Auto-detect your bench path and site
- ✅ Create and configure `config.yaml`
- ✅ Validate the configuration
- ✅ Show you next steps

### Step 3: Test Installation

```bash
# Start Claude Code
claude

# Load the expansion pack
*expansion-pack bmad-erpnext-v15*

# Test with a simple agent
*agent bench-operator*
"Check system status"
```

**Success Indicators:**
- ✅ Setup script completes without errors
- ✅ `config.yaml` created with your settings
- ✅ Claude Code loads the expansion pack
- ✅ Agents respond correctly

---

## Method 2: Manual Configuration

### Step 1: Download and Setup

```bash
# Clone the repository
cd /path/to/your/development/directory
git clone https://github.com/bmad-code-org/BMAD-METHOD.git
cd BMAD-METHOD/expansion-packs/bmad-erpnext-v15

# Verify files are present
ls -la
# Should see: config.yaml.example, setup.sh, README.md, LICENSE, etc.
```

### Step 2: Create Configuration File

```bash
# Copy the example configuration
cp config.yaml.example config.yaml

# Edit with your preferred editor
nano config.yaml
# OR
code config.yaml
# OR
vim config.yaml
```

### Step 3: Configure Your Environment

Edit these key sections in `config.yaml`:

#### 🏠 Environment Settings
```yaml
environment:
  bench_path: "/home/frappe/frappe-bench"          # ← Update this
  primary_site: "your-site-name.com"               # ← Update this
  user: "frappe"                                   # ← Update this
  development_directory: "/path/to/this/directory" # ← Update this
```

#### 📱 Existing Apps
```yaml
existing_apps:
  installed:
    - name: "frappe"
      version: "15.75.0"  # ← Update with your version
      status: "active"
    
    # Add your custom apps here:
    - name: "your_custom_app"      # ← Add if you have custom apps
      type: "custom"
      description: "Your app description"
```

#### ⚙️ Settings (Optional)
```yaml
settings:
  development:
    debug_mode: true        # ← Set to false for production
    log_level: "DEBUG"      # ← Use "INFO" for production
  
  frontend:
    vite_dev_server: true   # ← Enable for development
    pwa_enabled: true       # ← Enable PWA features
```

### Step 4: Validate Configuration

```bash
# Test YAML syntax
python3 -c "import yaml; yaml.safe_load(open('config.yaml'))"

# Should output nothing if syntax is correct
echo "✅ Configuration syntax is valid"
```

### Step 5: Test Installation

```bash
# Start Claude Code
claude

# Load expansion pack
*expansion-pack bmad-erpnext-v15*

# Test basic functionality
*list-agents*
*list-workflows*
```

---

## Method 3: Advanced Installation

### For Enterprise/Production Environments

#### Step 1: Environment Preparation

```bash
# Create dedicated directory structure
mkdir -p /opt/bmad-erpnext-v15
cd /opt/bmad-erpnext-v15

# Set proper ownership
sudo chown -R frappe:frappe /opt/bmad-erpnext-v15

# Clone with specific branch/version
git clone --branch v2.0.0 https://github.com/bmad-code-org/BMAD-METHOD.git
cd BMAD-METHOD/expansion-packs/bmad-erpnext-v15
```

#### Step 2: Multi-Environment Configuration

Create environment-specific configs:

```bash
# Development config
cp config.yaml.example config.dev.yaml
# Edit for development settings

# Staging config  
cp config.yaml.example config.staging.yaml
# Edit for staging settings

# Production config
cp config.yaml.example config.prod.yaml
# Edit for production settings

# Create symlink to active config
ln -sf config.dev.yaml config.yaml
```

#### Step 3: Integration with Existing Systems

```yaml
# config.yaml - Integration section
integration:
  existing_systems:
    docflow:
      description: "Workflow management system"
      integration_points:
        - "Use docflow for complex approval processes"
        - "Leverage existing workflow templates"
    
    custom_app:
      description: "Your custom application"
      integration_points:
        - "API integration endpoints"
        - "Shared data models"
```

#### Step 4: Security Configuration

```bash
# Set restrictive permissions
chmod 600 config.yaml
chmod 600 config.*.yaml

# Create secure backup location
mkdir -p ~/.bmad-backups
chmod 700 ~/.bmad-backups
```

#### Step 5: Docker Integration (Optional)

```bash
# Create Docker setup
cat > Dockerfile << EOF
FROM python:3.10-slim
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
EOF

# Build and run
docker build -t bmad-erpnext-v15 .
docker run -d --name bmad-expansion bmad-erpnext-v15
```

---

## Configuration Guide

### 🎯 Key Configuration Sections

#### 1. Environment Settings
```yaml
environment:
  bench_path: "/home/frappe/frappe-bench"    # Path to your Frappe bench
  primary_site: "mysite.com"                 # Your ERPNext site name
  user: "frappe"                             # System user running ERPNext
  development_directory: "/home/user/dev"    # Where you're developing
```

#### 2. Existing Apps Integration
```yaml
existing_apps:
  installed:
    - name: "frappe"
      version: "15.75.0"
      status: "active"
    - name: "erpnext"
      version: "15.20.0"
      status: "active"
    - name: "your_custom_app"
      type: "custom"
      description: "Your custom application"
```

#### 3. Development Settings
```yaml
settings:
  development:
    auto_reload: true          # Auto-reload during development
    debug_mode: true           # Enable debug logging
    log_level: "DEBUG"         # Logging verbosity
  
  frontend:
    vite_dev_server: true      # Enable Vite dev server
    hot_module_replacement: true # Enable HMR
    pwa_enabled: true          # Enable PWA features
```

### 📝 Configuration Templates

#### For Development Environment:
```yaml
settings:
  development:
    debug_mode: true
    log_level: "DEBUG"
    auto_reload: true
  frontend:
    vite_dev_server: true
    hot_module_replacement: true
```

#### For Production Environment:
```yaml
settings:
  development:
    debug_mode: false
    log_level: "INFO"
    auto_reload: false
  deployment:
    backup_before_deploy: true
    validate_before_deploy: true
    rollback_on_failure: true
```

---

## Verification & Testing

### 🔍 Installation Verification Checklist

#### 1. File Structure Check
```bash
# Verify all required files exist
ls -la
# Expected files:
# ✅ config.yaml
# ✅ config.yaml.example
# ✅ setup.sh
# ✅ LICENSE
# ✅ README.md
# ✅ agents/
# ✅ workflows/
# ✅ templates/
```

#### 2. Configuration Validation
```bash
# Check config.yaml syntax
python3 -c "import yaml; print('✅ Valid YAML') if yaml.safe_load(open('config.yaml')) else print('❌ Invalid YAML')"

# Verify paths exist
# Check if bench_path exists
ls $(grep "bench_path:" config.yaml | cut -d'"' -f2)

# Check if site exists
ls $(grep "bench_path:" config.yaml | cut -d'"' -f2)/sites/$(grep "primary_site:" config.yaml | cut -d'"' -f2)
```

#### 3. Claude Code Integration Test
```bash
# Start Claude Code
claude

# Test expansion pack loading
*expansion-pack bmad-erpnext-v15*
# Expected: Successful loading message

# Test agent availability
*list-agents*
# Expected: List of all agents

# Test workflow availability  
*list-workflows*
# Expected: List of all workflows
```

#### 4. Agent Functionality Test
```bash
# In Claude Code, test basic agents:

# Test bench operations
*agent bench-operator*
"Check bench status and show system information"

# Test ERPNext architecture
*agent erpnext-architect*
"Analyze current ERPNext installation and show system overview"

# Test modern app capabilities
*agent vue-spa-architect*
"Show available Vue 3 and modern frontend capabilities"
```

#### 5. Workflow Test
```bash
# In Claude Code, test workflows:

# Test enhancement workflow
*workflow enhancement*
"Plan enhancement for inventory management system"

# Test modern app development workflow
*workflow modern_app_development*
"Plan development of customer portal application"
```

### ✅ Success Indicators

**Installation Successful When:**
- ✅ All files present in expansion pack directory
- ✅ `config.yaml` created and customized for your environment
- ✅ Claude Code loads expansion pack without errors
- ✅ All agents respond to queries
- ✅ Workflows can be initiated
- ✅ No permission or path errors in logs

---

## Troubleshooting

### 🚨 Common Installation Issues

#### Issue 1: "expansion-pack not found"
**Symptoms:** Claude Code can't find the expansion pack
```bash
*expansion-pack bmad-erpnext-v15*
# Error: expansion pack not found
```

**Solutions:**
```bash
# Check if you're in the right directory
pwd
# Should be: /path/to/BMAD-METHOD/expansion-packs/bmad-erpnext-v15

# Verify config.yaml exists
ls -la config.yaml

# Check file permissions
chmod 644 config.yaml

# Try absolute path
claude --expansion-pack-path="/absolute/path/to/bmad-erpnext-v15"
```

#### Issue 2: "Invalid configuration"
**Symptoms:** YAML syntax errors in config.yaml

**Solutions:**
```bash
# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('config.yaml'))"

# Check for common issues:
# - Missing quotes around paths
# - Incorrect indentation
# - Missing colons
# - Extra spaces

# Reset to example and reconfigure
cp config.yaml config.yaml.backup
cp config.yaml.example config.yaml
# Re-edit config.yaml
```

#### Issue 3: "Bench path not found"
**Symptoms:** Can't find or access bench directory

**Solutions:**
```bash
# Find your bench directory
find /home -name "common_site_config.json" 2>/dev/null
find /opt -name "common_site_config.json" 2>/dev/null

# Update config.yaml with correct path
nano config.yaml
# Update bench_path: "/correct/path/to/frappe-bench"

# Check permissions
ls -la /path/to/frappe-bench/
# Should be accessible by your user
```

#### Issue 4: "Site not found"
**Symptoms:** ERPNext site not accessible

**Solutions:**
```bash
# List available sites
ls /path/to/frappe-bench/sites/

# Check site is active
bench --site your-site.com doctor

# Update config.yaml with correct site name
nano config.yaml
# Update primary_site: "correct-site-name.com"
```

#### Issue 5: Claude Code not starting
**Symptoms:** `claude` command not found

**Solutions:**
```bash
# Check if Claude Code is installed
which claude

# Install Claude Code if missing
# Follow: https://docs.anthropic.com/en/docs/claude-code

# Check PATH
echo $PATH

# Try with full path
/usr/local/bin/claude
```

### 🔧 Advanced Troubleshooting

#### Enable Debug Mode
```yaml
# In config.yaml
settings:
  development:
    debug_mode: true
    log_level: "DEBUG"
```

#### Check Logs
```bash
# Claude Code logs (if available)
tail -f ~/.claude/logs/debug.log

# System logs
journalctl -f -u claude

# ERPNext logs
tail -f /path/to/frappe-bench/logs/*.log
```

#### Permission Issues
```bash
# Fix file permissions
chmod 755 setup.sh
chmod 644 config.yaml
chmod 644 *.md

# Fix directory permissions
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
```

---

## Uninstallation

### 🗑️ Complete Removal

#### Method 1: Simple Removal
```bash
# Remove expansion pack directory
rm -rf /path/to/BMAD-METHOD/expansion-packs/bmad-erpnext-v15

# Or remove entire BMAD-METHOD if only using this pack
rm -rf /path/to/BMAD-METHOD
```

#### Method 2: Clean Removal
```bash
# Backup configuration (optional)
cp config.yaml ~/.bmad-backup-config.yaml

# Remove symlinks if created
rm -f ~/.claude/expansion-packs/bmad-erpnext-v15

# Remove directory
rm -rf /path/to/BMAD-METHOD/expansion-packs/bmad-erpnext-v15

# Clear Claude Code cache (if applicable)
rm -rf ~/.claude/cache/bmad-erpnext-v15
```

### 🧹 Cleanup Verification
```bash
# Verify removal
claude
*list-expansion-packs*
# bmad-erpnext-v15 should not be listed

# Check no residual files
find /home -name "*bmad-erpnext-v15*" 2>/dev/null
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

#### Step 2: Download New Version
```bash
# Pull latest changes
git pull origin main

# Or download new version
# git fetch --tags
# git checkout v2.1.0
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
# Validate configuration
python3 -c "import yaml; yaml.safe_load(open('config.yaml'))"

# Test in Claude Code
claude
*expansion-pack bmad-erpnext-v15*
*agent bench-operator*
"Test upgrade by showing system status"
```

### 📋 Upgrade Checklist
- ✅ Current installation backed up
- ✅ New version downloaded
- ✅ Configuration updated and tested
- ✅ All agents working correctly
- ✅ Workflows functioning properly
- ✅ No errors in Claude Code integration

---

## 🎉 Next Steps After Installation

### 1. Explore the Expansion Pack
```bash
# Check available documentation
ls *.md
# Read: README.md, QUICKSTART.md, TROUBLESHOOTING.md

# Explore agent capabilities
*list-agents*
*agent-info vue-spa-architect*
```

### 2. Try Your First Project
```bash
# Modern app development
*agent-team modern-app-team*
"Create a customer portal with Vue 3 SPA frontend"

# Business process automation
*agent-team automation-team*
"Automate purchase order approval workflow"

# System migration
*agent-team airtable-migration-team*
"Plan migration from Airtable CRM to ERPNext"
```

### 3. Join the Community
- 📚 Read the complete documentation
- 🔧 Try the example workflows
- 💬 Join community discussions
- 🐛 Report issues on GitHub
- 🤝 Contribute improvements

---

## 📞 Getting Help

### Resources
- **Documentation**: README.md, QUICKSTART.md, TROUBLESHOOTING.md
- **GitHub Issues**: Report bugs and request features
- **Community Forum**: Discuss usage and best practices
- **Support**: Professional support available

### Before Asking for Help
1. ✅ Check TROUBLESHOOTING.md
2. ✅ Verify installation steps
3. ✅ Test with basic agents first
4. ✅ Check system logs for errors
5. ✅ Try with a fresh config.yaml

---

**🚀 Ready to build amazing ERPNext applications with BMAD ERPNext v15!**