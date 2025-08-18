# Native Vue Patterns for ERPNext v16
## Modern Vue 3 Integration Without /frontend/ Directory

**Last Updated**: 2025-08-17  
**Framework Version**: Frappe Framework 15+ | ERPNext 16  
**Vue Version**: 3.x  
**Source Analysis**: Frappe core, ERPNext core, Otto repository patterns  

---

## 🚨 CRITICAL: NO /frontend/ DIRECTORY

**ERPNext v16 has NATIVE Vue 3 support** - NO separate frontend build required!

### ❌ **OLD PATTERN (Don't use)**
```
myapp/
├── frontend/          # ❌ REMOVE - Not needed
│   ├── src/
│   ├── public/
│   ├── package.json   # ❌ REMOVE
│   ├── vite.config.js # ❌ REMOVE
│   └── dist/
```

### ✅ **NEW PATTERN (Use this)**
```
myapp/
├── myapp/
│   ├── public/
│   │   └── js/
│   │       ├── my_feature.bundle.js    # Entry point
│   │       └── my_feature/             # Vue components
│   │           ├── MyComponent.vue
│   │           ├── components/
│   │           └── store.js
```

---

## 🎯 NATIVE VUE INTEGRATION PATTERNS

### **Bundle Entry Point Pattern (MANDATORY)**
```javascript
// myapp/public/js/feature_name.bundle.js
import { createApp } from "vue";
import { createPinia } from "pinia";
import MainComponent from "./feature_name/MainComponent.vue";

class FeatureName {
    constructor({ wrapper, page, options = {} }) {
        this.$wrapper = $(wrapper);
        this.page = page;
        this.options = options;
        this.init();
    }

    init() {
        this.setup_page_actions();
        this.setup_app();
    }

    setup_page_actions() {
        this.page.set_title(__("Feature Name"));
        
        // Add Frappe page actions
        this.page.set_primary_action(__("Save"), () => {
            this.$component.save();
        });

        this.page.add_button(__("Refresh"), () => {
            this.$component.refresh();
        });
    }

    setup_app() {
        // Create Vue app
        const app = createApp(MainComponent, {
            options: this.options
        });

        // CRITICAL: Setup Frappe globals
        this.setupFrappeGlobals(app);

        // Add Pinia for state management
        const pinia = createPinia();
        app.use(pinia);

        // Mount to wrapper
        this.$component = app.mount(this.$wrapper.get(0));
    }

    setupFrappeGlobals(app) {
        // Make Frappe globally available in Vue components
        app.config.globalProperties.$frappe = frappe;
        app.config.globalProperties.$__ = __;
        
        // Provide common Frappe utilities
        app.provide('frappe', frappe);
        app.provide('call', frappe.call);
        app.provide('db', frappe.db);
    }
}

// Register with Frappe
frappe.provide("frappe.ui");
frappe.ui.FeatureName = FeatureName;

// Page integration
frappe.pages["feature-name"].on_page_load = function(wrapper) {
    frappe.require("feature_name.bundle.js").then(() => {
        new FeatureName({ wrapper, page: wrapper.page });
    });
};
```

### **Vue Component Pattern**
```vue
<!-- myapp/public/js/feature_name/MainComponent.vue -->
<template>
  <div class="feature-container">
    <div class="feature-header">
      <h2>{{ __('Feature Title') }}</h2>
      <button 
        class="btn btn-primary btn-sm"
        @click="handleAction"
        :disabled="loading"
      >
        {{ loading ? __('Loading...') : __('Action') }}
      </button>
    </div>

    <div class="feature-content">
      <!-- Use Frappe's built-in CSS classes -->
      <div class="frappe-card">
        <div class="form-group">
          <label>{{ __('Field Label') }}</label>
          <div class="control-input">
            <input 
              v-model="formData.field"
              type="text"
              class="form-control"
              :placeholder="__('Enter value')"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue';

// Access Frappe through inject
const frappe = inject('frappe');
const call = inject('call');
const __ = window.__;

// Reactive data
const loading = ref(false);
const formData = ref({
  field: ''
});

// Methods using Frappe APIs
async function handleAction() {
  loading.value = true;
  
  try {
    const response = await call({
      method: 'myapp.api.my_method',
      args: {
        data: formData.value
      }
    });
    
    frappe.show_alert({
      message: __('Action completed successfully'),
      indicator: 'green'
    });
    
    // Handle response
    console.log(response.message);
    
  } catch (error) {
    frappe.show_alert({
      message: __('Action failed: {0}', [error.message]),
      indicator: 'red'
    });
  } finally {
    loading.value = false;
  }
}

async function loadData() {
  const data = await call({
    method: 'myapp.api.get_data',
    args: { doctype: 'MyDocType' }
  });
  
  formData.value = data.message;
}

// Lifecycle
onMounted(() => {
  loadData();
});

// Expose methods for parent access
defineExpose({
  save: handleAction,
  refresh: loadData
});
</script>

<style scoped>
.feature-container {
  padding: 1rem;
}

.feature-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.feature-content {
  /* Use Frappe's responsive grid */
  display: grid;
  gap: 1rem;
}

/* Mobile-first responsive design */
@media (min-width: 768px) {
  .feature-content {
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  }
}
</style>
```

