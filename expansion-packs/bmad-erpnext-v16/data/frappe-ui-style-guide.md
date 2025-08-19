# Frappe UI Style Guide

## Overview

This comprehensive style guide provides design standards, component patterns, and best practices for creating consistent, accessible, and beautiful user interfaces using Frappe UI components in ERPNext v16 applications.

## Design System Foundation

### Color Palette

#### Primary Colors
```css
/* Primary Brand Colors */
:root {
  --primary-50: #eff6ff;
  --primary-100: #dbeafe;
  --primary-200: #bfdbfe;
  --primary-300: #93c5fd;
  --primary-400: #60a5fa;
  --primary-500: #3b82f6;  /* Primary brand color */
  --primary-600: #2563eb;
  --primary-700: #1d4ed8;
  --primary-800: #1e40af;
  --primary-900: #1e3a8a;
}
```

#### Semantic Colors
```css
/* Status and Feedback Colors */
:root {
  /* Success */
  --success-50: #ecfdf5;
  --success-500: #10b981;
  --success-700: #047857;
  
  /* Warning */
  --warning-50: #fffbeb;
  --warning-500: #f59e0b;
  --warning-700: #b45309;
  
  /* Danger */
  --danger-50: #fef2f2;
  --danger-500: #ef4444;
  --danger-700: #b91c1c;
  
  /* Info */
  --info-50: #eff6ff;
  --info-500: #3b82f6;
  --info-700: #1d4ed8;
}
```

#### Neutral Colors
```css
/* Gray Scale */
:root {
  --gray-50: #f9fafb;
  --gray-100: #f3f4f6;
  --gray-200: #e5e7eb;
  --gray-300: #d1d5db;
  --gray-400: #9ca3af;
  --gray-500: #6b7280;
  --gray-600: #4b5563;
  --gray-700: #374151;
  --gray-800: #1f2937;
  --gray-900: #111827;
}
```

#### Usage Guidelines
```vue
<template>
  <!-- Primary actions -->
  <Button variant="primary">Save Changes</Button>
  
  <!-- Success states -->
  <Badge variant="success">Active</Badge>
  
  <!-- Warning states -->
  <Alert variant="warning">Please review your settings</Alert>
  
  <!-- Danger actions -->
  <Button variant="danger">Delete Item</Button>
  
  <!-- Neutral content -->
  <div class="text-gray-600">Secondary information</div>
</template>
```

### Typography System

#### Font Hierarchy
```css
/* Typography Scale */
:root {
  /* Font Families */
  --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', Consolas, monospace;
  
  /* Font Sizes */
  --text-xs: 0.75rem;    /* 12px */
  --text-sm: 0.875rem;   /* 14px */
  --text-base: 1rem;     /* 16px */
  --text-lg: 1.125rem;   /* 18px */
  --text-xl: 1.25rem;    /* 20px */
  --text-2xl: 1.5rem;    /* 24px */
  --text-3xl: 1.875rem;  /* 30px */
  --text-4xl: 2.25rem;   /* 36px */
  
  /* Line Heights */
  --leading-tight: 1.25;
  --leading-normal: 1.5;
  --leading-relaxed: 1.75;
  
  /* Font Weights */
  --font-normal: 400;
  --font-medium: 500;
  --font-semibold: 600;
  --font-bold: 700;
}
```

#### Typography Usage
```vue
<template>
  <div class="content-hierarchy">
    <!-- Page Title -->
    <h1 class="text-3xl font-bold text-gray-900 mb-2">
      Page Title
    </h1>
    
    <!-- Section Heading -->
    <h2 class="text-2xl font-semibold text-gray-800 mb-4">
      Section Heading
    </h2>
    
    <!-- Subsection -->
    <h3 class="text-xl font-medium text-gray-700 mb-3">
      Subsection Title
    </h3>
    
    <!-- Body Text -->
    <p class="text-base text-gray-600 leading-normal mb-4">
      Regular body text with comfortable reading line height.
    </p>
    
    <!-- Secondary Text -->
    <p class="text-sm text-gray-500 leading-relaxed mb-2">
      Secondary information or metadata.
    </p>
    
    <!-- Caption -->
    <span class="text-xs text-gray-400 font-medium">
      Caption or label text
    </span>
    
    <!-- Code -->
    <code class="font-mono text-sm bg-gray-100 px-2 py-1 rounded">
      inline code
    </code>
  </div>
</template>
```

