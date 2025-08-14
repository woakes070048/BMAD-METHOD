# Frappe UI Style Guide for ERPNext Apps

## Core Design Principles

### 1. Consistency
- Use frappe-ui components consistently across all views
- Maintain consistent spacing, colors, and typography
- Follow established patterns for similar functionality

### 2. Mobile-First Responsive Design
- Design for mobile first, enhance for desktop
- Use Tailwind's responsive prefixes consistently
- Test on multiple screen sizes

### 3. Performance
- Lazy load components when possible
- Minimize bundle size
- Use virtual scrolling for large datasets

## Component Library Structure

### 1. Base Components (from frappe-ui)
```vue
<!-- Always use these over custom components -->
<Button variant="solid|outline|ghost" />
<Input type="text|email|password|number" />
<Textarea rows="3" />
<Select :options="options" />
<Checkbox v-model="checked" />
<Dialog v-model="show" />
<LoadingIndicator />
<EmptyState />
<Badge :label="text" theme="blue|green|red|yellow" />
<Dropdown :options="menuItems" />
```

### 2. Layout Components
```vue
<!-- Standard page layout -->
<LayoutHeader>
  <template #left-header>
    <Breadcrumbs :items="breadcrumbs" />
  </template>
  <template #right-header>
    <Button variant="solid">Primary Action</Button>
  </template>
</LayoutHeader>

<!-- Content wrapper -->
<div class="flex-1 overflow-auto p-4 sm:p-6">
  <!-- Your content -->
</div>
```

### 3. Data Display Components
```vue
<!-- List views -->
<ListView 
  :columns="columns" 
  :rows="data" 
  :loading="loading"
  @row-click="handleRowClick"
/>

<!-- Cards -->
<div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
  <h3 class="text-lg font-semibold text-gray-900 mb-2">Card Title</h3>
  <p class="text-gray-600">Card content</p>
</div>
```

## Color System

### 1. Semantic Colors
```css
/* Primary colors (from frappe-ui) */
Primary: var(--primary-color)
Success: green-600 (#16a34a)
Warning: yellow-600 (#ca8a04)  
Danger: red-600 (#dc2626)
Info: blue-600 (#2563eb)

/* Neutral grays */
Gray-50: #f9fafb   /* Backgrounds */
Gray-100: #f3f4f6  /* Hover states */
Gray-200: #e5e7eb  /* Borders */
Gray-500: #6b7280  /* Muted text */
Gray-700: #374151  /* Body text */
Gray-900: #111827  /* Headings */
```

### 2. Status Colors
```javascript
const statusColors = {
  draft: 'gray',
  pending: 'yellow',
  approved: 'green',
  rejected: 'red',
  active: 'green',
  inactive: 'gray'
}
```

## Typography Scale

### 1. Headings
```css
/* Page title */
class="text-2xl font-bold text-gray-900"

/* Section title */
class="text-xl font-semibold text-gray-900"

/* Subsection */
class="text-lg font-medium text-gray-900"

/* Card title */
class="text-base font-semibold text-gray-900"
```

### 2. Body Text
```css
/* Primary text */
class="text-base text-gray-700"

/* Secondary text */
class="text-sm text-gray-600"

/* Helper/meta text */
class="text-xs text-gray-500"
```

## Spacing System

### 1. Consistent Scale
```css
/* Use Tailwind spacing consistently */
gap-2:  8px    /* Between buttons */
gap-4:  16px   /* Between form sections */
gap-6:  24px   /* Between major sections */

/* Padding scale */
p-2:    8px    /* Compact elements */
p-4:    16px   /* Standard elements */
p-6:    24px   /* Spacious elements */
```

### 2. Page Layout Spacing
```css
/* Page padding */
class="p-4 sm:p-6"

/* Section spacing */
class="space-y-4" /* Form fields */
class="space-y-6" /* Major sections */
```

## Form Design Patterns

### 1. Standard Form Layout
```vue
<template>
  <form class="space-y-6">
    <!-- Form sections -->
    <div class="space-y-4">
      <h3 class="text-lg font-medium text-gray-900">Section Title</h3>
      
      <!-- Form grid -->
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <FormControl label="Field Label" :error="errors.field">
          <Input v-model="data.field" placeholder="Enter value" />
        </FormControl>
      </div>
    </div>
    
    <!-- Actions -->
    <div class="flex gap-2 pt-4">
      <Button variant="solid" type="submit">Save</Button>
      <Button variant="outline" @click="cancel">Cancel</Button>
    </div>
  </form>
</template>
```

