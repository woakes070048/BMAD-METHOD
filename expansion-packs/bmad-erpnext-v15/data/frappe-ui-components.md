# Frappe UI Components Reference Guide

## Overview
Frappe UI is the official Vue 3 component library for building Frappe/ERPNext applications. Version 0.1.171+

## Installation

```bash
yarn add frappe-ui
# or
npm install frappe-ui
```

## Setup in Vue App

```javascript
import { createApp } from 'vue'
import { FrappeUI } from 'frappe-ui'
import App from './App.vue'

const app = createApp(App)
app.use(FrappeUI)
app.mount('#app')
```

## Data Fetching with createResource

The most important utility in frappe-ui is `createResource` for API calls:

```javascript
import { createResource } from 'frappe-ui'

// Basic usage
const resource = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'Customer',
    fields: ['name', 'customer_name']
  },
  auto: true // Fetch on mount
})

// Access states
resource.data // Response data
resource.loading // Loading state
resource.error // Error state
resource.reload() // Refresh data
```

For comprehensive patterns, see [frappe-ui-resource-patterns.md](./frappe-ui-resource-patterns.md)

## Core Components

### Button
Primary interaction element with multiple variants

```vue
<template>
  <Button 
    variant="solid"
    size="md"
    :loading="isLoading"
    @click="handleClick"
  >
    Click Me
  </Button>
</template>

<script setup>
import { Button } from 'frappe-ui'
</script>
```

**Props:**
- `variant`: 'solid' | 'outline' | 'ghost' | 'subtle'
- `size`: 'sm' | 'md' | 'lg'
- `loading`: Boolean
- `disabled`: Boolean
- `icon`: String (Feather icon name)

### FormControl
Versatile input component for forms

```vue
<template>
  <FormControl
    v-model="value"
    type="text"
    label="Name"
    placeholder="Enter name"
    :required="true"
    :error="errorMessage"
  />
</template>
```

**Props:**
- `type`: 'text' | 'email' | 'password' | 'number' | 'tel' | 'url' | 'date' | 'datetime-local' | 'textarea'
- `label`: String
- `placeholder`: String
- `required`: Boolean
- `disabled`: Boolean
- `error`: String
- `hint`: String

### Dialog
Modal dialog component

```vue
<template>
  <Dialog
    v-model="showDialog"
    :options="{
      title: 'Confirm Action',
      message: 'Are you sure?',
      actions: [
        {
          label: 'Cancel',
          variant: 'ghost'
        },
        {
          label: 'Confirm',
          variant: 'solid',
          onClick: handleConfirm
        }
      ]
    }"
  >
    <template #body>
      <!-- Custom body content -->
    </template>
  </Dialog>
</template>
```

### Dropdown
Dropdown menu component

```vue
<template>
  <Dropdown
    :options="[
      { label: 'Edit', icon: 'edit', onClick: handleEdit },
      { label: 'Delete', icon: 'trash', onClick: handleDelete }
    ]"
  >
    <Button icon="more-horizontal" />
  </Dropdown>
</template>
```

### Alert
Alert message component

```vue
<template>
  <Alert
    title="Success"
    variant="success"
    :dismissible="true"
  >
    Operation completed successfully
  </Alert>
</template>
```

**Variants:** 'info' | 'success' | 'warning' | 'error'

### Avatar
User avatar component

```vue
<template>
  <Avatar
    :image="userImage"
    :label="userName"
    size="lg"
  />
</template>
```

### Badge
Status indicator badge

```vue
<template>
  <Badge
    variant="success"
    size="md"
  >
    Active
  </Badge>
</template>
```

### Card
Container component

```vue
<template>
  <Card>
    <template #header>
      <h3>Card Title</h3>
    </template>
    <template #body>
      Card content goes here
    </template>
    <template #footer>
      <Button>Action</Button>
    </template>
  </Card>
</template>
```

### TextInput
Enhanced text input with search and clear

```vue
<template>
  <TextInput
    v-model="searchQuery"
    placeholder="Search..."
    :debounce="300"
    @change="handleSearch"
  />
</template>
```

### Select
Dropdown select component

```vue
<template>
  <Select
    v-model="selected"
    :options="options"
    label="Choose option"
  />
</template>

<script setup>
const options = [
  { label: 'Option 1', value: '1' },
  { label: 'Option 2', value: '2' }
]
</script>
```

### Checkbox
Checkbox input component

```vue
<template>
  <Checkbox
    v-model="checked"
    label="Accept terms"
  />
</template>
```

### Radio
Radio button group

```vue
<template>
  <Radio
    v-model="selected"
    :options="[
      { label: 'Option A', value: 'a' },
      { label: 'Option B', value: 'b' }
    ]"
  />
</template>
```

### DatePicker
Date selection component

```vue
<template>
  <DatePicker
    v-model="date"
    placeholder="Select date"
  />
</template>
```

### FileUpload
File upload component

```vue
<template>
  <FileUpload
    @success="handleUpload"
    :accept="'.pdf,.doc,.docx'"
    :max-size="5 * 1024 * 1024"
  />
</template>
```

### LoadingIndicator
Loading spinner

```vue
<template>
  <LoadingIndicator />
</template>
```

### LoadingText
Loading text with animation

```vue
<template>
  <LoadingText>Loading data...</LoadingText>
</template>
```

### EmptyState
Empty state placeholder

```vue
<template>
  <EmptyState
    title="No data found"
    description="Try adjusting your filters"
    :icon="'inbox'"
  >
    <template #actions>
      <Button>Add New</Button>
    </template>
  </EmptyState>
</template>
```

### ErrorMessage
Error display component

```vue
<template>
  <ErrorMessage :message="error" />
</template>
```

### Toast
Notification toast

