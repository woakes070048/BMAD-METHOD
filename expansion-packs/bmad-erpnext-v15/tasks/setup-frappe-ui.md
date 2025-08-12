# Task: Setup frappe-ui in ERPNext Vue SPA

## Purpose
Configure and integrate frappe-ui component library into your Vue 3 application for consistent UI/UX

## Prerequisites
- Vue 3 SPA already created
- Node.js and Yarn installed
- TailwindCSS configured

## Installation

### 1. Install frappe-ui
```bash
cd frontend
yarn add frappe-ui@^0.1.171
```

### 2. Install Peer Dependencies
```bash
# Required peer dependencies
yarn add @headlessui/vue@^1.7.22
yarn add @iconify/vue@^4.1.1
yarn add socket.io-client@^4.7.2
```

## Configuration

### 1. Main.js Setup
```javascript
// src/main.js
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import {
  FrappeUI,
  setConfig,
  frappeRequest
} from 'frappe-ui'
import App from './App.vue'
import router from './router'
import './index.css'

// Configure frappe-ui
setConfig('resourceFetcher', frappeRequest)

const app = createApp(App)
const pinia = createPinia()

// Use plugins
app.use(pinia)
app.use(router)
app.use(FrappeUI)

// Mount app
app.mount('#app')
```

### 2. Configure Request Handler
```javascript
// src/utils/frappeRequest.js
import { frappeRequest } from 'frappe-ui'

// Configure base URL
frappeRequest.configure({
  baseURL: import.meta.env.VITE_FRAPPE_URL || '',
  headers: {
    'X-Frappe-CSRF-Token': window.csrf_token
  }
})

export default frappeRequest
```

### 3. Update Vite Config
```javascript
// vite.config.js
export default defineConfig({
  // ... other config
  optimizeDeps: {
    include: [
      'frappe-ui',
      '@headlessui/vue',
      'socket.io-client'
    ]
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
      'frappe-ui': 'frappe-ui/src'
    }
  }
})
```

## Basic Component Usage

### 1. Button Component
```vue
<template>
  <div class="space-x-2">
    <Button variant="solid" @click="handleClick">
      Solid Button
    </Button>
    <Button variant="outline">
      Outline Button
    </Button>
    <Button variant="ghost" :loading="loading">
      Ghost Button
    </Button>
    <Button variant="subtle" icon="plus">
      With Icon
    </Button>
  </div>
</template>

<script setup>
import { Button } from 'frappe-ui'
import { ref } from 'vue'

const loading = ref(false)

function handleClick() {
  loading.value = true
  setTimeout(() => {
    loading.value = false
  }, 2000)
}
</script>
```

### 2. Form Controls
```vue
<template>
  <form @submit.prevent="handleSubmit">
    <FormControl
      v-model="form.name"
      label="Name"
      placeholder="Enter your name"
      :required="true"
      :error="errors.name"
    />
    
    <FormControl
      v-model="form.email"
      type="email"
      label="Email"
      placeholder="Enter email"
      :required="true"
      :error="errors.email"
    />
    
    <FormControl
      v-model="form.description"
      type="textarea"
      label="Description"
      :rows="4"
    />
    
    <Button type="submit" variant="solid">
      Submit
    </Button>
  </form>
</template>

<script setup>
import { FormControl, Button } from 'frappe-ui'
import { ref } from 'vue'

const form = ref({
  name: '',
  email: '',
  description: ''
})

const errors = ref({})

function handleSubmit() {
  // Validation and submission logic
}
</script>
```

### 3. Dialog/Modal
```vue
<template>
  <div>
    <Button @click="showDialog = true">
      Open Dialog
    </Button>
    
    <Dialog
      v-model="showDialog"
      :options="{
        title: 'Confirm Action',
        size: 'md'
      }"
    >
      <template #body>
        <p>Are you sure you want to proceed?</p>
      </template>
      
      <template #actions>
        <Button variant="ghost" @click="showDialog = false">
          Cancel
        </Button>
        <Button variant="solid" @click="handleConfirm">
          Confirm
        </Button>
      </template>
    </Dialog>
  </div>
</template>

<script setup>
import { Dialog, Button } from 'frappe-ui'
import { ref } from 'vue'

const showDialog = ref(false)

function handleConfirm() {
  // Handle confirmation
  showDialog.value = false
}
</script>
```

## Resource Management

