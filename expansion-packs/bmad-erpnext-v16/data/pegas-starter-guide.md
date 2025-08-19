# Pegas Starter Guide for ERPNext v16

## Overview

Pegas is a modern ERPNext application starter template designed for ERPNext v16 with native Vue 3 integration. This guide provides comprehensive instructions for getting started with Pegas to build modern, scalable ERPNext applications quickly and efficiently.

## What is Pegas?

Pegas is a complete starter template that includes:
- **Native Vue 3 Integration**: Built-in Vue 3 SPA capabilities using Frappe's esbuild pipeline
- **Modern UI Components**: Pre-configured Frappe UI component library
- **Best Practice Architecture**: Proven patterns for ERPNext development
- **Complete Toolchain**: Development, testing, and deployment tools
- **Progressive Web App**: PWA capabilities out of the box

## Quick Start

### Prerequisites

Before starting with Pegas, ensure you have:
- Frappe Framework v16+
- ERPNext v16+
- Node.js 16+ (for development tools)
- Python 3.8+
- Git

### Installation Methods

#### Method 1: Using BMAD Agent
```bash
# Activate the app scaffold coordinator
/bmadErpNext:agent:app-scaffold-coordinator

# Request Pegas template setup
"Create a new ERPNext app using the Pegas starter template with Vue 3 SPA architecture"
```

#### Method 2: Manual Installation
```bash
# Navigate to your bench directory
cd /path/to/your/frappe-bench

# Create new app from Pegas template
bench new-app my_pegas_app --template https://github.com/bmad-method/pegas-template

# Install the app
bench --site your-site.local install-app my_pegas_app

# Start development
bench start
```

#### Method 3: Clone and Customize
```bash
# Clone the Pegas template
git clone https://github.com/bmad-method/pegas-template.git my_custom_app

# Initialize as new app
cd my_custom_app
./setup.sh my_custom_app

# Add to bench
bench get-app /path/to/my_custom_app
bench --site your-site.local install-app my_custom_app
```

## Project Structure

### Pegas Application Structure
```
my_pegas_app/
├── my_pegas_app/
│   ├── __init__.py
│   ├── hooks.py                    # App configuration
│   ├── modules.txt                 # Module definitions
│   ├── patches.txt                 # Database patches
│   ├── public/                     # Static assets
│   │   ├── css/
│   │   ├── images/
│   │   └── js/
│   │       ├── dashboard.bundle.js # Main dashboard entry
│   │       ├── dashboard/          # Vue SPA components
│   │       │   ├── DashboardApp.vue
│   │       │   ├── components/
│   │       │   ├── views/
│   │       │   ├── stores/
│   │       │   └── utils/
│   │       └── shared/             # Shared components
│   ├── templates/                  # Jinja templates
│   │   ├── pages/
│   │   └── includes/
│   ├── www/                        # Web pages
│   │   └── dashboard.py           # Page controller
│   ├── core/                       # Core module
│   │   └── doctype/               # DocTypes
│   ├── api/                        # API endpoints
│   │   └── dashboard.py           # API methods
│   └── fixtures/                   # Sample data
├── requirements.txt                # Python dependencies
├── package.json                   # Node.js dependencies (for development)
├── README.md                      # Project documentation
├── license.txt                    # License file
└── setup.py                      # Package setup
```

### Key Directories Explained

#### `/public/js/` - Frontend Assets
- **Bundle files**: Entry points for Vue SPAs
- **Component directories**: Organized Vue components
- **Shared utilities**: Reusable code across features

#### `/api/` - Backend APIs
- **RESTful endpoints**: Whitelisted API methods
- **Business logic**: Core application functionality
- **Data processing**: Complex operations

#### `/core/` - Core Business Logic
- **DocTypes**: Data models and business entities
- **Controllers**: DocType business logic
- **Workflows**: Approval and automation logic

## Development Workflow

### 1. Initial Setup

#### Configure Your App
```python
# hooks.py - Basic configuration
app_name = "my_pegas_app"
app_title = "My Pegas Application"
app_publisher = "Your Company"
app_description = "Modern ERPNext application built with Pegas"
app_icon = "fa fa-rocket"
app_color = "#3b82f6"
app_email = "support@yourcompany.com"
app_license = "MIT"

# Web pages configuration
website_route_rules = [
    {"from_route": "/dashboard/<path:app_path>", "to_route": "dashboard"},
]

# Asset bundles
app_include_js = [
    "dashboard.bundle.js"
]

app_include_css = [
    "dashboard.bundle.css"
]
```

