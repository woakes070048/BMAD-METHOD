# Modern ERPNext Development Workflow Guide

## Overview
This guide outlines the complete development workflow for building modern ERPNext applications with native Vue.js components integrated directly into Frappe's asset pipeline.

## Development Environment Setup

### 1. Initial Setup
```bash
# Clone your ERPNext app repository
cd ~/frappe-bench
bench get-app https://github.com/your-org/your-app.git

# Install the app on your site
bench --site your-site.local install-app your_app

# Setup development mode
bench set-config developer_mode 1
bench set-config disable_website_cache 1
```

### 2. Native Vue Development Setup
```bash
# No separate frontend setup needed!
# Vue components live in public/js/ directory

# Start Frappe development server with asset watching
bench start

# Build Vue components (when needed)
bench build --app your_app

# For development with auto-rebuild
bench start  # Includes asset watching
```

## Project Structure

### Native Vue App Structure (NO /frontend/ directory)
```
your_app/
├── your_app/
│   ├── __init__.py
│   ├── hooks.py
│   ├── modules.txt
│   ├── patches.txt
│   ├── api/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── customer.py
│   │   └── utils.py
│   ├── your_module/
│   │   ├── doctype/
│   │   │   └── your_doctype/
│   │   │       ├── your_doctype.json
│   │   │       ├── your_doctype.py
│   │   │       ├── your_doctype.js
│   │   │       └── test_your_doctype.py
│   │   ├── page/
│   │   │   └── dashboard/
│   │   │       ├── dashboard.json
│   │   │       └── dashboard.js
│   │   ├── report/
│   │   └── web_form/
│   ├── public/
│   │   ├── js/                    # Vue components here
│   │   │   ├── dashboard.bundle.js       # Entry point
│   │   │   ├── dashboard/
│   │   │   │   ├── Dashboard.vue
│   │   │   │   ├── components/
│   │   │   │   │   ├── MetricCard.vue
│   │   │   │   │   └── ChartWidget.vue
│   │   │   │   └── stores/
│   │   │   │       └── dashboard.js
│   │   │   ├── customer.bundle.js        # Another feature
│   │   │   └── customer/
│   │   │       ├── CustomerList.vue
│   │   │       └── components/
│   │   ├── css/
│   │   └── images/
│   └── www/
├── tests/
├── requirements.txt
├── pyproject.toml
└── README.md
```

## Development Workflow

### 1. Feature Development Flow

#### Step 1: Create Feature Branch
```bash
# Create new feature branch
git checkout -b feature/customer-dashboard

# Track changes
git add .
git commit -m "feat: start customer dashboard implementation"
```

#### Step 2: Create Vue Components (Native Pattern)
```bash
# Create component directory
mkdir -p your_app/public/js/dashboard

# Create bundle entry point
touch your_app/public/js/dashboard.bundle.js

# Create Vue component
touch your_app/public/js/dashboard/Dashboard.vue

# Create supporting components
mkdir -p your_app/public/js/dashboard/components
touch your_app/public/js/dashboard/components/MetricCard.vue
```

#### Step 3: Implement Bundle Entry Point
```javascript
// your_app/public/js/dashboard.bundle.js
import { createApp } from "vue";
import Dashboard from "./dashboard/Dashboard.vue";
import { createPinia } from "pinia";

class DashboardApp {
  constructor({ wrapper, page }) {
    this.wrapper = wrapper;
    this.page = page;
    this.init();
  }
  
  init() {
    const app = createApp(Dashboard);
    
    // CRITICAL: Enable Frappe globals
    SetVueGlobals(app);
    
    const pinia = createPinia();
    app.use(pinia);
    
    this.app = app.mount(this.wrapper);
  }
}

frappe.provide("frappe.ui");
frappe.ui.DashboardApp = DashboardApp;
```

#### Step 4: Create Frappe Page
```javascript
// your_app/your_module/page/dashboard/dashboard.js
frappe.pages['dashboard'].on_page_load = function(wrapper) {
    const page = frappe.ui.make_app_page({
        parent: wrapper,
        title: 'Dashboard',
        single_column: true
    });
    
    // Load Vue bundle
    frappe.require('dashboard.bundle.js').then(() => {
        new frappe.ui.DashboardApp({
            wrapper: page.main,
            page: page
        });
    });
};
```

#### Step 5: Implement Vue Component
```vue
<!-- your_app/public/js/dashboard/Dashboard.vue -->
<template>
  <div class="dashboard-container">
    <div class="row">
      <div class="col-md-12">
        <h3>{{ __('Dashboard') }}</h3>
      </div>
    </div>
    
    <div class="row">
      <div class="col-md-6" v-for="metric in metrics" :key="metric.name">
        <MetricCard :metric="metric" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import MetricCard from './components/MetricCard.vue';

const metrics = ref([]);

onMounted(async () => {
  const response = await frappe.call({
    method: 'your_app.api.dashboard.get_metrics'
  });
  
  if (response.message) {
    metrics.value = response.message;
  }
});
</script>

<style scoped>
.dashboard-container {
  padding: var(--padding-lg);
}
</style>
```

### 2. Backend API Development

