# Native Vue Patterns for ERPNext v16

## Overview
Comprehensive patterns for implementing Vue 3 components natively within ERPNext/Frappe Framework without separate frontend applications.

## Core Concepts

### 1. NO Separate Frontend
- All Vue components live in `public/js/` directory
- Built using Frappe's esbuild pipeline
- No Vite, webpack, or separate build tools
- No `/frontend/` directory
- No separate package.json for frontend

### 2. Bundle Entry Points
Every Vue feature requires a `.bundle.js` entry point:
```javascript
// public/js/feature.bundle.js
import { createApp } from "vue";
import Component from "./feature/Component.vue";

// Class pattern for Frappe integration
class Feature {
  constructor(wrapper) {
    const app = createApp(Component);
    SetVueGlobals(app); // CRITICAL
    app.mount(wrapper);
  }
}
```

### 3. SetVueGlobals
MUST be called for every Vue app to enable:
- Translation function `__()`
- Access to `frappe` object
- Other Frappe utilities

## Implementation Patterns

### Pattern 1: Vue in Frappe Pages

```javascript
// module/page/my_page/my_page.js
frappe.pages['my-page'].on_page_load = function(wrapper) {
  frappe.require('my_page.bundle.js').then(() => {
    new frappe.ui.MyPage(wrapper);
  });
}

// public/js/my_page.bundle.js
import { createApp } from "vue";
import MyPageComponent from "./my_page/MyPage.vue";

class MyPage {
  constructor(wrapper) {
    this.$wrapper = $(wrapper);
    this.page = wrapper.page;
    
    // Setup page
    this.page.set_title(__("My Page"));
    this.page.set_primary_action(__("Save"), () => {
      this.save();
    });
    
    // Mount Vue
    const app = createApp(MyPageComponent);
    SetVueGlobals(app);
    this.app = app.mount(this.$wrapper.get(0));
  }
  
  save() {
    // Implement save
  }
}

frappe.provide("frappe.ui");
frappe.ui.MyPage = MyPage;
```

### Pattern 2: Vue in DocType HTML Fields

```javascript
// In DocType's client script or [doctype].js
frappe.ui.form.on('Customer', {
  refresh: function(frm) {
    if (frm.fields_dict.custom_dashboard) {
      renderDashboard(frm);
    }
  }
});

function renderDashboard(frm) {
  const wrapper = frm.fields_dict.custom_dashboard.$wrapper[0];
  
  // Option 1: Inline Vue (simple components)
  const { createApp } = Vue;
  const app = createApp({
    template: `
      <div class="dashboard">
        <h4>{{ title }}</h4>
        <div v-for="item in items" :key="item.name">
          {{ item.label }}: {{ item.value }}
        </div>
      </div>
    `,
    data() {
      return {
        title: 'Customer Dashboard',
        items: []
      }
    },
    mounted() {
      this.loadData();
    },
    methods: {
      async loadData() {
        const response = await frappe.call({
          method: 'app.api.get_customer_stats',
          args: { customer: frm.doc.name }
        });
        this.items = response.message;
      }
    }
  });
  app.mount(wrapper);
  
  // Option 2: Bundle-based (complex components)
  frappe.require('customer_dashboard.bundle.js').then(() => {
    new frappe.ui.CustomerDashboard({
      wrapper: wrapper,
      frm: frm
    });
  });
}
```

### Pattern 3: Vue in Script Reports

```javascript
// report/sales_analytics/sales_analytics.js
frappe.query_reports["Sales Analytics"] = {
  filters: [/* ... */],
  
  onload: function(report) {
    // Add Vue visualization button
    report.page.add_inner_button(__("Visualize"), () => {
      showVueVisualization(report);
    });
  },
  
  after_datatable_render: function(datatable_obj) {
    // Enhance report with Vue
    const wrapper = document.querySelector('.query-report');
    const vueContainer = document.createElement('div');
    vueContainer.id = 'report-vue-enhancement';
    wrapper.insertBefore(vueContainer, wrapper.firstChild);
    
    frappe.require('report_enhancement.bundle.js').then(() => {
      new frappe.ui.ReportEnhancement({
        wrapper: vueContainer,
        data: frappe.query_report.data
      });
    });
  }
};
```

### Pattern 4: Vue in Query Reports

```python
# report.py
def execute(filters=None):
    columns = get_columns()
    data = get_data(filters)
    
    # Signal to frontend to use Vue
    message = {
        "use_vue": True,
        "vue_component": "sales_dashboard",
        "component_data": prepare_vue_data(data)
    }
    
    return columns, data, message

# report.js
frappe.query_reports["Report Name"] = {
  onload: function(report) {
    if (report.message && report.message.use_vue) {
      loadVueComponent(report.message);
    }
  }
};
```

### Pattern 5: Vue in Custom Fields

```javascript
// For complex custom fields
frappe.ui.form.ControlCustom = class extends frappe.ui.form.Control {
  make() {
    super.make();
    this.render_vue_component();
  }
  
  render_vue_component() {
    frappe.require('custom_control.bundle.js').then(() => {
      new frappe.ui.CustomControl({
        wrapper: this.$wrapper[0],
        frm: this.frm,
        df: this.df
      });
    });
  }
};
```

### Pattern 6: Vue in Workspace

```javascript
// Custom workspace widget
frappe.widget.CustomWidget = class extends frappe.widget.BaseWidget {
  render() {
    frappe.require('custom_widget.bundle.js').then(() => {
      new frappe.ui.CustomWidget({
        wrapper: this.$wrapper[0],
        settings: this.settings
      });
    });
  }
};
```

