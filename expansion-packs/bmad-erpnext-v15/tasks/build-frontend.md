# Build Frontend

## Overview
This task guides you through building and optimizing the frontend assets for your ERPNext application, using the doppio pattern with Vue 3, Vite, and frappe-ui components.

## Prerequisites

### Required Knowledge
- [ ] Understanding of Vue 3 and Vite build system
- [ ] Basic knowledge of JavaScript module bundling
- [ ] Familiarity with frappe-ui components
- [ ] Understanding of the doppio frontend pattern

### Development Environment
- [ ] Node.js 16+ and npm are installed
- [ ] Frontend is set up using doppio_frappeui_starter
- [ ] Vite configuration is properly configured
- [ ] All frontend dependencies are installed

## Step-by-Step Process

### Step 1: Verify Frontend Setup

#### Check Doppio Configuration
```bash
# Navigate to your app frontend directory
cd apps/your_app/frontend

# Verify doppio structure exists
ls -la
# Should show: src/, package.json, vite.config.js, etc.

# Check if installed correctly
cat package.json | grep "name"
# Should show the correct package name
```

#### Verify Dependencies
```bash
# Check package.json dependencies
cat package.json

# Install/update dependencies if needed
npm install

# Check for any vulnerabilities
npm audit

# Fix vulnerabilities if found
npm audit fix
```

### Step 2: Configure Build Environment

#### Optimize Vite Configuration
```javascript
// vite.config.js - Enhanced configuration
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  
  // Build optimizations
  build: {
    target: 'es2015',
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: process.env.NODE_ENV === 'development',
    
    // Code splitting for better caching
    rollupOptions: {
      output: {
        manualChunks: {
          // Vendor chunk for third-party libraries
          vendor: ['vue', 'vue-router'],
          
          // Frappe UI components chunk
          'frappe-ui': ['frappe-ui'],
          
          // Utils chunk for utilities
          utils: [
            './src/utils/currency.js',
            './src/utils/validators.js',
            './src/utils/index.js'
          ]
        },
        
        // Consistent chunk naming
        chunkFileNames: 'assets/js/[name]-[hash].js',
        entryFileNames: 'assets/js/[name]-[hash].js',
        assetFileNames: ({ name }) => {
          if (/\.(css)$/.test(name)) {
            return 'assets/css/[name]-[hash][extname]'
          }
          if (/\.(png|jpe?g|svg|gif|ico|webp)$/.test(name)) {
            return 'assets/images/[name]-[hash][extname]'
          }
          return 'assets/[name]-[hash][extname]'
        }
      }
    },
    
    // Minimize bundle size
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: process.env.NODE_ENV === 'production',
        drop_debugger: true
      }
    },
    
    // Chunk size warning limit
    chunkSizeWarningLimit: 1000
  },
  
  // Development server configuration
  server: {
    port: 8080,
    host: true,
    
    // Proxy configuration for ERPNext integration
    proxy: {
      '^/(app|api|assets|files)': {
        target: 'http://{{ site_name }}:8000',
        changeOrigin: true,
        headers: {
          Host: '{{ site_name }}',
          'X-Frappe-Site-Name': '{{ site_name }}'
        }
      }
    }
  },
  
  // Path resolution
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
      '@components': path.resolve(__dirname, 'src/components'),
      '@utils': path.resolve(__dirname, 'src/utils'),
      '@stores': path.resolve(__dirname, 'src/stores'),
      '@composables': path.resolve(__dirname, 'src/composables')
    }
  },
  
  // CSS preprocessing
  css: {
    preprocessorOptions: {
      scss: {
        additionalData: `@import "@/styles/variables.scss";`
      }
    }
  },
  
  // Define global constants
  define: {
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version),
    __BUILD_DATE__: JSON.stringify(new Date().toISOString())
  }
})
```

#### Create Environment Configuration
```javascript
// .env.development
VITE_APP_TITLE=Your App Development
VITE_API_BASE_URL=http://localhost:8000
VITE_DEBUG_MODE=true

// .env.production  
VITE_APP_TITLE=Your App
VITE_API_BASE_URL=
VITE_DEBUG_MODE=false
```

