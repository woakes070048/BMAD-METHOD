# Vue SPA Architecture for ERPNext v16

## Overview

This guide outlines the architectural patterns and best practices for building Vue.js Single Page Applications (SPAs) within ERPNext v16 using Frappe's native asset pipeline. This architecture ensures optimal performance, maintainability, and seamless integration with Frappe Framework.

## Core Architecture Principles

### 1. Native Frappe Integration
- Use Frappe's built-in esbuild pipeline
- Leverage Frappe's asset bundling system
- Integrate with Frappe's authentication and permission system
- Utilize Frappe's routing and page management

### 2. Component-Based Architecture
- Modular component design
- Reusable UI components
- Clear component hierarchy
- Separation of concerns

### 3. State Management Strategy
- Local state for component-specific data
- Pinia for global application state
- Frappe's built-in state for DocType operations
- Real-time state synchronization

## Application Architecture Layers

### Layer 1: Framework Integration

#### Frappe Bundle Integration
```javascript
// Bundle entry point pattern
// [app_name]/public/js/[feature].bundle.js

import { createApp } from "vue";
import { createPinia } from "pinia";
import MainApp from "./components/MainApp.vue";

class FrappeVueApp {
    constructor(wrapper) {
        this.wrapper = wrapper;
        this.page = wrapper.page;
        this.initializePage();
        this.mountVueApp();
    }
    
    initializePage() {
        // Setup page title and actions
        this.page.set_title(__("App Title"));
        this.setupPageActions();
    }
    
    mountVueApp() {
        const app = createApp(MainApp);
        
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
        
        this.vueApp = app.mount(this.wrapper.get(0));
    }
}
```

#### Page Registration
```javascript
// Register with Frappe's page system
frappe.pages["app-name"].on_page_load = function(wrapper) {
    frappe.require("app-name.bundle.js").then(() => {
        new FrappeVueApp(wrapper);
    });
};
```

### Layer 2: Application Structure

#### Directory Architecture
```
[app_name]/
├── [app_name]/
│   └── public/
│       └── js/
│           ├── [feature].bundle.js           # Entry points
│           ├── [feature]/
│           │   ├── [Feature]App.vue          # Main app component
│           │   ├── components/               # Feature components
│           │   │   ├── forms/
│           │   │   ├── lists/
│           │   │   ├── modals/
│           │   │   └── shared/
│           │   ├── views/                    # Page views
│           │   │   ├── ListView.vue
│           │   │   ├── DetailView.vue
│           │   │   └── DashboardView.vue
│           │   ├── composables/              # Vue composables
│           │   │   ├── useApi.js
│           │   │   ├── useAuth.js
│           │   │   └── useNotifications.js
│           │   ├── stores/                   # Pinia stores
│           │   │   ├── appStore.js
│           │   │   └── userStore.js
│           │   └── utils/                    # Utilities
│           │       ├── api.js
│           │       ├── helpers.js
│           │       └── constants.js
│           └── shared/                       # Shared across features
│               ├── components/
│               ├── composables/
│               ├── stores/
│               └── utils/
```

### Layer 3: Component Architecture

#### Component Hierarchy Pattern
```vue
<!-- Main Application Component -->
<template>
  <div class="app-container">
    <!-- Navigation Layer -->
    <AppNavigation 
      :current-view="currentView"
      @navigate="handleNavigation"
    />
    
    <!-- Content Layer -->
    <main class="app-content">
      <router-view 
        v-if="useRouter"
        :key="$route.fullPath"
      />
      <component 
        v-else
        :is="currentComponent"
        :key="currentView"
        @action="handleAction"
      />
    </main>
    
    <!-- Global UI Layer -->
    <AppNotifications />
    <AppModals />
    <AppLoading v-if="globalLoading" />
  </div>
</template>

<script setup>
import { ref, computed, provide } from 'vue'
import { useAppStore } from './stores/appStore'

// Store integration
const appStore = useAppStore()
const { currentView, globalLoading } = storeToRefs(appStore)

// Navigation handling
function handleNavigation(view, params = {}) {
  appStore.navigateTo(view, params)
}

// Global action handling
function handleAction(action) {
  switch (action.type) {
    case 'show_modal':
      appStore.showModal(action.payload)
      break
    case 'show_notification':
      appStore.addNotification(action.payload)
      break
    default:
      console.warn('Unhandled action:', action)
  }
}

// Provide global app context
provide('appContext', {
  navigate: handleNavigation,
  action: handleAction
})
</script>
```

