# Socket.io Integration Patterns for ERPNext

## Overview
Socket.io enables real-time bidirectional communication between ERPNext backend and Vue frontend. Frappe Framework has built-in Socket.io support for real-time updates.

## Setup and Configuration

### Frontend Setup
```javascript
// src/utils/socket.js
import { io } from 'socket.io-client'

class SocketManager {
  constructor() {
    this.socket = null
    this.connected = false
    this.listeners = new Map()
  }

  connect() {
    if (this.socket) return

    // Connect to Frappe's socket.io server
    this.socket = io({
      path: '/socket.io',
      reconnectionDelay: 1000,
      reconnection: true,
      reconnectionAttempts: 5,
      transports: ['websocket'],
      agent: false,
      upgrade: false,
      rejectUnauthorized: false
    })

    this.setupEventHandlers()
  }

  setupEventHandlers() {
    this.socket.on('connect', () => {
      console.log('Socket connected')
      this.connected = true
      this.emit('socket:connected')
    })

    this.socket.on('disconnect', () => {
      console.log('Socket disconnected')
      this.connected = false
      this.emit('socket:disconnected')
    })

    this.socket.on('error', (error) => {
      console.error('Socket error:', error)
      this.emit('socket:error', error)
    })
  }

  // Subscribe to Frappe document events
  subscribeToDoc(doctype, name, callback) {
    const event = `doc_update:${doctype}:${name}`
    this.socket.on(event, callback)
    return () => this.socket.off(event, callback)
  }

  // Subscribe to custom events
  on(event, callback) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set())
    }
    this.listeners.get(event).add(callback)
    this.socket.on(event, callback)
    
    // Return unsubscribe function
    return () => {
      this.socket.off(event, callback)
      const callbacks = this.listeners.get(event)
      if (callbacks) {
        callbacks.delete(callback)
      }
    }
  }

  emit(event, data) {
    if (this.socket && this.connected) {
      this.socket.emit(event, data)
    }
  }

  disconnect() {
    if (this.socket) {
      this.socket.disconnect()
      this.socket = null
      this.connected = false
    }
  }
}

export const socketManager = new SocketManager()
```

### Vue Plugin Setup
```javascript
// src/plugins/socket.js
import { socketManager } from '@/utils/socket'

export default {
  install(app) {
    // Initialize socket connection
    socketManager.connect()

    // Make available globally
    app.config.globalProperties.$socket = socketManager
    app.provide('socket', socketManager)

    // Cleanup on app unmount
    app.unmount = new Proxy(app.unmount, {
      apply(target, thisArg, argList) {
        socketManager.disconnect()
        return Reflect.apply(target, thisArg, argList)
      }
    })
  }
}
```

### Main App Integration
```javascript
// src/main.js
import { createApp } from 'vue'
import App from './App.vue'
import socketPlugin from './plugins/socket'

const app = createApp(App)
app.use(socketPlugin)
app.mount('#app')
```

## Real-time Document Updates

### Composable for Document Subscription
```javascript
// src/composables/useRealtimeDoc.js
import { ref, onMounted, onUnmounted } from 'vue'
import { inject } from 'vue'
import { createResource } from 'frappe-ui'

export function useRealtimeDoc(doctype, name) {
  const socket = inject('socket')
  const doc = ref(null)
  const loading = ref(true)
  const error = ref(null)
  let unsubscribe = null

  // Initial fetch
  const resource = createResource({
    url: 'frappe.client.get',
    params: { doctype, name },
    auto: false,
    onSuccess(data) {
      doc.value = data
      loading.value = false
    },
    onError(err) {
      error.value = err
      loading.value = false
    }
  })

  onMounted(() => {
    // Fetch initial data
    resource.reload()

    // Subscribe to real-time updates
    unsubscribe = socket.subscribeToDoc(doctype, name, (data) => {
      console.log(`Document updated: ${doctype}/${name}`, data)
      doc.value = { ...doc.value, ...data }
    })
  })

  onUnmounted(() => {
    if (unsubscribe) {
      unsubscribe()
    }
  })

  return {
    doc,
    loading,
    error,
    reload: () => resource.reload()
  }
}
```

