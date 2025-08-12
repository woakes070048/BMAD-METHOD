# Create Vue Components

## Overview
This task guides you through creating Vue 3 components using the Composition API and frappe-ui library, following best practices for ERPNext frontend development with the doppio pattern.

## Prerequisites

### Required Knowledge
- [ ] Vue 3 Composition API fundamentals
- [ ] Understanding of frappe-ui component library
- [ ] Basic knowledge of JavaScript/TypeScript
- [ ] Familiarity with Frappe framework concepts

### Development Environment
- [ ] ERPNext development environment is set up
- [ ] Vue frontend is set up using doppio_frappeui_starter
- [ ] Node.js and npm are installed
- [ ] Development server is running

## Step-by-Step Process

### Step 1: Set Up Vue Component Structure

#### Navigate to Frontend Directory
```bash
# Go to your app's frontend directory (created via doppio method)
cd /path/to/frappe-bench/apps/{{app_name}}/frontend

# Verify doppio structure
ls -la
# Should show: src/, package.json, vite.config.js, etc.
```

#### Create Component Directory Structure
```bash
# Create component directories
mkdir -p src/components/{forms,lists,cards,modals,layouts}
mkdir -p src/composables
mkdir -p src/utils
mkdir -p src/stores
```

### Step 2: Create Basic Component Template

#### Create Your First Component
```vue
<!-- src/components/CustomerCard.vue -->
<template>
  <Card class="customer-card" :class="cardClasses">
    <template #header>
      <div class="flex justify-between items-center">
        <div class="flex items-center space-x-3">
          <Avatar 
            :label="customer.customer_name" 
            :image="customer.image"
            size="md"
          />
          <div>
            <h3 class="font-semibold text-gray-900">{{ customer.customer_name }}</h3>
            <p class="text-sm text-gray-600">{{ customer.email_id }}</p>
          </div>
        </div>
        <div class="flex space-x-2">
          <Button
            v-if="canEdit"
            variant="ghost"
            size="sm"
            @click="$emit('edit', customer)"
          >
            <Edit class="w-4 h-4" />
          </Button>
          <Dropdown :options="actionOptions" @click="handleAction">
            <template #trigger>
              <Button variant="ghost" size="sm">
                <MoreHorizontal class="w-4 h-4" />
              </Button>
            </template>
          </Dropdown>
        </div>
      </div>
    </template>

    <div class="space-y-4">
      <!-- Customer Details -->
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="text-sm font-medium text-gray-700">Territory</label>
          <p class="text-sm text-gray-900">{{ customer.territory }}</p>
        </div>
        <div>
          <label class="text-sm font-medium text-gray-700">Customer Group</label>
          <p class="text-sm text-gray-900">{{ customer.customer_group }}</p>
        </div>
      </div>

      <!-- Status Indicators -->
      <div class="flex space-x-2">
        <Badge 
          :color="statusColor" 
          :label="customer.disabled ? 'Inactive' : 'Active'"
        />
        <Badge 
          v-if="customer.is_frozen"
          color="orange"
          label="Frozen"
        />
      </div>

      <!-- Recent Activity -->
      <div v-if="showActivity && recentOrders.length > 0">
        <h4 class="text-sm font-medium text-gray-700 mb-2">Recent Orders</h4>
        <div class="space-y-1">
          <div 
            v-for="order in recentOrders.slice(0, 3)"
            :key="order.name"
            class="text-xs text-gray-600 flex justify-between"
          >
            <span>{{ order.name }}</span>
            <span>{{ formatCurrency(order.grand_total) }}</span>
          </div>
        </div>
      </div>
    </div>

    <template #footer v-if="showFooterActions">
      <div class="flex justify-end space-x-2">
        <Button
          variant="outline"
          size="sm"
          @click="$emit('view-orders', customer)"
        >
          View Orders
        </Button>
        <Button
          variant="solid"
          size="sm"
          @click="$emit('create-order', customer)"
        >
          New Order
        </Button>
      </div>
    </template>
  </Card>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { 
  Card, 
  Button, 
  Avatar, 
  Badge, 
  Dropdown 
} from 'frappe-ui'
import { Edit, MoreHorizontal } from 'lucide-vue-next'
import { createResource } from 'frappe-ui'
import { formatCurrency } from '@/utils/currency'
import { usePermissions } from '@/composables/usePermissions'

// Props
const props = defineProps({
  customer: {
    type: Object,
    required: true
  },
  showActivity: {
    type: Boolean,
    default: true
  },
  showFooterActions: {
    type: Boolean,
    default: true
  }
})

// Emits
const emit = defineEmits([
  'edit',
  'view-orders', 
  'create-order',
  'action'
])

// Composables
const { hasPermission } = usePermissions()

// Reactive data
const recentOrders = ref([])

// Resources
const ordersResource = createResource({
  url: 'frappe.client.get_list',
  auto: false,
  onSuccess(data) {
    recentOrders.value = data
  }
})

// Computed properties
const canEdit = computed(() => {
  return hasPermission('Customer', 'write', props.customer.name)
})

const statusColor = computed(() => {
  return props.customer.disabled ? 'red' : 'green'
})

const cardClasses = computed(() => {
  return {
    'opacity-60': props.customer.disabled,
    'border-orange-200': props.customer.is_frozen
  }
})

const actionOptions = computed(() => [
  {
    label: 'Edit Customer',
    value: 'edit',
    condition: canEdit.value
  },
  {
    label: 'View Orders',
    value: 'view-orders'
  },
  {
    label: 'Create Sales Order',
    value: 'create-order'
  },
  {
    label: 'Disable Customer',
    value: 'disable',
    condition: !props.customer.disabled
  }
].filter(option => option.condition !== false))

// Methods
const handleAction = (option) => {
  emit('action', {
    action: option.value,
    customer: props.customer
  })
}

const fetchRecentOrders = async () => {
  if (props.showActivity) {
    await ordersResource.fetch({
      doctype: 'Sales Order',
      filters: {
        customer: props.customer.name
      },
      fields: ['name', 'grand_total', 'transaction_date'],
      limit: 5,
      order_by: 'transaction_date desc'
    })
  }
}

// Lifecycle
onMounted(() => {
  fetchRecentOrders()
})
</script>

<style scoped>
.customer-card {
  @apply transition-all duration-200 hover:shadow-md;
}
</style>
```