#### Install Dependencies
```bash
# Install Python dependencies
pip install -r requirements.txt

# Install Node.js dependencies (for development)
npm install

# Install the app
bench --site your-site.local install-app my_pegas_app
```

### 2. Create Your First DocType

#### Using the Designer Agent
```bash
/bmadErpNext:agent:doctype-designer
"Create a Customer Profile DocType with fields for contact information, preferences, and relationship tracking"
```

#### Manual Creation
```python
# Create DocType JSON file
{
    "doctype": "DocType",
    "name": "Customer Profile",
    "module": "Core",
    "custom": 0,
    "is_submittable": 0,
    "fields": [
        {
            "fieldname": "customer_name",
            "label": "Customer Name",
            "fieldtype": "Data",
            "reqd": 1
        },
        {
            "fieldname": "email",
            "label": "Email",
            "fieldtype": "Data",
            "options": "Email"
        },
        {
            "fieldname": "phone",
            "label": "Phone",
            "fieldtype": "Data",
            "options": "Phone"
        }
    ],
    "permissions": [
        {
            "role": "System Manager",
            "read": 1,
            "write": 1,
            "create": 1,
            "delete": 1
        }
    ]
}
```

### 3. Build Your Vue SPA

#### Dashboard Entry Point
```javascript
// public/js/dashboard.bundle.js
import { createApp } from "vue";
import DashboardApp from "./dashboard/DashboardApp.vue";
import { createPinia } from "pinia";

class PegasDashboard {
    constructor(wrapper) {
        this.wrapper = wrapper;
        this.page = wrapper.page;
        this.setupPage();
        this.mountApp();
    }
    
    setupPage() {
        this.page.set_title(__("Dashboard"));
        
        // Add page actions
        this.page.set_primary_action(__("New Customer"), () => {
            this.createCustomer();
        });
        
        this.page.add_action_item(__("Export Data"), () => {
            this.exportData();
        });
    }
    
    mountApp() {
        // Create Vue app
        const app = createApp(DashboardApp);
        
        // CRITICAL: Set up Frappe globals
        SetVueGlobals(app);
        
        // Add state management
        const pinia = createPinia();
        app.use(pinia);
        
        // Provide Frappe context
        app.provide('frappeContext', {
            page: this.page,
            wrapper: this.wrapper
        });
        
        // Mount the app
        this.vueApp = app.mount(this.wrapper.get(0));
    }
    
    createCustomer() {
        this.vueApp.showCreateCustomerDialog();
    }
    
    exportData() {
        this.vueApp.exportDashboardData();
    }
}

// Register with Frappe
frappe.pages["dashboard"].on_page_load = function(wrapper) {
    frappe.require("dashboard.bundle.js").then(() => {
        new PegasDashboard(wrapper);
    });
};
```

