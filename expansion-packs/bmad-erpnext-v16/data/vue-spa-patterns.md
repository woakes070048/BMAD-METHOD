# Vue SPA Patterns for ERPNext v16

## Overview

This guide provides comprehensive patterns for building Vue.js Single Page Applications (SPAs) within ERPNext v16 using Frappe's native asset pipeline. These patterns ensure optimal integration with Frappe's architecture while maintaining modern Vue.js development practices.

## Project Structure Patterns

### Recommended Directory Structure

```
[app_name]/
├── [app_name]/
│   └── public/
│       └── js/
│           ├── [feature].bundle.js           # Entry points
│           ├── [feature]/
│           │   ├── [Feature]App.vue          # Main app component
│           │   ├── components/
│           │   │   ├── [Component].vue
│           │   │   └── common/
│           │   │       └── [SharedComponent].vue
│           │   ├── views/
│           │   │   ├── [ListView].vue
│           │   │   └── [DetailView].vue
│           │   ├── composables/
│           │   │   └── use[Feature].js
│           │   ├── stores/
│           │   │   └── [feature]Store.js
│           │   └── utils/
│           │       └── [featureUtils].js
│           └── shared/
│               ├── components/
│               ├── composables/
│               └── utils/
```

### Bundle Entry Pattern

```javascript
// [app_name]/public/js/customer-portal.bundle.js
import { createApp } from "vue";
import CustomerPortalApp from "./customer-portal/CustomerPortalApp.vue";
import { createPinia } from "pinia";

class CustomerPortal {
    constructor(wrapper) {
        this.$wrapper = $(wrapper);
        this.page = wrapper.page;
        this.setupPage();
        this.mountApp();
    }
    
    setupPage() {
        // Set page title
        this.page.set_title(__("Customer Portal"));
        
        // Add page actions
        this.page.set_primary_action(__("New Order"), () => {
            this.createNewOrder();
        });
        
        this.page.add_action_item(__("Export Data"), () => {
            this.exportData();
        });
    }
    
    mountApp() {
        // Create Vue app
        const app = createApp(CustomerPortalApp);
        
        // CRITICAL: Set up Frappe globals
        SetVueGlobals(app);
        
        // Add Pinia for state management
        const pinia = createPinia();
        app.use(pinia);
        
        // Provide Frappe page context
        app.provide('frappeContext', {
            page: this.page,
            wrapper: this.$wrapper
        });
        
        // Mount the app
        this.$app = app.mount(this.$wrapper.get(0));
    }
    
    createNewOrder() {
        // Access Vue app instance methods
        this.$app.createNewOrder();
    }
    
    exportData() {
        this.$app.exportData();
    }
}

// Register with Frappe
frappe.pages["customer-portal"].on_page_load = function(wrapper) {
    frappe.require("customer-portal.bundle.js").then(() => {
        new CustomerPortal(wrapper);
    });
};
```

## Component Architecture Patterns

### Main App Component Pattern

```vue
<!-- customer-portal/CustomerPortalApp.vue -->
<template>
  <div class="customer-portal">
    <!-- Navigation -->
    <div class="flex border-b mb-6">
      <nav class="flex space-x-6">
        <button
          v-for="tab in tabs"
          :key="tab.id"
          :class="[
            'pb-2 border-b-2 font-medium text-sm',
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
    
    <!-- Content Area -->
    <div class="tab-content">
      <component
        :is="currentComponent"
        :key="activeTab"
        @navigate="handleNavigation"
        @action="handleAction"
      />
    </div>
    
    <!-- Global Loading -->
    <div v-if="loading" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white p-6 rounded-lg">
        <div class="text-center">
          <div class="spinner"></div>
          <p class="mt-2">{{ __('Loading...') }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, inject } from 'vue'
import { useCustomerStore } from './stores/customerStore'

// Import views
import OrdersView from './views/OrdersView.vue'
import InvoicesView from './views/InvoicesView.vue'
import ProfileView from './views/ProfileView.vue'

// Frappe context
const frappeContext = inject('frappeContext')

// Store
const customerStore = useCustomerStore()
const { loading } = storeToRefs(customerStore)

// Local state
const activeTab = ref('orders')

const tabs = [
  { id: 'orders', label: 'Orders', component: 'OrdersView' },
  { id: 'invoices', label: 'Invoices', component: 'InvoicesView' },
  { id: 'profile', label: 'Profile', component: 'ProfileView' }
]

const currentComponent = computed(() => {
  const tab = tabs.find(t => t.id === activeTab.value)
  return tab?.component
})

// Methods exposed to parent
function createNewOrder() {
  activeTab.value = 'orders'
  // Access child component method
  const ordersComponent = getCurrentInstance().refs.ordersView
  ordersComponent?.showCreateDialog()
}

function exportData() {
  const currentView = getCurrentInstance().refs[`${activeTab.value}View`]
  currentView?.exportData()
}

function handleNavigation(tab) {
  activeTab.value = tab
}

function handleAction(action) {
  switch (action.type) {
    case 'create_order':
      createNewOrder()
      break
    case 'show_alert':
      frappe.show_alert(action.message)
      break
  }
}

// Lifecycle
onMounted(async () => {
  await customerStore.initialize()
})

// Expose methods to parent
defineExpose({
  createNewOrder,
  exportData
})
</script>
```

