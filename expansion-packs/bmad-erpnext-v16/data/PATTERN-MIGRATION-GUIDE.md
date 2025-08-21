# Pattern Migration Guide

## How to Fix Common Pattern Violations

This guide helps you migrate existing code that violates the critical patterns to compliant implementations.

---

## 🔧 Fixing Missing Page Titles

### Problem: Page doesn't display title
**Symptom**: Page loads but title is blank or shows "undefined"

### Step 1: Check Page JSON
```bash
# Find the page JSON file
find . -name "*.json" -path "*/page/*" | xargs grep -L '"title"'
```

### Step 2: Add Missing Title to JSON
```json
// Before (WRONG)
{
  "name": "my-page",
  "module": "My Module"
}

// After (CORRECT)
{
  "title": "My Page Title",        // ADD THIS
  "page_title": "My Page",         // ADD THIS
  "icon": "fa fa-dashboard",       // ADD THIS
  "name": "my-page",
  "module": "My Module"
}
```

### Step 3: Fix JavaScript
```javascript
// Before (WRONG)
frappe.pages['my-page'].on_page_load = function(wrapper) {
    var page = frappe.ui.make_app_page({
        parent: wrapper
    });
    // Missing title setup!
}

// After (CORRECT)
frappe.pages['my-page'].on_page_load = function(wrapper) {
    var page = frappe.ui.make_app_page({
        parent: wrapper,
        title: 'My Page Title'      // 1. ADD THIS
    });
    
    page.set_title(__('My Page Title'));                                  // 2. ADD THIS
    document.title = __('My Page Title') + ' | ' + frappe.boot.sitename; // 3. ADD THIS
}
```

---

## 🔧 Fixing API Security Issues

### Problem: API missing @frappe.whitelist()
**Symptom**: API returns 404 or "Method not whitelisted" error

### Find Violations
```bash
# Find Python functions that might be APIs without whitelist
grep -r "def.*(" --include="*.py" | grep -v "@frappe.whitelist"
```

### Fix Pattern
```python
# Before (WRONG)
def get_data(customer_id):
    return frappe.get_all("Customer", filters={"name": customer_id})

# After (CORRECT)
@frappe.whitelist()
def get_data(customer_id):
    # Add permission check FIRST
    if not frappe.has_permission("Customer", "read"):
        frappe.throw(_("Insufficient permissions"))
    
    # Validate input
    if not customer_id:
        frappe.throw(_("Customer ID required"))
    
    return frappe.get_all("Customer", filters={"name": customer_id})
```

### Problem: Using 'import requests'
```python
# Before (WRONG)
import requests

def call_external_api(url):
    response = requests.get(url)
    return response.json()

# After (CORRECT)
import frappe

def call_external_api(url):
    response = frappe.make_get_request(url)
    return response
```

---

## 🔧 Fixing Child Table Issues

### Problem: Child tables in workspace
**Symptom**: Clicking workspace link for child table shows error

### Find Violations
```bash
# Find workspace files linking to _ct tables
grep -r '"name".*".*_ct"' --include="*.json" --include="workspace.json"
```

### Fix Workspace
```json
// Before (WRONG)
{
  "links": [
    {
      "type": "doctype",
      "name": "Sales Order Item CT",  // WRONG - Child table
      "label": "Order Items"
    }
  ]
}

// After (CORRECT)
{
  "links": [
    {
      "type": "doctype",
      "name": "Sales Order",  // Link to parent instead
      "label": "Sales Orders"
    }
  ]
}
```

### Problem: Child table missing _ct suffix
```bash
# Rename the DocType folder
mv sales_order_item sales_order_item_ct

# Update the JSON file
sed -i 's/"Sales Order Item"/"Sales Order Item CT"/g' sales_order_item_ct/*.json

# Update Python imports
grep -r "SalesOrderItem" --include="*.py" | xargs sed -i 's/SalesOrderItem/SalesOrderItemCT/g'
```

---

## 🔧 Fixing Structure Violations

### Problem: /frontend/ directory exists
**Symptom**: Separate frontend build not integrated with Frappe