#### Main Vue Component
```vue
<!-- public/js/dashboard/DashboardApp.vue -->
<template>
  <div class="pegas-dashboard">
    <!-- Navigation Tabs -->
    <div class="mb-6">
      <nav class="flex space-x-1 border-b border-gray-200">
        <button
          v-for="tab in tabs"
          :key="tab.id"
          :class="[
            'px-3 py-2 text-sm font-medium border-b-2',
            activeTab === tab.id
              ? 'border-blue-500 text-blue-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          ]"
          @click="activeTab = tab.id"
        >
          {{ __(tab.label) }}
        </button>
      </nav>
    </div>
    
    <!-- Tab Content -->
    <div class="tab-content">
      <component
        :is="currentTabComponent"
        :key="activeTab"
        @action="handleAction"
        @navigate="handleNavigation"
      />
    </div>
    
    <!-- Global Modals -->
    <CreateCustomerDialog
      v-if="showCreateDialog"
      @close="showCreateDialog = false"
      @created="handleCustomerCreated"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, inject } from 'vue'
import { useDashboardStore } from './stores/dashboardStore'

// Components
import OverviewTab from './views/OverviewTab.vue'
import CustomersTab from './views/CustomersTab.vue'
import AnalyticsTab from './views/AnalyticsTab.vue'
import CreateCustomerDialog from './components/CreateCustomerDialog.vue'

// Frappe context
const frappeContext = inject('frappeContext')

// Store
const dashboardStore = useDashboardStore()

// Local state
const activeTab = ref('overview')
const showCreateDialog = ref(false)

const tabs = [
  { id: 'overview', label: 'Overview', component: 'OverviewTab' },
  { id: 'customers', label: 'Customers', component: 'CustomersTab' },
  { id: 'analytics', label: 'Analytics', component: 'AnalyticsTab' }
]

const currentTabComponent = computed(() => {
  const tab = tabs.find(t => t.id === activeTab.value)
  return tab?.component
})

// Methods
function handleAction(action) {
  switch (action.type) {
    case 'create_customer':
      showCreateDialog.value = true
      break
    case 'show_notification':
      frappe.show_alert(action.message)
      break
  }
}

function handleNavigation(tab) {
  activeTab.value = tab
}

function handleCustomerCreated(customer) {
  showCreateDialog.value = false
  dashboardStore.addCustomer(customer)
  frappe.show_alert(__('Customer created successfully'))
}

// Expose methods to parent class
function showCreateCustomerDialog() {
  showCreateDialog.value = true
}

function exportDashboardData() {
  dashboardStore.exportData()
}

// Lifecycle
onMounted(async () => {
  await dashboardStore.initialize()
})

// Expose methods
defineExpose({
  showCreateCustomerDialog,
  exportDashboardData
})
</script>

<style scoped>
.pegas-dashboard {
  padding: 1.5rem;
  max-width: 1200px;
  margin: 0 auto;
}
</style>
```

### 4. State Management with Pinia

#### Dashboard Store
```javascript
// public/js/dashboard/stores/dashboardStore.js
import { defineStore } from 'pinia'

export const useDashboardStore = defineStore('dashboard', {
  state: () => ({
    customers: [],
    analytics: {},
    loading: false,
    error: null
  }),
  
  getters: {
    customerCount: (state) => state.customers.length,
    activeCustomers: (state) => state.customers.filter(c => c.status === 'Active'),
    recentCustomers: (state) => state.customers.slice(0, 5)
  },
  
  actions: {
    async initialize() {
      this.loading = true
      try {
        await Promise.all([
          this.loadCustomers(),
          this.loadAnalytics()
        ])
      } catch (error) {
        this.error = error.message
        frappe.show_alert(__('Error loading dashboard data'))
      } finally {
        this.loading = false
      }
    },
    
    async loadCustomers() {
      try {
        const response = await frappe.call({
          method: 'my_pegas_app.api.dashboard.get_customers',
          args: {
            limit: 100
          }
        })
        this.customers = response.message || []
      } catch (error) {
        console.error('Error loading customers:', error)
        throw error
      }
    },
    
    async loadAnalytics() {
      try {
        const response = await frappe.call({
          method: 'my_pegas_app.api.dashboard.get_analytics'
        })
        this.analytics = response.message || {}
      } catch (error) {
        console.error('Error loading analytics:', error)
        throw error
      }
    },
    
    async addCustomer(customer) {
      try {
        const response = await frappe.call({
          method: 'my_pegas_app.api.dashboard.create_customer',
          args: customer
        })
        
        if (response.message) {
          this.customers.unshift(response.message)
          return response.message
        }
      } catch (error) {
        frappe.show_alert(__('Error creating customer'))
        throw error
      }
    },
    
    exportData() {
      const data = this.customers.map(customer => ({
        'Customer Name': customer.customer_name,
        'Email': customer.email,
        'Phone': customer.phone,
        'Status': customer.status,
        'Created': customer.creation
      }))
      
      frappe.tools.downloadify(data, null, 'customers')
    }
  }
})
```

### 5. API Development

