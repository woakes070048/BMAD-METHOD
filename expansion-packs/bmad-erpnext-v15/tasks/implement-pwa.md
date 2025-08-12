# Task: Implement PWA Features for ERPNext Vue SPA

## Objective
Transform your ERPNext Vue SPA into a Progressive Web Application (PWA) with offline capabilities, push notifications, and app-like experience.

## Prerequisites
- Vue 3 SPA already set up
- Vite build configuration
- Service worker support in target browsers
- HTTPS enabled (required for PWA features)

## Step-by-Step Implementation

### 1. Install PWA Dependencies

```bash
cd frontend
npm install -D vite-plugin-pwa workbox-window
npm install localforage idb
```

### 2. Configure Vite PWA Plugin

```javascript
// vite.config.js
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    vue(),
    VitePWA({
      registerType: 'prompt',
      includeAssets: ['favicon.ico', 'apple-touch-icon.png', 'safari-pinned-tab.svg'],
      manifest: {
        name: 'ERPNext Modern App',
        short_name: 'ModernApp',
        description: 'Modern ERPNext application with offline capabilities',
        theme_color: '#171717',
        background_color: '#ffffff',
        display: 'standalone',
        orientation: 'portrait',
        scope: '/',
        start_url: '/app/dashboard',
        categories: ['business', 'productivity'],
        lang: 'en-US',
        icons: [
          {
            src: 'pwa-192x192.png',
            sizes: '192x192',
            type: 'image/png',
            purpose: 'maskable'
          },
          {
            src: 'pwa-512x512.png',
            sizes: '512x512',
            type: 'image/png',
            purpose: 'maskable'
          },
          {
            src: 'pwa-192x192.png',
            sizes: '192x192',
            type: 'image/png'
          },
          {
            src: 'pwa-512x512.png',
            sizes: '512x512',
            type: 'image/png'
          }
        ],
        screenshots: [
          {
            src: 'screenshot-wide.png',
            sizes: '1280x720',
            type: 'image/png',
            form_factor: 'wide'
          },
          {
            src: 'screenshot-mobile.png', 
            sizes: '640x1136',
            type: 'image/png'
          }
        ]
      },
      workbox: {
        cleanupOutdatedCaches: true,
        clientsClaim: true,
        skipWaiting: true,
        runtimeCaching: [
          // API caching
          {
            urlPattern: /^.*\/api\/method\/.*/,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'api-cache',
              expiration: {
                maxEntries: 100,
                maxAgeSeconds: 60 * 60 * 24 // 24 hours
              },
              networkTimeoutSeconds: 10,
              cacheKeyWillBeUsed: async ({ request }) => {
                return request.url + '|' + request.headers.get('accept')
              }
            }
          },
          // Static assets
          {
            urlPattern: /\.(?:png|jpg|jpeg|svg|gif|webp)$/,
            handler: 'CacheFirst',
            options: {
              cacheName: 'images-cache',
              expiration: {
                maxEntries: 200,
                maxAgeSeconds: 60 * 60 * 24 * 30 // 30 days
              }
            }
          },
          // Fonts
          {
            urlPattern: /\.(?:woff|woff2|eot|ttf|otf)$/,
            handler: 'CacheFirst',
            options: {
              cacheName: 'fonts-cache',
              expiration: {
                maxEntries: 10,
                maxAgeSeconds: 60 * 60 * 24 * 365 // 1 year
              }
            }
          },
          // Documents and attachments
          {
            urlPattern: /\/files\/.*/,
            handler: 'CacheFirst',
            options: {
              cacheName: 'files-cache',
              expiration: {
                maxEntries: 50,
                maxAgeSeconds: 60 * 60 * 24 * 7 // 1 week
              }
            }
          }
        ]
      },
      devOptions: {
        enabled: true // Enable PWA in development
      }
    })
  ],
  // ... rest of your config
})
```

### 3. Create PWA Composable

