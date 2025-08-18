# ERPNext App Structure Standards
## Comprehensive Guide for Proper ERPNext Application Organization

**Last Updated**: 2025-08-17  
**Framework Version**: Frappe Framework 15+ | ERPNext 16  
**Purpose**: Define mandatory structure standards for ERPNext applications and identify deviations for cleanup

---

## 🏗️ MANDATORY ERPNEXT APP STRUCTURE

### Standard Directory Layout (ERPNext v16 - Native Vue)
```
[app_name]/                           # Root app directory (bench new-app creates this)
├── [app_name]/                       # Main app package
│   ├── __init__.py                   # Package initialization
│   ├── hooks.py                      # App hooks and configuration
│   ├── modules.txt                   # List of modules in app
│   ├── patches.txt                   # Database patches
│   ├── config/                       # App configuration
│   │   ├── __init__.py
│   │   ├── desktop.py               # Desktop icons/shortcuts
│   │   └── docs.py                  # Documentation configuration
│   ├── public/                       # Static assets (NATIVE Vue integration)
│   │   ├── css/                     # Stylesheets
│   │   ├── js/                      # JavaScript and Vue components
│   │   │   ├── dashboard.bundle.js          # Feature entry points
│   │   │   ├── customer_portal.bundle.js    # Another feature
│   │   │   ├── shared/                      # Shared utilities
│   │   │   │   ├── api.js                  # API helpers
│   │   │   │   ├── utils.js                # Common utilities
│   │   │   │   └── constants.js            # App constants
│   │   │   ├── dashboard/                   # Feature Vue components
│   │   │   │   ├── Dashboard.vue           # Main component
│   │   │   │   ├── components/             # Sub-components
│   │   │   │   │   ├── MetricCard.vue
│   │   │   │   │   └── ChartWidget.vue
│   │   │   │   ├── stores/                 # Pinia stores
│   │   │   │   │   └── dashboard.js
│   │   │   │   └── utils/                  # Feature utilities
│   │   │   └── customer_portal/            # Another feature
│   │   │       ├── CustomerPortal.vue
│   │   │       └── components/
│   │   └── icons/                   # App icons
│   ├── templates/                    # Jinja2 templates
│   │   ├── __init__.py
│   │   ├── includes/                # Reusable template parts
│   │   └── pages/                   # Page templates
│   ├── www/                         # Web pages
│   │   ├── __init__.py
│   │   └── [page_name].py           # Web page controllers
│   └── [module_name]/               # Business module
│       ├── __init__.py
│       ├── doctype/                 # DocType definitions
│       │   ├── __init__.py
│       │   └── [doctype_name]/      # Individual DocType
│       │       ├── [doctype_name].json
│       │       ├── [doctype_name].py
│       │       ├── [doctype_name].js
│       │       ├── test_[doctype_name].py
│       │       └── [doctype_name]_list.js
│       ├── page/                    # Custom pages
│       │   ├── __init__.py
│       │   └── [page_name]/
│       │       ├── [page_name].json
│       │       ├── [page_name].py
│       │       └── [page_name].js
│       ├── report/                  # Custom reports
│       │   ├── __init__.py
│       │   └── [report_name]/
│       │       ├── [report_name].json
│       │       ├── [report_name].py
│       │       └── [report_name].js
│       ├── web_form/               # Web forms
│       │   ├── __init__.py
│       │   └── [form_name]/
│       │       ├── [form_name].json
│       │       └── [form_name].py
│       ├── workspace/              # Workspace definitions
│       │   ├── __init__.py
│       │   └── [workspace_name].json
│       ├── dashboard_chart/        # Dashboard charts
│       │   ├── __init__.py
│       │   └── [chart_name].json
│       ├── number_card/           # Number cards
│       │   ├── __init__.py
│       │   └── [card_name].json
│       └── dashboard_chart_source/ # Chart data sources
│           ├── __init__.py
│           └── [source_name].json
├── requirements.txt                 # Python dependencies
├── setup.py                        # App installation script
├── README.md                       # App documentation
├── LICENSE                         # License file
└── .gitignore                      # Git ignore rules
```

---

## 🚫 ANTI-PATTERNS TO AVOID

### ❌ WRONG STRUCTURES (AI-GENERATED)