### Step 3: Create Form Components

#### Create a Form Component with Validation
```vue
<!-- src/components/forms/CustomerForm.vue -->
<template>
  <div class="customer-form">
    <form @submit.prevent="handleSubmit" class="space-y-6">
      <!-- Basic Information Section -->
      <div class="bg-white p-6 rounded-lg border">
        <h3 class="text-lg font-semibold mb-4">Basic Information</h3>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <FormControl
            v-model="formData.customer_name"
            :label="__('Customer Name')"
            type="text"
            :required="true"
            :error="errors.customer_name"
            placeholder="Enter customer name"
          />
          
          <FormControl
            v-model="formData.email_id"
            :label="__('Email')"
            type="email"
            :required="true"
            :error="errors.email_id"
            placeholder="customer@example.com"
          />
          
          <FormControl
            v-model="formData.mobile_no"
            :label="__('Mobile Number')"
            type="text"
            :error="errors.mobile_no"
            placeholder="+1234567890"
          />
          
          <FormControl
            v-model="formData.customer_type"
            :label="__('Customer Type')"
            type="select"
            :options="customerTypeOptions"
            :required="true"
            :error="errors.customer_type"
          />
        </div>
      </div>

      <!-- Address Information Section -->
      <div class="bg-white p-6 rounded-lg border">
        <h3 class="text-lg font-semibold mb-4">Address Information</h3>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div class="md:col-span-2">
            <FormControl
              v-model="formData.address_line1"
              :label="__('Address Line 1')"
              type="text"
              :error="errors.address_line1"
              placeholder="Street address"
            />
          </div>
          
          <FormControl
            v-model="formData.city"
            :label="__('City')"
            type="text"
            :error="errors.city"
          />
          
          <FormControl
            v-model="formData.state"
            :label="__('State/Province')"
            type="text"
            :error="errors.state"
          />
          
          <FormControl
            v-model="formData.pincode"
            :label="__('ZIP/Postal Code')"
            type="text"
            :error="errors.pincode"
          />
          
          <FormControl
            v-model="formData.country"
            :label="__('Country')"
            type="autocomplete"
            :options="countryOptions"
            :error="errors.country"
          />
        </div>
      </div>

      <!-- Business Information Section -->
      <div class="bg-white p-6 rounded-lg border">
        <h3 class="text-lg font-semibold mb-4">Business Information</h3>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <FormControl
            v-model="formData.territory"
            :label="__('Territory')"
            type="link"
            doctype="Territory"
            :error="errors.territory"
          />
          
          <FormControl
            v-model="formData.customer_group"
            :label="__('Customer Group')"
            type="link"
            doctype="Customer Group"
            :error="errors.customer_group"
          />
          
          <FormControl
            v-model="formData.credit_limit"
            :label="__('Credit Limit')"
            type="number"
            :error="errors.credit_limit"
            :formatter="formatCurrency"
          />
          
          <FormControl
            v-model="formData.payment_terms"
            :label="__('Payment Terms')"
            type="link"
            doctype="Payment Terms Template"
            :error="errors.payment_terms"
          />
        </div>
      </div>

      <!-- Form Actions -->
      <div class="flex justify-end space-x-4 pt-6 border-t">
        <Button
          type="button"
          variant="outline"
          @click="handleCancel"
          :disabled="saving"
        >
          {{ __('Cancel') }}
        </Button>
        <Button
          type="submit"
          variant="solid"
          :loading="saving"
          :disabled="!isFormValid"
        >
          {{ isEditMode ? __('Update Customer') : __('Create Customer') }}
        </Button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, computed, reactive, onMounted, watch } from 'vue'
import { FormControl, Button } from 'frappe-ui'
import { createResource } from 'frappe-ui'
import { toast } from '@/utils'
import { __ } from '@/utils/translations'
import { validateEmail, validatePhone } from '@/utils/validators'
import { formatCurrency } from '@/utils/currency'

// Props
const props = defineProps({
  customerId: {
    type: String,
    default: null
  }
})

// Emits
const emit = defineEmits(['saved', 'cancelled'])

// Reactive state
const formData = reactive({
  customer_name: '',
  email_id: '',
  mobile_no: '',
  customer_type: 'Company',
  address_line1: '',
  city: '',
  state: '',
  pincode: '',
  country: '',
  territory: '',
  customer_group: '',
  credit_limit: 0,
  payment_terms: ''
})

const errors = reactive({})
const saving = ref(false)

// Resources
const customerResource = createResource({
  url: 'frappe.client.get',
  auto: false,
  onSuccess(data) {
    if (data.message) {
      Object.assign(formData, data.message)
    }
  }
})

const saveResource = createResource({
  url: 'frappe.client.save',
  auto: false,
  onSuccess(data) {
    toast({
      title: __('Success'),
      text: isEditMode.value ? __('Customer updated successfully') : __('Customer created successfully'),
      icon: 'check',
      iconClasses: 'text-green-600'
    })
    emit('saved', data.message)
  },
  onError(error) {
    toast({
      title: __('Error'),
      text: error.message,
      icon: 'x',
      iconClasses: 'text-red-600'
    })
  }
})

const countriesResource = createResource({
  url: 'frappe.client.get_list',
  auto: true,
  params: {
    doctype: 'Country',
    fields: ['name'],
    limit: 0
  }
})

// Computed properties
const isEditMode = computed(() => !!props.customerId)

const customerTypeOptions = computed(() => [
  { label: 'Company', value: 'Company' },
  { label: 'Individual', value: 'Individual' }
])

const countryOptions = computed(() => {
  return countriesResource.data?.map(country => ({
    label: country.name,
    value: country.name
  })) || []
})

const isFormValid = computed(() => {
  return formData.customer_name && 
         formData.email_id && 
         formData.customer_type &&
         Object.keys(errors).length === 0
})

// Methods
const validateForm = () => {
  // Clear previous errors
  Object.keys(errors).forEach(key => delete errors[key])
  
  // Validate required fields
  if (!formData.customer_name) {
    errors.customer_name = __('Customer name is required')
  }
  
  if (!formData.email_id) {
    errors.email_id = __('Email is required')
  } else if (!validateEmail(formData.email_id)) {
    errors.email_id = __('Please enter a valid email address')
  }
  
  if (!formData.customer_type) {
    errors.customer_type = __('Customer type is required')
  }
  
  // Validate phone number format
  if (formData.mobile_no && !validatePhone(formData.mobile_no)) {
    errors.mobile_no = __('Please enter a valid phone number')
  }
  
  // Validate credit limit
  if (formData.credit_limit && formData.credit_limit < 0) {
    errors.credit_limit = __('Credit limit cannot be negative')
  }
  
  return Object.keys(errors).length === 0
}

const handleSubmit = async () => {
  if (!validateForm()) {
    return
  }
  
  saving.value = true
  
  try {
    const docData = {
      doctype: 'Customer',
      ...formData
    }
    
    if (isEditMode.value) {
      docData.name = props.customerId
    }
    
    await saveResource.fetch({
      doc: docData
    })
  } finally {
    saving.value = false
  }
}

const handleCancel = () => {
  emit('cancelled')
}

// Watchers
watch(() => formData.email_id, (newEmail) => {
  if (newEmail && errors.email_id) {
    delete errors.email_id
  }
})

watch(() => formData.customer_name, (newName) => {
  if (newName && errors.customer_name) {
    delete errors.customer_name
  }
})

// Lifecycle
onMounted(async () => {
  if (props.customerId) {
    await customerResource.fetch({
      doctype: 'Customer',
      name: props.customerId
    })
  }
})
</script>

<style scoped>
.customer-form {
  @apply max-w-4xl mx-auto;
}
</style>
```

