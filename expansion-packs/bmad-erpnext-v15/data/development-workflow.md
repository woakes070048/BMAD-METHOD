# Modern ERPNext Development Workflow Guide

## Overview
This guide outlines the complete development workflow for building modern ERPNext applications with Vue.js frontend, following Frappe CRM patterns.

## Development Environment Setup

### 1. Initial Setup
```bash
# Clone your ERPNext app repository
cd ~/frappe-bench
bench get-app https://github.com/your-org/your-app.git

# Install the app on your site
bench --site your-site.local install-app your_app

# Setup development mode
bench set-config developer_mode 1
bench set-config disable_website_cache 1
```

### 2. Frontend Development Setup
```bash
# Navigate to your app's frontend directory
cd apps/your_app/frontend

# Install dependencies
yarn install

# Start Vite dev server (in a separate terminal)
yarn dev

# The frontend will be available at http://localhost:5173
```

### 3. Backend Development Setup
```bash
# Start Frappe development server
bench start

# In another terminal, watch for changes
bench watch
```

## Project Structure

### Recommended App Structure
```
your_app/
├── your_app/
│   ├── __init__.py
│   ├── hooks.py
│   ├── modules.txt
│   ├── patches.txt
│   ├── api/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── customer.py
│   │   └── utils.py
│   ├── your_module/
│   │   ├── doctype/
│   │   │   └── your_doctype/
│   │   │       ├── your_doctype.json
│   │   │       ├── your_doctype.py
│   │   │       ├── your_doctype.js
│   │   │       └── test_your_doctype.py
│   │   ├── page/
│   │   ├── report/
│   │   └── web_form/
│   ├── public/
│   │   └── dist/  # Frontend build output
│   └── www/
├── frontend/
│   ├── package.json
│   ├── vite.config.js
│   ├── tailwind.config.js
│   ├── index.html
│   └── src/
│       ├── main.js
│       ├── App.vue
│       ├── router/
│       ├── stores/
│       ├── components/
│       ├── pages/
│       ├── composables/
│       ├── utils/
│       └── assets/
├── tests/
├── requirements.txt
├── pyproject.toml
├── package.json
└── README.md
```

## Development Workflow

### 1. Feature Development Flow

#### Step 1: Create Feature Branch
```bash
# Create and checkout feature branch
git checkout -b feature/new-feature

# Or for bugfix
git checkout -b fix/bug-description
```

#### Step 2: Backend Development

**Create DocType:**
```bash
# Use bench command to create DocType
bench new-doctype "Module Name" "DocType Name"

# Or create via UI in Developer Mode
# Desk > DocType > New
```

**Create API Endpoint:**
```python
# your_app/api/endpoint.py
import frappe
from frappe import _

@frappe.whitelist()
def get_data(filters=None):
    """API endpoint with proper validation."""
    if filters:
        filters = frappe.parse_json(filters)
    
    # Validate permissions
    if not frappe.has_permission("DocType", "read"):
        frappe.throw(_("Insufficient permissions"))
    
    return frappe.get_list(
        "DocType",
        fields=["*"],
        filters=filters or {}
    )
```

#### Step 3: Frontend Development

**Create Vue Component:**
```vue
<!-- frontend/src/components/NewFeature.vue -->
<template>
  <div class="new-feature">
    <LoadingIndicator v-if="resource.loading" />
    <ErrorBanner v-else-if="resource.error" :error="resource.error" />
    <div v-else>
      <!-- Component content -->
    </div>
  </div>
</template>

<script setup>
import { createResource } from 'frappe-ui'

const resource = createResource({
  url: 'your_app.api.endpoint.get_data',
  auto: true
})
</script>
```

#### Step 4: Testing

**Write Unit Tests:**
```python
# tests/test_api.py
import frappe
import unittest

class TestAPI(unittest.TestCase):
    def test_get_data(self):
        from your_app.api.endpoint import get_data
        
        # Test with valid data
        result = get_data()
        self.assertIsInstance(result, list)
        
        # Test with filters
        result = get_data({"status": "Active"})
        self.assertTrue(all(r.get("status") == "Active" for r in result))
```

**Write Frontend Tests:**
```javascript
// frontend/tests/components/NewFeature.spec.js
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import NewFeature from '@/components/NewFeature.vue'

describe('NewFeature', () => {
  it('renders correctly', () => {
    const wrapper = mount(NewFeature)
    expect(wrapper.exists()).toBe(true)
  })
})
```

### 2. Hot Reload Development

