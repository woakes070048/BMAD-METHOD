# Vue SPA Patterns for ERPNext Applications

## Core Vue 3 Patterns

### Composition API with Script Setup
Modern Vue 3 syntax for cleaner, more maintainable components

```vue
<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { storeToRefs } from 'pinia'
import { useAuthStore } from '@/stores/auth'

// Props with TypeScript
interface Props {
  doctype: string
  name?: string
  readonly?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  readonly: false
})

// Emits with TypeScript
const emit = defineEmits<{
  save: [data: any]
  cancel: []
}>()

// Reactive state
const loading = ref(false)
const formData = ref({})

// Store usage
const authStore = useAuthStore()
const { user, isLoggedIn } = storeToRefs(authStore)

// Computed properties
const canEdit = computed(() => {
  return !props.readonly && isLoggedIn.value
})

// Watchers
watch(() => props.name, async (newName) => {
  if (newName) {
    await loadDocument(newName)
  }
})

// Lifecycle
onMounted(async () => {
  await initializeComponent()
})

// Methods
async function loadDocument(name: string) {
  loading.value = true
  try {
    // Load document logic
  } finally {
    loading.value = false
  }
}
</script>
```

### Composables Pattern
Reusable logic extraction

```javascript
// composables/useDocument.js
import { ref, computed } from 'vue'
import { createResource } from 'frappe-ui'

export function useDocument(doctype, name) {
  const resource = createResource({
    url: 'frappe.client.get',
    params: { doctype, name },
    auto: true
  })
  
  const document = computed(() => resource.data)
  const loading = computed(() => resource.loading)
  const error = computed(() => resource.error)
  
  async function save(data) {
    await resource.update({
      url: 'frappe.client.save',
      params: { doc: { ...document.value, ...data } }
    })
  }
  
  async function reload() {
    await resource.reload()
  }
  
  return {
    document,
    loading,
    error,
    save,
    reload
  }
}

// Usage in component
const { document, loading, save } = useDocument('Customer', 'CUST-001')
```

### Provide/Inject Pattern
Cross-component communication without prop drilling

```javascript
// Parent component
import { provide } from 'vue'

const appConfig = {
  apiUrl: import.meta.env.VITE_API_URL,
  theme: 'light'
}

provide('appConfig', appConfig)

// Child component (any depth)
import { inject } from 'vue'

const appConfig = inject('appConfig')
```

## State Management Patterns

### Pinia Store Patterns

#### Setup Store Pattern
```javascript
// stores/contacts.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { createListResource } from 'frappe-ui'

export const useContactsStore = defineStore('contacts', () => {
  // State
  const contacts = ref([])
  const filters = ref({})
  const sortBy = ref('modified desc')
  const currentPage = ref(1)
  const pageSize = ref(20)
  
  // Resource
  const listResource = createListResource({
    doctype: 'Contact',
    fields: ['name', 'first_name', 'last_name', 'email', 'phone'],
    filters: filters.value,
    orderBy: sortBy.value,
    pageLength: pageSize.value,
    start: (currentPage.value - 1) * pageSize.value
  })
  
  // Getters
  const totalContacts = computed(() => listResource.data?.total || 0)
  const hasNextPage = computed(() => {
    return currentPage.value * pageSize.value < totalContacts.value
  })
  
  // Actions
  async function fetchContacts() {
    await listResource.fetch()
    contacts.value = listResource.data?.data || []
  }
  
  function setFilters(newFilters) {
    filters.value = newFilters
    currentPage.value = 1
    fetchContacts()
  }
  
  function nextPage() {
    if (hasNextPage.value) {
      currentPage.value++
      fetchContacts()
    }
  }
  
  function previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--
      fetchContacts()
    }
  }
  
  return {
    // State
    contacts,
    filters,
    sortBy,
    currentPage,
    pageSize,
    
    // Getters
    totalContacts,
    hasNextPage,
    
    // Actions
    fetchContacts,
    setFilters,
    nextPage,
    previousPage
  }
})
```

#### Store Composition Pattern
```javascript
// stores/app.js
export const useAppStore = defineStore('app', () => {
  // Compose other stores
  const authStore = useAuthStore()
  const settingsStore = useSettingsStore()
  
  // Global app state
  const sidebarOpen = ref(true)
  const commandPaletteOpen = ref(false)
  const globalSearch = ref('')
  
  // Global loading state
  const globalLoading = computed(() => {
    return authStore.loading || settingsStore.loading
  })
  
  return {
    sidebarOpen,
    commandPaletteOpen,
    globalSearch,
    globalLoading
  }
})
```