## API Patterns

### Always Use frappe.call()

```javascript
// ✅ CORRECT
const response = await frappe.call({
  method: 'app.module.api.method_name',
  args: {
    param1: 'value1',
    param2: 'value2'
  }
});

// ❌ WRONG - Don't use axios/fetch
const response = await axios.post('/api/method', data);
```

### Whitelisted Methods

```python
# Python API
import frappe
from frappe import _

@frappe.whitelist()
def get_dashboard_data(docname):
    """API method for Vue component"""
    if not frappe.has_permission("DocType", "read", docname):
        frappe.throw(_("Insufficient permissions"))
    
    return {
        "metrics": calculate_metrics(docname),
        "chart_data": prepare_chart_data(docname)
    }
```

## State Management

### Pinia with Native Vue

```javascript
// public/js/feature/store.js
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const useFeatureStore = defineStore('feature', () => {
  const items = ref([]);
  const loading = ref(false);
  
  async function loadData() {
    loading.value = true;
    try {
      const response = await frappe.call({
        method: 'frappe.client.get_list',
        args: { /* ... */ }
      });
      items.value = response.message;
    } finally {
      loading.value = false;
    }
  }
  
  return { items, loading, loadData };
});
```

## Styling Patterns

### Use Frappe's Built-in Classes

```vue
<template>
  <!-- Use Bootstrap 4 classes -->
  <div class="row">
    <div class="col-md-6">
      <!-- Use Frappe's button classes -->
      <button class="btn btn-primary btn-sm">
        {{ __('Save') }}
      </button>
    </div>
  </div>
  
  <!-- Use Frappe's card classes -->
  <div class="frappe-card">
    <div class="card-body">
      <!-- Content -->
    </div>
  </div>
</template>

<style scoped>
/* Use Frappe's CSS variables */
.custom-container {
  padding: var(--padding-lg);
  background: var(--card-bg);
  border-radius: var(--border-radius);
}
</style>
```

## Build & Deployment

### Development Workflow

```bash
# 1. Make changes to Vue components
# 2. Build assets
bench build --app app_name

# 3. Or use watch mode
bench start  # Includes asset watching

# 4. Clear cache after changes
bench --site site-name clear-cache
```

### Production Build

```bash
# Build with minification
bench build --production --app app_name

# Deploy
bench --site site-name migrate
bench restart
```

## Common Gotchas & Solutions

### 1. SetVueGlobals Not Found
**Problem**: `SetVueGlobals is not defined`
**Solution**: Ensure libs.bundle.js is loaded first

### 2. Translation Not Working
**Problem**: `__()` not available in Vue component
**Solution**: Always call `SetVueGlobals(app)`

### 3. Vue Not Reactive
**Problem**: Data changes not reflecting
**Solution**: Use Vue 3 Composition API correctly with ref/reactive

### 4. Build Not Updating
**Problem**: Changes not reflected after build
**Solution**: 
```bash
bench build --force --app app_name
bench --site site-name clear-cache
redis-cli FLUSHALL
```

### 5. Module Not Found
**Problem**: Import errors in bundle
**Solution**: Use relative paths `./component` not `component`

## Testing Patterns

### Component Testing

```javascript
// tests/test_vue_component.js
describe('Vue Component Tests', () => {
  it('should mount component', async () => {
    const wrapper = document.createElement('div');
    
    // Load bundle
    await frappe.require('feature.bundle.js');
    
    // Create instance
    const instance = new frappe.ui.Feature(wrapper);
    
    // Assert
    expect(wrapper.querySelector('.feature-container')).toBeTruthy();
  });
});
```

### Integration Testing

```python
# Python test
class TestVueIntegration(unittest.TestCase):
    def test_api_endpoint(self):
        response = frappe.call(
            "app.api.get_dashboard_data",
            docname="TEST-001"
        )
        self.assertIn("metrics", response)
```

## Migration Guide

### From /frontend/ to Native

1. **Move Components**
   - FROM: `app/frontend/src/components/`
   - TO: `app/public/js/components/`

2. **Replace Build System**
   - REMOVE: vite.config.js, package.json
   - USE: bench build

3. **Update Imports**
   - FROM: `import axios from 'axios'`
   - TO: Use `frappe.call()`

4. **Update Routing**
   - FROM: Vue Router
   - TO: Frappe's page system

5. **Update API Calls**
   - FROM: `axios.post('/api/...')`
   - TO: `frappe.call({ method: '...' })`

## Best Practices

### DO's
- ✅ Always use `.bundle.js` entry points
- ✅ Always call `SetVueGlobals(app)`
- ✅ Use `frappe.call()` for all API calls
- ✅ Structure components in `public/js/`
- ✅ Use Frappe's built-in styles
- ✅ Follow Frappe's naming conventions
- ✅ Use Pinia for complex state

### DON'Ts
- ❌ Don't create `/frontend/` directory
- ❌ Don't use separate build tools
- ❌ Don't use Vue Router
- ❌ Don't use axios/fetch
- ❌ Don't create separate package.json
- ❌ Don't ignore Frappe's patterns

## References

- Frappe's Print Format Builder: Example of native Vue
- Frappe's Workflow Builder: Complex Vue integration
- Frappe's Form Builder: Advanced component patterns
- File Uploader: Modal and dialog patterns