#### Backend Hot Reload
```python
# hooks.py - Enable auto-reload for Python files
develop_mode = 1
auto_reload = True

# Watch for changes
# bench watch automatically reloads Python files in develop mode
```

#### Frontend Hot Reload with Vite
```javascript
// vite.config.js
export default defineConfig({
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true
      },
      '/socket.io': {
        target: 'http://localhost:9000',
        ws: true
      }
    }
  }
})
```

### 3. Database Migrations

#### Create Migration Patch
```python
# patches/v1_0/update_customer_fields.py
import frappe

def execute():
    """Add new field to Customer DocType."""
    # Check if field exists
    if not frappe.db.has_column("Customer", "new_field"):
        frappe.db.add_column("Customer", "new_field", "varchar(140)")
    
    # Update existing records
    frappe.db.sql("""
        UPDATE `tabCustomer`
        SET new_field = 'default_value'
        WHERE new_field IS NULL
    """)
    
    frappe.db.commit()
```

#### Register Patch
```python
# patches.txt
your_app.patches.v1_0.update_customer_fields
```

#### Run Migration
```bash
bench migrate
# Or for specific app
bench --site your-site.local migrate --app your_app
```

### 4. Building for Production

#### Frontend Build
```bash
cd frontend
yarn build

# Output will be in your_app/public/dist/
```

#### Backend Optimization
```bash
# Clear cache
bench clear-cache

# Build JS/CSS
bench build --app your_app

# Optimize database
bench --site your-site.local mariadb --optimize
```

## Development Tools & Scripts

### 1. Development Scripts

**package.json Scripts:**
```json
{
  "scripts": {
    "dev": "concurrently \"bench start\" \"cd frontend && yarn dev\"",
    "build": "cd frontend && yarn build",
    "test": "yarn test:backend && yarn test:frontend",
    "test:backend": "bench --site test_site run-tests --app your_app",
    "test:frontend": "cd frontend && yarn test",
    "lint": "yarn lint:py && yarn lint:js",
    "lint:py": "ruff check your_app/",
    "lint:js": "cd frontend && eslint src/",
    "format": "yarn format:py && yarn format:js",
    "format:py": "black your_app/",
    "format:js": "cd frontend && prettier --write src/"
  }
}
```

### 2. Git Hooks with Husky

**Setup Pre-commit Hooks:**
```bash
# Install husky
npm install -D husky

# Initialize husky
npx husky init

# Add pre-commit hook
echo "npm run lint" > .husky/pre-commit
echo "npm test" >> .husky/pre-commit
```

### 3. VS Code Configuration

**.vscode/settings.json:**
```json
{
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": false,
  "python.linting.flake8Enabled": true,
  "python.formatting.provider": "black",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": true
  },
  "vue.validation.template": true,
  "vetur.format.enable": true,
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "vue"
  ],
  "tailwindCSS.includeLanguages": {
    "vue": "html"
  }
}
```

**.vscode/launch.json:**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Frappe",
      "type": "python",
      "request": "launch",
      "program": "${workspaceFolder}/../../frappe-bench/apps/frappe/frappe/app.py",
      "args": ["--site", "your-site.local", "--port", "8000"],
      "console": "integratedTerminal",
      "justMyCode": false
    },
    {
      "name": "Debug Vue",
      "type": "chrome",
      "request": "launch",
      "url": "http://localhost:5173",
      "webRoot": "${workspaceFolder}/frontend/src",
      "sourceMapPathOverrides": {
        "webpack:///./src/*": "${webRoot}/*"
      }
    }
  ]
}
```

## Debugging

### Backend Debugging

**Using frappe.throw and frappe.log_error:**
```python
import frappe

def debug_function():
    # Debug print (appears in console)
    print("Debug:", some_variable)
    
    # Log to Error Log DocType
    frappe.log_error(
        message=frappe.get_traceback(),
        title="Debug Error"
    )
    
    # Use pdb for breakpoints
    import pdb; pdb.set_trace()
    
    # Or use frappe.errprint
    frappe.errprint(f"Variable value: {some_variable}")
```

**Using Bench Console:**
```bash
bench --site your-site.local console

# In console
frappe.get_doc("Customer", "CUST-0001")
frappe.db.get_list("Customer", filters={"status": "Active"})
```

### Frontend Debugging

**Vue DevTools:**
```javascript
// Enable Vue DevTools in development
if (import.meta.env.DEV) {
  app.config.devtools = true
}
```

**Browser Console Debugging:**
```javascript
// Add debug logs
console.log('Component mounted:', { props, state })