#### Frontend Directory (v16 Native Vue)
```
# WRONG - Don't create separate frontend
[app_name]/
├── frontend/                        # ❌ REMOVE
│   ├── src/
│   ├── public/
│   ├── package.json                # ❌ REMOVE
│   ├── vite.config.js              # ❌ REMOVE
│   └── webpack.config.js           # ❌ REMOVE
```

#### Mixed Structure Patterns
```
# WRONG - Non-standard organization
[app_name]/
├── src/                             # ❌ Use [app_name]/ instead
├── lib/                             # ❌ Use utils/ in modules
├── components/                      # ❌ Use doctype/ structure
├── services/                        # ❌ Use module organization
├── controllers/                     # ❌ Use DocType controllers
├── models/                          # ❌ Use DocType definitions
├── views/                           # ❌ Use page/ structure
├── utils/                           # ❌ Use module-specific utils
└── helpers/                         # ❌ Use module organization
```

#### Backend API Structure
```
# WRONG - Separate API structure
[app_name]/
├── api/                             # ❌ WRONG LOCATION
│   ├── v1/                         # ❌ Versioning not needed
│   ├── v2/                         # ❌ Versioning not needed
│   ├── endpoints/                   # ❌ Use @frappe.whitelist
│   ├── handlers/                    # ❌ Use DocType methods
│   └── middleware/                  # ❌ Use Frappe hooks
```

---

## ✅ CORRECT PATTERNS

### File Naming Conventions

#### Python Files
```python
# Correct naming patterns
customer.py                          # DocType controller
customer_dashboard.py               # Related functionality
test_customer.py                    # Test files
customer_list.js                    # List view customizations
customer_form.js                    # Form customizations
```

#### Vue Files (Native Integration)
```javascript
// Correct Vue structure for ERPNext v16
[app_name]/public/js/
├── customer_dashboard.bundle.js    # Entry point
└── customer_dashboard/             # Component directory
    ├── CustomerDashboard.vue       # Main component
    ├── components/                 # Sub-components
    │   ├── CustomerList.vue
    │   └── CustomerForm.vue
    ├── store.js                    # Pinia store
    └── utils.js                    # Utilities
```

#### JSON Configuration Files
```json
// DocType JSON (standard format)
{
    "actions": [],
    "allow_copy": 0,
    "allow_events_in_timeline": 0,
    "allow_guest_to_view": 0,
    "allow_import": 1,
    "allow_rename": 1,
    "autoname": "naming_series:",
    "beta": 0,
    "creation": "2024-01-15 10:30:00.000000",
    "doctype": "DocType",
    "editable_grid": 1,
    "engine": "InnoDB",
    "field_order": [...],
    "fields": [...],
    "idx": 0,
    "is_submittable": 0,
    "is_tree": 0,
    "issingle": 0,
    "istable": 0,
    "max_attachments": 0,
    "modified": "2024-01-15 10:30:00.000000",
    "modified_by": "Administrator",
    "module": "Module Name",
    "name": "DocType Name",
    "naming_rule": "By \"Naming Series\" field",
    "owner": "Administrator",
    "permissions": [...],
    "quick_entry": 1,
    "read_only": 0,
    "show_name_in_global_search": 0,
    "sort_field": "modified",
    "sort_order": "DESC",
    "states": [],
    "track_changes": 1,
    "track_seen": 1,
    "track_views": 0
}
```

### Module Organization

#### Business Module Structure
```python
# Example: Sales module
sales/
├── __init__.py
├── doctype/
│   ├── customer/                   # Core entity
│   │   ├── customer.json
│   │   ├── customer.py
│   │   ├── customer.js
│   │   └── test_customer.py
│   ├── sales_order/               # Transaction
│   │   ├── sales_order.json
│   │   ├── sales_order.py
│   │   ├── sales_order.js
│   │   └── test_sales_order.py
│   └── sales_order_item/          # Child table
│       ├── sales_order_item.json
│       └── sales_order_item.py
├── page/                          # Custom pages
│   └── sales_analytics/
│       ├── sales_analytics.json
│       ├── sales_analytics.py
│       └── sales_analytics.js
├── report/                        # Reports
│   ├── sales_register/
│   │   ├── sales_register.json
│   │   ├── sales_register.py
│   │   └── sales_register.js
│   └── customer_ledger/
│       ├── customer_ledger.json
│       └── customer_ledger.py
├── workspace/                     # Workspace
│   └── sales.json
└── dashboard_chart/              # Charts
    ├── sales_trend.json
    └── top_customers.json
```