### Step 3: Optimize Dependencies and Imports

#### Analyze Bundle Size
```bash
# Install bundle analyzer
npm install --save-dev rollup-plugin-visualizer

# Add to package.json scripts
npm run build:analyze
```

```javascript
// Add to vite.config.js plugins array for analysis
import { visualizer } from 'rollup-plugin-visualizer'

export default defineConfig({
  plugins: [
    vue(),
    
    // Bundle analyzer (only in production)
    process.env.ANALYZE && visualizer({
      filename: 'dist/stats.html',
      open: true,
      gzipSize: true,
      brotliSize: true
    })
  ]
})
```

#### Optimize Imports
```javascript
// src/main.js - Optimized main entry point
import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'

// Import only needed frappe-ui components
import {
  Button,
  Card,
  Dialog,
  FormControl,
  ListView,
  Pagination,
  Avatar,
  Badge,
  Dropdown,
  toast,
  createResource
} from 'frappe-ui'

import App from './App.vue'
import routes from './router/routes'

// Create router
const router = createRouter({
  history: createWebHistory(),
  routes,
  
  // Scroll behavior for better UX
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    } else if (to.hash) {
      return { el: to.hash, behavior: 'smooth' }
    } else {
      return { top: 0 }
    }
  }
})

// Create app
const app = createApp(App)

// Use router
app.use(router)

// Register global frappe-ui components
app.component('Button', Button)
app.component('Card', Card)
app.component('Dialog', Dialog)
app.component('FormControl', FormControl)
app.component('ListView', ListView)
app.component('Pagination', Pagination)
app.component('Avatar', Avatar)
app.component('Badge', Badge)
app.component('Dropdown', Dropdown)

// Global properties
app.config.globalProperties.$toast = toast
app.config.globalProperties.$resources = createResource

// Error handling
app.config.errorHandler = (err, instance, info) => {
  console.error('Vue Error:', err, info)
  
  if (process.env.NODE_ENV === 'production') {
    // Send to error reporting service
    // reportError(err, { context: info })
  }
}

// Mount app
app.mount('#app')
```

### Step 4: Implement Code Splitting and Lazy Loading

#### Route-Based Code Splitting
```javascript
// src/router/routes.js - Lazy loaded routes
export default [
  {
    path: '/',
    name: 'Dashboard',
    component: () => import('@/pages/Dashboard.vue'),
    meta: { title: 'Dashboard' }
  },
  {
    path: '/customers',
    name: 'Customers',
    component: () => import('@/pages/customers/CustomerList.vue'),
    meta: { title: 'Customers' }
  },
  {
    path: '/customers/new',
    name: 'NewCustomer',
    component: () => import('@/pages/customers/NewCustomer.vue'),
    meta: { title: 'New Customer' }
  },
  {
    path: '/customers/:id',
    name: 'CustomerDetail',
    component: () => import('@/pages/customers/CustomerDetail.vue'),
    props: true,
    meta: { title: 'Customer Details' }
  },
  
  // Admin routes (lazy loaded as separate chunk)
  {
    path: '/admin',
    component: () => import('@/layouts/AdminLayout.vue'),
    children: [
      {
        path: 'settings',
        component: () => import('@/pages/admin/Settings.vue')
      },
      {
        path: 'users',
        component: () => import('@/pages/admin/Users.vue')
      }
    ]
  },
  
  // Error pages
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('@/pages/NotFound.vue')
  }
]
```