## Component Patterns

### Smart vs Presentational Components

#### Smart Component (Container)
```vue
<!-- pages/ContactList.vue -->
<script setup>
import { onMounted } from 'vue'
import { useContactsStore } from '@/stores/contacts'
import ContactTable from '@/components/ContactTable.vue'
import ContactFilters from '@/components/ContactFilters.vue'

const contactsStore = useContactsStore()

onMounted(() => {
  contactsStore.fetchContacts()
})

function handleFilterChange(filters) {
  contactsStore.setFilters(filters)
}

function handleSort(field) {
  contactsStore.sortBy = field
  contactsStore.fetchContacts()
}
</script>

<template>
  <div>
    <ContactFilters @change="handleFilterChange" />
    <ContactTable
      :contacts="contactsStore.contacts"
      :loading="contactsStore.loading"
      @sort="handleSort"
    />
  </div>
</template>
```

#### Presentational Component (Dumb)
```vue
<!-- components/ContactTable.vue -->
<script setup>
defineProps({
  contacts: Array,
  loading: Boolean
})

const emit = defineEmits(['sort', 'select'])
</script>

<template>
  <table>
    <thead>
      <tr>
        <th @click="emit('sort', 'name')">Name</th>
        <th @click="emit('sort', 'email')">Email</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="contact in contacts" :key="contact.name">
        <td>{{ contact.name }}</td>
        <td>{{ contact.email }}</td>
      </tr>
    </tbody>
  </table>
</template>
```

### Slot Patterns

#### Named Slots with Props
```vue
<!-- components/DataCard.vue -->
<template>
  <div class="card">
    <div class="card-header">
      <slot name="header" :item="item">
        <h3>{{ item.title }}</h3>
      </slot>
    </div>
    
    <div class="card-body">
      <slot :item="item">
        Default content
      </slot>
    </div>
    
    <div class="card-footer">
      <slot name="footer" :actions="actions">
        <button v-for="action in actions" :key="action.name">
          {{ action.label }}
        </button>
      </slot>
    </div>
  </div>
</template>

<!-- Usage -->
<DataCard :item="contact">
  <template #header="{ item }">
    <h2>{{ item.first_name }} {{ item.last_name }}</h2>
  </template>
  
  <template #default="{ item }">
    <p>Email: {{ item.email }}</p>
  </template>
  
  <template #footer>
    <Button @click="edit">Edit</Button>
    <Button @click="delete">Delete</Button>
  </template>
</DataCard>
```

### Renderless Component Pattern
```vue
<!-- components/MouseTracker.vue -->
<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const x = ref(0)
const y = ref(0)

function update(event) {
  x.value = event.pageX
  y.value = event.pageY
}

onMounted(() => window.addEventListener('mousemove', update))
onUnmounted(() => window.removeEventListener('mousemove', update))
</script>

<template>
  <slot :x="x" :y="y" />
</template>

<!-- Usage -->
<MouseTracker v-slot="{ x, y }">
  Mouse position: {{ x }}, {{ y }}
</MouseTracker>
```

## Routing Patterns

### Route Guards
```javascript
// router/index.js
import { useAuthStore } from '@/stores/auth'

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  
  // Initialize auth if not already done
  if (!authStore.initialized) {
    await authStore.init()
  }
  
  // Public routes
  if (to.meta.public) {
    return next()
  }
  
  // Auth required
  if (!authStore.isLoggedIn) {
    return next({
      name: 'Login',
      query: { redirect: to.fullPath }
    })
  }
  
  // Permission check
  if (to.meta.permission) {
    const hasPermission = await authStore.checkPermission(to.meta.permission)
    if (!hasPermission) {
      return next({ name: 'Forbidden' })
    }
  }
  
  next()
})
```

### Dynamic Route Registration
```javascript
// Dynamically add routes based on user permissions
async function setupDynamicRoutes() {
  const authStore = useAuthStore()
  const permissions = await authStore.getPermissions()
  
  const dynamicRoutes = []
  
  if (permissions.includes('view_reports')) {
    dynamicRoutes.push({
      path: '/reports',
      name: 'Reports',
      component: () => import('@/pages/Reports.vue')
    })
  }
  
  if (permissions.includes('admin')) {
    dynamicRoutes.push({
      path: '/admin',
      name: 'Admin',
      component: () => import('@/pages/Admin.vue')
    })
  }
  
  dynamicRoutes.forEach(route => {
    router.addRoute('app', route)
  })
}
```

