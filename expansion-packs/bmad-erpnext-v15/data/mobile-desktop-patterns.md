# Mobile-Desktop Responsive Patterns for ERPNext Vue Applications
## Complete Guide for Cross-Platform Development with Frappe UI

**Last Updated**: 2025-08-11  
**Framework Version**: Vue 3.4+ | Frappe UI 0.1.x | Ionic 8+ | ERPNext 15  
**Source**: Production patterns from CRM (desktop-first) and HRMS (mobile-first PWA with Ionic)

---

## 📱 Core Responsive Philosophy

### Desktop-First vs Mobile-First Approaches

#### Desktop-First Pattern (CRM Style)
```scss
// Desktop-first CSS approach
.sidebar {
  width: 256px;
  position: fixed;
  left: 0;
  top: 0;
  height: 100vh;
  
  // Tablet breakpoint
  @media (max-width: 1024px) {
    width: 200px;
  }
  
  // Mobile breakpoint
  @media (max-width: 768px) {
    position: absolute;
    left: -256px;
    transition: left 0.3s ease;
    z-index: 50;
    
    &.open {
      left: 0;
    }
  }
}

.main-content {
  margin-left: 256px;
  
  @media (max-width: 1024px) {
    margin-left: 200px;
  }
  
  @media (max-width: 768px) {
    margin-left: 0;
  }
}
```

#### Mobile-First Pattern (HRMS/Ionic Style)
```scss
// Mobile-first CSS approach
.content-area {
  padding: 16px;
  
  // Tablet breakpoint
  @media (min-width: 768px) {
    padding: 24px;
    max-width: 768px;
    margin: 0 auto;
  }
  
  // Desktop breakpoint
  @media (min-width: 1024px) {
    padding: 32px;
    max-width: 1200px;
    display: grid;
    grid-template-columns: 1fr 2fr;
    gap: 32px;
  }
}

.card-layout {
  // Mobile: stacked cards
  display: flex;
  flex-direction: column;
  gap: 16px;
  
  // Tablet: 2-column grid
  @media (min-width: 768px) {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 24px;
  }
  
  // Desktop: 3-column grid
  @media (min-width: 1024px) {
    grid-template-columns: repeat(3, 1fr);
    gap: 32px;
  }
}
```

## 🎨 Layout Patterns

### 1. Adaptive Navigation