#### Component-Level Code Splitting
```vue
<!-- Example of lazy loaded components -->
<template>
  <div class="dashboard">
    <!-- Always loaded components -->
    <DashboardHeader />
    
    <!-- Lazy loaded components -->
    <Suspense>
      <template #default>
        <AsyncSalesChart v-if="showSalesChart" />
      </template>
      <template #fallback>
        <div class="loading">Loading chart...</div>
      </template>
    </Suspense>
    
    <Suspense>
      <template #default>
        <AsyncRecentOrders v-if="showRecentOrders" />
      </template>
      <template #fallback>
        <div class="loading">Loading orders...</div>
      </template>
    </Suspense>
  </div>
</template>

<script setup>
import { ref, defineAsyncComponent } from 'vue'
import DashboardHeader from '@/components/DashboardHeader.vue'

// Async components with loading states
const AsyncSalesChart = defineAsyncComponent({
  loader: () => import('@/components/charts/SalesChart.vue'),
  loadingComponent: () => import('@/components/LoadingSpinner.vue'),
  errorComponent: () => import('@/components/ErrorMessage.vue'),
  delay: 200,
  timeout: 3000
})

const AsyncRecentOrders = defineAsyncComponent(
  () => import('@/components/RecentOrders.vue')
)

const showSalesChart = ref(true)
const showRecentOrders = ref(true)
</script>
```

### Step 5: Build for Different Environments

#### Development Build
```bash
# Development build with source maps and hot reload
npm run dev

# Build for development with file watching
npm run build:dev
```

```json
// package.json scripts
{
  "scripts": {
    "dev": "vite --host",
    "build:dev": "vite build --mode development",
    "build": "vite build",
    "build:prod": "vite build --mode production",
    "build:analyze": "ANALYZE=true vite build",
    "preview": "vite preview",
    "lint": "eslint . --ext .vue,.js,.jsx,.cjs,.mjs,.ts,.tsx,.cts,.mts --fix --ignore-path .gitignore",
    "format": "prettier --write src/",
    "test": "vitest",
    "test:coverage": "vitest run --coverage"
  }
}
```

#### Production Build with Optimizations
```bash
# Clean previous build
rm -rf dist/

# Production build
npm run build:prod

# Verify build output
ls -la dist/

# Check bundle sizes
du -sh dist/*
```

### Step 6: Integrate with ERPNext Build System

#### Update Frappe Hooks
```python
# your_app/hooks.py - Updated for frontend integration

# Web asset paths
app_include_js = [
    "/assets/your_app/dist/assets/js/index.js"
]

app_include_css = [
    "/assets/your_app/dist/assets/css/index.css"
]

# Website route rules for SPA
website_route_rules = [
    {"from_route": "/{{app_name}}/<path:app_path>", "to_route": "/{{app_name}}"},
]

# Build hook
before_install = "your_app.install.before_install"

# Custom build commands
build_js_cmd = "cd apps/your_app/frontend && npm run build"
```

#### Create Build Integration Script
```python
# your_app/install.py
import os
import subprocess
import frappe

def before_install():
    """Run before app installation"""
    build_frontend_assets()

def build_frontend_assets():
    """Build frontend assets during installation"""
    
    app_path = frappe.get_app_path("your_app")
    frontend_path = os.path.join(app_path, "frontend")
    
    if not os.path.exists(frontend_path):
        print("No frontend directory found, skipping frontend build")
        return
    
    print("Building frontend assets...")
    
    try:
        # Install dependencies
        subprocess.run(
            ["npm", "install"],
            cwd=frontend_path,
            check=True,
            capture_output=True,
            text=True
        )
        
        # Build for production
        subprocess.run(
            ["npm", "run", "build"],
            cwd=frontend_path,
            check=True,
            capture_output=True,
            text=True
        )
        
        print("✅ Frontend assets built successfully")
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Frontend build failed: {e}")
        print(f"Error output: {e.stderr}")
        raise

def after_install():
    """Run after app installation"""
    copy_assets_to_public()

def copy_assets_to_public():
    """Copy built assets to public directory"""
    
    import shutil
    
    app_path = frappe.get_app_path("your_app")
    dist_path = os.path.join(app_path, "frontend", "dist")
    public_path = os.path.join(app_path, "public", "dist")
    
    if os.path.exists(dist_path):
        if os.path.exists(public_path):
            shutil.rmtree(public_path)
        
        shutil.copytree(dist_path, public_path)
        print("✅ Assets copied to public directory")
```

### Step 7: Automated Build Pipeline

