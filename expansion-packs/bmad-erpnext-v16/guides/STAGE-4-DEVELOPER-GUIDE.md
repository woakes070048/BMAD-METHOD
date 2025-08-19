# STAGE 4: Developer Guide - Technical Implementation

## Overview

This guide covers Stage 4 of the BMAD ERPNext v16 development process, focusing on technical implementation. This stage involves multiple specialized agents working together to build the ERPNext solution.

## Key Development Agents

### Backend Development
- **Paracelsus (doctype-designer)**: DocType creation and schema design
- **Douglas Fargo (api-developer)**: API endpoint development
- **Allison Blake (api-architect)**: API architecture and security
- **Zane Donovan (workflow-specialist)**: Workflow implementation

### Frontend Development
- **Helena Wells (vue-spa-architect)**: Vue 3 SPA development
- **Artie Nielsen (frappe-ui-developer)**: Frappe UI components
- **Beverly Barlowe (workspace-architect)**: Workspace and dashboard design

### Integration & Data
- **Nathan Stark (data-integration-expert)**: Data migration and integration
- **Grace Monroe (jinja-template-specialist)**: Templates and reports

## Stage Objectives

### Primary Goals
1. **Technical Implementation**: Build ERPNext features according to specifications
2. **Code Quality**: Ensure high-quality, maintainable code
3. **Testing**: Comprehensive testing at all levels
4. **Documentation**: Technical and user documentation

### Deliverables
- Functional ERPNext application
- Custom DocTypes and workflows
- API endpoints and integrations
- Vue.js frontend components
- Test suites
- Technical documentation

## Development Workflow

### 1. Environment Setup

**Commands:**
```bash
/bmadErpNext:agent:bench-operator
"Set up development environment for ERPNext v16 project"
```

**Setup Steps:**
- Frappe bench installation
- ERPNext app installation
- Development site creation
- Git repository setup

### 2. DocType Development

**Commands:**
```bash
/bmadErpNext:agent:doctype-designer
"Create DocType for [business entity] with these fields: [field list]"
```

**DocType Creation Process:**
```bash
*task create-doctype*
"Create [DocType Name] with specified fields and relationships"
```

**Key Considerations:**
- Field types and validation
- Relationships and links
- Permissions and roles
- Naming series
- Custom scripts

### 3. API Development

**Commands:**
```bash
/bmadErpNext:agent:api-developer
"Create secure API endpoint for [functionality] with proper validation"
```

**API Development Process:**
```bash
*task create-api-endpoint*
"Create API endpoint for [specific operation]"
```

**Security Requirements:**
- `@frappe.whitelist()` decorator
- Permission validation
- Input sanitization
- Error handling

### 4. Frontend Development

**Commands:**
```bash
/bmadErpNext:agent:vue-spa-architect
"Create Vue 3 SPA for [feature] using native Frappe integration"
```

**Frontend Process:**
```bash
*task create-vue-components*
"Create Vue components for [specific functionality]"
```

**Vue Integration:**
- Native Frappe asset pipeline
- `SetVueGlobals(app)` usage
- Frappe UI components
- Pinia state management

### 5. Workflow Implementation

**Commands:**
```bash
/bmadErpNext:agent:workflow-specialist
"Implement approval workflow for [business process]"
```

**Workflow Process:**
```bash
*task setup-workflow*
"Configure workflow for [DocType] with approval stages"
```

## Development Teams

### Complete App Development
```bash
*agent-team development-team*
"Implement complete ERPNext feature including DocTypes, APIs, and frontend"
```

### Modern App Development
```bash
*agent-team modern-app-team*
"Build modern ERPNext application with Vue SPA and PWA features"
```

### API Development Team
```bash
*agent-team deployment-team*
"Implement secure, scalable API architecture for ERPNext integration"
```

## Development Standards

### Code Quality Standards

**Python Code:**
- Follow PEP 8 style guidelines
- Use type hints where appropriate
- Comprehensive error handling
- Proper logging

**JavaScript/Vue Code:**
- ES6+ syntax
- Vue 3 Composition API
- TypeScript where beneficial
- Proper component structure

**Frappe-First Development:**
- Use Frappe utilities and methods
- Follow Frappe naming conventions
- Leverage Frappe's built-in features
- Proper DocType design patterns

### Testing Requirements

**Unit Testing:**
```bash
*task create-unit-tests*
"Create comprehensive unit tests for [component/feature]"
```

**Integration Testing:**
```bash
*task run-integration-tests*
"Execute integration tests for [feature/module]"
```

**Test Coverage:**
- Minimum 80% code coverage
- All API endpoints tested
- Frontend component testing
- Workflow testing

## Implementation Patterns

### DocType Implementation Pattern

```python
# DocType Controller Example
class CustomDocType(Document):
    def validate(self):
        """Validation before save"""
        self.validate_mandatory_fields()
        self.set_defaults()
        
    def before_save(self):
        """Logic before saving"""
        self.calculate_totals()
        
    def on_submit(self):
        """Logic when document is submitted"""
        self.create_ledger_entries()
        
    def on_cancel(self):
        """Logic when document is cancelled"""
        self.reverse_ledger_entries()
```