### Layer 4: State Management Architecture

#### Pinia Store Structure
```javascript
// stores/appStore.js
import { defineStore } from 'pinia'
import { useUserStore } from './userStore'

export const useAppStore = defineStore('app', {
  state: () => ({
    currentView: 'dashboard',
    globalLoading: false,
    notifications: [],
    modals: [],
    sidebarCollapsed: false,
    theme: 'light'
  }),
  
  getters: {
    isAuthenticated: () => {
      const userStore = useUserStore()
      return userStore.isLoggedIn
    },
    
    hasPermission: (state) => (permission) => {
      return frappe.user.has_role(permission)
    },
    
    activeNotifications: (state) => {
      return state.notifications.filter(n => n.active)
    }
  },
  
  actions: {
    async initialize() {
      this.globalLoading = true
      try {
        await this.loadUserPreferences()
        await this.checkAuthentication()
      } finally {
        this.globalLoading = false
      }
    },
    
    navigateTo(view, params = {}) {
      this.currentView = view
      // Update browser history if needed
      if (params.updateHistory !== false) {
        history.pushState(null, '', `#${view}`)
      }
    },
    
    addNotification(notification) {
      const id = Date.now().toString()
      this.notifications.push({
        id,
        ...notification,
        active: true,
        timestamp: new Date()
      })
      
      // Auto-remove after timeout
      if (notification.timeout !== false) {
        setTimeout(() => {
          this.removeNotification(id)
        }, notification.timeout || 5000)
      }
    },
    
    async loadUserPreferences() {
      try {
        const response = await frappe.call({
          method: 'frappe.client.get_value',
          args: {
            doctype: 'User',
            fieldname: ['theme_preference', 'sidebar_preference'],
            filters: { name: frappe.session.user }
          }
        })
        
        if (response.message) {
          this.theme = response.message.theme_preference || 'light'
          this.sidebarCollapsed = response.message.sidebar_preference === 'collapsed'
        }
      } catch (error) {
        console.error('Error loading user preferences:', error)
      }
    }
  }
})
```

### Layer 5: API Integration Architecture

#### API Service Layer
```javascript
// utils/api.js
class FrappeAPIService {
  static async call(method, args = {}, options = {}) {
    const {
      freeze = false,
      freezeMessage = __('Loading...'),
      showProgress = false,
      timeout = 30000
    } = options
    
    if (freeze) {
      frappe.freeze(freezeMessage)
    }
    
    try {
      const response = await Promise.race([
        frappe.call({ method, args }),
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Request timeout')), timeout)
        )
      ])
      
      return response.message
    } catch (error) {
      this.handleError(error, method)
      throw error
    } finally {
      if (freeze) {
        frappe.unfreeze()
      }
    }
  }
  
  static handleError(error, method) {
    console.error(`API Error (${method}):`, error)
    
    // Global error handling
    if (error.message.includes('PermissionError')) {
      frappe.show_alert(__('You do not have permission to perform this action'))
    } else if (error.message.includes('ValidationError')) {
      frappe.show_alert(__('Validation failed. Please check your input.'))
    } else {
      frappe.show_alert(__('An error occurred. Please try again.'))
    }
  }
  
  // DocType operations
  static async getDoc(doctype, name, options = {}) {
    return this.call('frappe.client.get', { doctype, name }, options)
  }
  
  static async getList(doctype, options = {}) {
    const {
      fields = ['name'],
      filters = {},
      orderBy = 'modified desc',
      limitStart = 0,
      limitPageLength = 20
    } = options
    
    return this.call('frappe.client.get_list', {
      doctype,
      fields,
      filters,
      order_by: orderBy,
      limit_start: limitStart,
      limit_page_length: limitPageLength
    }, options)
  }
  
  static async insertDoc(doc, options = {}) {
    return this.call('frappe.client.insert', { doc }, options)
  }
  
  static async updateDoc(doctype, name, updates, options = {}) {
    return this.call('frappe.client.set_value', {
      doctype,
      name,
      fieldname: updates
    }, options)
  }
  
  static async deleteDoc(doctype, name, options = {}) {
    return this.call('frappe.client.delete', { doctype, name }, options)
  }
}

export default FrappeAPIService
```

#### API Composables
```javascript
// composables/useApi.js
import { ref, computed } from 'vue'
import FrappeAPIService from '../utils/api'

