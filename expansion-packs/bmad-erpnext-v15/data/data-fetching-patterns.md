# Data Fetching Patterns for ERPNext Vue Applications
## Complete Resource Management & API Patterns Reference

**Last Updated**: 2025-08-11  
**Framework Version**: Frappe UI 0.1.x | Vue 3.4+ | ERPNext 15  
**Source**: Production data patterns from CRM and HRMS applications

---

## 🔄 Core Resource Patterns

### 1. createResource - The Foundation

#### Basic Resource Creation
```javascript
// Basic resource pattern
import { createResource } from 'frappe-ui'

const users = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'User',
    fields: ['name', 'full_name', 'email', 'enabled'],
    filters: { enabled: 1 },
    order_by: 'full_name asc'
  },
  auto: true, // Automatically fetch on creation
  cache: 'users-list' // Enable caching
})

// Resource properties available:
// users.data - The fetched data
// users.loading - Loading state
// users.error - Error object if any
// users.fetched - Boolean if data has been fetched
// users.reload() - Function to refetch data
// users.submit() - Function to submit with new params
// users.reset() - Function to reset resource state
```

#### Advanced Resource Configuration
```javascript
// Advanced resource with all options
const advancedResource = createResource({
  // Basic configuration
  url: 'frappe.client.get_list',
  method: 'GET', // Default is GET
  
  // Parameters
  params: {
    doctype: 'Contact',
    fields: ['name', 'full_name', 'email'],
    limit_page_length: 20
  },
  
  // Auto-fetch on creation
  auto: true,
  
  // Caching
  cache: ['contacts', 'list'], // Array for complex cache keys
  
  // Data transformation
  transform(data) {
    return data.map(contact => ({
      ...contact,
      display_name: `${contact.full_name} (${contact.email})`
    }))
  },
  
  // Debouncing
  debounce: 300, // Debounce requests by 300ms
  
  // Initial data
  initialData: [],
  
  // Lifecycle hooks
  onFetch(params) {
    console.log('Fetching with params:', params)
  },
  
  onSuccess(data) {
    console.log('Fetch successful:', data)
  },
  
  onError(error) {
    console.error('Fetch error:', error)
  },
  
  onData(data) {
    console.log('Data received:', data)
  },
  
  // Parameter generation
  makeParams(params) {
    return {
      ...this.params,
      ...params,
      // Add dynamic filters based on current state
      filters: {
        ...this.params.filters,
        modified: ['>', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()]
      }
    }
  },
  
  // Validation before request
  validate(params) {
    if (!params.doctype) {
      return 'DocType is required'
    }
    return null
  },
  
  // Before submit hook
  beforeSubmit(params) {
    // Modify params or perform validation
    if (params.search) {
      params.filters = {
        ...params.filters,
        full_name: ['like', `%${params.search}%`]
      }
    }
  }
})
```

### 2. Dynamic Parameter Management

#### Reactive Parameter Updates
```javascript
import { createResource } from 'frappe-ui'
import { ref, watch } from 'vue'

// Reactive filters
const filters = ref({
  status: '',
  territory: '',
  search: ''
})

const customers = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'Customer',
    fields: ['name', 'customer_name', 'territory', 'status'],
    order_by: 'customer_name asc'
  }
})

// Watch filters and update resource
watch(filters, (newFilters) => {
  const activeFilters = {}
  
  if (newFilters.status) {
    activeFilters.status = newFilters.status
  }
  
  if (newFilters.territory) {
    activeFilters.territory = newFilters.territory
  }
  
  if (newFilters.search) {
    activeFilters.customer_name = ['like', `%${newFilters.search}%`]
  }
  
  customers.update({
    params: {
      ...customers.params,
      filters: activeFilters
    }
  })
  
  customers.reload()
}, { deep: true })

// Usage in component
const updateFilter = (key, value) => {
  filters.value[key] = value
}

const clearFilters = () => {
  filters.value = { status: '', territory: '', search: '' }
}
```

#### Parameterized Resources
```javascript
// Resource that accepts parameters at call time
const customerDetails = createResource({
  url: 'frappe.client.get',
  makeParams: (customerName) => ({
    doctype: 'Customer',
    name: customerName
  })
})

// Usage
const loadCustomer = async (customerName) => {
  await customerDetails.submit(customerName)
  return customerDetails.data
}

// Or with multiple parameters
const salesOrdersByCustomer = createResource({
  url: 'frappe.client.get_list',
  makeParams: ({ customer, from_date, to_date }) => ({
    doctype: 'Sales Order',
    fields: ['name', 'transaction_date', 'grand_total', 'status'],
    filters: {
      customer: customer,
      transaction_date: ['between', [from_date, to_date]]
    },
    order_by: 'transaction_date desc'
  })
})

const loadCustomerOrders = async (customer, dateRange) => {
  await salesOrdersByCustomer.submit({
    customer,
    from_date: dateRange.start,
    to_date: dateRange.end
  })
  return salesOrdersByCustomer.data
}
```

