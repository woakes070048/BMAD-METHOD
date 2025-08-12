# Frappe UI Component Library Patterns
## Comprehensive Component Reference for Vue Development with ERPNext

**Last Updated**: 2025-08-11  
**Framework Version**: Frappe UI 0.1.x | Vue 3.4+ | ERPNext 15  
**Source**: Production patterns from CRM, HRMS, and Frappe UI library

---

## 🎯 Core Component Categories

### 1. Input & Form Components

#### Button Component
```vue
<template>
  <!-- Basic button patterns -->
  <Button variant="solid">Primary Action</Button>
  <Button variant="subtle">Secondary Action</Button>
  <Button variant="ghost">Tertiary Action</Button>
  <Button variant="outline">Alternative Action</Button>
  
  <!-- Size variants -->
  <Button size="xs">Extra Small</Button>
  <Button size="sm">Small</Button>
  <Button size="md">Medium (default)</Button>
  <Button size="lg">Large</Button>
  
  <!-- Loading states -->
  <Button :loading="isSubmitting" :disabled="!canSubmit">
    Submit Form
  </Button>
  
  <!-- Icon buttons -->
  <Button icon="plus">Add New</Button>
  <Button icon-left="download">Download</Button>
  <Button icon-right="external-link">Open</Button>
</template>

<script setup>
import { Button } from 'frappe-ui'
import { ref, computed } from 'vue'

const isSubmitting = ref(false)
const formData = ref({})

const canSubmit = computed(() => {
  return Object.values(formData.value).every(val => val)
})

const handleSubmit = async () => {
  isSubmitting.value = true
  try {
    // API call logic here
  } finally {
    isSubmitting.value = false
  }
}
</script>
```

#### FormControl Component
```vue
<template>
  <!-- Text input with validation -->
  <FormControl
    v-model="form.email"
    label="Email Address"
    type="email"
    placeholder="Enter your email"
    :error-message="errors.email"
    required
  />
  
  <!-- Select dropdown -->
  <FormControl
    v-model="form.status"
    label="Status"
    type="select"
    :options="statusOptions"
    placeholder="Select status"
  />
  
  <!-- Textarea -->
  <FormControl
    v-model="form.description"
    label="Description"
    type="textarea"
    placeholder="Enter description"
    rows="4"
  />
  
  <!-- File upload -->
  <FormControl
    v-model="form.attachment"
    label="Attachment"
    type="file"
    accept=".pdf,.doc,.docx"
    @change="handleFileUpload"
  />
  
  <!-- Date picker -->
  <FormControl
    v-model="form.date"
    label="Due Date"
    type="date"
    :min="today"
  />
  
  <!-- Number input with formatting -->
  <FormControl
    v-model="form.amount"
    label="Amount"
    type="number"
    :format-value="formatCurrency"
    step="0.01"
  />
</template>

<script setup>
import { FormControl } from 'frappe-ui'
import { reactive, ref } from 'vue'

const form = reactive({
  email: '',
  status: '',
  description: '',
  attachment: null,
  date: '',
  amount: 0
})

const errors = ref({})

const statusOptions = [
  { label: 'Open', value: 'Open' },
  { label: 'In Progress', value: 'In Progress' },
  { label: 'Closed', value: 'Closed' }
]

const formatCurrency = (value) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD'
  }).format(value)
}

const handleFileUpload = (file) => {
  // File handling logic
  console.log('File uploaded:', file)
}
</script>
```