#### Desktop Sidebar + Mobile Drawer
```vue
<!-- components/AppNavigation.vue -->
<template>
  <!-- Desktop Sidebar -->
  <aside
    v-if="!isMobile"
    class="fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg border-r"
  >
    <div class="flex flex-col h-full">
      <!-- Logo -->
      <div class="p-6 border-b">
        <img src="/logo.svg" alt="Logo" class="h-8" />
      </div>
      
      <!-- Navigation -->
      <nav class="flex-1 p-4 space-y-2">
        <router-link
          v-for="item in navigationItems"
          :key="item.name"
          :to="item.to"
          class="flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors"
          :class="[
            $route.name === item.name
              ? 'bg-blue-50 text-blue-700'
              : 'text-gray-600 hover:bg-gray-50'
          ]"
        >
          <FeatherIcon :name="item.icon" class="w-5 h-5 mr-3" />
          {{ item.label }}
        </router-link>
      </nav>
    </div>
  </aside>
  
  <!-- Mobile Drawer -->
  <div
    v-if="isMobile"
    :class="[
      'fixed inset-0 z-50 transition-opacity duration-300',
      showMobileNav ? 'opacity-100' : 'opacity-0 pointer-events-none'
    ]"
  >
    <!-- Backdrop -->
    <div
      class="absolute inset-0 bg-black bg-opacity-50"
      @click="showMobileNav = false"
    ></div>
    
    <!-- Drawer -->
    <div
      :class="[
        'absolute left-0 top-0 h-full w-64 bg-white shadow-xl transform transition-transform duration-300',
        showMobileNav ? 'translate-x-0' : '-translate-x-full'
      ]"
    >
      <div class="flex flex-col h-full">
        <!-- Header -->
        <div class="flex items-center justify-between p-4 border-b">
          <img src="/logo.svg" alt="Logo" class="h-8" />
          <Button
            icon="x"
            variant="ghost"
            size="sm"
            @click="showMobileNav = false"
          />
        </div>
        
        <!-- Navigation -->
        <nav class="flex-1 p-4 space-y-2">
          <router-link
            v-for="item in navigationItems"
            :key="item.name"
            :to="item.to"
            @click="showMobileNav = false"
            class="flex items-center px-3 py-3 text-base font-medium rounded-lg"
            :class="[
              $route.name === item.name
                ? 'bg-blue-50 text-blue-700'
                : 'text-gray-600'
            ]"
          >
            <FeatherIcon :name="item.icon" class="w-6 h-6 mr-3" />
            {{ item.label }}
          </router-link>
        </nav>
      </div>
    </div>
  </div>
  
  <!-- Mobile Header Bar -->
  <header
    v-if="isMobile"
    class="fixed top-0 left-0 right-0 z-40 bg-white shadow-sm border-b h-16"
  >
    <div class="flex items-center justify-between px-4 h-full">
      <Button
        icon="menu"
        variant="ghost"
        @click="showMobileNav = true"
      />
      
      <img src="/logo.svg" alt="Logo" class="h-8" />
      
      <div class="w-8"></div> <!-- Spacer for centering -->
    </div>
  </header>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { Button, FeatherIcon } from 'frappe-ui'

const showMobileNav = ref(false)
const screenWidth = ref(window.innerWidth)

const isMobile = computed(() => screenWidth.value < 768)

const navigationItems = [
  { name: 'Dashboard', to: '/', icon: 'home', label: 'Dashboard' },
  { name: 'Leads', to: '/leads', icon: 'users', label: 'Leads' },
  { name: 'Deals', to: '/deals', icon: 'dollar-sign', label: 'Deals' },
  { name: 'Contacts', to: '/contacts', icon: 'user', label: 'Contacts' }
]

const handleResize = () => {
  screenWidth.value = window.innerWidth
}

onMounted(() => {
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
})
</script>
```

### 2. Ionic Mobile Navigation

#### Ionic Tab Bar Navigation
```vue
<!-- layouts/IonicMobileLayout.vue -->
<template>
  <ion-app>
    <!-- Main content -->
    <ion-router-outlet id="main-content" />
    
    <!-- Tab bar for mobile navigation -->
    <ion-tab-bar slot="bottom">
      <ion-tab-button
        v-for="tab in tabs"
        :key="tab.name"
        :tab="tab.name"
        :href="tab.to"
        :class="{ 'tab-selected': $route.name === tab.name }"
      >
        <ion-icon :icon="tab.icon"></ion-icon>
        <ion-label>{{ tab.label }}</ion-label>
        <ion-badge
          v-if="tab.badge"
          color="danger"
          class="tab-badge"
        >
          {{ tab.badge }}
        </ion-badge>
      </ion-tab-button>
    </ion-tab-bar>
    
    <!-- Global components -->
    <Toasts />
  </ion-app>
</template>

<script setup>
import { computed, inject } from 'vue'
import {
  IonApp,
  IonRouterOutlet,
  IonTabBar,
  IonTabButton,
  IonIcon,
  IonLabel,
  IonBadge
} from '@ionic/vue'
import {
  home,
  calendar,
  person,
  notifications,
  settings
} from 'ionicons/icons'
import { Toasts } from 'frappe-ui'

const $route = inject('$route')
const notificationCount = inject('$notificationCount', 0)

const tabs = computed(() => [
  {
    name: 'Home',
    to: '/',
    icon: home,
    label: 'Home'
  },
  {
    name: 'Calendar',
    to: '/calendar',
    icon: calendar,
    label: 'Calendar'
  },
  {
    name: 'Profile',
    to: '/profile',
    icon: person,
    label: 'Profile'
  },
  {
    name: 'Notifications',
    to: '/notifications',
    icon: notifications,
    label: 'Alerts',
    badge: notificationCount.value > 0 ? notificationCount.value : null
  },
  {
    name: 'Settings',
    to: '/settings',
    icon: settings,
    label: 'Settings'
  }
])
</script>

<style scoped>
.tab-selected {
  --color-selected: var(--ion-color-primary);
}

.tab-badge {
  position: absolute;
  top: 4px;
  right: 8px;
  min-width: 16px;
  height: 16px;
  font-size: 10px;
}
</style>
```

