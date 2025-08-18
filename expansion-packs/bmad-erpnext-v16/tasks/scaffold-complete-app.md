# Scaffold Complete Native ERPNext App

## Overview
This task guides you through scaffolding a complete ERPNext application with native Vue.js components integrated directly into Frappe's asset pipeline - NO separate frontend directory.

## Prerequisites

### Required Knowledge
- [ ] ERPNext/Frappe Framework basics
- [ ] Vue 3 Composition API
- [ ] Python for backend development
- [ ] Understanding of DocTypes and Frappe architecture

### Development Environment
- [ ] Frappe bench installed and configured
- [ ] ERPNext installed
- [ ] Development site created
- [ ] No separate Node.js/npm setup needed for frontend

## Step-by-Step Process

### Step 1: Create the App Structure

#### Create New App
```bash
# Navigate to frappe-bench
cd ~/frappe-bench

# Create new app
bench new-app {{app_name}}

# Install app on site
bench --site {{site_name}} install-app {{app_name}}
```

### Step 2: Setup Native Vue Components

#### Create Component Directory Structure
```bash
# Create Vue component directories in public/js
cd apps/{{app_name}}/{{app_name}}/public/js
mkdir -p {dashboard,list_view,reports}/{components,stores}
```

#### Create Bundle Entry Points
```javascript
// public/js/dashboard.bundle.js
import { createApp } from "vue";
import DashboardComponent from "./dashboard/Dashboard.vue";
import { createPinia } from "pinia";

class Dashboard {
  constructor({ wrapper, docname }) {
    this.wrapper = wrapper;
    this.docname = docname;
    this.init();
  }
  
  init() {
    const app = createApp(DashboardComponent, {
      docname: this.docname
    });
    
    // CRITICAL: Setup Frappe globals
    SetVueGlobals(app);
    
    const pinia = createPinia();
    app.use(pinia);
    
    this.app = app.mount(this.wrapper);
  }
}

frappe.provide("frappe.ui");
frappe.ui.Dashboard = Dashboard;
```

### Step 3: Create Frappe Pages for Vue Components

#### Create Page Definition
```python
# {{app_name}}/{{module_name}}/page/dashboard/dashboard.py
# Page doctype is created through Frappe UI
```

#### Create Page JavaScript
```javascript
// {{app_name}}/{{module_name}}/page/dashboard/dashboard.js
frappe.pages['dashboard'].on_page_load = function(wrapper) {
    const page = frappe.ui.make_app_page({
        parent: wrapper,
        title: 'Dashboard',
        single_column: true
    });
    
    // Load Vue bundle
    frappe.require('dashboard.bundle.js').then(() => {
        new frappe.ui.Dashboard({
            wrapper: page.main,
            docname: frappe.session.user
        });
    });
};
```

### Step 4: Implement DocType Integration

#### Add HTML Fields for Vue Components
```python
# In DocType configuration or through UI
{
    "fieldname": "custom_dashboard",
    "fieldtype": "HTML",
    "label": "Dashboard",
    "options": "<div id='custom-dashboard'></div>"
}
```

#### Create Client Scripts for Vue Integration
```javascript
// {{app_name}}/{{module_name}}/doctype/{{doctype_name}}/{{doctype_name}}.js
frappe.ui.form.on('{{DocType}}', {
    refresh: function(frm) {
        if (frm.fields_dict.custom_dashboard) {
            renderVueDashboard(frm);
        }
    }
});

function renderVueDashboard(frm) {
    const wrapper = frm.fields_dict.custom_dashboard.$wrapper[0];
    
    // Load and mount Vue component
    frappe.require('dashboard.bundle.js').then(() => {
        new frappe.ui.Dashboard({
            wrapper: wrapper,
            docname: frm.doc.name,
            frm: frm
        });
    });
}
```

### Step 5: Create Vue Components

#### Main Dashboard Component
```vue
<!-- public/js/dashboard/Dashboard.vue -->
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
    
    <div class="row">
      <div class="col-md-12">
        <DataTable 
          :doctype="doctype"
          :fields="tableFields"
          :filters="filters"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import MetricCard from './components/MetricCard.vue';
import DataTable from './components/DataTable.vue';

const props = defineProps({
  docname: String
});

const metrics = ref([]);
const doctype = ref('Sales Order');
const tableFields = ref([
  { name: 'name', label: 'ID' },
  { name: 'customer', label: 'Customer' },
  { name: 'grand_total', label: 'Total' },
  { name: 'status', label: 'Status' }
]);
const filters = ref({});

onMounted(async () => {
  await loadDashboardData();
});

async function loadDashboardData() {
  const response = await frappe.call({
    method: '{{app_name}}.api.dashboard.get_dashboard_data',
    args: {
      user: props.docname
    }
  });
  
  if (response.message) {
    metrics.value = response.message.metrics;
    filters.value = response.message.filters;
  }
}
</script>

<style scoped>
.dashboard-container {
  padding: var(--padding-lg);
}
</style>
```

#### Reusable Components
```vue
<!-- public/js/dashboard/components/MetricCard.vue -->
<template>
  <div class="frappe-card">
    <div class="card-body">
      <h5 class="card-title">{{ metric.label }}</h5>
      <h2 class="metric-value">{{ formattedValue }}</h2>
      <p class="text-muted">{{ metric.description }}</p>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  metric: Object
});

const formattedValue = computed(() => {
  if (props.metric.type === 'currency') {
    return frappe.format(props.metric.value, { fieldtype: 'Currency' });
  }
  return props.metric.value;
});
</script>
```

### Step 6: Create Pinia Stores

