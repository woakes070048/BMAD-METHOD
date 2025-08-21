# Otto & Check_run Vue Patterns for ERPNext

## Overview
This document outlines Vue.js patterns extracted from the Otto and Check_run applications, providing proven approaches for integrating Vue 3 with Frappe's native asset pipeline.

## Core Pattern: Bundle.js Entry Points

### Otto Pattern (from `/otto/public/js/view_session/`)
```javascript
// view_session.bundle.js
import { createApp } from 'vue';
import ViewSession from './ViewSession.vue';
import { createPinia } from 'pinia';

class SessionViewer {
    constructor(wrapper) {
        this.$wrapper = $(wrapper);
        this.page = wrapper.page;
        
        // Setup page actions
        this.setupPageActions();
        
        // Create Vue app
        const app = createApp(ViewSession);
        
        // Add Pinia for state management
        const pinia = createPinia();
        app.use(pinia);
        
        // CRITICAL: Set Frappe globals
        SetVueGlobals(app);
        
        // Mount the app
        this.$component = app.mount(this.$wrapper.get(0));
    }
    
    setupPageActions() {
        this.page.set_primary_action(__('Refresh'), () => {
            this.$component.refresh();
        });
    }
}

// Register with Frappe pages
frappe.pages['view-otto-session'].on_page_load = function(wrapper) {
    frappe.require('view_session.bundle.js').then(() => {
        new SessionViewer(wrapper);
    });
}
```

### Check_run Pattern (from `/check_run/public/js/check_run/`)
```javascript
// check_run.bundle.js
import { createApp } from 'vue';
import CheckRun from './CheckRun.vue';
import ModeOfPaymentSummary from './ModeOfPaymentSummary.vue';

// Component registration happens in bundle
const CheckRunApp = {
    components: {
        CheckRun,
        ModeOfPaymentSummary
    },
    
    init(wrapper) {
        const app = createApp(CheckRun);
        
        // Register additional components
        app.component('ModeOfPaymentSummary', ModeOfPaymentSummary);
        
        // Set up Frappe globals
        SetVueGlobals(app);
        
        // Mount to wrapper
        return app.mount(wrapper);
    }
};

// Export for use in Frappe pages
window.CheckRunApp = CheckRunApp;
```

## Component Organization Structure

### Otto's Component Structure
```
public/js/view_session/
├── Container.vue           # Main container component
├── ViewSession.vue        # Root component
├── components/            # Organized sub-components
│   ├── AllToolUseViewer.vue
│   ├── ContentViewer.vue
│   ├── Detail.vue
│   ├── ImageViewer.vue
│   ├── ObjectViewer.vue
│   ├── PreViewer.vue
│   ├── ScrapbookViewer.vue
│   ├── SectionContainer.vue
│   ├── SessionViewer.vue
│   ├── StatsViewer.vue
│   ├── TextViewer.vue
│   └── ToolUseViewer.vue
├── selection.js           # Utility functions
├── utils.js              # Helper functions
└── view_session.bundle.js # Entry point
```

### Check_run's Component Structure
```
public/js/check_run/
├── CheckRun.vue                      # Main component
├── ModeOfPaymentSummary.vue         # Sub-component
├── check_run.js                     # Frappe integration
├── check_run_quick_entry.js         # Quick entry dialog
└── check_run_settings_quick_entry.js # Settings dialog
```

## Vue Component Patterns

### 1. Root Component Pattern (Otto Style)
```vue
<!-- ViewSession.vue -->
<template>
  <div class="frappe-container">
    <Container v-if="session">
      <SessionViewer :session="session" />
      <StatsViewer :stats="session.stats" />
      <AllToolUseViewer :tools="session.tools" />
    </Container>
    <div v-else class="text-muted text-center p-5">
      {{ __('Loading session...') }}
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import Container from './Container.vue';
import SessionViewer from './components/SessionViewer.vue';
import StatsViewer from './components/StatsViewer.vue';
import AllToolUseViewer from './components/AllToolUseViewer.vue';

const session = ref(null);

onMounted(async () => {
  await loadSession();
});

async function loadSession() {
  const result = await frappe.call({
    method: 'otto.api.session_view.get_session',
    args: { session_id: frappe.route_options.session_id }
  });
  session.value = result.message;
}

function refresh() {
  loadSession();
}

// Expose for parent component
defineExpose({ refresh });
</script>
```