---

## 📁 FILE ORGANIZATION BEST PRACTICES

### DocType File Structure

#### Complete DocType Implementation
```python
# customer/customer.py - DocType controller
import frappe
from frappe.model.document import Document
from frappe import _

class Customer(Document):
    def autoname(self):
        """Set document name"""
        pass
    
    def validate(self):
        """Validation before save"""
        self.validate_customer_name()
        self.set_defaults()
    
    def before_save(self):
        """Logic before saving"""
        pass
    
    def after_insert(self):
        """Logic after document creation"""
        pass
    
    def on_update(self):
        """Logic after document update"""
        pass
    
    def on_submit(self):
        """Logic when document is submitted"""
        pass
    
    def on_cancel(self):
        """Logic when document is cancelled"""
        pass
    
    def validate_customer_name(self):
        """Validate customer name"""
        if not self.customer_name:
            frappe.throw(_("Customer Name is required"))

# API methods
@frappe.whitelist()
def get_customer_balance(customer):
    """Get customer outstanding balance"""
    # Implementation here
    pass
```

#### Client-side JavaScript
```javascript
// customer/customer.js - Form scripts
frappe.ui.form.on('Customer', {
    refresh: function(frm) {
        // Form refresh logic
        frm.add_custom_button(__('View Ledger'), function() {
            frappe.route_options = {
                "customer": frm.doc.name
            };
            frappe.set_route("query-report", "Customer Ledger");
        });
    },
    
    customer_name: function(frm) {
        // Field change logic
        if (frm.doc.customer_name) {
            frm.set_value('customer_code', 
                frm.doc.customer_name.substring(0, 3).toUpperCase());
        }
    },
    
    validate: function(frm) {
        // Client-side validation
        if (!frm.doc.territory) {
            frappe.msgprint(__('Please select a territory'));
            frappe.validated = false;
        }
    }
});

// List view customizations
frappe.listview_settings['Customer'] = {
    add_fields: ['customer_group', 'territory', 'outstanding_amount'],
    
    get_indicator: function(doc) {
        if (doc.outstanding_amount > 0) {
            return [__("Outstanding"), "orange", "outstanding_amount,>,0"];
        } else {
            return [__("Paid"), "green", "outstanding_amount,=,0"];
        }
    },
    
    onload: function(listview) {
        // Custom list view logic
    }
};
```

### Page Structure

#### Custom Page Implementation
```python
# page/sales_analytics/sales_analytics.py
import frappe

@frappe.whitelist()
def get_sales_data(filters=None):
    """Get sales analytics data"""
    
    filters = filters or {}
    
    data = frappe.db.sql("""
        SELECT 
            DATE(creation) as date,
            SUM(base_grand_total) as total_sales,
            COUNT(*) as order_count
        FROM `tabSales Order`
        WHERE docstatus = 1
        GROUP BY DATE(creation)
        ORDER BY date DESC
        LIMIT 30
    """, as_dict=True)
    
    return data
```

```javascript
// page/sales_analytics/sales_analytics.js
frappe.pages['sales-analytics'].on_page_load = function(wrapper) {
    var page = frappe.ui.make_app_page({
        parent: wrapper,
        title: 'Sales Analytics',
        single_column: true
    });
    
    // Add page content
    page.main.html(`
        <div class="analytics-container">
            <div class="filters"></div>
            <div class="charts"></div>
            <div class="summary"></div>
        </div>
    `);
    
    // Initialize analytics
    new SalesAnalytics(page);
};

class SalesAnalytics {
    constructor(page) {
        this.page = page;
        this.setup_filters();
        this.load_data();
    }
    
    setup_filters() {
        // Setup filter controls
    }
    
    load_data() {
        frappe.call({
            method: 'myapp.sales.page.sales_analytics.sales_analytics.get_sales_data',
            callback: (r) => {
                this.render_charts(r.message);
            }
        });
    }
    
    render_charts(data) {
        // Render chart using Frappe Charts
    }
}
```

---

## 🎯 STRUCTURE VALIDATION

### Automated Structure Checker

