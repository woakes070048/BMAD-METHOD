# Frappe UI Components Reference

## Overview

Frappe UI is the official component library for Frappe Framework, providing a consistent design system and reusable components for ERPNext applications. This guide covers the essential components available for native ERPNext v16 development.

## Installation and Setup

### NPM Package
```bash
npm install frappe-ui
```

### Vue Integration
```javascript
import { createApp } from 'vue'
import { FrappeUI } from 'frappe-ui'

const app = createApp(App)
app.use(FrappeUI)
```

## Core Components

### Form Components

#### Input Field
```vue
<template>
  <Input
    v-model="value"
    type="text"
    placeholder="Enter value"
    :required="true"
    :disabled="false"
  />
</template>
```

**Props:**
- `modelValue`: Current value
- `type`: Input type (text, email, password, number)
- `placeholder`: Placeholder text
- `required`: Whether field is required
- `disabled`: Whether field is disabled

#### Select Field
```vue
<template>
  <Select
    v-model="selectedValue"
    :options="options"
    placeholder="Select option"
  />
</template>

<script setup>
const options = [
  { label: 'Option 1', value: 'opt1' },
  { label: 'Option 2', value: 'opt2' }
]
</script>
```

#### Textarea
```vue
<template>
  <Textarea
    v-model="content"
    placeholder="Enter description"
    :rows="4"
  />
</template>
```

#### Checkbox
```vue
<template>
  <Checkbox
    v-model="isChecked"
    label="Accept terms and conditions"
  />
</template>
```

#### Date Picker
```vue
<template>
  <DatePicker
    v-model="selectedDate"
    placeholder="Select date"
    format="yyyy-MM-dd"
  />
</template>
```

### Layout Components

#### Card
```vue
<template>
  <Card class="p-4">
    <template #header>
      <h3>Card Title</h3>
    </template>
    <template #body>
      <p>Card content goes here</p>
    </template>
    <template #footer>
      <Button variant="primary">Action</Button>
    </template>
  </Card>
</template>
```

#### Grid System
```vue
<template>
  <div class="grid grid-cols-12 gap-4">
    <div class="col-span-6">
      <Card>Left Column</Card>
    </div>
    <div class="col-span-6">
      <Card>Right Column</Card>
    </div>
  </div>
</template>
```

### Navigation Components

#### Button
```vue
<template>
  <Button
    variant="primary"
    size="medium"
    :loading="isLoading"
    @click="handleClick"
  >
    Save Changes
  </Button>
</template>
```

**Variants:**
- `primary`: Primary action button
- `secondary`: Secondary action button
- `success`: Success state button
- `danger`: Danger/delete button
- `ghost`: Transparent button

**Sizes:**
- `small`: Compact button
- `medium`: Standard button
- `large`: Prominent button

#### Link
```vue
<template>
  <Link
    href="/dashboard"
    class="text-blue-600"
  >
    Go to Dashboard
  </Link>
</template>
```

#### Breadcrumbs
```vue
<template>
  <Breadcrumbs :items="breadcrumbItems" />
</template>

<script setup>
const breadcrumbItems = [
  { label: 'Home', route: '/' },
  { label: 'Sales', route: '/sales' },
  { label: 'Order Details', route: '/sales/order/123' }
]
</script>
```

### Data Display Components

#### Table
```vue
<template>
  <Table
    :columns="columns"
    :data="tableData"
    :loading="loading"
  />
</template>

<script setup>
const columns = [
  { key: 'name', label: 'Name', width: '200px' },
  { key: 'email', label: 'Email', width: '250px' },
  { key: 'status', label: 'Status', width: '100px' }
]

const tableData = ref([
  { name: 'John Doe', email: 'john@example.com', status: 'Active' }
])
</script>
```

#### List View
```vue
<template>
  <ListView
    :items="listItems"
    :columns="columns"
    @row-click="handleRowClick"
  />
</template>
```

#### Badge
```vue
<template>
  <Badge
    variant="success"
    size="medium"
  >
    Active
  </Badge>
</template>
```

**Badge Variants:**
- `success`: Green badge
- `warning`: Yellow badge
- `danger`: Red badge
- `info`: Blue badge
- `secondary`: Gray badge

### Feedback Components

#### Alert
```vue
<template>
  <Alert
    variant="success"
    :show="showAlert"
    @dismiss="showAlert = false"
  >
    Operation completed successfully!
  </Alert>
</template>
```

#### Loading Indicator
```vue
<template>
  <div v-if="loading" class="flex justify-center">
    <LoadingIndicator />
  </div>
</template>
```

#### Progress Bar
```vue
<template>
  <ProgressBar
    :value="progress"
    :max="100"
    variant="primary"
  />
</template>
```

### Modal and Overlay Components

#### Modal
```vue
<template>
  <Modal
    v-model="showModal"
    title="Confirm Action"
    size="medium"
  >
    <template #body>
      <p>Are you sure you want to delete this item?</p>
    </template>
    <template #footer>
      <Button variant="secondary" @click="showModal = false">
        Cancel
      </Button>
      <Button variant="danger" @click="confirmDelete">
        Delete
      </Button>
    </template>
  </Modal>
</template>
```