#### Advanced Input Patterns
```vue
<template>
  <!-- Autocomplete with resource -->
  <Autocomplete
    v-model="selectedUser"
    :options="userOptions"
    placeholder="Search users..."
    :loading="users.loading"
    @search="searchUsers"
  >
    <template #prefix>
      <FeatherIcon name="user" class="w-4 h-4" />
    </template>
    <template #option="{ option }">
      <div class="flex items-center space-x-2">
        <Avatar :label="option.full_name" size="sm" />
        <div>
          <div class="font-medium">{{ option.full_name }}</div>
          <div class="text-sm text-gray-500">{{ option.email }}</div>
        </div>
      </div>
    </template>
  </Autocomplete>
  
  <!-- Multi-select with custom chips -->
  <div class="space-y-2">
    <label class="block text-sm font-medium">Tags</label>
    <div class="flex flex-wrap gap-2 mb-2">
      <Badge
        v-for="tag in selectedTags"
        :key="tag"
        variant="subtle"
        class="cursor-pointer"
        @click="removeTag(tag)"
      >
        {{ tag }}
        <FeatherIcon name="x" class="w-3 h-3 ml-1" />
      </Badge>
    </div>
    <Input
      v-model="tagInput"
      placeholder="Add tags..."
      @keydown.enter="addTag"
      @keydown.comma="addTag"
    />
  </div>
</template>

<script setup>
import { Autocomplete, Input, Avatar, Badge, FeatherIcon } from 'frappe-ui'
import { ref, computed } from 'vue'
import { createResource } from 'frappe-ui'

// User search with resource
const selectedUser = ref(null)
const users = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'User',
    fields: ['name', 'full_name', 'email', 'user_image'],
    filters: { enabled: 1 }
  }
})

const userOptions = computed(() => users.data || [])

const searchUsers = (query) => {
  users.update({
    params: {
      ...users.params,
      filters: {
        ...users.params.filters,
        full_name: ['like', `%${query}%`]
      }
    }
  })
  users.reload()
}

// Tag management
const selectedTags = ref(['urgent', 'follow-up'])
const tagInput = ref('')

const addTag = () => {
  const tag = tagInput.value.trim().replace(',', '')
  if (tag && !selectedTags.value.includes(tag)) {
    selectedTags.value.push(tag)
    tagInput.value = ''
  }
}

const removeTag = (tag) => {
  selectedTags.value = selectedTags.value.filter(t => t !== tag)
}
</script>
```

### 2. Display Components

#### Avatar Component
```vue
<template>
  <!-- User avatars with different sources -->
  <div class="flex items-center space-x-4">
    <!-- Image avatar -->
    <Avatar
      :image="user.user_image"
      :label="user.full_name"
      size="lg"
    />
    
    <!-- Initials avatar -->
    <Avatar :label="user.full_name" size="md" />
    
    <!-- Small avatar for lists -->
    <Avatar :label="user.full_name" size="sm" />
    
    <!-- Extra small for compact views -->
    <Avatar :label="user.full_name" size="xs" />
  </div>
  
  <!-- Avatar with online indicator -->
  <div class="relative">
    <Avatar :image="user.user_image" :label="user.full_name" size="lg" />
    <div class="absolute bottom-0 right-0 w-4 h-4 bg-green-500 border-2 border-white rounded-full"></div>
  </div>
  
  <!-- Avatar group for team display -->
  <div class="flex -space-x-2">
    <Avatar
      v-for="member in team.slice(0, 3)"
      :key="member.name"
      :image="member.user_image"
      :label="member.full_name"
      size="sm"
      class="border-2 border-white"
    />
    <div
      v-if="team.length > 3"
      class="flex items-center justify-center w-8 h-8 bg-gray-300 rounded-full border-2 border-white text-xs font-medium"
    >
      +{{ team.length - 3 }}
    </div>
  </div>
</template>

<script setup>
import { Avatar } from 'frappe-ui'

const user = {
  name: 'john@example.com',
  full_name: 'John Doe',
  user_image: '/files/user_image.jpg'
}

const team = [
  { name: 'user1', full_name: 'Alice Smith', user_image: null },
  { name: 'user2', full_name: 'Bob Johnson', user_image: '/files/bob.jpg' },
  { name: 'user3', full_name: 'Carol Williams', user_image: null },
  { name: 'user4', full_name: 'David Brown', user_image: null }
]
</script>
```