### 2. Sub-Component Pattern (Check_run Style)
```vue
<!-- ModeOfPaymentSummary.vue -->
<template>
  <div class="mode-of-payment-summary">
    <h4>{{ __('Payment Summary') }}</h4>
    <div v-for="mode in paymentModes" :key="mode.name" class="payment-mode-item">
      <div class="d-flex justify-content-between">
        <span>{{ mode.mode_of_payment }}</span>
        <span class="font-weight-bold">{{ format_currency(mode.amount) }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  payments: {
    type: Array,
    required: true
  }
});

const paymentModes = computed(() => {
  // Group payments by mode
  const grouped = {};
  props.payments.forEach(payment => {
    const mode = payment.mode_of_payment || 'Unknown';
    if (!grouped[mode]) {
      grouped[mode] = { mode_of_payment: mode, amount: 0 };
    }
    grouped[mode].amount += payment.amount;
  });
  return Object.values(grouped);
});

// Use Frappe's format_currency
const format_currency = (amount) => {
  return window.format_currency(amount, frappe.defaults.get_user_default('currency'));
};
</script>
```

## Frappe Integration Patterns

### 1. Using Frappe APIs in Vue
```javascript
// Pattern from Otto
async function fetchData() {
  try {
    const response = await frappe.call({
      method: 'app_name.api.endpoint',
      args: {
        param1: value1,
        param2: value2
      }
    });
    return response.message;
  } catch (error) {
    frappe.msgprint({
      title: __('Error'),
      message: error.message,
      indicator: 'red'
    });
  }
}
```

### 2. Using Frappe Utilities
```javascript
// Access Frappe globals through window
const { __ } = window;  // Translation
const { format_currency, format_date } = window;  // Formatters

// Use Frappe's date utilities
const today = frappe.datetime.get_today();
const formatted = frappe.datetime.str_to_user(date_string);

// Use Frappe's user utilities
const user = frappe.session.user;
const has_role = frappe.user_roles.includes('System Manager');
```

### 3. Frappe Page Integration
```javascript
// hooks.py configuration
app_include_js = [
    "/assets/app_name/js/feature.bundle.js"
]

# Page definition
page_name = {
    "page_name": "feature-page",
    "title": _("Feature Page"),
    "single_column": True,
    "custom_page": True
}
```

## State Management with Pinia

### Store Definition (Otto Pattern)
```javascript
// stores/sessionStore.js
import { defineStore } from 'pinia';

export const useSessionStore = defineStore('session', {
  state: () => ({
    session: null,
    loading: false,
    error: null
  }),
  
  getters: {
    isLoading: (state) => state.loading,
    hasError: (state) => !!state.error
  },
  
  actions: {
    async fetchSession(sessionId) {
      this.loading = true;
      try {
        const result = await frappe.call({
          method: 'otto.api.get_session',
          args: { session_id: sessionId }
        });
        this.session = result.message;
      } catch (error) {
        this.error = error;
        frappe.throw(error.message);
      } finally {
        this.loading = false;
      }
    }
  }
});
```

## Build Configuration

### Frappe's esbuild Pipeline
```javascript
// No separate build config needed!
// Frappe automatically handles:
// - Vue SFC compilation
// - Bundle generation
// - Asset optimization
// - Hot reload in development

// Just run:
bench build --app app_name
// or in development:
bench start  // Includes watch mode
```

## Key Differences from Standalone Vue Apps

