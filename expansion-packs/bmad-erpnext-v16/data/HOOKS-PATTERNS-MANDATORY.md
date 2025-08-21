# 🚨 HOOKS.PY PATTERNS - MANDATORY FOR ALL FRAPPE APPS

## CRITICAL: Without Proper hooks.py, Your App WILL NOT WORK

This document contains MANDATORY patterns for hooks.py configuration. Every Frappe app MUST have a properly configured hooks.py file or it will not function.

---

## 🔴 THE MOST CRITICAL FILE IN YOUR APP

### What is hooks.py?
- **Location**: `[app_name]/hooks.py`
- **Purpose**: Tells Frappe how to integrate your app
- **Without it**: Your app is invisible to Frappe

### 🚨 MANDATORY MINIMUM CONFIGURATION

```python
# [app_name]/hooks.py
from frappe import _

# 🚨 MANDATORY: App metadata
app_name = "your_app_name"
app_title = "Your App Title"
app_publisher = "Your Company"
app_description = "Brief description of your app"
app_icon = "fa fa-cube"  # FontAwesome icon
app_color = "blue"       # Theme color
app_email = "contact@example.com"
app_license = "MIT"
app_version = "1.0.0"

# 🚨 MANDATORY: Include app in desk
app_include_js = "/assets/your_app_name/js/your_app.js"
app_include_css = "/assets/your_app_name/css/your_app.css"

# 🚨 CRITICAL: DocType JavaScript (for form customization)
doctype_js = {
    "Customer": "public/js/customer.js",
    "Sales Order": ["public/js/sales_order.js"],
}

# 🚨 CRITICAL: DocType Python controllers
doc_events = {
    "Customer": {
        "validate": "your_app_name.overrides.customer.validate",
        "after_insert": "your_app_name.overrides.customer.after_insert"
    },
    "*": {  # Apply to ALL DocTypes
        "before_save": "your_app_name.utils.log_all_saves"
    }
}

# 🚨 MANDATORY for scheduled tasks
scheduler_events = {
    "cron": {
        "0 0 * * *": [  # Daily at midnight
            "your_app_name.tasks.daily_cleanup"
        ]
    },
    "hourly": [
        "your_app_name.tasks.sync_data"
    ],
    "daily": [
        "your_app_name.tasks.send_daily_report"
    ],
    "weekly": [
        "your_app_name.tasks.weekly_backup"
    ]
}
```

---

## 🔴 DOC EVENTS - HOOKING INTO DOCUMENT LIFECYCLE

### NEVER DO THIS:
```python
# ❌ WRONG - Won't work!
doc_events = {
    "Customer": "your_app_name.customer.validate"  # WRONG - Not a dict!
}
```

### ALWAYS DO THIS:
```python
# ✅ CORRECT - Proper structure
doc_events = {
    "Customer": {
        "validate": "your_app_name.overrides.customer.validate",
        "before_save": "your_app_name.overrides.customer.before_save",
        "after_insert": "your_app_name.overrides.customer.after_insert",
        "on_update": "your_app_name.overrides.customer.on_update",
        "on_submit": "your_app_name.overrides.customer.on_submit",
        "on_cancel": "your_app_name.overrides.customer.on_cancel",
        "on_trash": "your_app_name.overrides.customer.on_trash"
    }
}
```

### Available Document Events:
```python
# Complete list of hookable events
doc_events = {
    "DocType Name": {
        # VALIDATION PHASE
        "validate": "module.path.function",        # Before validation
        "before_naming": "module.path.function",   # Before name is set
        
        # SAVE PHASE  
        "before_save": "module.path.function",     # Before saving to DB
        "after_insert": "module.path.function",    # After first save
        "on_update": "module.path.function",       # After any save
        
        # SUBMISSION PHASE (for submittable doctypes)
        "before_submit": "module.path.function",   # Before submission
        "on_submit": "module.path.function",       # After submission
        
        # CANCELLATION PHASE
        "before_cancel": "module.path.function",   # Before cancellation
        "on_cancel": "module.path.function",       # After cancellation
        
        # DELETION PHASE
        "on_trash": "module.path.function",        # Before deletion
        "after_delete": "module.path.function",    # After deletion
        
        # SPECIAL EVENTS
        "on_change": "module.path.function",       # Any field change
        "before_update_after_submit": "module.path.function"  # Special case
    }
}
```

