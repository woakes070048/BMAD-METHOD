# Native Vue Development Checklist for ERPNext

## 🏗️ Project Setup

### Initial Configuration
- [ ] ERPNext app created with `bench new-app`
- [ ] App installed on development site
- [ ] NO /frontend/ directory created
- [ ] NO separate package.json for frontend
- [ ] NO Vite/webpack configuration files

### Directory Structure
- [ ] `public/js/` directory exists
- [ ] Component folders organized in `public/js/`
- [ ] Bundle entry points (`.bundle.js`) created
- [ ] Vue components (`.vue` files) in subdirectories
- [ ] Store files for Pinia state management

## 🎨 Native Vue Architecture

### Bundle Entry Points
- [ ] Each feature has a `.bundle.js` file
- [ ] Bundle imports Vue components correctly
- [ ] Class pattern used for Frappe integration
- [ ] `SetVueGlobals(app)` called for EVERY Vue app
- [ ] Component exported to `frappe.ui` namespace

### Component Structure
- [ ] Vue 3 Composition API used (`<script setup>`)
- [ ] Props properly defined with types
- [ ] Emits documented
- [ ] Frappe globals accessed via `window`
- [ ] Translation function `__()` working

### State Management
- [ ] Pinia stores created when needed
- [ ] Store uses Composition API pattern
- [ ] Actions use `frappe.call()` for API
- [ ] Loading states properly managed
- [ ] Error handling implemented

## 🔌 Frappe Integration

### Page Integration
- [ ] Page definition JSON created
- [ ] Page JavaScript loads bundle
- [ ] Page actions (buttons, menus) configured
- [ ] Page title and breadcrumbs set
- [ ] Permissions configured

### DocType Integration
- [ ] HTML fields added for Vue mount points
- [ ] Client scripts load Vue components
- [ ] Form object (`frm`) passed to components
- [ ] Field updates trigger Vue reactivity
- [ ] DocType events handled properly

### Report Integration
- [ ] Script Report Python returns Vue data
- [ ] Report JavaScript loads Vue components
- [ ] Query Report enhancements work
- [ ] Visualizations render correctly
- [ ] Export functionality maintained

## 🌐 API Integration

### Backend APIs
- [ ] All methods use `@frappe.whitelist()`
- [ ] Permission checks implemented
- [ ] Error handling with `frappe.throw()`
- [ ] Proper response structure
- [ ] Transaction handling correct

### Frontend API Calls
- [ ] `frappe.call()` used exclusively
- [ ] NO axios/fetch used
- [ ] Proper error handling
- [ ] Loading states shown
- [ ] Success/error messages displayed

## 💅 Styling & UI

### Frappe Styles
- [ ] Bootstrap 4 classes used
- [ ] Frappe utility classes applied
- [ ] CSS variables used (--padding-lg, etc.)
- [ ] frappe-card class for containers
- [ ] Button classes (btn-primary, btn-sm, etc.)

### Responsive Design
- [ ] Mobile responsive (col-md-*, col-sm-*)
- [ ] Touch interactions work
- [ ] Viewport meta tag correct
- [ ] Forms usable on mobile
- [ ] Tables scroll horizontally on mobile

## 🏗️ Build Process

### Development Build
- [ ] `bench build --app [app_name]` works
- [ ] Assets compile without errors
- [ ] Source maps generated
- [ ] Vue DevTools detects components
- [ ] Hot reload working with `bench start`

### Production Build
- [ ] `bench build --production` works
- [ ] JavaScript minified
- [ ] CSS optimized
- [ ] Bundle size reasonable
- [ ] No console errors in production

## 🧪 Testing

### Component Testing
- [ ] Components render without errors
- [ ] Props work correctly
- [ ] Events emit properly
- [ ] Computed properties update
- [ ] Watchers trigger correctly

### Integration Testing
- [ ] API endpoints return expected data
- [ ] Form submissions work
- [ ] Navigation functions
- [ ] Permissions enforced
- [ ] Error states handled

### Browser Testing
- [ ] Works in Chrome/Chromium
- [ ] Works in Firefox
- [ ] Works in Safari
- [ ] Works in Edge
- [ ] No console errors

## 🚀 Deployment

### Pre-deployment
- [ ] All assets built for production
- [ ] Cache cleared
- [ ] Migrations run successfully
- [ ] Permissions configured
- [ ] API endpoints secured

### Deployment Steps
- [ ] Code pushed to repository
- [ ] App pulled on production
- [ ] Assets built on production
- [ ] Cache cleared on production
- [ ] Bench restarted

### Post-deployment
- [ ] Pages load correctly
- [ ] Vue components render
- [ ] API calls work
- [ ] No JavaScript errors
- [ ] Performance acceptable

## ⚡ Performance

### Loading Performance
- [ ] Initial page load < 3 seconds
- [ ] Time to interactive < 5 seconds
- [ ] Bundle size < 500KB
- [ ] Critical CSS inlined
- [ ] Images optimized

### Runtime Performance
- [ ] Smooth scrolling
- [ ] No janky animations
- [ ] Efficient re-renders
- [ ] Memory leaks prevented
- [ ] API calls debounced/throttled

## 🔒 Security

### Frontend Security
- [ ] XSS prevention (no v-html with user data)
- [ ] CSRF token handled by frappe.call()
- [ ] Sensitive data not in frontend
- [ ] Input validation on frontend
- [ ] Secure storage (no localStorage for secrets)

### Backend Security
- [ ] All APIs use @frappe.whitelist()
- [ ] Permission checks on all methods
- [ ] SQL injection prevented
- [ ] Rate limiting implemented
- [ ] Audit logs maintained

## 📚 Documentation

### Code Documentation
- [ ] README.md updated
- [ ] Component props documented
- [ ] API methods documented
- [ ] Complex logic commented
- [ ] JSDoc comments added

### User Documentation
- [ ] User guide created
- [ ] Screenshots included
- [ ] Common issues documented
- [ ] FAQ section added
- [ ] Video tutorials (optional)

## ⚠️ Common Issues Checklist

### Build Issues
- [ ] Import paths are relative (`./component`)
- [ ] No circular dependencies
- [ ] Vue version consistent
- [ ] Node modules not imported directly

### Runtime Issues
- [ ] SetVueGlobals called for all apps
- [ ] Frappe libraries loaded first
- [ ] DOM ready before mounting
- [ ] Cleanup on page unload
- [ ] Event listeners removed

### API Issues
- [ ] CORS not needed (same origin)
- [ ] CSRF token included automatically
- [ ] Timeouts handled
- [ ] Network errors caught
- [ ] Offline state handled

## ✅ Final Validation

### Functionality
- [ ] All features work as expected
- [ ] No regression from previous version
- [ ] Edge cases handled
- [ ] Accessibility standards met
- [ ] Internationalization works

### Quality
- [ ] Code review completed
- [ ] No ESLint errors
- [ ] No console errors/warnings
- [ ] Performance benchmarks met
- [ ] Security scan passed

### Sign-off
- [ ] Developer testing complete
- [ ] QA testing passed
- [ ] User acceptance received
- [ ] Documentation complete
- [ ] Ready for production

## 📝 Notes

Remember:
- NO separate frontend directory
- NO Vite/webpack configuration
- ALWAYS use SetVueGlobals(app)
- ALWAYS use frappe.call() for APIs
- ALWAYS build with bench build
- FOLLOW Frappe's patterns