### Spacing System

#### Spatial Scale
```css
/* Spacing Scale (based on 4px grid) */
:root {
  --space-0: 0;
  --space-1: 0.25rem;  /* 4px */
  --space-2: 0.5rem;   /* 8px */
  --space-3: 0.75rem;  /* 12px */
  --space-4: 1rem;     /* 16px */
  --space-5: 1.25rem;  /* 20px */
  --space-6: 1.5rem;   /* 24px */
  --space-8: 2rem;     /* 32px */
  --space-10: 2.5rem;  /* 40px */
  --space-12: 3rem;    /* 48px */
  --space-16: 4rem;    /* 64px */
  --space-20: 5rem;    /* 80px */
  --space-24: 6rem;    /* 96px */
}
```

#### Spacing Guidelines
```vue
<template>
  <!-- Container Spacing -->
  <div class="p-6">        <!-- 24px padding -->
    
    <!-- Section Spacing -->
    <div class="space-y-8"> <!-- 32px vertical gaps -->
      
      <!-- Card Spacing -->
      <Card class="p-4">    <!-- 16px internal padding -->
        
        <!-- Form Spacing -->
        <div class="space-y-4"> <!-- 16px between form elements -->
          <Input />
          <Select />
          <Textarea />
        </div>
        
        <!-- Button Group -->
        <div class="flex space-x-3 mt-6"> <!-- 12px horizontal, 24px top -->
          <Button variant="secondary">Cancel</Button>
          <Button variant="primary">Save</Button>
        </div>
        
      </Card>
      
    </div>
    
  </div>
</template>
```

## Component Styling Standards

### Button Standards

#### Size Variants
```vue
<template>
  <!-- Size Examples -->
  <div class="flex items-center space-x-3">
    <Button size="small">Small Button</Button>
    <Button size="medium">Medium Button</Button>
    <Button size="large">Large Button</Button>
  </div>
</template>

<style>
/* Size Specifications */
.btn-small {
  padding: 0.375rem 0.75rem;  /* 6px 12px */
  font-size: 0.875rem;        /* 14px */
  line-height: 1.25;
}

.btn-medium {
  padding: 0.5rem 1rem;       /* 8px 16px */
  font-size: 1rem;            /* 16px */
  line-height: 1.5;
}

.btn-large {
  padding: 0.75rem 1.5rem;    /* 12px 24px */
  font-size: 1.125rem;        /* 18px */
  line-height: 1.5;
}
</style>
```

#### Color Variants
```vue
<template>
  <!-- Button Color Variants -->
  <div class="space-y-3">
    <!-- Primary Actions -->
    <Button variant="primary">Primary Action</Button>
    
    <!-- Secondary Actions -->
    <Button variant="secondary">Secondary Action</Button>
    
    <!-- Success Actions -->
    <Button variant="success">Confirm Action</Button>
    
    <!-- Warning Actions -->
    <Button variant="warning">Warning Action</Button>
    
    <!-- Danger Actions -->
    <Button variant="danger">Delete Action</Button>
    
    <!-- Ghost/Transparent -->
    <Button variant="ghost">Ghost Button</Button>
    
    <!-- Outline Style -->
    <Button variant="outline">Outline Button</Button>
  </div>
</template>
```