#### Badge Component
```vue
<template>
  <!-- Status badges -->
  <div class="flex flex-wrap gap-2 mb-4">
    <Badge variant="subtle" theme="green">Active</Badge>
    <Badge variant="subtle" theme="yellow">Pending</Badge>
    <Badge variant="subtle" theme="red">Inactive</Badge>
    <Badge variant="subtle" theme="blue">Draft</Badge>
  </div>
  
  <!-- Count badges -->
  <div class="flex items-center space-x-4">
    <div class="relative">
      <FeatherIcon name="bell" class="w-6 h-6" />
      <Badge
        variant="solid"
        theme="red"
        size="sm"
        class="absolute -top-2 -right-2"
      >
        {{ notificationCount }}
      </Badge>
    </div>
  </div>
  
  <!-- Interactive badges -->
  <div class="flex flex-wrap gap-2">
    <Badge
      v-for="filter in activeFilters"
      :key="filter.key"
      variant="subtle"
      theme="blue"
      class="cursor-pointer hover:bg-blue-100"
      @click="removeFilter(filter)"
    >
      {{ filter.label }}
      <FeatherIcon name="x" class="w-3 h-3 ml-1" />
    </Badge>
  </div>
  
  <!-- Custom badge component -->
  <Badge
    :variant="getStatusVariant(item.status)"
    :theme="getStatusTheme(item.status)"
  >
    {{ item.status }}
  </Badge>
</template>

<script setup>
import { Badge, FeatherIcon } from 'frappe-ui'
import { ref, computed } from 'vue'

const notificationCount = ref(5)
const activeFilters = ref([
  { key: 'status', label: 'Open', value: 'Open' },
  { key: 'assigned_to', label: 'John Doe', value: 'john@example.com' }
])

const item = { status: 'In Progress' }

const getStatusVariant = (status) => {
  const variants = {
    'Open': 'subtle',
    'In Progress': 'solid',
    'Closed': 'outline'
  }
  return variants[status] || 'subtle'
}

const getStatusTheme = (status) => {
  const themes = {
    'Open': 'blue',
    'In Progress': 'yellow',
    'Closed': 'green'
  }
  return themes[status] || 'gray'
}

const removeFilter = (filter) => {
  activeFilters.value = activeFilters.value.filter(f => f.key !== filter.key)
}
</script>
```

### 3. Layout & Navigation Components

#### Dialog Component
```vue
<template>
  <!-- Basic dialog -->
  <Dialog v-model="showDialog" :options="{ size: 'md' }">
    <template #header>
      <h3 class="text-lg font-semibold">Confirm Action</h3>
    </template>
    <template #body>
      <p class="text-sm text-gray-600 mb-4">
        Are you sure you want to delete this item? This action cannot be undone.
      </p>
    </template>
    <template #actions>
      <Button variant="ghost" @click="showDialog = false">Cancel</Button>
      <Button variant="solid" theme="red" @click="confirmDelete">Delete</Button>
    </template>
  </Dialog>
  
  <!-- Form dialog -->
  <Dialog v-model="showFormDialog" :options="{ size: 'lg' }">
    <template #header>
      <h3 class="text-lg font-semibold">{{ editMode ? 'Edit' : 'Create' }} Contact</h3>
    </template>
    <template #body>
      <form @submit.prevent="saveContact" class="space-y-4">
        <FormControl
          v-model="contactForm.full_name"
          label="Full Name"
          required
          :error-message="formErrors.full_name"
        />
        <FormControl
          v-model="contactForm.email"
          label="Email"
          type="email"
          :error-message="formErrors.email"
        />
        <FormControl
          v-model="contactForm.phone"
          label="Phone"
          :error-message="formErrors.phone"
        />
        <FormControl
          v-model="contactForm.company"
          label="Company"
          :error-message="formErrors.company"
        />
      </form>
    </template>
    <template #actions>
      <Button variant="ghost" @click="showFormDialog = false">Cancel</Button>
      <Button
        variant="solid"
        :loading="saving"
        @click="saveContact"
      >
        {{ editMode ? 'Update' : 'Create' }}
      </Button>
    </template>
  </Dialog>
</template>

<script setup>
import { Dialog, Button, FormControl } from 'frappe-ui'
import { ref, reactive } from 'vue'

// Basic dialog
const showDialog = ref(false)

// Form dialog
const showFormDialog = ref(false)
const editMode = ref(false)
const saving = ref(false)

const contactForm = reactive({
  full_name: '',
  email: '',
  phone: '',
  company: ''
})

const formErrors = ref({})

const confirmDelete = () => {
  // Delete logic
  showDialog.value = false
}

const saveContact = async () => {
  saving.value = true
  formErrors.value = {}
  
  try {
    // Validation
    if (!contactForm.full_name) {
      formErrors.value.full_name = 'Full name is required'
      return
    }
    
    // API call to save contact
    // await createResource(...).submit()
    
    showFormDialog.value = false
    resetForm()
  } catch (error) {
    // Handle errors
  } finally {
    saving.value = false
  }
}

const resetForm = () => {
  Object.keys(contactForm).forEach(key => {
    contactForm[key] = ''
  })
  formErrors.value = {}
}
</script>
```