```javascript
// src/composables/usePWA.js
import { ref, onMounted } from 'vue'
import { useRegisterSW } from 'virtual:pwa-register/vue'

export function usePWA() {
  const isInstallable = ref(false)
  const isOffline = ref(!navigator.onLine)
  const deferredPrompt = ref(null)

  // Service Worker registration
  const {
    needRefresh,
    offlineReady,
    updateServiceWorker,
  } = useRegisterSW({
    onRegistered(r) {
      console.log('SW Registered: ' + r)
    },
    onRegisterError(error) {
      console.log('SW registration error', error)
    },
  })

  // Install prompt handling
  const handleBeforeInstallPrompt = (e) => {
    e.preventDefault()
    deferredPrompt.value = e
    isInstallable.value = true
  }

  const installApp = async () => {
    if (!deferredPrompt.value) return

    deferredPrompt.value.prompt()
    const { outcome } = await deferredPrompt.value.userChoice
    
    if (outcome === 'accepted') {
      console.log('User accepted the install prompt')
    }
    
    deferredPrompt.value = null
    isInstallable.value = false
  }

  // Online/offline detection
  const handleOnline = () => {
    isOffline.value = false
  }

  const handleOffline = () => {
    isOffline.value = true
  }

  onMounted(() => {
    window.addEventListener('beforeinstallprompt', handleBeforeInstallPrompt)
    window.addEventListener('online', handleOnline)
    window.addEventListener('offline', handleOffline)
  })

  return {
    isInstallable,
    isOffline,
    needRefresh,
    offlineReady,
    installApp,
    updateServiceWorker,
  }
}
```

### 4. Create Offline Storage Service

```javascript
// src/services/offlineStorage.js
import localforage from 'localforage'

class OfflineStorage {
  constructor() {
    this.store = localforage.createInstance({
      name: 'ERPNextApp',
      storeName: 'documents',
      version: 1.0,
      description: 'Offline document storage'
    })

    this.queueStore = localforage.createInstance({
      name: 'ERPNextApp',
      storeName: 'queue',
      version: 1.0,
      description: 'Offline action queue'
    })
  }

  // Document operations
  async storeDocument(doctype, name, data) {
    const key = `${doctype}:${name}`
    await this.store.setItem(key, {
      ...data,
      _cached_at: Date.now(),
      _doctype: doctype,
      _name: name
    })
  }

  async getDocument(doctype, name) {
    const key = `${doctype}:${name}`
    return await this.store.getItem(key)
  }

  async removeDocument(doctype, name) {
    const key = `${doctype}:${name}`
    await this.store.removeItem(key)
  }

  async getCachedDocuments(doctype) {
    const keys = await this.store.keys()
    const doctypeKeys = keys.filter(key => key.startsWith(`${doctype}:`))
    
    const documents = await Promise.all(
      doctypeKeys.map(key => this.store.getItem(key))
    )
    
    return documents.filter(Boolean)
  }

  // Queue operations for offline actions
  async queueAction(action) {
    const id = `action_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    await this.queueStore.setItem(id, {
      id,
      ...action,
      timestamp: Date.now(),
      status: 'pending'
    })
    return id
  }

  async getQueuedActions() {
    const keys = await this.queueStore.keys()
    const actions = await Promise.all(
      keys.map(key => this.queueStore.getItem(key))
    )
    return actions.filter(action => action && action.status === 'pending')
  }

  async markActionCompleted(id) {
    const action = await this.queueStore.getItem(id)
    if (action) {
      action.status = 'completed'
      await this.queueStore.setItem(id, action)
    }
  }

  async removeAction(id) {
    await this.queueStore.removeItem(id)
  }

  // Cleanup old cached data
  async cleanup(maxAge = 7 * 24 * 60 * 60 * 1000) { // 7 days
    const keys = await this.store.keys()
    const now = Date.now()
    
    for (const key of keys) {
      const item = await this.store.getItem(key)
      if (item && item._cached_at && (now - item._cached_at) > maxAge) {
        await this.store.removeItem(key)
      }
    }
  }
}

export const offlineStorage = new OfflineStorage()
```

### 5. Create Offline-Aware Resource Hook

```javascript
// src/composables/useOfflineResource.js
import { ref, computed } from 'vue'
import { createResource } from 'frappe-ui'
import { offlineStorage } from '@/services/offlineStorage'
import { usePWA } from '@/composables/usePWA'

