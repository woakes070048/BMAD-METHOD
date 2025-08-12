# BMAD-ERPNext Vue Frontend Design Specification

## Architecture Overview

Based on Frappe CRM's Vue3 implementation, BMAD-ERPNext follows a modular, composable architecture:

### Core Technologies
- **Vue 3** with Composition API
- **Vue Router** for SPA navigation
- **Pinia/Stores** for state management
- **Frappe-UI** component library
- **Vite** as build tool
- **TailwindCSS** for styling

## Directory Structure

```
bmad-app/
├── frontend/
│   ├── src/
│   │   ├── components/       # Reusable UI components
│   │   │   ├── Controls/     # Form controls (Input, Select, etc.)
│   │   │   ├── ListViews/    # List view components
│   │   │   ├── Kanban/       # Kanban board components
│   │   │   ├── Dashboard/    # Dashboard widgets
│   │   │   ├── Modals/       # Dialog components
│   │   │   └── Layouts/      # Page layout components
│   │   ├── pages/           # Vue page components (routes)
│   │   ├── stores/          # Pinia stores for state
│   │   ├── composables/     # Reusable composition functions
│   │   ├── utils/           # Helper functions
│   │   ├── router.js        # Route definitions
│   │   ├── App.vue          # Root component
│   │   └── main.js          # Entry point
│   ├── public/              # Static assets
│   └── package.json         # Dependencies
```

## Page Construction Pattern

### 1. List View Pages

```vue
<!-- pages/[DocType]List.vue -->
<template>
  <LayoutHeader>
    <template #left-header>
      <ViewBreadcrumbs v-model="viewControls" :routeName="routeName" />
    </template>
    <template #right-header>
      <CustomActions v-if="customActions" :actions="customActions" />
      <Button variant="solid" :label="__('Create')" @click="showCreateModal = true">
        <template #prefix><FeatherIcon name="plus" class="h-4" /></template>
      </Button>
    </template>
  </LayoutHeader>
  
  <ViewControls
    ref="viewControls"
    v-model="items"
    v-model:loadMore="loadMore"
    :doctype="doctype"
    :filters="defaultFilters"
    :options="{
      allowedViews: ['list', 'group_by', 'kanban'],
    }"
  />
  
  <!-- View Type Components -->
  <ListView v-if="viewType === 'list'" v-model="items" :options="listOptions" />
  <KanbanView v-else-if="viewType === 'kanban'" v-model="items" :options="kanbanOptions" />
  <GroupByView v-else-if="viewType === 'group_by'" v-model="items" :options="groupOptions" />
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { createResource } from 'frappe-ui'
import ViewControls from '@/components/ViewControls.vue'

const route = useRoute()
const doctype = 'Your DocType'
const items = ref([])
const viewType = computed(() => route.params.viewType || 'list')

// Resource for fetching data
const listResource = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: doctype,
    fields: ['*'],
    filters: {},
    order_by: 'modified desc',
    start: 0,
    limit: 20,
  },
  auto: true,
  onSuccess: (data) => {
    items.value = data
  }
})
</script>
```

### 2. Detail View Pages

```vue
<!-- pages/[DocType]Detail.vue -->
<template>
  <LayoutHeader>
    <template #left-header>
      <Breadcrumbs :items="breadcrumbs" />
    </template>
    <template #right-header>
      <AssignTo v-model="doc._assign" :doctype="doctype" :docname="docId" />
      <StatusDropdown v-model="doc.status" :options="statusOptions" @change="updateStatus" />
      <Button variant="solid" :label="__('Save')" @click="save" />
    </template>
  </LayoutHeader>
  
  <div class="flex h-full overflow-hidden">
    <Tabs v-model="activeTab" :tabs="tabs">
      <template #tab-panel>
        <!-- Tab Content Components -->
        <component :is="activeTabComponent" v-model="doc" />
      </template>
    </Tabs>
    
    <Resizer side="right">
      <!-- Sidebar Content -->
      <DetailSidebar :doc="doc" @update="updateField" />
    </Resizer>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { createDocumentResource } from 'frappe-ui'

const route = useRoute()
const doctype = 'Your DocType'
const docId = computed(() => route.params.id)

const doc = createDocumentResource({
  doctype: doctype,
  name: docId.value,
  auto: true,
})

const tabs = [
  { name: 'details', label: 'Details', component: 'DetailsTab' },
  { name: 'activities', label: 'Activities', component: 'ActivitiesTab' },
  { name: 'attachments', label: 'Attachments', component: 'AttachmentsTab' },
]
</script>
```

## Component Patterns

### 1. Form Controls

```vue
<!-- components/Controls/TextInput.vue -->
<template>
  <div class="form-control">
    <label v-if="label" class="text-sm text-gray-600">{{ label }}</label>
    <Input
      v-model="value"
      :placeholder="placeholder"
      :disabled="disabled"
      @change="$emit('change', value)"
    />
    <div v-if="error" class="text-red-500 text-xs mt-1">{{ error }}</div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: String,
  label: String,
  placeholder: String,
  disabled: Boolean,
  error: String,
})

const emit = defineEmits(['update:modelValue', 'change'])

const value = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val)
})
</script>
```

