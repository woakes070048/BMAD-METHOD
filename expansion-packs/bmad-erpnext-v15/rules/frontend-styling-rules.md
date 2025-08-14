# Frontend Styling Rules for Vue + frappe-ui

## Core Style Architecture

### 1. Base Styles
```css
/* Always import frappe-ui base styles first */
@import "frappe-ui/src/style.css";

/* Then add your custom styles using Tailwind layers */
@layer components {
  .custom-component {
    @apply /* tailwind classes */;
  }
}
```

### 2. Component Structure Pattern
```vue
<template>
  <div class="container-class">
    <!-- Mobile-first responsive design -->
    <div class="flex flex-col sm:flex-row gap-2 sm:gap-4">
      <!-- Content -->
    </div>
  </div>
</template>

<style scoped>
/* Component-specific styles only when necessary */
/* Prefer Tailwind utility classes */
</style>
```

## Frappe CRM UI Patterns

### 1. Layout Components
```vue
<!-- Standard Page Layout -->
<LayoutHeader>
  <template #left-header>
    <Breadcrumbs :items="breadcrumbs" />
  </template>
  <template #right-header>
    <Button variant="solid" @click="action">
      <template #prefix>
        <Icon name="plus" class="h-4 w-4" />
      </template>
      {{ label }}
    </Button>
  </template>
</LayoutHeader>

<!-- Content Area -->
<div class="flex flex-col gap-4 p-4 sm:p-6">
  <!-- Your content -->
</div>
```

### 2. Responsive Breakpoints
```css
/* Follow Frappe CRM patterns */
Mobile:  < 640px  (default)
Tablet:  >= 640px (sm:)
Desktop: >= 1024px (lg:)
Wide:    >= 1280px (xl:)

/* Example responsive pattern */
class="px-3 sm:px-5 lg:px-6"
class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4"
```

### 3. Color System
```javascript
// Use Tailwind's gray scale for neutrals
gray-50:  #f9fafb  // Backgrounds
gray-100: #f3f4f6  // Hover states
gray-200: #e5e7eb  // Borders
gray-500: #6b7280  // Muted text
gray-700: #374151  // Body text
gray-900: #111827  // Headings

// Semantic colors from frappe-ui
primary:   var(--primary-color)
success:   green-600
warning:   yellow-600
danger:    red-600
```

## Component Styling Rules

### 1. Buttons
```vue
<!-- Primary Action -->
<Button variant="solid" :loading="isLoading">
  Action
</Button>

<!-- Secondary Action -->
<Button variant="outline">
  Cancel
</Button>

<!-- Icon Button -->
<Button variant="ghost">
  <Icon name="settings" class="h-4 w-4" />
</Button>
```

### 2. Forms
```vue
<!-- Form Field Pattern -->
<div class="space-y-4">
  <FormControl label="Field Label" :error="errors.field">
    <Input 
      v-model="value"
      placeholder="Enter value"
      :disabled="isDisabled"
    />
  </FormControl>
</div>

<!-- Field Group Pattern -->
<div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
  <FormControl>...</FormControl>
  <FormControl>...</FormControl>
</div>
```

### 3. Lists and Tables
```vue
<!-- List View Pattern -->
<ListView
  :columns="columns"
  :rows="data"
  :loading="loading"
  class="border border-gray-200 rounded-lg"
>
  <template #empty>
    <EmptyState 
      title="No items found"
      description="Create your first item to get started"
    />
  </template>
</ListView>
```

### 4. Cards
```vue
<!-- Standard Card -->
<div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
  <h3 class="text-lg font-semibold text-gray-900 mb-2">
    Card Title
  </h3>
  <p class="text-gray-600">
    Card content
  </p>
</div>

<!-- Clickable Card -->
<div class="
  bg-white rounded-lg shadow-sm border border-gray-200 p-4
  hover:shadow-md transition-shadow cursor-pointer
">
  <!-- Content -->
</div>
```

## Typography Rules

### 1. Text Hierarchy
```html
<!-- Page Title -->
<h1 class="text-2xl font-bold text-gray-900">Page Title</h1>

<!-- Section Title -->
<h2 class="text-xl font-semibold text-gray-900">Section</h2>

<!-- Subsection -->
<h3 class="text-lg font-medium text-gray-900">Subsection</h3>

<!-- Body Text -->
<p class="text-base text-gray-700">Body text</p>

<!-- Small/Helper Text -->
<span class="text-sm text-gray-500">Helper text</span>
```

### 2. Text Utilities
```css
/* Truncation */
class="truncate"              /* Single line */
class="line-clamp-2"          /* Multi-line */

/* Alignment */
class="text-left sm:text-center lg:text-right"

/* Weight */
class="font-normal"   /* 400 */
class="font-medium"   /* 500 */
class="font-semibold" /* 600 */
class="font-bold"     /* 700 */
```

## Spacing System

### 1. Consistent Spacing
```css
/* Use consistent spacing scale */
gap-1:  0.25rem (4px)
gap-2:  0.5rem  (8px)
gap-3:  0.75rem (12px)
gap-4:  1rem    (16px)
gap-6:  1.5rem  (24px)
gap-8:  2rem    (32px)

/* Page padding */
class="p-4 sm:p-6"

/* Section spacing */
class="space-y-4" /* Vertical spacing between sections */
```