export function useOfflineResource(options) {
  const { isOffline } = usePWA()
  const cachedData = ref(null)
  const syncStatus = ref('synced') // synced, pending, error

  // Create the base resource
  const resource = createResource({
    ...options,
    auto: false, // We'll handle auto-loading with offline logic
    onSuccess: async (data) => {
      // Cache successful responses
      if (options.doctype && options.name) {
        await offlineStorage.storeDocument(options.doctype, options.name, data)
      }
      cachedData.value = data
      syncStatus.value = 'synced'
      
      if (options.onSuccess) {
        options.onSuccess(data)
      }
    },
    onError: async (error) => {
      if (isOffline.value && options.doctype && options.name) {
        // Try to load from cache when offline
        const cached = await offlineStorage.getDocument(options.doctype, options.name)
        if (cached) {
          cachedData.value = cached
          syncStatus.value = 'cached'
          return
        }
      }
      
      if (options.onError) {
        options.onError(error)
      }
    }
  })

  // Enhanced fetch method
  const fetch = async () => {
    if (isOffline.value && options.doctype && options.name) {
      // Try cache first when offline
      const cached = await offlineStorage.getDocument(options.doctype, options.name)
      if (cached) {
        cachedData.value = cached
        syncStatus.value = 'cached'
        return cached
      }
    }

    return resource.fetch()
  }

  // Enhanced submit method for offline queueing
  const submit = async (data) => {
    if (isOffline.value) {
      // Queue the action for later
      await offlineStorage.queueAction({
        type: 'submit',
        url: resource.url,
        data: data,
        doctype: options.doctype,
        name: options.name
      })
      syncStatus.value = 'pending'
      return { queued: true }
    }

    return resource.submit(data)
  }

  // Auto-load with offline support
  if (options.auto !== false) {
    fetch()
  }

  return {
    ...resource,
    fetch,
    submit,
    cachedData,
    syncStatus,
    isOffline,
    data: computed(() => cachedData.value || resource.data)
  }
}
```

### 6. Create Background Sync Service

```javascript
// src/services/backgroundSync.js
import { offlineStorage } from './offlineStorage'
import { toast } from 'frappe-ui'

class BackgroundSyncService {
  constructor() {
    this.isProcessing = false
    this.syncInterval = null
  }

  startPeriodicSync() {
    // Check for queued actions every 30 seconds when online
    this.syncInterval = setInterval(() => {
      if (navigator.onLine && !this.isProcessing) {
        this.processQueue()
      }
    }, 30000)
  }

  stopPeriodicSync() {
    if (this.syncInterval) {
      clearInterval(this.syncInterval)
      this.syncInterval = null
    }
  }

  async processQueue() {
    if (this.isProcessing) return

    this.isProcessing = true

    try {
      const actions = await offlineStorage.getQueuedActions()
      
      if (actions.length === 0) {
        this.isProcessing = false
        return
      }

      console.log(`Processing ${actions.length} queued actions`)

      for (const action of actions) {
        try {
          await this.processAction(action)
          await offlineStorage.markActionCompleted(action.id)
        } catch (error) {
          console.error('Failed to process action:', action, error)
          // Keep the action in queue for retry
        }
      }

      if (actions.length > 0) {
        toast.success(`Synced ${actions.length} offline changes`)
      }

    } catch (error) {
      console.error('Error processing background sync queue:', error)
    } finally {
      this.isProcessing = false
    }
  }

  async processAction(action) {
    switch (action.type) {
      case 'submit':
        return this.processSubmitAction(action)
      case 'update':
        return this.processUpdateAction(action)
      case 'delete':
        return this.processDeleteAction(action)
      default:
        throw new Error(`Unknown action type: ${action.type}`)
    }
  }

  async processSubmitAction(action) {
    const response = await fetch('/api/method/' + action.url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Frappe-CSRF-Token': window.csrf_token
      },
      credentials: 'include',
      body: JSON.stringify(action.data)
    })

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }

    const result = await response.json()
    
    if (result.message && result.message.success === false) {
      throw new Error(result.message.message || 'API request failed')
    }

    return result
  }

  async processUpdateAction(action) {
    // Similar to submit but for updates
    return this.processSubmitAction(action)
  }

  async processDeleteAction(action) {
    const response = await fetch(`/api/method/frappe.client.delete`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Frappe-CSRF-Token': window.csrf_token
      },
      credentials: 'include',
      body: JSON.stringify({
        doctype: action.doctype,
        name: action.name
      })
    })

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }

    // Remove from local cache
    await offlineStorage.removeDocument(action.doctype, action.name)
  }

  // Manual sync trigger
  async syncNow() {
    await this.processQueue()
  }
}