```javascript
// public/js/dashboard/stores/dashboard.js
import { defineStore } from 'pinia';
import { ref } from 'vue';

export const useDashboardStore = defineStore('dashboard', () => {
  const data = ref(null);
  const loading = ref(false);
  const error = ref(null);
  
  async function fetchData(filters = {}) {
    loading.value = true;
    error.value = null;
    
    try {
      const response = await frappe.call({
        method: '{{app_name}}.api.dashboard.get_data',
        args: { filters }
      });
      
      data.value = response.message;
    } catch (e) {
      error.value = e.message;
      frappe.msgprint({
        title: __('Error'),
        message: e.message,
        indicator: 'red'
      });
    } finally {
      loading.value = false;
    }
  }
  
  return {
    data,
    loading,
    error,
    fetchData
  };
});
```

### Step 7: Backend API Integration

#### Create Whitelisted API Methods
```python
# {{app_name}}/api/dashboard.py
import frappe
from frappe import _

@frappe.whitelist()
def get_dashboard_data(user=None):
    """Get dashboard data for user"""
    if not user:
        user = frappe.session.user
    
    # Check permissions
    if not frappe.has_permission("Dashboard", "read"):
        frappe.throw(_("Insufficient permissions"))
    
    metrics = calculate_metrics(user)
    recent_items = get_recent_items(user)
    
    return {
        "metrics": metrics,
        "recent_items": recent_items,
        "filters": {"owner": user}
    }

def calculate_metrics(user):
    """Calculate dashboard metrics"""
    return [
        {
            "name": "total_sales",
            "label": _("Total Sales"),
            "value": get_total_sales(user),
            "type": "currency",
            "description": _("Total sales this month")
        },
        {
            "name": "open_orders",
            "label": _("Open Orders"),
            "value": get_open_orders_count(user),
            "type": "number",
            "description": _("Orders pending processing")
        }
    ]
```

### Step 8: Build and Deploy

#### Build Assets
```bash
# Build the Vue components and bundles
bench build --app {{app_name}}

# For production build
bench build --production --app {{app_name}}

# Clear cache after build
bench --site {{site_name}} clear-cache
```

#### Test the Application
```bash
# Start development server
bench start

# Access the application
# Navigate to: http://localhost:8000/app/dashboard
```

## Generated Output Structure

### Native App Structure (NO frontend directory)
```
{{app_name}}/
├── {{app_name}}/
│   ├── __init__.py
│   ├── hooks.py
│   ├── modules.txt
│   ├── patches.txt
│   ├── api/
│   │   ├── __init__.py
│   │   ├── dashboard.py
│   │   └── utils.py
│   ├── {{module_name}}/
│   │   ├── __init__.py
│   │   ├── doctype/
│   │   │   └── {{doctype_name}}/
│   │   │       ├── {{doctype_name}}.json
│   │   │       ├── {{doctype_name}}.py
│   │   │       └── {{doctype_name}}.js
│   │   └── page/
│   │       └── dashboard/
│   │           ├── dashboard.json
│   │           └── dashboard.js
│   ├── public/
│   │   ├── js/
│   │   │   ├── dashboard.bundle.js           # Entry point
│   │   │   ├── dashboard/
│   │   │   │   ├── Dashboard.vue
│   │   │   │   ├── components/
│   │   │   │   │   ├── MetricCard.vue
│   │   │   │   │   ├── DataTable.vue
│   │   │   │   │   └── ChartWidget.vue
│   │   │   │   └── stores/
│   │   │   │       └── dashboard.js
│   │   │   ├── list_view.bundle.js
│   │   │   └── list_view/
│   │   │       ├── ListView.vue
│   │   │       └── components/
│   │   └── css/
│   │       └── {{app_name}}.css
│   └── www/
│       └── __init__.py
├── LICENSE
├── README.md
└── pyproject.toml
```

## Best Practices

### DO's
- ✅ Use `.bundle.js` entry points for each feature
- ✅ Always call `SetVueGlobals(app)` for Vue apps
- ✅ Use `frappe.call()` for all API calls
- ✅ Structure components in `public/js/`
- ✅ Use Frappe's built-in Bootstrap classes
- ✅ Build with `bench build`
- ✅ Use HTML fields for Vue mount points in DocTypes

### DON'Ts
- ❌ Don't create `/frontend/` directory
- ❌ Don't use Vite or webpack
- ❌ Don't use Vue Router (use Frappe pages)
- ❌ Don't use axios/fetch (use frappe.call)
- ❌ Don't create separate package.json for frontend
- ❌ Don't ignore Frappe's patterns

## Common Issues & Solutions

### Issue: Vue component not rendering
**Solution**: Ensure `SetVueGlobals(app)` is called before mounting

### Issue: Translation not working
**Solution**: Use `window.__` or ensure SetVueGlobals is called

### Issue: Build not updating
**Solution**: 
```bash
bench build --force --app {{app_name}}
bench --site {{site_name}} clear-cache
```

### Issue: API calls failing
**Solution**: Ensure methods are decorated with `@frappe.whitelist()`

## Next Steps

1. **Add More Components**: Create additional Vue components as needed
2. **Implement State Management**: Use Pinia for complex state
3. **Add Tests**: Write tests for components and APIs
4. **Optimize Performance**: Implement lazy loading for large components
5. **Add PWA Features**: Implement service workers for offline support

## Resources

- [Frappe Framework Documentation](https://frappeframework.com)
- [Vue 3 Documentation](https://vuejs.org)
- [Pinia Documentation](https://pinia.vuejs.org)
- [Otto Source Code](https://github.com/woakes070048/otto) - Example of native Vue in Frappe