#### Dropdown Component
```vue
<template>
  <!-- Action dropdown -->
  <Dropdown :options="actionOptions" placement="bottom-end">
    <template #default>
      <Button icon="more-horizontal" variant="ghost" />
    </template>
  </Dropdown>
  
  <!-- Filter dropdown -->
  <Dropdown :options="filterOptions" placement="bottom-start">
    <template #default>
      <Button icon="filter">
        Filter
        <Badge v-if="activeFilterCount" variant="solid" theme="blue" size="sm" class="ml-2">
          {{ activeFilterCount }}
        </Badge>
      </Button>
    </template>
  </Dropdown>
  
  <!-- User menu -->
  <Dropdown :options="userMenuOptions" placement="bottom-end">
    <template #default>
      <div class="flex items-center space-x-2 cursor-pointer hover:bg-gray-50 p-2 rounded">
        <Avatar :image="currentUser.user_image" :label="currentUser.full_name" size="sm" />
        <span class="text-sm font-medium">{{ currentUser.full_name }}</span>
        <FeatherIcon name="chevron-down" class="w-4 h-4" />
      </div>
    </template>
  </Dropdown>
</template>

<script setup>
import { Dropdown, Button, Avatar, Badge, FeatherIcon } from 'frappe-ui'
import { computed } from 'vue'

// Action dropdown options
const actionOptions = [
  {
    label: 'Edit',
    icon: 'edit',
    handler: () => editItem()
  },
  {
    label: 'Duplicate',
    icon: 'copy',
    handler: () => duplicateItem()
  },
  {
    group: 'Danger',
    label: 'Delete',
    icon: 'trash-2',
    class: 'text-red-600',
    handler: () => deleteItem()
  }
]

// Filter dropdown options
const filterOptions = [
  {
    group: 'Status',
    label: 'Open',
    handler: () => applyFilter('status', 'Open')
  },
  {
    group: 'Status',
    label: 'Closed',
    handler: () => applyFilter('status', 'Closed')
  },
  {
    group: 'Priority',
    label: 'High',
    handler: () => applyFilter('priority', 'High')
  }
]

// User menu options
const currentUser = {
  full_name: 'John Doe',
  user_image: null
}

const userMenuOptions = [
  {
    label: 'Profile Settings',
    icon: 'user',
    handler: () => openProfile()
  },
  {
    label: 'Preferences',
    icon: 'settings',
    handler: () => openPreferences()
  },
  {
    group: 'Account',
    label: 'Logout',
    icon: 'log-out',
    class: 'text-red-600',
    handler: () => logout()
  }
]

const activeFilterCount = computed(() => {
  // Return count of active filters
  return 2
})

// Handler functions
const editItem = () => console.log('Edit clicked')
const duplicateItem = () => console.log('Duplicate clicked')
const deleteItem = () => console.log('Delete clicked')
const applyFilter = (key, value) => console.log('Filter applied:', key, value)
const openProfile = () => console.log('Profile clicked')
const openPreferences = () => console.log('Preferences clicked')
const logout = () => console.log('Logout clicked')
</script>
```

