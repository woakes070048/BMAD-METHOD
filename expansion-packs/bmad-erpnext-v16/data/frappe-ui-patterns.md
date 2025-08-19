# Frappe UI Patterns and Best Practices

## Overview

This guide provides proven patterns and best practices for using Frappe UI components in ERPNext v16 applications. These patterns ensure consistency, maintainability, and optimal user experience.

## Design System Patterns

### Color System

```css
/* Frappe UI Color Palette */
:root {
  /* Primary Colors */
  --primary-50: #eff6ff;
  --primary-500: #3b82f6;
  --primary-600: #2563eb;
  --primary-700: #1d4ed8;
  
  /* Semantic Colors */
  --success: #10b981;
  --warning: #f59e0b;
  --danger: #ef4444;
  --info: #3b82f6;
  
  /* Neutral Colors */
  --gray-50: #f9fafb;
  --gray-100: #f3f4f6;
  --gray-500: #6b7280;
  --gray-900: #111827;
}
```

### Typography Scale

```vue
<template>
  <div>
    <!-- Headings -->
    <h1 class="text-3xl font-bold">Page Title</h1>
    <h2 class="text-2xl font-semibold">Section Title</h2>
    <h3 class="text-xl font-medium">Subsection Title</h3>
    
    <!-- Body Text -->
    <p class="text-base">Regular body text</p>
    <p class="text-sm text-gray-600">Secondary text</p>
    <p class="text-xs text-gray-500">Caption text</p>
  </div>
</template>
```

### Spacing System

```vue
<template>
  <!-- Consistent spacing using Tailwind classes -->
  <div class="space-y-6"> <!-- 24px vertical spacing -->
    <div class="p-4"> <!-- 16px padding -->
      <h2 class="mb-4">Title</h2> <!-- 16px bottom margin -->
      <div class="grid grid-cols-2 gap-4"> <!-- 16px gap -->
        <Input />
        <Select />
      </div>
    </div>
  </div>
</template>
```

## Component Patterns

### Form Patterns

#### Standard Form Layout
```vue
<template>
  <Card class="max-w-2xl">
    <template #header>
      <h2 class="text-xl font-semibold">{{ formTitle }}</h2>
    </template>
    
    <template #body>
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <!-- Form Row Pattern -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium mb-1">
              First Name <span class="text-red-500">*</span>
            </label>
            <Input
              v-model="form.firstName"
              required
              :error="errors.firstName"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium mb-1">
              Last Name <span class="text-red-500">*</span>
            </label>
            <Input
              v-model="form.lastName"
              required
              :error="errors.lastName"
            />
          </div>
        </div>
        
        <!-- Full Width Fields -->
        <div>
          <label class="block text-sm font-medium mb-1">Email</label>
          <Input
            v-model="form.email"
            type="email"
            :error="errors.email"
          />
        </div>
        
        <!-- Action Buttons -->
        <div class="flex justify-end space-x-3 pt-4">
          <Button variant="secondary" @click="handleCancel">
            Cancel
          </Button>
          <Button
            type="submit"
            variant="primary"
            :loading="submitting"
          >
            Save
          </Button>
        </div>
      </form>
    </template>
  </Card>
</template>

<script setup>
import { ref, reactive } from 'vue'

const form = reactive({
  firstName: '',
  lastName: '',
  email: ''
})

const errors = ref({})
const submitting = ref(false)

async function handleSubmit() {
  if (!validateForm()) return
  
  submitting.value = true
  try {
    await saveData()
    frappe.show_alert('Saved successfully!')
  } catch (error) {
    frappe.show_alert('Error saving data')
  } finally {
    submitting.value = false
  }
}
</script>
```

