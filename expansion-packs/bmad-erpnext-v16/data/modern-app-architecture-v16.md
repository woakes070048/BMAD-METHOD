# Modern ERPNext App Architecture v16
## Comprehensive Guide Based on Frappe/ERPNext Source Analysis

**Last Updated**: 2025-08-17  
**Framework Version**: Frappe Framework 15+ | ERPNext 16  
**Source Analysis**: Frappe core, ERPNext core, Otto repository patterns  
**Purpose**: Define modern architecture patterns for ERPNext applications with NATIVE Vue 3 integration

---

## 🚨 CRITICAL: ERPNext v16 ARCHITECTURE CHANGES

**NO SEPARATE FRONTEND** - ERPNext v16 has **NATIVE Vue 3 integration**

### ❌ **OLD ARCHITECTURE (Don't use)**
```
app_name/
├── backend/                # ❌ Remove
├── frontend/               # ❌ Remove - No longer needed!
│   ├── src/
│   ├── vite.config.js
│   └── package.json
```

### ✅ **NEW ARCHITECTURE (Use this)**
```
app_name/                   # Created by bench new-app
├── app_name/               # Main app package
│   ├── public/             # Static assets integrated with Frappe
│   │   └── js/            # Vue components + bundle entries
│   ├── [module]/          # Business modules
│   │   ├── doctype/       # Business entities
│   │   ├── page/          # Custom pages
│   │   └── api/           # API endpoints
│   └── hooks.py           # App configuration
├── requirements.txt
└── setup.py
```

---

## 🏗️ NATIVE INTEGRATION ARCHITECTURE

### **Component Organization Pattern**
```
app_name/public/js/
├── dashboard.bundle.js              # Feature entry point
├── customer_portal.bundle.js        # Another feature
├── shared/                          # Shared utilities
│   ├── api.js                      # API helpers
│   ├── utils.js                    # Common utilities
│   └── constants.js                # App constants
├── dashboard/                       # Feature-specific components
│   ├── Dashboard.vue               # Main component
│   ├── components/                 # Sub-components
│   │   ├── MetricCard.vue
│   │   ├── SalesChart.vue
│   │   └── ActivityFeed.vue
│   ├── stores/                     # Pinia stores
│   │   ├── dashboard.js
│   │   └── metrics.js
│   └── utils/                      # Feature utilities
│       ├── chartHelpers.js
│       └── dataTransform.js
└── customer_portal/                # Another feature
    ├── CustomerPortal.vue
    ├── components/
    └── stores/
```

### **Bundle Entry Point Architecture**
```javascript
// app_name/public/js/dashboard.bundle.js
import { createApp } from "vue";
import { createPinia } from "pinia";
import Dashboard from "./dashboard/Dashboard.vue";

class DashboardApp {
    constructor({ wrapper, page, options = {} }) {
        this.$wrapper = $(wrapper);
        this.page = page;
        this.options = options;
        this.init();
    }

    init() {
        // Setup Frappe page integration
        this.setupPageActions();
        this.setupApp();
        this.setupRealtime();
    }

    setupPageActions() {
        this.page.set_title(__("Dashboard"));
        
        // Primary actions
        this.page.set_primary_action(__("Refresh"), () => {
            this.$component.refresh();
        });

        // Menu actions
        this.page.add_menu_item(__("Export"), () => {
            this.$component.exportData();
        });

        this.page.add_menu_item(__("Settings"), () => {
            this.$component.openSettings();
        });
    }

    setupApp() {
        const app = createApp(Dashboard, {
            ...this.options
        });

        // Critical: Setup Frappe integration
        this.setupFrappeIntegration(app);

        // State management
        const pinia = createPinia();
        app.use(pinia);

        // Mount to Frappe page wrapper
        this.$component = app.mount(this.$wrapper.get(0));
    }

    setupFrappeIntegration(app) {
        // Make Frappe available globally in Vue
        app.config.globalProperties.$frappe = frappe;
        app.config.globalProperties.$__ = __;
        app.config.globalProperties.$router = {
            push: (route) => frappe.set_route(...route.split('/'))
        };

        // Provide Frappe services
        app.provide('frappe', frappe);
        app.provide('call', frappe.call);
        app.provide('db', frappe.db);
        app.provide('request', frappe.request);
    }

    setupRealtime() {
        // Real-time updates
        frappe.realtime.on('dashboard_update', (data) => {
            if (this.$component && this.$component.handleRealtimeUpdate) {
                this.$component.handleRealtimeUpdate(data);
            }
        });
    }
}

// Register with Frappe page system
frappe.pages["dashboard"].on_page_load = function(wrapper) {
    frappe.require("dashboard.bundle.js").then(() => {
        new DashboardApp({ 
            wrapper, 
            page: wrapper.page,
            options: frappe.route_options || {}
        });
    });
};

// Export for direct usage
frappe.provide("frappe.ui");
frappe.ui.DashboardApp = DashboardApp;
```