#### Button States
```vue
<template>
  <!-- Interactive States -->
  <div class="grid grid-cols-2 gap-4">
    <!-- Normal State -->
    <Button>Normal State</Button>
    
    <!-- Hover State (handled by CSS) -->
    <Button class="hover:opacity-90">Hover Effect</Button>
    
    <!-- Loading State -->
    <Button :loading="true">Loading...</Button>
    
    <!-- Disabled State -->
    <Button :disabled="true">Disabled</Button>
    
    <!-- Active/Pressed State -->
    <Button class="active:scale-95">Press Effect</Button>
  </div>
</template>
```

### Form Component Standards

#### Input Field Styling
```vue
<template>
  <!-- Standard Input Pattern -->
  <div class="form-group">
    <label class="block text-sm font-medium text-gray-700 mb-1">
      Field Label
      <span v-if="required" class="text-red-500 ml-1">*</span>
    </label>
    
    <Input
      v-model="value"
      :placeholder="placeholder"
      :error="errorMessage"
      :disabled="disabled"
      class="w-full"
    />
    
    <!-- Error Message -->
    <div v-if="errorMessage" class="mt-1 text-sm text-red-600">
      {{ errorMessage }}
    </div>
    
    <!-- Help Text -->
    <div v-if="helpText" class="mt-1 text-sm text-gray-500">
      {{ helpText }}
    </div>
  </div>
</template>
```

#### Form Layout Patterns
```vue
<template>
  <!-- Single Column Form -->
  <form class="space-y-6 max-w-lg">
    
    <!-- Two Column Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <FormField label="First Name" required>
        <Input v-model="form.firstName" />
      </FormField>
      
      <FormField label="Last Name" required>
        <Input v-model="form.lastName" />
      </FormField>
    </div>
    
    <!-- Full Width Field -->
    <FormField label="Email Address" required>
      <Input v-model="form.email" type="email" />
    </FormField>
    
    <!-- Action Buttons -->
    <div class="flex justify-end space-x-3 pt-4 border-t">
      <Button variant="secondary" @click="handleCancel">
        Cancel
      </Button>
      <Button variant="primary" type="submit" :loading="submitting">
        Save Changes
      </Button>
    </div>
    
  </form>
</template>
```

### Card and Layout Standards

#### Card Component Styling
```vue
<template>
  <!-- Standard Card Pattern -->
  <Card class="bg-white shadow-sm border border-gray-200 rounded-lg overflow-hidden">
    
    <!-- Card Header -->
    <template #header>
      <div class="px-6 py-4 border-b border-gray-200">
        <div class="flex justify-between items-center">
          <h3 class="text-lg font-semibold text-gray-900">
            Card Title
          </h3>
          <div class="flex space-x-2">
            <Button variant="ghost" size="small">
              Action
            </Button>
          </div>
        </div>
      </div>
    </template>
    
    <!-- Card Body -->
    <template #body>
      <div class="px-6 py-4">
        <!-- Card content -->
        <p class="text-gray-600">
          Card content goes here with proper spacing and typography.
        </p>
      </div>
    </template>
    
    <!-- Card Footer -->
    <template #footer>
      <div class="px-6 py-3 bg-gray-50 border-t border-gray-200">
        <div class="flex justify-end space-x-3">
          <Button variant="secondary" size="small">Cancel</Button>
          <Button variant="primary" size="small">Save</Button>
        </div>
      </div>
    </template>
    
  </Card>
</template>
```

#### Layout Grid Standards
```vue
<template>
  <!-- Dashboard Layout -->
  <div class="container mx-auto px-4 py-6">
    
    <!-- Header Section -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">Dashboard</h1>
      <p class="text-gray-600">Welcome to your dashboard</p>
    </div>
    
    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
      <StatCard 
        v-for="stat in stats" 
        :key="stat.id"
        :title="stat.title"
        :value="stat.value"
        :change="stat.change"
      />
    </div>
    
    <!-- Content Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      
      <!-- Main Content -->
      <div class="lg:col-span-2">
        <Card>
          <template #header>
            <h2 class="text-xl font-semibold">Recent Activity</h2>
          </template>
          <template #body>
            <ActivityList :items="activities" />
          </template>
        </Card>
      </div>
      
      <!-- Sidebar -->
      <div class="lg:col-span-1">
        <Card>
          <template #header>
            <h2 class="text-xl font-semibold">Quick Actions</h2>
          </template>
          <template #body>
            <QuickActionsList :actions="quickActions" />
          </template>
        </Card>
      </div>
      
    </div>
    
  </div>
</template>
```