#### Create Build Script
```bash
#!/bin/bash
# build.sh - Automated build script

set -e

echo "🔨 Starting frontend build process..."

# Configuration
APP_NAME="your_app"
FRONTEND_DIR="apps/$APP_NAME/frontend"
PUBLIC_DIR="apps/$APP_NAME/public"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if frontend directory exists
if [ ! -d "$FRONTEND_DIR" ]; then
    print_error "Frontend directory not found: $FRONTEND_DIR"
    exit 1
fi

# Navigate to frontend directory
cd "$FRONTEND_DIR"

# Check Node.js version
NODE_VERSION=$(node --version)
print_status "Using Node.js $NODE_VERSION"

# Install dependencies
print_status "Installing dependencies..."
if npm ci; then
    print_status "✅ Dependencies installed"
else
    print_error "❌ Failed to install dependencies"
    exit 1
fi

# Run linting
print_status "Running linting..."
if npm run lint; then
    print_status "✅ Linting passed"
else
    print_warning "⚠️ Linting issues found"
fi

# Run tests
print_status "Running tests..."
if npm run test; then
    print_status "✅ Tests passed"
else
    print_warning "⚠️ Some tests failed"
fi

# Build for production
print_status "Building for production..."
if npm run build; then
    print_status "✅ Build completed successfully"
else
    print_error "❌ Build failed"
    exit 1
fi

# Analyze bundle size
print_status "Analyzing bundle size..."
if npm run build:analyze; then
    print_status "✅ Bundle analysis completed"
else
    print_warning "⚠️ Bundle analysis failed"
fi

# Copy assets to public directory
print_status "Copying assets to public directory..."
cd ../../..  # Back to bench root

if [ -d "$FRONTEND_DIR/dist" ]; then
    mkdir -p "$PUBLIC_DIR/{{app_name}}"
    cp -r "$FRONTEND_DIR/dist"/* "$PUBLIC_DIR/{{app_name}}/"
    print_status "✅ Assets copied successfully"
else
    print_error "❌ Build output not found"
    exit 1
fi

# Generate build report
print_status "Generating build report..."
BUILD_SIZE=$(du -sh "$PUBLIC_DIR/{{app_name}}" | cut -f1)
JS_COUNT=$(find "$PUBLIC_DIR/{{app_name}}" -name "*.js" | wc -l)
CSS_COUNT=$(find "$PUBLIC_DIR/{{app_name}}" -name "*.css" | wc -l)

echo ""
echo "📊 Build Summary:"
echo "   Total Size: $BUILD_SIZE"
echo "   JavaScript Files: $JS_COUNT"
echo "   CSS Files: $CSS_COUNT"
echo "   Build Time: $(date)"

# Update Frappe assets
print_status "Building Frappe assets..."
if bench build --app "$APP_NAME"; then
    print_status "✅ Frappe assets built"
else
    print_warning "⚠️ Frappe asset build had issues"
fi

print_status "🎉 Frontend build process completed!"
```

#### Make Script Executable
```bash
chmod +x build.sh

# Run the build script
./build.sh
```

### Step 8: Performance Optimization

#### Asset Optimization
```javascript
// Additional Vite plugins for optimization
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { splitVendorChunkPlugin } from 'vite'

export default defineConfig({
  plugins: [
    vue(),
    splitVendorChunkPlugin(),
    
    // PWA plugin for offline support (optional)
    // VitePWA({
    //   registerType: 'autoUpdate',
    //   workbox: {
    //     globPatterns: ['**/*.{js,css,html,ico,png,svg}']
    //   }
    // })
  ],
  
  build: {
    // Enable gzip compression
    reportCompressedSize: true,
    
    // Optimize chunks
    rollupOptions: {
      output: {
        manualChunks(id) {
          // Create separate chunks for large dependencies
          if (id.includes('node_modules')) {
            if (id.includes('vue')) {
              return 'vue'
            }
            if (id.includes('frappe-ui')) {
              return 'frappe-ui'
            }
            if (id.includes('chart') || id.includes('d3')) {
              return 'charts'
            }
            return 'vendor'
          }
        }
      }
    }
  }
})
```

#### Image Optimization
```bash
# Install image optimization tools
npm install --save-dev @vitejs/plugin-legacy

# Add to package.json
npm install --save-dev imagemin imagemin-mozjpeg imagemin-pngquant
```