### 2. List Item Components

```vue
<!-- components/ListViews/ListItem.vue -->
<template>
  <div class="list-item flex items-center px-4 py-3 hover:bg-gray-50">
    <Avatar :label="item.name" :image="item.image" size="md" />
    <div class="flex-1 ml-3">
      <div class="font-medium">{{ item.title }}</div>
      <div class="text-sm text-gray-500">{{ item.subtitle }}</div>
    </div>
    <div class="flex items-center gap-2">
      <Badge v-if="item.status" :label="item.status" :theme="statusTheme" />
      <slot name="actions" />
    </div>
  </div>
</template>
```

## State Management with Stores

### 1. Document Store Pattern

```javascript
// stores/document.js
import { defineStore } from 'pinia'
import { createResource } from 'frappe-ui'

export const useDocumentStore = defineStore('document', {
  state: () => ({
    doc: null,
    loading: false,
    error: null,
  }),
  
  actions: {
    async fetchDocument(doctype, name) {
      this.loading = true
      const resource = createResource({
        url: 'frappe.client.get',
        params: { doctype, name },
        onSuccess: (data) => {
          this.doc = data
          this.loading = false
        },
        onError: (error) => {
          this.error = error
          this.loading = false
        }
      })
      await resource.fetch()
    },
    
    async saveDocument() {
      const resource = createResource({
        url: 'frappe.client.save',
        params: this.doc,
        onSuccess: (data) => {
          this.doc = data
        }
      })
      await resource.submit()
    }
  }
})
```

### 2. List Store Pattern

```javascript
// stores/list.js
import { defineStore } from 'pinia'
import { createListResource } from 'frappe-ui'

export const useListStore = defineStore('list', {
  state: () => ({
    items: [],
    filters: {},
    sortBy: 'modified desc',
    pageLength: 20,
    currentPage: 0,
  }),
  
  getters: {
    filteredItems: (state) => {
      // Apply client-side filtering if needed
      return state.items
    }
  },
  
  actions: {
    async fetchList(doctype) {
      const resource = createListResource({
        doctype,
        fields: ['*'],
        filters: this.filters,
        orderBy: this.sortBy,
        pageLength: this.pageLength,
        start: this.currentPage * this.pageLength,
      })
      await resource.fetch()
      this.items = resource.data
    }
  }
})
```

## Composables for Reusability

### 1. Document Operations

```javascript
// composables/useDocument.js
import { ref, computed } from 'vue'
import { createDocumentResource } from 'frappe-ui'

export function useDocument(doctype, name) {
  const doc = createDocumentResource({
    doctype,
    name,
    auto: true,
  })
  
  const save = async () => {
    await doc.save()
  }
  
  const updateField = (field, value) => {
    doc.doc[field] = value
    doc.dirty = true
  }
  
  return {
    doc: computed(() => doc.doc),
    loading: computed(() => doc.loading),
    error: computed(() => doc.error),
    save,
    updateField,
  }
}
```

### 2. List Operations

```javascript
// composables/useList.js
import { ref, computed } from 'vue'
import { createListResource } from 'frappe-ui'

export function useList(doctype, options = {}) {
  const list = createListResource({
    doctype,
    fields: options.fields || ['*'],
    filters: options.filters || {},
    orderBy: options.orderBy || 'modified desc',
    pageLength: options.pageLength || 20,
    auto: true,
  })
  
  const reload = () => list.reload()
  const loadMore = () => list.loadMore()
  
  return {
    items: computed(() => list.data),
    loading: computed(() => list.loading),
    hasMore: computed(() => list.hasNextPage),
    reload,
    loadMore,
  }
}
```

## Router Configuration

```javascript
// router.js
import { createRouter, createWebHistory } from 'vue-router'
import { sessionStore } from '@/stores/session'

const routes = [
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('@/pages/Dashboard.vue'),
  },
  {
    path: '/:doctype/view/:viewType?',
    name: 'ListView',
    component: () => import('@/pages/ListView.vue'),
    props: true,
  },
  {
    path: '/:doctype/:id',
    name: 'DetailView',
    component: () => import('@/pages/DetailView.vue'),
    props: true,
  }
]

const router = createRouter({
  history: createWebHistory('/app'),
  routes,
})

// Navigation guards
router.beforeEach(async (to, from, next) => {
  const { isLoggedIn } = sessionStore()
  
  if (!isLoggedIn && to.name !== 'Login') {
    window.location.href = '/login?redirect-to=' + to.fullPath
    return
  }
  
  next()
})

export default router
```

## UI/UX Design Principles

### 1. Consistent Layout Structure
- **Header**: Navigation, breadcrumbs, and primary actions
- **Main Content**: List/detail views with appropriate spacing
- **Sidebar**: Filters, metadata, and secondary actions
- **Footer**: Pagination and bulk actions