## Data Display Standards

### Table Component Styling
```vue
<template>
  <!-- Enhanced Table -->
  <div class="bg-white shadow-sm border border-gray-200 rounded-lg overflow-hidden">
    
    <!-- Table Header -->
    <div class="px-6 py-4 border-b border-gray-200 bg-gray-50">
      <div class="flex justify-between items-center">
        <h3 class="text-lg font-semibold text-gray-900">Data Table</h3>
        <div class="flex space-x-3">
          <Input 
            placeholder="Search..." 
            class="w-64"
            v-model="searchQuery"
          />
          <Button variant="primary" size="small">
            <PlusIcon class="w-4 h-4 mr-2" />
            Add New
          </Button>
        </div>
      </div>
    </div>
    
    <!-- Table Content -->
    <Table 
      :columns="columns"
      :data="tableData"
      :loading="loading"
      @row-click="handleRowClick"
      class="w-full"
    >
      
      <!-- Custom Cell Templates -->
      <template #cell-status="{ value }">
        <Badge 
          :variant="getStatusVariant(value)"
          class="inline-flex"
        >
          {{ value }}
        </Badge>
      </template>
      
      <template #cell-actions="{ row }">
        <div class="flex space-x-2">
          <Button variant="ghost" size="small" @click="editItem(row)">
            Edit
          </Button>
          <Button variant="ghost" size="small" @click="deleteItem(row)">
            Delete
          </Button>
        </div>
      </template>
      
    </Table>
    
    <!-- Table Footer -->
    <div class="px-6 py-3 border-t border-gray-200 bg-gray-50">
      <div class="flex justify-between items-center">
        <div class="text-sm text-gray-600">
          Showing {{ startIndex }} to {{ endIndex }} of {{ totalRecords }} results
        </div>
        <Pagination 
          :current-page="currentPage"
          :total-pages="totalPages"
          @page-change="handlePageChange"
        />
      </div>
    </div>
    
  </div>
</template>
```

### List Component Styling
```vue
<template>
  <!-- List View -->
  <div class="bg-white shadow-sm border border-gray-200 rounded-lg">
    
    <!-- List Header -->
    <div class="px-6 py-4 border-b border-gray-200">
      <h3 class="text-lg font-semibold text-gray-900">List Items</h3>
    </div>
    
    <!-- List Items -->
    <div class="divide-y divide-gray-200">
      <div 
        v-for="item in items" 
        :key="item.id"
        class="px-6 py-4 hover:bg-gray-50 cursor-pointer transition-colors"
        @click="selectItem(item)"
      >
        <div class="flex justify-between items-start">
          
          <!-- Item Content -->
          <div class="flex-1 min-w-0">
            <div class="flex items-center space-x-3">
              <h4 class="text-sm font-medium text-gray-900 truncate">
                {{ item.title }}
              </h4>
              <Badge :variant="item.status" size="small">
                {{ item.status }}
              </Badge>
            </div>
            <p class="mt-1 text-sm text-gray-600 truncate">
              {{ item.description }}
            </p>
            <div class="mt-2 flex items-center space-x-4 text-xs text-gray-500">
              <span>{{ formatDate(item.created_at) }}</span>
              <span>{{ item.author }}</span>
            </div>
          </div>
          
          <!-- Item Actions -->
          <div class="flex-shrink-0 ml-4">
            <Dropdown>
              <template #trigger>
                <Button variant="ghost" size="small">
                  <MoreIcon class="w-4 h-4" />
                </Button>
              </template>
              <template #content>
                <DropdownItem @click="editItem(item)">Edit</DropdownItem>
                <DropdownItem @click="duplicateItem(item)">Duplicate</DropdownItem>
                <DropdownItem @click="deleteItem(item)">Delete</DropdownItem>
              </template>
            </Dropdown>
          </div>
          
        </div>
      </div>
    </div>
    
    <!-- Empty State -->
    <div v-if="items.length === 0" class="px-6 py-12 text-center">
      <div class="text-gray-400 mb-4">
        <EmptyIcon class="w-12 h-12 mx-auto" />
      </div>
      <h3 class="text-sm font-medium text-gray-900 mb-1">No items found</h3>
      <p class="text-sm text-gray-500">Get started by creating a new item.</p>
      <Button variant="primary" class="mt-4" @click="createNew">
        Create New Item
      </Button>
    </div>
    
  </div>
</template>
```

