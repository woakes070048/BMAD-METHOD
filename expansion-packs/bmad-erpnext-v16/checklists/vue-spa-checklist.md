# Vue SPA Development Checklist for ERPNext v16

## Overview

This comprehensive checklist ensures high-quality Vue SPA development within ERPNext v16 applications using Frappe's native asset pipeline. Follow this checklist systematically to maintain consistency, performance, and reliability.

## Pre-Development Setup

### Environment Verification
- [ ] **Frappe Framework v16+** installed and running
- [ ] **ERPNext v16+** installed (if required)
- [ ] **Node.js 16+** available for development tools
- [ ] **Python 3.8+** with proper virtual environment
- [ ] **Git** configured with proper branching strategy
- [ ] **IDE/Editor** configured with Vue 3 and ESLint support

### Project Structure Setup
- [ ] **App directory structure** follows ERPNext conventions
- [ ] **Public/js directory** properly organized for Vue components
- [ ] **Bundle entry points** created following `*.bundle.js` pattern
- [ ] **Component directories** structured hierarchically
- [ ] **Shared utilities** directory established for reusable code

### Development Dependencies
- [ ] **Vue 3** properly integrated with Frappe's esbuild pipeline
- [ ] **Pinia** installed for state management (if needed)
- [ ] **Frappe UI** components library available
- [ ] **Development tools** (ESLint, Prettier) configured
- [ ] **Testing framework** (Vitest/Jest) set up

## Architecture Design

### Application Architecture
- [ ] **Bundle entry strategy** defined and documented
- [ ] **Component hierarchy** planned and documented
- [ ] **State management approach** determined (local vs global)
- [ ] **API integration patterns** established
- [ ] **Route/navigation structure** planned (Frappe pages vs Vue Router)

### Component Design
- [ ] **Component naming conventions** established (PascalCase)
- [ ] **Component responsibility boundaries** clearly defined
- [ ] **Reusable component library** planned
- [ ] **Prop interfaces** designed and documented
- [ ] **Event communication patterns** established

### State Management
- [ ] **Local state strategy** defined for component-specific data
- [ ] **Global state requirements** identified
- [ ] **Pinia store structure** designed (if using global state)
- [ ] **Data flow patterns** documented
- [ ] **State persistence needs** identified

## Implementation Standards

### Vue 3 Best Practices
- [ ] **Composition API** used consistently throughout application
- [ ] **Script setup syntax** implemented for cleaner component code
- [ ] **Reactive references** properly used (`ref`, `reactive`, `computed`)
- [ ] **Lifecycle hooks** appropriately implemented
- [ ] **Template refs** used instead of direct DOM manipulation

### Frappe Integration
- [ ] **SetVueGlobals(app)** called in all bundle entry points
- [ ] **Frappe context** properly provided to Vue components
- [ ] **Frappe API calls** implemented using `frappe.call()`
- [ ] **Frappe permissions** respected in component logic
- [ ] **Frappe translations** integrated using `__()` function

### 🚨 CRITICAL: Page Title Requirements
- [ ] **Page JSON has "title" field** - MANDATORY, NO EXCEPTIONS!
- [ ] **Page JSON has "icon" field** - MANDATORY for navigation
- [ ] **JavaScript sets title in 3 places:**
  - [ ] `frappe.ui.make_app_page({ title: 'Title' })`
  - [ ] `page.set_title(__('Title'))`
  - [ ] `document.title = __('Title') + ' | ' + frappe.boot.sitename`
- [ ] **Vue component receives title** from page context
- [ ] **Title displays in page header** visually

### Component Implementation
- [ ] **Props validation** implemented with proper types
- [ ] **Event emissions** properly declared and documented
- [ ] **Slot usage** implemented where appropriate
- [ ] **Scoped styles** used to prevent CSS conflicts
- [ ] **Component exposure** implemented for parent access

### Code Quality
- [ ] **ESLint rules** followed without errors
- [ ] **Code formatting** consistent (Prettier or similar)
- [ ] **Import statements** organized properly
- [ ] **Variable naming** follows conventions (camelCase, PascalCase)
- [ ] **Function decomposition** implemented for complex logic

## User Interface Standards

### Frappe UI Integration
- [ ] **Frappe UI components** used instead of custom implementations
- [ ] **Design system consistency** maintained across components
- [ ] **Color palette** follows Frappe UI standards
- [ ] **Typography scale** properly implemented
- [ ] **Spacing system** consistently applied

### Responsive Design
- [ ] **Mobile-first approach** implemented
- [ ] **Breakpoint strategy** defined and consistently used
- [ ] **Touch interactions** properly handled on mobile devices
- [ ] **Viewport meta tag** configured correctly
- [ ] **Flexible layouts** implemented using CSS Grid/Flexbox