---

## 🏗️ MODERN APP STRUCTURE (v16 Standards)

### **Complete App Structure**
```
myapp/                              # App root directory
├── myapp/                          # Main app package
│   ├── __init__.py
│   ├── hooks.py                    # App configuration
│   ├── modules.txt                 # Module list
│   ├── patches.txt                 # Database patches
│   │
│   ├── config/                     # App configuration
│   │   ├── __init__.py
│   │   ├── desktop.py             # Desktop shortcuts
│   │   └── docs.py                # Documentation config
│   │
│   ├── public/                     # Static assets (NO /frontend/)
│   │   ├── css/                   # Custom CSS
│   │   ├── js/                    # JavaScript and Vue components
│   │   │   ├── dashboard.bundle.js         # Feature entry points
│   │   │   ├── customer_portal.bundle.js   # Another feature
│   │   │   ├── dashboard/                  # Vue components
│   │   │   │   ├── Dashboard.vue           # Main component
│   │   │   │   ├── components/             # Sub-components
│   │   │   │   │   ├── MetricCard.vue
│   │   │   │   │   ├── ChartWidget.vue
│   │   │   │   │   └── DataTable.vue
│   │   │   │   ├── stores/                 # Pinia stores
│   │   │   │   │   ├── dashboard.js
│   │   │   │   │   └── metrics.js
│   │   │   │   └── utils/                  # Helper functions
│   │   │   │       ├── chartHelpers.js
│   │   │   │       └── dataTransform.js
│   │   │   └── customer_portal/            # Another feature
│   │   │       ├── CustomerPortal.vue
│   │   │       └── components/
│   │   └── icons/                 # App-specific icons
│   │
│   ├── templates/                  # Jinja2 templates
│   │   ├── __init__.py
│   │   ├── includes/              # Reusable template parts
│   │   └── pages/                 # Page templates
│   │
│   ├── www/                        # Web pages
│   │   ├── __init__.py
│   │   └── api/                   # Web API endpoints
│   │
│   └── [module_name]/              # Business modules
│       ├── __init__.py
│       ├── doctype/               # DocType definitions
│       │   ├── __init__.py
│       │   └── [doctype_name]/
│       │       ├── [doctype_name].json     # DocType schema
│       │       ├── [doctype_name].py       # Controller logic
│       │       ├── [doctype_name].js       # Client-side scripts
│       │       └── test_[doctype_name].py  # Tests
│       ├── page/                  # Custom pages
│       │   ├── __init__.py
│       │   └── [page_name]/
│       │       ├── [page_name].json        # Page definition
│       │       ├── [page_name].py          # Page controller
│       │       └── [page_name].js          # Page initialization
│       ├── report/                # Custom reports
│       ├── workspace/             # Workspace definitions
│       └── api/                   # Module API endpoints
│           ├── __init__.py
│           └── [feature].py       # API methods
│
├── requirements.txt               # Python dependencies
├── setup.py                      # App installation
├── README.md                     # Documentation
└── .gitignore                    # Git ignore rules
```

---

## 📦 BUILD PROCESS (Native Integration)

### **NO Separate Build Required!**
```bash
# ✅ CORRECT: Use Frappe's built-in build
bench build --app myapp

# ✅ Development mode with watch
bench start  # Automatically watches and builds

# ❌ WRONG: Don't use separate frontend build
# npm run build     # NOT NEEDED
# vite build        # NOT NEEDED
```

### **Asset Pipeline Integration**
```python
# myapp/hooks.py
app_include_js = [
    "dashboard.bundle.js",           # Your Vue features
    "customer_portal.bundle.js",
]

app_include_css = [
    "myapp.css"                     # Custom styles
]

# Frappe automatically handles:
# - Vue 3 compilation
# - CSS processing
# - Asset bundling
# - Hot reloading in development
```

