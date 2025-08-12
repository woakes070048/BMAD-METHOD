# frappe-ui Compliance Checklist for ERPNext Apps

## 📦 Installation & Setup

### Core Dependencies
- [ ] frappe-ui@^0.1.171 installed
- [ ] @headlessui/vue@^1.7.22 installed
- [ ] @iconify/vue@^4.1.1 installed
- [ ] socket.io-client@^4.7.2 installed
- [ ] TailwindCSS properly configured
- [ ] PostCSS configuration set up

### Vite Configuration
- [ ] frappe-ui optimized in `optimizeDeps`
- [ ] Correct alias path to frappe-ui source
- [ ] TailwindCSS content includes frappe-ui paths
- [ ] Build configuration properly chunks frappe-ui

## 🎨 Component Usage Standards

### Button Component
- [ ] **MUST**: Use frappe-ui Button instead of native button
- [ ] **MUST**: Use proper variant prop (solid, outline, ghost, subtle)
- [ ] **MUST**: Include loading states with :loading prop
- [ ] **SHOULD**: Use size prop for consistency (sm, md, lg)
- [ ] **SHOULD**: Use icon prop for consistent iconography
- [ ] **MUST NOT**: Override core Button styles with custom CSS

#### ✅ Correct Usage
```vue
<Button variant="solid" :loading="isSubmitting" icon="plus">
  Create New
</Button>
```

#### ❌ Incorrect Usage
```vue
<button class="my-custom-button" @click="submit">
  Create New
</button>
```

### FormControl Component
- [ ] **MUST**: Use FormControl for all form inputs
- [ ] **MUST**: Include proper label prop
- [ ] **MUST**: Handle error states with :error prop
- [ ] **MUST**: Use appropriate type prop
- [ ] **SHOULD**: Include placeholder for better UX
- [ ] **SHOULD**: Mark required fields with :required

#### ✅ Correct Usage
```vue
<FormControl
  v-model="email"
  type="email"
  label="Email Address"
  :required="true"
  :error="errors.email"
  placeholder="Enter your email"
/>
```

### Dialog Component
- [ ] **MUST**: Use frappe-ui Dialog for modals
- [ ] **MUST**: Use proper v-model for open/close state
- [ ] **MUST**: Include title in options
- [ ] **SHOULD**: Use appropriate size (sm, md, lg, xl)
- [ ] **MUST**: Implement proper slot structure
- [ ] **MUST**: Handle keyboard navigation (Escape key)

#### ✅ Correct Usage
```vue
<Dialog
  v-model="showDialog"
  :options="{ title: 'Confirm Delete', size: 'md' }"
>
  <template #body>
    <p>Are you sure you want to delete this item?</p>
  </template>
  <template #actions>
    <Button variant="ghost" @click="showDialog = false">Cancel</Button>
    <Button variant="solid" @click="confirmDelete">Delete</Button>
  </template>
</Dialog>
```

### Toast Notifications
- [ ] **MUST**: Use frappe-ui toast system
- [ ] **MUST**: Use appropriate toast type (success, error, warning, info)
- [ ] **SHOULD**: Keep messages concise and actionable
- [ ] **MUST NOT**: Create custom notification systems

#### ✅ Correct Usage
```javascript
import { toast } from 'frappe-ui'

// Success notification
toast.success('Document saved successfully')

// Error notification  
toast.error('Failed to save document')
```

## 📊 Data Management

### Resource Pattern Compliance
- [ ] **MUST**: Use createResource for API calls
- [ ] **MUST**: Use createListResource for list data
- [ ] **MUST**: Use createDocumentResource for document operations
- [ ] **MUST**: Implement proper error handling in onError
- [ ] **MUST**: Show loading states during data fetching
- [ ] **SHOULD**: Use auto: true for data that loads immediately

#### ✅ Resource Usage
```javascript
const contactList = createListResource({
  doctype: 'Contact',
  fields: ['name', 'email', 'phone'],
  filters: { status: 'Active' },
  auto: true,
  onSuccess(data) {
    console.log('Contacts loaded:', data.length)
  },
  onError(error) {
    toast.error('Failed to load contacts')
  }
})
```

### ListView Component
- [ ] **MUST**: Use frappe-ui ListView for data tables
- [ ] **MUST**: Define proper column configuration
- [ ] **MUST**: Implement row click handlers appropriately
- [ ] **MUST**: Handle empty states with EmptyState component
- [ ] **SHOULD**: Implement selection features where appropriate
- [ ] **SHOULD**: Use custom cell templates for complex data

#### ✅ ListView Usage
```vue
<ListView
  :columns="columns"
  :rows="contacts"
  :loading="contactList.loading"
  @row-click="handleRowClick"
>
  <template #empty>
    <EmptyState
      title="No contacts found"
      description="Create your first contact to get started"
    />
  </template>
</ListView>
```

