# Modern ERPNext App Architecture Guide

## Overview
Architecture patterns for building modern ERPNext v16 applications with **NATIVE Vue 3 integration** (NO /frontend/ directory), following Frappe team's best practices.

## 🚨 CRITICAL: ERPNext v16 Native Vue Integration

**NO SEPARATE FRONTEND** - ERPNext v16 has native Vue 3 support built-in!

### ❌ OLD PATTERN (Don't use)
```
app_name/
├── backend/               # ❌ Remove
├── frontend/              # ❌ Remove - No longer needed!
│   ├── src/
│   ├── vite.config.js     # ❌ Remove
│   └── package.json       # ❌ Remove
```

### ✅ NEW PATTERN (Use this)
```
app_name/                  # Created by bench new-app
├── app_name/              # Main app package
│   ├── public/            # Static assets integrated with Frappe
│   │   └── js/           # Vue components + bundle entries
│   ├── [module]/         # Business modules
│   │   ├── doctype/      # Business entities
│   │   ├── page/         # Custom pages
│   │   └── api/          # API endpoints
│   └── hooks.py          # App configuration
├── requirements.txt
└── setup.py
```

## Core Architecture Principles

### 1. Native Integration
- **Backend**: Python/Frappe for business logic, data persistence
- **Frontend**: Vue 3 natively integrated in Frappe
- **API Layer**: Whitelisted methods for secure communication
- **Real-time**: Socket.io for live updates
- **Build**: Frappe's esbuild pipeline (NO separate build)

## Frontend Architecture

### Component Hierarchy (Native Vue)
```
app_name/public/js/
├── dashboard.bundle.js              # Feature entry point
├── dashboard/                       # Feature components
│   ├── Dashboard.vue               # Main component
│   ├── components/                 # Sub-components
│   │   ├── MetricCard.vue
│   │   ├── ChartWidget.vue
│   │   └── ActivityFeed.vue
│   ├── stores/                     # Pinia stores
│   │   └── dashboard.js
│   └── utils/                      # Feature utilities
└── customer_portal.bundle.js        # Another feature
```

### State Management Pattern
```javascript
// Pinia Store Structure
stores/
├── auth.js         // Authentication state
├── app.js         // Global app state
├── users.js       // User management
├── documents.js   // Document cache
└── realtime.js    // WebSocket state

// Store Pattern
export const useDocumentStore = defineStore('documents', () => {
  // State
  const documents = ref(new Map())
  const loading = ref(false)
  
  // Getters
  const getDocument = computed(() => (doctype, name) => {
    return documents.value.get(`${doctype}:${name}`)
  })
  
  // Actions
  async function fetchDocument(doctype, name) {
    loading.value = true
    try {
      const doc = await api.getDocument(doctype, name)
      documents.value.set(`${doctype}:${name}`, doc)
      return doc
    } finally {
      loading.value = false
    }
  }
  
  return { documents, loading, getDocument, fetchDocument }
})
```

### Routing Strategy
```javascript
// Dynamic route loading with guards
const routes = [
  {
    path: '/app',
    component: () => import('@/layouts/AppLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/pages/Dashboard.vue'),
        meta: { title: 'Dashboard' }
      },
      {
        path: ':doctype',
        name: 'ListView',
        component: () => import('@/pages/ListView.vue'),
        props: true
      },
      {
        path: ':doctype/:name',
        name: 'DetailView',
        component: () => import('@/pages/DetailView.vue'),
        props: true,
        meta: { requiresPermission: 'read' }
      }
    ]
  }
]
```

## Backend Architecture

### API Module Organization
```python
# api/__init__.py
from . import auth
from . import doc
from . import session
from . import views

# api/doc.py
import frappe
from frappe import _

@frappe.whitelist()
def get_list(doctype, fields=None, filters=None, limit=20, offset=0):
    """Generic list endpoint with permissions"""
    if not frappe.has_permission(doctype, "read"):
        frappe.throw(_("No permission"))
    
    return {
        "data": frappe.get_all(
            doctype,
            fields=frappe.parse_json(fields) or ["*"],
            filters=frappe.parse_json(filters) or {},
            limit=int(limit),
            start=int(offset)
        ),
        "total": frappe.db.count(doctype, filters)
    }
```