// Use Vue DevTools
// $vm0 in console refers to selected component

// Conditional breakpoints
if (someCondition) {
  debugger
}
```

## Performance Optimization

### 1. Backend Optimization

**Query Optimization:**
```python
# Use get_all with specific fields instead of get_list
data = frappe.get_all(
    "Customer",
    fields=["name", "customer_name"],  # Only fetch needed fields
    filters={"status": "Active"},
    limit=100
)

# Use db.sql for complex queries
data = frappe.db.sql("""
    SELECT c.name, c.customer_name, COUNT(so.name) as order_count
    FROM `tabCustomer` c
    LEFT JOIN `tabSales Order` so ON so.customer = c.name
    WHERE c.status = 'Active'
    GROUP BY c.name
    LIMIT 100
""", as_dict=True)

# Add indexes for frequently queried fields
# In DocType definition, set "Search Index" for fields
```

### 2. Frontend Optimization

**Code Splitting:**
```javascript
// router/index.js
const routes = [
  {
    path: '/dashboard',
    component: () => import('@/pages/Dashboard.vue')  // Lazy load
  }
]
```

**Component Lazy Loading:**
```vue
<script setup>
import { defineAsyncComponent } from 'vue'

const HeavyComponent = defineAsyncComponent(() =>
  import('@/components/HeavyComponent.vue')
)
</script>
```

**Resource Caching:**
```javascript
const resource = createResource({
  url: 'api.endpoint',
  cache: 'resource-key',  // Cache results
  auto: true
})
```

## Deployment

### 1. Pre-deployment Checklist

- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] Database migrations prepared
- [ ] Frontend built for production
- [ ] Environment variables configured
- [ ] SSL certificates ready
- [ ] Backup current system
- [ ] Monitoring setup

### 2. Deployment Commands

```bash
# Pull latest changes
cd ~/frappe-bench
git pull origin main

# Install/update app
bench get-app https://github.com/your-org/your-app.git --branch main
bench --site your-site.com install-app your_app

# Run migrations
bench --site your-site.com migrate

# Build assets
bench build --app your_app

# Clear cache
bench clear-cache

# Restart services
bench restart

# Or use supervisor
sudo supervisorctl restart all
```

### 3. Production Configuration

**nginx Configuration:**
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /socket.io {
        proxy_pass http://localhost:9000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    location /assets {
        alias /home/frappe/frappe-bench/sites/assets;
        expires 30d;
    }
}
```

## Continuous Integration/Deployment

### GitHub Actions Workflow

**.github/workflows/ci.yml:**
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      mariadb:
        image: mariadb:10.6
        env:
          MYSQL_ROOT_PASSWORD: root
        options: >-
          --health-cmd="mysqladmin ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5
        ports:
          - 3306:3306
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install Bench
        run: |
          pip install frappe-bench
          bench init test-bench --skip-redis-config-generation
          cd test-bench
          bench get-app ${{ github.workspace }}
      
      - name: Run Backend Tests
        run: |
          cd test-bench
          bench --site test_site run-tests --app your_app
      
      - name: Run Frontend Tests
        run: |
          cd frontend
          yarn install
          yarn test
      
      - name: Build Frontend
        run: |
          cd frontend
          yarn build

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Deploy to Production
        uses: appleboy/ssh-action@v0.1.5
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd ~/frappe-bench
            bench get-app https://github.com/${{ github.repository }}.git --branch main
            bench --site production.com migrate
            bench build --app your_app
            bench restart
```

## Troubleshooting Common Issues

### 1. Frontend Not Loading
```bash
# Check if Vite server is running
ps aux | grep vite

# Check nginx proxy configuration
sudo nginx -t

# Check browser console for errors
# Check network tab for failed requests
```

### 2. API Errors
```python
# Check Error Log DocType in Desk
# Or check logs
bench --site your-site.local show-error-log

# Enable debug mode
bench --site your-site.local set-config debug 1
```

### 3. Build Failures
```bash
# Clear node_modules and reinstall
rm -rf frontend/node_modules
cd frontend && yarn install

# Clear bench cache
bench clear-cache
bench build --force
```

## Best Practices

1. **Use version control** for all code changes
2. **Write tests** for new features
3. **Document APIs** and complex logic
4. **Follow naming conventions** consistently
5. **Use environment variables** for configuration
6. **Implement proper error handling**
7. **Optimize queries** and API calls
8. **Use caching** strategically
9. **Monitor performance** in production
10. **Regular security audits**