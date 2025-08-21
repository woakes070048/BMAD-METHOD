# Frappe Complete Page Patterns - Single Source of Truth

**CRITICAL**: This is THE definitive guide for creating Frappe pages. ALL agents MUST follow these patterns exactly.

## 🚨 MOST COMMON ERROR: MISSING PAGE TITLE

**THE #1 MISTAKE**: Agents create pages WITHOUT the mandatory "title" field!

### ❌ WRONG - What agents do now (MISSING TITLE):
```json
{
  "name": "my-page",
  "module": "My Module",
  "roles": [{"role": "System Manager"}]
}
```

### ✅ CORRECT - What MUST be done (WITH TITLE):
```json
{
  "title": "My Page Title",         // THIS IS MANDATORY!
  "page_title": "My Page Title",    // ALSO RECOMMENDED!
  "name": "my-page",
  "module": "My Module",
  "icon": "fa fa-dashboard",        // ALSO MANDATORY!
  "roles": [{"role": "System Manager"}],
  "standard": "Yes"
}
```

## ⚠️ MANDATORY PAGE REQUIREMENTS - NEVER SKIP ANY

### The 5 Essential Files for Every Page

1. **Page JSON Definition** - `{module}/page/{page_name}/{page_name}.json`
2. **Page JavaScript** - `{module}/page/{page_name}/{page_name}.js`
3. **Vue Bundle Entry** - `public/js/{feature}.bundle.js` (for Vue pages)
4. **Vue Component** - `public/js/{feature}/{Feature}.vue` (for Vue pages)
5. **Python Handler** (optional) - `{module}/page/{page_name}/{page_name}.py`

## 📋 COMPLETE Page JSON Structure (ALL FIELDS)

```json
{
  "content": null,
  "creation": "2024-01-01 00:00:00.000000",
  "docstatus": 0,
  "doctype": "Page",
  "icon": "fa fa-dashboard",
  "idx": 0,
  "modified": "2024-01-01 00:00:00.000000",
  "modified_by": "Administrator",
  "module": "Module Name",
  "name": "page-name",
  "owner": "Administrator",
  "page_name": "page-name",
  "restrict_to_domain": null,
  "roles": [
    {
      "role": "System Manager"
    },
    {
      "role": "Sales User"
    }
  ],
  "script": null,
  "standard": "Yes",
  "style": null,
  "system_page": "No",
  "title": "Page Title Here"
}
```

### ⚠️ CRITICAL FIELDS OFTEN MISSED:
- **`"title"`** - MANDATORY - Display title for the page
- **`"icon"`** - MANDATORY - Icon for navigation menu
- **`"roles"`** - MANDATORY - Who can access this page
- **`"module"`** - MANDATORY - Which module owns this page
- **`"standard"`** - Set to "Yes" for app pages

## 🎯 COMPLETE Page JavaScript Pattern

### 🚨 MUST SET TITLE IN THREE PLACES:

```javascript
// {module}/page/{page_name}/{page_name}.js

frappe.pages['page-name'].on_page_load = function(wrapper) {
    var page = frappe.ui.make_app_page({
        parent: wrapper,
        title: 'Page Title',  // 1️⃣ MANDATORY - Initial title
        single_column: true
    });

    // 2️⃣ MANDATORY - Set page title (appears in header)
    page.set_title(__('Page Title'));
    
    // 3️⃣ MANDATORY - Set browser tab title
    document.title = __('Page Title') + ' | ' + frappe.boot.sitename;
    
    // MANDATORY - Set page icon
    page.set_icon('fa fa-dashboard');
    
    // OPTIONAL - Add breadcrumbs
    frappe.breadcrumbs.add("Module Name");
    
    // Add primary action button
    page.set_primary_action(__('Save'), () => {
        // Action handler
    }, 'fa fa-save');
    
    // Add secondary action
    page.set_secondary_action(__('Refresh'), () => {
        frappe.ui.pages['page-name'].refresh();
    }, 'fa fa-refresh');
    
    // Add menu items
    page.add_menu_item(__('Export'), () => {
        // Export handler
    });
    
    page.add_menu_item(__('Print'), () => {
        window.print();
    });
    
    // For Vue pages - load bundle
    frappe.require('feature.bundle.js').then(() => {
        new frappe.ui.FeatureName(page);
    });
    
    // For non-Vue pages - create content
    $(frappe.render_template('page_template', {})).appendTo(page.body);
};

frappe.pages['page-name'].refresh = function(wrapper) {
    // Refresh logic
};
```