export const backgroundSync = new BackgroundSyncService()
```

### 7. Add PWA Components

```vue
<!-- src/components/PWAInstallPrompt.vue -->
<template>
  <div
    v-if="showPrompt"
    class="fixed bottom-4 left-4 right-4 bg-white border border-gray-200 rounded-lg shadow-lg p-4 z-50"
  >
    <div class="flex items-start space-x-3">
      <div class="flex-shrink-0">
        <Icon name="download" class="h-6 w-6 text-blue-600" />
      </div>
      <div class="flex-1">
        <h3 class="text-sm font-semibold text-gray-900">
          Install App
        </h3>
        <p class="text-sm text-gray-600">
          Add this app to your home screen for quick access and offline use.
        </p>
      </div>
    </div>
    <div class="mt-4 flex space-x-2">
      <Button variant="solid" size="sm" @click="install">
        Install
      </Button>
      <Button variant="ghost" size="sm" @click="dismiss">
        Not now
      </Button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { usePWA } from '@/composables/usePWA'
import { Button, Icon } from 'frappe-ui'

const { isInstallable, installApp } = usePWA()
const showPrompt = ref(false)
const dismissed = ref(false)

onMounted(() => {
  // Show prompt after 30 seconds if installable and not dismissed
  setTimeout(() => {
    if (isInstallable.value && !dismissed.value) {
      showPrompt.value = true
    }
  }, 30000)
})

const install = () => {
  installApp()
  showPrompt.value = false
}

const dismiss = () => {
  showPrompt.value = false
  dismissed.value = true
  // Remember dismissal in localStorage
  localStorage.setItem('pwa-install-dismissed', Date.now())
}

// Check if user previously dismissed
onMounted(() => {
  const dismissedTime = localStorage.getItem('pwa-install-dismissed')
  if (dismissedTime) {
    const daysSinceDismissed = (Date.now() - parseInt(dismissedTime)) / (1000 * 60 * 60 * 24)
    if (daysSinceDismissed < 30) { // Don't show for 30 days
      dismissed.value = true
    }
  }
})
</script>
```

```vue
<!-- src/components/OfflineIndicator.vue -->
<template>
  <div
    v-if="isOffline || hasPendingChanges"
    class="flex items-center space-x-2 px-3 py-2 bg-yellow-50 border-l-4 border-yellow-400"
  >
    <Icon 
      :name="isOffline ? 'wifi-off' : 'clock'"
      class="h-4 w-4 text-yellow-600"
    />
    <span class="text-sm text-yellow-800">
      {{ statusMessage }}
    </span>
    <Button
      v-if="hasPendingChanges && !isOffline"
      variant="ghost"
      size="sm"
      @click="syncNow"
      :loading="isSyncing"
    >
      Sync Now
    </Button>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { usePWA } from '@/composables/usePWA'
import { backgroundSync } from '@/services/backgroundSync'
import { offlineStorage } from '@/services/offlineStorage'
import { Button, Icon } from 'frappe-ui'

const { isOffline } = usePWA()
const pendingActions = ref([])
const isSyncing = ref(false)

const hasPendingChanges = computed(() => pendingActions.value.length > 0)

const statusMessage = computed(() => {
  if (isOffline.value) {
    return 'You are offline. Changes will sync when connected.'
  } else if (hasPendingChanges.value) {
    return `${pendingActions.value.length} changes pending sync`
  }
  return ''
})

const updatePendingActions = async () => {
  pendingActions.value = await offlineStorage.getQueuedActions()
}

const syncNow = async () => {
  isSyncing.value = true
  try {
    await backgroundSync.syncNow()
    await updatePendingActions()
  } catch (error) {
    console.error('Sync failed:', error)
  } finally {
    isSyncing.value = false
  }
}

let intervalId = null

onMounted(() => {
  updatePendingActions()
  // Check for pending actions every 10 seconds
  intervalId = setInterval(updatePendingActions, 10000)
})

onUnmounted(() => {
  if (intervalId) {
    clearInterval(intervalId)
  }
})
</script>
```

### 8. Update Main App with PWA Features

```vue
<!-- src/App.vue -->
<template>
  <div id="app">
    <!-- Update notification -->
    <UpdateNotification 
      v-if="needRefresh"
      @update="updateServiceWorker"
    />
    
    <!-- Offline indicator -->
    <OfflineIndicator />
    
    <!-- Install prompt -->
    <PWAInstallPrompt />
    
    <!-- Main app content -->
    <RouterView v-if="isReady" />
    <div v-else class="flex items-center justify-center h-screen">
      <LoadingIndicator />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { usePWA } from '@/composables/usePWA'