#### Backend API Endpoints
```python
# api/dashboard.py
import frappe
from frappe import _

@frappe.whitelist()
def get_customers(limit=20):
    """Get customer list for dashboard"""
    try:
        customers = frappe.get_all(
            "Customer Profile",
            fields=["name", "customer_name", "email", "phone", "status", "creation"],
            limit=int(limit),
            order_by="creation desc"
        )
        
        return {
            "success": True,
            "data": customers,
            "total": len(customers)
        }
    except Exception as e:
        frappe.log_error(message=str(e), title="Dashboard API Error")
        frappe.throw(_("Error fetching customers: {0}").format(str(e)))

@frappe.whitelist()
def get_analytics():
    """Get dashboard analytics data"""
    try:
        # Customer analytics
        total_customers = frappe.db.count("Customer Profile")
        active_customers = frappe.db.count("Customer Profile", {"status": "Active"})
        
        # Recent activity
        recent_customers = frappe.db.count(
            "Customer Profile", 
            {"creation": (">=", frappe.utils.add_days(frappe.utils.today(), -30))}
        )
        
        return {
            "success": True,
            "data": {
                "total_customers": total_customers,
                "active_customers": active_customers,
                "recent_customers": recent_customers,
                "growth_rate": calculate_growth_rate()
            }
        }
    except Exception as e:
        frappe.log_error(message=str(e), title="Analytics API Error")
        frappe.throw(_("Error fetching analytics: {0}").format(str(e)))

@frappe.whitelist()
def create_customer(**kwargs):
    """Create new customer"""
    if not frappe.has_permission("Customer Profile", "create"):
        frappe.throw(_("Insufficient permissions"), frappe.PermissionError)
    
    try:
        # Validate required fields
        if not kwargs.get("customer_name"):
            frappe.throw(_("Customer name is required"))
        
        # Create customer document
        customer = frappe.get_doc({
            "doctype": "Customer Profile",
            "customer_name": kwargs.get("customer_name"),
            "email": kwargs.get("email"),
            "phone": kwargs.get("phone"),
            "status": "Active"
        })
        
        customer.insert()
        
        return {
            "success": True,
            "data": customer.as_dict(),
            "message": _("Customer created successfully")
        }
    except Exception as e:
        frappe.log_error(message=str(e), title="Customer Creation Error")
        frappe.throw(_("Error creating customer: {0}").format(str(e)))

def calculate_growth_rate():
    """Calculate customer growth rate"""
    try:
        current_month = frappe.db.count(
            "Customer Profile",
            {"creation": (">=", frappe.utils.get_first_day())}
        )
        
        last_month = frappe.db.count(
            "Customer Profile",
            {
                "creation": (">=", frappe.utils.add_months(frappe.utils.get_first_day(), -1)),
                "creation": ("<", frappe.utils.get_first_day())
            }
        )
        
        if last_month > 0:
            growth_rate = ((current_month - last_month) / last_month) * 100
        else:
            growth_rate = 100 if current_month > 0 else 0
            
        return round(growth_rate, 2)
    except Exception:
        return 0
```

## Advanced Features

### Progressive Web App (PWA)

#### Service Worker Configuration
```javascript
// public/sw.js - Service Worker
const CACHE_NAME = 'pegas-app-v1'
const OFFLINE_URLS = [
    '/dashboard',
    '/assets/css/dashboard.bundle.css',
    '/assets/js/dashboard.bundle.js'
]

self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => cache.addAll(OFFLINE_URLS))
    )
})

self.addEventListener('fetch', event => {
    event.respondWith(
        caches.match(event.request)
            .then(response => response || fetch(event.request))
    )
})
```

#### PWA Manifest
```json
{
    "name": "My Pegas App",
    "short_name": "Pegas",
    "description": "Modern ERPNext application",
    "start_url": "/dashboard",
    "display": "standalone",
    "background_color": "#ffffff",
    "theme_color": "#3b82f6",
    "icons": [
        {
            "src": "/assets/images/icon-192.png",
            "sizes": "192x192",
            "type": "image/png"
        },
        {
            "src": "/assets/images/icon-512.png",
            "sizes": "512x512",
            "type": "image/png"
        }
    ]
}
```

### Testing Strategy