### 3. Responsive Data Display

#### Adaptive Card Layouts
```vue
<!-- components/ResponsiveCardGrid.vue -->
<template>
  <div class="responsive-grid">
    <div
      v-for="item in items"
      :key="item.id"
      class="grid-item"
    >
      <!-- Mobile: Compact card -->
      <div
        v-if="isMobile"
        class="mobile-card"
        @click="$emit('item-click', item)"
      >
        <div class="flex items-center space-x-3">
          <Avatar :label="item.name" size="sm" />
          <div class="flex-1 min-w-0">
            <h3 class="font-medium text-sm truncate">{{ item.name }}</h3>
            <p class="text-xs text-gray-500 truncate">{{ item.subtitle }}</p>
          </div>
          <div class="text-right">
            <Badge
              :theme="getStatusTheme(item.status)"
              :variant="getStatusVariant(item.status)"
              size="sm"
            >
              {{ item.status }}
            </Badge>
            <p class="text-xs text-gray-500 mt-1">{{ formatCurrency(item.value) }}</p>
          </div>
        </div>
      </div>
      
      <!-- Desktop: Full card -->
      <div
        v-else
        class="desktop-card"
        @click="$emit('item-click', item)"
      >
        <div class="card-header">
          <div class="flex items-center space-x-3">
            <Avatar :label="item.name" size="md" />
            <div>
              <h3 class="font-semibold text-lg">{{ item.name }}</h3>
              <p class="text-sm text-gray-500">{{ item.subtitle }}</p>
            </div>
          </div>
          <Badge
            :theme="getStatusTheme(item.status)"
            :variant="getStatusVariant(item.status)"
          >
            {{ item.status }}
          </Badge>
        </div>
        
        <div class="card-content">
          <div class="grid grid-cols-2 gap-4 text-sm">
            <div>
              <span class="text-gray-500">Value:</span>
              <span class="font-medium ml-1">{{ formatCurrency(item.value) }}</span>
            </div>
            <div>
              <span class="text-gray-500">Date:</span>
              <span class="font-medium ml-1">{{ formatDate(item.date) }}</span>
            </div>
          </div>
        </div>
        
        <div class="card-actions">
          <Button size="sm" variant="ghost">View</Button>
          <Button size="sm" variant="subtle">Edit</Button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { Avatar, Badge, Button } from 'frappe-ui'
import { useResponsive } from '@/composables/useResponsive'

const props = defineProps({
  items: { type: Array, required: true }
})

const emit = defineEmits(['item-click'])

const { isMobile } = useResponsive()

// Status styling functions
const getStatusTheme = (status) => {
  const themes = {
    'Active': 'green',
    'Inactive': 'red',
    'Pending': 'yellow',
    'Draft': 'gray'
  }
  return themes[status] || 'gray'
}

const getStatusVariant = (status) => {
  return status === 'Active' ? 'solid' : 'subtle'
}

// Formatting functions
const formatCurrency = (value) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(value)
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  })
}
</script>

<style scoped>
.responsive-grid {
  display: grid;
  gap: 16px;
}

/* Mobile: Single column */
@media (max-width: 767px) {
  .responsive-grid {
    grid-template-columns: 1fr;
  }
}

/* Tablet: 2 columns */
@media (min-width: 768px) and (max-width: 1023px) {
  .responsive-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 20px;
  }
}

/* Desktop: 3 columns */
@media (min-width: 1024px) {
  .responsive-grid {
    grid-template-columns: repeat(3, 1fr);
    gap: 24px;
  }
}

.mobile-card {
  @apply bg-white p-4 rounded-lg shadow-sm border cursor-pointer;
  @apply hover:shadow-md transition-shadow;
}

.desktop-card {
  @apply bg-white rounded-lg shadow-sm border cursor-pointer;
  @apply hover:shadow-md transition-shadow overflow-hidden;
}

.card-header {
  @apply p-6 pb-4 flex items-center justify-between;
}

.card-content {
  @apply px-6 pb-4;
}

.card-actions {
  @apply px-6 py-4 bg-gray-50 border-t flex justify-end space-x-2;
}
</style>
```