---

## 🔄 STATE MANAGEMENT WITH PINIA

### **Store Pattern**
```javascript
// myapp/public/js/dashboard/stores/dashboard.js
import { defineStore } from 'pinia';

export const useDashboardStore = defineStore('dashboard', {
  state: () => ({
    metrics: [],
    loading: false,
    filters: {
      dateRange: 'last_month',
      department: null
    }
  }),

  getters: {
    filteredMetrics: (state) => {
      return state.metrics.filter(metric => {
        // Filter logic using Frappe patterns
        return metric.department === state.filters.department || !state.filters.department;
      });
    }
  },

  actions: {
    async fetchMetrics() {
      this.loading = true;
      
      try {
        const response = await frappe.call({
          method: 'myapp.api.dashboard.get_metrics',
          args: {
            filters: this.filters
          }
        });
        
        this.metrics = response.message;
      } catch (error) {
        frappe.show_alert({
          message: __('Failed to load metrics'),
          indicator: 'red'
        });
      } finally {
        this.loading = false;
      }
    },

    updateFilters(newFilters) {
      this.filters = { ...this.filters, ...newFilters };
      this.fetchMetrics(); // Auto-refresh
    }
  }
});
```

### **Using Store in Components**
```vue
<script setup>
import { useDashboardStore } from '../stores/dashboard.js';
import { computed, onMounted } from 'vue';

const store = useDashboardStore();

// Reactive computed properties
const metrics = computed(() => store.filteredMetrics);
const loading = computed(() => store.loading);

// Actions
function updateDateRange(range) {
  store.updateFilters({ dateRange: range });
}

onMounted(() => {
  store.fetchMetrics();
});
</script>
```

---

## 🎨 RESPONSIVE DESIGN PATTERNS

### **Mobile-First Vue Components**
```vue
<template>
  <div class="responsive-container">
    <!-- Mobile layout -->
    <div class="mobile-layout" v-if="isMobile">
      <div class="mobile-header">
        <h3>{{ title }}</h3>
        <button @click="toggleMenu" class="btn btn-sm">
          {{ showMenu ? '✕' : '☰' }}
        </button>
      </div>
      
      <div v-if="showMenu" class="mobile-menu">
        <slot name="mobile-actions" />
      </div>
      
      <div class="mobile-content">
        <slot name="mobile-content" />
      </div>
    </div>

    <!-- Desktop layout -->
    <div class="desktop-layout" v-else>
      <div class="desktop-header">
        <h2>{{ title }}</h2>
        <div class="desktop-actions">
          <slot name="desktop-actions" />
        </div>
      </div>
      
      <div class="desktop-content">
        <slot name="desktop-content" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';

const props = defineProps({
  title: String
});

const windowWidth = ref(window.innerWidth);
const showMenu = ref(false);

const isMobile = computed(() => windowWidth.value < 768);

function updateWidth() {
  windowWidth.value = window.innerWidth;
}

function toggleMenu() {
  showMenu.value = !showMenu.value;
}

onMounted(() => {
  window.addEventListener('resize', updateWidth);
});

onUnmounted(() => {
  window.removeEventListener('resize', updateWidth);
});
</script>

<style scoped>
.responsive-container {
  width: 100%;
}

/* Mobile styles */
.mobile-layout {
  display: block;
}

.mobile-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem;
  border-bottom: 1px solid var(--border-color);
}

.mobile-menu {
  padding: 0.5rem;
  background: var(--bg-light-gray);
  border-bottom: 1px solid var(--border-color);
}

.mobile-content {
  padding: 0.5rem;
}

/* Desktop styles */
.desktop-layout {
  display: block;
}

.desktop-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border-bottom: 1px solid var(--border-color);
}

.desktop-actions {
  display: flex;
  gap: 0.5rem;
}

.desktop-content {
  padding: 1rem;
}

/* Responsive grid for content */
@media (min-width: 768px) {
  .desktop-content {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 1rem;
  }
}
</style>
```

---

## 🔌 FRAPPE INTEGRATION PATTERNS