### Usage in Components
```vue
<template>
  <div v-if="loading">Loading...</div>
  <div v-else-if="error">Error: {{ error }}</div>
  <div v-else>
    <h2>{{ doc.title }}</h2>
    <p>Status: {{ doc.status }}</p>
    <p>Last Modified: {{ doc.modified }}</p>
  </div>
</template>

<script setup>
import { useRealtimeDoc } from '@/composables/useRealtimeDoc'

const props = defineProps({
  doctype: String,
  name: String
})

const { doc, loading, error } = useRealtimeDoc(props.doctype, props.name)
</script>
```

## Real-time List Updates

### Live List Component
```vue
<template>
  <div class="space-y-4">
    <div v-for="item in items" :key="item.name" class="border p-4 rounded">
      <h3>{{ item.title }}</h3>
      <p>{{ item.status }}</p>
      <Badge v-if="item.isNew" variant="success">New</Badge>
      <Badge v-if="item.isUpdated" variant="info">Updated</Badge>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, inject } from 'vue'
import { createResource } from 'frappe-ui'
import { Badge } from 'frappe-ui'

const props = defineProps({
  doctype: String,
  filters: Object
})

const socket = inject('socket')
const items = ref([])
let unsubscribers = []

// Fetch initial list
const listResource = createResource({
  url: 'frappe.client.get_list',
  params: {
    doctype: props.doctype,
    fields: ['*'],
    filters: props.filters || {}
  },
  auto: true,
  onSuccess(data) {
    items.value = data
    subscribeToUpdates(data)
  }
})

function subscribeToUpdates(initialItems) {
  // Subscribe to each document
  initialItems.forEach(item => {
    const unsub = socket.subscribeToDoc(props.doctype, item.name, (update) => {
      const index = items.value.findIndex(i => i.name === item.name)
      if (index !== -1) {
        items.value[index] = {
          ...items.value[index],
          ...update,
          isUpdated: true
        }
        // Remove update indicator after 3 seconds
        setTimeout(() => {
          items.value[index].isUpdated = false
        }, 3000)
      }
    })
    unsubscribers.push(unsub)
  })

  // Subscribe to new document creation
  socket.on(`new_doc:${props.doctype}`, (newDoc) => {
    if (matchesFilters(newDoc, props.filters)) {
      items.value.unshift({
        ...newDoc,
        isNew: true
      })
      // Remove new indicator after 3 seconds
      setTimeout(() => {
        const index = items.value.findIndex(i => i.name === newDoc.name)
        if (index !== -1) {
          items.value[index].isNew = false
        }
      }, 3000)
    }
  })
}

function matchesFilters(doc, filters) {
  // Simple filter matching logic
  if (!filters) return true
  return Object.entries(filters).every(([key, value]) => {
    return doc[key] === value
  })
}

onUnmounted(() => {
  unsubscribers.forEach(unsub => unsub())
  socket.off(`new_doc:${props.doctype}`)
})
</script>
```

## Custom Event Patterns

### Backend Event Emission
```python
# In your Python controller or API
import frappe
from frappe import publish_realtime

@frappe.whitelist()
def process_order(order_name):
    """Process an order and emit real-time updates"""
    order = frappe.get_doc("Sales Order", order_name)
    
    # Emit progress updates
    publish_realtime(
        event='order_processing',
        message={
            'order': order_name,
            'status': 'started',
            'progress': 0
        },
        user=frappe.session.user
    )
    
    # Process order steps
    for i, step in enumerate(['validate', 'calculate', 'submit']):
        # Do processing...
        time.sleep(1)  # Simulate work
        
        publish_realtime(
            event='order_processing',
            message={
                'order': order_name,
                'status': 'processing',
                'step': step,
                'progress': (i + 1) * 33
            },
            user=frappe.session.user
        )
    
    # Complete
    publish_realtime(
        event='order_processing',
        message={
            'order': order_name,
            'status': 'completed',
            'progress': 100
        },
        user=frappe.session.user
    )
    
    return {'status': 'success'}

# Broadcast to all users
def notify_all_users(message):
    publish_realtime(
        event='global_notification',
        message=message,
        room=None  # Broadcast to all
    )

# Send to specific room/channel
def notify_department(department, message):
    publish_realtime(
        event='department_update',
        message=message,
        room=f'department:{department}'
    )
```

