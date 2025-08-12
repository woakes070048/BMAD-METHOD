# Frappe UI createResource Patterns

## Overview
`createResource` is the primary data fetching utility in frappe-ui for making API calls to Frappe/ERPNext backend. It provides reactive data fetching with built-in loading states, error handling, and caching.

## Basic Usage

### Simple GET Request
```vue
<template>
  <div>
    <Button @click="userData.reload()">Refresh</Button>
    <div v-if="userData.loading">Loading...</div>
    <div v-else-if="userData.error">{{ userData.error }}</div>
    <div v-else>{{ userData.data }}</div>
  </div>
</template>

<script setup>
import { createResource } from 'frappe-ui'

const userData = createResource({
  url: 'frappe.client.get',
  params: {
    doctype: 'User',
    name: 'Administrator'
  },
  auto: true // Fetch automatically on mount
})
</script>
```

### POST Request with Parameters
```vue
<script setup>
import { createResource } from 'frappe-ui'
import { ref } from 'vue'

const formData = ref({
  title: '',
  description: ''
})

const createTask = createResource({
  url: 'custom_app.api.tasks.create_task',
  onSuccess(data) {
    console.log('Task created:', data)
    // Reset form or navigate
  },
  onError(error) {
    console.error('Failed to create task:', error)
  }
})

function submitTask() {
  createTask.submit(formData.value)
}
</script>
```

## Advanced Patterns

### List Resource with Pagination
```vue
<script setup>
import { createResource } from 'frappe-ui'
import { ref, computed } from 'vue'

const page = ref(1)
const pageSize = 20

const listResource = createResource({
  url: 'frappe.client.get_list',
  params: computed(() => ({
    doctype: 'Sales Order',
    fields: ['name', 'customer', 'grand_total', 'status'],
    filters: {
      status: ['!=', 'Cancelled']
    },
    order_by: 'creation desc',
    limit: pageSize,
    start: (page.value - 1) * pageSize
  })),
  auto: true
})

function nextPage() {
  page.value++
  listResource.reload()
}

function previousPage() {
  if (page.value > 1) {
    page.value--
    listResource.reload()
  }
}
</script>
```

### Document Resource (CRUD Operations)
```vue
<script setup>
import { createDocumentResource } from 'frappe-ui'
import { ref } from 'vue'

const docName = ref('SO-2024-00001')

const doc = createDocumentResource({
  doctype: 'Sales Order',
  name: docName,
  fields: ['*'], // Fetch all fields
  auto: true,
  onSuccess(data) {
    console.log('Document loaded:', data)
  }
})

// Update document
async function updateDoc(updates) {
  await doc.setValue(updates)
  await doc.save()
}

// Delete document
async function deleteDoc() {
  await doc.delete()
}

// Submit document
async function submitDoc() {
  await doc.submit()
}
</script>
```

### Custom List Resource
```vue
<script setup>
import { createListResource } from 'frappe-ui'

const orders = createListResource({
  doctype: 'Sales Order',
  fields: ['name', 'customer', 'grand_total', 'status'],
  filters: {
    status: ['!=', 'Cancelled']
  },
  orderBy: 'creation desc',
  pageLength: 20,
  auto: true
})

// Built-in pagination
orders.next() // Next page
orders.previous() // Previous page
orders.reload() // Refresh current page

// Access data
orders.data // Current page data
orders.hasNextPage // Boolean
orders.hasPreviousPage // Boolean
orders.loading // Loading state
orders.error // Error state
</script>
```

### Resource with Transform
```vue
<script setup>
import { createResource } from 'frappe-ui'

const dashboard = createResource({
  url: 'custom_app.api.dashboard.get_metrics',
  transform(data) {
    // Transform backend data before storing
    return {
      ...data,
      formattedRevenue: new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
      }).format(data.revenue),
      chartData: processChartData(data.raw_data)
    }
  },
  auto: true
})
</script>
```

### Debounced Search
```vue
<script setup>
import { createResource } from 'frappe-ui'
import { ref, watch } from 'vue'
import { debounce } from 'frappe-ui'

const searchQuery = ref('')

const searchResults = createResource({
  url: 'custom_app.api.search.global_search',
  params: {
    query: searchQuery
  },
  debounce: 300,
  auto: false
})

watch(searchQuery, debounce((newQuery) => {
  if (newQuery.length > 2) {
    searchResults.reload()
  }
}, 300))
</script>
```

### File Upload
```vue
<script setup>
import { createResource } from 'frappe-ui'

const uploadFile = createResource({
  url: 'upload_file',
  onSuccess(data) {
    console.log('File uploaded:', data.file_url)
  },
  onError(error) {
    console.error('Upload failed:', error)
  }
})

function handleFileSelect(event) {
  const file = event.target.files[0]
  const formData = new FormData()
  formData.append('file', file)
  formData.append('is_private', 0)
  formData.append('folder', 'Home')
  
  uploadFile.submit(null, {
    headers: {
      'Content-Type': 'multipart/form-data'
    },
    body: formData
  })
}
</script>
```