### 1. Using createResource
```vue
<script setup>
import { createResource } from 'frappe-ui'
import { computed } from 'vue'

const userResource = createResource({
  url: 'frappe.auth.get_logged_user',
  auto: true, // Auto-fetch on mount
  onSuccess(data) {
    console.log('User loaded:', data)
  },
  onError(error) {
    console.error('Error loading user:', error)
  }
})

const user = computed(() => userResource.data)
const loading = computed(() => userResource.loading)

// Manual fetch
function refreshUser() {
  userResource.fetch()
}
</script>

<template>
  <div v-if="loading">
    <LoadingIndicator />
  </div>
  <div v-else-if="user">
    Welcome, {{ user.full_name }}
    <Button @click="refreshUser">Refresh</Button>
  </div>
</template>
```

### 2. Using createListResource
```vue
<script setup>
import { createListResource } from 'frappe-ui'
import { onMounted } from 'vue'

const contacts = createListResource({
  doctype: 'Contact',
  fields: ['name', 'first_name', 'last_name', 'email'],
  filters: { status: 'Active' },
  orderBy: 'modified desc',
  pageLength: 20,
  auto: false
})

onMounted(() => {
  contacts.fetch()
})

// Pagination
function nextPage() {
  contacts.next()
}

function previousPage() {
  contacts.previous()
}

// Update filters
function applyFilter(newFilters) {
  contacts.update({
    filters: newFilters
  })
  contacts.fetch()
}
</script>

<template>
  <ListView
    :columns="columns"
    :rows="contacts.data"
    :loading="contacts.loading"
  />
  <div class="flex justify-between">
    <Button @click="previousPage" :disabled="!contacts.hasPreviousPage">
      Previous
    </Button>
    <Button @click="nextPage" :disabled="!contacts.hasNextPage">
      Next
    </Button>
  </div>
</template>
```

### 3. Using createDocumentResource
```vue
<script setup>
import { createDocumentResource } from 'frappe-ui'
import { toast } from 'frappe-ui'

const props = defineProps(['docname'])

const document = createDocumentResource({
  doctype: 'Customer',
  name: props.docname,
  fields: '*',
  auto: true,
  onSuccess() {
    toast.success('Document loaded')
  }
})

async function saveDocument() {
  try {
    await document.save()
    toast.success('Saved successfully')
  } catch (error) {
    toast.error('Failed to save')
  }
}

function updateField(field, value) {
  document.setValue(field, value)
}
</script>

<template>
  <form @submit.prevent="saveDocument">
    <FormControl
      :value="document.doc?.customer_name"
      @update:value="(val) => updateField('customer_name', val)"
      label="Customer Name"
    />
    <Button type="submit" :loading="document.saving">
      Save
    </Button>
  </form>
</template>
```

## Advanced Components

### 1. Data Table with ListView
```vue
<template>
  <ListView
    :columns="columns"
    :rows="items"
    :options="{
      selectable: true,
      showTooltip: true,
      onRowClick: handleRowClick
    }"
  >
    <template #header>
      <div class="flex justify-between">
        <h2>Items List</h2>
        <Button @click="addNew">Add New</Button>
      </div>
    </template>
    
    <template #cell="{ column, row }">
      <div v-if="column.key === 'status'">
        <Badge :variant="getStatusVariant(row.status)">
          {{ row.status }}
        </Badge>
      </div>
    </template>
    
    <template #empty>
      <EmptyState
        title="No items found"
        description="Create your first item to get started"
      />
    </template>
  </ListView>
</template>

<script setup>
import { ListView, Button, Badge, EmptyState } from 'frappe-ui'

const columns = [
  { label: 'Name', key: 'name', width: '200px' },
  { label: 'Description', key: 'description' },
  { label: 'Status', key: 'status', width: '100px' }
]

const items = ref([])

function handleRowClick(row) {
  router.push(`/items/${row.name}`)
}

function getStatusVariant(status) {
  return status === 'Active' ? 'success' : 'gray'
}
</script>
```

### 2. Toast Notifications
```javascript
// In any component or composable
import { toast } from 'frappe-ui'

// Success toast
toast.success('Operation completed successfully')

// Error toast
toast.error('Something went wrong')

// Info toast
toast.info('Please note this information')

// Warning toast
toast.warning('This action cannot be undone')

// Custom toast
toast({
  title: 'Custom Notification',
  text: 'With additional details',
  icon: 'check-circle',
  position: 'top-right',
  duration: 5000
})
```