```python
import os
import json
import sys
from pathlib import Path

class ERPNextStructureValidator:
    def __init__(self, app_path):
        self.app_path = Path(app_path)
        self.app_name = self.app_path.name
        self.violations = []
        self.warnings = []
        
    def validate_structure(self):
        """Validate app structure against ERPNext standards"""
        
        # Check root level files
        self.check_root_files()
        
        # Check main app directory
        self.check_app_directory()
        
        # Check module structure
        self.check_module_structure()
        
        # Check file naming conventions
        self.check_naming_conventions()
        
        # Check for anti-patterns
        self.check_anti_patterns()
        
        return {
            'violations': self.violations,
            'warnings': self.warnings,
            'compliance_score': self.calculate_score()
        }
    
    def check_root_files(self):
        """Check for required root level files"""
        
        required_files = ['setup.py', 'requirements.txt']
        optional_files = ['README.md', 'LICENSE', '.gitignore']
        
        for file in required_files:
            if not (self.app_path / file).exists():
                self.violations.append(f"Missing required file: {file}")
        
        for file in optional_files:
            if not (self.app_path / file).exists():
                self.warnings.append(f"Missing recommended file: {file}")
    
    def check_app_directory(self):
        """Check main app directory structure"""
        
        app_dir = self.app_path / self.app_name
        if not app_dir.exists():
            self.violations.append(f"Missing main app directory: {self.app_name}/")
            return
        
        required_files = ['__init__.py', 'hooks.py', 'modules.txt']
        for file in required_files:
            if not (app_dir / file).exists():
                self.violations.append(f"Missing required app file: {self.app_name}/{file}")
        
        # Check standard directories
        standard_dirs = ['public', 'templates', 'www']
        for dir_name in standard_dirs:
            dir_path = app_dir / dir_name
            if dir_path.exists() and not (dir_path / '__init__.py').exists():
                self.warnings.append(f"Missing __init__.py in {self.app_name}/{dir_name}/")
    
    def check_module_structure(self):
        """Check module directory structure"""
        
        app_dir = self.app_path / self.app_name
        
        # Read modules.txt to get module list
        modules_file = app_dir / 'modules.txt'
        if modules_file.exists():
            with open(modules_file, 'r') as f:
                modules = [line.strip() for line in f if line.strip()]
            
            for module in modules:
                module_dir = app_dir / module
                if module_dir.exists():
                    self.validate_module_directory(module_dir, module)
    
    def validate_module_directory(self, module_dir, module_name):
        """Validate individual module structure"""
        
        # Check for __init__.py
        if not (module_dir / '__init__.py').exists():
            self.violations.append(f"Missing __init__.py in module: {module_name}")
        
        # Check standard subdirectories
        standard_subdirs = ['doctype', 'page', 'report', 'workspace']
        for subdir in standard_subdirs:
            subdir_path = module_dir / subdir
            if subdir_path.exists():
                if not (subdir_path / '__init__.py').exists():
                    self.violations.append(f"Missing __init__.py in {module_name}/{subdir}/")
                
                # Validate DocType structure
                if subdir == 'doctype':
                    self.validate_doctype_structure(subdir_path, module_name)
    
    def validate_doctype_structure(self, doctype_dir, module_name):
        """Validate DocType directory structure"""
        
        for doctype_path in doctype_dir.iterdir():
            if doctype_path.is_dir():
                doctype_name = doctype_path.name
                
                # Check required files
                json_file = doctype_path / f"{doctype_name}.json"
                py_file = doctype_path / f"{doctype_name}.py"
                
                if not json_file.exists():
                    self.violations.append(f"Missing JSON file for DocType: {doctype_name}")
                
                if not py_file.exists():
                    self.violations.append(f"Missing Python file for DocType: {doctype_name}")
                
                # Validate JSON structure
                if json_file.exists():
                    self.validate_doctype_json(json_file, doctype_name)
    
    def validate_doctype_json(self, json_file, doctype_name):
        """Validate DocType JSON structure"""
        
        try:
            with open(json_file, 'r') as f:
                data = json.load(f)
            
            required_fields = ['doctype', 'name', 'module', 'fields']
            for field in required_fields:
                if field not in data:
                    self.violations.append(f"Missing required field '{field}' in {doctype_name}.json")
            
            # Validate doctype matches filename
            if data.get('name') != doctype_name:
                self.violations.append(f"DocType name mismatch in {doctype_name}.json")
                
        except json.JSONDecodeError:
            self.violations.append(f"Invalid JSON in {doctype_name}.json")
        except Exception as e:
            self.warnings.append(f"Could not validate {doctype_name}.json: {e}")
    
    def check_naming_conventions(self):
        """Check file and directory naming conventions"""
        
        for root, dirs, files in os.walk(self.app_path):
            # Check directory names
            for dir_name in dirs:
                if not self.is_valid_name(dir_name):
                    self.warnings.append(f"Non-standard directory name: {dir_name}")
            
            # Check file names
            for file_name in files:
                if file_name.endswith('.py') and not self.is_valid_name(file_name[:-3]):
                    self.warnings.append(f"Non-standard file name: {file_name}")
    
    def is_valid_name(self, name):
        """Check if name follows Python/ERPNext conventions"""
        import re
        
        # Allow snake_case and standard names
        pattern = r'^[a-z0-9_]+$'
        return re.match(pattern, name) is not None
    
    def check_anti_patterns(self):
        """Check for anti-patterns that should be avoided"""
        
        anti_patterns = [
            ('frontend', 'Should use public/js/ for Vue components'),
            ('src', 'Should use app_name/ as main directory'),
            ('lib', 'Should organize code in modules'),
            ('components', 'Should use DocType structure'),
            ('services', 'Should use module organization'),
            ('controllers', 'Should use DocType controllers'),
            ('models', 'Should use DocType definitions'),
            ('views', 'Should use page/ structure')
        ]
        
        for root, dirs, files in os.walk(self.app_path):
            for pattern, message in anti_patterns:
                if pattern in dirs:
                    self.violations.append(f"Anti-pattern detected: {pattern}/ - {message}")
    
    def calculate_score(self):
        """Calculate compliance score"""
        
        total_checks = len(self.violations) + len(self.warnings) + 100  # Base score
        violations_weight = len(self.violations) * 10
        warnings_weight = len(self.warnings) * 2
        
        score = max(0, 100 - violations_weight - warnings_weight)
        return score

# Usage
if __name__ == "__main__":
    app_path = sys.argv[1] if len(sys.argv) > 1 else "."
    
    validator = ERPNextStructureValidator(app_path)
    result = validator.validate_structure()
    
    print("=== ERPNEXT STRUCTURE VALIDATION ===")
    print(f"Compliance Score: {result['compliance_score']}%")
    
    if result['violations']:
        print("\n❌ VIOLATIONS (Must Fix):")
        for violation in result['violations']:
            print(f"  - {violation}")
    
    if result['warnings']:
        print("\n⚠️ WARNINGS (Should Fix):")
        for warning in result['warnings']:
            print(f"  - {warning}")
    
    if not result['violations'] and not result['warnings']:
        print("\n✅ Structure is compliant with ERPNext standards!")
```