### Cached Resources
```vue
<script setup>
import { createResource } from 'frappe-ui'

// Cache configuration for frequently accessed data
const settings = createResource({
  url: 'custom_app.api.settings.get',
  cache: 'app-settings', // Cache key
  auto: true
})

// Another component can access cached data
const cachedSettings = createResource({
  url: 'custom_app.api.settings.get',
  cache: 'app-settings', // Same cache key
  auto: true // Will use cached data if available
})
</script>
```

### Dependent Resources
```vue
<script setup>
import { createResource } from 'frappe-ui'
import { ref, computed } from 'vue'

const selectedCustomer = ref(null)

// Primary resource
const customers = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'Customer',
    fields: ['name', 'customer_name']
  },
  auto: true
})

// Dependent resource
const customerOrders = createResource({
  url: 'frappe.client.get_list',
  params: computed(() => ({
    doctype: 'Sales Order',
    fields: ['*'],
    filters: {
      customer: selectedCustomer.value
    }
  })),
  auto: false // Manual trigger
})

// Watch for customer selection
watch(selectedCustomer, (newCustomer) => {
  if (newCustomer) {
    customerOrders.reload()
  }
})
</script>
```

## Error Handling Patterns

### Global Error Handler
```javascript
// In main.js or plugin
import { createResource } from 'frappe-ui'

// Set global error handler
createResource.setGlobalErrorHandler((error) => {
  if (error.response?.status === 403) {
    // Handle permission errors
    showToast({
      title: 'Permission Denied',
      text: error.message,
      icon: 'x',
      iconClasses: 'text-red-600'
    })
  } else if (error.response?.status === 404) {
    // Handle not found
    router.push('/404')
  } else {
    // Generic error handling
    console.error('API Error:', error)
  }
})
```

### Resource-level Error Handling
```vue
<script setup>
import { createResource } from 'frappe-ui'
import { ref } from 'vue'

const retryCount = ref(0)
const maxRetries = 3

const dataResource = createResource({
  url: 'custom_app.api.data.fetch',
  onError(error) {
    if (retryCount.value < maxRetries) {
      retryCount.value++
      setTimeout(() => {
        dataResource.reload()
      }, 1000 * retryCount.value) // Exponential backoff
    } else {
      // Max retries reached
      handleFinalError(error)
    }
  },
  auto: true
})
</script>
```

## Best Practices

### 1. Use Computed Params for Reactive Queries
```javascript
const resource = createResource({
  url: 'endpoint',
  params: computed(() => ({
    // Reactive parameters
    filter: activeFilter.value,
    sort: currentSort.value
  }))
})
```

### 2. Proper Loading States
```vue
<template>
  <div>
    <LoadingIndicator v-if="resource.loading" />
    <ErrorMessage v-else-if="resource.error" :error="resource.error" />
    <DataDisplay v-else :data="resource.data" />
  </div>
</template>
```

### 3. Resource Cleanup
```javascript
onBeforeUnmount(() => {
  // Cancel pending requests
  resource.reset()
})
```

### 4. Type Safety with TypeScript
```typescript
interface Task {
  name: string
  title: string
  status: string
}

const tasks = createResource<Task[]>({
  url: 'custom_app.api.tasks.list',
  auto: true
})

// tasks.data is typed as Task[]
```

### 5. Optimistic Updates
```javascript
const updateTask = createResource({
  url: 'custom_app.api.tasks.update',
  onSubmit(params) {
    // Optimistically update UI
    taskList.value = taskList.value.map(task => 
      task.name === params.name 
        ? { ...task, ...params.updates }
        : task
    )
  },
  onError() {
    // Revert optimistic update on error
    taskList.reload()
  }
})
```

## Integration with Stores (Pinia)

```javascript
// stores/customer.js
import { defineStore } from 'pinia'
import { createResource } from 'frappe-ui'

export const useCustomerStore = defineStore('customer', () => {
  const customerList = createResource({
    url: 'frappe.client.get_list',
    params: {
      doctype: 'Customer',
      fields: ['*']
    }
  })

  const selectedCustomer = createDocumentResource({
    doctype: 'Customer'
  })

  function loadCustomer(name) {
    selectedCustomer.name = name
    selectedCustomer.reload()
  }

  return {
    customerList,
    selectedCustomer,
    loadCustomer
  }
})
```

## Common Pitfalls to Avoid

1. **Not handling loading states** - Always show appropriate feedback
2. **Forgetting error handling** - Implement both local and global error handlers
3. **Over-fetching data** - Use field selection and pagination
4. **Not cleaning up resources** - Reset resources in component cleanup
5. **Ignoring caching** - Leverage caching for frequently accessed data
6. **Direct state mutation** - Always use proper update methods
7. **Not using computed params** - Makes queries non-reactive