```javascript
import { toast } from 'frappe-ui'

// Success toast
toast.success('Operation successful')

// Error toast
toast.error('Something went wrong')

// Info toast
toast.info('Information message')

// Warning toast
toast.warning('Warning message')

// Custom toast
toast({
  title: 'Custom Toast',
  text: 'With custom content',
  icon: 'check',
  position: 'top-right',
  duration: 5000
})
```

### Tooltip
Hover tooltip

```vue
<template>
  <Tooltip text="Helpful information">
    <Button icon="help-circle" />
  </Tooltip>
</template>
```

### Popover
Contextual popover

```vue
<template>
  <Popover>
    <template #target>
      <Button>Open Popover</Button>
    </template>
    <template #content>
      <div class="p-2">
        Popover content
      </div>
    </template>
  </Popover>
</template>
```

### Tabs
Tab navigation component

```vue
<template>
  <Tabs
    v-model="activeTab"
    :tabs="[
      { label: 'Tab 1', value: 'tab1' },
      { label: 'Tab 2', value: 'tab2' }
    ]"
  />
</template>
```

### ListView
Data list/table component

```vue
<template>
  <ListView
    :columns="columns"
    :rows="rows"
    :options="{
      selectable: true,
      showTooltip: true
    }"
  />
</template>

<script setup>
const columns = [
  { label: 'Name', key: 'name' },
  { label: 'Email', key: 'email' }
]
</script>
```

## Resource Hooks

### createResource
Basic resource for API calls

```javascript
import { createResource } from 'frappe-ui'

const resource = createResource({
  url: 'frappe.client.get',
  params: {
    doctype: 'User',
    name: 'Administrator'
  },
  auto: true, // Auto-fetch on mount
  onSuccess(data) {
    console.log('Data loaded:', data)
  },
  onError(error) {
    console.error('Error:', error)
  }
})

// Manual fetch
resource.fetch()

// Access data
resource.data
resource.loading
resource.error
```

### createListResource
Resource for list data

```javascript
import { createListResource } from 'frappe-ui'

const listResource = createListResource({
  doctype: 'Contact',
  fields: ['name', 'email', 'phone'],
  filters: { status: 'Active' },
  orderBy: 'creation desc',
  pageLength: 20,
  auto: true
})

// Pagination
listResource.next()
listResource.previous()

// Reload
listResource.reload()

// Update filters
listResource.update({ filters: { status: 'Inactive' } })
```

### createDocumentResource
Resource for single document

```javascript
import { createDocumentResource } from 'frappe-ui'

const docResource = createDocumentResource({
  doctype: 'Contact',
  name: 'CONT-001',
  fields: ['*'],
  auto: true
})

// Update document
docResource.setValue('email', 'new@example.com')
docResource.save()

// Delete document
docResource.delete()

// Reload
docResource.reload()
```

## Icons
Frappe UI uses Feather Icons

```vue
<template>
  <FeatherIcon name="edit" class="w-4 h-4" />
</template>

<script setup>
import { FeatherIcon } from 'frappe-ui'
</script>
```

Common icons:
- `edit`, `trash`, `plus`, `minus`
- `check`, `x`, `alert-circle`, `info`
- `search`, `filter`, `download`, `upload`
- `settings`, `user`, `users`, `mail`
- `calendar`, `clock`, `bell`, `bookmark`

## Utility Functions

### debounce
Debounce function calls

```javascript
import { debounce } from 'frappe-ui'

const debouncedSearch = debounce((query) => {
  // Search logic
}, 300)
```

### call
Make API calls

```javascript
import { call } from 'frappe-ui'

const response = await call({
  method: 'frappe.client.get_list',
  args: {
    doctype: 'Contact',
    fields: ['name', 'email']
  }
})
```

## Styling with TailwindCSS
Frappe UI components are designed to work with TailwindCSS

```vue
<template>
  <div class="space-y-4">
    <Card class="p-4">
      <Button class="w-full">
        Full Width Button
      </Button>
    </Card>
  </div>
</template>
```

## Best Practices

1. **Always use Frappe UI components when available** - Ensures consistency
2. **Use resource hooks for data fetching** - Built-in error handling and loading states
3. **Handle loading and error states** - Better UX
4. **Use toast for user feedback** - Non-intrusive notifications
5. **Leverage slots for customization** - Flexible component composition
6. **Follow Frappe design patterns** - Consistent with ERPNext ecosystem

## Common Patterns

### Form with Validation
```vue
<template>
  <form @submit.prevent="handleSubmit">
    <FormControl
      v-model="form.email"
      type="email"
      label="Email"
      :error="errors.email"
      required
    />
    <FormControl
      v-model="form.password"
      type="password"
      label="Password"
      :error="errors.password"
      required
    />
    <Button type="submit" :loading="submitting">
      Submit
    </Button>
  </form>
</template>
```

### Data Table with Actions
```vue
<template>
  <ListView
    :columns="columns"
    :rows="contacts.data"
  >
    <template #actions="{ row }">
      <Dropdown
        :options="[
          { label: 'Edit', onClick: () => editContact(row) },
          { label: 'Delete', onClick: () => deleteContact(row) }
        ]"
      >
        <Button icon="more-horizontal" variant="ghost" />
      </Dropdown>
    </template>
  </ListView>
</template>
```

### Modal Form
```vue
<template>
  <Dialog v-model="showModal">
    <template #body>
      <FormControl
        v-model="formData.name"
        label="Name"
        required
      />
    </template>
    <template #actions>
      <Button @click="showModal = false">Cancel</Button>
      <Button variant="solid" @click="save">Save</Button>
    </template>
  </Dialog>
</template>
```

## Resources
- GitHub: https://github.com/frappe/frappe-ui
- Documentation: https://ui.frappe.io
- Examples: Check Frappe CRM and Helpdesk repos