### Step 4: Create List Components

#### Create a Data List Component
```vue
<!-- src/components/lists/CustomerList.vue -->
<template>
  <div class="customer-list">
    <!-- List Header -->
    <div class="flex justify-between items-center mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">{{ __('Customers') }}</h1>
        <p class="text-gray-600 mt-1">{{ __('Manage your customer database') }}</p>
      </div>
      <div class="flex items-center space-x-4">
        <Button
          variant="solid"
          @click="showCreateModal = true"
          :disabled="!canCreate"
        >
          <Plus class="w-4 h-4 mr-2" />
          {{ __('New Customer') }}
        </Button>
      </div>
    </div>

    <!-- Filters and Search -->
    <div class="bg-white p-4 rounded-lg border mb-6">
      <div class="flex flex-wrap items-center gap-4">
        <!-- Search -->
        <div class="flex-1 min-w-64">
          <FormControl
            v-model="searchQuery"
            type="text"
            :placeholder="__('Search customers...')"
            :debounce="300"
          >
            <template #prefix>
              <Search class="w-4 h-4 text-gray-400" />
            </template>
          </FormControl>
        </div>
        
        <!-- Territory Filter -->
        <FormControl
          v-model="filters.territory"
          type="select"
          :placeholder="__('All Territories')"
          :options="territoryOptions"
          class="min-w-40"
        />
        
        <!-- Status Filter -->
        <FormControl
          v-model="filters.status"
          type="select"
          :placeholder="__('All Status')"
          :options="statusOptions"
          class="min-w-32"
        />
        
        <!-- Clear Filters -->
        <Button
          v-if="hasActiveFilters"
          variant="ghost"
          @click="clearFilters"
          class="px-3"
        >
          <X class="w-4 h-4" />
        </Button>
      </div>
    </div>

    <!-- List View -->
    <div class="bg-white rounded-lg border">
      <ListView
        :columns="columns"
        :rows="customers"
        :loading="customersResource.loading"
        :options="listOptions"
        @row-click="handleRowClick"
      >
        <!-- Custom column templates -->
        <template #cell-customer_name="{ row }">
          <div class="flex items-center space-x-3">
            <Avatar :label="row.customer_name" :image="row.image" size="sm" />
            <div>
              <div class="font-medium text-gray-900">{{ row.customer_name }}</div>
              <div class="text-sm text-gray-500">{{ row.email_id }}</div>
            </div>
          </div>
        </template>
        
        <template #cell-status="{ row }">
          <Badge 
            :color="row.disabled ? 'red' : 'green'"
            :label="row.disabled ? __('Inactive') : __('Active')"
          />
        </template>
        
        <template #cell-total_sales="{ row }">
          <div class="text-right">
            {{ formatCurrency(row.total_sales) }}
          </div>
        </template>
        
        <template #cell-actions="{ row }">
          <div class="flex justify-end">
            <Dropdown :options="getRowActions(row)" @click="handleRowAction">
              <template #trigger>
                <Button variant="ghost" size="sm">
                  <MoreHorizontal class="w-4 h-4" />
                </Button>
              </template>
            </Dropdown>
          </div>
        </template>
      </ListView>
      
      <!-- Pagination -->
      <div class="p-4 border-t" v-if="totalPages > 1">
        <div class="flex items-center justify-between">
          <div class="text-sm text-gray-700">
            {{ __('Showing {0} to {1} of {2} results', [
              (currentPage - 1) * pageSize + 1,
              Math.min(currentPage * pageSize, totalCount),
              totalCount
            ]) }}
          </div>
          <Pagination
            :total="totalCount"
            :page-size="pageSize"
            :current-page="currentPage"
            @update:current-page="handlePageChange"
          />
        </div>
      </div>
    </div>

    <!-- Create/Edit Modal -->
    <Dialog v-model="showCreateModal" :options="{ title: __('New Customer'), size: 'xl' }">
      <template #body>
        <CustomerForm @saved="handleCustomerSaved" @cancelled="showCreateModal = false" />
      </template>
    </Dialog>
  </div>
</template>

<script setup>
import { ref, computed, reactive, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import {
  ListView,
  Button,
  FormControl,
  Avatar,
  Badge,
  Dropdown,
  Dialog,
  Pagination
} from 'frappe-ui'
import { Plus, Search, X, MoreHorizontal } from 'lucide-vue-next'
import { createResource } from 'frappe-ui'
import CustomerForm from '../forms/CustomerForm.vue'
import { formatCurrency } from '@/utils/currency'
import { __ } from '@/utils/translations'
import { usePermissions } from '@/composables/usePermissions'

// Router
const router = useRouter()

// Composables
const { hasPermission } = usePermissions()

// Reactive state
const searchQuery = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const showCreateModal = ref(false)

const filters = reactive({
  territory: '',
  status: ''
})

// Resources
const customersResource = createResource({
  url: 'frappe.client.get_list',
  auto: true,
  params: computed(() => ({
    doctype: 'Customer',
    fields: [
      'name',
      'customer_name',
      'email_id',
      'territory',
      'customer_group',
      'disabled',
      'creation',
      'image'
    ],
    filters: getFilters(),
    limit: pageSize.value,
    start: (currentPage.value - 1) * pageSize.value,
    order_by: 'creation desc'
  })),
  onSuccess(data) {
    // Fetch total count for pagination
    totalCountResource.fetch()
  }
})

const totalCountResource = createResource({
  url: 'frappe.client.get_count',
  auto: false,
  params: computed(() => ({
    doctype: 'Customer',
    filters: getFilters()
  }))
})

const territoriesResource = createResource({
  url: 'frappe.client.get_list',
  auto: true,
  params: {
    doctype: 'Territory',
    fields: ['name'],
    limit: 0
  }
})

// Computed properties
const customers = computed(() => customersResource.data || [])
const totalCount = computed(() => totalCountResource.data || 0)
const totalPages = computed(() => Math.ceil(totalCount.value / pageSize.value))

const canCreate = computed(() => hasPermission('Customer', 'create'))

const hasActiveFilters = computed(() => {
  return searchQuery.value || filters.territory || filters.status
})

const territoryOptions = computed(() => {
  const territories = territoriesResource.data || []
  return [
    { label: __('All Territories'), value: '' },
    ...territories.map(t => ({ label: t.name, value: t.name }))
  ]
})

const statusOptions = computed(() => [
  { label: __('All Status'), value: '' },
  { label: __('Active'), value: 'active' },
  { label: __('Inactive'), value: 'inactive' }
])

const columns = computed(() => [
  {
    label: __('Customer'),
    key: 'customer_name',
    width: '300px'
  },
  {
    label: __('Territory'),
    key: 'territory',
    width: '150px'
  },
  {
    label: __('Customer Group'),
    key: 'customer_group',
    width: '150px'
  },
  {
    label: __('Status'),
    key: 'status',
    width: '100px',
    align: 'center'
  },
  {
    label: __('Created'),
    key: 'creation',
    width: '120px',
    formatter: (value) => new Date(value).toLocaleDateString()
  },
  {
    label: '',
    key: 'actions',
    width: '80px',
    align: 'right'
  }
])

const listOptions = computed(() => ({
  showTooltip: true,
  resizeColumn: true,
  emptyMessage: __('No customers found')
}))

// Methods
const getFilters = () => {
  const filterObj = {}
  
  if (searchQuery.value) {
    filterObj.customer_name = ['like', `%${searchQuery.value}%`]
  }
  
  if (filters.territory) {
    filterObj.territory = filters.territory
  }
  
  if (filters.status) {
    filterObj.disabled = filters.status === 'inactive' ? 1 : 0
  }
  
  return filterObj
}

const clearFilters = () => {
  searchQuery.value = ''
  filters.territory = ''
  filters.status = ''
}

const handleRowClick = (row) => {
  router.push(`/customers/${row.name}`)
}

const handlePageChange = (page) => {
  currentPage.value = page
}

const getRowActions = (row) => {
  return [
    {
      label: __('View'),
      value: 'view',
      row
    },
    {
      label: __('Edit'),
      value: 'edit',
      row,
      condition: hasPermission('Customer', 'write', row.name)
    },
    {
      label: __('New Sales Order'),
      value: 'new-order',
      row
    },
    {
      label: row.disabled ? __('Activate') : __('Deactivate'),
      value: 'toggle-status',
      row,
      condition: hasPermission('Customer', 'write', row.name)
    }
  ].filter(action => action.condition !== false)
}

const handleRowAction = ({ option }) => {
  const { value, row } = option
  
  switch (value) {
    case 'view':
      router.push(`/customers/${row.name}`)
      break
    case 'edit':
      router.push(`/customers/${row.name}/edit`)
      break
    case 'new-order':
      router.push(`/sales-orders/new?customer=${row.name}`)
      break
    case 'toggle-status':
      toggleCustomerStatus(row)
      break
  }
}

const toggleCustomerStatus = async (customer) => {
  // Implementation for toggling customer status
}

const handleCustomerSaved = (customer) => {
  showCreateModal.value = false
  customersResource.fetch()
}

// Watchers
watch([searchQuery, filters], () => {
  currentPage.value = 1
  customersResource.fetch()
}, { deep: true })

// Lifecycle
onMounted(() => {
  customersResource.fetch()
})
</script>
```

