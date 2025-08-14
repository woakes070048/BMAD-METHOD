# Vue Frontend Architecture for ERPNext Applications
## Complete Reference for Building Modern Vue.js Apps with Frappe Framework

**Last Updated**: 2025-08-11  
**Framework Version**: Vue 3.4+ | Frappe UI 0.1.x | ERPNext 15  
**Source**: Production patterns from CRM (desktop-first) and HRMS (mobile-first with Ionic)  
**Starter Template**: pegas-frappe-vue-starter (https://github.com/woakes070048/pegas-frappe-vue-starter)

---

## 🏗️ Core Architecture Patterns

### 1. Vue 3 Application Setup

#### Standard Desktop-First Setup (CRM Pattern)
```javascript
// main.js - Desktop application pattern
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import { initSocket } from './socket'

import {
  Button,
  Input,
  FormControl,
  setConfig,
  frappeRequest,
  resourcesPlugin,
} from 'frappe-ui'

const app = createApp(App)
const pinia = createPinia()

// Configure Frappe UI resource fetcher
setConfig('resourceFetcher', frappeRequest)

// Register plugins
app.use(pinia)
app.use(resourcesPlugin)
app.use(router)

// Global component registration
app.component('Button', Button)
app.component('Input', Input)
app.component('FormControl', FormControl)

// Global provides
app.provide('$socket', initSocket())

// Mount application
router.isReady().then(() => {
  app.mount('#app')
})
```

#### Mobile-First Setup with Ionic (HRMS Pattern)
```javascript
// main.js - Mobile PWA pattern
import { createApp } from 'vue'
import { IonicVue } from '@ionic/vue'
import App from './App.vue'
import router from './router'

import {
  Button,
  Input,
  FormControl,
  setConfig,
  frappeRequest,
  resourcesPlugin,
} from 'frappe-ui'

import { translationsPlugin } from './plugins/translationsPlugin.js'
import { session } from '@/data/session'
import { userResource } from '@/data/user'
import { employeeResource } from '@/data/employee'

import dayjs from '@/utils/dayjs'
import getIonicConfig from '@/utils/ionicConfig'

// Ionic CSS imports
import '@ionic/vue/css/core.css'
import './theme/variables.css'
import './main.css'

const app = createApp(App)

// Configure Frappe
setConfig('resourceFetcher', frappeRequest)

// Register plugins
app.use(resourcesPlugin)
app.use(translationsPlugin)
app.use(router)
app.use(IonicVue, getIonicConfig())

// Global components
app.component('Button', Button)
app.component('Input', Input)
app.component('FormControl', FormControl)

// Dependency injection
app.provide('$session', session)
app.provide('$user', userResource)
app.provide('$employee', employeeResource)
app.provide('$dayjs', dayjs)

// PWA service worker registration
const registerServiceWorker = async () => {
  if ('serviceWorker' in navigator) {
    try {
      await navigator.serviceWorker.register('/assets/hrms/frontend/sw.js')
      console.log('Service worker registered')
    } catch (error) {
      console.error('Service worker registration failed:', error)
    }
  }
}

// Application initialization
router.isReady().then(async () => {
  // Development context setup
  if (import.meta.env.DEV) {
    await frappeRequest({
      url: '/api/method/hrms.www.hrms.get_context_for_dev',
    }).then(values => {
      if (!window.frappe) window.frappe = {}
      window.frappe.boot = values
    })
  }
  
  await translationsPlugin.isReady()
  registerServiceWorker()
  app.mount('#app')
})
```

### 2. Router Configuration Patterns

#### Desktop Router Setup
```javascript
// router/index.js - Desktop navigation pattern
import { createRouter, createWebHistory } from 'vue-router'
import { sessionStore } from '@/stores/session'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('@/pages/Home.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/pages/Login.vue'),
    meta: { hideNavbar: true }
  },
  {
    path: '/leads',
    name: 'Leads',
    component: () => import('@/pages/Leads.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/deals',
    name: 'Deals',
    component: () => import('@/pages/Deals.vue'),
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Navigation guards
router.beforeEach(async (to, from, next) => {
  const session = sessionStore()
  
  if (to.meta.requiresAuth && !session.isLoggedIn) {
    next({ name: 'Login', query: { redirect: to.fullPath } })
  } else if (to.name === 'Login' && session.isLoggedIn) {
    next({ name: 'Home' })
  } else {
    next()
  }
})

export default router
```

#### Mobile Router with Employee Validation (HRMS Pattern)
```javascript
// router/index.js - Mobile with employee-specific routing
import { createRouter, createWebHistory } from 'vue-router'
import { session } from '@/data/session'
import { userResource } from '@/data/user'
import { employeeResource } from '@/data/employee'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('@/pages/Home.vue')
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/pages/Login.vue')
  },
  {
    path: '/invalid-employee',
    name: 'InvalidEmployee',
    component: () => import('@/pages/InvalidEmployee.vue')
  },
  {
    path: '/update-password',
    name: 'UpdatePassword',
    component: () => import('@/pages/UpdatePassword.vue'),
    meta: { outsidePWAScope: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to, from, next) => {
  let isLoggedIn = session.isLoggedIn

  try {
    if (isLoggedIn) await userResource.reload()
  } catch (error) {
    isLoggedIn = false
  }

  if (!isLoggedIn) {
    // Handle password reset outside PWA
    if (to.path === '/update-password') {
      return next(false)
    } else if (to.name !== 'Login') {
      next({ name: 'Login' })
      return
    }
  }

  // Employee validation for authenticated users
  if (isLoggedIn && to.name !== 'InvalidEmployee') {
    await employeeResource.promise
    
    // User must be an employee to access the app
    if (!employeeResource?.data || 
        employeeResource?.data?.user_id !== userResource.data.name) {
      next({ name: 'InvalidEmployee' })
    } else if (to.name === 'Login') {
      next({ name: 'Home' })
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router
```

### 3. State Management with Pinia

#### Session Store Pattern
```javascript
// stores/session.js - Authentication state management
import { defineStore } from 'pinia'
import { createResource } from 'frappe-ui'
import { userResource } from './user'
import router from '@/router'
import { ref, computed } from 'vue'

export const sessionStore = defineStore('session', () => {
  // Session user detection
  function sessionUser() {
    let cookies = new URLSearchParams(document.cookie.split('; ').join('&'))
    let _sessionUser = cookies.get('user_id')
    if (_sessionUser === 'Guest') {
      _sessionUser = null
    }
    return _sessionUser
  }

  // Reactive state
  let user = ref(sessionUser())
  const isLoggedIn = computed(() => !!user.value)

  // Login resource
  const login = createResource({
    url: 'login',
    onError() {
      throw new Error('Invalid email or password')
    },
    onSuccess() {
      userResource.reload()
      user.value = sessionUser()
      login.reset()
      router.replace({ path: '/' })
    },
  })

  // Logout resource
  const logout = createResource({
    url: 'logout',
    onSuccess() {
      userResource.reset()
      user.value = null
      window.location.href = '/login'
    },
  })

  return {
    user,
    isLoggedIn,
    login,
    logout,
  }
})
```

#### Data Store Pattern with Resource Management
```javascript
// stores/contacts.js - Entity-specific store
import { defineStore } from 'pinia'
import { createResource } from 'frappe-ui'
import { ref, computed } from 'vue'

export const contactsStore = defineStore('contacts', () => {
  // State
  const filters = ref({
    status: '',
    assigned_to: '',
    search: ''
  })
  
  const selectedContacts = ref([])

  // Resources
  const contacts = createResource({
    url: 'frappe.client.get_list',
    params: {
      doctype: 'Contact',
      fields: ['name', 'full_name', 'email', 'phone', 'status', 'modified'],
      order_by: 'modified desc'
    },
    auto: true
  })

  const createContact = createResource({
    url: 'frappe.client.insert',
    onSuccess(contact) {
      contacts.setData(data => [contact, ...data])
      showToast('Contact created successfully')
    }
  })

  const updateContact = createResource({
    url: 'frappe.client.set_value',
    onSuccess() {
      contacts.reload()
      showToast('Contact updated successfully')
    }
  })

  const deleteContact = createResource({
    url: 'frappe.client.delete',
    onSuccess() {
      contacts.reload()
      showToast('Contact deleted successfully')
    }
  })

  // Computed
  const filteredContacts = computed(() => {
    if (!contacts.data) return []
    
    return contacts.data.filter(contact => {
      const matchesStatus = !filters.value.status || 
                           contact.status === filters.value.status
      const matchesSearch = !filters.value.search || 
                           contact.full_name.toLowerCase().includes(
                             filters.value.search.toLowerCase()
                           )
      const matchesAssignee = !filters.value.assigned_to || 
                             contact.assigned_to === filters.value.assigned_to
      
      return matchesStatus && matchesSearch && matchesAssignee
    })
  })

  // Actions
  const applyFilter = (key, value) => {
    filters.value[key] = value
    updateContactsResource()
  }

  const clearFilters = () => {
    filters.value = { status: '', assigned_to: '', search: '' }
    updateContactsResource()
  }

  const updateContactsResource = () => {
    const activeFilters = {}
    if (filters.value.status) activeFilters.status = filters.value.status
    if (filters.value.assigned_to) activeFilters.assigned_to = filters.value.assigned_to
    if (filters.value.search) {
      activeFilters.full_name = ['like', `%${filters.value.search}%`]
    }

    contacts.update({
      params: {
        ...contacts.params,
        filters: activeFilters
      }
    })
    contacts.reload()
  }

  const selectContact = (contact) => {
    if (selectedContacts.value.includes(contact.name)) {
      selectedContacts.value = selectedContacts.value.filter(
        name => name !== contact.name
      )
    } else {
      selectedContacts.value.push(contact.name)
    }
  }

  const selectAllContacts = () => {
    selectedContacts.value = filteredContacts.value.map(c => c.name)
  }

  const clearSelection = () => {
    selectedContacts.value = []
  }

  return {
    // State
    filters,
    selectedContacts,
    
    // Resources
    contacts,
    createContact,
    updateContact,
    deleteContact,
    
    // Computed
    filteredContacts,
    
    // Actions
    applyFilter,
    clearFilters,
    selectContact,
    selectAllContacts,
    clearSelection
  }
})
```

### 4. Component Architecture Patterns

#### Layout Components
```vue
<!-- layouts/AppLayout.vue - Main desktop layout -->
<template>
  <div class="flex h-screen bg-gray-50">
    <!-- Sidebar -->
    <aside class="w-64 bg-white shadow-sm border-r">
      <div class="p-6">
        <img src="/logo.png" alt="Logo" class="h-8" />
      </div>
      <nav class="px-4">
        <router-link 
          v-for="item in navigation"
          :key="item.name"
          :to="item.to"
          class="flex items-center px-3 py-2 text-sm font-medium rounded-md"
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
    </aside>

    <!-- Main content -->
    <div class="flex-1 flex flex-col overflow-hidden">
      <!-- Header -->
      <header class="bg-white shadow-sm border-b px-6 py-4">
        <div class="flex items-center justify-between">
          <div>
            <h1 class="text-2xl font-semibold text-gray-900">
              {{ pageTitle }}
            </h1>
          </div>
          <div class="flex items-center space-x-4">
            <Button icon="bell" variant="ghost" />
            <UserMenu />
          </div>
        </div>
      </header>

      <!-- Page content -->
      <main class="flex-1 overflow-auto p-6">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { Button, FeatherIcon } from 'frappe-ui'
import UserMenu from '@/components/UserMenu.vue'

const navigation = [
  { name: 'Home', to: '/', icon: 'home', label: 'Dashboard' },
  { name: 'Leads', to: '/leads', icon: 'users', label: 'Leads' },
  { name: 'Deals', to: '/deals', icon: 'dollar-sign', label: 'Deals' },
  { name: 'Contacts', to: '/contacts', icon: 'user', label: 'Contacts' }
]

const pageTitle = computed(() => {
  const route = $route
  const navItem = navigation.find(item => item.name === route.name)
  return navItem?.label || 'Dashboard'
})
</script>
```

#### Mobile Layout with Ionic
```vue
<!-- layouts/MobileLayout.vue - Ionic mobile layout -->
<template>
  <ion-page>
    <!-- Header -->
    <ion-header>
      <ion-toolbar>
        <ion-title>{{ pageTitle }}</ion-title>
        <ion-buttons slot="start" v-if="showBackButton">
          <ion-back-button default-href="/"></ion-back-button>
        </ion-buttons>
        <ion-buttons slot="end">
          <ion-button @click="openNotifications">
            <ion-icon :icon="notificationsOutline"></ion-icon>
            <ion-badge v-if="notificationCount" color="danger">
              {{ notificationCount }}
            </ion-badge>
          </ion-button>
        </ion-buttons>
      </ion-toolbar>
    </ion-header>

    <!-- Content -->
    <ion-content>
      <router-view />
    </ion-content>

    <!-- Tab bar -->
    <ion-tab-bar slot="bottom" v-if="showTabs">
      <ion-tab-button 
        v-for="tab in tabs"
        :key="tab.name"
        :tab="tab.name"
        :href="tab.to"
      >
        <ion-icon :icon="tab.icon"></ion-icon>
        <ion-label>{{ tab.label }}</ion-label>
      </ion-tab-button>
    </ion-tab-bar>
  </ion-page>
</template>

<script setup>
import { computed, inject } from 'vue'
import {
  IonPage,
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonButtons,
  IonButton,
  IonIcon,
  IonBadge,
  IonTabBar,
  IonTabButton,
  IonLabel,
  IonBackButton
} from '@ionic/vue'
import {
  home,
  person,
  calendar,
  settings,
  notificationsOutline
} from 'ionicons/icons'

const $route = inject('$route')
const notificationCount = inject('$notificationCount', 0)

const tabs = [
  { name: 'home', to: '/', icon: home, label: 'Home' },
  { name: 'profile', to: '/profile', icon: person, label: 'Profile' },
  { name: 'calendar', to: '/calendar', icon: calendar, label: 'Calendar' },
  { name: 'settings', to: '/settings', icon: settings, label: 'Settings' }
]

const pageTitle = computed(() => {
  return $route.meta?.title || 'HRMS'
})

const showBackButton = computed(() => {
  return $route.meta?.showBackButton !== false && $route.name !== 'Home'
})

const showTabs = computed(() => {
  return $route.meta?.hideTabs !== true
})

const openNotifications = () => {
  // Handle notifications
}
</script>
```

### 5. Build Configuration

#### Vite Config for Desktop Apps
```javascript
// vite.config.js - Desktop build configuration
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
    },
  },
  
  server: {
    port: 8080,
    proxy: {
      // Proxy API calls to Frappe backend
      '^/(api|assets|files)/.*': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        ws: true, // WebSocket support
      },
    },
  },
  
  build: {
    outDir: '../assets',
    emptyOutDir: true,
    rollupOptions: {
      output: {
        // Split vendor chunks
        manualChunks: {
          vendor: ['vue', 'vue-router', 'pinia'],
          frappe: ['frappe-ui'],
        },
      },
    },
  },
  
  optimizeDeps: {
    include: ['frappe-ui', 'vue', 'vue-router', 'pinia'],
  },
})
```

#### Mobile PWA Build Config
```javascript
// vite.config.js - Mobile PWA configuration
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    vue(),
    VitePWA({
      registerType: 'autoUpdate',
      devOptions: {
        enabled: true
      },
      workbox: {
        navigateFallback: '/hrms',
        globPatterns: ['**/*.{js,css,html,ico,png,svg}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/api\/.*/i,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'api-cache',
              expiration: {
                maxEntries: 100,
                maxAgeSeconds: 60 * 60 * 24 // 24 hours
              }
            }
          }
        ]
      },
      manifest: {
        name: 'HRMS Mobile',
        short_name: 'HRMS',
        description: 'Human Resource Management System',
        theme_color: '#2563eb',
        background_color: '#ffffff',
        display: 'standalone',
        orientation: 'portrait',
        icons: [
          {
            src: 'icon-192x192.png',
            sizes: '192x192',
            type: 'image/png'
          },
          {
            src: 'icon-512x512.png',
            sizes: '512x512',
            type: 'image/png'
          }
        ]
      }
    })
  ],
  
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
    },
  },
  
  server: {
    port: 8080,
    proxy: {
      '^/(api|assets|files)/.*': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
    },
  }
})
```

### 6. Socket.io Integration

#### Real-time Communication Setup
```javascript
// socket.js - WebSocket connection management
import { io } from 'socket.io-client'
import { sessionStore } from '@/stores/session'

let socket = null

export function initSocket() {
  if (socket) return socket

  const session = sessionStore()
  
  socket = io('/', {
    withCredentials: true,
    transports: ['websocket', 'polling'],
    autoConnect: session.isLoggedIn
  })

  // Connection events
  socket.on('connect', () => {
    console.log('Socket connected:', socket.id)
  })

  socket.on('disconnect', (reason) => {
    console.log('Socket disconnected:', reason)
  })

  // Real-time data updates
  socket.on('doc_update', (data) => {
    handleDocUpdate(data)
  })

  socket.on('new_notification', (notification) => {
    handleNewNotification(notification)
  })

  return socket
}

function handleDocUpdate(data) {
  // Update local state when documents change
  const { doctype, name, action } = data
  
  // Emit to stores or components that care about this doctype
  window.dispatchEvent(new CustomEvent('doc-update', {
    detail: { doctype, name, action, data }
  }))
}

function handleNewNotification(notification) {
  // Show toast notification
  import('frappe-ui').then(({ createToast }) => {
    createToast({
      title: notification.title,
      text: notification.message,
      icon: 'bell',
      timeout: 5000
    })
  })
}

export { socket }
```

### 7. Advanced Patterns

#### Composables for Reusable Logic
```javascript
// composables/useDocumentActions.js - Reusable document operations
import { ref } from 'vue'
import { createResource, createToast } from 'frappe-ui'
import { useRouter } from 'vue-router'

export function useDocumentActions(doctype, options = {}) {
  const router = useRouter()
  
  // State
  const loading = ref(false)
  const errors = ref({})

  // Create resource
  const createDoc = createResource({
    url: 'frappe.client.insert',
    onSuccess(doc) {
      createToast({
        title: 'Success',
        text: `${doctype} created successfully`,
        icon: 'check',
        iconClasses: 'text-green-600'
      })
      
      if (options.onCreateSuccess) {
        options.onCreateSuccess(doc)
      } else {
        router.push(`/${doctype.toLowerCase()}s/${doc.name}`)
      }
    },
    onError(error) {
      errors.value = error.exc_type === 'ValidationError' 
        ? error.exc 
        : { _server: error.message }
    }
  })

  // Update resource
  const updateDoc = createResource({
    url: 'frappe.client.set_value',
    onSuccess() {
      createToast({
        title: 'Saved',
        text: `${doctype} updated successfully`,
        icon: 'check',
        iconClasses: 'text-green-600'
      })
      
      if (options.onUpdateSuccess) {
        options.onUpdateSuccess()
      }
    },
    onError(error) {
      errors.value = error.exc_type === 'ValidationError' 
        ? error.exc 
        : { _server: error.message }
    }
  })

  // Delete resource
  const deleteDoc = createResource({
    url: 'frappe.client.delete',
    onSuccess() {
      createToast({
        title: 'Deleted',
        text: `${doctype} deleted successfully`,
        icon: 'check',
        iconClasses: 'text-green-600'
      })
      
      if (options.onDeleteSuccess) {
        options.onDeleteSuccess()
      } else {
        router.push(`/${doctype.toLowerCase()}s`)
      }
    },
    onError(error) {
      createToast({
        title: 'Error',
        text: error.message || 'Failed to delete',
        icon: 'x',
        iconClasses: 'text-red-600'
      })
    }
  })

  // Actions
  const create = async (data) => {
    errors.value = {}
    loading.value = true
    
    try {
      await createDoc.submit({
        doc: { doctype, ...data }
      })
    } finally {
      loading.value = false
    }
  }

  const update = async (name, data) => {
    errors.value = {}
    loading.value = true
    
    try {
      await updateDoc.submit({
        doctype,
        name,
        fieldname: data
      })
    } finally {
      loading.value = false
    }
  }

  const remove = async (name) => {
    const confirmed = confirm(`Are you sure you want to delete this ${doctype}?`)
    if (!confirmed) return

    loading.value = true
    
    try {
      await deleteDoc.submit({
        doctype,
        name
      })
    } finally {
      loading.value = false
    }
  }

  return {
    // State
    loading,
    errors,
    
    // Resources
    createDoc,
    updateDoc,
    deleteDoc,
    
    // Actions
    create,
    update,
    remove
  }
}
```

#### Translation Plugin
```javascript
// plugins/translationsPlugin.js - Internationalization support
import { createResource } from 'frappe-ui'

let translations = {}
let currentLanguage = 'en'

const translationsResource = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'Translation',
    fields: ['source_text', 'translated_text', 'language'],
    filters: { language: currentLanguage },
    limit_page_length: 0
  },
  onSuccess(data) {
    translations = {}
    data.forEach(translation => {
      translations[translation.source_text] = translation.translated_text
    })
  }
})

export const translationsPlugin = {
  install(app) {
    // Global translation function
    app.config.globalProperties.$t = (text, ...args) => {
      let translated = translations[text] || text
      
      // Handle template interpolation
      if (args.length > 0) {
        args.forEach((arg, index) => {
          translated = translated.replace(`{${index}}`, arg)
        })
      }
      
      return translated
    }

    // Provide translation function
    app.provide('$t', app.config.globalProperties.$t)
  },

  async isReady() {
    if (!translationsResource.loading && !translationsResource.fetched) {
      await translationsResource.fetch()
    }
    return translationsResource.promise
  },

  setLanguage(lang) {
    currentLanguage = lang
    translationsResource.update({
      params: {
        ...translationsResource.params,
        filters: { language: lang }
      }
    })
    return translationsResource.reload()
  }
}
```

---

## 🚀 Production Best Practices

### Performance Optimization
- Use `shallowRef` for large data structures
- Implement virtual scrolling for long lists
- Lazy load routes and components
- Optimize bundle size with code splitting
- Use service workers for caching

### Error Handling
- Implement global error handlers
- Use try-catch blocks in async operations
- Provide fallback UI for failed resource loads
- Log errors to monitoring services

### Security
- Validate data on client and server
- Sanitize user inputs
- Use HTTPS in production
- Implement proper CORS policies

This architecture reference provides everything needed to build modern, scalable Vue.js applications integrated with ERPNext and the Frappe framework.