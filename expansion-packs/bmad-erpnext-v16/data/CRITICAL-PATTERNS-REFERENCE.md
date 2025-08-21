# 🚨 CRITICAL PATTERNS REFERENCE GUIDE

## Quick Reference for All Agents

This document provides a quick reference for the MANDATORY patterns that ALL agents must follow when working with ERPNext/Frappe applications.

---

## 🔴 MANDATORY: Page Creation Patterns

### Page JSON Requirements
```json
{
  "title": "Page Title Here",        // 🚨 MANDATORY - NEVER SKIP!
  "page_title": "Page Title",        // RECOMMENDED
  "name": "page-name",               // MANDATORY - URL slug
  "module": "Module Name",           // MANDATORY - Module ownership
  "icon": "fa fa-dashboard",         // 🚨 MANDATORY - Navigation icon
  "roles": [{"role": "System Manager"}],
  "standard": "Yes"
}
```

### Page JavaScript Requirements
```javascript
// 🚨 CRITICAL: Title MUST be set in 3 places!
frappe.pages['page-name'].on_page_load = function(wrapper) {
    var page = frappe.ui.make_app_page({
        parent: wrapper,
        title: 'Page Title',                    // 1. SET HERE
        single_column: true
    });
    
    page.set_title(__('Page Title'));          // 2. Page header
    document.title = __('Page Title') + ' | ' + frappe.boot.sitename;  // 3. Browser tab
}
```

**FAILURE TO SET TITLE = PAGE WON'T DISPLAY PROPERLY**

---

## 🔴 MANDATORY: API Security Patterns

### API Endpoint Requirements
```python
# 🚨 EVERY API MUST FOLLOW THIS PATTERN - NO EXCEPTIONS!
import frappe
from frappe import _

@frappe.whitelist()  # 🚨 MANDATORY - NEVER SKIP!
def api_method(param1, param2=None):
    """API endpoint with proper security"""
    
    # 🚨 Permission check MUST BE FIRST!
    if not frappe.has_permission("DocType", "read"):
        frappe.throw(_("Insufficient permissions"))  # Use frappe.throw()
    
    try:
        # Your logic here
        data = frappe.get_all("DocType", filters={...})
        return {"success": True, "data": data}
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "API Error")
        frappe.throw(_("An error occurred"))  # NEVER raise Exception
```

### NEVER DO THIS:
```python
# ❌ WRONG - Missing @frappe.whitelist()
def api_method():
    pass

# ❌ WRONG - Using requests library
import requests  # NEVER DO THIS!
response = requests.get(url)  # WRONG!

# ✅ CORRECT - Use Frappe's methods
response = frappe.make_get_request(url, headers=None)
```

---

## 🔴 MANDATORY: Workspace Configuration

### Workspace JSON Requirements
```json
{
  "title": "Workspace Title",      // 🚨 MUST be at TOP of JSON!
  "module": "Module Name",
  "icon": "fa fa-home",           // Only Frappe icons allowed
  "extends": "",
  "shortcuts": [...],
  "cards": [
    {
      "label": "Documents",
      "links": [
        {
          "type": "doctype",
          "name": "Sales Order",       // ✅ CORRECT - Parent DocType
          "label": "Sales Orders"
        },
        {
          "type": "doctype", 
          "name": "Sales Order Item CT",  // ❌ WRONG - NEVER link child tables!
          "label": "Order Items"
        }
      ]
    }
  ]
}
```

**RULE: NEVER link DocTypes ending with _ct (child tables) in workspaces!**

---

## 🔴 MANDATORY: DocType Naming Rules

### Child Table Naming Convention
```python
# Parent DocType
class SalesOrder(Document):
    pass  # Folder: sales_order

# Child Table - MUST use _ct suffix!
class SalesOrderItemCT(Document):  # ✅ CORRECT - Has _ct suffix
    pass  # Folder: sales_order_item_ct

# ❌ WRONG - Missing _ct suffix
class SalesOrderItem(Document):  # Will cause workspace link failures!
    pass
```

### Child Table JSON
```json
{
  "istable": 1,              // MANDATORY for child tables
  "module": "Sales",
  "name": "Sales Order Item CT",  // Must have CT suffix
  "naming": "random"         // Child tables use random naming
}
```

---

## 🔴 MANDATORY: Project Structure Rules

### NEVER Create /frontend/ Directory
```
❌ WRONG Structure:
app_name/
├── frontend/           # NEVER DO THIS!
│   ├── src/
│   └── package.json    # NO separate frontend build!

✅ CORRECT Structure:
app_name/
├── public/
│   └── js/
│       ├── feature.bundle.js    # Entry point
│       └── feature/
│           ├── Component.vue    # Vue components
│           └── store.js        # Pinia store
```

### Import Pattern Rules
```python
# ❌ WRONG - Triple nesting
from app.module.submodule.file import function

# ✅ CORRECT - Package layer
from app.module import function
```

---

## 🔴 MANDATORY: Vue Integration Pattern

### Bundle Entry Point
```javascript
// feature.bundle.js
import { createApp } from "vue";
import FeatureComponent from "./feature/FeatureComponent.vue";

class FeatureName {
    constructor(wrapper) {
        let app = createApp(FeatureComponent);
        SetVueGlobals(app);  // 🚨 CRITICAL - NEVER SKIP!
        this.$component = app.mount(wrapper);
    }
}

// Register with Frappe
frappe.provide("feature_namespace");
feature_namespace.FeatureName = FeatureName;
```

---

## 🔴 Quality Gate Checklist

Before ANY code is accepted, verify:

### UI Components
- [ ] Page JSON has "title" field
- [ ] Page JSON has "icon" field
- [ ] JavaScript sets title in 3 places
- [ ] Workspace title at TOP of JSON
- [ ] No child table links in workspace

### API Security
- [ ] @frappe.whitelist() on ALL endpoints
- [ ] Permission check FIRST after try
- [ ] frappe.throw() for ALL errors
- [ ] NO 'import requests'

### Structure
- [ ] NO /frontend/ directory
- [ ] Child tables use _ct suffix
- [ ] Package layer imports only
- [ ] Vue uses SetVueGlobals()

---

## 🚨 ENFORCEMENT

These patterns are enforced by:
1. **Requirements Gathering** - business-analyst.md
2. **Story Creation** - erpnext-scrum-master.md
3. **Development** - All technical agents
4. **Validation** - frappe-compliance-validator.md
5. **Documentation** - documentation-specialist.md
6. **Auditing** - app-auditor.md

**VIOLATIONS WILL BE REJECTED AT MULTIPLE STAGES**

---

## 📚 References

- MANDATORY-SAFETY-PROTOCOLS.md - Full safety requirements
- frappe-complete-page-patterns.md - Complete page examples
- api-whitelisting-guide.md - API security details
- doctype-design-patterns.md - DocType best practices

---

*This document is MANDATORY reading for ALL agents working on ERPNext/Frappe applications*
*Last Updated: 2025-08-21*