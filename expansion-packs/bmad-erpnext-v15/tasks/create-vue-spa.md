# Task: Create Vue SPA for ERPNext App (Doppio Method)

## Purpose
Set up a modern Vue 3 Single Page Application using the doppio_frappeui_starter template with proper Frappe integration

## Prerequisites
- ERPNext app already created with `bench new-app`
- Node.js 18+ and Yarn installed
- Frappe bench running
- Understanding of Frappe's CSRF and routing system

## Input Requirements
```yaml
app_name: String # Name of the ERPNext app (snake_case)
app_title: String # Display title for the app
site_name: String # Site name (e.g., mysite.test)
features:
  - pwa: Boolean # Add PWA support (optional)
  - typescript: Boolean # Use TypeScript (optional)
```

## Step-by-Step Implementation

### 1. Navigate to Your App Directory
```bash
cd apps/{{app_name}}
```

### 2. Clone the Doppio Starter Template
```bash
# Clone the official doppio frappe-ui starter
npx degit NagariaHussain/doppio_frappeui_starter frontend
```

This creates a `frontend` directory with:
- Pre-configured Vite setup
- frappe-ui integration
- Proper proxy configuration
- Base component structure

### 3. Install Dependencies
```bash
cd frontend
yarn install
```

The doppio template comes with pre-configured dependencies:
- Vue 3.x
- frappe-ui (latest)
- Vue Router
- Vite
- TailwindCSS
- Essential plugins

### 4. Configure Development Environment

#### 4.1 Configure site_config.json for Development
In your site's `site_config.json` file, add:
```json
{
  "ignore_csrf": 1
}
```

⚠️ **Important**: This disables CSRF protection in development. Remove this in production!

#### 4.2 Customize Vite Configuration (if needed)
The doppio template comes with a pre-configured `vite.config.js`. You may need to customize:

```javascript
// vite.config.js - already configured by doppio, customize as needed
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 8080, // Doppio standard port
    proxy: {
      // Proxy all non-frontend requests to Frappe
      '^/((?!frontend).)*$': {
        target: 'http://{{site_name}}:8000',
        ws: true,
        router: function (req) {
          const host = req.headers.host
          if (host) {
            return `http://${host.replace(':8080', ':8000')}`
          }
          return 'http://{{site_name}}:8000'
        },
      },
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  base: '/frontend/', // Important: matches Frappe routing
  build: {
    outDir: '../{{app_name}}/public/frontend',
    emptyOutDir: true,
  }
})
```

### 5. Set Up Frappe Backend Integration

#### 5.1 Create Backend Web Page
Create `{{app_name}}/www/frontend.html`:
```html
{% extends "templates/web.html" %}

{% block title %}{{app_title}}{% endblock %}

{% block head_include %}
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>{{app_title}}</title>
    <script>
        // Make CSRF token available to Vue app
        window.csrf_token = "{{ csrf_token }}";
        window.frappe_site_name = "{{ frappe.local.site }}";
    </script>
{% endblock %}

{% block content %}
    <div id="app"></div>
    <script type="module" src="/assets/{{app_name}}/frontend/index.js"></script>
    <link rel="stylesheet" type="text/css" href="/assets/{{app_name}}/frontend/index.css">
{% endblock %}
```

#### 5.2 Configure App Routing in hooks.py
Add to your `{{app_name}}/hooks.py`:
```python
# Website routing
website_route_rules = [
    {"from_route": "/frontend/<path:app_path>", "to_route": "frontend"},
]

# Optional: Add to Frappe desk
add_to_apps_screen = [
    {
        "name": "{{app_name}}",
        "logo": "/assets/{{app_name}}/logo.svg",
        "title": "{{app_title}}",
        "route": "/frontend",
        "has_permission": "{{app_name}}.api.permission.has_app_permission"
    }
]
```

### 6. Customize the Doppio Template

The doppio template comes with basic components. Customize them for your app:

#### 6.1 Update Router Configuration
Edit `src/router.js` to match your app structure:
```javascript
import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('@/pages/Dashboard.vue')
  },
  {
    path: '/{{app_name}}-feature',
    name: '{{app_title}} Feature',
    component: () => import('@/pages/{{app_name|title}}Feature.vue')
  }
]

const router = createRouter({
  history: createWebHistory('/frontend/'),
  routes
})

export default router
```

#### 6.2 Customize Main Component
The doppio template includes a basic ping test. Replace `src/App.vue` with your app:
```vue
<template>
  <div id="app">
    <div v-if="isLoading" class="flex items-center justify-center h-screen">
      <div class="text-lg">Loading {{app_title}}...</div>
    </div>
    <router-view v-else />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const isLoading = ref(true)

onMounted(async () => {
  // Initialize your app here
  try {
    // Add any initialization logic
    await new Promise(resolve => setTimeout(resolve, 1000)) // Remove this delay
  } catch (error) {
    console.error('Failed to initialize app:', error)
  } finally {
    isLoading.value = false
  }
})
</script>
```

#### 6.3 Create App-Specific Pages
Create `src/pages/Dashboard.vue`:
```vue
<template>
  <div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold text-gray-900 mb-6">
      {{app_title}} Dashboard
    </h1>
    
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div class="bg-white p-6 rounded-lg shadow">
        <h2 class="text-xl font-semibold mb-4">Quick Stats</h2>
        <Button @click="testAPI" variant="solid">
          Test API Connection
        </Button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { Button, createResource } from 'frappe-ui'

