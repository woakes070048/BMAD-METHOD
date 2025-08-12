# Install App

## Overview
This task guides you through the complete installation process of your ERPNext app, including dependencies, site setup, and post-installation configuration.

## Prerequisites

### System Requirements
- [ ] Frappe Bench is installed and configured
- [ ] Database server (MariaDB/MySQL) is running
- [ ] Redis server is running (for background jobs)
- [ ] Node.js and npm are installed (for frontend assets)
- [ ] Python 3.8+ with pip installed

### Access Requirements
- [ ] Administrator access to the target site
- [ ] Database permissions for the site
- [ ] File system write permissions
- [ ] Network access for downloading dependencies

## Step-by-Step Process

### Step 1: Pre-Installation Preparation

#### Verify Environment
```bash
# Check bench status
bench --version

# Check site status
bench --site [site-name] status

# Verify database connectivity
bench --site [site-name] console
```

```python
# In the console
import frappe
frappe.db.sql("SELECT 1")
# Should return [(1,)]
```

#### Backup Existing Data (Recommended)
```bash
# Create full site backup
bench --site [site-name] backup --with-files

# Verify backup was created
ls -la sites/[site-name]/private/backups/
```

#### Check App Dependencies
```bash
# Navigate to your app directory
cd apps/your_app

# Check requirements.txt
cat requirements.txt

# Check package.json (if frontend exists)
cat frontend/package.json
```

### Step 2: Install Python Dependencies

#### Install from requirements.txt
```bash
# Install Python dependencies
bench --site [site-name] pip-compile

# Or install specific requirements
pip install -r apps/your_app/requirements.txt
```

#### Verify Installations
```python
# Test in bench console
bench --site [site-name] console

# Verify imports
import pandas
import requests
# etc. - based on your requirements
```

### Step 3: Install Node.js Dependencies (If Applicable)

#### Install Frontend Dependencies
```bash
# If your app has a frontend
cd apps/your_app/frontend

# Install dependencies
npm install

# Build assets
npm run build

# Verify build output
ls -la dist/
```

#### Configure Asset Paths
```python
# In your_app/hooks.py
app_include_js = [
    "/assets/your_app/dist/index.js"
]

app_include_css = [
    "/assets/your_app/dist/index.css"
]

# Build asset files
bench build --app your_app
```

### Step 4: Install the App

#### Basic Installation
```bash
# Install app on site
bench --site [site-name] install-app your_app

# Check installation status
bench --site [site-name] list-apps
```

#### Installation with Specific Version
```bash
# Install specific version
bench get-app your_app --branch version-1.0
bench --site [site-name] install-app your_app
```

#### Installation Log Verification
```bash
# Check installation logs
tail -f logs/web.log

# Or check specific error logs
bench --site [site-name] console
```

```python
# Verify app installation in console
import frappe
frappe.get_installed_apps()
# Should include 'your_app'

# Check app version
frappe.get_version('your_app')
```

### Step 5: Run Database Migrations

#### Execute Migrations
```bash
# Run all pending migrations
bench --site [site-name] migrate

# Force run migrations (if needed)
bench --site [site-name] migrate --force
```

#### Verify Database Schema
```bash
# Check if all tables were created
bench --site [site-name] console
```

```python
# Verify DocTypes are installed
frappe.db.get_list("DocType", {"module": "Your App"})

# Check specific table structure
frappe.db.describe("Your Custom DocType")
```

### Step 6: Install Fixtures and Initial Data

#### Install Default Data
```bash
# Install fixtures defined in hooks.py
bench --site [site-name] install-fixtures

# Or install specific fixtures
bench --site [site-name] import-doc path/to/fixture.json
```