export function useApi() {
  const loading = ref(false)
  const error = ref(null)
  const data = ref(null)
  
  const isLoading = computed(() => loading.value)
  const hasError = computed(() => error.value !== null)
  const hasData = computed(() => data.value !== null)
  
  async function execute(apiCall) {
    loading.value = true
    error.value = null
    
    try {
      const result = await apiCall()
      data.value = result
      return result
    } catch (err) {
      error.value = err
      throw err
    } finally {
      loading.value = false
    }
  }
  
  function reset() {
    loading.value = false
    error.value = null
    data.value = null
  }
  
  return {
    loading: readonly(loading),
    error: readonly(error),
    data: readonly(data),
    isLoading,
    hasError,
    hasData,
    execute,
    reset
  }
}

// DocType-specific composable
export function useDocType(doctype) {
  const { execute, ...rest } = useApi()
  
  async function getDoc(name) {
    return execute(() => FrappeAPIService.getDoc(doctype, name))
  }
  
  async function getList(options = {}) {
    return execute(() => FrappeAPIService.getList(doctype, options))
  }
  
  async function createDoc(doc) {
    return execute(() => FrappeAPIService.insertDoc({ doctype, ...doc }))
  }
  
  async function updateDoc(name, updates) {
    return execute(() => FrappeAPIService.updateDoc(doctype, name, updates))
  }
  
  async function deleteDoc(name) {
    return execute(() => FrappeAPIService.deleteDoc(doctype, name))
  }
  
  return {
    ...rest,
    getDoc,
    getList,
    createDoc,
    updateDoc,
    deleteDoc
  }
}
```

### Layer 6: Real-time Integration

#### Real-time Event Handling
```javascript
// composables/useRealtime.js
import { ref, onMounted, onUnmounted } from 'vue'

export function useRealtime() {
  const events = ref([])
  const connected = ref(false)
  
  function subscribe(eventName, handler) {
    frappe.realtime.on(eventName, handler)
    
    // Track subscription for cleanup
    events.value.push({ eventName, handler })
  }
  
  function unsubscribe(eventName, handler) {
    frappe.realtime.off(eventName, handler)
    
    // Remove from tracking
    const index = events.value.findIndex(
      e => e.eventName === eventName && e.handler === handler
    )
    if (index > -1) {
      events.value.splice(index, 1)
    }
  }
  
  function emit(eventName, data) {
    frappe.realtime.emit(eventName, data)
  }
  
  function cleanup() {
    events.value.forEach(({ eventName, handler }) => {
      frappe.realtime.off(eventName, handler)
    })
    events.value = []
  }
  
  onMounted(() => {
    connected.value = frappe.realtime.socket?.connected || false
  })
  
  onUnmounted(() => {
    cleanup()
  })
  
  return {
    connected: readonly(connected),
    subscribe,
    unsubscribe,
    emit,
    cleanup
  }
}

// DocType-specific real-time updates
export function useDocTypeRealtime(doctype, handlers = {}) {
  const { subscribe, unsubscribe } = useRealtime()
  
  onMounted(() => {
    // Subscribe to document updates
    subscribe('doc_update', (data) => {
      if (data.doctype === doctype && handlers.onUpdate) {
        handlers.onUpdate(data)
      }
    })
    
    subscribe('doc_submit', (data) => {
      if (data.doctype === doctype && handlers.onSubmit) {
        handlers.onSubmit(data)
      }
    })
    
    subscribe('doc_cancel', (data) => {
      if (data.doctype === doctype && handlers.onCancel) {
        handlers.onCancel(data)
      }
    })
  })
}
```

## Performance Architecture

### Code Splitting Strategy

#### Route-based Splitting
```javascript
// Dynamic imports for route components
const routes = [
  {
    path: '/dashboard',
    component: () => import('./views/DashboardView.vue')
  },
  {
    path: '/orders',
    component: () => import('./views/OrdersView.vue')
  },
  {
    path: '/customers',
    component: () => import('./views/CustomersView.vue')
  }
]
```

#### Component-based Splitting
```vue
<script setup>
import { defineAsyncComponent } from 'vue'

// Lazy load heavy components
const DataTable = defineAsyncComponent({
  loader: () => import('./components/DataTable.vue'),
  loadingComponent: LoadingSpinner,
  errorComponent: ErrorComponent,
  delay: 200,
  timeout: 3000
})

