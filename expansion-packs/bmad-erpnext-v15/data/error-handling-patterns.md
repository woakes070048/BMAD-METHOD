# Error Handling Patterns for Vue/ERPNext Applications

## Overview
Comprehensive error handling ensures a robust user experience and helps with debugging. This guide covers error handling at all levels of a Vue/ERPNext application.

## Global Error Handling

### Vue Error Handler Setup
```javascript
// src/main.js
import { createApp } from 'vue'
import App from './App.vue'
import { setupErrorHandling } from './utils/errorHandler'

const app = createApp(App)

// Setup global error handling
setupErrorHandling(app)

app.mount('#app')
```

### Error Handler Implementation
```javascript
// src/utils/errorHandler.js
import { showToast } from '@/utils/toast'

export function setupErrorHandling(app) {
  // Vue error handler
  app.config.errorHandler = (error, instance, info) => {
    console.error('Vue Error:', error, info)
    
    // Log to error tracking service
    logError({
      error,
      component: instance?.$options.name || 'Unknown',
      info,
      type: 'vue-error'
    })
    
    // Show user-friendly message
    showErrorToUser(error)
  }
  
  // Promise rejection handler
  window.addEventListener('unhandledrejection', (event) => {
    console.error('Unhandled Promise Rejection:', event.reason)
    
    logError({
      error: event.reason,
      type: 'unhandled-rejection'
    })
    
    showErrorToUser(event.reason)
    
    // Prevent default browser behavior
    event.preventDefault()
  })
  
  // Global error handler
  window.addEventListener('error', (event) => {
    console.error('Global Error:', event.error)
    
    logError({
      error: event.error,
      type: 'global-error',
      filename: event.filename,
      lineno: event.lineno,
      colno: event.colno
    })
    
    showErrorToUser(event.error)
  })
}

function logError(errorData) {
  // Send to error tracking service (e.g., Sentry)
  if (window.Sentry) {
    window.Sentry.captureException(errorData.error, {
      extra: errorData
    })
  }
  
  // Also log to backend
  fetch('/api/method/log_frontend_error', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Frappe-CSRF-Token': window.csrf_token
    },
    body: JSON.stringify(errorData)
  }).catch(err => {
    console.error('Failed to log error to backend:', err)
  })
}

function showErrorToUser(error) {
  const message = getUserFriendlyMessage(error)
  
  showToast({
    title: 'Error',
    text: message,
    icon: 'x',
    iconClasses: 'text-red-600',
    position: 'top-center',
    duration: 5000
  })
}

function getUserFriendlyMessage(error) {
  // Map technical errors to user-friendly messages
  const errorMap = {
    'NetworkError': 'Connection error. Please check your internet connection.',
    'ValidationError': 'Please check your input and try again.',
    'PermissionError': 'You do not have permission to perform this action.',
    'NotFoundError': 'The requested resource was not found.',
    'ServerError': 'Server error. Please try again later.'
  }
  
  if (error.response?.status === 403) {
    return errorMap.PermissionError
  } else if (error.response?.status === 404) {
    return errorMap.NotFoundError
  } else if (error.response?.status >= 500) {
    return errorMap.ServerError
  } else if (error.name in errorMap) {
    return errorMap[error.name]
  }
  
  return error.message || 'An unexpected error occurred'
}
```

## Component-Level Error Boundaries

### Error Boundary Component
```vue
<!-- src/components/ErrorBoundary.vue -->
<template>
  <div v-if="hasError" class="error-boundary">
    <div class="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
      <AlertCircle class="w-12 h-12 text-red-500 mx-auto mb-4" />
      <h3 class="text-lg font-semibold text-red-800 mb-2">
        {{ title }}
      </h3>
      <p class="text-red-600 mb-4">{{ message }}</p>
      
      <div class="space-x-2">
        <Button @click="retry" variant="solid">
          Try Again
        </Button>
        <Button @click="reset" variant="outline">
          Reset
        </Button>
      </div>
      
      <!-- Show details in development -->
      <details v-if="isDevelopment" class="mt-4 text-left">
        <summary class="cursor-pointer text-sm text-gray-500">
          Error Details
        </summary>
        <pre class="mt-2 text-xs bg-gray-100 p-2 rounded overflow-auto">{{ error }}</pre>
      </details>
    </div>
  </div>
  <slot v-else />
</template>

<script setup>
import { ref, onErrorCaptured } from 'vue'
import { Button } from 'frappe-ui'
import { AlertCircle } from 'lucide-vue-next'

const props = defineProps({
  title: {
    type: String,
    default: 'Something went wrong'
  },
  message: {
    type: String,
    default: 'An error occurred while rendering this component'
  },
  onError: Function,
  onRetry: Function
})

const hasError = ref(false)
const error = ref(null)
const isDevelopment = import.meta.env.DEV

onErrorCaptured((err, instance, info) => {
  console.error('Error captured:', err, info)
  hasError.value = true
  error.value = err
  
  if (props.onError) {
    props.onError(err, instance, info)
  }
  
  // Prevent error propagation
  return false
})

function retry() {
  if (props.onRetry) {
    props.onRetry()
  }
  reset()
}

function reset() {
  hasError.value = false
  error.value = null
}

defineExpose({ reset })
</script>
```