### 2. Component Hierarchy
```
LayoutHeader
├── Breadcrumbs
├── PageTitle
└── ActionButtons

ViewControls
├── QuickFilters
├── SearchBar
├── FilterDropdown
├── SortDropdown
└── ViewToggle

ListView/DetailView
├── DataTable/Form
├── EmptyState
└── LoadingState

Sidebar
├── MetaInfo
├── RelatedLinks
└── ActivityFeed
```

### 3. Responsive Design
- Mobile-first approach
- Breakpoints: sm (640px), md (768px), lg (1024px), xl (1280px)
- Touch-friendly interfaces for mobile
- Collapsible sidebars and navigation

### 4. Interaction Patterns
- **Loading States**: Skeleton screens for better perceived performance
- **Error Handling**: Toast notifications for errors, inline validation
- **Confirmation**: Modal dialogs for destructive actions
- **Feedback**: Visual feedback for user actions (hover, active, disabled states)

### 5. Color System
```css
/* Primary Colors */
--primary: #2563eb;    /* Blue */
--secondary: #64748b;  /* Slate */
--success: #10b981;    /* Green */
--warning: #f59e0b;    /* Amber */
--danger: #ef4444;     /* Red */

/* Neutral Colors */
--gray-50: #f9fafb;
--gray-100: #f3f4f6;
--gray-900: #111827;
```

### 6. Typography
```css
/* Font Sizes */
--text-xs: 0.75rem;
--text-sm: 0.875rem;
--text-base: 1rem;
--text-lg: 1.125rem;
--text-xl: 1.25rem;

/* Font Weights */
--font-normal: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
```

## DocType Optimization for Vue Frontend

### 1. Field Configuration
```json
{
  "fieldname": "customer_name",
  "fieldtype": "Data",
  "label": "Customer Name",
  "reqd": 1,
  "in_list_view": 1,
  "in_standard_filter": 1,
  "bold": 1,
  "options": {
    "placeholder": "Enter customer name",
    "maxlength": 100
  }
}
```

### 2. List View Settings
```python
# In DocType controller
def get_list_settings(self):
    return {
        "fields": ["name", "customer_name", "status", "modified"],
        "filters": [],
        "order_by": "modified desc",
        "group_by": "status",
        "kanban_field": "status"
    }
```

### 3. Custom Actions
```javascript
// In page component
const customActions = [
  {
    label: 'Export',
    icon: 'download',
    action: () => exportData()
  },
  {
    label: 'Import',
    icon: 'upload',
    action: () => showImportModal.value = true
  }
]
```

## Performance Optimization

### 1. Code Splitting
```javascript
// Lazy load components
const Dashboard = () => import('@/pages/Dashboard.vue')
const ListView = () => import('@/pages/ListView.vue')
```

### 2. Data Caching
```javascript
// Use cache parameter in resources
const resource = createResource({
  url: 'frappe.client.get_list',
  cache: ['List', doctype],
  params: { doctype }
})
```

### 3. Virtual Scrolling
```vue
<!-- For large lists -->
<VirtualList
  :items="items"
  :item-height="60"
  :buffer="5"
>
  <template #default="{ item }">
    <ListItem :item="item" />
  </template>
</VirtualList>
```

## Testing Strategy

### 1. Unit Tests
```javascript
// component.test.js
import { mount } from '@vue/test-utils'
import Component from '@/components/Component.vue'

describe('Component', () => {
  it('renders correctly', () => {
    const wrapper = mount(Component, {
      props: { title: 'Test' }
    })
    expect(wrapper.text()).toContain('Test')
  })
})
```

### 2. Integration Tests
```javascript
// Using Cypress
describe('List View', () => {
  it('loads and displays items', () => {
    cy.visit('/items/view/list')
    cy.get('[data-testid="list-item"]').should('have.length.gt', 0)
  })
})
```

## Implementation Checklist

- [ ] Set up Vue 3 project with Vite
- [ ] Install and configure Frappe-UI
- [ ] Create base layout components
- [ ] Implement router with navigation guards
- [ ] Set up state management stores
- [ ] Create reusable form controls
- [ ] Build list view components
- [ ] Build detail view components
- [ ] Implement data fetching with resources
- [ ] Add loading and error states
- [ ] Implement responsive design
- [ ] Set up testing framework
- [ ] Configure build and deployment

## Best Practices

1. **Component Naming**: Use PascalCase for components, kebab-case for files
2. **Props Validation**: Always define prop types and defaults
3. **Composition API**: Prefer Composition API over Options API
4. **TypeScript**: Consider using TypeScript for better type safety
5. **Accessibility**: Follow WCAG guidelines, use semantic HTML
6. **Performance**: Lazy load routes, optimize bundle size
7. **Documentation**: Document components with JSDoc comments
8. **Error Boundaries**: Implement error boundaries for graceful failures
9. **Security**: Sanitize user input, validate permissions
10. **Internationalization**: Use translation functions for all user-facing text