### 4. Form Adaptations

#### Responsive Form Layouts
```vue
<!-- components/ResponsiveForm.vue -->
<template>
  <form @submit.prevent="handleSubmit" class="responsive-form">
    <!-- Mobile: Stacked layout -->
    <div v-if="isMobile" class="mobile-form">
      <div class="form-section">
        <h3 class="section-title">Basic Information</h3>
        <div class="space-y-4">
          <FormControl
            v-model="form.name"
            label="Full Name"
            required
            :error-message="errors.name"
          />
          <FormControl
            v-model="form.email"
            label="Email"
            type="email"
            required
            :error-message="errors.email"
          />
          <FormControl
            v-model="form.phone"
            label="Phone"
            :error-message="errors.phone"
          />
        </div>
      </div>
      
      <div class="form-section">
        <h3 class="section-title">Address</h3>
        <div class="space-y-4">
          <FormControl
            v-model="form.address"
            label="Street Address"
            :error-message="errors.address"
          />
          <div class="grid grid-cols-2 gap-3">
            <FormControl
              v-model="form.city"
              label="City"
              :error-message="errors.city"
            />
            <FormControl
              v-model="form.state"
              label="State"
              :error-message="errors.state"
            />
          </div>
          <FormControl
            v-model="form.zipCode"
            label="ZIP Code"
            :error-message="errors.zipCode"
          />
        </div>
      </div>
    </div>
    
    <!-- Desktop: Two-column layout -->
    <div v-else class="desktop-form">
      <div class="form-columns">
        <div class="form-column">
          <h3 class="section-title">Basic Information</h3>
          <div class="space-y-6">
            <FormControl
              v-model="form.name"
              label="Full Name"
              required
              :error-message="errors.name"
            />
            <FormControl
              v-model="form.email"
              label="Email"
              type="email"
              required
              :error-message="errors.email"
            />
            <FormControl
              v-model="form.phone"
              label="Phone"
              :error-message="errors.phone"
            />
          </div>
        </div>
        
        <div class="form-column">
          <h3 class="section-title">Address Information</h3>
          <div class="space-y-6">
            <FormControl
              v-model="form.address"
              label="Street Address"
              :error-message="errors.address"
            />
            <div class="grid grid-cols-2 gap-4">
              <FormControl
                v-model="form.city"
                label="City"
                :error-message="errors.city"
              />
              <FormControl
                v-model="form.state"
                label="State"
                :error-message="errors.state"
              />
            </div>
            <FormControl
              v-model="form.zipCode"
              label="ZIP Code"
              :error-message="errors.zipCode"
            />
          </div>
        </div>
      </div>
    </div>
    
    <!-- Form actions -->
    <div class="form-actions">
      <Button
        type="button"
        variant="ghost"
        @click="$emit('cancel')"
        :class="isMobile ? 'flex-1' : ''"
      >
        Cancel
      </Button>
      <Button
        type="submit"
        :loading="saving"
        :class="isMobile ? 'flex-1' : ''"
      >
        Save
      </Button>
    </div>
  </form>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { FormControl, Button } from 'frappe-ui'
import { useResponsive } from '@/composables/useResponsive'

const props = defineProps({
  initialData: { type: Object, default: () => ({}) }
})

const emit = defineEmits(['submit', 'cancel'])

const { isMobile } = useResponsive()

const form = reactive({
  name: '',
  email: '',
  phone: '',
  address: '',
  city: '',
  state: '',
  zipCode: '',
  ...props.initialData
})

const errors = ref({})
const saving = ref(false)

const handleSubmit = async () => {
  errors.value = {}
  
  // Validation
  if (!form.name) errors.value.name = 'Name is required'
  if (!form.email) errors.value.email = 'Email is required'
  
  if (Object.keys(errors.value).length > 0) return
  
  saving.value = true
  try {
    await emit('submit', form)
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.responsive-form {
  @apply max-w-4xl mx-auto;
}

.mobile-form {
  @apply space-y-6;
}

.desktop-form {
  @apply space-y-8;
}

.form-columns {
  @apply grid grid-cols-2 gap-12;
}

.form-column {
  @apply space-y-6;
}

.form-section {
  @apply space-y-4;
}

.section-title {
  @apply text-lg font-semibold text-gray-900 mb-4;
}

.form-actions {
  @apply flex justify-end space-x-3 pt-8 border-t;
}

@media (max-width: 767px) {
  .form-actions {
    @apply flex-col space-x-0 space-y-3;
  }
}
</style>
```