### Using Error Boundary
```vue
<template>
  <ErrorBoundary 
    title="Failed to load data"
    message="We couldn't load the requested information"
    :on-retry="loadData"
  >
    <DataComponent :data="data" />
  </ErrorBoundary>
</template>

<script setup>
import ErrorBoundary from '@/components/ErrorBoundary.vue'
import DataComponent from '@/components/DataComponent.vue'

const data = ref(null)

function loadData() {
  // Reload data logic
}
</script>
```

## API Error Handling

### Enhanced createResource with Error Handling
```javascript
// src/utils/api.js
import { createResource as frappeCreateResource } from 'frappe-ui'
import { showToast } from '@/utils/toast'

export function createResource(options) {
  const enhancedOptions = {
    ...options,
    onError: (error) => {
      handleApiError(error)
      
      // Call original onError if provided
      if (options.onError) {
        options.onError(error)
      }
    }
  }
  
  return frappeCreateResource(enhancedOptions)
}

function handleApiError(error) {
  console.error('API Error:', error)
  
  // Parse error response
  const errorData = parseErrorResponse(error)
  
  // Handle specific error types
  switch (errorData.type) {
    case 'ValidationError':
      handleValidationError(errorData)
      break
    case 'PermissionError':
      handlePermissionError(errorData)
      break
    case 'RateLimitError':
      handleRateLimitError(errorData)
      break
    default:
      handleGenericError(errorData)
  }
}

function parseErrorResponse(error) {
  if (error.response) {
    const { status, data } = error.response
    
    return {
      status,
      type: data?.exception || 'Unknown',
      message: data?.message || error.message,
      details: data?.details || {},
      traceback: data?._server_messages
    }
  }
  
  return {
    type: error.name,
    message: error.message,
    details: {}
  }
}

function handleValidationError(errorData) {
  showToast({
    title: 'Validation Error',
    text: errorData.message,
    icon: 'alert-triangle',
    iconClasses: 'text-yellow-600'
  })
}

function handlePermissionError(errorData) {
  showToast({
    title: 'Permission Denied',
    text: 'You do not have permission to perform this action',
    icon: 'lock',
    iconClasses: 'text-red-600'
  })
}

function handleRateLimitError(errorData) {
  showToast({
    title: 'Too Many Requests',
    text: 'Please wait a moment before trying again',
    icon: 'clock',
    iconClasses: 'text-orange-600'
  })
}

function handleGenericError(errorData) {
  showToast({
    title: 'Error',
    text: errorData.message || 'An unexpected error occurred',
    icon: 'x',
    iconClasses: 'text-red-600'
  })
}
```

### Retry Logic with Exponential Backoff
```javascript
// src/utils/retryable.js
export async function retryableRequest(fn, options = {}) {
  const {
    maxRetries = 3,
    initialDelay = 1000,
    maxDelay = 10000,
    shouldRetry = (error) => error.response?.status >= 500
  } = options
  
  let lastError
  
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn()
    } catch (error) {
      lastError = error
      
      if (!shouldRetry(error) || attempt === maxRetries - 1) {
        throw error
      }
      
      const delay = Math.min(
        initialDelay * Math.pow(2, attempt),
        maxDelay
      )
      
      console.log(`Retry attempt ${attempt + 1} after ${delay}ms`)
      await new Promise(resolve => setTimeout(resolve, delay))
    }
  }
  
  throw lastError
}

// Usage
const data = await retryableRequest(
  () => resource.fetch(),
  {
    maxRetries: 3,
    shouldRetry: (error) => {
      // Retry on network errors or 5xx status codes
      return !error.response || error.response.status >= 500
    }
  }
)
```

## Form Validation Error Handling