#### Dropdown
```vue
<template>
  <Dropdown>
    <template #trigger>
      <Button>Actions</Button>
    </template>
    <template #content>
      <DropdownItem @click="editItem">Edit</DropdownItem>
      <DropdownItem @click="deleteItem">Delete</DropdownItem>
    </template>
  </Dropdown>
</template>
```

#### Tooltip
```vue
<template>
  <Tooltip text="This is a helpful tooltip">
    <Button>Hover me</Button>
  </Tooltip>
</template>
```

## ERPNext-Specific Components

### DocType Components

#### DocType Form
```vue
<template>
  <DocTypeForm
    :doctype="'Customer'"
    :doc="customerDoc"
    @save="handleSave"
  />
</template>
```

#### DocType List
```vue
<template>
  <DocTypeList
    :doctype="'Sales Order'"
    :filters="filters"
    @row-click="openOrder"
  />
</template>
```

#### Link Field
```vue
<template>
  <LinkField
    v-model="customerLink"
    doctype="Customer"
    placeholder="Select Customer"
  />
</template>
```

### Frappe Integration Components

#### Page Header
```vue
<template>
  <PageHeader
    :title="pageTitle"
    :breadcrumbs="breadcrumbs"
  >
    <template #actions>
      <Button variant="primary" @click="createNew">
        New Record
      </Button>
    </template>
  </PageHeader>
</template>
```

#### Resource Manager
```vue
<template>
  <ResourceManager
    :resource="resourceConfig"
    @create="handleCreate"
    @update="handleUpdate"
    @delete="handleDelete"
  />
</template>
```

## Styling and Theming

### CSS Classes

Frappe UI uses Tailwind CSS classes for styling:

```vue
<template>
  <div class="p-4 bg-white rounded-lg shadow">
    <h2 class="text-xl font-semibold mb-4">Section Title</h2>
    <div class="grid grid-cols-2 gap-4">
      <Input class="col-span-1" />
      <Select class="col-span-1" />
    </div>
  </div>
</template>
```

### Custom Themes

```css
/* Custom theme variables */
:root {
  --primary-color: #1976d2;
  --secondary-color: #424242;
  --success-color: #4caf50;
  --warning-color: #ff9800;
  --danger-color: #f44336;
}
```

## Integration with Frappe

### API Integration

```vue
<script setup>
import { ref, onMounted } from 'vue'

const data = ref([])
const loading = ref(false)

async function loadData() {
  loading.value = true
  try {
    const response = await frappe.call({
      method: 'frappe.client.get_list',
      args: {
        doctype: 'Customer',
        fields: ['name', 'customer_name', 'territory']
      }
    })
    data.value = response.message
  } catch (error) {
    frappe.show_alert('Error loading data')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadData()
})
</script>
```

### Real-time Updates

```vue
<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const notifications = ref([])

function handleRealtimeUpdate(data) {
  if (data.doctype === 'Sales Order') {
    notifications.value.push({
      id: Date.now(),
      message: `Sales Order ${data.name} updated`,
      type: 'info'
    })
  }
}

onMounted(() => {
  frappe.realtime.on('doc_update', handleRealtimeUpdate)
})

onUnmounted(() => {
  frappe.realtime.off('doc_update', handleRealtimeUpdate)
})
</script>
```

## Best Practices

### Component Usage

1. **Consistent Styling**: Use Frappe UI components for consistent look and feel
2. **Responsive Design**: Utilize grid system for responsive layouts
3. **Accessibility**: Ensure proper ARIA labels and keyboard navigation
4. **Performance**: Use lazy loading for large data sets

### Code Organization

```vue
<template>
  <!-- Template content -->
</template>

<script setup>
// Imports
import { ref, computed, onMounted } from 'vue'
import { Input, Button, Card } from 'frappe-ui'

// Reactive data
const formData = ref({})
const loading = ref(false)

// Computed properties
const isFormValid = computed(() => {
  return formData.value.name && formData.value.email
})

// Methods
function handleSubmit() {
  // Submit logic
}

// Lifecycle
onMounted(() => {
  // Initialization
})
</script>

<style scoped>
/* Component-specific styles */
</style>
```

### Error Handling

```vue
<script setup>
import { ref } from 'vue'

const error = ref(null)
const loading = ref(false)

async function performAction() {
  loading.value = true
  error.value = null
  
  try {
    await frappe.call({
      method: 'app.api.method',
      args: { data: 'value' }
    })
    frappe.show_alert('Success!')
  } catch (err) {
    error.value = err.message
    frappe.show_alert('Error occurred')
  } finally {
    loading.value = false
  }
}
</script>
```

## Resources

### Documentation
- [Frappe UI Documentation](https://github.com/frappe/frappe-ui)
- [Vue 3 Composition API Guide](https://vuejs.org/guide/composition-api/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

### Examples
- [Frappe Helpdesk](https://github.com/frappe/helpdesk)
- [Frappe CRM](https://github.com/frappe/crm)
- Community examples and templates

### Support
- [Frappe Community Forum](https://discuss.frappe.io/)
- [GitHub Issues](https://github.com/frappe/frappe-ui/issues)
- BMAD ERPNext v16 agent support