### 5. Touch-Friendly Interactions

#### Mobile Gesture Support
```vue
<!-- components/TouchFriendlyList.vue -->
<template>
  <div class="touch-list">
    <div
      v-for="item in items"
      :key="item.id"
      class="list-item"
      @touchstart="handleTouchStart"
      @touchmove="handleTouchMove"
      @touchend="handleTouchEnd"
      @click="handleItemClick(item)"
    >
      <!-- Swipe action buttons -->
      <div class="swipe-actions left-actions">
        <button class="action-btn edit-btn" @click="editItem(item)">
          <FeatherIcon name="edit" class="w-5 h-5" />
        </button>
      </div>
      
      <div class="swipe-actions right-actions">
        <button class="action-btn delete-btn" @click="deleteItem(item)">
          <FeatherIcon name="trash-2" class="w-5 h-5" />
        </button>
      </div>
      
      <!-- Main content -->
      <div class="item-content">
        <div class="flex items-center space-x-3">
          <Avatar :label="item.name" size="md" />
          <div class="flex-1 min-w-0">
            <h3 class="font-medium truncate">{{ item.name }}</h3>
            <p class="text-sm text-gray-500 truncate">{{ item.description }}</p>
          </div>
          <div class="text-right">
            <Badge :theme="getStatusTheme(item.status)">
              {{ item.status }}
            </Badge>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Avatar, Badge, FeatherIcon } from 'frappe-ui'

const props = defineProps({
  items: { type: Array, required: true }
})

const emit = defineEmits(['edit', 'delete', 'item-click'])

// Touch handling
let startX = 0
let currentX = 0
let activeElement = null

const handleTouchStart = (e) => {
  if (!window.TouchEvent || !(e instanceof TouchEvent)) return
  
  startX = e.touches[0].clientX
  activeElement = e.currentTarget
}

const handleTouchMove = (e) => {
  if (!activeElement) return
  
  currentX = e.touches[0].clientX
  const diffX = currentX - startX
  
  // Only allow horizontal swiping
  const diffY = Math.abs(e.touches[0].clientY - e.touches[0].clientY)
  if (diffY > 50) return
  
  // Apply transform
  const clampedDiff = Math.max(-120, Math.min(120, diffX))
  activeElement.style.transform = `translateX(${clampedDiff}px)`
  
  // Show appropriate actions
  if (clampedDiff > 0) {
    activeElement.classList.add('swiping-right')
    activeElement.classList.remove('swiping-left')
  } else if (clampedDiff < 0) {
    activeElement.classList.add('swiping-left')
    activeElement.classList.remove('swiping-right')
  }
  
  e.preventDefault()
}

const handleTouchEnd = (e) => {
  if (!activeElement) return
  
  const diffX = currentX - startX
  
  // Snap to position
  if (Math.abs(diffX) > 60) {
    if (diffX > 0) {
      activeElement.style.transform = 'translateX(80px)'
      activeElement.classList.add('actions-revealed')
    } else {
      activeElement.style.transform = 'translateX(-80px)'
      activeElement.classList.add('actions-revealed')
    }
  } else {
    activeElement.style.transform = 'translateX(0)'
    activeElement.classList.remove('actions-revealed', 'swiping-left', 'swiping-right')
  }
  
  activeElement = null
}

const handleItemClick = (item) => {
  // Don't trigger click if actions are revealed
  if (event.currentTarget.classList.contains('actions-revealed')) {
    event.currentTarget.style.transform = 'translateX(0)'
    event.currentTarget.classList.remove('actions-revealed', 'swiping-left', 'swiping-right')
    return
  }
  
  emit('item-click', item)
}

const editItem = (item) => {
  emit('edit', item)
}

const deleteItem = (item) => {
  emit('delete', item)
}

const getStatusTheme = (status) => {
  const themes = {
    'Active': 'green',
    'Inactive': 'red',
    'Pending': 'yellow'
  }
  return themes[status] || 'gray'
}
</script>

<style scoped>
.touch-list {
  @apply space-y-2;
}

.list-item {
  @apply relative bg-white rounded-lg shadow-sm border overflow-hidden;
  @apply transform transition-transform duration-200 ease-out;
  min-height: 64px;
  cursor: pointer;
}

.item-content {
  @apply p-4 relative z-10 bg-white;
  min-height: 64px;
  display: flex;
  align-items: center;
}

.swipe-actions {
  @apply absolute top-0 bottom-0 flex items-center;
  @apply opacity-0 transition-opacity duration-200;
}

.left-actions {
  @apply left-0 bg-blue-500 justify-center;
  width: 80px;
}

.right-actions {
  @apply right-0 bg-red-500 justify-center;
  width: 80px;
}

.action-btn {
  @apply w-12 h-12 rounded-full flex items-center justify-center;
  @apply bg-white bg-opacity-20 text-white;
  @apply active:bg-opacity-30 transition-colors;
}

.list-item.swiping-right .left-actions,
.list-item.swiping-left .right-actions {
  @apply opacity-100;
}

.list-item.actions-revealed .swipe-actions {
  @apply opacity-100;
}

/* Increase touch target sizes */
.action-btn,
.item-content {
  min-height: 44px; /* iOS minimum touch target */
}
</style>
```