### List View Pattern

```vue
<!-- views/OrdersView.vue -->
<template>
  <div class="orders-view">
    <!-- Header -->
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-2xl font-bold">{{ __('My Orders') }}</h2>
      <button
        class="btn btn-primary"
        @click="showCreateDialog = true"
      >
        {{ __('New Order') }}
      </button>
    </div>
    
    <!-- Filters -->
    <div class="bg-gray-50 p-4 rounded mb-4">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm font-medium mb-1">{{ __('Status') }}</label>
          <select
            v-model="filters.status"
            class="form-control"
            @change="loadOrders"
          >
            <option value="">{{ __('All Statuses') }}</option>
            <option value="Draft">{{ __('Draft') }}</option>
            <option value="Submitted">{{ __('Submitted') }}</option>
            <option value="Completed">{{ __('Completed') }}</option>
          </select>
        </div>
        
        <div>
          <label class="block text-sm font-medium mb-1">{{ __('From Date') }}</label>
          <input
            v-model="filters.fromDate"
            type="date"
            class="form-control"
            @change="loadOrders"
          />
        </div>
        
        <div>
          <label class="block text-sm font-medium mb-1">{{ __('To Date') }}</label>
          <input
            v-model="filters.toDate"
            type="date"
            class="form-control"
            @change="loadOrders"
          />
        </div>
      </div>
    </div>
    
    <!-- Orders Table -->
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              {{ __('Order No') }}
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              {{ __('Date') }}
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              {{ __('Status') }}
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              {{ __('Total') }}
            </th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
              {{ __('Actions') }}
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr
            v-for="order in orders"
            :key="order.name"
            class="hover:bg-gray-50 cursor-pointer"
            @click="viewOrder(order)"
          >
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm font-medium text-gray-900">
                {{ order.name }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-900">
                {{ formatDate(order.transaction_date) }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span
                :class="[
                  'inline-flex px-2 py-1 text-xs font-semibold rounded-full',
                  getStatusClass(order.status)
                ]"
              >
                {{ __(order.status) }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-900">
                {{ formatCurrency(order.grand_total) }}
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <button
                class="text-blue-600 hover:text-blue-900 mr-3"
                @click.stop="viewOrder(order)"
              >
                {{ __('View') }}
              </button>
              <button
                v-if="order.status === 'Draft'"
                class="text-green-600 hover:text-green-900"
                @click.stop="editOrder(order)"
              >
                {{ __('Edit') }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>
      
      <!-- Empty State -->
      <div v-if="!loading && orders.length === 0" class="text-center py-12">
        <div class="text-gray-500">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          <h3 class="mt-2 text-sm font-medium text-gray-900">{{ __('No orders') }}</h3>
          <p class="mt-1 text-sm text-gray-500">{{ __('Get started by creating a new order.') }}</p>
          <div class="mt-6">
            <button
              class="btn btn-primary"
              @click="showCreateDialog = true"
            >
              {{ __('New Order') }}
            </button>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Pagination -->
    <div v-if="totalPages > 1" class="flex justify-center mt-6">
      <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px">
        <button
          :disabled="currentPage === 1"
          class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
          @click="changePage(currentPage - 1)"
        >
          {{ __('Previous') }}
        </button>
        <button
          v-for="page in visiblePages"
          :key="page"
          :class="[
            'relative inline-flex items-center px-4 py-2 border text-sm font-medium',
            page === currentPage
              ? 'z-10 bg-blue-50 border-blue-500 text-blue-600'
              : 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50'
          ]"
          @click="changePage(page)"
        >
          {{ page }}
        </button>
        <button
          :disabled="currentPage === totalPages"
          class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
          @click="changePage(currentPage + 1)"
        >
          {{ __('Next') }}
        </button>
      </nav>
    </div>
    
    <!-- Create Order Dialog -->
    <CreateOrderDialog
      v-if="showCreateDialog"
      @close="showCreateDialog = false"
      @created="handleOrderCreated"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useOrderStore } from '../stores/orderStore'
import CreateOrderDialog from '../components/CreateOrderDialog.vue'

// Store
const orderStore = useOrderStore()
const { orders, loading, currentPage, totalPages } = storeToRefs(orderStore)

// Local state
const showCreateDialog = ref(false)
const filters = ref({
  status: '',
  fromDate: '',
  toDate: ''
})

// Computed
const visiblePages = computed(() => {
  const pages = []
  const start = Math.max(1, currentPage.value - 2)
  const end = Math.min(totalPages.value, start + 4)
  
  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

// Methods
async function loadOrders() {
  await orderStore.fetchOrders(filters.value)
}

function viewOrder(order) {
  frappe.set_route('sales-order', order.name)
}

function editOrder(order) {
  frappe.set_route('sales-order', order.name)
}

function getStatusClass(status) {
  const classes = {
    'Draft': 'bg-gray-100 text-gray-800',
    'Submitted': 'bg-blue-100 text-blue-800',
    'Completed': 'bg-green-100 text-green-800',
    'Cancelled': 'bg-red-100 text-red-800'
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}

function formatDate(date) {
  return frappe.datetime.str_to_user(date)
}

function formatCurrency(amount) {
  return frappe.format(amount, { fieldtype: 'Currency' })
}

function changePage(page) {
  if (page >= 1 && page <= totalPages.value) {
    orderStore.setPage(page)
    loadOrders()
  }
}

function handleOrderCreated(order) {
  showCreateDialog.value = false
  loadOrders()
  frappe.show_alert(__('Order created successfully'))
}

function exportData() {
  // Export functionality
  const data = orders.value.map(order => ({
    'Order No': order.name,
    'Date': formatDate(order.transaction_date),
    'Status': order.status,
    'Total': order.grand_total
  }))
  
  frappe.tools.downloadify(data, null, 'orders')
}

// Lifecycle
onMounted(() => {
  loadOrders()
})

// Expose methods
defineExpose({
  showCreateDialog: () => { showCreateDialog.value = true },
  exportData
})
</script>
```