## Interactive Component Standards

### Modal Dialog Styling
```vue
<template>
  <!-- Modal Component -->
  <Modal 
    v-model="showModal"
    :title="modalTitle"
    size="medium"
    @close="handleClose"
  >
    
    <!-- Modal Header (if custom needed) -->
    <template #header>
      <div class="flex items-center justify-between p-6 border-b border-gray-200">
        <h2 class="text-xl font-semibold text-gray-900">
          {{ modalTitle }}
        </h2>
        <Button variant="ghost" size="small" @click="handleClose">
          <CloseIcon class="w-5 h-5" />
        </Button>
      </div>
    </template>
    
    <!-- Modal Body -->
    <template #body>
      <div class="p-6">
        <!-- Modal content with proper spacing -->
        <div class="space-y-4">
          <p class="text-gray-600">
            Modal content goes here with consistent spacing and typography.
          </p>
          
          <!-- Form elements if needed -->
          <div class="space-y-4">
            <FormField label="Field Label">
              <Input v-model="formData.field" />
            </FormField>
          </div>
        </div>
      </div>
    </template>
    
    <!-- Modal Footer -->
    <template #footer>
      <div class="flex justify-end space-x-3 p-6 border-t border-gray-200 bg-gray-50">
        <Button variant="secondary" @click="handleClose">
          Cancel
        </Button>
        <Button variant="primary" @click="handleSave" :loading="saving">
          Save Changes
        </Button>
      </div>
    </template>
    
  </Modal>
</template>
```

### Notification and Alert Styling
```vue
<template>
  <!-- Alert Component -->
  <Alert 
    :variant="alert.type"
    :show="alert.visible"
    @dismiss="dismissAlert"
    class="mb-4"
  >
    <div class="flex items-start">
      <div class="flex-shrink-0 mr-3">
        <component :is="getAlertIcon(alert.type)" class="w-5 h-5" />
      </div>
      <div class="flex-1">
        <h4 v-if="alert.title" class="font-medium mb-1">
          {{ alert.title }}
        </h4>
        <p class="text-sm">
          {{ alert.message }}
        </p>
        <div v-if="alert.actions" class="mt-3 flex space-x-3">
          <Button 
            v-for="action in alert.actions"
            :key="action.label"
            :variant="action.variant || 'ghost'"
            size="small"
            @click="action.handler"
          >
            {{ action.label }}
          </Button>
        </div>
      </div>
    </div>
  </Alert>
  
  <!-- Toast Notifications -->
  <div class="fixed top-4 right-4 z-50 space-y-2">
    <div
      v-for="notification in notifications"
      :key="notification.id"
      :class="[
        'max-w-sm p-4 rounded-lg shadow-lg transition-all duration-300',
        getNotificationClass(notification.type)
      ]"
    >
      <div class="flex items-start">
        <component 
          :is="getNotificationIcon(notification.type)" 
          class="w-5 h-5 mr-3 flex-shrink-0 mt-0.5"
        />
        <div class="flex-1">
          <p class="text-sm font-medium">{{ notification.title }}</p>
          <p v-if="notification.message" class="text-sm mt-1 opacity-90">
            {{ notification.message }}
          </p>
        </div>
        <Button 
          variant="ghost" 
          size="small" 
          @click="removeNotification(notification.id)"
          class="ml-2 -mr-1 -mt-1"
        >
          <CloseIcon class="w-4 h-4" />
        </Button>
      </div>
    </div>
  </div>
</template>
```