---

## 📊 STATE MANAGEMENT ARCHITECTURE

### **Pinia Store Pattern (Frappe-Integrated)**
```javascript
// app_name/public/js/dashboard/stores/dashboard.js
import { defineStore } from 'pinia';

export const useDashboardStore = defineStore('dashboard', {
    state: () => ({
        // Data state
        metrics: [],
        charts: [],
        activities: [],
        
        // UI state
        loading: {
            metrics: false,
            charts: false,
            activities: false
        },
        
        // Filters
        filters: {
            dateRange: 'last_month',
            department: null,
            territory: null
        },

        // Cache
        cache: new Map(),
        lastUpdated: null
    }),

    getters: {
        // Computed metrics
        totalRevenue: (state) => 
            state.metrics.reduce((sum, m) => sum + (m.revenue || 0), 0),
        
        // Filtered data
        filteredCharts: (state) => {
            return state.charts.filter(chart => {
                if (state.filters.department && chart.department !== state.filters.department) return false;
                if (state.filters.territory && chart.territory !== state.filters.territory) return false;
                return true;
            });
        },

        // Loading states
        isLoading: (state) => 
            Object.values(state.loading).some(Boolean),
        
        // Cache utilities
        getCachedData: (state) => (key) => state.cache.get(key)
    },

    actions: {
        // Data fetching
        async fetchMetrics(refresh = false) {
            const cacheKey = `metrics_${JSON.stringify(this.filters)}`;
            
            if (!refresh && this.cache.has(cacheKey)) {
                this.metrics = this.cache.get(cacheKey);
                return;
            }

            this.loading.metrics = true;
            
            try {
                const response = await frappe.call({
                    method: 'app_name.api.dashboard.get_metrics',
                    args: {
                        filters: this.filters,
                        fields: ['name', 'value', 'change', 'department', 'territory']
                    }
                });
                
                this.metrics = response.message || [];
                this.cache.set(cacheKey, this.metrics);
                this.lastUpdated = new Date();
                
            } catch (error) {
                frappe.show_alert({
                    message: __('Failed to load metrics: {0}', [error.message]),
                    indicator: 'red'
                });
            } finally {
                this.loading.metrics = false;
            }
        },

        async fetchCharts() {
            this.loading.charts = true;
            
            try {
                const response = await frappe.call({
                    method: 'app_name.api.dashboard.get_charts',
                    args: { filters: this.filters }
                });
                
                this.charts = response.message || [];
                
            } catch (error) {
                console.error('Failed to load charts:', error);
            } finally {
                this.loading.charts = false;
            }
        },

        // Real-time updates
        handleRealtimeUpdate(data) {
            switch (data.type) {
                case 'metric_update':
                    this.updateMetric(data.metric);
                    break;
                case 'new_activity':
                    this.activities.unshift(data.activity);
                    break;
            }
        },

        updateMetric(updatedMetric) {
            const index = this.metrics.findIndex(m => m.name === updatedMetric.name);
            if (index !== -1) {
                this.metrics[index] = { ...this.metrics[index], ...updatedMetric };
            }
        },

        // Filter actions
        updateFilters(newFilters) {
            this.filters = { ...this.filters, ...newFilters };
            // Clear related cache
            this.clearFilterCache();
            // Refetch data
            this.fetchMetrics(true);
            this.fetchCharts();
        },

        clearFilterCache() {
            for (const key of this.cache.keys()) {
                if (key.startsWith('metrics_')) {
                    this.cache.delete(key);
                }
            }
        },

        // Cache management
        clearCache() {
            this.cache.clear();
        }
    }
});
```

---

## 🎨 COMPONENT ARCHITECTURE PATTERNS