#### Custom Data Installation Script
```python
# Create setup script in your_app/setup.py
import frappe

def after_install():
    """Run after app installation"""
    create_default_data()
    setup_permissions()
    configure_settings()

def create_default_data():
    """Create default records"""
    
    # Create default Customer Groups
    default_groups = [
        {"customer_group_name": "Retail", "parent_customer_group": "All Customer Groups"},
        {"customer_group_name": "Wholesale", "parent_customer_group": "All Customer Groups"}
    ]
    
    for group_data in default_groups:
        if not frappe.db.exists("Customer Group", group_data["customer_group_name"]):
            customer_group = frappe.get_doc({
                "doctype": "Customer Group",
                **group_data
            })
            customer_group.insert()
    
    # Create default Territories
    default_territories = [
        {"territory_name": "North Region", "parent_territory": "All Territories"},
        {"territory_name": "South Region", "parent_territory": "All Territories"}
    ]
    
    for territory_data in default_territories:
        if not frappe.db.exists("Territory", territory_data["territory_name"]):
            territory = frappe.get_doc({
                "doctype": "Territory", 
                **territory_data
            })
            territory.insert()

def setup_permissions():
    """Setup custom permissions"""
    
    # Add role permissions
    from frappe.core.doctype.role.role import desk_properties
    
    roles_to_create = [
        "Sales Executive",
        "Sales Manager",
        "Customer Service"
    ]
    
    for role_name in roles_to_create:
        if not frappe.db.exists("Role", role_name):
            role = frappe.get_doc({
                "doctype": "Role",
                "role_name": role_name,
                **desk_properties
            })
            role.insert()

def configure_settings():
    """Configure app settings"""
    
    # Create custom settings document
    if not frappe.db.exists("Your App Settings", "Your App Settings"):
        settings = frappe.get_doc({
            "doctype": "Your App Settings",
            "name": "Your App Settings",
            "enable_notifications": 1,
            "default_customer_group": "Retail"
        })
        settings.insert()
```

#### Execute Setup Script
```python
# Run setup in console
bench --site [site-name] console

from your_app.setup import after_install
after_install()
```

### Step 7: Configure Permissions and Roles

#### Set Up Role Permissions
```bash
# Create roles and permissions via script
bench --site [site-name] console
```

```python
# Permission setup script
import frappe
from frappe.permissions import add_permission

def setup_permissions():
    """Set up role-based permissions"""
    
    # Customer permissions
    add_permission("Customer", "Sales Executive", 0)  # Read
    add_permission("Customer", "Sales Executive", 1)  # Write  
    add_permission("Customer", "Sales Manager", 0)    # Read
    add_permission("Customer", "Sales Manager", 1)    # Write
    add_permission("Customer", "Sales Manager", 2)    # Create
    add_permission("Customer", "Sales Manager", 3)    # Delete
    
    # Sales Order permissions
    add_permission("Sales Order", "Sales Executive", 0)  # Read
    add_permission("Sales Order", "Sales Executive", 1)  # Write
    add_permission("Sales Order", "Sales Executive", 2)  # Create
    add_permission("Sales Order", "Sales Manager", 0)   # Read  
    add_permission("Sales Order", "Sales Manager", 1)   # Write
    add_permission("Sales Order", "Sales Manager", 2)   # Create
    add_permission("Sales Order", "Sales Manager", 4)   # Submit
    
    frappe.db.commit()
    print("Permissions setup completed")

# Run the setup
setup_permissions()
```

### Step 8: Install and Configure Workflows

#### Create Workflow Documents
```python
# Create workflow for Sales Order approval
def create_workflows():
    
    # Create Workflow States
    workflow_states = [
        {"state": "Draft", "style": "Info"},
        {"state": "Pending Approval", "style": "Warning"},
        {"state": "Approved", "style": "Success"},
        {"state": "Rejected", "style": "Danger"}
    ]
    
    for state_data in workflow_states:
        if not frappe.db.exists("Workflow State", state_data["state"]):
            state = frappe.get_doc({
                "doctype": "Workflow State",
                **state_data
            })
            state.insert()
    
    # Create Workflow Actions
    workflow_actions = [
        {"action_name": "Approve", "allow_self_approval": 0},
        {"action_name": "Reject", "allow_self_approval": 0},
        {"action_name": "Submit for Approval", "allow_self_approval": 1}
    ]
    
    for action_data in workflow_actions:
        if not frappe.db.exists("Workflow Action", action_data["action_name"]):
            action = frappe.get_doc({
                "doctype": "Workflow Action",
                **action_data  
            })
            action.insert()
    
    # Create main workflow
    if not frappe.db.exists("Workflow", "Sales Order Approval"):
        workflow = frappe.get_doc({
            "doctype": "Workflow",
            "workflow_name": "Sales Order Approval",
            "document_type": "Sales Order",
            "is_active": 1,
            "send_email_alert": 1,
            "states": [
                {
                    "state": "Draft",
                    "doc_status": "0",
                    "allow_edit": "Sales Executive",
                    "next_state": "Pending Approval"
                },
                {
                    "state": "Pending Approval", 
                    "doc_status": "0",
                    "allow_edit": "Sales Manager",
                    "next_state": "Approved"
                },
                {
                    "state": "Approved",
                    "doc_status": "1", 
                    "allow_edit": "",
                    "next_state": ""
                }
            ],
            "transitions": [
                {
                    "state": "Draft",
                    "action": "Submit for Approval", 
                    "next_state": "Pending Approval",
                    "allowed": "Sales Executive"
                },
                {
                    "state": "Pending Approval",
                    "action": "Approve",
                    "next_state": "Approved", 
                    "allowed": "Sales Manager"
                }
            ]
        })
        workflow.insert()

# Execute workflow creation
create_workflows()
```