### 3. Data Manipulation Patterns

#### Adding/Updating Data
```javascript
import { createResource } from 'frappe-ui'

// List resource
const contacts = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'Contact',
    fields: ['name', 'full_name', 'email', 'phone'],
    order_by: 'full_name asc'
  },
  auto: true
})

// Create resource
const createContact = createResource({
  url: 'frappe.client.insert',
  onSuccess(newContact) {
    // Add to existing list without refetching
    contacts.setData(currentData => [newContact, ...currentData])
  }
})

// Update resource
const updateContact = createResource({
  url: 'frappe.client.save',
  onSuccess(updatedContact) {
    // Update item in list
    contacts.setData(currentData => 
      currentData.map(contact => 
        contact.name === updatedContact.name 
          ? { ...contact, ...updatedContact }
          : contact
      )
    )
  }
})

// Delete resource
const deleteContact = createResource({
  url: 'frappe.client.delete',
  onSuccess(_, params) {
    // Remove from list
    contacts.setData(currentData => 
      currentData.filter(contact => contact.name !== params.name)
    )
  }
})

// Usage functions
const addNewContact = async (contactData) => {
  await createContact.submit({
    doc: { doctype: 'Contact', ...contactData }
  })
}

const saveContact = async (name, updates) => {
  await updateContact.submit({
    doc: { doctype: 'Contact', name, ...updates }
  })
}

const removeContact = async (name) => {
  const confirmed = confirm('Are you sure you want to delete this contact?')
  if (confirmed) {
    await deleteContact.submit({ doctype: 'Contact', name })
  }
}
```

#### Optimistic Updates
```javascript
// Optimistic update pattern
const toggleContactStatus = createResource({
  url: 'frappe.client.set_value',
  
  // Optimistically update UI before server response
  beforeSubmit(params) {
    const { name, value } = params
    
    // Update UI immediately
    contacts.setData(currentData => 
      currentData.map(contact => 
        contact.name === name 
          ? { ...contact, disabled: value }
          : contact
      )
    )
  },
  
  onError(error, params) {
    // Revert optimistic update on error
    const { name } = params
    contacts.setData(currentData => 
      currentData.map(contact => 
        contact.name === name 
          ? { ...contact, disabled: !contact.disabled }
          : contact
      )
    )
  }
})

const toggleStatus = async (contactName, currentStatus) => {
  await toggleContactStatus.submit({
    doctype: 'Contact',
    name: contactName,
    fieldname: 'disabled',
    value: currentStatus ? 0 : 1
  })
}
```

### 4. Pagination & Infinite Scrolling

#### Traditional Pagination
```javascript
import { ref, computed } from 'vue'
import { createResource } from 'frappe-ui'

const currentPage = ref(1)
const pageSize = ref(20)

const customers = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'Customer',
    fields: ['name', 'customer_name', 'territory'],
    limit_page_length: pageSize.value,
    limit_start: 0,
    order_by: 'customer_name asc'
  },
  auto: true
})

// Total count resource
const customerCount = createResource({
  url: 'frappe.client.get_count',
  params: {
    doctype: 'Customer'
  },
  auto: true
})

const totalPages = computed(() => {
  return Math.ceil((customerCount.data || 0) / pageSize.value)
})

const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  
  currentPage.value = page
  
  customers.update({
    params: {
      ...customers.params,
      limit_start: (page - 1) * pageSize.value
    }
  })
  
  customers.reload()
}

const nextPage = () => goToPage(currentPage.value + 1)
const prevPage = () => goToPage(currentPage.value - 1)
```

#### Infinite Scrolling
```javascript
import { ref, onMounted, onUnmounted } from 'vue'
import { createResource } from 'frappe-ui'

const allItems = ref([])
const hasMore = ref(true)
const loading = ref(false)

const itemsResource = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'Item',
    fields: ['name', 'item_name', 'item_code'],
    limit_page_length: 20,
    limit_start: 0
  },
  
  onSuccess(data) {
    if (data.length < 20) {
      hasMore.value = false
    }
    
    allItems.value = [...allItems.value, ...data]
    loading.value = false
  },
  
  onError() {
    loading.value = false
  }
})

const loadMore = async () => {
  if (loading.value || !hasMore.value) return
  
  loading.value = true
  
  itemsResource.update({
    params: {
      ...itemsResource.params,
      limit_start: allItems.value.length
    }
  })
  
  await itemsResource.reload()
}

// Scroll listener
const handleScroll = () => {
  const { scrollTop, scrollHeight, clientHeight } = document.documentElement
  
  if (scrollTop + clientHeight >= scrollHeight - 100) {
    loadMore()
  }
}

onMounted(() => {
  itemsResource.fetch()
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})
```