#### Multi-Step Form Pattern
```vue
<template>
  <Card class="max-w-4xl">
    <!-- Progress Indicator -->
    <template #header>
      <div class="space-y-4">
        <h2 class="text-xl font-semibold">Setup Wizard</h2>
        <ProgressBar
          :value="currentStep"
          :max="totalSteps"
          class="w-full"
        />
        <div class="flex justify-between text-sm text-gray-600">
          <span
            v-for="(step, index) in steps"
            :key="index"
            :class="{
              'text-primary-600 font-medium': index + 1 <= currentStep,
              'text-gray-400': index + 1 > currentStep
            }"
          >
            {{ step.title }}
          </span>
        </div>
      </div>
    </template>
    
    <template #body>
      <!-- Step Content -->
      <div class="min-h-[400px]">
        <component
          :is="currentStepComponent"
          v-model="formData"
          @next="handleNext"
          @back="handleBack"
        />
      </div>
    </template>
  </Card>
</template>
```

### List and Table Patterns

#### Enhanced Data Table
```vue
<template>
  <Card>
    <template #header>
      <div class="flex justify-between items-center">
        <h2 class="text-xl font-semibold">{{ title }}</h2>
        <div class="flex space-x-2">
          <Input
            v-model="searchQuery"
            placeholder="Search..."
            class="w-64"
          />
          <Button variant="primary" @click="createNew">
            <PlusIcon class="w-4 h-4 mr-2" />
            New
          </Button>
        </div>
      </div>
    </template>
    
    <template #body>
      <!-- Filters -->
      <div v-if="hasFilters" class="mb-4 p-4 bg-gray-50 rounded">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Select
            v-model="filters.status"
            :options="statusOptions"
            placeholder="All Statuses"
          />
          <DatePicker
            v-model="filters.dateFrom"
            placeholder="From Date"
          />
          <DatePicker
            v-model="filters.dateTo"
            placeholder="To Date"
          />
        </div>
      </div>
      
      <!-- Data Table -->
      <Table
        :columns="columns"
        :data="filteredData"
        :loading="loading"
        @row-click="handleRowClick"
        @sort="handleSort"
      />
      
      <!-- Pagination -->
      <div class="flex justify-between items-center mt-4">
        <div class="text-sm text-gray-600">
          Showing {{ startIndex }} to {{ endIndex }} of {{ totalRecords }} results
        </div>
        <Pagination
          :current-page="currentPage"
          :total-pages="totalPages"
          @page-change="handlePageChange"
        />
      </div>
    </template>
  </Card>
</template>
```

#### Master-Detail Pattern
```vue
<template>
  <div class="grid grid-cols-12 gap-6 h-full">
    <!-- Master List -->
    <div class="col-span-4">
      <Card class="h-full">
        <template #header>
          <h3 class="font-semibold">{{ masterTitle }}</h3>
        </template>
        <template #body>
          <div class="space-y-2">
            <div
              v-for="item in masterItems"
              :key="item.id"
              :class="[
                'p-3 rounded cursor-pointer border',
                selectedItem?.id === item.id
                  ? 'border-primary-500 bg-primary-50'
                  : 'border-gray-200 hover:border-gray-300'
              ]"
              @click="selectItem(item)"
            >
              <div class="font-medium">{{ item.name }}</div>
              <div class="text-sm text-gray-600">{{ item.description }}</div>
            </div>
          </div>
        </template>
      </Card>
    </div>
    
    <!-- Detail View -->
    <div class="col-span-8">
      <Card class="h-full" v-if="selectedItem">
        <template #header>
          <div class="flex justify-between items-center">
            <h3 class="font-semibold">{{ selectedItem.name }}</h3>
            <Button variant="primary" @click="editItem">
              Edit
            </Button>
          </div>
        </template>
        <template #body>
          <DetailView :item="selectedItem" />
        </template>
      </Card>
      
      <div v-else class="flex items-center justify-center h-full text-gray-500">
        Select an item to view details
      </div>
    </div>
  </div>
</template>
```

### Navigation Patterns