#### Unit Tests
```javascript
// tests/components/DashboardApp.test.js
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import DashboardApp from '@/dashboard/DashboardApp.vue'

describe('DashboardApp', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    
    // Mock Frappe globals
    global.frappe = {
      call: vi.fn(),
      show_alert: vi.fn(),
      __: (text) => text
    }
  })
  
  it('renders dashboard tabs', () => {
    const wrapper = mount(DashboardApp, {
      global: {
        provide: {
          frappeContext: { page: {}, wrapper: {} }
        }
      }
    })
    
    expect(wrapper.find('[data-test="overview-tab"]').exists()).toBe(true)
    expect(wrapper.find('[data-test="customers-tab"]').exists()).toBe(true)
  })
  
  it('handles tab navigation', async () => {
    const wrapper = mount(DashboardApp)
    
    await wrapper.find('[data-test="customers-tab"]').trigger('click')
    
    expect(wrapper.vm.activeTab).toBe('customers')
  })
})
```

#### Integration Tests
```python
# tests/test_dashboard_api.py
import frappe
import unittest
from my_pegas_app.api.dashboard import get_customers, create_customer

class TestDashboardAPI(unittest.TestCase):
    def setUp(self):
        frappe.set_user("Administrator")
    
    def test_get_customers(self):
        """Test getting customer list"""
        result = get_customers(limit=10)
        
        self.assertTrue(result.get("success"))
        self.assertIsInstance(result.get("data"), list)
    
    def test_create_customer(self):
        """Test creating new customer"""
        customer_data = {
            "customer_name": "Test Customer",
            "email": "test@example.com",
            "phone": "+1234567890"
        }
        
        result = create_customer(**customer_data)
        
        self.assertTrue(result.get("success"))
        self.assertEqual(result["data"]["customer_name"], "Test Customer")
        
        # Cleanup
        frappe.delete_doc("Customer Profile", result["data"]["name"])
```

## Deployment Guide

### Production Build
```bash
# Build assets for production
bench build --app my_pegas_app

# Run database migrations
bench --site your-site.local migrate

# Clear cache
bench --site your-site.local clear-cache

# Restart services (if needed)
sudo service nginx reload
sudo supervisorctl restart all
```

### Environment Configuration
```python
# production_settings.py
import frappe

# Production-specific settings
if frappe.conf.get("environment") == "production":
    # Enable compression
    frappe.conf.compress_css = True
    frappe.conf.compress_js = True
    
    # Cache settings
    frappe.conf.redis_cache = "redis://localhost:6379/0"
    
    # Logging
    frappe.conf.log_level = "INFO"
```

## Best Practices

### Code Organization
1. **Modular Structure**: Organize code into logical modules
2. **Component Reusability**: Create reusable Vue components
3. **State Management**: Use Pinia for complex state
4. **API Design**: Follow RESTful patterns
5. **Error Handling**: Implement comprehensive error handling

### Performance Optimization
1. **Lazy Loading**: Load components on demand
2. **Code Splitting**: Split bundles by feature
3. **Caching**: Implement appropriate caching strategies
4. **Bundle Size**: Monitor and optimize bundle sizes

### Security Considerations
1. **Input Validation**: Validate all user inputs
2. **Permission Checks**: Verify permissions on all operations
3. **Data Sanitization**: Sanitize data before processing
4. **HTTPS**: Use HTTPS in production

## Troubleshooting

### Common Issues

#### Build Errors
```bash
# Clear build cache
rm -rf node_modules/.cache
npm run build

# Check for missing dependencies
npm install
```

#### API Errors
```python
# Check server logs
bench --site your-site.local console
>>> frappe.get_all("Error Log", limit=5)
```

#### Performance Issues
```bash
# Profile application
bench --site your-site.local console
>>> frappe.db.sql("SHOW PROCESSLIST")
```

## Support and Resources

### Documentation
- [Frappe Framework Documentation](https://frappeframework.com/docs)
- [ERPNext Documentation](https://docs.erpnext.com)
- [Vue 3 Documentation](https://vuejs.org/guide/)

### Community
- [Frappe Community Forum](https://discuss.frappe.io)
- [BMAD Method Discord](https://discord.gg/bmad-method)
- [GitHub Discussions](https://github.com/bmad-method/pegas-template/discussions)

### BMAD Agents
- App Scaffold Coordinator: `/bmadErpNext:agent:app-scaffold-coordinator`
- Vue SPA Architect: `/bmadErpNext:agent:vue-spa-architect`
- API Architect: `/bmadErpNext:agent:api-architect`
- DocType Designer: `/bmadErpNext:agent:doctype-designer`

---

Pegas provides a solid foundation for building modern ERPNext applications with Vue 3 and follows all Frappe best practices while providing modern development experience.