// Test API connectivity
const apiTest = createResource({
  url: 'frappe.auth.get_logged_user',
  auto: false,
  onSuccess(data) {
    console.log('API Test successful:', data)
  },
  onError(error) {
    console.error('API Test failed:', error)
  }
})

function testAPI() {
  apiTest.fetch()
}
</script>
```

### 7. Development Workflow

#### 7.1 Start Development Servers
You need two terminals:

**Terminal 1 - Frappe Backend:**
```bash
cd ~/frappe-bench  # or your bench directory
bench start
```

**Terminal 2 - Vue Frontend:**
```bash
cd apps/{{app_name}}/frontend
yarn dev
```

#### 7.2 Access Your Application
- **Development**: http://{{site_name}}:8080/frontend
- **Production**: http://{{site_name}}:8000/frontend

#### 7.3 Development Features
- ✅ Hot reload enabled
- ✅ API calls proxied to Frappe (port 8000)
- ✅ CSRF protection disabled in development
- ✅ Source maps for debugging
- ✅ frappe-ui components ready to use

### 8. Build for Production

#### 8.1 Build the Frontend
```bash
cd apps/{{app_name}}/frontend
yarn build
```

This creates production files in `../{{app_name}}/public/frontend/`

#### 8.2 Production Configuration
1. **Remove development CSRF bypass** from site_config.json:
   ```json
   {
     "ignore_csrf": 1  // REMOVE THIS LINE
   }
   ```

2. **Ensure CSRF token** is available in your frontend.html template (already configured above)

3. **Test production build** locally:
   ```bash
   yarn preview
   ```

### 9. Testing & Verification

#### 9.1 Quick Test Checklist
- [ ] ✅ Doppio template cloned successfully
- [ ] ✅ Dependencies installed (`yarn install` completed)
- [ ] ✅ Development server starts (`yarn dev` works)
- [ ] ✅ Can access app at http://{{site_name}}:8080/frontend
- [ ] ✅ API calls work (test with the ping button)
- [ ] ✅ Build process works (`yarn build` succeeds)
- [ ] ✅ Backend routing configured in hooks.py
- [ ] ✅ Frontend.html template created

#### 9.2 Verify Doppio Features
The doppio template includes:
- ✅ Basic Vue 3 app with frappe-ui
- ✅ API connectivity test (ping button)
- ✅ Proper proxy configuration
- ✅ TailwindCSS integration
- ✅ Build system configured

## Troubleshooting Common Issues

### Issue 1: "Cannot GET /frontend"
**Problem**: Backend routing not configured
**Solution**: 
1. Add `website_route_rules` to hooks.py
2. Create frontend.html in www/ directory
3. Restart bench: `bench restart`

### Issue 2: CSRF Token Errors
**Problem**: CSRF protection interfering in development
**Solution**:
- Development: Add `"ignore_csrf": 1` to site_config.json
- Production: Remove this setting and ensure frontend.html includes csrf_token

### Issue 3: API Calls Failing
**Problem**: Proxy configuration or CORS issues
**Solution**:
1. Check vite.config.js proxy settings
2. Verify Frappe bench is running on port 8000
3. Check site_config.json for CORS settings if needed

### Issue 4: Yarn Dev Not Working
**Problem**: Port conflicts or dependency issues
**Solution**:
1. Check if port 8080 is available
2. Clear node_modules and reinstall: `rm -rf node_modules && yarn install`
3. Check Node.js version (requires 18+)

### Issue 5: Build Failures
**Problem**: Path or configuration issues
**Solution**:
1. Verify build output directory: `../{{app_name}}/public/frontend`
2. Check that parent directory exists
3. Ensure proper permissions on directories

## Production Deployment

### 1. Build and Deploy
```bash
# Build the frontend
cd apps/{{app_name}}/frontend
yarn build

# The files are automatically placed in {{app_name}}/public/frontend/
# Restart your production server
sudo supervisorctl restart all
```

### 2. Nginx Configuration (if needed)
```nginx
# Usually not needed as Frappe handles asset serving
location /assets/{{app_name}}/frontend/ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 3. Production Checklist
- [ ] Remove `"ignore_csrf": 1` from site_config.json
- [ ] Verify frontend.html includes CSRF token
- [ ] Test app functionality in production
- [ ] Check browser console for errors
- [ ] Verify asset loading (CSS/JS files)

## Next Steps & Extensions

### Immediate Next Steps
1. **Customize the UI** - Replace doppio's ping example with your app logic
2. **Add more pages** - Create additional Vue components/pages
3. **Integrate with ERPNext** - Connect to your app's DocTypes and APIs
4. **Add authentication** - Implement proper user login/logout flows

### Advanced Features
1. **PWA Support** - Add service worker and offline capabilities
2. **State Management** - Implement Pinia stores for complex state
3. **Testing** - Add unit tests with Vitest
4. **TypeScript** - Convert to TypeScript for better type safety
5. **API Integration** - Create custom API endpoints for your app
6. **Real-time Features** - Add WebSocket/Socket.io integration

### Best Practices
- Follow frappe-ui component patterns
- Use createResource for all API calls  
- Implement proper error handling
- Add loading states for better UX
- Follow Vue 3 Composition API patterns
- Keep components small and focused

## Doppio Template Benefits
- ✅ **Production Ready** - Proven template used by Frappe team
- ✅ **Best Practices** - Follows Frappe's recommended patterns
- ✅ **Maintained** - Actively maintained by Frappe
- ✅ **Documented** - Well-documented approach
- ✅ **Integrated** - Designed specifically for Frappe integration