### Step 9: Testing and Quality Assurance

#### Build Testing Script
```javascript
// test-build.js - Test built assets
const fs = require('fs')
const path = require('path')

function testBuildOutput() {
    const distPath = path.join(__dirname, 'dist')
    
    console.log('🧪 Testing build output...')
    
    // Check if dist directory exists
    if (!fs.existsSync(distPath)) {
        console.error('❌ Build output directory not found')
        process.exit(1)
    }
    
    // Check for required files
    const requiredFiles = ['index.html']
    const requiredDirs = ['assets']
    
    for (const file of requiredFiles) {
        const filePath = path.join(distPath, file)
        if (!fs.existsSync(filePath)) {
            console.error(`❌ Required file missing: ${file}`)
            process.exit(1)
        }
        console.log(`✅ Found required file: ${file}`)
    }
    
    for (const dir of requiredDirs) {
        const dirPath = path.join(distPath, dir)
        if (!fs.existsSync(dirPath)) {
            console.error(`❌ Required directory missing: ${dir}`)
            process.exit(1)
        }
        console.log(`✅ Found required directory: ${dir}`)
    }
    
    // Check file sizes
    const stats = fs.statSync(distPath)
    const totalSize = fs.readdirSync(distPath).reduce((total, file) => {
        const filePath = path.join(distPath, file)
        const stat = fs.statSync(filePath)
        return total + stat.size
    }, 0)
    
    console.log(`📊 Total build size: ${(totalSize / 1024 / 1024).toFixed(2)} MB`)
    
    // Check for source maps in production build
    const hasSourceMaps = fs.readdirSync(distPath, { recursive: true })
        .some(file => file.endsWith('.map'))
    
    if (process.env.NODE_ENV === 'production' && hasSourceMaps) {
        console.warn('⚠️ Source maps found in production build')
    }
    
    console.log('✅ Build output test completed successfully')
}

testBuildOutput()
```

### Step 10: Deploy Built Assets

#### Production Deployment
```bash
# Production build and deployment
npm run build:prod

# Copy to production server (example)
rsync -av dist/ user@server:/path/to/production/assets/

# Or integrate with bench deployment
bench build --app your_app --force
```

#### CDN Integration (Optional)
```javascript
// vite.config.js - CDN configuration for production
export default defineConfig({
  build: {
    rollupOptions: {
      external: process.env.NODE_ENV === 'production' ? [
        'vue',
        'vue-router'
      ] : [],
      
      output: {
        globals: process.env.NODE_ENV === 'production' ? {
          'vue': 'Vue',
          'vue-router': 'VueRouter'
        } : {}
      }
    }
  }
})
```

## Best Practices

### Development Workflow
- Use development server for active development
- Enable hot module replacement for faster iteration
- Use source maps for debugging
- Run linting and testing before building
- Keep dependencies up to date

### Build Optimization
- Minimize bundle size through code splitting
- Use tree shaking to eliminate dead code
- Optimize images and static assets
- Enable gzip compression
- Cache bust with file hashing

### Production Deployment
- Always build with NODE_ENV=production
- Remove debug code and console statements
- Use minification and compression
- Test built assets before deployment
- Monitor bundle size over time

### Performance Monitoring
- Track build times and bundle sizes
- Monitor loading performance in production
- Use performance budgets
- Regularly audit dependencies
- Optimize critical rendering path

## Common Issues and Solutions

### Issue: Build Fails with Memory Errors
**Solution**: Increase Node.js memory limit: `NODE_OPTIONS=--max_old_space_size=4096 npm run build`

### Issue: Assets Not Loading in Production
**Solution**: Check paths in hooks.py and ensure assets are copied correctly

### Issue: Large Bundle Sizes
**Solution**: Use code splitting, tree shaking, and remove unused dependencies

### Issue: Slow Development Server
**Solution**: Use Vite's dependency pre-bundling and enable caching

---

*Your frontend build process is now fully configured and optimized for production deployment. The assets are properly integrated with ERPNext and ready for end users.*