### 6. Responsive Utilities

#### useResponsive Composable
```javascript
// composables/useResponsive.js
import { ref, computed, onMounted, onUnmounted } from 'vue'

export function useResponsive() {
  const windowWidth = ref(0)
  
  // Breakpoints (matching Tailwind CSS)
  const breakpoints = {
    sm: 640,
    md: 768,
    lg: 1024,
    xl: 1280,
    '2xl': 1536
  }
  
  // Computed responsive states
  const isMobile = computed(() => windowWidth.value < breakpoints.md)
  const isTablet = computed(() => 
    windowWidth.value >= breakpoints.md && windowWidth.value < breakpoints.lg
  )
  const isDesktop = computed(() => windowWidth.value >= breakpoints.lg)
  
  const screenSize = computed(() => {
    if (windowWidth.value < breakpoints.sm) return 'xs'
    if (windowWidth.value < breakpoints.md) return 'sm'
    if (windowWidth.value < breakpoints.lg) return 'md'
    if (windowWidth.value < breakpoints.xl) return 'lg'
    if (windowWidth.value < breakpoints['2xl']) return 'xl'
    return '2xl'
  })
  
  // Responsive grid columns
  const gridCols = computed(() => {
    if (isMobile.value) return 1
    if (isTablet.value) return 2
    return 3
  })
  
  // Responsive page size for data lists
  const pageSize = computed(() => {
    if (isMobile.value) return 10
    if (isTablet.value) return 20
    return 50
  })
  
  const updateWindowWidth = () => {
    windowWidth.value = window.innerWidth
  }
  
  onMounted(() => {
    updateWindowWidth()
    window.addEventListener('resize', updateWindowWidth)
  })
  
  onUnmounted(() => {
    window.removeEventListener('resize', updateWindowWidth)
  })
  
  // Utility functions
  const isScreenSize = (size) => screenSize.value === size
  const isScreenSizeOrLarger = (size) => {
    const sizeOrder = ['xs', 'sm', 'md', 'lg', 'xl', '2xl']
    const currentIndex = sizeOrder.indexOf(screenSize.value)
    const targetIndex = sizeOrder.indexOf(size)
    return currentIndex >= targetIndex
  }
  
  const getResponsiveValue = (values) => {
    const keys = Object.keys(values).sort((a, b) => {
      const aBreakpoint = breakpoints[a] || 0
      const bBreakpoint = breakpoints[b] || 0
      return aBreakpoint - bBreakpoint
    })
    
    let selectedValue = values[keys[0]]
    
    for (const key of keys) {
      const breakpoint = breakpoints[key] || 0
      if (windowWidth.value >= breakpoint) {
        selectedValue = values[key]
      }
    }
    
    return selectedValue
  }
  
  return {
    windowWidth,
    isMobile,
    isTablet,
    isDesktop,
    screenSize,
    gridCols,
    pageSize,
    isScreenSize,
    isScreenSizeOrLarger,
    getResponsiveValue
  }
}
```