### API Implementation Pattern

```python
# API Endpoint Example
@frappe.whitelist()
def create_custom_record(data):
    """Create custom record with validation"""
    # Validate permissions
    if not frappe.has_permission("Custom DocType", "create"):
        frappe.throw(_("No permission to create"))
    
    try:
        # Create document
        doc = frappe.get_doc({
            "doctype": "Custom DocType",
            **data
        })
        doc.insert()
        
        return {
            "success": True,
            "name": doc.name,
            "message": _("Record created successfully")
        }
    except Exception as e:
        frappe.log_error(message=str(e), title="API Error")
        frappe.throw(_("Error creating record"))
```

### Vue Component Pattern

```vue
<template>
  <div class="custom-component">
    <div class="frappe-card">
      <div class="card-header">
        <h4>{{ title }}</h4>
      </div>
      <div class="card-body">
        <form @submit.prevent="handleSubmit">
          <div class="form-group">
            <label>{{ __('Field Name') }}</label>
            <input 
              v-model="formData.field"
              type="text"
              class="form-control"
              required
            />
          </div>
          <button type="submit" class="btn btn-primary">
            {{ __('Save') }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const formData = ref({
  field: ''
})

async function handleSubmit() {
  try {
    const result = await frappe.call({
      method: 'app.api.create_custom_record',
      args: formData.value
    })
    
    frappe.show_alert(__('Saved successfully'))
  } catch (error) {
    frappe.show_alert(__('Error saving data'))
  }
}
</script>
```

## Quality Assurance

### Code Review Process
```bash
/bmadErpNext:agent:erpnext-qa-lead
"Review code for [feature/component] ensuring ERPNext best practices"
```

### Testing Strategy
```bash
/bmadErpNext:agent:testing-specialist
"Create comprehensive testing strategy for ERPNext implementation"
```

### Performance Optimization
```bash
*task performance-analysis*
"Analyze and optimize performance for ERPNext application"
```

## Development Checklist

### Backend Development
- [ ] DocTypes created with proper schema
- [ ] Controllers implemented with business logic
- [ ] API endpoints secured and tested
- [ ] Workflows configured correctly
- [ ] Permissions set up properly

### Frontend Development
- [ ] Vue components built and tested
- [ ] Frappe UI integration complete
- [ ] Responsive design implemented
- [ ] PWA features added (if required)
- [ ] Performance optimized

### Integration
- [ ] External system integrations working
- [ ] Data migration completed
- [ ] API integrations tested
- [ ] Real-time features implemented

### Testing
- [ ] Unit tests written and passing
- [ ] Integration tests successful
- [ ] User acceptance testing completed
- [ ] Performance testing done
- [ ] Security testing passed

### Documentation
- [ ] Code documented with comments
- [ ] API documentation generated
- [ ] User guides created
- [ ] Technical documentation complete

## Common Development Tasks

### Create New Feature
```bash
*workflow modern-app-development*
"Implement [feature name] with complete frontend and backend"
```

### Add Integration
```bash
/bmadErpNext:agent:data-integration-expert
"Integrate ERPNext with [external system] for [purpose]"
```

### Optimize Performance
```bash
*task performance-analysis*
"Analyze and optimize performance bottlenecks"
```

### Add Mobile Support
```bash
*agent-team mobile-team*
"Add mobile support and PWA features to ERPNext application"
```

## Deployment Preparation

### Pre-deployment Checklist
```bash
*task pre-deployment-verification*
"Verify application readiness for deployment"
```

### Build Process
```bash
*task build-frontend*
"Build and optimize frontend assets for production"
```

## Handoff to Stage 5

### Deliverables for QA Team
- Functional application with all features implemented
- Comprehensive test suite
- Technical documentation
- Deployment artifacts

### Handoff Command
```bash
/bmadErpNext:agent:main-dev-coordinator
"Ready to hand off Stage 4 Development deliverables to QA Team for Stage 5"
```

## Success Metrics

### Code Quality
- All tests passing
- Code coverage > 80%
- No critical security issues
- Performance benchmarks met

### Feature Completeness
- All user stories implemented
- Acceptance criteria satisfied
- Integration points working
- Documentation complete

## Tips for Success

1. **Follow ERPNext Patterns**: Use established ERPNext development patterns
2. **Test Early and Often**: Write tests as you develop
3. **Code Reviews**: Regular peer reviews improve quality
4. **Performance Focus**: Consider performance from the start
5. **Documentation**: Document code and decisions as you go

## Development Resources

### ERPNext Development
- Frappe Framework documentation
- ERPNext developer guide
- Community forums and resources
- BMAD ERPNext patterns library

### Tools and Templates
- Development environment setup scripts
- Code templates and generators
- Testing frameworks and utilities
- CI/CD pipeline configurations

## Next Stage

Once Stage 4 is complete, proceed to [STAGE-5-QA-LEAD-GUIDE.md](STAGE-5-QA-LEAD-GUIDE.md) for quality assurance and testing.

---

**Stage 4 Owners**: Multiple specialized development agents  
**Estimated Duration**: 4-8 weeks depending on scope  
**Key Focus**: Implementation, Quality, Testing