## Data Fetching Patterns

### Suspense with Async Components
```vue
<template>
  <Suspense>
    <template #default>
      <AsyncDashboard />
    </template>
    <template #fallback>
      <LoadingSpinner />
    </template>
  </Suspense>
</template>

<script setup>
import { defineAsyncComponent } from 'vue'

const AsyncDashboard = defineAsyncComponent({
  loader: () => import('@/pages/Dashboard.vue'),
  loadingComponent: LoadingSpinner,
  errorComponent: ErrorComponent,
  delay: 200,
  timeout: 3000
})
</script>
```

### Optimistic Updates
```javascript
// stores/todos.js
export const useTodosStore = defineStore('todos', () => {
  const todos = ref([])
  
  async function updateTodo(id, updates) {
    // Optimistic update
    const index = todos.value.findIndex(t => t.id === id)
    const oldTodo = { ...todos.value[index] }
    todos.value[index] = { ...oldTodo, ...updates }
    
    try {
      // Actual API call
      await api.updateTodo(id, updates)
    } catch (error) {
      // Rollback on error
      todos.value[index] = oldTodo
      throw error
    }
  }
})
```

### Infinite Scroll Pattern
```vue
<script setup>
import { ref, onMounted } from 'vue'
import { useIntersectionObserver } from '@vueuse/core'

const items = ref([])
const page = ref(1)
const loading = ref(false)
const hasMore = ref(true)
const loadMoreEl = ref()

async function loadMore() {
  if (loading.value || !hasMore.value) return
  
  loading.value = true
  try {
    const newItems = await fetchItems(page.value)
    items.value.push(...newItems)
    page.value++
    hasMore.value = newItems.length === 20
  } finally {
    loading.value = false
  }
}

useIntersectionObserver(loadMoreEl, ([{ isIntersecting }]) => {
  if (isIntersecting) {
    loadMore()
  }
})

onMounted(() => loadMore())
</script>

<template>
  <div>
    <div v-for="item in items" :key="item.id">
      {{ item.name }}
    </div>
    <div ref="loadMoreEl" v-if="hasMore">
      <LoadingSpinner v-if="loading" />
    </div>
  </div>
</template>
```

## Form Patterns

### Form Composition
```vue
<script setup>
import { ref, computed } from 'vue'
import { useField, useForm } from 'vee-validate'
import * as yup from 'yup'

const schema = yup.object({
  email: yup.string().email().required(),
  password: yup.string().min(8).required(),
  confirmPassword: yup.string()
    .oneOf([yup.ref('password')], 'Passwords must match')
    .required()
})

const { errors, handleSubmit, isSubmitting } = useForm({
  validationSchema: schema
})

const { value: email } = useField('email')
const { value: password } = useField('password')
const { value: confirmPassword } = useField('confirmPassword')

const onSubmit = handleSubmit(async (values) => {
  try {
    await api.register(values)
    router.push('/dashboard')
  } catch (error) {
    toast.error(error.message)
  }
})
</script>

<template>
  <form @submit="onSubmit">
    <FormControl
      v-model="email"
      label="Email"
      type="email"
      :error="errors.email"
    />
    <FormControl
      v-model="password"
      label="Password"
      type="password"
      :error="errors.password"
    />
    <FormControl
      v-model="confirmPassword"
      label="Confirm Password"
      type="password"
      :error="errors.confirmPassword"
    />
    <Button type="submit" :loading="isSubmitting">
      Register
    </Button>
  </form>
</template>
```

### Dynamic Form Fields
```vue
<script setup>
import { ref } from 'vue'

const fields = ref([
  { name: 'name', type: 'text', label: 'Name', required: true },
  { name: 'email', type: 'email', label: 'Email', required: true },
  { name: 'phone', type: 'tel', label: 'Phone', required: false }
])

const formData = ref({})

function addField() {
  fields.value.push({
    name: `field_${Date.now()}`,
    type: 'text',
    label: 'New Field',
    required: false
  })
}
</script>

<template>
  <form>
    <div v-for="field in fields" :key="field.name">
      <FormControl
        v-model="formData[field.name]"
        :type="field.type"
        :label="field.label"
        :required="field.required"
      />
    </div>
    <Button @click="addField">Add Field</Button>
  </form>
</template>
```