### Accessibility
- [ ] **Semantic HTML** used throughout components
- [ ] **ARIA attributes** properly implemented
- [ ] **Keyboard navigation** fully functional
- [ ] **Screen reader compatibility** verified
- [ ] **Color contrast** meets WCAG AA standards
- [ ] **Focus management** properly implemented

### Performance Optimization
- [ ] **Component lazy loading** implemented where appropriate
- [ ] **Bundle splitting** configured for optimal loading
- [ ] **Image optimization** applied to all assets
- [ ] **Virtual scrolling** implemented for large lists
- [ ] **Memoization** used for expensive computations

## API Integration

### Backend API Design
- [ ] **@frappe.whitelist()** decorator used on ALL exposed methods - NO EXCEPTIONS!
- [ ] **Permission checks** MUST be FIRST operation after try block
- [ ] **frappe.throw()** used for ALL errors - NEVER raise Exception
- [ ] **NO 'import requests'** - Use frappe.make_get_request() instead
- [ ] **Input validation** performed on server side
- [ ] **Error handling** comprehensive and user-friendly
- [ ] **Response formats** consistent across endpoints
- [ ] **API returns page titles** when needed for UI display

### Frontend API Integration
- [ ] **API service layer** implemented for centralized calls
- [ ] **Error handling** implemented with user feedback
- [ ] **Loading states** managed properly
- [ ] **Caching strategy** implemented where appropriate
- [ ] **Retry logic** implemented for failed requests

### Real-time Features
- [ ] **Frappe real-time events** integrated where needed
- [ ] **WebSocket connections** properly managed
- [ ] **Event subscriptions** cleaned up on component unmount
- [ ] **Real-time state updates** synchronized across components
- [ ] **Connection status** handled gracefully

## Testing Strategy

### Unit Testing
- [ ] **Component tests** written for all major components
- [ ] **Composable tests** implemented for reusable logic
- [ ] **API service tests** cover all endpoint integrations
- [ ] **State management tests** verify store behavior
- [ ] **Test coverage** meets minimum requirements (80%+)

### Integration Testing
- [ ] **Component integration** tested across the application
- [ ] **API integration** tested with backend services
- [ ] **User workflow testing** covers complete user journeys
- [ ] **Real-time feature testing** verifies live updates
- [ ] **Error scenario testing** covers edge cases

### End-to-End Testing
- [ ] **Critical user paths** covered by E2E tests
- [ ] **Cross-browser testing** performed on target browsers
- [ ] **Mobile device testing** covers responsive behavior
- [ ] **Performance testing** validates load times and interactions
- [ ] **Accessibility testing** using automated tools

## Security Implementation

### Input Validation
- [ ] **Client-side validation** implemented for user experience
- [ ] **Server-side validation** enforced for security
- [ ] **XSS prevention** implemented in all user inputs
- [ ] **CSRF protection** enabled for state-changing operations
- [ ] **SQL injection prevention** using parameterized queries

### Authentication & Authorization
- [ ] **Frappe session management** properly integrated
- [ ] **Permission-based UI** shows/hides features appropriately
- [ ] **API authorization** verified on every request
- [ ] **Role-based access control** implemented correctly
- [ ] **Sensitive data protection** implemented in frontend

### Data Security
- [ ] **HTTPS enforcement** in production environment
- [ ] **Secure cookie settings** configured properly
- [ ] **Data sanitization** performed before display
- [ ] **Sensitive information** not exposed in frontend
- [ ] **Content Security Policy** configured appropriately

## Performance Optimization

### Bundle Optimization
- [ ] **Code splitting** implemented by route/feature
- [ ] **Lazy loading** configured for heavy components
- [ ] **Tree shaking** eliminating unused code
- [ ] **Bundle analysis** performed and optimized
- [ ] **Vendor chunks** properly separated

### Runtime Performance
- [ ] **Virtual scrolling** implemented for large datasets
- [ ] **Debouncing** implemented for search and input handlers
- [ ] **Memoization** used for expensive calculations
- [ ] **Efficient re-rendering** optimized using keys and watchers
- [ ] **Memory leaks** prevented in event listeners and timers

### Loading Performance
- [ ] **Critical CSS** inlined for above-the-fold content
- [ ] **Resource preloading** configured for critical assets
- [ ] **Image lazy loading** implemented
- [ ] **Progressive loading** implemented for data-heavy views
- [ ] **Caching strategies** implemented for static assets

## Production Readiness