### **Main Dashboard Component**
```vue
<!-- app_name/public/js/dashboard/Dashboard.vue -->
<template>
  <div class="dashboard-container">
    <!-- Header Section -->
    <DashboardHeader 
      :title="__('Dashboard')"
      :filters="store.filters"
      :loading="store.isLoading"
      @update-filters="handleFiltersUpdate"
      @refresh="handleRefresh"
    />

    <!-- Metrics Section -->
    <MetricsGrid 
      :metrics="store.metrics"
      :loading="store.loading.metrics"
      class="dashboard-metrics"
    />

    <!-- Charts Section -->
    <ChartsGrid 
      :charts="store.filteredCharts"
      :loading="store.loading.charts"
      class="dashboard-charts"
    />

    <!-- Activity Feed -->
    <ActivityFeed 
      :activities="store.activities"
      :loading="store.loading.activities"
      class="dashboard-activity"
    />
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, defineExpose } from 'vue';
import { useDashboardStore } from './stores/dashboard.js';

// Components
import DashboardHeader from './components/DashboardHeader.vue';
import MetricsGrid from './components/MetricsGrid.vue';
import ChartsGrid from './components/ChartsGrid.vue';
import ActivityFeed from './components/ActivityFeed.vue';

// Store
const store = useDashboardStore();

// Methods
async function initialize() {
  await Promise.all([
    store.fetchMetrics(),
    store.fetchCharts(),
    store.fetchActivities()
  ]);
}

function handleFiltersUpdate(filters) {
  store.updateFilters(filters);
}

function handleRefresh() {
  store.fetchMetrics(true);
  store.fetchCharts();
}

function handleRealtimeUpdate(data) {
  store.handleRealtimeUpdate(data);
}

function exportData() {
  frappe.call({
    method: 'app_name.api.dashboard.export_data',
    args: { filters: store.filters },
    callback: (r) => {
      if (r.message) {
        // Download file
        window.open(r.message.url);
      }
    }
  });
}

function openSettings() {
  frappe.set_route('Form', 'Dashboard Settings', 'Dashboard Settings');
}

// Lifecycle
onMounted(() => {
  initialize();
});

onUnmounted(() => {
  store.clearCache();
});

// Expose methods for parent component access
defineExpose({
  refresh: handleRefresh,
  handleRealtimeUpdate,
  exportData,
  openSettings
});
</script>

<style scoped>
.dashboard-container {
  display: grid;
  gap: 1rem;
  padding: 1rem;
  max-width: 100%;
}

.dashboard-metrics {
  grid-area: metrics;
}

.dashboard-charts {
  grid-area: charts;
}

.dashboard-activity {
  grid-area: activity;
}

/* Responsive grid layouts */
@media (min-width: 768px) {
  .dashboard-container {
    grid-template-areas:
      "header header"
      "metrics activity"
      "charts activity";
    grid-template-columns: 2fr 1fr;
  }
}

@media (min-width: 1200px) {
  .dashboard-container {
    grid-template-areas:
      "header header header"
      "metrics metrics activity"
      "charts charts activity";
    grid-template-columns: 2fr 1fr 1fr;
  }
}
</style>
```

---

## 🔌 API INTEGRATION ARCHITECTURE