### Frontend Event Handling
```vue
<template>
  <div>
    <ProgressBar :value="progress" v-if="processing" />
    <div v-if="status">Status: {{ status }}</div>
    <Button @click="processOrder">Process Order</Button>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, inject } from 'vue'
import { createResource, ProgressBar, Button } from 'frappe-ui'

const socket = inject('socket')
const progress = ref(0)
const status = ref('')
const processing = ref(false)

const processOrderResource = createResource({
  url: 'custom_app.api.process_order',
  onSuccess() {
    // Order processed successfully
  }
})

function processOrder() {
  processing.value = true
  processOrderResource.submit({
    order_name: 'SO-2024-00001'
  })
}

onMounted(() => {
  // Listen for order processing updates
  socket.on('order_processing', (data) => {
    progress.value = data.progress
    status.value = data.status
    
    if (data.status === 'completed') {
      processing.value = false
      setTimeout(() => {
        progress.value = 0
        status.value = ''
      }, 2000)
    }
  })
})

onUnmounted(() => {
  socket.off('order_processing')
})
</script>
```

## Notification System

### Global Notification Store
```javascript
// stores/notifications.js
import { defineStore } from 'pinia'
import { ref } from 'vue'
import { socketManager } from '@/utils/socket'

export const useNotificationStore = defineStore('notifications', () => {
  const notifications = ref([])
  const unreadCount = ref(0)

  function init() {
    // Listen for notifications
    socketManager.on('notification', (notification) => {
      addNotification(notification)
    })

    // Listen for global broadcasts
    socketManager.on('global_notification', (message) => {
      addNotification({
        type: 'info',
        title: 'System Notification',
        message,
        timestamp: new Date()
      })
    })
  }

  function addNotification(notification) {
    notifications.value.unshift({
      ...notification,
      id: Date.now(),
      read: false
    })
    unreadCount.value++
    
    // Show toast notification
    showToast(notification)
  }

  function markAsRead(id) {
    const notification = notifications.value.find(n => n.id === id)
    if (notification && !notification.read) {
      notification.read = true
      unreadCount.value--
    }
  }

  function clearAll() {
    notifications.value = []
    unreadCount.value = 0
  }

  return {
    notifications,
    unreadCount,
    init,
    addNotification,
    markAsRead,
    clearAll
  }
})
```

## Collaborative Editing

### Real-time Collaboration Component
```vue
<template>
  <div class="relative">
    <!-- Show other users editing -->
    <div class="flex gap-2 mb-2">
      <Avatar 
        v-for="user in activeUsers" 
        :key="user.id"
        :title="user.name"
        :image="user.avatar"
        size="sm"
      />
    </div>
    
    <!-- Editor with real-time sync -->
    <textarea
      v-model="content"
      @input="handleInput"
      @focus="handleFocus"
      @blur="handleBlur"
      class="w-full p-2 border rounded"
      :placeholder="placeholder"
    />
    
    <!-- Show who is typing -->
    <div v-if="typingUsers.length" class="text-sm text-gray-500 mt-1">
      {{ typingMessage }}
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, inject } from 'vue'
import { debounce } from 'frappe-ui'
import { Avatar } from 'frappe-ui'

const props = defineProps({
  doctype: String,
  name: String,
  field: String,
  placeholder: String
})

const socket = inject('socket')
const content = ref('')
const activeUsers = ref([])
const typingUsers = ref([])
const userId = ref(null)

const typingMessage = computed(() => {
  if (typingUsers.value.length === 1) {
    return `${typingUsers.value[0].name} is typing...`
  } else if (typingUsers.value.length > 1) {
    return `${typingUsers.value.length} people are typing...`
  }
  return ''
})

// Debounced content update
const emitContentUpdate = debounce((value) => {
  socket.emit('field_update', {
    doctype: props.doctype,
    name: props.name,
    field: props.field,
    value,
    user: userId.value
  })
}, 300)

// Debounced typing indicator
const emitTyping = debounce(() => {
  socket.emit('user_typing', {
    doctype: props.doctype,
    name: props.name,
    field: props.field,
    user: userId.value,
    typing: true
  })
}, 100)

function handleInput(event) {
  emitContentUpdate(event.target.value)
  emitTyping()
}

function handleFocus() {
  socket.emit('user_joined_field', {
    doctype: props.doctype,
    name: props.name,
    field: props.field,
    user: userId.value
  })
}

function handleBlur() {
  socket.emit('user_left_field', {
    doctype: props.doctype,
    name: props.name,
    field: props.field,
    user: userId.value
  })
  
  // Stop typing indicator
  socket.emit('user_typing', {
    doctype: props.doctype,
    name: props.name,
    field: props.field,
    user: userId.value,
    typing: false
  })
}

onMounted(() => {
  // Get current user ID
  userId.value = frappe.session.user
  
  // Join collaboration room
  const room = `${props.doctype}:${props.name}:${props.field}`
  socket.emit('join_room', room)
  
  // Listen for field updates
  socket.on('field_update', (data) => {
    if (data.field === props.field && data.user !== userId.value) {
      content.value = data.value
    }
  })
  
  // Listen for active users
  socket.on('active_users_update', (users) => {
    activeUsers.value = users.filter(u => u.id !== userId.value)
  })
  
  // Listen for typing indicators
  socket.on('user_typing', (data) => {
    if (data.typing && data.user !== userId.value) {
      const userIndex = typingUsers.value.findIndex(u => u.id === data.user)
      if (userIndex === -1) {
        typingUsers.value.push(data)
      }
      
      // Remove typing indicator after 2 seconds
      setTimeout(() => {
        typingUsers.value = typingUsers.value.filter(u => u.id !== data.user)
      }, 2000)
    } else {
      typingUsers.value = typingUsers.value.filter(u => u.id !== data.user)
    }
  })
})

onUnmounted(() => {
  handleBlur()
  const room = `${props.doctype}:${props.name}:${props.field}`
  socket.emit('leave_room', room)
  socket.off('field_update')
  socket.off('active_users_update')
  socket.off('user_typing')
})
</script>
```