### 2. Field Layout Rules
```css
/* Full-width fields */
class="sm:col-span-2" /* For textareas, tables, rich text */

/* Half-width fields */
class="sm:col-span-1" /* For inputs, selects, dates */

/* Responsive stacking */
class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4"
```

## List and Table Patterns

### 1. Standard List View
```vue
<template>
  <div class="space-y-4">
    <!-- List controls -->
    <div class="flex items-center justify-between">
      <div class="flex gap-2">
        <Input placeholder="Search..." v-model="search" />
        <Select :options="filterOptions" v-model="filter" />
      </div>
      <Button variant="solid" @click="create">
        <template #prefix>
          <Icon name="plus" class="h-4 w-4" />
        </template>
        Create New
      </Button>
    </div>
    
    <!-- List content -->
    <ListView 
      :columns="columns" 
      :rows="filteredData" 
      :loading="loading"
      @row-click="handleRowClick"
    >
      <template #empty>
        <EmptyState 
          title="No items found"
          description="Create your first item to get started"
        />
      </template>
    </ListView>
  </div>
</template>
```

### 2. Mobile-Responsive Tables
```vue
<!-- Desktop: Table, Mobile: Cards -->
<div class="hidden sm:block">
  <ListView :columns="columns" :rows="data" />
</div>

<div class="block sm:hidden space-y-2">
  <div v-for="item in data" :key="item.id" 
       class="bg-white rounded-lg p-4 shadow-sm border">
    <h4 class="font-semibold">{{ item.title }}</h4>
    <p class="text-sm text-gray-600 mt-1">{{ item.description }}</p>
    <div class="flex justify-between items-center mt-3">
      <Badge :label="item.status" />
      <span class="text-xs text-gray-500">{{ item.date }}</span>
    </div>
  </div>
</div>
```

## Navigation Patterns

### 1. Breadcrumb Navigation
```vue
<Breadcrumbs :items="[
  { label: 'Home', route: '/' },
  { label: 'Customers', route: '/customers' },
  { label: customer.name }
]" />
```

### 2. Tab Navigation
```vue
<div class="border-b border-gray-200">
  <nav class="-mb-px flex space-x-8">
    <button
      v-for="tab in tabs"
      :key="tab.id"
      :class="[
        'py-2 px-1 border-b-2 font-medium text-sm',
        activeTab === tab.id
          ? 'border-primary text-primary'
          : 'border-transparent text-gray-500 hover:text-gray-700'
      ]"
      @click="activeTab = tab.id"
    >
      {{ tab.label }}
    </button>
  </nav>
</div>
```

## Modal and Dialog Patterns

### 1. Standard Modal
```vue
<Dialog v-model="showModal" :options="{ size: 'lg' }">
  <template #body>
    <div class="space-y-4">
      <h2 class="text-lg font-semibold">Modal Title</h2>
      <p class="text-gray-600">Modal content</p>
      <!-- Form or content -->
    </div>
  </template>
  <template #actions>
    <div class="flex gap-2">
      <Button variant="outline" @click="showModal = false">Cancel</Button>
      <Button variant="solid" @click="confirm">Confirm</Button>
    </div>
  </template>
</Dialog>
```

### 2. Confirmation Dialog
```vue
<Dialog v-model="showConfirm" :options="{ size: 'sm' }">
  <template #body>
    <div class="text-center">
      <Icon name="alert-triangle" class="h-12 w-12 text-red-600 mx-auto mb-4" />
      <h3 class="text-lg font-medium text-gray-900 mb-2">Confirm Delete</h3>
      <p class="text-gray-600">This action cannot be undone.</p>
    </div>
  </template>
  <template #actions>
    <div class="flex gap-2 justify-center">
      <Button variant="outline" @click="showConfirm = false">Cancel</Button>
      <Button variant="solid" theme="red" @click="deleteItem">Delete</Button>
    </div>
  </template>
</Dialog>
```