---

## 📋 STRUCTURE CLEANUP CHECKLIST

### Pre-Cleanup Assessment
- [ ] **Document Current Structure** - Map existing directory layout
- [ ] **Identify Violations** - Run structure validator
- [ ] **Assess Impact** - Understand what needs to move
- [ ] **Create Backup** - Full app backup before changes
- [ ] **Plan Migration** - Step-by-step restructuring plan

### Cleanup Process
- [ ] **Remove Anti-Pattern Directories** - Delete non-standard structures
- [ ] **Reorganize Files** - Move to standard locations
- [ ] **Update Imports** - Fix all import statements
- [ ] **Rename Files** - Apply naming conventions
- [ ] **Create Missing Files** - Add required __init__.py files

### Post-Cleanup Validation
- [ ] **Structure Validation** - Run validator again
- [ ] **Import Testing** - Verify all imports work
- [ ] **Functionality Testing** - Test all features
- [ ] **Documentation Update** - Update any documentation
- [ ] **Team Communication** - Inform team of changes

### Success Criteria
- ✅ **95%+ Compliance Score** with structure validator
- ✅ **Zero Import Errors** after restructuring
- ✅ **All Features Working** as before cleanup
- ✅ **Standard Naming** throughout codebase
- ✅ **No Anti-Patterns** remaining in structure

Remember: **Structure standards ensure maintainability, consistency, and team collaboration efficiency!**