### Step 9: Set Up Email and Notification Templates

#### Create Email Templates
```bash
bench --site [site-name] console
```

```python
# Create email templates
def create_email_templates():
    
    templates = [
        {
            "template_name": "Customer Welcome Email",
            "subject": "Welcome to Our Company!",
            "response": """
            <p>Dear {{ doc.customer_name }},</p>
            <p>Welcome to our company! We're excited to have you as our customer.</p>
            <p>Your customer ID is: <strong>{{ doc.name }}</strong></p>
            <p>If you have any questions, please don't hesitate to contact us.</p>
            <p>Best regards,<br>The Sales Team</p>
            """
        },
        {
            "template_name": "Order Confirmation",
            "subject": "Order Confirmation - {{ doc.name }}",
            "response": """
            <p>Dear {{ doc.customer_name }},</p>
            <p>Thank you for your order! Here are the details:</p>
            <ul>
                <li>Order Number: {{ doc.name }}</li>
                <li>Order Date: {{ doc.transaction_date }}</li>
                <li>Total Amount: {{ doc.grand_total }}</li>
            </ul>
            <p>We will process your order shortly.</p>
            <p>Best regards,<br>The Sales Team</p>
            """
        }
    ]
    
    for template_data in templates:
        if not frappe.db.exists("Email Template", template_data["template_name"]):
            template = frappe.get_doc({
                "doctype": "Email Template",
                **template_data
            })
            template.insert()

create_email_templates()
```

### Step 10: Post-Installation Verification

#### Verify Installation Status
```bash
# Check app status
bench --site [site-name] list-apps

# Verify all services are running
bench --site [site-name] doctor

# Test basic functionality
bench --site [site-name] console
```

```python
# Comprehensive installation test
def verify_installation():
    """Verify app installation is complete and working"""
    
    # Check app is installed
    installed_apps = frappe.get_installed_apps()
    assert "your_app" in installed_apps, "App not installed"
    
    # Check DocTypes are available
    doctypes = frappe.get_all("DocType", {"module": "Your App"})
    assert len(doctypes) > 0, "No DocTypes found"
    
    # Check permissions are set
    customer_perms = frappe.get_all("Custom DocPerm", 
        {"parent": "Customer", "role": "Sales Executive"})
    assert len(customer_perms) > 0, "Permissions not set"
    
    # Check fixtures are installed
    customer_groups = frappe.get_all("Customer Group", {"parent_customer_group": "All Customer Groups"})
    assert len(customer_groups) > 0, "Default data not created"
    
    # Test API endpoints
    try:
        result = frappe.call("your_app.api.test_endpoint")
        assert result.get("success"), "API endpoints not working"
    except:
        pass  # API might not be implemented yet
    
    print("✓ App installation verified successfully!")

# Run verification
verify_installation()
```