import { backgroundSync } from '@/services/backgroundSync'
import { offlineStorage } from '@/services/offlineStorage'
import { LoadingIndicator } from 'frappe-ui'
import UpdateNotification from '@/components/UpdateNotification.vue'
import OfflineIndicator from '@/components/OfflineIndicator.vue'
import PWAInstallPrompt from '@/components/PWAInstallPrompt.vue'

const isReady = ref(false)
const authStore = useAuthStore()
const { needRefresh, updateServiceWorker } = usePWA()

onMounted(async () => {
  try {
    // Initialize app
    await authStore.init()
    
    // Start background sync
    backgroundSync.startPeriodicSync()
    
    // Cleanup old cached data
    await offlineStorage.cleanup()
    
  } catch (error) {
    console.error('Failed to initialize app:', error)
  } finally {
    isReady.value = true
  }
})
</script>
```

### 9. Create Push Notification Service (Optional)

```javascript
// src/services/pushNotifications.js
class PushNotificationService {
  constructor() {
    this.registration = null
    this.subscription = null
  }

  async init() {
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) {
      console.warn('Push notifications not supported')
      return false
    }

    try {
      this.registration = await navigator.serviceWorker.ready
      return true
    } catch (error) {
      console.error('Service worker not ready:', error)
      return false
    }
  }

  async requestPermission() {
    const permission = await Notification.requestPermission()
    return permission === 'granted'
  }

  async subscribe() {
    if (!this.registration) {
      throw new Error('Service worker not ready')
    }

    try {
      this.subscription = await this.registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(
          import.meta.env.VITE_VAPID_PUBLIC_KEY
        )
      })

      // Send subscription to server
      await this.sendSubscriptionToServer(this.subscription)
      return this.subscription
    } catch (error) {
      console.error('Failed to subscribe to push notifications:', error)
      throw error
    }
  }

  async sendSubscriptionToServer(subscription) {
    const response = await fetch('/api/method/your_app.api.notifications.subscribe', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Frappe-CSRF-Token': window.csrf_token
      },
      credentials: 'include',
      body: JSON.stringify({
        subscription: subscription.toJSON()
      })
    })

    if (!response.ok) {
      throw new Error('Failed to send subscription to server')
    }
  }

  urlBase64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding)
      .replace(/-/g, '+')
      .replace(/_/g, '/')

    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }
}

export const pushNotifications = new PushNotificationService()
```

### 10. Add PWA Icons and Assets

Create the following icon files in your `public` directory:

```
public/
├── favicon.ico
├── apple-touch-icon.png (180x180)
├── pwa-192x192.png
├── pwa-512x512.png
├── safari-pinned-tab.svg
├── screenshot-wide.png (1280x720)
└── screenshot-mobile.png (640x1136)
```

### 11. Update HTML Meta Tags

```html
<!-- public/index.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    
    <!-- PWA Meta Tags -->
    <meta name="theme-color" content="#171717" />
    <meta name="description" content="Modern ERPNext application with offline capabilities" />
    
    <!-- Apple Touch Icon -->
    <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
    
    <!-- Apple Mobile Web App -->
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="default" />
    <meta name="apple-mobile-web-app-title" content="ModernApp" />
    
    <!-- Microsoft -->
    <meta name="msapplication-TileColor" content="#171717" />
    <meta name="msapplication-config" content="/browserconfig.xml" />
    
    <title>ERPNext Modern App</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/src/main.js"></script>
  </body>
</html>
```

### 12. Testing PWA Features

```javascript
// src/utils/pwaTest.js
export class PWATestSuite {
  static async runTests() {
    const results = {
      serviceWorker: await this.testServiceWorker(),
      manifest: await this.testManifest(),
      offline: await this.testOfflineCapability(),
      installable: await this.testInstallability(),
      caching: await this.testCaching()
    }

    console.table(results)
    return results
  }

  static async testServiceWorker() {
    try {
      if (!('serviceWorker' in navigator)) {
        return { status: 'fail', message: 'Service Worker not supported' }
      }

      const registration = await navigator.serviceWorker.ready
      return { 
        status: 'pass', 
        message: `Service Worker registered: ${registration.scope}` 
      }
    } catch (error) {
      return { status: 'fail', message: error.message }
    }
  }