### 3. Dropdown Menu
```vue
<template>
  <Dropdown
    :options="dropdownOptions"
    placement="bottom-end"
  >
    <Button icon="more-horizontal" variant="ghost" />
  </Dropdown>
</template>

<script setup>
import { Dropdown, Button } from 'frappe-ui'
import { useRouter } from 'vue-router'

const router = useRouter()

const dropdownOptions = [
  {
    label: 'Edit',
    icon: 'edit',
    onClick: () => router.push('/edit')
  },
  {
    label: 'Duplicate',
    icon: 'copy',
    onClick: () => handleDuplicate()
  },
  {
    label: 'Separator',
    type: 'separator'
  },
  {
    label: 'Delete',
    icon: 'trash',
    variant: 'danger',
    onClick: () => handleDelete()
  }
]
</script>
```

## Theme Customization

### 1. Extend TailwindCSS Config
```javascript
// tailwind.config.js
export default {
  content: [
    './index.html',
    './src/**/*.{vue,js,ts,jsx,tsx}',
    './node_modules/frappe-ui/src/**/*.{vue,js,ts}'
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#171717',
          50: '#f5f5f5',
          // ... more shades
        }
      }
    }
  }
}
```

### 2. Custom CSS Variables
```css
/* src/index.css */
:root {
  --fr-btn-primary: theme('colors.primary.DEFAULT');
  --fr-btn-primary-hover: theme('colors.primary.600');
  --fr-border-color: theme('colors.gray.200');
  --fr-text-color: theme('colors.gray.900');
}

.dark {
  --fr-btn-primary: theme('colors.primary.400');
  --fr-btn-primary-hover: theme('colors.primary.500');
  --fr-border-color: theme('colors.gray.700');
  --fr-text-color: theme('colors.gray.100');
}
```

## Error Handling

### Global Error Handler for Resources
```javascript
// src/utils/errorHandler.js
import { toast } from 'frappe-ui'

export function handleResourceError(error) {
  console.error('Resource error:', error)
  
  if (error.response?.status === 403) {
    toast.error('You do not have permission to perform this action')
  } else if (error.response?.status === 404) {
    toast.error('Resource not found')
  } else if (error.response?.status === 500) {
    toast.error('Server error. Please try again later')
  } else {
    toast.error(error.message || 'An unexpected error occurred')
  }
}

// Usage in resource
const resource = createResource({
  url: 'api.method',
  onError: handleResourceError
})
```

## Testing frappe-ui Components

```javascript
// tests/Button.spec.js
import { mount } from '@vue/test-utils'
import { Button } from 'frappe-ui'

describe('Button Component', () => {
  it('renders correctly', () => {
    const wrapper = mount(Button, {
      props: {
        variant: 'solid'
      },
      slots: {
        default: 'Click me'
      }
    })
    
    expect(wrapper.text()).toBe('Click me')
    expect(wrapper.classes()).toContain('btn-solid')
  })
  
  it('shows loading state', async () => {
    const wrapper = mount(Button, {
      props: {
        loading: true
      }
    })
    
    expect(wrapper.find('.loading-spinner').exists()).toBe(true)
    expect(wrapper.attributes('disabled')).toBeDefined()
  })
})
```

## Common Issues & Solutions

### Issue: Components not rendering
**Solution**: Ensure frappe-ui is properly registered in main.js

### Issue: Styles not applied
**Solution**: Check TailwindCSS configuration includes frappe-ui path

### Issue: Resources not fetching
**Solution**: Verify CSRF token and API endpoint configuration

### Issue: TypeScript errors
**Solution**: Add frappe-ui type declarations:
```typescript
// src/types/frappe-ui.d.ts
declare module 'frappe-ui' {
  export const Button: any
  export const FormControl: any
  // ... other components
}
```

## Best Practices

1. **Always use frappe-ui components** when available
2. **Handle loading and error states** for all resources
3. **Use toast notifications** for user feedback
4. **Implement proper form validation**
5. **Follow consistent styling** with TailwindCSS
6. **Test component integrations**
7. **Document custom component usage**
8. **Keep frappe-ui updated** to latest version

## Next Steps
1. Explore all available components
2. Create custom composite components
3. Implement complex forms
4. Add keyboard shortcuts
5. Optimize bundle size