const ChartComponent = defineAsyncComponent(() => 
  import('./components/ChartComponent.vue')
)
</script>
```

### Caching Strategy

#### API Response Caching
```javascript
// utils/cache.js
class APICache {
  constructor(maxSize = 100, ttl = 300000) { // 5 minutes
    this.cache = new Map()
    this.maxSize = maxSize
    this.ttl = ttl
  }
  
  get(key) {
    const item = this.cache.get(key)
    if (!item) return null
    
    if (Date.now() > item.expiry) {
      this.cache.delete(key)
      return null
    }
    
    return item.data
  }
  
  set(key, data) {
    if (this.cache.size >= this.maxSize) {
      const firstKey = this.cache.keys().next().value
      this.cache.delete(firstKey)
    }
    
    this.cache.set(key, {
      data,
      expiry: Date.now() + this.ttl
    })
  }
  
  clear() {
    this.cache.clear()
  }
}

export const apiCache = new APICache()
```

### Virtual Scrolling for Large Lists
```vue
<!-- components/VirtualList.vue -->
<template>
  <div 
    ref="containerRef"
    class="virtual-list"
    @scroll="handleScroll"
  >
    <div 
      :style="{ height: totalHeight + 'px' }"
      class="virtual-list-phantom"
    ></div>
    <div
      :style="{ transform: `translateY(${offsetY}px)` }"
      class="virtual-list-content"
    >
      <div
        v-for="item in visibleItems"
        :key="item.id"
        :style="{ height: itemHeight + 'px' }"
        class="virtual-list-item"
      >
        <slot :item="item" :index="item.index"></slot>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watchEffect } from 'vue'

const props = defineProps({
  items: Array,
  itemHeight: { type: Number, default: 50 },
  visibleCount: { type: Number, default: 10 }
})

const containerRef = ref(null)
const scrollTop = ref(0)

const totalHeight = computed(() => props.items.length * props.itemHeight)
const startIndex = computed(() => Math.floor(scrollTop.value / props.itemHeight))
const endIndex = computed(() => 
  Math.min(startIndex.value + props.visibleCount, props.items.length)
)

const visibleItems = computed(() => 
  props.items.slice(startIndex.value, endIndex.value).map((item, index) => ({
    ...item,
    index: startIndex.value + index
  }))
)

const offsetY = computed(() => startIndex.value * props.itemHeight)

function handleScroll(event) {
  scrollTop.value = event.target.scrollTop
}
</script>
```

## Security Architecture

### Authentication Integration
```javascript
// composables/useAuth.js
import { ref, computed } from 'vue'

export function useAuth() {
  const user = ref(frappe.session.user)
  const roles = ref(frappe.user_roles)
  
  const isLoggedIn = computed(() => user.value !== 'Guest')
  const isAdmin = computed(() => roles.value.includes('Administrator'))
  
  function hasRole(role) {
    return roles.value.includes(role)
  }
  
  function hasPermission(doctype, permission = 'read') {
    return frappe.perm.has_perm(doctype, 0, permission)
  }
  
  function canRead(doctype) {
    return hasPermission(doctype, 'read')
  }
  
  function canWrite(doctype) {
    return hasPermission(doctype, 'write')
  }
  
  function canCreate(doctype) {
    return hasPermission(doctype, 'create')
  }
  
  function canDelete(doctype) {
    return hasPermission(doctype, 'delete')
  }
  
  async function checkPermission(doctype, name, permission) {
    try {
      const response = await frappe.call({
        method: 'frappe.core.doctype.user_permission.user_permission.has_permission',
        args: { doctype, name, permission }
      })
      return response.message
    } catch (error) {
      console.error('Permission check failed:', error)
      return false
    }
  }
  
  return {
    user: readonly(user),
    roles: readonly(roles),
    isLoggedIn,
    isAdmin,
    hasRole,
    hasPermission,
    canRead,
    canWrite,
    canCreate,
    canDelete,
    checkPermission
  }
}
```

### Input Validation and Sanitization
```javascript
// utils/validation.js
export class InputValidator {
  static sanitizeHtml(input) {
    // Use Frappe's built-in sanitization
    return frappe.utils.escape_html(input)
  }
  
  static validateEmail(email) {
    const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return pattern.test(email)
  }
  