  static async testManifest() {
    try {
      const response = await fetch('/manifest.json')
      if (response.ok) {
        const manifest = await response.json()
        return { 
          status: 'pass', 
          message: `Manifest loaded: ${manifest.name}` 
        }
      } else {
        return { status: 'fail', message: 'Manifest not found' }
      }
    } catch (error) {
      return { status: 'fail', message: error.message }
    }
  }

  static async testOfflineCapability() {
    // Test offline functionality
    // This would involve mocking offline state and testing cache
    return { status: 'manual', message: 'Manual testing required' }
  }

  static async testInstallability() {
    if ('BeforeInstallPromptEvent' in window) {
      return { status: 'pass', message: 'Install prompt supported' }
    } else {
      return { status: 'fail', message: 'Install prompt not supported' }
    }
  }

  static async testCaching() {
    try {
      const cache = await caches.open('api-cache')
      return { status: 'pass', message: 'Caching API available' }
    } catch (error) {
      return { status: 'fail', message: error.message }
    }
  }
}

// Run in development
if (import.meta.env.DEV) {
  window.testPWA = PWATestSuite.runTests
}
```

### 13. Update Build Scripts

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build && npm run build:pwa-assets",
    "build:pwa-assets": "node scripts/generate-pwa-assets.js",
    "preview": "vite preview",
    "test:pwa": "npm run build && npx lighthouse http://localhost:4173 --preset=desktop --view"
  }
}
```

### 14. Create Asset Generation Script

```javascript
// scripts/generate-pwa-assets.js
import sharp from 'sharp'
import { promises as fs } from 'fs'

const sizes = [
  { size: 192, name: 'pwa-192x192.png' },
  { size: 512, name: 'pwa-512x512.png' },
  { size: 180, name: 'apple-touch-icon.png' }
]

async function generateIcons() {
  // Assuming you have a source icon at assets/icon.png
  const sourceIcon = 'assets/icon.png'
  
  for (const { size, name } of sizes) {
    await sharp(sourceIcon)
      .resize(size, size)
      .png()
      .toFile(`public/${name}`)
    
    console.log(`Generated ${name}`)
  }
}

generateIcons().catch(console.error)
```

## Best Practices

### 1. Cache Strategy
- **Network First**: For critical, frequently changing data (API calls)
- **Cache First**: For static assets (images, fonts)
- **Stale While Revalidate**: For less critical but frequently accessed data

### 2. Offline UX Patterns
- Clear offline indicators
- Queue actions with visual feedback
- Graceful degradation of features
- Helpful error messages

### 3. Performance Optimization
- Lazy load non-critical PWA features
- Minimize service worker code
- Use efficient caching strategies
- Monitor cache sizes

### 4. Security Considerations
- Only cache public data offline
- Validate queued actions before sync
- Use HTTPS for all PWA features
- Sanitize cached data

## Testing Checklist

### Manual Testing
- [ ] App installs on mobile devices
- [ ] Offline functionality works
- [ ] Service worker updates properly
- [ ] Push notifications work (if implemented)
- [ ] App manifest is valid
- [ ] Icons display correctly

### Automated Testing
- [ ] Lighthouse PWA audit passes
- [ ] Service worker registration works
- [ ] Caching strategies function
- [ ] Offline queue processes correctly

### Browser Testing
- [ ] Chrome (Android & Desktop)
- [ ] Safari (iOS)
- [ ] Firefox
- [ ] Edge

## Troubleshooting

### Common Issues

1. **Service Worker not updating**
   - Clear browser cache
   - Check skipWaiting configuration
   - Verify version changes

2. **Install prompt not showing**
   - Check manifest.json validity
   - Verify HTTPS requirement
   - Test on supported browsers

3. **Offline caching not working**
   - Verify cache strategies
   - Check network patterns
   - Debug service worker logs

4. **Background sync failing**
   - Check queue processing logic
   - Verify API endpoints are reachable
   - Monitor browser console for errors

## Deployment Considerations

### Production Checklist
- [ ] HTTPS enabled
- [ ] Service worker properly registered
- [ ] Cache headers configured
- [ ] Manifest.json accessible
- [ ] Icons available at correct URLs
- [ ] Performance monitoring set up

### CDN Configuration
- Ensure service worker is served from same origin
- Configure proper cache headers for PWA assets
- Test PWA features with CDN enabled

This completes the PWA implementation for your ERPNext Vue SPA. The app will now work offline, be installable, and provide a native app-like experience.