### DocType Naming Convention
```python
# Use prefixes for namespace management
# Examples from Frappe apps:
# - HD_ for Helpdesk (HD_Ticket, HD_Agent)
# - CRM_ for CRM (CRM_Lead, CRM_Deal)

class PrefixedDocType:
    """
    app_prefix_entity_name
    Examples:
    - APP_Customer_Settings
    - APP_Invoice_Template
    """
    pass
```

### Hooks Configuration
```python
# hooks.py
app_name = "modern_app"
app_title = "Modern App"

# Single Page App routing
website_route_rules = [
    {"from_route": "/app/<path:app_path>", "to_route": "app"},
]

# Add to apps screen
add_to_apps_screen = [
    {
        "name": "modern_app",
        "logo": "/assets/modern_app/logo.svg",
        "title": "Modern App",
        "route": "/app",
        "has_permission": "modern_app.api.permission.has_app_permission"
    }
]

# Document events
doc_events = {
    "User": {
        "after_insert": "modern_app.api.user.after_user_insert"
    }
}

# Scheduled tasks
scheduler_events = {
    "daily": ["modern_app.tasks.daily_cleanup"],
    "hourly": ["modern_app.tasks.sync_data"]
}
```

## Data Flow Patterns

### 1. List View Pattern
```
User Action → Vue Component → Pinia Action → API Call → Backend → Database
     ↑                                                               ↓
     ←─────────── Update UI ←── Update Store ←── Response ←────────
```

### 2. Real-time Update Pattern
```
Database Change → Document Hook → Publish Event → Socket.io → Vue Component
                                                       ↓
                                                  Update Store
                                                       ↓
                                                   Update UI
```

### 3. Form Submission Pattern
```javascript
// Frontend
async function submitForm(data) {
  try {
    startLoading()
    validateLocally(data)
    const response = await api.createDocument(doctype, data)
    showSuccess('Document created')
    router.push(`/${doctype}/${response.name}`)
  } catch (error) {
    handleError(error)
  } finally {
    stopLoading()
  }
}

// Backend
@frappe.whitelist()
def create_document(doctype, data):
    doc = frappe.get_doc({
        "doctype": doctype,
        **frappe.parse_json(data)
    })
    doc.insert()
    return doc.as_dict()
```

## Integration Patterns

### 1. frappe-ui Resource Pattern
```javascript
// Using native Frappe API calls
async function loadContacts() {
  try {
    const response = await frappe.call({
      method: 'frappe.client.get_list',
      args: {
        doctype: 'Contact',
        fields: ['name', 'email', 'phone'],
        filters: { status: 'Active' }
      }
    });
    
    const contacts = response.message.map(formatContact);
    console.log('Contacts loaded:', contacts.length);
    return contacts;
    
  } catch (error) {
    frappe.show_alert({
      message: __('Failed to load contacts'),
      indicator: 'red'
    });
  }
}

// In component
onMounted(() => loadContacts())
```

### 2. WebSocket Integration
```javascript
// Socket.io setup
import { io } from 'socket.io-client'

const socket = io({
  path: '/socket.io',
  transports: ['websocket', 'polling']
})

// Listen for real-time updates
socket.on('doc_update', (data) => {
  if (data.doctype === 'Contact') {
    store.updateContact(data.doc)
  }
})

// Emit events
socket.emit('doc_subscribe', {
  doctype: 'Contact',
  name: 'CONT-001'
})
```

### 3. File Upload Pattern
```javascript
// Frontend - Use Frappe's upload_file
async function handleFileSelect(event) {
  const file = event.target.files[0]
  const formData = new FormData()
  formData.append('file', file)
  formData.append('doctype', 'Contact')
  formData.append('docname', 'CONT-001')
  
  try {
    const response = await frappe.call({
      method: 'upload_file',
      args: formData,
      type: 'POST'
    });
    
    console.log('File uploaded:', response.message.file_url);
    frappe.show_alert({
      message: __('File uploaded successfully'),
      indicator: 'green'
    });
    
  } catch (error) {
    frappe.show_alert({
      message: __('Upload failed: {0}', [error.message]),
      indicator: 'red'
    });
  }
}
```

## Security Patterns