## Responsive Design Standards

### Breakpoint Strategy
```css
/* Responsive Breakpoints */
:root {
  /* Mobile First Approach */
  --screen-sm: 640px;   /* Small devices */
  --screen-md: 768px;   /* Medium devices */
  --screen-lg: 1024px;  /* Large devices */
  --screen-xl: 1280px;  /* Extra large */
  --screen-2xl: 1536px; /* 2X Extra large */
}
```

### Responsive Patterns
```vue
<template>
  <!-- Responsive Container -->
  <div class="container mx-auto px-4 sm:px-6 lg:px-8">
    
    <!-- Responsive Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 lg:gap-6">
      <Card v-for="item in items" :key="item.id">
        <!-- Card content -->
      </Card>
    </div>
    
    <!-- Responsive Navigation -->
    <nav class="block md:hidden">
      <!-- Mobile navigation -->
      <MobileMenu />
    </nav>
    
    <nav class="hidden md:block">
      <!-- Desktop navigation -->
      <DesktopMenu />
    </nav>
    
    <!-- Responsive Form -->
    <form class="space-y-6">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <FormField label="First Name">
          <Input class="w-full" />
        </FormField>
        <FormField label="Last Name">
          <Input class="w-full" />
        </FormField>
      </div>
      
      <!-- Stack buttons on mobile, inline on desktop -->
      <div class="flex flex-col sm:flex-row sm:justify-end space-y-3 sm:space-y-0 sm:space-x-3">
        <Button variant="secondary" class="w-full sm:w-auto">Cancel</Button>
        <Button variant="primary" class="w-full sm:w-auto">Save</Button>
      </div>
    </form>
    
  </div>
</template>
```

## Accessibility Standards

### ARIA and Semantic HTML
```vue
<template>
  <!-- Accessible Form -->
  <form role="form" aria-labelledby="form-title">
    <h2 id="form-title" class="sr-only">Contact Information Form</h2>
    
    <!-- Accessible Field -->
    <div class="form-group">
      <label 
        for="email-input"
        class="block text-sm font-medium text-gray-700"
      >
        Email Address
        <span aria-label="required" class="text-red-500">*</span>
      </label>
      <Input
        id="email-input"
        v-model="email"
        type="email"
        required
        :aria-invalid="hasEmailError"
        :aria-describedby="hasEmailError ? 'email-error' : null"
      />
      <div 
        v-if="hasEmailError"
        id="email-error"
        role="alert"
        class="mt-1 text-sm text-red-600"
      >
        {{ emailError }}
      </div>
    </div>
    
    <!-- Accessible Button -->
    <Button
      type="submit"
      :aria-label="isSubmitting ? 'Submitting form' : 'Submit form'"
      :disabled="isSubmitting"
    >
      {{ isSubmitting ? 'Submitting...' : 'Submit' }}
    </Button>
  </form>
  
  <!-- Accessible Modal -->
  <Modal
    v-model="showModal"
    role="dialog"
    aria-modal="true"
    :aria-labelledby="modalTitleId"
  >
    <h2 :id="modalTitleId" class="text-xl font-semibold">
      {{ modalTitle }}
    </h2>
    <!-- Modal content -->
  </Modal>
</template>
```