## Performance Patterns

### Lazy Loading Components
```javascript
// router/index.js
const routes = [
  {
    path: '/dashboard',
    component: () => import(
      /* webpackChunkName: "dashboard" */
      '@/pages/Dashboard.vue'
    )
  },
  {
    path: '/reports',
    component: () => import(
      /* webpackChunkName: "reports" */
      '@/pages/Reports.vue'
    )
  }
]
```

### Memo and Caching
```vue
<script setup>
import { computed, ref } from 'vue'

const items = ref([...])

// Expensive computation with caching
const processedItems = computed(() => {
  return items.value.map(item => {
    // Expensive operation
    return expensiveProcess(item)
  })
})

// Manual memoization
const cache = new Map()
function memoizedExpensiveOperation(input) {
  if (cache.has(input)) {
    return cache.get(input)
  }
  const result = expensiveOperation(input)
  cache.set(input, result)
  return result
}
</script>
```

### Virtual List Pattern
```vue
<script setup>
import { VirtualList } from '@tanstack/vue-virtual'

const items = ref(generateLargeList(10000))

function rowRenderer({ index, style }) {
  return h('div', { style }, items.value[index].name)
}
</script>

<template>
  <VirtualList
    :size="items.length"
    :height="600"
    :itemHeight="50"
    :renderItem="rowRenderer"
  />
</template>
```

## Error Handling Patterns

### Global Error Handler
```javascript
// main.js
app.config.errorHandler = (err, instance, info) => {
  console.error('Global error:', err, info)
  
  // Send to error tracking service
  if (import.meta.env.PROD) {
    errorTracker.report(err, {
      componentInfo: info,
      user: store.state.user
    })
  }
  
  // Show user-friendly error
  toast.error('An unexpected error occurred')
}

// Component error boundary
app.component('ErrorBoundary', {
  template: `
    <div v-if="hasError" class="error-boundary">
      <h2>Something went wrong</h2>
      <button @click="retry">Retry</button>
    </div>
    <slot v-else />
  `,
  data: () => ({ hasError: false }),
  errorCaptured(err, instance, info) {
    this.hasError = true
    console.error('Error captured:', err)
    return false // Prevent propagation
  },
  methods: {
    retry() {
      this.hasError = false
      this.$forceUpdate()
    }
  }
})
```

## Testing Patterns

### Component Testing
```javascript
import { mount } from '@vue/test-utils'
import { createTestingPinia } from '@pinia/testing'
import ContactList from '@/pages/ContactList.vue'

describe('ContactList', () => {
  it('displays contacts', async () => {
    const wrapper = mount(ContactList, {
      global: {
        plugins: [
          createTestingPinia({
            initialState: {
              contacts: {
                contacts: [
                  { id: 1, name: 'John Doe' },
                  { id: 2, name: 'Jane Smith' }
                ]
              }
            }
          })
        ]
      }
    })
    
    expect(wrapper.findAll('.contact-item')).toHaveLength(2)
    expect(wrapper.text()).toContain('John Doe')
  })
})
```

## Real-time Patterns

### WebSocket Integration
```javascript
// composables/useWebSocket.js
import { ref, onMounted, onUnmounted } from 'vue'
import { io } from 'socket.io-client'

export function useWebSocket(url) {
  const socket = ref(null)
  const connected = ref(false)
  const messages = ref([])
  
  onMounted(() => {
    socket.value = io(url)
    
    socket.value.on('connect', () => {
      connected.value = true
    })
    
    socket.value.on('disconnect', () => {
      connected.value = false
    })
    
    socket.value.on('message', (msg) => {
      messages.value.push(msg)
    })
  })
  
  onUnmounted(() => {
    if (socket.value) {
      socket.value.disconnect()
    }
  })
  
  function emit(event, data) {
    if (socket.value && connected.value) {
      socket.value.emit(event, data)
    }
  }
  
  return {
    connected,
    messages,
    emit
  }
}
```

## Best Practices Summary

1. **Use Composition API** for better code organization
2. **Extract reusable logic** into composables
3. **Implement proper TypeScript** types
4. **Follow single responsibility** principle
5. **Use Pinia** for state management
6. **Implement error boundaries** for robustness
7. **Optimize performance** with lazy loading
8. **Write tests** for critical paths
9. **Handle loading and error states** consistently
10. **Use frappe-ui components** for consistency