## 🚀 Vue Page Bundle Pattern (COMPLETE)

### 🚨 CRITICAL: Vue Pages MUST Set Titles Too!

**COMMON MISTAKE**: Vue developers forget to set page titles because they focus on the component.
**SOLUTION**: ALWAYS call `setup_page()` BEFORE mounting Vue to set titles properly!

```javascript
// public/js/{feature}.bundle.js

import { createApp } from "vue";
import FeatureComponent from "./{feature}/Feature.vue";
import { createPinia } from "pinia";

class FeatureName {
    constructor(page) {
        this.page = page;
        this.$wrapper = $(page.body);
        
        // 🚨 MANDATORY - Setup page FIRST (sets titles)
        this.setup_page();
        
        // THEN mount Vue app
        this.mount_component();
    }
    
    setup_page() {
        // 🚨 MANDATORY - Set title in THREE places
        // 1. Page title (appears in header)
        this.page.set_title(__("Feature Title"));
        
        // 2. Document title (browser tab)
        document.title = __("Feature Title") + " | " + frappe.boot.sitename;
        
        // 3. Set indicator if needed
        this.page.set_indicator(__('Active'), 'green');
        
        // MANDATORY - Clear existing content
        this.$wrapper.empty();
        
        // Add container for Vue app
        this.$wrapper.html('<div id="vue-app"></div>');
        
        // Setup page actions
        this.page.set_primary_action(__("Save"), () => {
            if (this.$component && this.$component.save) {
                this.$component.save();
            }
        });
        
        this.page.set_secondary_action(__("Refresh"), () => {
            if (this.$component && this.$component.refresh) {
                this.$component.refresh();
            }
        });
        
        // Add menu items
        this.page.add_menu_item(__("Export Data"), () => {
            if (this.$component && this.$component.exportData) {
                this.$component.exportData();
            }
        });
        
        this.page.add_menu_item(__("Import Data"), () => {
            if (this.$component && this.$component.importData) {
                this.$component.importData();
            }
        });
        
        this.page.add_menu_item(__("Settings"), () => {
            if (this.$component && this.$component.showSettings) {
                this.$component.showSettings();
            }
        }, true); // true = add separator before
    }
    
    mount_component() {
        const app = createApp(FeatureComponent, {
            page: this.page
        });
        
        // MANDATORY for Frappe integration
        if (typeof SetVueGlobals !== 'undefined') {
            SetVueGlobals(app);
        }
        
        // Setup Pinia store
        const pinia = createPinia();
        app.use(pinia);
        
        // Mount to container
        this.$component = app.mount('#vue-app');
        
        // Store reference for cleanup
        this.app = app;
    }
    
    // Cleanup on page unload
    destroy() {
        if (this.app) {
            this.app.unmount();
        }
    }
}

// MANDATORY - Register with Frappe
frappe.provide("frappe.ui");
frappe.ui.FeatureName = FeatureName;

export default FeatureName;
```

## 📝 Vue Component Pattern for Pages

```vue
<!-- public/js/{feature}/Feature.vue -->
<template>
  <div class="frappe-card">
    <!-- Page Header -->
    <div class="page-header-actions-container">
      <h2>{{ pageTitle }}</h2>
      <div class="page-actions">
        <button 
          class="btn btn-primary btn-sm"
          @click="handleSave"
        >
          {{ __('Save') }}
        </button>
      </div>
    </div>
    
    <!-- Page Content -->
    <div class="page-content">
      <!-- Your content here -->
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { usePageStore } from './store'

// Props from bundle
const props = defineProps({
  page: Object
})

// Store
const store = usePageStore()

// Page title - MANDATORY
const pageTitle = computed(() => __('Feature Title'))

// MANDATORY - Set page title on mount
onMounted(() => {
  if (props.page) {
    props.page.set_title(pageTitle.value)
  }
})

// Expose methods for page actions
defineExpose({
  save: handleSave,
  refresh: handleRefresh,
  exportData: handleExport,
  importData: handleImport,
  showSettings: handleSettings
})

function handleSave() {
  // Save logic
}

function handleRefresh() {
  // Refresh logic
}

function handleExport() {
  // Export logic
}

function handleImport() {
  // Import logic
}

function handleSettings() {
  // Settings logic
}
</script>
```

## 🛠️ Python Backend for Pages (When Needed)