## 🎯 State Management Integration

### Pinia Store Pattern
- [ ] **MUST**: Use Pinia for state management
- [ ] **SHOULD**: Use setup store syntax
- [ ] **MUST**: Integrate frappe-ui resources with stores
- [ ] **MUST**: Handle resource states properly
- [ ] **SHOULD**: Use storeToRefs for reactive references

#### ✅ Store Integration
```javascript
export const useContactsStore = defineStore('contacts', () => {
  const contacts = ref([])
  
  const contactList = createListResource({
    doctype: 'Contact',
    auto: false,
    onSuccess(data) {
      contacts.value = data
    }
  })
  
  async function fetchContacts() {
    await contactList.fetch()
  }
  
  return { contacts, fetchContacts, loading: contactList.loading }
})
```

## 🎨 Styling Guidelines

### TailwindCSS Integration
- [ ] **MUST**: Use TailwindCSS classes provided by frappe-ui
- [ ] **MUST**: Include frappe-ui in TailwindCSS content paths
- [ ] **MUST NOT**: Override frappe-ui component styles directly
- [ ] **SHOULD**: Extend theme colors to match frappe-ui palette
- [ ] **SHOULD**: Use consistent spacing scale

### Theme Customization
- [ ] **SHOULD**: Use CSS custom properties for theming
- [ ] **MUST**: Maintain compatibility with frappe-ui themes
- [ ] **SHOULD**: Support dark mode if required
- [ ] **MUST NOT**: Hard-code colors that conflict with theme

#### ✅ Theme Extension
```javascript
// tailwind.config.js
export default {
  content: [
    './src/**/*.{vue,js}',
    './node_modules/frappe-ui/src/**/*.{vue,js}'
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#171717',
          // ... extend as needed
        }
      }
    }
  }
}
```

## 📱 Responsive Design

### Mobile Compatibility
- [ ] **MUST**: Ensure all frappe-ui components work on mobile
- [ ] **MUST**: Use responsive breakpoints consistently
- [ ] **MUST**: Implement proper touch interactions
- [ ] **SHOULD**: Consider mobile-specific UX patterns
- [ ] **MUST**: Test on various screen sizes

### Accessibility Standards
- [ ] **MUST**: Leverage frappe-ui's built-in accessibility features
- [ ] **MUST**: Ensure proper keyboard navigation
- [ ] **MUST**: Implement ARIA labels where needed
- [ ] **MUST**: Maintain adequate color contrast
- [ ] **SHOULD**: Test with screen readers

## 🔧 Error Handling

### Resource Error Management
- [ ] **MUST**: Implement onError handlers for all resources
- [ ] **MUST**: Show user-friendly error messages
- [ ] **MUST**: Log errors appropriately
- [ ] **SHOULD**: Implement retry mechanisms
- [ ] **SHOULD**: Handle different error types appropriately

#### ✅ Error Handling Pattern
```javascript
const resource = createResource({
  url: 'api.method',
  onError(error) {
    console.error('API Error:', error)
    
    if (error.response?.status === 403) {
      toast.error('You do not have permission to perform this action')
    } else {
      toast.error('An unexpected error occurred')
    }
  }
})
```

### Loading States
- [ ] **MUST**: Show loading indicators for all async operations
- [ ] **MUST**: Use frappe-ui LoadingIndicator component
- [ ] **MUST**: Disable interactive elements during loading
- [ ] **SHOULD**: Implement skeleton loaders for better UX

## 📊 Performance Requirements

### Bundle Optimization
- [ ] **MUST**: Lazy load frappe-ui components appropriately  
- [ ] **MUST**: Configure proper code splitting
- [ ] **MUST**: Use tree shaking for unused components
- [ ] **SHOULD**: Monitor bundle size regularly
- [ ] **SHOULD**: Implement dynamic imports for large components

### Resource Management
- [ ] **MUST**: Implement proper cleanup for resources
- [ ] **MUST**: Cancel requests on component unmount
- [ ] **SHOULD**: Implement caching strategies
- [ ] **SHOULD**: Use pagination for large datasets

## 🧪 Testing Standards

### Component Testing
- [ ] **MUST**: Test frappe-ui component integration
- [ ] **MUST**: Mock frappe-ui resources in tests
- [ ] **MUST**: Test error states and loading states
- [ ] **SHOULD**: Test accessibility features
- [ ] **SHOULD**: Test responsive behavior

#### ✅ Testing Pattern
```javascript
import { mount } from '@vue/test-utils'
import { Button } from 'frappe-ui'

test('button shows loading state', () => {
  const wrapper = mount(Button, {
    props: { loading: true }
  })
  
  expect(wrapper.find('.loading-spinner').exists()).toBe(true)
  expect(wrapper.attributes('disabled')).toBeDefined()
})
```

## 📋 Code Quality