#### Performance Check
```python
# Check app performance
import time

def performance_check():
    """Basic performance check after installation"""
    
    start_time = time.time()
    
    # Test database queries
    customers = frappe.get_all("Customer", limit=100)
    
    # Test document creation
    test_customer = frappe.get_doc({
        "doctype": "Customer",
        "customer_name": "Installation Test Customer",
        "email_id": "test@installation.com"
    })
    test_customer.insert()
    
    # Clean up test data
    test_customer.delete()
    
    end_time = time.time()
    duration = end_time - start_time
    
    print(f"Performance check completed in {duration:.2f} seconds")
    
    if duration > 5:
        print("⚠️ Performance seems slow, consider optimization")
    else:
        print("✓ Performance check passed")

performance_check()
```

### Step 11: Configure Production Settings

#### Production Configuration
```python
# Production settings configuration
def configure_production_settings():
    """Configure settings for production environment"""
    
    # System settings
    system_settings = frappe.get_doc("System Settings")
    system_settings.enable_scheduler = 1
    system_settings.disable_website_cache = 0
    system_settings.save()
    
    # App specific settings
    if frappe.db.exists("Your App Settings", "Your App Settings"):
        app_settings = frappe.get_doc("Your App Settings", "Your App Settings")
        app_settings.enable_background_jobs = 1
        app_settings.email_notifications = 1
        app_settings.save()
    
    # Setup scheduled jobs
    from frappe.utils.scheduler import enable_scheduler
    enable_scheduler()
    
    print("✓ Production settings configured")

# Only run in production
if frappe.conf.get("developer_mode") != 1:
    configure_production_settings()
```

#### Build Assets for Production
```bash
# Build optimized assets
bench build --production

# Compress static assets
bench compress

# Clear cache
bench --site [site-name] clear-cache
```

## Post-Installation Tasks

### Configure Backup Strategy
```bash
# Set up automatic backups
# Add to crontab
0 2 * * * cd /path/to/bench && ./env/bin/bench --site [site-name] backup --with-files

# Test backup restoration
bench --site [site-name] restore path/to/backup.sql.gz
```

### Monitor Installation
```python
# Create monitoring script
def monitor_app_health():
    """Monitor app health post-installation"""
    
    # Check database connectivity
    try:
        frappe.db.sql("SELECT 1")
        print("✓ Database connection OK")
    except Exception as e:
        print(f"✗ Database error: {e}")
    
    # Check app functionality
    try:
        frappe.get_all("Customer", limit=1)
        print("✓ App queries working")
    except Exception as e:
        print(f"✗ App query error: {e}")
    
    # Check scheduled jobs
    from frappe.utils.scheduler import get_scheduler_status
    if get_scheduler_status():
        print("✓ Scheduler is running")
    else:
        print("✗ Scheduler is not running")

# Run health check
monitor_app_health()
```

## Common Issues and Solutions

### Issue: Installation Fails with Dependency Errors
**Cause**: Missing Python/Node.js dependencies
**Solution**: 
```bash
# Install missing Python dependencies
pip install -r apps/your_app/requirements.txt

# Install Node.js dependencies
cd apps/your_app/frontend && npm install
```

### Issue: Database Migration Errors
**Cause**: Schema conflicts or missing tables
**Solution**:
```bash
# Force migration
bench --site [site-name] migrate --force

# Check for specific table issues
bench --site [site-name] console
frappe.db.describe("Your DocType")
```

### Issue: Permission Denied Errors
**Cause**: Incorrect file permissions
**Solution**:
```bash
# Fix file permissions
sudo chown -R frappe:frappe apps/your_app
chmod -R 755 apps/your_app
```

### Issue: Frontend Assets Not Loading
**Cause**: Build errors or incorrect paths
**Solution**:
```bash
# Rebuild assets
bench build --app your_app --force

# Check asset paths in hooks.py
```

## Best Practices

### Pre-Installation
- Always backup before installing
- Test installation in development environment first
- Verify all dependencies are available
- Check system requirements

### During Installation
- Monitor installation logs for errors
- Verify each step before proceeding
- Test functionality incrementally
- Document any custom configurations

### Post-Installation
- Run comprehensive functionality tests
- Set up monitoring and alerting
- Configure backup strategies
- Train users on new functionality
- Plan for future updates

---

*Your ERPNext app is now successfully installed and ready for production use. Monitor the system closely during initial usage and be prepared to address any issues that arise.*