### 5. Real-time Data Synchronization

#### Socket.io Integration
```javascript
import { createResource } from 'frappe-ui'
import { ref, onMounted, onUnmounted } from 'vue'

const notifications = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'Notification Log',
    fields: ['name', 'subject', 'email_content', 'creation', 'read'],
    filters: { for_user: frappe.session.user },
    order_by: 'creation desc',
    limit_page_length: 50
  },
  auto: true
})

// Socket connection
let socket = null

const connectSocket = () => {
  if (typeof io === 'undefined') return
  
  socket = io('/', {
    withCredentials: true,
    transports: ['websocket']
  })
  
  // Listen for new notifications
  socket.on('new_notification', (data) => {
    // Add new notification to the top of the list
    notifications.setData(currentData => [data, ...currentData])
  })
  
  // Listen for document updates
  socket.on('doc_update', (data) => {
    if (data.doctype === 'Notification Log') {
      // Update specific notification
      notifications.setData(currentData => 
        currentData.map(notif => 
          notif.name === data.name 
            ? { ...notif, ...data.doc }
            : notif
        )
      )
    }
  })
}

const disconnectSocket = () => {
  if (socket) {
    socket.disconnect()
    socket = null
  }
}

onMounted(connectSocket)
onUnmounted(disconnectSocket)
```

#### Auto-refresh Pattern
```javascript
import { createResource } from 'frappe-ui'
import { ref, onMounted, onUnmounted } from 'vue'

const dashboardStats = createResource({
  url: 'custom_app.api.get_dashboard_stats',
  auto: true,
  cache: false // Disable caching for fresh data
})

const refreshInterval = ref(null)

const startAutoRefresh = (intervalMs = 30000) => {
  refreshInterval.value = setInterval(() => {
    if (!document.hidden) { // Only refresh when tab is active
      dashboardStats.reload()
    }
  }, intervalMs)
}

const stopAutoRefresh = () => {
  if (refreshInterval.value) {
    clearInterval(refreshInterval.value)
    refreshInterval.value = null
  }
}

// Handle visibility change
const handleVisibilityChange = () => {
  if (document.hidden) {
    stopAutoRefresh()
  } else {
    dashboardStats.reload() // Refresh immediately when tab becomes active
    startAutoRefresh()
  }
}

onMounted(() => {
  startAutoRefresh()
  document.addEventListener('visibilitychange', handleVisibilityChange)
})

onUnmounted(() => {
  stopAutoRefresh()
  document.removeEventListener('visibilitychange', handleVisibilityChange)
})
```

### 6. Error Handling & Retry Logic

#### Comprehensive Error Handling
```javascript
import { createResource, createToast } from 'frappe-ui'

const customers = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'Customer',
    fields: ['name', 'customer_name']
  },
  
  onError(error) {
    console.error('Failed to load customers:', error)
    
    let message = 'Failed to load customers'
    
    if (error.httpStatus === 500) {
      message = 'Server error. Please try again later.'
    } else if (error.httpStatus === 403) {
      message = 'You do not have permission to view customers'
    } else if (error.httpStatus === 404) {
      message = 'Customer data not found'
    } else if (error.exc_type === 'ValidationError') {
      message = error.exc || 'Invalid request parameters'
    }
    
    createToast({
      title: 'Error',
      text: message,
      icon: 'alert-circle',
      iconClasses: 'text-red-600',
      timeout: 0 // Don't auto-dismiss errors
    })
  }
})

// Retry mechanism
const retryCount = ref(0)
const maxRetries = 3

const loadCustomersWithRetry = async () => {
  try {
    await customers.fetch()
    retryCount.value = 0 // Reset on success
  } catch (error) {
    if (retryCount.value < maxRetries) {
      retryCount.value++
      
      // Exponential backoff
      const delay = Math.pow(2, retryCount.value) * 1000
      
      createToast({
        title: 'Retrying...',
        text: `Attempt ${retryCount.value} of ${maxRetries}`,
        icon: 'refresh-cw',
        timeout: 2000
      })
      
      setTimeout(() => {
        loadCustomersWithRetry()
      }, delay)
    } else {
      createToast({
        title: 'Failed',
        text: 'Unable to load data after multiple attempts',
        icon: 'x-circle',
        iconClasses: 'text-red-600'
      })
    }
  }
}
```

### 7. Performance Optimization Patterns