### 4. Data Display Components

#### ListView Component
```vue
<template>
  <!-- Advanced ListView with custom columns -->
  <ListView
    :resource="contactsResource"
    :columns="columns"
    :page-length="20"
    row-key="name"
    @row-click="handleRowClick"
  >
    <template #header>
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-xl font-semibold">Contacts</h2>
        <div class="flex items-center space-x-2">
          <Input
            v-model="searchQuery"
            placeholder="Search contacts..."
            @input="handleSearch"
          >
            <template #prefix>
              <FeatherIcon name="search" class="w-4 h-4" />
            </template>
          </Input>
          <Button icon="plus" @click="createContact">New Contact</Button>
        </div>
      </div>
    </template>
    
    <template #name="{ value, row }">
      <div class="flex items-center space-x-3">
        <Avatar :label="value" size="sm" />
        <div>
          <div class="font-medium">{{ value }}</div>
          <div class="text-sm text-gray-500">{{ row.email }}</div>
        </div>
      </div>
    </template>
    
    <template #status="{ value }">
      <Badge
        :variant="getStatusVariant(value)"
        :theme="getStatusTheme(value)"
      >
        {{ value }}
      </Badge>
    </template>
    
    <template #actions="{ row }">
      <Dropdown :options="getRowActions(row)" placement="bottom-end">
        <Button icon="more-horizontal" variant="ghost" size="sm" />
      </Dropdown>
    </template>
  </ListView>
</template>

<script setup>
import { ListView, Input, Button, Avatar, Badge, Dropdown, FeatherIcon } from 'frappe-ui'
import { ref, computed } from 'vue'
import { createResource } from 'frappe-ui'
import debounce from 'lodash/debounce'

// Resource for contacts data
const contactsResource = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'Contact',
    fields: ['name', 'full_name', 'email', 'phone', 'status', 'modified'],
    order_by: 'modified desc'
  },
  auto: true
})

// Search functionality
const searchQuery = ref('')
const handleSearch = debounce((query) => {
  contactsResource.update({
    params: {
      ...contactsResource.params,
      filters: query ? { full_name: ['like', `%${query}%`] } : {}
    }
  })
  contactsResource.reload()
}, 300)

// Column configuration
const columns = [
  {
    label: 'Name',
    key: 'full_name',
    width: '250px'
  },
  {
    label: 'Phone',
    key: 'phone',
    width: '150px'
  },
  {
    label: 'Status',
    key: 'status',
    width: '100px'
  },
  {
    label: 'Modified',
    key: 'modified',
    width: '150px',
    format: (value) => new Date(value).toLocaleDateString()
  },
  {
    label: '',
    key: 'actions',
    width: '50px'
  }
]

// Row actions
const getRowActions = (row) => [
  {
    label: 'View',
    icon: 'eye',
    handler: () => viewContact(row)
  },
  {
    label: 'Edit',
    icon: 'edit',
    handler: () => editContact(row)
  },
  {
    group: 'Danger',
    label: 'Delete',
    icon: 'trash-2',
    class: 'text-red-600',
    handler: () => deleteContact(row)
  }
]

// Status styling
const getStatusVariant = (status) => {
  const variants = { 'Active': 'subtle', 'Inactive': 'outline' }
  return variants[status] || 'subtle'
}

const getStatusTheme = (status) => {
  const themes = { 'Active': 'green', 'Inactive': 'red' }
  return themes[status] || 'gray'
}

// Event handlers
const handleRowClick = (row) => {
  console.log('Row clicked:', row)
}

const createContact = () => {
  console.log('Create contact')
}

const viewContact = (row) => {
  console.log('View contact:', row)
}

const editContact = (row) => {
  console.log('Edit contact:', row)
}

const deleteContact = (row) => {
  console.log('Delete contact:', row)
}
</script>
```