## State Management Patterns

### Pinia Store Pattern

```javascript
// stores/orderStore.js
import { defineStore } from 'pinia'

export const useOrderStore = defineStore('orders', {
  state: () => ({
    orders: [],
    selectedOrder: null,
    loading: false,
    error: null,
    currentPage: 1,
    pageSize: 20,
    totalRecords: 0,
    filters: {
      status: '',
      customer: '',
      fromDate: '',
      toDate: ''
    }
  }),
  
  getters: {
    totalPages: (state) => Math.ceil(state.totalRecords / state.pageSize),
    
    filteredOrders: (state) => {
      return state.orders.filter(order => {
        if (state.filters.status && order.status !== state.filters.status) {
          return false
        }
        if (state.filters.customer && order.customer !== state.filters.customer) {
          return false
        }
        return true
      })
    },
    
    draftOrders: (state) => state.orders.filter(order => order.status === 'Draft'),
    submittedOrders: (state) => state.orders.filter(order => order.status === 'Submitted')
  },
  
  actions: {
    async fetchOrders(filters = {}) {
      this.loading = true
      this.error = null
      
      try {
        const response = await frappe.call({
          method: 'erpnext.selling.doctype.sales_order.sales_order.get_customer_orders',
          args: {
            customer: frappe.session.user,
            filters: {
              ...this.filters,
              ...filters
            },
            page: this.currentPage,
            page_size: this.pageSize
          }
        })
        
        this.orders = response.message.data
        this.totalRecords = response.message.total
        
        // Update filters
        Object.assign(this.filters, filters)
        
      } catch (error) {
        this.error = error.message
        frappe.show_alert(__('Error loading orders'))
        console.error('Error fetching orders:', error)
      } finally {
        this.loading = false
      }
    },
    
    async fetchOrderDetails(orderName) {
      this.loading = true
      
      try {
        const response = await frappe.call({
          method: 'frappe.client.get',
          args: {
            doctype: 'Sales Order',
            name: orderName
          }
        })
        
        this.selectedOrder = response.message
        return response.message
        
      } catch (error) {
        this.error = error.message
        frappe.show_alert(__('Error loading order details'))
        throw error
      } finally {
        this.loading = false
      }
    },
    
    async createOrder(orderData) {
      this.loading = true
      
      try {
        const response = await frappe.call({
          method: 'frappe.client.insert',
          args: {
            doc: {
              doctype: 'Sales Order',
              ...orderData
            }
          }
        })
        
        // Add to local state
        this.orders.unshift(response.message)
        this.totalRecords++
        
        return response.message
        
      } catch (error) {
        this.error = error.message
        frappe.show_alert(__('Error creating order'))
        throw error
      } finally {
        this.loading = false
      }
    },
    
    async updateOrder(orderName, updates) {
      this.loading = true
      
      try {
        const response = await frappe.call({
          method: 'frappe.client.set_value',
          args: {
            doctype: 'Sales Order',
            name: orderName,
            fieldname: updates
          }
        })
        
        // Update local state
        const index = this.orders.findIndex(order => order.name === orderName)
        if (index !== -1) {
          Object.assign(this.orders[index], updates)
        }
        
        if (this.selectedOrder?.name === orderName) {
          Object.assign(this.selectedOrder, updates)
        }
        
        return response.message
        
      } catch (error) {
        this.error = error.message
        frappe.show_alert(__('Error updating order'))
        throw error
      } finally {
        this.loading = false
      }
    },
    
    setPage(page) {
      this.currentPage = page
    },
    
    clearError() {
      this.error = null
    },
    
    reset() {
      this.$reset()
    }
  }
})
```