### Keyboard Navigation
```vue
<script setup>
import { onMounted, onUnmounted } from 'vue'

// Keyboard navigation support
function handleKeyDown(event) {
  switch (event.key) {
    case 'Escape':
      if (showModal.value) {
        closeModal()
      }
      break
    case 'Enter':
      if (event.ctrlKey || event.metaKey) {
        handleSubmit()
      }
      break
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleKeyDown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeyDown)
})
</script>
```

## Animation and Transitions

### Transition Standards
```css
/* Standard Transitions */
:root {
  /* Duration */
  --transition-fast: 150ms;
  --transition-normal: 200ms;
  --transition-slow: 300ms;
  
  /* Easing */
  --ease-in: cubic-bezier(0.4, 0, 1, 1);
  --ease-out: cubic-bezier(0, 0, 0.2, 1);
  --ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
}

/* Component Transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity var(--transition-normal) var(--ease-in-out);
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.slide-enter-active,
.slide-leave-active {
  transition: transform var(--transition-normal) var(--ease-in-out);
}

.slide-enter-from {
  transform: translateX(-100%);
}

.slide-leave-to {
  transform: translateX(100%);
}
```

### Animation Usage
```vue
<template>
  <!-- Page Transitions -->
  <transition name="fade" mode="out-in">
    <component :is="currentComponent" :key="currentRoute" />
  </transition>
  
  <!-- Modal Transitions -->
  <transition name="modal">
    <Modal v-if="showModal" />
  </transition>
  
  <!-- List Transitions -->
  <transition-group name="list" tag="div" class="space-y-2">
    <div
      v-for="item in items"
      :key="item.id"
      class="p-4 bg-white rounded border"
    >
      {{ item.name }}
    </div>
  </transition-group>
</template>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: all 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
  transform: scale(0.9);
}

.list-enter-active,
.list-leave-active {
  transition: all 0.3s ease;
}

.list-enter-from,
.list-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

.list-move {
  transition: transform 0.3s ease;
}
</style>
```

## Performance Guidelines

### CSS Optimization
```css
/* Use CSS custom properties for theming */
.component {
  background-color: var(--background-color);
  color: var(--text-color);
  transition: all var(--transition-normal);
}

/* Minimize repaints and reflows */
.animated-element {
  transform: translateX(0);
  will-change: transform;
}

/* Use efficient selectors */
.button-primary { /* Good: class selector */ }
div.button { /* Avoid: element + class */ }
```

### Bundle Size Optimization
```vue
<script setup>
// Tree-shake unused components
import { Button, Input } from 'frappe-ui'
// Instead of: import * from 'frappe-ui'

// Lazy load heavy components
const HeavyChart = defineAsyncComponent(() => 
  import('./components/HeavyChart.vue')
)

// Use dynamic imports for conditional features
async function loadFeature() {
  if (userNeedsFeature) {
    const { AdvancedFeature } = await import('./AdvancedFeature.vue')
    return AdvancedFeature
  }
}
</script>
```

## Best Practices Summary

### Design Consistency
1. **Use Design Tokens**: Utilize CSS custom properties for consistent theming
2. **Follow Spacing Scale**: Use the 4px-based spacing system consistently
3. **Maintain Typography Hierarchy**: Use defined font sizes and weights
4. **Color Usage**: Apply semantic colors appropriately

### User Experience
1. **Accessibility First**: Ensure all components are keyboard and screen reader accessible
2. **Progressive Enhancement**: Design for mobile first, enhance for larger screens
3. **Performance**: Optimize for fast loading and smooth interactions
4. **Feedback**: Provide clear visual feedback for user actions

### Development Workflow
1. **Component Reusability**: Create reusable, well-documented components
2. **Style Isolation**: Use scoped styles and avoid global style pollution
3. **Testing**: Test components across devices and accessibility tools
4. **Documentation**: Document component APIs and usage examples

This style guide ensures consistent, accessible, and maintainable user interfaces across ERPNext v16 applications using Frappe UI components.