### Step 5: Create Composable Functions

#### Create Reusable Composables
```javascript
// src/composables/usePermissions.js
import { computed } from 'vue'
import { createResource } from 'frappe-ui'

export function usePermissions() {
  const userPermissions = createResource({
    url: 'frappe.client.get',
    auto: true,
    params: {
      doctype: 'User',
      name: 'current_user',
      fields: ['roles']
    }
  })

  const hasPermission = (doctype, perm_type, doc_name = null) => {
    // Implementation for permission checking
    return frappe.boot.user.can_read?.includes(doctype) || false
  }

  const hasRole = (role) => {
    const userRoles = userPermissions.data?.roles || []
    return userRoles.some(r => r.role === role)
  }

  return {
    hasPermission,
    hasRole,
    userPermissions: computed(() => userPermissions.data)
  }
}
```

```javascript
// src/composables/useCustomers.js
import { ref, computed } from 'vue'
import { createResource } from 'frappe-ui'

export function useCustomers() {
  const customers = ref([])
  const loading = ref(false)
  const filters = ref({})

  const customersResource = createResource({
    url: 'frappe.client.get_list',
    auto: false,
    onSuccess(data) {
      customers.value = data
      loading.value = false
    },
    onError() {
      loading.value = false
    }
  })

  const fetchCustomers = async (params = {}) => {
    loading.value = true
    await customersResource.fetch({
      doctype: 'Customer',
      fields: [
        'name',
        'customer_name', 
        'email_id',
        'territory',
        'disabled'
      ],
      ...params
    })
  }

  const createCustomer = async (customerData) => {
    const createResource = createResource({
      url: 'frappe.client.insert',
      auto: false
    })

    return await createResource.fetch({
      doc: {
        doctype: 'Customer',
        ...customerData
      }
    })
  }

  const updateCustomer = async (name, updates) => {
    const updateResource = createResource({
      url: 'frappe.client.set_value',
      auto: false
    })

    return await updateResource.fetch({
      doctype: 'Customer',
      name,
      fieldname: updates
    })
  }

  return {
    customers: computed(() => customers.value),
    loading: computed(() => loading.value),
    filters,
    fetchCustomers,
    createCustomer,
    updateCustomer,
    customersResource
  }
}
```