#### Create API Endpoints
```python
# your_app/api/dashboard.py
import frappe
from frappe import _

@frappe.whitelist()
def get_metrics():
    """Get dashboard metrics"""
    if not frappe.has_permission("Dashboard", "read"):
        frappe.throw(_("Insufficient permissions"))
    
    return [
        {
            "name": "total_sales",
            "label": _("Total Sales"),
            "value": 150000,
            "type": "currency"
        },
        {
            "name": "open_orders",
            "label": _("Open Orders"),
            "value": 25,
            "type": "number"
        }
    ]
```

### 3. Build and Test Cycle

#### Build Assets
```bash
# Build Vue components
bench build --app your_app

# For production build
bench build --production --app your_app

# Clear cache after changes
bench --site your-site.local clear-cache
```

#### Testing
```bash
# Run Python tests
bench --site your-site.local run-tests --app your_app

# Test specific module
bench --site your-site.local run-tests --app your_app --module your_module

# Console testing for quick validation
bench --site your-site.local console
>>> frappe.call("your_app.api.dashboard.get_metrics")
```

### 4. Code Quality and Standards

#### Validation Checklist
- [ ] All API methods use `@frappe.whitelist()`
- [ ] Vue components use `SetVueGlobals(app)`
- [ ] API calls use `frappe.call()` (not axios/fetch)
- [ ] Components use Bootstrap 4 classes
- [ ] Bundle entry points follow class pattern
- [ ] No `/frontend/` directory references
- [ ] Build works with `bench build`

#### Performance Optimization
```bash
# Optimize bundle size
bench build --production --app your_app

# Check asset sizes
ls -la your_app/public/js/

# Monitor build time
time bench build --app your_app
```

## Common Development Patterns

### 1. DocType Integration
```javascript
// In DocType's client script
frappe.ui.form.on('Customer', {
    refresh: function(frm) {
        if (frm.fields_dict.custom_dashboard) {
            renderCustomerDashboard(frm);
        }
    }
});

function renderCustomerDashboard(frm) {
    const wrapper = frm.fields_dict.custom_dashboard.$wrapper[0];
    
    frappe.require('customer_dashboard.bundle.js').then(() => {
        new frappe.ui.CustomerDashboard({
            wrapper: wrapper,
            customer: frm.doc.name
        });
    });
}
```

### 2. State Management with Pinia
```javascript
// your_app/public/js/dashboard/stores/dashboard.js
import { defineStore } from 'pinia';
import { ref } from 'vue';

export const useDashboardStore = defineStore('dashboard', () => {
  const metrics = ref([]);
  const loading = ref(false);
  
  async function fetchMetrics() {
    loading.value = true;
    try {
      const response = await frappe.call({
        method: 'your_app.api.dashboard.get_metrics'
      });
      metrics.value = response.message;
    } finally {
      loading.value = false;
    }
  }
  
  return { metrics, loading, fetchMetrics };
});
```

### 3. Component Communication
```vue
<!-- Parent Component -->
<template>
  <div>
    <MetricCard 
      v-for="metric in metrics"
      :key="metric.name"
      :metric="metric"
      @click="handleMetricClick"
    />
  </div>
</template>

<script setup>
function handleMetricClick(metric) {
  // Navigate using Frappe's router
  frappe.set_route('List', 'Sales Order', {
    'status': 'Open'
  });
}
</script>
```

## Deployment Workflow

### 1. Pre-deployment
```bash
# Build production assets
bench build --production --app your_app

# Run full test suite
bench --site your-site.local run-tests --app your_app

# Check for console errors in browser
# Verify all functionality works
```

### 2. Deployment
```bash
# On production server
git pull origin main
bench --site your-site.local migrate
bench build --production --app your_app
bench --site your-site.local clear-cache
bench restart
```

### 3. Post-deployment Validation
```bash
# Check application loads
curl -I https://your-site.com/app/dashboard

# Verify Vue components render
# Check browser console for errors
# Test critical user workflows
```

## Troubleshooting

### Common Issues

#### Vue Component Not Rendering
```bash
# Check if bundle built successfully
ls -la your_app/public/js/

# Verify bundle loads
# Open browser console and check for errors

# Force rebuild
bench build --force --app your_app
bench --site your-site.local clear-cache
```

#### API Calls Failing
```python
# Ensure method is whitelisted
@frappe.whitelist()
def your_method():
    pass

# Check permissions
frappe.has_permission("DocType", "read")

# Test in console
frappe.call("your_app.api.method")
```

#### Translation Not Working
```javascript
// Ensure SetVueGlobals is called
const app = createApp(Component);
SetVueGlobals(app);  // This enables __() function
app.mount(wrapper);

// Use in templates
{{ __('Translatable Text') }}
```

## Best Practices

### DO's ✅
- Use `.bundle.js` entry points for features
- Always call `SetVueGlobals(app)`
- Use `frappe.call()` for API calls
- Structure components in `public/js/`
- Use Bootstrap 4 classes
- Build with `bench build`
- Test frequently during development

### DON'Ts ❌
- Don't create `/frontend/` directory
- Don't use Vite or webpack separately
- Don't use Vue Router (use Frappe pages)
- Don't use axios/fetch
- Don't create separate package.json for frontend
- Don't ignore Frappe's asset pipeline

## Resources

- [Frappe Framework Documentation](https://frappeframework.com)
- [Vue 3 Documentation](https://vuejs.org)
- [Otto Source Code](https://github.com/woakes070048/otto) - Example native Vue app
- [Frappe CRM Source](https://github.com/frappe/crm) - Modern Frappe patterns