## Composables Pattern

### Data Fetching Composable

```javascript
// composables/useAsyncData.js
import { ref, watchEffect } from 'vue'

export function useAsyncData(fetcher, options = {}) {
  const data = ref(null)
  const error = ref(null)
  const loading = ref(false)
  
  const {
    immediate = true,
    resetOnExecute = true,
    onError = null,
    onSuccess = null
  } = options
  
  const execute = async (...args) => {
    if (resetOnExecute) {
      data.value = null
      error.value = null
    }
    
    loading.value = true
    
    try {
      const result = await fetcher(...args)
      data.value = result
      
      if (onSuccess) {
        onSuccess(result)
      }
      
      return result
    } catch (err) {
      error.value = err
      
      if (onError) {
        onError(err)
      } else {
        console.error('Async operation failed:', err)
      }
      
      throw err
    } finally {
      loading.value = false
    }
  }
  
  if (immediate) {
    execute()
  }
  
  return {
    data,
    error,
    loading,
    execute
  }
}
```

### Form Handling Composable

```javascript
// composables/useForm.js
import { ref, reactive, computed } from 'vue'

export function useForm(initialData = {}, validationRules = {}) {
  const formData = reactive({ ...initialData })
  const errors = ref({})
  const touched = ref({})
  const submitting = ref(false)
  
  const isValid = computed(() => {
    return Object.keys(errors.value).length === 0
  })
  
  const isDirty = computed(() => {
    return JSON.stringify(formData) !== JSON.stringify(initialData)
  })
  
  function validate(field = null) {
    if (field) {
      // Validate single field
      const rule = validationRules[field]
      if (rule) {
        const error = rule(formData[field], formData)
        if (error) {
          errors.value[field] = error
        } else {
          delete errors.value[field]
        }
      }
    } else {
      // Validate all fields
      errors.value = {}
      for (const [field, rule] of Object.entries(validationRules)) {
        const error = rule(formData[field], formData)
        if (error) {
          errors.value[field] = error
        }
      }
    }
  }
  
  function touch(field) {
    touched.value[field] = true
    validate(field)
  }
  
  function reset(newData = initialData) {
    Object.assign(formData, newData)
    errors.value = {}
    touched.value = {}
    submitting.value = false
  }
  
  async function submit(submitFn) {
    // Touch all fields
    for (const field in formData) {
      touch(field)
    }
    
    if (!isValid.value) {
      return false
    }
    
    submitting.value = true
    
    try {
      const result = await submitFn(formData)
      return result
    } catch (error) {
      throw error
    } finally {
      submitting.value = false
    }
  }
  
  return {
    formData,
    errors,
    touched,
    submitting,
    isValid,
    isDirty,
    validate,
    touch,
    reset,
    submit
  }
}
```