### Step 6: Create Utility Functions

#### Create Helper Utilities
```javascript
// src/utils/currency.js
export function formatCurrency(amount, currency = 'USD') {
  if (amount == null) return '-'
  
  const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency
  })
  
  return formatter.format(amount)
}

export function parseCurrency(currencyString) {
  // Remove currency symbols and parse number
  return parseFloat(currencyString.replace(/[^0-9.-]/g, '')) || 0
}
```

```javascript
// src/utils/validators.js
export function validateEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

export function validatePhone(phone) {
  const phoneRegex = /^[\+]?[1-9][\d]{0,15}$/
  return phoneRegex.test(phone.replace(/[\s\-\(\)]/g, ''))
}

export function validateRequired(value, fieldName) {
  if (!value || (typeof value === 'string' && !value.trim())) {
    return `${fieldName} is required`
  }
  return null
}
```

```javascript
// src/utils/index.js
import { toast as frappeToast } from 'frappe-ui'

export function toast(options) {
  return frappeToast({
    position: 'top-right',
    timeout: 5000,
    ...options
  })
}

export function confirm(message) {
  return new Promise((resolve) => {
    const dialog = frappe.confirm(
      message,
      () => resolve(true),
      () => resolve(false)
    )
  })
}

export function debounce(func, wait) {
  let timeout
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout)
      func(...args)
    }
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
  }
}
```