### 5. Utility Components

#### Toast Notifications
```vue
<template>
  <div>
    <!-- Trigger buttons for different toast types -->
    <div class="flex space-x-2">
      <Button @click="showSuccessToast">Success Toast</Button>
      <Button @click="showErrorToast">Error Toast</Button>
      <Button @click="showWarningToast">Warning Toast</Button>
      <Button @click="showInfoToast">Info Toast</Button>
    </div>
  </div>
</template>

<script setup>
import { Button, createToast } from 'frappe-ui'

const showSuccessToast = () => {
  createToast({
    title: 'Success!',
    text: 'Contact has been saved successfully.',
    icon: 'check',
    iconClasses: 'text-green-600',
    timeout: 5000
  })
}

const showErrorToast = () => {
  createToast({
    title: 'Error!',
    text: 'Failed to save contact. Please try again.',
    icon: 'x',
    iconClasses: 'text-red-600',
    timeout: 0 // Persistent toast
  })
}

const showWarningToast = () => {
  createToast({
    title: 'Warning',
    text: 'This action cannot be undone.',
    icon: 'alert-triangle',
    iconClasses: 'text-yellow-600',
    timeout: 8000
  })
}

const showInfoToast = () => {
  createToast({
    title: 'Info',
    text: 'New updates are available.',
    icon: 'info',
    iconClasses: 'text-blue-600',
    timeout: 6000
  })
}
</script>
```

#### Loading States
```vue
<template>
  <div class="space-y-6">
    <!-- Loading indicator -->
    <div class="text-center">
      <LoadingIndicator v-if="loading" class="mb-4" />
      <p v-if="loading" class="text-sm text-gray-500">Loading data...</p>
    </div>
    
    <!-- Loading text with skeleton -->
    <div class="space-y-2">
      <LoadingText v-if="loading" class="h-6 w-3/4" />
      <LoadingText v-if="loading" class="h-6 w-1/2" />
      <LoadingText v-if="loading" class="h-6 w-2/3" />
    </div>
    
    <!-- Button loading states -->
    <div class="flex space-x-2">
      <Button :loading="saving" @click="save">
        Save Changes
      </Button>
      <Button :loading="deleting" variant="ghost" theme="red" @click="delete">
        Delete Item
      </Button>
    </div>
    
    <!-- Custom loading overlay -->
    <div class="relative">
      <div v-if="loading" class="absolute inset-0 bg-white bg-opacity-75 flex items-center justify-center z-10">
        <div class="text-center">
          <LoadingIndicator class="mb-2" />
          <p class="text-sm text-gray-600">Processing...</p>
        </div>
      </div>
      <div class="p-6 border rounded-lg" :class="{ 'opacity-50': loading }">
        <h3 class="text-lg font-medium mb-4">Content Area</h3>
        <p class="text-gray-600">This content will be overlaid when loading.</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { Button, LoadingIndicator, LoadingText } from 'frappe-ui'
import { ref } from 'vue'

const loading = ref(false)
const saving = ref(false)
const deleting = ref(false)

const save = async () => {
  saving.value = true
  // Simulate API call
  setTimeout(() => {
    saving.value = false
  }, 2000)
}

const delete = async () => {
  deleting.value = true
  // Simulate API call
  setTimeout(() => {
    deleting.value = false
  }, 1500)
}
</script>
```

---

## 🎨 Design System Guidelines

### Color Themes
```javascript
// Available theme colors
const themes = {
  gray: 'default neutral theme',
  blue: 'primary actions and info states',
  green: 'success states and positive actions',
  yellow: 'warning states and pending actions',  
  red: 'error states and destructive actions',
  purple: 'special features and premium content',
  pink: 'creative content and highlights'
}

// Usage in components
<Badge theme="green" variant="subtle">Active</Badge>
<Button theme="red" variant="solid">Delete</Button>
```