## API Integration Patterns

### Frappe API Service

```javascript
// utils/frappeApi.js
class FrappeAPI {
  static async call(method, args = {}) {
    try {
      const response = await frappe.call({
        method,
        args
      })
      return response.message
    } catch (error) {
      console.error(`API Error (${method}):`, error)
      throw error
    }
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
    })
  }
  
  static async getDoc(doctype, name) {
    return this.call('frappe.client.get', {
      doctype,
      name
    })
  }
  
  static async insertDoc(doc) {
    return this.call('frappe.client.insert', { doc })
  }
  
  static async updateDoc(doctype, name, updates) {
    return this.call('frappe.client.set_value', {
      doctype,
      name,
      fieldname: updates
    })
  }
  
  static async deleteDoc(doctype, name) {
    return this.call('frappe.client.delete', {
      doctype,
      name
    })
  }
  
  static async submitDoc(doctype, name) {
    return this.call('frappe.client.submit', {
      doctype,
      name
    })
  }
  
  static async cancelDoc(doctype, name) {
    return this.call('frappe.client.cancel', {
      doctype,
      name
    })
  }
}

export default FrappeAPI
```

## Real-time Updates Pattern

```vue
<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const notifications = ref([])
const orderUpdates = ref([])

function handleDocUpdate(data) {
  if (data.doctype === 'Sales Order') {
    // Update local data
    orderStore.handleRealtimeUpdate(data)
    
    // Show notification
    notifications.value.push({
      id: Date.now(),
      type: 'info',
      message: `Order ${data.name} has been updated`,
      timestamp: new Date()
    })
    
    // Auto-remove notification after 5 seconds
    setTimeout(() => {
      notifications.value = notifications.value.filter(n => n.id !== Date.now())
    }, 5000)
  }
}

function handleDocSubmit(data) {
  if (data.doctype === 'Sales Order') {
    frappe.show_alert(`Order ${data.name} has been submitted`)
  }
}

onMounted(() => {
  // Subscribe to real-time events
  frappe.realtime.on('doc_update', handleDocUpdate)
  frappe.realtime.on('doc_submit', handleDocSubmit)
})

onUnmounted(() => {
  // Cleanup subscriptions
  frappe.realtime.off('doc_update', handleDocUpdate)
  frappe.realtime.off('doc_submit', handleDocSubmit)
})
</script>
```

## Performance Optimization Patterns

### Lazy Loading Components

```vue
<script setup>
import { defineAsyncComponent } from 'vue'

// Lazy load heavy components
const ChartComponent = defineAsyncComponent(() =>
  import('./components/ChartComponent.vue')
)

const DataTable = defineAsyncComponent({
  loader: () => import('./components/DataTable.vue'),
  loadingComponent: () => import('./components/LoadingSpinner.vue'),
  errorComponent: () => import('./components/ErrorComponent.vue'),
  delay: 200,
  timeout: 3000
})
</script>
```

### Virtual Scrolling

```vue
<!-- For large datasets -->
<template>
  <div
    ref="containerRef"
    class="virtual-list"
    @scroll="handleScroll"
  >
    <div :style="{ height: totalHeight + 'px' }" class="virtual-list-phantom"></div>
    <div
      :style="{
        transform: `translateY(${offsetY}px)`
      }"
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
import { ref, computed, nextTick } from 'vue'

const props = defineProps({
  items: Array,
  itemHeight: { type: Number, default: 50 },
  visibleCount: { type: Number, default: 10 }
})

const containerRef = ref(null)
const scrollTop = ref(0)

const totalHeight = computed(() => props.items.length * props.itemHeight)
const startIndex = computed(() => Math.floor(scrollTop.value / props.itemHeight))
const endIndex = computed(() => Math.min(startIndex.value + props.visibleCount, props.items.length))
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

## Best Practices Summary

1. **Bundle Organization**: Use clear entry points with proper Frappe integration
2. **Component Structure**: Follow consistent component patterns and naming
3. **State Management**: Use Pinia for complex state, composables for reusable logic
4. **API Integration**: Centralize API calls and error handling
5. **Performance**: Implement lazy loading and virtual scrolling for large datasets
6. **Real-time**: Leverage Frappe's real-time capabilities for live updates
7. **Testing**: Write unit tests for composables and integration tests for components