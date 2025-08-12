# Complete Guide: Modern ERPNext App Development

This comprehensive guide demonstrates how to build modern ERPNext applications using the bmad-erpnext-v15 expansion pack, following the patterns established by Frappe CRM.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Project Setup](#project-setup)
3. [Backend Development](#backend-development)
4. [Frontend Development](#frontend-development)
5. [Real-time Features](#real-time-features)
6. [Testing](#testing)
7. [Security](#security)
8. [Deployment](#deployment)
9. [Troubleshooting](#troubleshooting)

## Quick Start

### Prerequisites

- ERPNext v15 installation
- Frappe Framework v15.75.0+
- Node.js 18+ and Yarn
- Python 3.8+

### 1. Create New App

```bash
# Navigate to your bench directory
cd ~/frappe-bench

# Create new app
bench new-app customer_portal

# Install app on site
bench --site mysite.local install-app customer_portal
```

### 2. Setup Frontend

```bash
# Navigate to app directory
cd apps/customer_portal

# Clone frappe-ui starter template
npx degit NagariaHussain/doppio_frappeui_starter frontend

# Install dependencies
cd frontend
yarn install

# Configure development environment
cp ../../../BMAD-METHOD/expansion-packs/bmad-erpnext-v15/templates/vue-spa-template.yaml ./template-reference.yaml
```

### 3. Basic Configuration

Add to `site_config.json` for development:
```json
{
  "ignore_csrf": 1,
  "developer_mode": 1
}
```

## Project Setup

### Directory Structure

Following the modern patterns, organize your project:

```
customer_portal/
├── customer_portal/
│   ├── __init__.py
│   ├── hooks.py
│   ├── api/                    # Backend APIs
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── customer.py
│   │   └── dashboard.py
│   ├── customer_management/    # Business module
│   │   └── doctype/
│   └── www/
│       └── app.py
├── frontend/                   # Vue SPA
│   ├── src/
│   ├── package.json
│   └── vite.config.js
└── tests/
```

### Configuration Files

#### hooks.py
```python
app_name = "customer_portal"
app_title = "Customer Portal"
app_publisher = "Your Company"

# Enable SPA routing
website_route_rules = [
    {"from_route": "/customer_portal/<path:app_path>", "to_route": "customer_portal"},
]

# Add to desk
add_to_apps_screen = [
    {
        "name": "customer_portal",
        "logo": "/assets/customer_portal/images/logo.svg",
        "title": "Customer Portal",
        "route": "/customer_portal",
        "has_permission": "customer_portal.api.auth.has_app_permission"
    }
]
```

## Backend Development

### 1. Create API Module

#### Basic API Structure (api/__init__.py)
```python
from . import auth
from . import customer
from . import dashboard
```

#### Authentication API (api/auth.py)
```python
import frappe
from frappe import _
from frappe.auth import LoginManager

@frappe.whitelist(allow_guest=True)
def get_logged_user():
    if frappe.session.user == "Guest":
        return {"success": False, "message": "Not logged in"}
    
    user_doc = frappe.get_doc("User", frappe.session.user)
    return {
        "success": True,
        "user": {
            "email": user_doc.email,
            "full_name": user_doc.full_name,
            "user_image": user_doc.user_image,
            "roles": frappe.get_roles(frappe.session.user),
        }
    }
```

### 2. Create DocTypes

#### Customer Profile DocType

Create via Frappe UI or programmatically:

```bash
# Use the template provided in example-app-template.yaml
bench --site mysite.local console
```

```python
# In console
import frappe
import json

# Load the JSON from template
doctype_json = {
    "doctype": "DocType",
    "name": "Customer Profile",
    "module": "Customer Management",
    "fields": [
        {
            "fieldname": "customer",
            "fieldtype": "Link",
            "options": "Customer",
            "label": "Customer",
            "reqd": 1
        },
        # ... other fields from template
    ]
}

doc = frappe.get_doc(doctype_json)
doc.insert()
```

### 3. Business Logic Implementation

#### Customer Profile Controller
```python
# customer_management/doctype/customer_profile/customer_profile.py
import frappe
from frappe.model.document import Document

class CustomerProfile(Document):
    def validate(self):
        self.validate_customer_link()
        self.sync_customer_data()
    
    def validate_customer_link(self):
        if not frappe.db.exists("Customer", self.customer):
            frappe.throw("Customer does not exist")
```

## Frontend Development

### 1. Basic Vue Setup

#### main.js
```javascript
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { FrappeUI, setConfig, frappeRequest } from 'frappe-ui'
import router from './router'
import App from './App.vue'
import './index.css'

// Configure frappe-ui
setConfig('resourceFetcher', frappeRequest)

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.use(FrappeUI)
app.mount('#app')
```

### 2. Store Management

#### Auth Store
```javascript
// stores/auth.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { createResource } from 'frappe-ui'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  
  const sessionResource = createResource({
    url: 'customer_portal.api.auth.get_logged_user',
    auto: false,
    onSuccess(data) {
      if (data.success) {
        user.value = data.user
      }
    }
  })
  
  const isLoggedIn = computed(() => !!user.value)
  
  async function init() {
    await sessionResource.fetch()
  }
  
  return { user, isLoggedIn, init }
})
```

### 3. Components

#### Customer List Component
```vue
<!-- pages/CustomerList.vue -->
<template>
  <div>
    <PageHeader title="Customers" />
    
    <div class="mt-6">
      <ListView
        :columns="columns"
        :rows="customers"
        :loading="customerStore.isLoading"
        @row-click="handleRowClick"
      />
    </div>
  </div>
</template>

<script setup>
import { onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ListView } from 'frappe-ui'
import { useCustomerStore } from '@/stores/customer'
import PageHeader from '@/components/PageHeader.vue'

const router = useRouter()
const customerStore = useCustomerStore()

const columns = [
  { label: 'Name', key: 'customer_name' },
  { label: 'Email', key: 'email_id' },
  { label: 'Phone', key: 'mobile_no' }
]

const customers = computed(() => customerStore.customerList)

function handleRowClick(row) {
  router.push(`/app/customer/${row.name}`)
}

onMounted(() => {
  customerStore.fetchCustomerList()
})
</script>
```

## Real-time Features

### 1. WebSocket Integration

#### Realtime Store
```javascript
// stores/realtime.js
import { defineStore } from 'pinia'
import { ref } from 'vue'
import { io } from 'socket.io-client'

export const useRealtimeStore = defineStore('realtime', () => {
  const socket = ref(null)
  const connected = ref(false)
  
  function connect() {
    socket.value = io({
      path: '/socket.io',
      transports: ['websocket', 'polling']
    })
    
    socket.value.on('connect', () => {
      connected.value = true
    })
    
    socket.value.on('doc_update', (data) => {
      // Handle document updates
      window.dispatchEvent(new CustomEvent('doc-update', { detail: data }))
    })
  }
  
  function subscribeToDocument(doctype, name) {
    if (socket.value?.connected) {
      socket.value.emit('doc_subscribe', { doctype, name })
    }
  }
  
  return { connected, connect, subscribeToDocument }
})
```

### 2. Backend Realtime Hooks

```python
# realtime_hooks.py
import frappe
from frappe.realtime import emit_via_redis

def emit_document_update(doc, method=None):
    if should_emit_realtime_event(doc.doctype):
        emit_via_redis(
            event="doc_update",
            message={
                "doctype": doc.doctype,
                "name": doc.name,
                "user": frappe.session.user
            },
            room=f"{doc.doctype}:{doc.name}"
        )
```

## Testing

### 1. Unit Testing Setup

#### Vitest Configuration
```javascript
// vitest.config.js
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./tests/setup.js']
  }
})
```

#### Component Tests
```javascript
// tests/components/CustomerList.test.js
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import CustomerList from '@/pages/CustomerList.vue'

describe('CustomerList', () => {
  it('renders customer list', () => {
    const wrapper = mount(CustomerList, {
      global: {
        stubs: ['PageHeader', 'ListView']
      }
    })
    
    expect(wrapper.exists()).toBe(true)
  })
})
```

### 2. E2E Testing

#### Playwright Configuration
```javascript
// playwright.config.js
import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './tests/e2e',
  use: {
    baseURL: 'http://localhost:8080',
  },
  webServer: {
    command: 'yarn dev',
    url: 'http://localhost:8080',
  },
})
```

#### E2E Tests
```javascript
// tests/e2e/customer-management.spec.js
import { test, expect } from '@playwright/test'

test('should display customer list', async ({ page }) => {
  await page.goto('/customer_portal/app/customers')
  
  await expect(page.locator('h1')).toContainText('Customers')
  await expect(page.locator('[data-testid="customer-list"]')).toBeVisible()
})
```

## Security

### 1. CSRF Protection

#### Frontend Implementation
```javascript
// utils/csrf.js
class CSRFTokenManager {
  async getToken() {
    if (!this.token || this.isTokenExpired()) {
      await this.refreshToken()
    }
    return this.token
  }
  
  async refreshToken() {
    const response = await fetch('/api/method/frappe.sessions.get_csrf_token', {
      method: 'POST',
      credentials: 'include'
    })
    const data = await response.json()
    this.setToken(data.message.csrf_token)
  }
}
```

### 2. API Security

#### Input Sanitization
```python
# api/utils.py
import frappe
from frappe.utils import validate_email_address

@frappe.whitelist()
def secure_api_endpoint(data):
    # Validate input
    data = frappe.parse_json(data)
    
    # Sanitize data
    for key, value in data.items():
        if isinstance(value, str):
            data[key] = frappe.utils.sanitize_html(value)
    
    # Process data
    return process_secure_data(data)
```

## Deployment

### 1. Production Build

```bash
# Build frontend
cd frontend
yarn build

# The build output goes to ../customer_portal/public/customer_portal/
```

### 2. Production Configuration

Remove development settings from `site_config.json`:
```json
{
  "ignore_csrf": 0,
  "developer_mode": 0
}
```

### 3. Nginx Configuration

```nginx
# Add to your site's nginx configuration
location /customer_portal/ {
    try_files $uri $uri/ @frappe;
}

location /assets/customer_portal/ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    try_files $uri =404;
}
```

## Troubleshooting

### Common Issues

#### 1. CSRF Token Errors
**Problem**: 403 Forbidden errors in production

**Solution**:
```javascript
// Ensure CSRF token is properly set
window.csrf_token = "{{ csrf_token }}";
```

#### 2. WebSocket Connection Issues
**Problem**: Socket.io not connecting

**Solution**:
```javascript
// Check WebSocket configuration
const socket = io({
  transports: ['websocket', 'polling'], // fallback to polling
  upgrade: true,
  timeout: 20000
})
```

#### 3. Permission Errors
**Problem**: API calls returning permission denied

**Solution**:
```python
# Check user permissions
@frappe.whitelist()
def check_permissions():
    user = frappe.session.user
    roles = frappe.get_roles(user)
    return {"user": user, "roles": roles}
```

#### 4. Build Issues
**Problem**: Frontend build failing

**Solution**:
```bash
# Clear cache and reinstall
rm -rf node_modules
rm yarn.lock
yarn install

# Check for conflicting dependencies
yarn why package-name
```

#### 5. Hot Reload Not Working
**Problem**: Changes not reflecting in development

**Solution**:
```javascript
// vite.config.js - ensure proper proxy setup
export default defineConfig({
  server: {
    host: '0.0.0.0',
    port: 8080,
    proxy: {
      '^/((?!frontend).)*$': {
        target: 'http://localhost:8000',
        ws: true
      }
    }
  }
})
```

### Development Tips

1. **Use Browser DevTools**: Monitor network requests and console errors
2. **Enable Frappe Developer Mode**: Shows detailed error messages
3. **Check Frappe Logs**: `tail -f sites/mysite.local/logs/web.log`
4. **Use Vue DevTools**: For debugging Vue components and stores
5. **Test API Endpoints**: Use tools like Postman or curl

### Performance Optimization

1. **Code Splitting**: Use dynamic imports for routes
2. **Lazy Loading**: Load components on demand
3. **Bundle Analysis**: Use `yarn build --analyze`
4. **Image Optimization**: Use WebP format and proper sizing
5. **Caching**: Implement proper HTTP caching headers

This guide provides a complete foundation for building modern ERPNext applications. Follow the patterns and templates provided in the bmad-erpnext-v15 expansion pack for best results.