## Loading and Empty States

### 1. Loading Patterns
```vue
<!-- Skeleton loader -->
<div v-if="loading" class="space-y-4">
  <div v-for="i in 3" :key="i" class="animate-pulse">
    <div class="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
    <div class="h-4 bg-gray-200 rounded w-1/2"></div>
  </div>
</div>

<!-- Button loading -->
<Button :loading="saving" @click="save">
  Save Changes
</Button>

<!-- Page loading -->
<LoadingIndicator v-if="pageLoading" />
```

### 2. Empty State Patterns
```vue
<EmptyState
  v-if="!data.length && !loading"
  title="No items found"
  :description="hasFilters ? 'Try adjusting your filters' : 'Create your first item'"
  :icon="emptyIcon"
>
  <template #actions>
    <Button variant="solid" @click="createNew" v-if="!hasFilters">
      Create First Item
    </Button>
    <Button variant="outline" @click="clearFilters" v-else>
      Clear Filters
    </Button>
  </template>
</EmptyState>
```

## Status and Feedback Patterns

### 1. Status Indicators
```vue
<!-- Badge status -->
<Badge 
  :label="status" 
  :theme="getStatusTheme(status)"
/>

<!-- Dot indicator -->
<div class="flex items-center gap-2">
  <div :class="[
    'h-2 w-2 rounded-full',
    isActive ? 'bg-green-500' : 'bg-gray-400'
  ]"></div>
  <span class="text-sm">{{ statusText }}</span>
</div>
```

### 2. Toast Notifications
```javascript
// Success message
$toast.success('Item created successfully')

// Error message
$toast.error('Failed to save item')

// Warning message
$toast.warning('Please review your input')
```

## Responsive Design Rules

### 1. Breakpoint Usage
```css
/* Mobile-first approach */
/* Base: < 640px (mobile) */
/* sm: >= 640px (tablet) */
/* lg: >= 1024px (desktop) */
/* xl: >= 1280px (wide) */

/* Common patterns */
class="px-4 sm:px-6"
class="text-sm sm:text-base"
class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3"
class="flex flex-col sm:flex-row"
```

### 2. Mobile Optimizations
```vue
<!-- Hide/show content based on screen size -->
<div class="hidden sm:block">Desktop content</div>
<div class="block sm:hidden">Mobile content</div>

<!-- Responsive spacing -->
<div class="p-4 sm:p-6 lg:p-8">Content</div>

<!-- Responsive grid -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
  <!-- Items -->
</div>
```

## Animation and Transitions

### 1. Standard Transitions
```css
/* Hover transitions */
class="transition-colors duration-200"

/* Layout transitions */
class="transition-all duration-300"

/* Fade in/out */
class="transition-opacity duration-200"
```

### 2. Loading Animations
```css
/* Pulse animation for skeletons */
class="animate-pulse"

/* Spin animation for loading indicators */
class="animate-spin"
```

## Accessibility Guidelines

### 1. Focus States
```css
/* Always provide visible focus indicators */
class="focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
```

### 2. ARIA Labels
```vue
<Button :aria-label="buttonDescription">
  <Icon name="settings" />
</Button>

<Input :aria-describedby="field.help ? `${field.name}-help` : undefined" />
<div v-if="field.help" :id="`${field.name}-help`" class="text-sm text-gray-500">
  {{ field.help }}
</div>
```

### 3. Semantic HTML
```vue
<!-- Use proper semantic elements -->
<nav>Navigation content</nav>
<main>Main content</main>
<section>Content sections</section>
<button>Interactive elements</button> <!-- Not <div @click> -->
```

## Key Principles Summary

1. **Use frappe-ui components** - Don't recreate what exists
2. **Mobile-first responsive** - Design for small screens first
3. **Consistent spacing** - Use Tailwind scale systematically
4. **Semantic colors** - Green for success, red for danger, etc.
5. **Loading states** - Always show feedback during operations
6. **Empty states** - Guide users when no data exists
7. **Accessibility first** - Focus indicators, ARIA labels, semantic HTML
8. **Performance conscious** - Lazy load, virtual scroll large datasets
9. **Error handling** - Clear messages and recovery paths
10. **Progressive enhancement** - Basic functionality works, enhanced with JS