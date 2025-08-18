# Build Native Vue Components

## Overview
This task guides you through building and optimizing native Vue components for your ERPNext application using Frappe's built-in esbuild pipeline.

## Prerequisites

### Required Knowledge
- [ ] Understanding of Vue 3 Composition API
- [ ] Basic knowledge of JavaScript ES6 modules
- [ ] Familiarity with Frappe's page system
- [ ] Understanding of native Vue integration patterns

### Development Environment
- [ ] ERPNext app created with `bench new-app`
- [ ] Vue components in `public/js/` directory
- [ ] Bundle entry points created (`.bundle.js` files)
- [ ] Frappe bench running

## Step-by-Step Process

### Step 1: Verify Component Structure

#### Check Native Vue Setup
```bash
# Navigate to your app directory
cd apps/your_app

# Verify public/js structure exists
ls -la your_app/public/js/
# Should show: [feature].bundle.js and [feature]/ directories

# Check bundle entry point
cat your_app/public/js/[feature].bundle.js
# Should import Vue and use SetVueGlobals
```

#### Verify Frappe Integration
```javascript
// Check that bundle files have proper structure:
// 1. Import Vue and components
import { createApp } from "vue";
import FeatureComponent from "./feature/Feature.vue";

// 2. Class pattern for Frappe pages
class FeaturePage {
    constructor(wrapper) {
        // ...
        SetVueGlobals(app); // CRITICAL
    }
}
```

### Step 2: Build Assets with Bench

#### Development Build
```bash
# Build assets for your app
bench build --app your_app

# This compiles:
# - All .bundle.js files
# - Vue components (.vue files)
# - JavaScript modules
# - CSS/SCSS files
```

#### Watch Mode for Development
```bash
# Start bench with asset watching
bench start

# This automatically rebuilds on file changes
# No separate frontend server needed!
```

### Step 3: Production Build

#### Optimize for Production
```bash
# Build with production optimizations
bench build --production --app your_app

# This will:
# - Minify JavaScript
# - Optimize Vue templates
# - Tree-shake unused code
# - Generate source maps
```

#### Clear Cache After Build
```bash
# Clear browser cache
bench --site [site-name] clear-cache

# Clear server cache
bench --site [site-name] clear-website-cache
```

### Step 4: Verify Build Output

#### Check Assets Directory
```bash
# Check compiled assets
ls -la sites/assets/your_app/
# Should show compiled JS and CSS files

# Check assets.json
cat sites/assets/assets.json | grep your_app
# Should list all compiled bundles
```

#### Test in Browser
```javascript
// Open browser console and verify:
// 1. No build errors in console
// 2. Vue DevTools detects Vue app
// 3. Components render correctly
// 4. API calls work (frappe.call)
```

### Step 5: Troubleshooting Build Issues

#### Common Issues and Solutions

1. **Module not found errors**
```bash
# Check import paths are relative
# Wrong: import Component from 'Component.vue'
# Right: import Component from './Component.vue'
```

2. **SetVueGlobals is not defined**
```javascript
// Ensure it's available globally
// This is set by Frappe when loading libs.bundle.js
```

3. **Vue components not reactive**
```javascript
// Ensure using Vue 3 syntax
// Use ref() and reactive() from 'vue'
// Not Vue 2 data() function
```

4. **Build not updating**
```bash
# Force rebuild
bench build --force --app your_app

# Clear all caches
bench --site [site-name] clear-cache
redis-cli FLUSHALL
```

## Build Configuration

### No Separate Build Config Needed!
Unlike traditional Vue apps, you DON'T need:
- ❌ vite.config.js
- ❌ webpack.config.js  
- ❌ rollup.config.js
- ❌ separate package.json for frontend

Everything is handled by Frappe's build system!

### ESBuild Configuration (Automatic)
Frappe's esbuild automatically:
- Compiles Vue SFCs
- Handles imports
- Bundles dependencies
- Processes styles
- Generates source maps

## Best Practices

### DO's
- ✅ Use `.bundle.js` as entry points
- ✅ Import Vue from Frappe's node_modules
- ✅ Call `SetVueGlobals(app)` for every Vue app
- ✅ Use `bench build` for compilation
- ✅ Structure components in `public/js/[feature]/`
- ✅ Use Frappe's built-in styles

### DON'Ts
- ❌ Don't create `/frontend/` directory
- ❌ Don't use separate build tools
- ❌ Don't run `npm run build`
- ❌ Don't configure Vite/webpack
- ❌ Don't create frontend package.json

## Validation

### Build Success Checklist
- [ ] `bench build --app your_app` completes without errors
- [ ] Assets appear in `sites/assets/your_app/`
- [ ] Browser console shows no errors
- [ ] Vue DevTools detects components
- [ ] Pages load and render correctly
- [ ] API calls work via `frappe.call()`
- [ ] Styles apply correctly
- [ ] Production build is minified

## Output Structure

After successful build:
```
sites/
└── assets/
    ├── your_app/
    │   ├── js/
    │   │   └── [feature].bundle.js (compiled)
    │   └── css/
    │       └── [feature].bundle.css (if applicable)
    └── assets.json (updated with your bundles)
```

## Next Steps

After building assets:
1. Test components in development
2. Implement component logic
3. Add API integrations
4. Test in production mode
5. Deploy to production server

## References

- Frappe Build System: Uses esbuild internally
- Vue 3 Documentation: For component patterns
- SetVueGlobals: Critical for Frappe integration
- No external build tools needed!