### Migration Steps
```bash
# 1. Move Vue components to public/js/
mkdir -p app_name/public/js/feature
mv frontend/src/components/* app_name/public/js/feature/

# 2. Create bundle entry point
cat > app_name/public/js/feature.bundle.js << 'EOF'
import { createApp } from "vue";
import FeatureComponent from "./feature/FeatureComponent.vue";

class FeatureName {
    constructor(wrapper) {
        let app = createApp(FeatureComponent);
        SetVueGlobals(app);  // CRITICAL!
        this.$component = app.mount(wrapper);
    }
}

frappe.provide("app_name");
app_name.FeatureName = FeatureName;
EOF

# 3. Remove frontend directory
rm -rf frontend/

# 4. Build with Frappe
bench build --app app_name
```

---

## 🔧 Validation Checklist

After migration, verify:

### Page Validation
```javascript
// Test in browser console
frappe.pages['page-name'] && console.log('Page registered');
document.title.includes('Page Title') && console.log('Title set');
```

### API Validation
```python
# Test in bench console
frappe.get_doc("User", "Administrator")
frappe.call("app.api.method_name")  # Should work if whitelisted
```

### Workspace Validation
```bash
# Check for child table links
grep -r "_ct" workspace.json  # Should return nothing
```

---

## 🚀 Automated Migration Script

```python
#!/usr/bin/env python
"""
Pattern Migration Helper
Run from bench directory: bench execute migration_helper.py
"""

import frappe
import os
import json
import re

def fix_page_titles():
    """Add missing titles to page JSON files"""
    pages_path = frappe.get_app_path("app_name", "page")
    
    for page_dir in os.listdir(pages_path):
        json_path = os.path.join(pages_path, page_dir, f"{page_dir}.json")
        if os.path.exists(json_path):
            with open(json_path, 'r') as f:
                data = json.load(f)
            
            # Add missing fields
            if 'title' not in data:
                data['title'] = page_dir.replace('_', ' ').title()
                data['icon'] = 'fa fa-file'
                
                with open(json_path, 'w') as f:
                    json.dump(data, f, indent=2)
                print(f"Fixed: {page_dir}")

def find_missing_whitelists():
    """Find API methods missing @frappe.whitelist()"""
    api_path = frappe.get_app_path("app_name", "api")
    
    for root, dirs, files in os.walk(api_path):
        for file in files:
            if file.endswith('.py'):
                path = os.path.join(root, file)
                with open(path, 'r') as f:
                    content = f.read()
                
                # Find functions without whitelist
                pattern = r'def\s+(\w+)\s*\([^)]*\):'
                functions = re.findall(pattern, content)
                
                for func in functions:
                    if f'@frappe.whitelist' not in content:
                        print(f"Missing whitelist: {file}::{func}")

def check_workspace_compliance():
    """Check workspaces for child table links"""
    workspaces = frappe.get_all("Workspace")
    
    for ws in workspaces:
        doc = frappe.get_doc("Workspace", ws.name)
        if doc.content:
            data = json.loads(doc.content)
            for card in data.get('cards', []):
                for link in card.get('links', []):
                    if link.get('name', '').endswith('_ct'):
                        print(f"Child table in workspace: {ws.name} -> {link['name']}")

# Run migrations
if __name__ == "__main__":
    print("Starting pattern migration check...")
    fix_page_titles()
    find_missing_whitelists()
    check_workspace_compliance()
    print("Migration check complete!")
```

---

## 📋 Common Error Messages and Fixes

| Error Message | Likely Cause | Fix |
|--------------|--------------|-----|
| "Page title is undefined" | Missing title in JSON or JS | Add title in 3 places |
| "Method not whitelisted" | Missing @frappe.whitelist() | Add decorator to function |
| "DocType not found" | Linking to child table | Link to parent DocType |
| "Import error: requests" | Using requests library | Use frappe.make_get_request() |
| "Permission denied" | Missing permission check | Add frappe.has_permission() first |

---

## 🎯 Prevention

To prevent future violations:

1. **Use Templates**: Always start from approved templates
2. **Run Checklists**: Use vue-spa-checklist.md before committing
3. **Code Review**: Have frappe-compliance-validator review all code
4. **Automated Tests**: Add pattern validation to CI/CD

---

*This migration guide helps transition existing code to compliance with critical patterns*
*For questions, consult MANDATORY-SAFETY-PROTOCOLS.md*