### **Backend API Structure**
```python
# app_name/app_name/api/dashboard.py
import frappe
from frappe import _

@frappe.whitelist()
def get_metrics(filters=None, fields=None):
    """Get dashboard metrics with filters"""
    
    filters = frappe.parse_json(filters) if filters else {}
    fields = frappe.parse_json(fields) if fields else ['*']
    
    # Validate permissions
    if not frappe.has_permission('Dashboard', 'read'):
        frappe.throw(_('Insufficient permissions'), frappe.PermissionError)
    
    try:
        # Build query based on filters
        conditions = []
        values = {}
        
        if filters.get('date_range'):
            date_condition, date_values = build_date_filter(filters['date_range'])
            conditions.append(date_condition)
            values.update(date_values)
        
        if filters.get('department'):
            conditions.append('department = %(department)s')
            values['department'] = filters['department']
        
        where_clause = ' AND '.join(conditions) if conditions else '1=1'
        
        # Execute query
        metrics = frappe.db.sql(f"""
            SELECT {', '.join(fields)}
            FROM `tabDashboard Metric`
            WHERE {where_clause}
            ORDER BY display_order ASC
        """, values, as_dict=True)
        
        # Process metrics
        for metric in metrics:
            metric['formatted_value'] = format_metric_value(metric)
            metric['change_indicator'] = calculate_change_indicator(metric)
        
        return metrics
        
    except Exception as e:
        frappe.log_error(f"Dashboard metrics fetch failed: {str(e)}")
        frappe.throw(_('Failed to fetch metrics'))

@frappe.whitelist()
def get_charts(filters=None):
    """Get dashboard charts data"""
    
    filters = frappe.parse_json(filters) if filters else {}
    
    try:
        charts = []
        
        # Revenue chart
        revenue_data = get_revenue_chart_data(filters)
        charts.append({
            'name': 'revenue_trend',
            'title': _('Revenue Trend'),
            'type': 'line',
            'data': revenue_data
        })
        
        # Sales by territory
        territory_data = get_territory_chart_data(filters)
        charts.append({
            'name': 'sales_by_territory',
            'title': _('Sales by Territory'),
            'type': 'bar',
            'data': territory_data
        })
        
        return charts
        
    except Exception as e:
        frappe.log_error(f"Dashboard charts fetch failed: {str(e)}")
        frappe.throw(_('Failed to fetch charts'))

def build_date_filter(date_range):
    """Build date filter conditions"""
    from frappe.utils import add_days, today, getdate
    
    end_date = today()
    
    if date_range == 'last_week':
        start_date = add_days(end_date, -7)
    elif date_range == 'last_month':
        start_date = add_days(end_date, -30)
    elif date_range == 'last_quarter':
        start_date = add_days(end_date, -90)
    else:
        start_date = add_days(end_date, -30)  # default to last month
    
    condition = 'date BETWEEN %(start_date)s AND %(end_date)s'
    values = {
        'start_date': start_date,
        'end_date': end_date
    }
    
    return condition, values

def format_metric_value(metric):
    """Format metric value for display"""
    value = metric.get('value', 0)
    
    if metric.get('type') == 'currency':
        return frappe.utils.fmt_money(value)
    elif metric.get('type') == 'percentage':
        return f"{value:.1f}%"
    elif metric.get('type') == 'number':
        return frappe.utils.comma_and(value)
    
    return str(value)
```

### **Frontend API Service**
```javascript
// app_name/public/js/shared/api.js
class DashboardAPI {
    constructor() {
        this.baseUrl = '/api/method/app_name.api.dashboard';
    }

    async getMetrics(filters = {}, fields = null) {
        try {
            const response = await frappe.call({
                method: `${this.baseUrl}.get_metrics`,
                args: { 
                    filters: JSON.stringify(filters),
                    fields: fields ? JSON.stringify(fields) : null
                }
            });
            
            return response.message || [];
        } catch (error) {
            console.error('API Error - getMetrics:', error);
            throw new Error(`Failed to fetch metrics: ${error.message}`);
        }
    }

    async getCharts(filters = {}) {
        try {
            const response = await frappe.call({
                method: `${this.baseUrl}.get_charts`,
                args: { filters: JSON.stringify(filters) }
            });
            
            return response.message || [];
        } catch (error) {
            console.error('API Error - getCharts:', error);
            throw new Error(`Failed to fetch charts: ${error.message}`);
        }
    }

    async exportData(filters = {}) {
        try {
            const response = await frappe.call({
                method: `${this.baseUrl}.export_data`,
                args: { filters: JSON.stringify(filters) }
            });
            
            return response.message;
        } catch (error) {
            console.error('API Error - exportData:', error);
            throw new Error(`Failed to export data: ${error.message}`);
        }
    }

    // Real-time subscription
    subscribeToUpdates(callback) {
        frappe.realtime.on('dashboard_update', callback);
        
        return () => {
            frappe.realtime.off('dashboard_update', callback);
        };
    }
}

// Export singleton instance
export const dashboardAPI = new DashboardAPI();
```

---

## 🏗️ BUILD & DEPLOYMENT ARCHITECTURE

### **Build Integration with Frappe**
```python
# app_name/hooks.py
app_name = "app_name"
app_title = "App Name"
app_publisher = "Your Company"
app_description = "Modern ERPNext App"
app_email = "dev@yourcompany.com"
app_license = "MIT"

# Build configuration
app_include_js = [
    # Vue bundle entries
    "dashboard.bundle.js",
    "customer_portal.bundle.js",
    "reports.bundle.js"
]

app_include_css = [
    "app_name.css"
]

# Page definitions
website_route_rules = [
    {"from_route": "/app/<path:app_path>", "to_route": "app"},
]

# Real-time events
doc_events = {
    "Dashboard Metric": {
        "after_insert": "app_name.realtime.broadcast_metric_update",
        "on_update": "app_name.realtime.broadcast_metric_update",
    }
}
```