### API Security Layers
1. **Authentication**: Session/Token validation
2. **Authorization**: Permission checks
3. **Validation**: Input sanitization
4. **Rate Limiting**: Request throttling
5. **Audit**: Logging and monitoring

### Frontend Security
```javascript
// Sanitize user input
import DOMPurify from 'dompurify'

function sanitizeHTML(dirty) {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
    ALLOWED_ATTR: ['href']
  })
}

// Secure API calls
async function secureAPICall(method, args) {
  const csrfToken = document.querySelector('meta[name="csrf-token"]').content
  
  return fetch('/api/method/' + method, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Frappe-CSRF-Token': csrfToken
    },
    credentials: 'include',
    body: JSON.stringify(args)
  })
}
```

## Performance Optimization

### Frontend Optimizations
1. **Code Splitting**: Dynamic imports for routes
2. **Lazy Loading**: Components loaded on demand
3. **Virtual Scrolling**: For large lists
4. **Image Optimization**: WebP, lazy loading
5. **Bundle Optimization**: Tree shaking, minification

### Backend Optimizations
1. **Query Optimization**: Indexed fields, projections
2. **Caching**: Redis caching for frequent queries
3. **Batch Operations**: Bulk updates/inserts
4. **Async Processing**: Background jobs for heavy tasks
5. **CDN**: Static assets served from CDN

### Caching Strategy
```python
# Backend caching
@frappe.whitelist()
@frappe.cache_manager.memoize()
def get_cached_data(key):
    # Expensive operation
    return process_data(key)

# Frontend caching
const cache = new Map()

async function getCachedDocument(doctype, name) {
  const key = `${doctype}:${name}`
  
  if (cache.has(key)) {
    const cached = cache.get(key)
    if (Date.now() - cached.timestamp < 60000) { // 1 minute
      return cached.data
    }
  }
  
  const data = await fetchDocument(doctype, name)
  cache.set(key, { data, timestamp: Date.now() })
  return data
}
```

## Testing Strategy

### Frontend Testing
```javascript
// Component test
import { mount } from '@vue/test-utils'
import ContactForm from '@/components/ContactForm.vue'

test('validates email field', async () => {
  const wrapper = mount(ContactForm)
  
  await wrapper.find('input[type="email"]').setValue('invalid')
  await wrapper.find('form').trigger('submit')
  
  expect(wrapper.find('.error').text()).toBe('Invalid email')
})
```

### Backend Testing
```python
# API test
import frappe
import unittest

class TestAPI(unittest.TestCase):
    def test_get_list_with_permissions(self):
        # Setup
        frappe.set_user("test@example.com")
        
        # Test
        from app.api.doc import get_list
        result = get_list("Contact", limit=10)
        
        # Assert
        self.assertIsInstance(result, dict)
        self.assertIn("data", result)
        self.assertLessEqual(len(result["data"]), 10)
```

## Deployment Architecture

### Production Setup
```
                    ┌─────────────┐
                    │   Nginx     │
                    │  (Reverse   │
                    │   Proxy)    │
                    └──────┬──────┘
                           │
                ┌──────────┴──────────┐
                │                     │
         ┌──────▼──────┐      ┌──────▼──────┐
         │   Static    │      │   Frappe    │
         │   Assets    │      │   Server    │
         │   (CDN)     │      │  (Gunicorn) │
         └─────────────┘      └──────┬──────┘
                                     │
                              ┌──────▼──────┐
                              │   Redis     │
                              │   Cache     │
                              └──────┬──────┘
                                     │
                              ┌──────▼──────┐
                              │   MariaDB   │
                              │  Database   │
                              └─────────────┘
```

## Best Practices Summary

### Do's ✅
- Use Composition API with `<script setup>`
- Implement proper error boundaries
- Use frappe-ui components consistently
- Follow Frappe naming conventions
- Implement proper loading states
- Use TypeScript for better type safety
- Write tests for critical paths
- Document API endpoints
- Use environment variables
- Implement proper logging

### Don'ts ❌
- Don't expose sensitive data in frontend
- Don't skip input validation
- Don't ignore error handling
- Don't use deprecated APIs
- Don't hardcode configuration
- Don't skip permission checks
- Don't use synchronous operations for heavy tasks
- Don't ignore performance metrics
- Don't bypass Frappe's security features
- Don't reinvent built-in functionality