#### Sidebar Navigation
```vue
<template>
  <div class="flex h-screen bg-gray-100">
    <!-- Sidebar -->
    <div class="w-64 bg-white shadow-lg">
      <div class="p-4 border-b">
        <h1 class="text-xl font-semibold">App Name</h1>
      </div>
      
      <nav class="mt-4">
        <div
          v-for="item in navigationItems"
          :key="item.id"
          class="px-4 py-2"
        >
          <Link
            :href="item.href"
            :class="[
              'flex items-center space-x-3 p-2 rounded',
              $route.path === item.href
                ? 'bg-primary-100 text-primary-700'
                : 'text-gray-700 hover:bg-gray-100'
            ]"
          >
            <component :is="item.icon" class="w-5 h-5" />
            <span>{{ item.label }}</span>
          </Link>
        </div>
      </nav>
    </div>
    
    <!-- Main Content -->
    <div class="flex-1 flex flex-col overflow-hidden">
      <!-- Top Bar -->
      <header class="bg-white shadow-sm border-b px-6 py-4">
        <div class="flex justify-between items-center">
          <Breadcrumbs :items="breadcrumbs" />
          <UserMenu />
        </div>
      </header>
      
      <!-- Page Content -->
      <main class="flex-1 overflow-auto p-6">
        <router-view />
      </main>
    </div>
  </div>
</template>
```

#### Tab Navigation
```vue
<template>
  <Card>
    <template #header>
      <!-- Tab Headers -->
      <div class="border-b">
        <nav class="-mb-px flex space-x-8">
          <button
            v-for="tab in tabs"
            :key="tab.id"
            :class="[
              'py-2 px-1 border-b-2 font-medium text-sm',
              activeTab === tab.id
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            ]"
            @click="activeTab = tab.id"
          >
            {{ tab.label }}
          </button>
        </nav>
      </div>
    </template>
    
    <template #body>
      <!-- Tab Content -->
      <div class="py-4">
        <component
          :is="currentTabComponent"
          :data="tabData"
          @update="handleUpdate"
        />
      </div>
    </template>
  </Card>
</template>
```

## Responsive Design Patterns

### Mobile-First Approach
```vue
<template>
  <div class="container mx-auto px-4">
    <!-- Mobile: Stack vertically, Desktop: Side by side -->
    <div class="flex flex-col lg:flex-row gap-6">
      <div class="flex-1">
        <Card>
          <!-- Content -->
        </Card>
      </div>
      
      <div class="w-full lg:w-80">
        <Card>
          <!-- Sidebar content -->
        </Card>
      </div>
    </div>
    
    <!-- Responsive grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 mt-6">
      <Card v-for="item in items" :key="item.id">
        <!-- Card content -->
      </Card>
    </div>
  </div>
</template>
```

### Adaptive Components
```vue
<template>
  <div>
    <!-- Mobile: Drawer, Desktop: Sidebar -->
    <div class="lg:hidden">
      <Button @click="showMobileMenu = true">
        <MenuIcon class="w-6 h-6" />
      </Button>
      
      <Drawer v-model="showMobileMenu">
        <NavigationMenu />
      </Drawer>
    </div>
    
    <div class="hidden lg:block w-64">
      <NavigationMenu />
    </div>
  </div>
</template>
```

## State Management Patterns

### Local State with Composition API
```vue
<script setup>
import { ref, reactive, computed, watch } from 'vue'

// Simple reactive state
const loading = ref(false)
const error = ref(null)

// Complex state object
const formState = reactive({
  data: {},
  errors: {},
  touched: {},
  submitting: false
})

// Computed properties
const isFormValid = computed(() => {
  return Object.keys(formState.errors).length === 0
})

const hasUnsavedChanges = computed(() => {
  return JSON.stringify(formState.data) !== JSON.stringify(originalData.value)
})

// Watchers
watch(
  () => formState.data,
  (newData) => {
    validateForm(newData)
  },
  { deep: true }
)
</script>
```

### Global State with Pinia
```javascript
// stores/customer.js
import { defineStore } from 'pinia'

export const useCustomerStore = defineStore('customer', {
  state: () => ({
    customers: [],
    selectedCustomer: null,
    loading: false,
    filters: {
      status: '',
      territory: ''
    }
  }),
  
  getters: {
    filteredCustomers: (state) => {
      return state.customers.filter(customer => {
        if (state.filters.status && customer.status !== state.filters.status) {
          return false
        }
        if (state.filters.territory && customer.territory !== state.filters.territory) {
          return false
        }
        return true
      })
    }
  },
  
  actions: {
    async fetchCustomers() {
      this.loading = true
      try {
        const response = await frappe.call({
          method: 'frappe.client.get_list',
          args: {
            doctype: 'Customer',
            fields: ['name', 'customer_name', 'status', 'territory']
          }
        })
        this.customers = response.message
      } catch (error) {
        console.error('Error fetching customers:', error)
      } finally {
        this.loading = false
      }
    }
  }
})
```