## Connection Management

### Connection Status Component
```vue
<template>
  <div class="fixed bottom-4 right-4 z-50">
    <transition name="fade">
      <div 
        v-if="!connected"
        class="bg-red-500 text-white px-4 py-2 rounded-lg shadow-lg flex items-center gap-2"
      >
        <Spinner size="sm" />
        <span>Reconnecting...</span>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue'
import { Spinner } from 'frappe-ui'

const socket = inject('socket')
const connected = ref(true)

onMounted(() => {
  socket.on('socket:connected', () => {
    connected.value = true
  })
  
  socket.on('socket:disconnected', () => {
    connected.value = false
  })
})
</script>

<style scoped>
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>
```

## Best Practices

### 1. Proper Cleanup
Always unsubscribe from events when components unmount:
```javascript
onUnmounted(() => {
  socket.off('event_name')
  unsubscribe()
})
```

### 2. Error Handling
```javascript
socket.on('error', (error) => {
  console.error('Socket error:', error)
  // Show user-friendly error message
  showToast({
    title: 'Connection Error',
    text: 'Real-time updates may be delayed',
    icon: 'alert-circle'
  })
})
```

### 3. Reconnection Strategy
```javascript
socket.on('disconnect', () => {
  // Attempt reconnection with exponential backoff
  let retryDelay = 1000
  const maxDelay = 30000
  
  const retry = () => {
    socket.connect()
    if (!socket.connected) {
      retryDelay = Math.min(retryDelay * 2, maxDelay)
      setTimeout(retry, retryDelay)
    }
  }
  
  setTimeout(retry, retryDelay)
})
```

### 4. Room Management
```javascript
// Join specific rooms for targeted updates
socket.emit('join_room', `user:${userId}`)
socket.emit('join_room', `department:${deptId}`)

// Leave rooms when no longer needed
socket.emit('leave_room', `user:${userId}`)
```

### 5. Performance Optimization
- Debounce frequent events
- Use rooms to limit broadcast scope
- Implement message queuing for offline support
- Batch updates when possible
- Use compression for large payloads

## Security Considerations

1. **Authentication**: Validate user session before accepting socket connections
2. **Authorization**: Check permissions before broadcasting sensitive data
3. **Input Validation**: Sanitize all data received through sockets
4. **Rate Limiting**: Implement rate limiting to prevent abuse
5. **Encryption**: Use WSS (WebSocket Secure) in production