#### Resource Caching Strategy
```javascript
import { createResource, getCachedResource } from 'frappe-ui'

// Long-lived cached resources
const userProfiles = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'User',
    fields: ['name', 'full_name', 'user_image']
  },
  cache: 'user-profiles',
  auto: true
})

// Check cache before creating new resource
const getUserProfile = (userId) => {
  // Check if we already have the data cached
  const cached = getCachedResource('user-profiles')
  if (cached && cached.data) {
    return cached.data.find(user => user.name === userId)
  }
  
  return null
}

// Short-lived resources for dynamic data
const recentActivities = createResource({
  url: 'custom_app.api.get_recent_activities',
  cache: false, // Disable caching for dynamic data
  auto: true
})
```

#### Debounced Search Pattern
```javascript
import { createResource } from 'frappe-ui'
import { ref, watch } from 'vue'
import debounce from 'lodash/debounce'

const searchQuery = ref('')
const searchResults = ref([])

const searchResource = createResource({
  url: 'frappe.client.get_list',
  debounce: 300, // Built-in debouncing
  
  makeParams: (query) => ({
    doctype: 'Customer',
    fields: ['name', 'customer_name', 'email'],
    filters: query ? {
      customer_name: ['like', `%${query}%`]
    } : {},
    limit_page_length: 10
  }),
  
  onSuccess(data) {
    searchResults.value = data
  }
})

// Alternative manual debouncing
const debouncedSearch = debounce(async (query) => {
  if (!query.trim()) {
    searchResults.value = []
    return
  }
  
  await searchResource.submit(query)
}, 300)

watch(searchQuery, debouncedSearch)
```

### 8. Bulk Operations

#### Batch Processing
```javascript
import { createResource } from 'frappe-ui'

const batchUpdate = createResource({
  url: 'frappe.client.bulk_update',
  onSuccess(results) {
    console.log('Bulk update completed:', results)
    // Refresh the main list
    customers.reload()
  }
})

const bulkUpdateCustomers = async (customerNames, updates) => {
  const docs = customerNames.map(name => ({
    doctype: 'Customer',
    name: name,
    ...updates
  }))
  
  await batchUpdate.submit({
    docs: docs
  })
}

// Bulk delete
const batchDelete = createResource({
  url: 'custom_app.api.bulk_delete',
  onSuccess(results) {
    console.log('Bulk delete completed:', results)
    customers.reload()
  }
})

const bulkDeleteCustomers = async (customerNames) => {
  const confirmed = confirm(`Delete ${customerNames.length} customers?`)
  if (!confirmed) return
  
  await batchDelete.submit({
    doctype: 'Customer',
    names: customerNames
  })
}
```

### 9. Advanced Query Patterns

#### Complex Filtering
```javascript
const advancedCustomerSearch = createResource({
  url: 'frappe.client.get_list',
  makeParams: (filters) => {
    const docFilters = {}
    
    // Date range filter
    if (filters.dateRange) {
      docFilters.creation = ['between', [
        filters.dateRange.start,
        filters.dateRange.end
      ]]
    }
    
    // Multiple select filter
    if (filters.territories && filters.territories.length > 0) {
      docFilters.territory = ['in', filters.territories]
    }
    
    // Numeric range filter
    if (filters.creditLimitRange) {
      const conditions = []
      if (filters.creditLimitRange.min) {
        conditions.push(['credit_limit', '>=', filters.creditLimitRange.min])
      }
      if (filters.creditLimitRange.max) {
        conditions.push(['credit_limit', '<=', filters.creditLimitRange.max])
      }
      if (conditions.length > 0) {
        docFilters.credit_limit = conditions
      }
    }
    
    // Text search across multiple fields
    if (filters.search) {
      docFilters['name,customer_name,email_id'] = ['like', `%${filters.search}%`]
    }
    
    return {
      doctype: 'Customer',
      fields: ['name', 'customer_name', 'territory', 'credit_limit'],
      filters: docFilters,
      order_by: filters.sortBy || 'customer_name asc'
    }
  }
})
```

#### Aggregation Queries
```javascript
const salesSummary = createResource({
  url: 'frappe.client.get_list',
  makeParams: (period) => ({
    doctype: 'Sales Invoice',
    fields: [
      'customer',
      'sum(grand_total) as total_sales',
      'count(name) as invoice_count',
      'avg(grand_total) as avg_invoice_value'
    ],
    filters: {
      posting_date: ['>=', period.startDate],
      docstatus: 1
    },
    group_by: 'customer',
    order_by: 'total_sales desc',
    limit_page_length: 50
  })
})
```

This comprehensive guide covers all essential data fetching patterns for building robust ERPNext Vue applications with efficient resource management and optimal performance.