## Error Handling Patterns

### Global Error Handler
```vue
<script setup>
import { ref } from 'vue'

const error = ref(null)
const retryCount = ref(0)
const maxRetries = 3

async function handleAsyncOperation() {
  error.value = null
  
  try {
    const result = await performOperation()
    retryCount.value = 0
    return result
  } catch (err) {
    error.value = {
      message: err.message,
      code: err.code,
      retryable: err.retryable !== false
    }
    
    // Auto-retry for retryable errors
    if (error.value.retryable && retryCount.value < maxRetries) {
      retryCount.value++
      setTimeout(() => {
        handleAsyncOperation()
      }, 1000 * retryCount.value)
    }
  }
}
</script>

<template>
  <div>
    <!-- Error Display -->
    <Alert
      v-if="error"
      variant="danger"
      :show="true"
      @dismiss="error = null"
    >
      <div class="flex justify-between items-center">
        <span>{{ error.message }}</span>
        <Button
          v-if="error.retryable && retryCount < maxRetries"
          variant="secondary"
          size="small"
          @click="handleAsyncOperation"
        >
          Retry ({{ retryCount }}/{{ maxRetries }})
        </Button>
      </div>
    </Alert>
  </div>
</template>
```

## Performance Patterns

### Lazy Loading
```vue
<script setup>
import { ref, onMounted } from 'vue'

const data = ref([])
const loading = ref(false)
const hasMore = ref(true)
const page = ref(1)

async function loadMore() {
  if (loading.value || !hasMore.value) return
  
  loading.value = true
  try {
    const response = await frappe.call({
      method: 'app.api.get_paginated_data',
      args: {
        page: page.value,
        page_size: 20
      }
    })
    
    data.value.push(...response.message.data)
    hasMore.value = response.message.has_more
    page.value++
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadMore()
})
</script>

<template>
  <div>
    <div v-for="item in data" :key="item.id">
      <!-- Item content -->
    </div>
    
    <div v-if="hasMore" class="text-center mt-4">
      <Button
        @click="loadMore"
        :loading="loading"
        variant="secondary"
      >
        Load More
      </Button>
    </div>
  </div>
</template>
```

### Virtual Scrolling for Large Lists
```vue
<script setup>
import { ref, computed } from 'vue'

const items = ref([]) // Large dataset
const scrollContainer = ref(null)
const itemHeight = 60
const visibleItems = 10

const visibleData = computed(() => {
  const start = Math.floor(scrollTop.value / itemHeight)
  const end = Math.min(start + visibleItems, items.value.length)
  return items.value.slice(start, end).map((item, index) => ({
    ...item,
    index: start + index
  }))
})
</script>
```

## Best Practices Summary

### Component Design
1. **Single Responsibility**: Each component should have one clear purpose
2. **Prop Validation**: Always validate props with proper types
3. **Event Naming**: Use descriptive event names with kebab-case
4. **Slot Usage**: Provide slots for customization where appropriate

### Performance
1. **Lazy Loading**: Load data and components on demand
2. **Virtual Scrolling**: Use for large datasets
3. **Memoization**: Cache expensive computations
4. **Bundle Splitting**: Code split by routes/features

### Accessibility
1. **Semantic HTML**: Use proper HTML elements
2. **ARIA Labels**: Provide labels for screen readers
3. **Keyboard Navigation**: Ensure keyboard accessibility
4. **Color Contrast**: Meet WCAG guidelines

### Testing
1. **Unit Tests**: Test component logic
2. **Integration Tests**: Test component interactions
3. **E2E Tests**: Test user workflows
4. **Visual Regression**: Catch visual changes