### 7. PWA Features for Mobile

#### Service Worker Integration
```javascript
// sw.js - Service Worker for offline functionality
const CACHE_NAME = 'erpnext-app-v1'
const urlsToCache = [
  '/',
  '/offline.html',
  '/assets/app.css',
  '/assets/app.js',
  '/assets/icons/icon-192x192.png',
  '/assets/icons/icon-512x512.png'
]

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(urlsToCache))
  )
})

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Return cached version or fetch from network
        if (response) {
          return response
        }
        
        // Clone the request for fetch
        const fetchRequest = event.request.clone()
        
        return fetch(fetchRequest).then((response) => {
          // Check if valid response
          if (!response || response.status !== 200 || response.type !== 'basic') {
            return response
          }
          
          // Clone the response for caching
          const responseToCache = response.clone()
          
          caches.open(CACHE_NAME)
            .then((cache) => {
              cache.put(event.request, responseToCache)
            })
          
          return response
        }).catch(() => {
          // Return offline page for navigation requests
          if (event.request.destination === 'document') {
            return caches.match('/offline.html')
          }
        })
      })
  )
})
```

#### PWA Manifest Configuration
```json
{
  "name": "ERPNext Mobile",
  "short_name": "ERPNext",
  "description": "Mobile interface for ERPNext ERP system",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#2563eb",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "/assets/icons/icon-72x72.png",
      "sizes": "72x72",
      "type": "image/png"
    },
    {
      "src": "/assets/icons/icon-96x96.png",
      "sizes": "96x96",
      "type": "image/png"
    },
    {
      "src": "/assets/icons/icon-128x128.png",
      "sizes": "128x128",
      "type": "image/png"
    },
    {
      "src": "/assets/icons/icon-144x144.png",
      "sizes": "144x144",
      "type": "image/png"
    },
    {
      "src": "/assets/icons/icon-152x152.png",
      "sizes": "152x152",
      "type": "image/png"
    },
    {
      "src": "/assets/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/assets/icons/icon-384x384.png",
      "sizes": "384x384",
      "type": "image/png"
    },
    {
      "src": "/assets/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ],
  "screenshots": [
    {
      "src": "/assets/screenshots/mobile-1.png",
      "sizes": "390x844",
      "type": "image/png",
      "form_factor": "narrow"
    },
    {
      "src": "/assets/screenshots/desktop-1.png",
      "sizes": "1920x1080",
      "type": "image/png",
      "form_factor": "wide"
    }
  ]
}
```

This comprehensive guide covers all essential patterns for building responsive, cross-platform ERPNext applications that work seamlessly on both desktop and mobile devices.