### Event Handler Pattern:
```python
# your_app_name/overrides/customer.py
import frappe
from frappe import _

def validate(doc, method):
    """
    Called during document validation
    Args:
        doc: The document instance
        method: The method name (e.g., "validate")
    """
    # Your validation logic
    if not doc.customer_group:
        frappe.throw(_("Customer Group is mandatory"))
    
    # Set computed fields
    doc.full_name = f"{doc.first_name} {doc.last_name}".strip()

def after_insert(doc, method):
    """Called after document is inserted"""
    # Create related documents
    frappe.get_doc({
        "doctype": "Welcome Task",
        "customer": doc.name,
        "assigned_to": frappe.session.user
    }).insert()
    
    # Send notifications
    frappe.sendmail(
        recipients=[doc.email_id],
        subject="Welcome!",
        message="Welcome to our system"
    )
```

---

## 🔴 SCHEDULER EVENTS - BACKGROUND TASKS

### Scheduler Event Types:

```python
scheduler_events = {
    # CRON FORMAT (most flexible)
    "cron": {
        "*/5 * * * *": [  # Every 5 minutes
            "your_app_name.tasks.check_alerts"
        ],
        "0 2 * * *": [    # Daily at 2 AM
            "your_app_name.tasks.daily_backup"
        ],
        "0 0 * * 0": [    # Weekly on Sunday
            "your_app_name.tasks.weekly_report"
        ]
    },
    
    # SIMPLE INTERVALS
    "all": [  # Runs every minute
        "your_app_name.tasks.process_queue"
    ],
    
    "hourly": [
        "your_app_name.tasks.hourly_sync"
    ],
    
    "hourly_long": [  # For tasks taking > 5 minutes
        "your_app_name.tasks.generate_reports"
    ],
    
    "daily": [
        "your_app_name.tasks.daily_cleanup"
    ],
    
    "daily_long": [   # For tasks taking > 10 minutes
        "your_app_name.tasks.data_migration"
    ],
    
    "weekly": [
        "your_app_name.tasks.weekly_maintenance"
    ],
    
    "weekly_long": [  # For tasks taking > 30 minutes
        "your_app_name.tasks.full_backup"
    ],
    
    "monthly": [
        "your_app_name.tasks.monthly_invoice"
    ],
    
    "monthly_long": [  # For tasks taking > 60 minutes
        "your_app_name.tasks.archive_old_data"
    ]
}
```

### Scheduler Task Pattern:
```python
# your_app_name/tasks.py
import frappe
from frappe.utils import now_datetime, add_days

def daily_cleanup():
    """Daily cleanup task - MUST be efficient"""
    # Delete old logs
    frappe.db.sql("""
        DELETE FROM `tabError Log` 
        WHERE creation < %s
    """, add_days(now_datetime(), -30))
    
    # Clear old sessions
    frappe.db.sql("""
        DELETE FROM `tabSessions` 
        WHERE lastupdate < %s
    """, add_days(now_datetime(), -7))
    
    frappe.db.commit()

def hourly_sync():
    """Hourly sync task"""
    # Use enqueue for long-running tasks
    from frappe.utils.background_jobs import enqueue
    
    enqueue(
        "your_app_name.sync.run_full_sync",
        queue="long",
        timeout=3000
    )
```

---

## 🔴 FIXTURES - DATA THAT SHIPS WITH YOUR APP

```python
# Export specific records with your app
fixtures = [
    # Export ALL records of these DocTypes
    "Custom Field",
    "Property Setter",
    
    # Export with filters
    {
        "dt": "Print Format",
        "filters": [["module", "=", "Your App Name"]]
    },
    {
        "dt": "Workflow",
        "filters": [["document_type", "in", ["Sales Order", "Purchase Order"]]]
    },
    {
        "dt": "Role",
        "filters": [["name", "in", ["Sales Admin", "Purchase Admin"]]]
    }
]
```

---

## 🔴 WHITELISTED METHODS - API ENDPOINTS

```python
# Override whitelisted methods
override_whitelisted_methods = {
    "frappe.desk.search.search_link": "your_app_name.overrides.custom_search_link",
    "frappe.core.doctype.user.user.get_users": "your_app_name.overrides.get_filtered_users"
}

# Override DocType classes
override_doctype_class = {
    "Customer": "your_app_name.overrides.CustomCustomer"
}
```

---

## 🔴 PERMISSIONS & ROLES

```python
# Custom permissions
permission_query_conditions = {
    "Customer": "your_app_name.permissions.get_customer_conditions",
}

has_permission = {
    "Customer": "your_app_name.permissions.customer_has_permission",
}

# Auto-create roles on install
default_roles = [
    {"role": "Customer Admin", "desk_access": 1},
    {"role": "Sales Admin", "desk_access": 1}
]
```

---

## 🔴 WEB PAGES & ROUTES