### DO NOT:
- Create `/frontend/` directory
- Use Vite or separate build tools
- Create separate package.json for frontend
- Use Vue Router (use Frappe's page system)
- Import CSS separately (use Frappe's style system)

### DO:
- Place Vue files in `public/js/`
- Use `.bundle.js` suffix for entry points
- Call `SetVueGlobals(app)` before mounting
- Use Frappe's page system for routing
- Use Frappe's built-in utilities and APIs
- Let Frappe handle the build process

## Common Patterns

### 1. Dialog Integration
```javascript
// Using Frappe dialogs with Vue components
const dialog = new frappe.ui.Dialog({
  title: __('Select Options'),
  fields: [{
    fieldtype: 'HTML',
    fieldname: 'vue_component'
  }]
});

// Mount Vue component in dialog
const app = createApp(DialogComponent);
SetVueGlobals(app);
app.mount(dialog.fields_dict.vue_component.wrapper);
dialog.show();
```

### 2. List View Enhancement
```javascript
// Enhance existing list view with Vue
frappe.listview_settings['DocType'] = {
  onload: function(listview) {
    const wrapper = listview.$result.find('.list-header-toolbar');
    const app = createApp(ListToolbar, {
      listview: listview
    });
    SetVueGlobals(app);
    app.mount(wrapper[0]);
  }
};
```

### 3. Form View Enhancement
```javascript
// Add Vue component to form view
frappe.ui.form.on('DocType', {
  refresh: function(frm) {
    const wrapper = frm.fields_dict['custom_html'].wrapper;
    const app = createApp(FormComponent, {
      frm: frm,
      doc: frm.doc
    });
    SetVueGlobals(app);
    app.mount(wrapper);
  }
});
```

## Best Practices

1. **Component Naming**: Use PascalCase for Vue components
2. **File Organization**: Keep related components together
3. **Bundle Size**: Create separate bundles for large features
4. **State Management**: Use Pinia for complex state
5. **API Calls**: Always use frappe.call() for backend communication
6. **Error Handling**: Use Frappe's error display methods
7. **Translations**: Use `__()` for all user-facing text
8. **Styling**: Use Frappe's existing Bootstrap classes
9. **Icons**: Use Frappe's icon set or frappe-ui icons
10. **Testing**: Write tests that work with Frappe's test framework

## Migration from /frontend/ Pattern

If you have existing Vue code in `/frontend/`:

1. Move components to `public/js/[feature]/`
2. Create `.bundle.js` entry point
3. Remove Vite configuration
4. Add `SetVueGlobals(app)` call
5. Update imports to use relative paths
6. Remove separate package.json
7. Update hooks.py to include bundle
8. Test with `bench build --app [app_name]`

## Example: Complete Feature Implementation

```javascript
// public/js/customer_portal.bundle.js
import { createApp } from 'vue';
import { createPinia } from 'pinia';
import CustomerPortal from './customer_portal/CustomerPortal.vue';
import { useCustomerStore } from './customer_portal/stores/customerStore';

class CustomerPortalApp {
  constructor(wrapper) {
    this.$wrapper = $(wrapper);
    this.page = wrapper.page;
    
    // Initialize Vue app
    this.initVueApp();
    
    // Setup page actions
    this.setupPageActions();
  }
  
  initVueApp() {
    const app = createApp(CustomerPortal);
    const pinia = createPinia();
    
    app.use(pinia);
    SetVueGlobals(app);
    
    this.$app = app.mount(this.$wrapper.get(0));
    
    // Initialize store
    const store = useCustomerStore();
    store.initialize();
  }
  
  setupPageActions() {
    this.page.set_primary_action(__('Refresh'), () => {
      this.$app.refresh();
    });
    
    this.page.set_secondary_action(__('Settings'), () => {
      this.$app.openSettings();
    });
  }
}

// Register with Frappe
frappe.pages['customer-portal'].on_page_load = function(wrapper) {
  frappe.require('customer_portal.bundle.js').then(() => {
    new CustomerPortalApp(wrapper);
  });
};
```

This pattern ensures seamless integration with Frappe while leveraging Vue 3's modern features.