```python
# {module}/page/{page_name}/{page_name}.py

import frappe
from frappe import _

@frappe.whitelist()
def get_page_data():
    """Get data for page initialization"""
    # MANDATORY - Permission check
    if not frappe.has_permission("DocType", "read"):
        frappe.throw(_("Insufficient permissions"))
    
    return {
        "title": _("Page Title"),  # MANDATORY - Include title
        "data": get_data(),
        "settings": get_settings(),
        "permissions": get_user_permissions()
    }

@frappe.whitelist()
def save_page_data(data):
    """Save page data"""
    # MANDATORY - Validate and parse
    data = frappe.parse_json(data)
    
    # MANDATORY - Permission check
    if not frappe.has_permission("DocType", "write"):
        frappe.throw(_("Insufficient permissions"))
    
    try:
        # Process data
        result = process_save(data)
        
        return {
            "success": True,
            "message": _("Data saved successfully"),
            "data": result
        }
    except Exception as e:
        frappe.log_error(message=str(e), title="Page Save Error")
        frappe.throw(_("Failed to save data"))
```

## 📂 Complete File Structure

```
app_name/
├── {module_name}/
│   └── page/
│       └── {page_name}/
│           ├── {page_name}.json     # MANDATORY - Page definition
│           ├── {page_name}.js       # MANDATORY - Page initialization
│           └── {page_name}.py       # OPTIONAL - Backend handlers
├── public/
│   └── js/
│       ├── {feature}.bundle.js      # MANDATORY for Vue - Entry point
│       └── {feature}/
│           ├── Feature.vue          # MANDATORY for Vue - Main component
│           ├── store.js             # OPTIONAL - Pinia store
│           └── components/          # OPTIONAL - Sub-components
│               ├── ListView.vue
│               └── DetailView.vue
```

## ⚠️ COMMON MISTAKES TO AVOID

### ❌ Missing Title (MOST COMMON)
```javascript
// WRONG - No title set
frappe.pages['page-name'].on_page_load = function(wrapper) {
    var page = frappe.ui.make_app_page({
        parent: wrapper
    });
    // Missing: page.set_title()
}

// CORRECT - Title properly set
frappe.pages['page-name'].on_page_load = function(wrapper) {
    var page = frappe.ui.make_app_page({
        parent: wrapper,
        title: 'Page Title'  // Set here
    });
    page.set_title(__('Page Title'));  // AND here
}
```

### ❌ Missing Roles in JSON
```json
// WRONG - No roles defined
{
  "doctype": "Page",
  "name": "page-name"
  // Missing roles array
}

// CORRECT - Roles properly defined
{
  "doctype": "Page",
  "name": "page-name",
  "roles": [
    {"role": "System Manager"},
    {"role": "All"}
  ]
}
```

### ❌ Not Using Frappe Patterns
```javascript
// WRONG - Custom routing
import { createRouter } from 'vue-router'  // NO!

// CORRECT - Use Frappe pages
frappe.set_route('page-name')  // YES!
```

## ✅ VALIDATION CHECKLIST

Before completing ANY page creation:

- [ ] **JSON file has ALL fields** including `"title"`, `"icon"`, `"roles"`
- [ ] **JS file calls** `page.set_title(__("Title"))` 
- [ ] **Bundle properly registered** with `frappe.ui.FeatureName`
- [ ] **Vue component exposes methods** for page actions
- [ ] **Permissions checked** in backend handlers
- [ ] **Error handling** with `frappe.throw()` and `frappe.log_error()`
- [ ] **Page appears in menu** (check hooks.py or workspace)
- [ ] **Breadcrumbs added** for navigation context
- [ ] **Mobile responsive** (test on small screens)
- [ ] **Loading states** implemented for async operations

## 🎯 Testing Your Page

```bash
# After creating page files
bench --site {site} migrate
bench --site {site} clear-cache
bench build --app {app_name}

# Navigate to page
# URL: /app/page-name
```

## 📚 Additional Resources

- **Page Types**: Standard pages, single-column pages, dashboard pages
- **Page Actions**: Primary, secondary, menu items, custom buttons
- **Page Events**: on_page_load, on_page_show, refresh
- **Page Permissions**: Role-based, user permissions, domain restrictions
- **Page Performance**: Lazy loading, virtual scrolling, pagination

## 🔍 Debugging Tips

1. **Page not loading?** Check browser console for errors
2. **Title not showing?** Verify `page.set_title()` is called
3. **Vue not mounting?** Check `frappe.require()` path
4. **Permissions error?** Verify roles in JSON and user permissions
5. **Build errors?** Run `bench build --force`

---

**REMEMBER**: ALWAYS include ALL mandatory fields and NEVER skip page.set_title()!