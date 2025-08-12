# Complete Guide: Modern ERPNext App Development

This comprehensive guide demonstrates how to build modern ERPNext applications using the bmad-erpnext-v15 expansion pack, following the patterns established by Frappe CRM.

## Table of Contents

1. [Team Command Reference](#team-command-reference)
2. [Quick Start](#quick-start)
3. [Project Setup](#project-setup)
4. [Backend Development](#backend-development)
5. [Frontend Development](#frontend-development)
6. [Real-time Features](#real-time-features)
7. [Testing](#testing)
8. [Security](#security)
9. [Deployment](#deployment)
10. [Troubleshooting](#troubleshooting)

## Team Command Reference

### Quick Command Card - Copy & Paste Ready

#### 🚀 Most Common Commands by Workflow Stage

##### Stage 1: Product Requirements (Product Owner)
```bash
# Activate Product Owner Agent
/bmadErpNext:agent:erpnext-product-owner

# Inside agent, use these commands:
*create-epic                    # Create an epic for large features
*create-story                    # Create user story from requirements  
*shard-doc requirements.md docs/ # Break down large requirements
*execute-checklist-po            # Run PO validation checklist
*exit
```

##### Stage 2: Business Analysis
```bash
# Activate Business Analyst Agent
/bmadErpNext:agent:business-analyst

# Inside agent, use these commands:
*requirements-gather             # Start requirements elicitation
*process-map                     # Create process flow diagrams
*data-model                      # Design data relationships
*validate-requirements           # Check requirements completeness
*exit
```

##### Stage 3: Sprint Planning (Scrum Master)
```bash
# Activate Scrum Master Agent
/bmadErpNext:agent:erpnext-scrum-master

# Inside agent, use these commands:
*plan-sprint                     # Create sprint plan from stories
*estimate-story                  # Add story points
*assign-tasks                    # Distribute work to team
*track-progress                  # Monitor sprint progress
*exit
```

##### Stage 4: Development
```bash
# For DocType Development
/bmadErpNext:agent:doctype-designer
*create-doctype Customer_Profile # Create new DocType
*exit

# For API Development
/bmadErpNext:agent:api-developer
*create-api customer             # Create API endpoints
*exit

# For Vue Frontend
/bmadErpNext:agent:vue-frontend-architect
*setup-vue-spa                   # Initialize Vue SPA
*create-component CustomerList   # Create Vue component
*exit
```

##### Stage 5: Testing (QA Lead)
```bash
# Activate QA Lead Agent
/bmadErpNext:agent:erpnext-qa-lead

# Inside agent, use these commands:
*create-test-plan                # Generate test cases
*run-tests                       # Execute test suite
*validate-acceptance             # Check acceptance criteria
*report-defects                  # Document issues
*exit
```

##### Stage 6: Deployment
```bash
# Activate Bench Operator
/bmadErpNext:agent:bench-operator

# Inside agent, use these commands:
*install-app customer_portal    # Install app on site
*run-migrations                  # Apply database changes
*build-assets                    # Build frontend assets
*deploy-production              # Deploy to production
*exit
```

### Agent Directory - Who Does What?

#### 📋 Project Management Agents
| Agent | Primary Purpose | Key Commands | When to Use |
|-------|----------------|--------------|-------------|
| **erpnext-product-owner** | Requirements & Stories | `*create-epic`, `*create-story`, `*shard-doc` | Starting new features, creating user stories |
| **erpnext-scrum-master** | Sprint Planning | `*plan-sprint`, `*track-progress` | Planning iterations, managing tasks |
| **erpnext-qa-lead** | Quality Assurance | `*create-test-plan`, `*run-tests` | Testing features, validation |
| **main-dev-coordinator** | Team Coordination | `*coordinate-team`, `*status-report` | Managing multiple developers |

#### 🛠️ Development Agents
| Agent | Primary Purpose | Key Commands | When to Use |
|-------|----------------|--------------|-------------|
| **erpnext-architect** | System Design | `*design-architecture`, `*review-design` | Planning system architecture |
| **doctype-designer** | Data Models | `*create-doctype`, `*design-schema` | Creating ERPNext DocTypes |
| **api-developer** | Backend APIs | `*create-api`, `*whitelist-methods` | Building REST/RPC endpoints |
| **workflow-specialist** | Business Logic | `*create-workflow`, `*setup-automation` | Implementing workflows |

#### 🎨 Frontend Agents
| Agent | Primary Purpose | Key Commands | When to Use |
|-------|----------------|--------------|-------------|
| **vue-frontend-architect** | Vue Architecture | `*setup-vue-spa`, `*design-store` | Vue.js app structure |
| **vue-spa-architect** | SPA Development | `*create-router`, `*setup-auth` | Single-page applications |
| **frappe-ui-developer** | Frappe UI Components | `*create-list-view`, `*create-form` | Using Frappe UI library |
| **mobile-ui-specialist** | Mobile/PWA | `*implement-pwa`, `*optimize-mobile` | Mobile-first features |

#### 🔧 Specialized Agents
| Agent | Primary Purpose | Key Commands | When to Use |
|-------|----------------|--------------|-------------|
| **bench-operator** | DevOps & Deployment | `*install-app`, `*deploy-production` | Managing bench operations |
| **testing-specialist** | Test Automation | `*create-unit-tests`, `*e2e-tests` | Writing automated tests |
| **data-integration-expert** | Integrations | `*setup-webhook`, `*migrate-data` | External system integration |
| **frappe-compliance-validator** | Code Quality | `*validate-code`, `*check-patterns` | Ensuring Frappe best practices |

#### 🔄 Migration Agents
| Agent | Primary Purpose | Key Commands | When to Use |
|-------|----------------|--------------|-------------|
| **airtable-analyzer** | Airtable Migration | `*analyze-base`, `*map-schema` | Migrating from Airtable |
| **n8n-workflow-analyst** | n8n Conversion | `*convert-workflow`, `*map-triggers` | Converting n8n workflows |
| **workflow-converter** | Workflow Migration | `*import-workflow`, `*test-workflow` | General workflow migration |

### Common Workflow Commands

#### 🎯 Complete Feature Development Flow
```bash
# 1. Start with requirements
/bmadErpNext:agent:erpnext-product-owner
*create-story
*exit

# 2. Design the data model
/bmadErpNext:agent:doctype-designer
*create-doctype Customer_Profile
*exit

# 3. Build the API
/bmadErpNext:agent:api-developer
*create-api customer
*exit

# 4. Create the frontend
/bmadErpNext:agent:vue-frontend-architect
*setup-vue-spa
*create-component CustomerList
*exit

# 5. Test everything
/bmadErpNext:agent:testing-specialist
*create-unit-tests
*run-tests
*exit

# 6. Deploy
/bmadErpNext:agent:bench-operator
*install-app customer_portal
*deploy-production
*exit
```

#### 🔄 Migration Workflows
```bash
# Airtable to ERPNext Migration
/bmadErpNext:workflow:airtable-to-erpnext-migration

# n8n Workflow Conversion
/bmadErpNext:workflow:n8n-workflow-conversion

# Combined Migration (Airtable + n8n)
/bmadErpNext:workflow:combined-airtable-n8n-conversion
```

### 5 Essential Tips for Team Success

#### 1. 🎯 Choosing the Right Agent - Decision Tree

```
Need to create requirements? → erpnext-product-owner
Need to design data models? → doctype-designer
Need to build APIs? → api-developer
Need to create Vue frontend? → vue-frontend-architect
Need to test? → testing-specialist
Need to deploy? → bench-operator
Need to migrate from Airtable? → airtable-analyzer
Need to convert n8n workflows? → n8n-workflow-analyst
```

#### 2. 🚀 Quick Scenarios & Commands

**"I need to create a new customer portal"**
```bash
# Use the modern app team
/bmadErpNext:team:modern-app-team
```

**"I need to migrate from Airtable"**
```bash
# Use the airtable migration team
/bmadErpNext:team:airtable-migration-team
```

**"I need to build a Vue SPA"**
```bash
/bmadErpNext:task:create-vue-spa
```

**"I need to create a new DocType"**
```bash
/bmadErpNext:task:create-doctype
```

#### 3. 🎮 Command Shortcuts

Most agents support these universal commands:
- `*help` - Show available commands
- `*status` - Check current progress
- `*list` - List available resources
- `*exit` - Exit agent mode
- `*yolo` - Skip confirmations (use carefully!)

#### 4. 👥 Team Collaboration Patterns

**Sequential Pattern** (One agent at a time):
```bash
Product Owner → Business Analyst → Developer → Tester → Deployer
```

**Parallel Pattern** (Multiple agents working together):
```bash
# Activate a complete team
/bmadErpNext:team:development-team
```

**Expert Pattern** (Bring in specialist when needed):
```bash
# Start with general development
/bmadErpNext:agent:api-developer
*create-api customer
*exit

# Need Frappe compliance check
/bmadErpNext:agent:frappe-compliance-validator
*validate-code
*exit
```

#### 5. 🆘 Emergency Commands

**Something went wrong?**
```bash
# Check what's happening
/bmadErpNext:status

# View logs
/bmadErpNext:logs

# Reset agent state
/bmadErpNext:reset:agent

# Get help
/bmadErpNext:help
```

**Need to validate your work?**
```bash
# Run compliance check
/bmadErpNext:agent:frappe-compliance-validator
*validate-code
*exit
```

### Quick Start Examples

#### Example 1: Create a Customer Portal
```bash
# Step 1: Define requirements
/bmadErpNext:agent:erpnext-product-owner
*create-story
# Follow prompts to define: Customer Portal with login, dashboard, profile management
*exit

# Step 2: Create the app structure
/bmadErpNext:task:create-vue-spa --app-name customer_portal

# Step 3: Design the DocTypes
/bmadErpNext:agent:doctype-designer
*create-doctype Customer_Profile
*create-doctype Portal_Settings
*exit

# Step 4: Build the APIs
/bmadErpNext:task:create-api-module --module customer

# Step 5: Deploy
/bmadErpNext:agent:bench-operator
*install-app customer_portal
*exit
```

#### Example 2: Migrate from Airtable
```bash
# Step 1: Analyze Airtable base
/bmadErpNext:agent:airtable-analyzer
*analyze-base https://airtable.com/shrXXXXXXXX
*map-schema
*exit

# Step 2: Run migration workflow
/bmadErpNext:workflow:airtable-to-erpnext-migration \
  --base-id appXXXXXXXX \
  --api-key keyXXXXXXXX

# Step 3: Validate migration
/bmadErpNext:agent:testing-specialist
*validate-migration
*exit
```

#### Example 3: Build a Vue SPA with Frappe UI
```bash
# Step 1: Setup Vue SPA
/bmadErpNext:task:setup-frappe-ui --app-name my_app

# Step 2: Create components
/bmadErpNext:agent:frappe-ui-developer
*create-list-view Customers
*create-form CustomerForm
*create-dashboard MainDashboard
*exit

# Step 3: Add PWA support
/bmadErpNext:task:implement-pwa --app-name my_app

# Step 4: Test
/bmadErpNext:task:run-tests --app my_app
```

#### Example 4: Create a Complete DocType with API
```bash
# All-in-one command for DocType + API + Tests
/bmadErpNext:team:development-team
# The team will coordinate to:
# 1. Design the DocType
# 2. Create API endpoints
# 3. Add validation
# 4. Write tests
# 5. Generate documentation
```

### Task Quick Reference

| Task | Command | Purpose |
|------|---------|---------|
| **create-doctype** | `/bmadErpNext:task:create-doctype` | Create new DocType |
| **create-api-endpoint** | `/bmadErpNext:task:create-api-endpoint` | Add API endpoint |
| **create-vue-spa** | `/bmadErpNext:task:create-vue-spa` | Setup Vue SPA |
| **setup-frappe-ui** | `/bmadErpNext:task:setup-frappe-ui` | Install Frappe UI |
| **implement-pwa** | `/bmadErpNext:task:implement-pwa` | Add PWA support |
| **run-tests** | `/bmadErpNext:task:run-tests` | Execute tests |
| **run-migrations** | `/bmadErpNext:task:run-migrations` | Apply migrations |
| **build-frontend** | `/bmadErpNext:task:build-frontend` | Build assets |

### Team Quick Reference

| Team | Purpose | Key Agents |
|------|---------|------------|
| **development-team** | Full app development | Architect, DocType, API, Vue, Testing |
| **modern-app-team** | Vue SPA development | Vue architects, PWA, Mobile UI |
| **airtable-migration-team** | Airtable migration | Analyzer, Converter, Validator |
| **n8n-conversion-team** | n8n workflow conversion | Workflow analyst, Converter |
| **business-analysis-team** | Requirements & analysis | PO, BA, Architect |

---

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