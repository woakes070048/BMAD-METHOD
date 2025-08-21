# MANDATORY SAFETY PROTOCOLS

## CRITICAL: Page Creation Requirements

### EVERY Page MUST Have These Fields:

```json
{
  "title": "Page Title Here",        // MANDATORY - Display title
  "page_title": "Page Title Here",   // RECOMMENDED - Alternative title
  "name": "page-name",               // MANDATORY - URL slug
  "module": "Module Name",           // MANDATORY - Module ownership
  "icon": "fa fa-dashboard",         // MANDATORY - Navigation icon
  "roles": [                         // MANDATORY - Access control
    {"role": "System Manager"},
    {"role": "Sales User"}
  ],
  "standard": "Yes",                 // For app pages
  "doctype": "Page",
  "idx": 0,
  "docstatus": 0
}
```

### Page JavaScript Requirements:

```javascript
// CORRECT: Set title in ALL required places
frappe.pages['page-name'].on_page_load = function(wrapper) {
    var page = frappe.ui.make_app_page({
        parent: wrapper,
        title: 'Page Title',          // 1. SET HERE
        single_column: true
    });
    
    // 2. ALSO SET HERE (page header)
    page.set_title(__('Page Title'));
    
    // 3. AND HERE (browser tab)
    document.title = __('Page Title') + ' | ' + frappe.boot.sitename;
    
    // 4. Optional but recommended
    page.set_indicator(__('Active'), 'green');
    
    // Add breadcrumbs
    frappe.breadcrumbs.add("Module Name");
}
```

### Vue Page Bundle Requirements:

```javascript
// public/js/feature.bundle.js
class FeatureName {
    constructor(page) {
        this.page = page;
        this.$wrapper = $(page.body);
        
        // MANDATORY: Setup page with titles
        this.setup_page();
        this.mount_component();
    }
    
    setup_page() {
        // SET TITLE IN THREE PLACES:
        this.page.set_title(__("Feature Title"));                              // 1. Page header
        document.title = __("Feature Title") + " | " + frappe.boot.sitename;   // 2. Browser tab
        this.page.set_indicator(__('Active'), 'green');                        // 3. Indicator
        
        // Clear and prepare for Vue
        this.$wrapper.empty();
        this.$wrapper.html('<div id="vue-app"></div>');
        
        // Setup page actions
        this.page.set_primary_action(__("Save"), () => {
            if (this.$component && this.$component.save) {
                this.$component.save();
            }
        });
    }
    
    mount_component() {
        let app = createApp(FeatureComponent);
        SetVueGlobals(app);  // CRITICAL for Frappe integration
        
        const pinia = createPinia();
        app.use(pinia);
        
        this.$component = app.mount(this.$wrapper.find('#vue-app').get(0));
    }
}
```

## Import Pattern Rules

### CORRECT Import Patterns:
```python
# From package layer (app-name/app-name/)
from app_name.api.endpoints import api_function
from app_name.lib.services import ServiceClass
from app_name.utils.helpers import helper_function

# Using Frappe methods for DocTypes
doc = frappe.get_doc("Customer", "CUST-00001")
customers = frappe.get_all("Customer", filters={"status": "Active"})
```

### WRONG Import Patterns (NEVER DO):
```python
# ❌ Triple nesting - WRONG!
from app_name.app_name.api.endpoints import function

# ❌ Direct DocType import - WRONG!
from app_name.app_name.doctype.customer.customer import Customer

# ❌ Import from root - WRONG!
from app_name import something  # if something is at root level
```

## Structure Requirements

### CORRECT App Structure:
```
app-name/                           # Root directory (kebab-case)
├── pyproject.toml                 # Modern Python packaging
├── README.md                       # Documentation
├── requirements.txt                # Python dependencies
└── app-name/                      # Package layer (same name)
    ├── __init__.py
    ├── hooks.py                   # MUST be here!
    ├── modules.txt
    ├── api/                       # API endpoints
    │   ├── __init__.py
    │   └── endpoints.py           # @frappe.whitelist required
    ├── lib/                       # Business logic
    │   ├── __init__.py
    │   └── services/
    ├── utils/                     # Utilities
    │   ├── __init__.py
    │   └── helpers.py
    ├── public/                    # Static assets
    │   ├── js/                   # Vue components here!
    │   ├── css/
    │   └── images/
    └── app-name/                  # Module layer (triple nesting)
        ├── __init__.py
        └── doctype/               # DocTypes here
            ├── sales_order/
            └── sales_order_item_ct/  # Child table with _ct
```