### Form with Comprehensive Validation
```vue
<template>
  <form @submit.prevent="handleSubmit" class="space-y-4">
    <FormField
      v-model="form.email"
      label="Email"
      type="email"
      :error="errors.email"
      @blur="validateField('email')"
    />
    
    <FormField
      v-model="form.password"
      label="Password"
      type="password"
      :error="errors.password"
      @blur="validateField('password')"
    />
    
    <ErrorAlert v-if="submitError" :error="submitError" />
    
    <Button 
      type="submit"
      :loading="submitting"
      :disabled="!isValid"
    >
      Submit
    </Button>
  </form>
</template>

<script setup>
import { ref, computed, reactive } from 'vue'
import { createResource } from '@/utils/api'
import FormField from '@/components/FormField.vue'
import ErrorAlert from '@/components/ErrorAlert.vue'
import { Button } from 'frappe-ui'

const form = reactive({
  email: '',
  password: ''
})

const errors = reactive({
  email: null,
  password: null
})

const submitError = ref(null)
const submitting = ref(false)

const validators = {
  email: (value) => {
    if (!value) return 'Email is required'
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
      return 'Invalid email format'
    }
    return null
  },
  password: (value) => {
    if (!value) return 'Password is required'
    if (value.length < 8) return 'Password must be at least 8 characters'
    return null
  }
}

const isValid = computed(() => {
  return Object.keys(form).every(field => {
    return form[field] && !errors[field]
  })
})

function validateField(field) {
  errors[field] = validators[field](form[field])
}

function validateForm() {
  let valid = true
  Object.keys(form).forEach(field => {
    validateField(field)
    if (errors[field]) valid = false
  })
  return valid
}

const submitResource = createResource({
  url: 'custom_app.api.submit_form',
  onSuccess(data) {
    // Handle success
    console.log('Form submitted:', data)
  },
  onError(error) {
    submitError.value = error
    submitting.value = false
    
    // Handle field-specific errors from backend
    if (error.response?.data?.field_errors) {
      Object.assign(errors, error.response.data.field_errors)
    }
  }
})

async function handleSubmit() {
  submitError.value = null
  
  if (!validateForm()) {
    return
  }
  
  submitting.value = true
  
  try {
    await submitResource.submit(form)
  } finally {
    submitting.value = false
  }
}
</script>
```

### FormField Component with Error Display
```vue
<!-- src/components/FormField.vue -->
<template>
  <div class="form-field">
    <label :for="id" class="block text-sm font-medium text-gray-700 mb-1">
      {{ label }}
      <span v-if="required" class="text-red-500">*</span>
    </label>
    
    <input
      :id="id"
      :type="type"
      :value="modelValue"
      @input="$emit('update:modelValue', $event.target.value)"
      @blur="$emit('blur')"
      :class="inputClasses"
      :placeholder="placeholder"
      :disabled="disabled"
    />
    
    <transition name="slide-down">
      <p v-if="error" class="mt-1 text-sm text-red-600">
        {{ error }}
      </p>
    </transition>
    
    <p v-if="hint && !error" class="mt-1 text-sm text-gray-500">
      {{ hint }}
    </p>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: [String, Number],
  label: String,
  type: {
    type: String,
    default: 'text'
  },
  error: String,
  hint: String,
  placeholder: String,
  required: Boolean,
  disabled: Boolean
})

const emit = defineEmits(['update:modelValue', 'blur'])

const id = computed(() => {
  return `field-${Math.random().toString(36).substr(2, 9)}`
})

const inputClasses = computed(() => {
  const base = 'w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2'
  
  if (props.error) {
    return `${base} border-red-300 focus:ring-red-500 focus:border-red-500`
  }
  
  return `${base} border-gray-300 focus:ring-blue-500 focus:border-blue-500`
})
</script>

<style scoped>
.slide-down-enter-active,
.slide-down-leave-active {
  transition: all 0.2s ease;
}

.slide-down-enter-from,
.slide-down-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}
</style>
```

## Async Error Handling

### Async Composable with Error State
```javascript
// src/composables/useAsyncData.js
import { ref, watchEffect } from 'vue'

export function useAsyncData(asyncFn) {
  const data = ref(null)
  const error = ref(null)
  const loading = ref(false)
  
  async function execute(...args) {
    loading.value = true
    error.value = null
    
    try {
      data.value = await asyncFn(...args)
    } catch (err) {
      error.value = err
      console.error('Async operation failed:', err)
    } finally {
      loading.value = false
    }
  }
  
  function retry() {
    execute()
  }
  
  return {
    data,
    error,
    loading,
    execute,
    retry
  }
}

// Usage
const { data, error, loading, execute, retry } = useAsyncData(
  async (id) => {
    const response = await fetch(`/api/items/${id}`)
    if (!response.ok) throw new Error('Failed to fetch')
    return response.json()
  }
)

// Execute on mount
onMounted(() => execute(itemId))
```