### Size Variants
```javascript
// Standard size scale
const sizes = {
  xs: 'extra small - compact displays',
  sm: 'small - secondary content',
  md: 'medium - default size',
  lg: 'large - important content',
  xl: 'extra large - hero content'
}

// Usage examples
<Avatar size="xs" />  // 24px
<Avatar size="sm" />  // 32px  
<Avatar size="md" />  // 40px (default)
<Avatar size="lg" />  // 48px
<Avatar size="xl" />  // 56px
```

### Spacing and Layout
```vue
<template>
  <!-- Standard spacing classes -->
  <div class="space-y-4">        <!-- 16px vertical spacing -->
    <div class="space-x-2">      <!-- 8px horizontal spacing -->
      <Button>Action 1</Button>
      <Button>Action 2</Button>
    </div>
    <div class="p-4">            <!-- 16px padding -->
      <div class="mb-6">         <!-- 24px bottom margin -->
        Content here
      </div>
    </div>
  </div>
  
  <!-- Responsive spacing -->
  <div class="space-y-2 md:space-y-4 lg:space-y-6">
    Responsive vertical spacing
  </div>
</template>
```

---

## 🚀 Best Practices

### Component Composition
```vue
<script setup>
// ✅ Good: Compose reusable logic
import { useFormValidation } from '@/composables/useFormValidation'
import { useToast } from '@/composables/useToast'

const { form, errors, validate } = useFormValidation(schema)
const { showSuccess, showError } = useToast()

// ✅ Good: Extract complex logic
const handleSubmit = async () => {
  if (!validate()) return
  
  try {
    await submitForm(form)
    showSuccess('Form submitted successfully')
  } catch (error) {
    showError(error.message)
  }
}
</script>
```

### Performance Optimization
```vue
<script setup>
// ✅ Good: Use computed for derived state
const filteredItems = computed(() => {
  return items.value.filter(item => 
    item.name.toLowerCase().includes(searchQuery.value.toLowerCase())
  )
})

// ✅ Good: Debounce expensive operations
import debounce from 'lodash/debounce'
const debouncedSearch = debounce(performSearch, 300)

// ✅ Good: Use shallowRef for large objects
const largeDataSet = shallowRef([])
</script>
```

### Accessibility
```vue
<template>
  <!-- ✅ Good: Proper ARIA labels -->
  <Button
    aria-label="Close dialog"
    aria-describedby="dialog-description"
    @click="closeDialog"
  >
    <FeatherIcon name="x" />
  </Button>
  
  <!-- ✅ Good: Keyboard navigation -->
  <div
    tabindex="0"
    role="button"
    @keydown.enter="handleAction"
    @keydown.space="handleAction"
    @click="handleAction"
  >
    Custom clickable element
  </div>
</template>
```

---

## 📚 Component Reference Quick Guide

### Most Commonly Used Components
1. **Button** - Primary actions, form submissions
2. **FormControl** - All input types with validation
3. **Dialog** - Modals, confirmations, forms
4. **ListView** - Data tables and lists
5. **Avatar** - User representations
6. **Badge** - Status indicators, counts
7. **Dropdown** - Action menus, filters
8. **LoadingIndicator** - Async operation feedback

### Advanced Components
1. **Autocomplete** - Search with suggestions
2. **DatePicker** - Date and time selection
3. **FileUploader** - File upload with progress
4. **TextEditor** - Rich text editing
5. **Chart** - Data visualization
6. **Calendar** - Event scheduling

### Utility Functions
```javascript
import {
  createToast,      // Show notifications
  createDialog,     // Show modal dialogs
  createResource,   // Data fetching
  call,            // API calls
} from 'frappe-ui'
```

This comprehensive reference covers all major Frappe UI patterns extracted from production CRM and HRMS applications, providing everything needed for building modern Vue.js applications with ERPNext integration.