### Build Process
- [ ] **Production build** configured and tested
- [ ] **Asset minification** enabled for CSS and JS
- [ ] **Source maps** configured appropriately for debugging
- [ ] **Environment variables** properly configured
- [ ] **Build pipeline** automated and documented

### Error Handling
- [ ] **Global error boundary** implemented for unhandled errors
- [ ] **User-friendly error messages** displayed appropriately
- [ ] **Error logging** configured for production monitoring
- [ ] **Fallback UI** implemented for error states
- [ ] **Recovery mechanisms** implemented where possible

### Monitoring & Analytics
- [ ] **Performance monitoring** configured (Core Web Vitals)
- [ ] **Error tracking** implemented (Sentry or similar)
- [ ] **User analytics** configured (if required)
- [ ] **Load testing** performed under expected traffic
- [ ] **Health checks** implemented for critical functionality

## Deployment

### Pre-Deployment
- [ ] **Code review** completed by team members
- [ ] **All tests passing** in CI/CD pipeline
- [ ] **Security scan** performed and issues resolved
- [ ] **Performance benchmarks** met or improved
- [ ] **Documentation** updated for new features

### Deployment Process
- [ ] **Database migrations** executed successfully
- [ ] **Asset building** completed without errors
- [ ] **Cache clearing** performed after deployment
- [ ] **Service restart** executed if required
- [ ] **Deployment verification** performed in production

### Post-Deployment
- [ ] **Functionality testing** performed in production
- [ ] **Performance monitoring** checked for regressions
- [ ] **Error rates** monitored for anomalies
- [ ] **User feedback** collected and addressed
- [ ] **Rollback plan** ready if issues arise

## Documentation

### Code Documentation
- [ ] **Component APIs** fully documented
- [ ] **Props and events** documented with examples
- [ ] **Complex logic** explained with inline comments
- [ ] **Architecture decisions** documented in README
- [ ] **API endpoints** documented with request/response examples

### User Documentation
- [ ] **User guide** created for new features
- [ ] **Admin documentation** updated for configuration
- [ ] **Troubleshooting guide** provided for common issues
- [ ] **Video tutorials** created for complex workflows
- [ ] **Change log** maintained for version history

### Developer Documentation
- [ ] **Setup instructions** clear and comprehensive
- [ ] **Development workflow** documented
- [ ] **Testing procedures** documented
- [ ] **Deployment process** documented
- [ ] **Contribution guidelines** established

## Maintenance Planning

### Code Maintenance
- [ ] **Dependency updates** scheduled regularly
- [ ] **Security patches** applied promptly
- [ ] **Performance monitoring** ongoing
- [ ] **Code refactoring** planned for technical debt
- [ ] **Version upgrade path** planned for framework updates

### User Support
- [ ] **Support channels** established and documented
- [ ] **Issue tracking** system configured
- [ ] **User feedback** collection mechanism implemented
- [ ] **Training materials** kept up to date
- [ ] **Knowledge base** maintained and accessible

### Continuous Improvement
- [ ] **Performance metrics** tracked over time
- [ ] **User satisfaction** measured and improved
- [ ] **Feature usage** analyzed for optimization opportunities
- [ ] **Technical debt** regularly assessed and addressed
- [ ] **Team knowledge** shared and documented

## Sign-off Checklist

### Technical Review
- [ ] **Code quality** meets team standards
- [ ] **Performance benchmarks** achieved
- [ ] **Security requirements** satisfied
- [ ] **Accessibility standards** met
- [ ] **Browser compatibility** verified

### Business Review
- [ ] **Functional requirements** completely implemented
- [ ] **User acceptance testing** completed successfully
- [ ] **Business stakeholder approval** obtained
- [ ] **Training requirements** identified and scheduled
- [ ] **Go-live plan** approved and scheduled

### Final Verification
- [ ] **Production environment** fully tested
- [ ] **Backup and recovery** procedures verified
- [ ] **Monitoring and alerting** configured and tested
- [ ] **Support documentation** complete and accessible
- [ ] **Team handover** completed (if applicable)

---

## Notes

- **Priority Levels**: Mark items as High (H), Medium (M), or Low (L) priority based on project requirements
- **Responsible Parties**: Assign team members to specific checklist sections
- **Timeline**: Set realistic deadlines for each major section
- **Review Schedule**: Plan regular checklist reviews throughout development
- **Adaptation**: Customize this checklist based on specific project needs

## Tools and Resources

- **Vue DevTools**: For component debugging and performance analysis
- **Frappe Developer Console**: For backend API testing and debugging
- **Lighthouse**: For performance and accessibility auditing
- **WAVE**: For accessibility testing
- **ESLint/Prettier**: For code quality and formatting

Remember: This checklist is a living document that should be updated based on project learnings and evolving best practices.