### TypeScript Integration (if used)
- [ ] **SHOULD**: Add type declarations for frappe-ui
- [ ] **SHOULD**: Use proper typing for resource responses
- [ ] **MUST**: Handle type safety for component props
- [ ] **SHOULD**: Implement proper error type handling

### ESLint Rules
- [ ] **MUST**: Configure ESLint for Vue 3 + frappe-ui
- [ ] **MUST**: Ensure no unused imports
- [ ] **MUST**: Follow consistent naming conventions
- [ ] **SHOULD**: Use composition API consistently

## 🚀 Deployment Checklist

### Production Build
- [ ] **MUST**: Verify frappe-ui builds correctly
- [ ] **MUST**: Check bundle sizes are reasonable
- [ ] **MUST**: Test all components in production mode
- [ ] **MUST**: Verify CDN compatibility (if used)

### Performance Metrics
- [ ] **SHOULD**: Lighthouse performance score > 90
- [ ] **SHOULD**: First Contentful Paint < 1.8s
- [ ] **SHOULD**: Time to Interactive < 3.9s
- [ ] **MUST**: No console errors in production

## 📖 Documentation Requirements

### Component Documentation
- [ ] **MUST**: Document custom components using frappe-ui
- [ ] **MUST**: Include usage examples
- [ ] **MUST**: Document any extensions or customizations
- [ ] **SHOULD**: Create style guide for consistency

### API Integration
- [ ] **MUST**: Document resource configurations
- [ ] **MUST**: Document error handling patterns
- [ ] **SHOULD**: Include integration examples
- [ ] **SHOULD**: Document troubleshooting steps

## ⚡ Compliance Score

### Critical Requirements (Must Pass All)
- [ ] Using frappe-ui components instead of custom alternatives
- [ ] Proper resource pattern implementation
- [ ] Error handling for all API calls
- [ ] Loading states for all async operations
- [ ] Accessibility standards maintained
- [ ] No custom CSS overriding frappe-ui styles

### Important Requirements (80%+ Pass Rate)
- [ ] Responsive design implementation
- [ ] TypeScript integration (if applicable)
- [ ] Performance optimization
- [ ] Proper testing coverage
- [ ] Documentation completeness
- [ ] Code quality standards

### Nice-to-Have (60%+ Pass Rate)
- [ ] Advanced features (PWA, offline support)
- [ ] Custom theme extensions
- [ ] Performance monitoring
- [ ] Advanced testing strategies

## 🎯 Compliance Levels

### **Level 1 - Basic Compliance (60-69%)**
- Core components used correctly
- Basic error handling implemented
- Minimum accessibility standards met

### **Level 2 - Good Compliance (70-84%)**
- Most components follow patterns
- Comprehensive error handling
- Good performance characteristics
- Proper testing implemented

### **Level 3 - Excellent Compliance (85-94%)**
- All critical and important requirements met
- Advanced features implemented
- Comprehensive documentation
- Superior performance

### **Level 4 - Perfect Compliance (95-100%)**
- All requirements exceeded
- Innovation in frappe-ui usage
- Exemplary code quality
- Outstanding performance metrics

## 🔍 Common Violations to Avoid

### ❌ Critical Violations
1. Using native HTML elements instead of frappe-ui components
2. Creating custom modal/dialog systems
3. Not handling resource errors
4. Missing loading states
5. Overriding frappe-ui component styles

### ❌ Important Violations  
1. Not using responsive design patterns
2. Poor accessibility implementation
3. Inefficient resource usage
4. Missing TypeScript types
5. Inadequate testing coverage

### ❌ Style Violations
1. Inconsistent spacing and sizing
2. Custom colors that don't match theme
3. Non-standard component usage
4. Poor mobile experience
5. Accessibility shortcuts

## 📞 Getting Help

### Resources
- [frappe-ui Documentation](https://github.com/frappe/frappe-ui)
- [Vue 3 Documentation](https://vuejs.org/)
- [TailwindCSS Documentation](https://tailwindcss.com/)
- [Frappe Framework Documentation](https://frappeframework.com/docs/)

### Best Practices
- Study Helpdesk app implementation
- Review CRM app patterns
- Follow Frappe team examples
- Engage with community discussions
- Regular compliance audits

## ✅ Final Validation

Before considering your app frappe-ui compliant:

1. **Automated Checks**: Run ESLint, build without errors
2. **Manual Review**: Check each component against standards
3. **Performance Testing**: Verify load times and bundle sizes
4. **Accessibility Audit**: Test with screen readers and keyboard navigation
5. **Cross-browser Testing**: Ensure compatibility across browsers
6. **Mobile Testing**: Verify responsive behavior on devices
7. **User Testing**: Validate UX with actual users
8. **Documentation Review**: Ensure completeness and accuracy

**Minimum Score for Production**: 85% compliance
**Recommended Score**: 90%+ compliance
**Excellence Target**: 95%+ compliance