### NEVER CREATE These Directories:
- ❌ `/frontend/` - Use `public/js/` instead
- ❌ `/src/` - Use package layer directories
- ❌ `/backend/` - Use `api/`, `lib/`, `utils/`
- ❌ Root level Python files (except setup.py)

## API Security Requirements

### EVERY API Endpoint MUST Have:
```python
import frappe
from frappe import _

@frappe.whitelist()  # MANDATORY - Never forget this!
def api_function(param1, param2=None):
    """API endpoint documentation"""
    
    # 1. ALWAYS validate permissions first
    if not frappe.has_permission("DocType", "read"):
        frappe.throw(_("Insufficient permissions"), frappe.PermissionError)
    
    # 2. Validate input
    if not param1:
        frappe.throw(_("param1 is required"))
    
    try:
        # 3. Your logic here
        result = process_data(param1, param2)
        
        # 4. Return structured response
        return {
            "success": True,
            "data": result,
            "message": _("Operation successful")
        }
    except Exception as e:
        # 5. Log errors properly
        frappe.log_error(message=str(e), title="API Error")
        frappe.throw(_("An error occurred: {0}").format(str(e)))
```

## DocType and Child Table Naming

### CORRECT Naming Convention:
```python
# Parent DocType
DocType Name: SalesOrder          # PascalCase
Folder: sales_order               # snake_case
Class: class SalesOrder(Document) # PascalCase

# Child Table (MUST end with _ct)
DocType Name: SalesOrderItemCT    # PascalCase with CT
Folder: sales_order_item_ct       # snake_case with _ct
Class: class SalesOrderItemCT(Document)

# In JSON definition
{
  "istable": 1,  # For child tables
  "module": "Sales",
  "name": "Sales Order Item CT"
}
```

### WRONG Naming (NEVER DO):
```python
# ❌ Child table without _ct suffix
sales_order_item  # WRONG - Missing _ct!

# ❌ Wrong case
Sales-Order       # WRONG - Use SalesOrder
SALES_ORDER      # WRONG - Use SalesOrder
```

## Workspace Requirements

### CORRECT Workspace JSON:
```json
{
  "title": "Sales Management",      // MANDATORY field
  "name": "Sales Management",
  "module": "Sales",
  "icon": "fa fa-shopping-cart",   // MANDATORY field
  "category": "Modules",
  "is_standard": 1,
  "extends_another_page": 0,
  "hide_custom": 0,
  "links": [
    {
      "type": "doctype",
      "name": "Sales Order",        // ONLY parent DocTypes
      "link": "List/Sales Order",
      "onboard": 0
    }
    // NEVER add child tables here!
  ]
}
```

## The Three Laws of Development

1. **Never change code without understanding it**
   - Read the entire file first
   - Understand the business logic
   - Check for dependencies

2. **Never fix symptoms without finding root cause**
   - Investigate the actual error
   - Check logs thoroughly
   - Understand why it's happening

3. **Never continue after three failed attempts**
   - Stop and reassess
   - Ask for help
   - Document the blockers

## Universal Workflow Requirement

ALL agents MUST execute `universal-context-detection-workflow` before any work:
- Detect work type (troubleshooting/new development/enhancement/migration)
- Initialize safety protocols
- Start session tracking
- Cannot skip this step

## Quality Gate Checklist

Before ANY code is considered complete:
- [ ] Pages have "title" field in JSON
- [ ] Page JavaScript sets title in 3 places
- [ ] No /frontend/ directory exists
- [ ] All APIs have @frappe.whitelist decorator
- [ ] Child tables use _ct suffix
- [ ] Imports follow package layer pattern
- [ ] Structure follows 3-layer architecture
- [ ] Documentation is updated
- [ ] Tests are passing

## Common Errors and Solutions

### Error: Page has no title
**Solution**: Add "title" field to page JSON and set in JavaScript

### Error: ImportError with triple nesting
**Solution**: Use package layer imports, not module layer

### Error: API not accessible
**Solution**: Add @frappe.whitelist() decorator

### Error: Child table not showing
**Solution**: Ensure it ends with _ct and istable=1

### Error: /frontend/ directory issues
**Solution**: Move everything to public/js/ and use Frappe's build

---

**REMEMBER**: These are MANDATORY protocols. Every agent MUST follow these patterns exactly. No exceptions.