  static validateLength(input, min = 0, max = Infinity) {
    const length = input?.length || 0
    return length >= min && length <= max
  }
  
  static validateRequired(value) {
    return value !== null && value !== undefined && value !== ''
  }
  
  static validatePattern(input, pattern) {
    return pattern.test(input)
  }
}

// Form validation composable
export function useFormValidation(rules = {}) {
  const errors = ref({})
  
  function validate(data) {
    errors.value = {}
    
    for (const [field, fieldRules] of Object.entries(rules)) {
      const value = data[field]
      
      for (const rule of fieldRules) {
        const result = rule.validator(value, data)
        if (result !== true) {
          errors.value[field] = result
          break
        }
      }
    }
    
    return Object.keys(errors.value).length === 0
  }
  
  return {
    errors: readonly(errors),
    validate
  }
}
```

## Testing Architecture

### Component Testing Strategy
```javascript
// tests/components/ComponentName.test.js
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import ComponentName from '@/components/ComponentName.vue'

describe('ComponentName', () => {
  let wrapper
  
  beforeEach(() => {
    setActivePinia(createPinia())
    
    // Mock Frappe globals
    global.frappe = {
      call: vi.fn(),
      show_alert: vi.fn(),
      __: (text) => text
    }
    
    wrapper = mount(ComponentName, {
      props: {
        // Test props
      },
      global: {
        provide: {
          frappeContext: {
            page: {},
            wrapper: {}
          }
        }
      }
    })
  })
  
  afterEach(() => {
    wrapper.unmount()
  })
  
  it('renders correctly', () => {
    expect(wrapper.exists()).toBe(true)
  })
  
  it('handles user interactions', async () => {
    await wrapper.find('button').trigger('click')
    expect(wrapper.emitted()).toHaveProperty('action')
  })
})
```

### Integration Testing
```javascript
// tests/integration/api.test.js
import FrappeAPIService from '@/utils/api'

describe('API Integration', () => {
  beforeEach(() => {
    global.frappe = {
      call: vi.fn(),
      freeze: vi.fn(),
      unfreeze: vi.fn()
    }
  })
  
  it('calls Frappe API correctly', async () => {
    const mockResponse = { message: { test: 'data' } }
    global.frappe.call.mockResolvedValue(mockResponse)
    
    const result = await FrappeAPIService.call('test.method', { arg: 'value' })
    
    expect(global.frappe.call).toHaveBeenCalledWith({
      method: 'test.method',
      args: { arg: 'value' }
    })
    expect(result).toEqual({ test: 'data' })
  })
})
```

## Deployment Architecture

### Build Process Integration
```javascript
// Build configuration for Frappe
const esbuildConfig = {
  entryPoints: ['./public/js/*.bundle.js'],
  bundle: true,
  minify: process.env.NODE_ENV === 'production',
  sourcemap: process.env.NODE_ENV === 'development',
  target: ['es2020'],
  format: 'iife',
  outdir: './public/dist/js/',
  define: {
    'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development')
  },
  external: ['frappe']
}
```

### Progressive Web App (PWA) Integration
```javascript
// Service worker registration
if ('serviceWorker' in navigator && process.env.NODE_ENV === 'production') {
  navigator.serviceWorker.register('/sw.js')
    .then(registration => {
      console.log('SW registered: ', registration)
    })
    .catch(registrationError => {
      console.log('SW registration failed: ', registrationError)
    })
}
```

## Best Practices Summary

### Architecture Principles
1. **Frappe-First**: Always use Frappe's built-in capabilities
2. **Component Isolation**: Clear component boundaries and responsibilities
3. **State Management**: Use appropriate state management for scope
4. **Performance**: Implement lazy loading and virtual scrolling
5. **Security**: Validate input and respect Frappe permissions
6. **Testing**: Comprehensive testing at all levels
7. **Documentation**: Document architecture decisions and patterns

### Common Patterns
1. **Bundle Entry Points**: Consistent Frappe integration pattern
2. **Component Structure**: Hierarchical component organization
3. **API Integration**: Centralized API service with error handling
4. **Real-time Updates**: Event-driven state synchronization
5. **Caching**: Smart caching for performance optimization
6. **Validation**: Input validation and sanitization
7. **Error Handling**: Graceful error handling and user feedback

This architecture provides a robust foundation for building scalable, maintainable Vue.js SPAs within ERPNext v16 while maintaining full compatibility with Frappe Framework.