### **Development Workflow**
```bash
# ✅ CORRECT: Use Frappe's integrated build
bench build --app app_name

# Development with hot reload
bench start

# Production build
bench build --app app_name --production

# ❌ WRONG: Don't use separate build processes
# npm run build        # Not needed
# vite build          # Not needed
```

---

## 📱 RESPONSIVE ARCHITECTURE

### **Mobile-First Component Design**
```vue
<template>
  <div class="responsive-component">
    <!-- Mobile layout -->
    <div v-if="isMobile" class="mobile-layout">
      <div class="mobile-header">
        <h3>{{ title }}</h3>
        <button @click="toggleMenu" class="mobile-menu-btn">
          <i :class="showMenu ? 'fa fa-times' : 'fa fa-bars'"></i>
        </button>
      </div>
      
      <Transition name="slide-down">
        <div v-if="showMenu" class="mobile-menu">
          <slot name="mobile-actions" />
        </div>
      </Transition>
      
      <div class="mobile-content">
        <slot name="mobile-content" />
      </div>
    </div>

    <!-- Desktop layout -->
    <div v-else class="desktop-layout">
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
  title: { type: String, required: true }
});

// Responsive state
const windowWidth = ref(window.innerWidth);
const showMenu = ref(false);

const isMobile = computed(() => windowWidth.value < 768);

// Event handlers
function updateWidth() {
  windowWidth.value = window.innerWidth;
  if (!isMobile.value) {
    showMenu.value = false;
  }
}

function toggleMenu() {
  showMenu.value = !showMenu.value;
}

// Lifecycle
onMounted(() => {
  window.addEventListener('resize', updateWidth);
});

onUnmounted(() => {
  window.removeEventListener('resize', updateWidth);
});
</script>

<style scoped>
/* Mobile styles */
.mobile-layout {
  display: block;
}

.mobile-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 1rem;
  background: var(--bg-color);
  border-bottom: 1px solid var(--border-color);
}

.mobile-menu-btn {
  background: none;
  border: none;
  font-size: 1.25rem;
  color: var(--text-color);
  cursor: pointer;
}

.mobile-menu {
  padding: 1rem;
  background: var(--bg-light);
  border-bottom: 1px solid var(--border-color);
}

.mobile-content {
  padding: 1rem;
}

/* Desktop styles */
.desktop-layout {
  display: block;
}

.desktop-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 2rem;
  background: var(--bg-color);
  border-bottom: 1px solid var(--border-color);
}

.desktop-actions {
  display: flex;
  gap: 0.75rem;
}

.desktop-content {
  padding: 2rem;
}

/* Transitions */
.slide-down-enter-active,
.slide-down-leave-active {
  transition: all 0.3s ease;
}

.slide-down-enter-from,
.slide-down-leave-to {
  transform: translateY(-100%);
  opacity: 0;
}
</style>
```

---

## ✅ SUCCESS METRICS & VALIDATION

### **Architecture Compliance Checklist**
- [ ] ✅ **No /frontend/ directory** - Using native Vue integration
- [ ] ✅ **Bundle entry points** in public/js/ directory
- [ ] ✅ **Frappe page integration** implemented
- [ ] ✅ **Pinia state management** configured
- [ ] ✅ **API methods whitelisted** and secured
- [ ] ✅ **Real-time updates** integrated
- [ ] ✅ **Mobile-responsive** components
- [ ] ✅ **Build using bench** command only
- [ ] ✅ **Frappe globals** properly injected
- [ ] ✅ **Error handling** implemented
- [ ] ✅ **Performance optimized** (lazy loading, caching)

### **Performance Targets**
- **First Load**: < 2 seconds
- **Bundle Size**: < 500KB per feature
- **Mobile Performance**: 90+ Lighthouse score
- **API Response**: < 200ms average
- **Memory Usage**: < 100MB for complex features

### **Quality Gates**
- **Test Coverage**: 80%+ unit tests
- **Type Safety**: Full TypeScript adoption
- **Accessibility**: WCAG 2.1 AA compliance
- **Browser Support**: Modern browsers (ES2020+)

Remember: **ERPNext v16 provides native Vue 3 integration. No separate frontend build or configuration needed!**