## Error Recovery Strategies

### Offline Queue for Failed Requests
```javascript
// src/utils/offlineQueue.js
class OfflineQueue {
  constructor() {
    this.queue = []
    this.processing = false
    
    // Listen for online/offline events
    window.addEventListener('online', () => this.processQueue())
    window.addEventListener('offline', () => this.handleOffline())
  }
  
  add(request) {
    this.queue.push({
      ...request,
      timestamp: Date.now(),
      retries: 0
    })
    
    // Save to localStorage for persistence
    this.saveQueue()
    
    // Try to process immediately if online
    if (navigator.onLine) {
      this.processQueue()
    }
  }
  
  async processQueue() {
    if (this.processing || !navigator.onLine || this.queue.length === 0) {
      return
    }
    
    this.processing = true
    
    while (this.queue.length > 0) {
      const request = this.queue[0]
      
      try {
        await this.executeRequest(request)
        this.queue.shift() // Remove successful request
        this.saveQueue()
      } catch (error) {
        request.retries++
        
        if (request.retries >= 3) {
          // Max retries reached, remove from queue
          this.queue.shift()
          this.handleFailedRequest(request, error)
        } else {
          // Move to end of queue
          this.queue.push(this.queue.shift())
        }
        
        this.saveQueue()
        
        // Wait before next attempt
        await new Promise(resolve => setTimeout(resolve, 1000))
      }
    }
    
    this.processing = false
  }
  
  async executeRequest(request) {
    const response = await fetch(request.url, {
      method: request.method,
      headers: request.headers,
      body: request.body
    })
    
    if (!response.ok) {
      throw new Error(`Request failed: ${response.status}`)
    }
    
    return response.json()
  }
  
  handleFailedRequest(request, error) {
    console.error('Request permanently failed:', request, error)
    
    // Notify user
    showToast({
      title: 'Sync Failed',
      text: 'Some changes could not be synced',
      icon: 'alert-triangle',
      iconClasses: 'text-yellow-600'
    })
  }
  
  handleOffline() {
    showToast({
      title: 'Offline',
      text: 'Changes will be synced when connection is restored',
      icon: 'wifi-off',
      iconClasses: 'text-gray-600'
    })
  }
  
  saveQueue() {
    localStorage.setItem('offline_queue', JSON.stringify(this.queue))
  }
  
  loadQueue() {
    const saved = localStorage.getItem('offline_queue')
    if (saved) {
      this.queue = JSON.parse(saved)
    }
  }
}

export const offlineQueue = new OfflineQueue()
```

## Error Monitoring

### Frontend Error Tracking
```javascript
// src/utils/errorTracking.js
class ErrorTracker {
  constructor() {
    this.errors = []
    this.maxErrors = 100
  }
  
  track(error, context = {}) {
    const errorEntry = {
      timestamp: new Date().toISOString(),
      message: error.message,
      stack: error.stack,
      context,
      userAgent: navigator.userAgent,
      url: window.location.href,
      user: frappe?.session?.user
    }
    
    this.errors.push(errorEntry)
    
    // Keep only recent errors
    if (this.errors.length > this.maxErrors) {
      this.errors.shift()
    }
    
    // Send to backend periodically
    this.sendToBackend(errorEntry)
  }
  
  async sendToBackend(error) {
    try {
      await fetch('/api/method/custom_app.api.log_frontend_error', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Frappe-CSRF-Token': window.csrf_token
        },
        body: JSON.stringify(error)
      })
    } catch (err) {
      console.error('Failed to send error to backend:', err)
    }
  }
  
  getRecentErrors() {
    return this.errors.slice(-10)
  }
  
  clearErrors() {
    this.errors = []
  }
}

export const errorTracker = new ErrorTracker()
```

## Best Practices

1. **Always provide fallback UI** for error states
2. **Log errors appropriately** without exposing sensitive data
3. **Show user-friendly messages** instead of technical errors
4. **Implement retry mechanisms** for transient failures
5. **Use error boundaries** to prevent cascade failures
6. **Track errors** for monitoring and debugging
7. **Handle offline scenarios** gracefully
8. **Validate on both client and server** sides
9. **Provide clear recovery actions** for users
10. **Test error scenarios** thoroughly