```python
# Website routes
website_route_rules = [
    {"from_route": "/products/<path:name>", "to_route": "product_page"},
    {"from_route": "/api/method/<path:name>", "to_route": "api_handler"}
]

# Portal menu items
portal_menu_items = [
    {"title": "Projects", "route": "/projects", "role": "Customer"},
    {"title": "Orders", "route": "/orders", "role": "Customer"}
]

# Website context
website_context = {
    "favicon": "/assets/your_app_name/images/favicon.ico",
    "splash_image": "/assets/your_app_name/images/splash.png"
}
```

---

## 🔴 JINJA CUSTOMIZATION

```python
# Add custom Jinja filters
jinja = {
    "methods": [
        "your_app_name.utils.format_currency",
        "your_app_name.utils.get_user_language"
    ],
    "filters": [
        "your_app_name.utils.money_format",
        "your_app_name.utils.date_format"
    ]
}
```

---

## 🔴 INSTALLATION HOOKS

```python
# Run after app installation
after_install = "your_app_name.setup.after_install"

# Run before app uninstall
before_uninstall = "your_app_name.setup.before_uninstall"

# Run after migrations
after_migrate = "your_app_name.setup.after_migrate"

# Run on session creation
on_session_creation = "your_app_name.auth.on_session_creation"

# Run on logout
on_logout = "your_app_name.auth.on_logout"
```

### Installation Handler Pattern:
```python
# your_app_name/setup.py
import frappe

def after_install():
    """Called after app is installed"""
    # Create default settings
    if not frappe.db.exists("Your App Settings", "Your App Settings"):
        frappe.get_doc({
            "doctype": "Your App Settings",
            "enable_feature_x": 1,
            "default_warehouse": "Stores - ABC"
        }).insert()
    
    # Add custom fields
    create_custom_fields()
    
    # Set up default data
    setup_default_data()
    
    frappe.db.commit()
```

---

## 🔴 BACKGROUND JOBS CONFIGURATION

```python
# Default background job queues
default_jobs = {
    "your_app_name.tasks.process_emails": "short",
    "your_app_name.tasks.generate_report": "long"
}

# Redis queue configuration
redis_queue = "redis://localhost:11311"
redis_cache = "redis://localhost:13311"
```

---

## 🚨 COMMON MISTAKES TO AVOID

### ❌ WRONG: Missing app_name
```python
# Will cause import errors!
app_title = "My App"  # Where's app_name?
```

### ❌ WRONG: Incorrect doc_events structure
```python
doc_events = {
    "Customer": "module.function"  # Must be a dict!
}
```

### ❌ WRONG: Wrong scheduler format
```python
scheduler_events = {
    "daily": "module.function"  # Must be a list!
}
```

### ✅ CORRECT: Complete minimal hooks.py
```python
app_name = "your_app"
app_title = "Your App"
app_publisher = "Your Company"
app_description = "App description"
app_icon = "fa fa-cube"
app_color = "blue"

# Even if empty, include these
doc_events = {}
scheduler_events = {}
fixtures = []
```

---

## 📋 HOOKS.PY CHECKLIST

Before deploying, verify:

- [ ] app_name matches folder name exactly
- [ ] All doc_events use dict structure
- [ ] All scheduler_events use list structure
- [ ] All module paths are correct
- [ ] No syntax errors (run `python -m py_compile hooks.py`)
- [ ] All referenced modules exist
- [ ] All referenced functions exist
- [ ] fixtures list is valid
- [ ] No sensitive data in fixtures

---

## 🎯 TESTING YOUR HOOKS

```python
# Test in bench console
bench console

# In console:
import your_app_name.hooks
print(your_app_name.hooks.app_name)
print(your_app_name.hooks.doc_events)
print(your_app_name.hooks.scheduler_events)

# Test specific hook
from your_app_name.overrides.customer import validate
# Create test doc and call validate
```

---

## 🚀 QUICK START TEMPLATE

Copy this complete hooks.py template:

```python
# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from frappe import _

app_name = "your_app_name"
app_title = "Your App Title"
app_publisher = "Your Company"
app_description = "Your app description"
app_icon = "fa fa-cube"
app_color = "#3498db"
app_email = "info@example.com"
app_license = "MIT"
app_version = "1.0.0"

# Include files
app_include_css = "/assets/your_app_name/css/your_app.css"
app_include_js = "/assets/your_app_name/js/your_app.js"

# DocType JS
doctype_js = {}

# Doc Events
doc_events = {}

# Scheduled Tasks
scheduler_events = {
    "hourly": [],
    "daily": [],
    "weekly": [],
    "monthly": []
}

# Fixtures
fixtures = []

# Installation
after_install = "your_app_name.install.after_install"
```

---

**REMEMBER**: Without a proper hooks.py, your app is just a collection of files that Frappe cannot see or use!