### Step 7: Set Up Routing

#### Configure Vue Router
```javascript
// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'Dashboard',
    component: () => import('@/pages/Dashboard.vue')
  },
  {
    path: '/customers',
    name: 'CustomerList',
    component: () => import('@/pages/customers/CustomerList.vue')
  },
  {
    path: '/customers/new',
    name: 'NewCustomer',
    component: () => import('@/pages/customers/NewCustomer.vue')
  },
  {
    path: '/customers/:id',
    name: 'CustomerDetail',
    component: () => import('@/pages/customers/CustomerDetail.vue'),
    props: true
  },
  {
    path: '/customers/:id/edit',
    name: 'EditCustomer', 
    component: () => import('@/pages/customers/EditCustomer.vue'),
    props: true
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
```

### Step 8: Create Page Components

#### Create Page Components
```vue
<!-- src/pages/customers/CustomerList.vue -->
<template>
  <div class="customer-list-page">
    <CustomerList />
  </div>
</template>

<script setup>
import CustomerList from '@/components/lists/CustomerList.vue'
</script>
```

### Step 9: Build and Test

#### Build the Frontend
```bash
# Build for development
npm run dev

# Build for production
npm run build

# Run tests
npm run test
```

#### Integration with ERPNext
```python
# your_app/hooks.py
website_route_rules = [
    {"from_route": "/customers/<path:app_path>", "to_route": "/customers"},
]

app_include_js = [
    "/assets/your_app/dist/index.js"
]

app_include_css = [
    "/assets/your_app/dist/index.css" 
]
```

## Best Practices

### Component Architecture
- Keep components focused on single responsibility
- Use composition API with `<script setup>`
- Implement proper prop validation
- Use emits for parent-child communication
- Create reusable composables for shared logic

### State Management
- Use reactive refs for component state
- Implement computed properties for derived state
- Consider Pinia for complex application state
- Use watchers sparingly and with cleanup

### Performance Optimization
- Use v-memo for expensive renders
- Implement virtual scrolling for large lists
- Lazy load components when appropriate
- Debounce user inputs
- Use keep-alive for route caching

### Error Handling
- Implement error boundaries for components
- Provide user-friendly error messages
- Log errors for debugging
- Handle loading and empty states gracefully

---

*Your Vue components are now ready for production use. Test thoroughly and monitor performance in production environments.*