### 2. Component Spacing
```vue
<!-- Button Groups -->
<div class="flex gap-2">
  <Button>Save</Button>
  <Button>Cancel</Button>
</div>

<!-- Form Sections -->
<div class="space-y-6">
  <section class="space-y-4">
    <!-- Form fields -->
  </section>
</div>
```

## Animation & Transitions

### 1. Standard Transitions
```css
/* Use for hover states */
class="transition-colors duration-200"

/* Use for layout changes */
class="transition-all duration-200"

/* Use for shadows */
class="transition-shadow duration-200"
```

### 2. Loading States
```vue
<!-- Skeleton Loading -->
<div v-if="loading" class="animate-pulse">
  <div class="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
  <div class="h-4 bg-gray-200 rounded w-1/2"></div>
</div>

<!-- Spinner -->
<LoadingIndicator v-if="loading" />
```

## Mobile-First Rules

### 1. Touch Targets
```css
/* Minimum touch target size: 44x44px */
class="min-h-[44px] min-w-[44px]"

/* Spacing for touch */
class="py-3 px-4" /* For buttons */
class="p-4"       /* For clickable cards */
```

### 2. Mobile Navigation
```vue
<!-- Responsive Navigation -->
<div class="flex lg:hidden">
  <!-- Mobile menu -->
</div>
<div class="hidden lg:flex">
  <!-- Desktop menu -->
</div>
```

### 3. Responsive Tables
```vue
<!-- Mobile: Cards, Desktop: Table -->
<div class="block sm:hidden">
  <!-- Card layout for mobile -->
  <div v-for="item in items" class="bg-white rounded-lg p-4 mb-2">
    <!-- Card content -->
  </div>
</div>

<div class="hidden sm:block">
  <!-- Table for desktop -->
  <ListView :columns="columns" :rows="items" />
</div>
```

## Accessibility Rules

### 1. Focus States
```css
/* Always visible focus indicators */
class="focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
```

### 2. ARIA Labels
```vue
<Button 
  :aria-label="isOpen ? 'Close menu' : 'Open menu'"
  @click="toggle"
>
  <Icon :name="isOpen ? 'x' : 'menu'" />
</Button>
```

### 3. Semantic HTML
```vue
<!-- Use proper semantic elements -->
<nav> for navigation
<main> for main content
<section> for sections
<article> for self-contained content
<button> for actions (not <div @click>)
```

## Performance Rules

### 1. Optimize Images
```vue
<!-- Lazy load images -->
<img 
  loading="lazy"
  :src="imageSrc"
  :alt="imageAlt"
  class="rounded-lg"
>
```

### 2. Code Splitting
```javascript
// Lazy load heavy components
const HeavyComponent = () => import('@/components/HeavyComponent.vue')
```

### 3. Minimize Re-renders
```vue
<!-- Use v-once for static content -->
<div v-once>
  {{ staticContent }}
</div>

<!-- Use v-memo for expensive lists -->
<div v-for="item in items" :key="item.id" v-memo="[item.id, item.updated]">
  <!-- Expensive rendering -->
</div>
```

## Dark Mode Support

### 1. Color Classes
```css
/* Always provide dark mode variants */
class="bg-white dark:bg-gray-900"
class="text-gray-900 dark:text-gray-100"
class="border-gray-200 dark:border-gray-700"
```

### 2. Dark Mode Toggle
```vue
<script setup>
import { useTheme } from '@/composables/theme'
const { isDark, toggle } = useTheme()
</script>

<Button @click="toggle">
  <Icon :name="isDark ? 'sun' : 'moon'" />
</Button>
```

## Common Patterns from Frappe CRM

### 1. View Controls
```vue
<div class="flex items-center justify-between gap-2">
  <div class="flex gap-2">
    <Filter v-model="filters" />
    <SortBy v-model="sortBy" />
  </div>
  <div class="flex gap-2">
    <Button @click="refresh">
      <RefreshIcon class="h-4 w-4" />
    </Button>
    <ColumnSettings v-model="columns" />
  </div>
</div>
```

### 2. Empty States
```vue
<EmptyState
  :title="`No ${doctype} found`"
  :description="Create your first record to get started"
  :icon="icon"
>
  <template #actions>
    <Button variant="solid" @click="create">
      Create {{ doctype }}
    </Button>
  </template>
</EmptyState>
```

### 3. Status Indicators
```vue
<!-- Status Badge -->
<Badge 
  :variant="status === 'active' ? 'success' : 'gray'"
  :label="status"
/>

<!-- Progress Indicator -->
<div class="flex items-center gap-2">
  <div class="h-2 w-2 rounded-full bg-green-500"></div>
  <span class="text-sm text-gray-600">Active</span>
</div>
```

## Testing Your Styles

### Visual Regression Testing
```bash
# Test responsive design
# Open browser dev tools
# Test at: 320px, 640px, 1024px, 1440px

# Test interactions
# Hover states
# Focus states
# Active states
# Disabled states

# Test themes
# Light mode
# Dark mode (if supported)
```

### Accessibility Testing
```bash
# Keyboard navigation
# Tab through all interactive elements
# Ensure focus indicators are visible

# Screen reader testing
# Use browser extensions or native screen readers
# Verify ARIA labels make sense
```

## Remember

1. **Mobile-first**: Design for mobile, enhance for desktop
2. **Consistency**: Use frappe-ui components when available
3. **Performance**: Keep bundle size small, lazy load when needed
4. **Accessibility**: Always consider keyboard and screen reader users
5. **Maintainability**: Use utility classes over custom CSS when possible