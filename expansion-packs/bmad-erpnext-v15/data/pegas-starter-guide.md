# Pegas Frappe Vue Starter Guide

## Overview

The Pegas Frappe Vue Starter is a comprehensive, production-ready Vue.js starter template specifically designed for Frappe Framework applications. It replaces the older doppio starter with enhanced features, better documentation, and production-tested components.

**Repository**: https://github.com/woakes070048/pegas-frappe-vue-starter

## Key Advantages Over Doppio

### Enhanced Features
- 📚 **Comprehensive Documentation** in `/docs` folder
- 🧩 **Reference Components** from production CRM implementation
- 🏗️ **Better Architecture** with organized composables and stores
- 🎨 **Production-Ready UI** components and layouts
- 📱 **Mobile-First** responsive design
- 🔧 **Enhanced Tooling** with proper TypeScript support

### What's Included

#### Core Infrastructure
- **Vue 3** with Composition API
- **Vite** for lightning-fast development
- **Tailwind CSS** for utility-first styling
- **Frappe UI 0.1.171** component library
- **Vue Router** for navigation
- **Pinia** for state management
- **PWA support** out of the box

#### Reference Components (Production-Tested)
```
reference_components/
├── CRM/                    # Complete CRM implementation
│   ├── Modals/            # Modal dialogs (reusable patterns)
│   ├── ListViews/         # Data tables with filtering/sorting
│   ├── Settings/          # Configuration pages
│   └── Stores/            # State management examples
├── ComplexFeatures/
│   └── Activities/        # Communication timeline components
└── Telephony/             # Phone system integration
```

#### Documentation Structure
```
docs/
├── GETTING_STARTED.md     # Quick setup guide
├── DEVELOPER_GUIDE.md     # Complete development workflow
├── ARCHITECTURE.md        # System design patterns
├── COMPONENTS.md          # Component usage guide
├── API_DEVELOPMENT_GUIDE.md # API integration patterns
├── FRAPPE_INTEGRATION.md  # Frappe-specific features
├── DEPLOYMENT.md          # Production deployment
└── USER_GUIDE.md          # End-user documentation
```

## Migration from Doppio

### Before (Doppio)
```bash
# Old method
npx degit NagariaHussain/doppio_frappeui_starter frontend
```

### After (Pegas)
```bash
# New method
git clone https://github.com/woakes070048/pegas-frappe-vue-starter.git frontend
```

### Key Changes Required

1. **Clone Command**: Use `git clone` instead of `npx degit`
2. **Clean Up**: Remove `.git` folder after cloning (if customizing)
3. **Configuration**: Update `src/config/brand.js` with your app settings
4. **Reference**: Use `reference_components/` for implementation patterns

## Quick Setup Guide

### 1. Clone the Template
```bash
# In your ERPNext app directory
cd apps/your_app
git clone https://github.com/woakes070048/pegas-frappe-vue-starter.git frontend
cd frontend

# Remove git history if customizing
rm -rf .git
```

### 2. Install Dependencies
```bash
yarn install
# or
npm install
```

### 3. Configure Your App
Edit `src/config/brand.js`:
```javascript
export const brandConfig = {
  appName: 'Your App',
  appTitle: 'Your Application', 
  baseRoute: '/your-app',
  // ... customize other settings
}
```

### 4. Start Development
```bash
yarn dev
# Runs on http://localhost:8080/app
```

## Key Configuration Files

### Package.json
```json
{
  "name": "frontend-starter-template",
  "version": "1.0.0",
  "scripts": {
    "dev": "vite --host --port 8080 --base /app/",
    "build": "vite build --base=/assets/app/frontend/",
    "lint": "biome check .",
    "lint:fix": "biome check --apply ."
  },
  "dependencies": {
    "frappe-ui": "^0.1.171",
    "vue": "^3.5.13",
    "vue-router": "^4.2.2",
    "pinia": "^2.0.33"
  }
}
```

### Vite Config
Pre-configured with:
- Proper proxy settings for Frappe
- Vue 3 support with JSX
- PWA plugin
- Tailwind CSS integration

## Advanced Features

### 1. Component Patterns
Learn from production-tested patterns:
```bash
# Study these for implementation guidance
reference_components/CRM/Modals/         # Modal dialogs
reference_components/CRM/ListViews/      # Data tables
reference_components/CRM/Settings/       # Configuration UIs
```

### 2. State Management
Pre-configured Pinia stores:
```javascript
// Example store usage
import { useSessionStore } from '@/stores/session'
const { isLoggedIn, user } = useSessionStore()
```

### 3. Frappe Integration
Enhanced patterns for:
- Authentication
- API calls with error handling
- Permission management
- File uploads
- Real-time updates via WebSocket

### 4. Mobile Support
Built-in responsive components:
- Mobile navigation
- Touch-friendly interfaces
- Progressive Web App features

## Development Workflow

### 1. Component Development
```bash
# Create new components in src/components/
# Follow patterns from reference_components/
```

### 2. Page Creation
```bash
# Add pages to src/pages/
# Register routes in src/router.js
# Add navigation in src/config/brand.js
```

### 3. API Integration
```javascript
// Use frappe-ui resources
import { createResource } from 'frappe-ui'

const data = createResource({
  url: 'your_app.api.get_data',
  auto: true
})
```

## Production Deployment

### 1. Build Process
```bash
yarn build
# Outputs to dist/ folder
```

### 2. Integration with Frappe App
```bash
# Copy built files to your app
cp -r dist/* ../your_app/public/
```

### 3. Configure Routes
In your app's `hooks.py`:
```python
website_route_rules = [
    {"from_route": "/your-app/<path:app_path>", "to_route": "your-app"},
]
```

## Migration Checklist

When updating from doppio to pegas:

- [ ] Update clone commands in documentation
- [ ] Review reference components for better patterns
- [ ] Update configuration files
- [ ] Test mobile responsiveness
- [ ] Implement enhanced error handling
- [ ] Add PWA features if needed
- [ ] Update build and deployment scripts

## Best Practices

### 1. Use Reference Components
Don't reinvent the wheel - study the reference implementations:
- Modal patterns from CRM
- List view implementations
- Settings page structures

### 2. Follow Documentation
The pegas starter includes comprehensive docs:
- Read GETTING_STARTED.md first
- Study ARCHITECTURE.md for patterns
- Reference API_DEVELOPMENT_GUIDE.md for backend integration

### 3. Leverage Composables
Use Vue 3 composables for reusable logic:
```javascript
// Example from the starter
import { useDocument } from '@/composables/useDocument'
const { doc, loading, save } = useDocument('DocType', 'name')
```

### 4. Mobile-First Design
The starter is mobile-first:
- Test on mobile devices early
- Use responsive Tailwind classes
- Leverage PWA features

## Troubleshooting

### Common Issues

1. **CORS Errors**
   - Update site_config.json with correct origins
   - Ensure proper Frappe site configuration

2. **Build Issues**
   - Clear node_modules and reinstall
   - Check Vite configuration

3. **Component Import Errors**
   - Verify frappe-ui version compatibility
   - Check import paths

## Support Resources

- **Documentation**: `/docs` folder in the starter
- **Examples**: `/reference_components` folder
- **Frappe Community**: https://discuss.frappe.io
- **GitHub Issues**: https://github.com/woakes070048/pegas-frappe-vue-starter/issues

## Conclusion

The pegas-frappe-vue-starter provides a significant upgrade over the doppio template with:
- Better documentation and examples
- Production-tested components
- Enhanced development workflow
- Mobile-first approach
- Comprehensive reference implementations

This makes it the ideal choice for modern ERPNext application development.