### **DocType Integration**
```javascript
// Accessing DocType data in Vue components
async function loadDocTypeData() {
  try {
    // Get single document
    const doc = await frappe.db.get_doc('Customer', 'CUST-001');
    
    // Get multiple documents with filters
    const customers = await frappe.db.get_list('Customer', {
      filters: {
        status: 'Active',
        territory: 'US'
      },
      fields: ['name', 'customer_name', 'email'],
      limit: 20
    });
    
    // Update document
    await frappe.db.set_value('Customer', 'CUST-001', {
      status: 'Inactive',
      notes: 'Updated from Vue component'
    });
    
    return { doc, customers };
  } catch (error) {
    frappe.show_alert({
      message: __('Failed to load data: {0}', [error.message]),
      indicator: 'red'
    });
  }
}
```

### **Permission Integration**
```javascript
// Check permissions in Vue components
function checkPermissions() {
  const canRead = frappe.boot.user.can_read.includes('Customer');
  const canWrite = frappe.boot.user.can_write.includes('Customer');
  const canCreate = frappe.boot.user.can_create.includes('Customer');
  
  // Or use specific permission check
  const hasSpecificPerm = frappe.user.has_role(['Sales Manager', 'System Manager']);
  
  return {
    canRead,
    canWrite, 
    canCreate,
    hasSpecificPerm
  };
}
```

### **Real-time Updates**
```javascript
// Listen for real-time updates
onMounted(() => {
  // Listen for DocType updates
  frappe.realtime.on('doc_update', (data) => {
    if (data.doctype === 'Customer') {
      // Refresh component data
      loadCustomers();
    }
  });
  
  // Custom events
  frappe.realtime.on('dashboard_update', (data) => {
    store.updateMetrics(data.metrics);
  });
});

onUnmounted(() => {
  // Clean up event listeners
  frappe.realtime.off('doc_update');
  frappe.realtime.off('dashboard_update');
});
```

---

## 🧪 TESTING PATTERNS

### **Component Testing**
```javascript
// myapp/public/js/dashboard/tests/Dashboard.test.js
import { mount } from '@vue/test-utils';
import { createPinia, setActivePinia } from 'pinia';
import Dashboard from '../Dashboard.vue';

// Mock Frappe
global.frappe = {
  call: jest.fn(),
  show_alert: jest.fn(),
  __: (text) => text
};

describe('Dashboard Component', () => {
  beforeEach(() => {
    setActivePinia(createPinia());
  });

  it('renders correctly', () => {
    const wrapper = mount(Dashboard);
    expect(wrapper.find('.dashboard-container').exists()).toBe(true);
  });

  it('loads data on mount', async () => {
    frappe.call.mockResolvedValue({
      message: [{ name: 'Test Metric', value: 100 }]
    });

    const wrapper = mount(Dashboard);
    await wrapper.vm.$nextTick();

    expect(frappe.call).toHaveBeenCalledWith({
      method: 'myapp.api.dashboard.get_metrics',
      args: expect.any(Object)
    });
  });
});
```

---

## 📈 PERFORMANCE OPTIMIZATION

### **Code Splitting**
```javascript
// Dynamic imports for large components
const LazyComponent = defineAsyncComponent(() => 
  import('./components/HeavyComponent.vue')
);
```

### **Virtual Scrolling for Large Lists**
```vue
<template>
  <div class="virtual-list">
    <div 
      v-for="item in visibleItems" 
      :key="item.name"
      class="list-item"
    >
      {{ item.customer_name }}
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  items: Array,
  itemHeight: { type: Number, default: 50 },
  containerHeight: { type: Number, default: 400 }
});

const visibleCount = computed(() => 
  Math.ceil(props.containerHeight / props.itemHeight) + 2
);

const visibleItems = computed(() => 
  props.items.slice(0, visibleCount.value)
);
</script>
```

---

## ✅ SUCCESS METRICS

### **Implementation Checklist**
- [ ] ✅ **No /frontend/ directory** created
- [ ] ✅ **Bundle entry points** in public/js/
- [ ] ✅ **Vue components** organized by feature
- [ ] ✅ **Frappe globals** properly injected
- [ ] ✅ **Pinia stores** for state management
- [ ] ✅ **Responsive design** implemented
- [ ] ✅ **frappe.call()** for API communication
- [ ] ✅ **Built using** bench build --app myapp
- [ ] ✅ **Mobile-first** approach followed

### **Performance Targets**
- **First Contentful Paint**: < 1.5s
- **Time to Interactive**: < 3s
- **Bundle Size**: < 500KB per feature
- **Mobile Score**: 90+ on Lighthouse

Remember: **ERPNext v16 has Vue 3 natively integrated. No separate frontend build needed!**