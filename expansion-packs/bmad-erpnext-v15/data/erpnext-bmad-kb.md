# ERPNext BMAD Knowledge Base

## ERPNext Development Methodology Using BMAD

This knowledge base provides comprehensive guidance for ERPNext development using the BMAD (Business Methodology for Agile Development) framework, specifically adapted for Frappe Framework and ERPNext ecosystem.

## ERPNext Environment Context

### Current Environment
- **Bench Path:** `/home/frappe/frappe-bench`
- **Primary Site:** `prima-erpnext.pegashosting.com`
- **Frappe Version:** 15.75.0
- **ERPNext Version:** 15.x
- **Development Directory:** `/home/frappe/bmad-erpnext-development`

### Installed Applications
- **frappe** (15.75.0) - Core framework
- **erpnext** (15.x) - Ready to install
- **docflow** (custom) - Workflow management system
- **n8n_integration** (custom) - Automation and workflow integration
- **payments** (15.x) - Available for installation

## BMAD ERPNext Development Principles

### 1. Frappe-First Development
**Core Principle:** Always use Frappe Framework built-in capabilities before considering external solutions.

**Implementation:**
- Use Frappe field types instead of custom validation
- Leverage Frappe UI components over external UI libraries
- Utilize Frappe API patterns for all endpoints
- Follow Frappe naming conventions and file structures
- Implement Frappe security patterns and permission models

**Examples:**
```python
# Good: Using Frappe built-in validation
def validate(self):
    if self.start_date > self.end_date:
        frappe.throw(_("Start Date cannot be after End Date"))

# Bad: Custom validation that duplicates Frappe capability
def validate(self):
    import datetime
    if datetime.strptime(self.start_date, '%Y-%m-%d') > datetime.strptime(self.end_date, '%Y-%m-%d'):
        raise Exception("Date error")
```

### 2. Mobile-First ERPNext Development
**Core Principle:** Design for mobile devices first, then enhance for desktop.

**Implementation:**
- Use responsive Frappe UI components
- Design touch-friendly interfaces
- Optimize for limited screen real estate
- Consider offline functionality where appropriate
- Implement Progressive Web App (PWA) features

### 3. Multi-App Integration Awareness
**Core Principle:** Always consider integration with existing apps in design decisions.

**Implementation:**
- Design DocTypes with docflow workflow integration in mind
- Plan automation hooks for n8n_integration
- Ensure compatibility with existing custom apps
- Design APIs for potential external integration
- Consider data synchronization requirements

## ERPNext BMAD Team Structure

### Management Layer
- **ERPNext Product Owner** - Business requirements validation and ERPNext fit analysis
- **ERPNext Scrum Master** - Story creation with ERPNext context and technical guidance
- **ERPNext QA Lead** - Framework compliance validation and integration testing
- **Main Development Coordinator** - Task routing to appropriate ERPNext specialists

### Technical Specialist Layer
- **ERPNext Architect** - Solution architecture and system design
- **DocType Designer** - DocType schema design and relationship modeling
- **API Developer** - ERPNext API development and security implementation
- **Vue Frontend Architect** - Vue.js integration with Frappe UI
- **Workflow Specialist** - docflow integration and automation design
- **Testing Specialist** - ERPNext-specific testing and validation
- **Integration Expert** - Multi-app integration and data synchronization

## ERPNext Development Workflow

### 1. Epic Creation Process
1. **Business Analysis** - ERPNext fit analysis and module planning
2. **Integration Assessment** - Multi-app compatibility analysis
3. **Epic Definition** - ERPNext-specific epic with DocType impact analysis
4. **Story Breakdown** - Stories sequenced by ERPNext development dependencies

### 2. Story Development Process
1. **Story Creation** - ERPNext Scrum Master creates detailed stories
2. **Story Validation** - Product Owner validates ERPNext business fit
3. **Specialist Assignment** - Main Dev Coordinator routes to appropriate specialist
4. **Development** - Specialist implements following Frappe patterns
5. **Integration Testing** - Validate multi-app compatibility
6. **QA Review** - Framework compliance and quality validation
7. **Deployment** - Bench operations and site deployment

### 3. Integration Coordination Process
1. **Integration Planning** - Identify touchpoints with existing apps
2. **Coordination Meetings** - Align with docflow and n8n_integration teams
3. **Parallel Development** - Coordinate changes across multiple apps
4. **Integration Testing** - Validate end-to-end workflows
5. **Deployment Coordination** - Synchronized deployment across apps

## ERPNext Technical Patterns

### DocType Development Pattern
```python
# Standard DocType Controller Pattern
import frappe
from frappe.model.document import Document

class CustomDocType(Document):
    def validate(self):
        """Validate document before save"""
        self.validate_required_fields()
        self.validate_business_rules()
        self.validate_integration_requirements()
    
    def before_save(self):
        """Process before saving"""
        self.set_calculated_fields()
        self.prepare_integration_data()
    
    def after_insert(self):
        """Process after document creation"""
        self.trigger_workflow()
        self.trigger_automation()
    
    def on_update(self):
        """Process after document update"""
        self.sync_related_documents()
        self.update_integration_systems()
```

### API Development Pattern
```python
# Standard API Endpoint Pattern
import frappe

@frappe.whitelist()
def get_custom_data(filters=None):
    """Get custom data with proper validation and security"""
    # Validate permissions
    if not frappe.has_permission("Custom DocType", "read"):
        frappe.throw(_("Insufficient permissions"))
    
    # Validate input
    if filters:
        filters = frappe.parse_json(filters)
    
    # Execute query
    data = frappe.get_all(
        "Custom DocType",
        filters=filters,
        fields=["name", "title", "status", "modified"]
    )
    
    return data

@frappe.whitelist()
def create_custom_document(doc_data):
    """Create document with validation"""
    # Validate permissions
    if not frappe.has_permission("Custom DocType", "create"):
        frappe.throw(_("Insufficient permissions"))
    
    # Create and save document
    doc = frappe.get_doc(doc_data)
    doc.insert()
    
    return doc.name
```

### Vue.js Component Pattern
```javascript
// Standard Vue Component with Frappe UI
<template>
  <div class="custom-component">
    <FrappeCard>
      <template #header>
        <h3>{{ title }}</h3>
      </template>
      <template #body>
        <FrappeList
          :data="listData"
          :loading="isLoading"
          @item-click="handleItemClick"
        />
      </template>
    </FrappeCard>
  </div>
</template>

<script>
import { FrappeCard, FrappeList } from 'frappe-ui'

export default {
  name: 'CustomComponent',
  components: {
    FrappeCard,
    FrappeList
  },
  data() {
    return {
      listData: [],
      isLoading: false
    }
  },
  methods: {
    async loadData() {
      this.isLoading = true
      try {
        const response = await this.$frappe.call({
          method: 'custom_app.api.get_custom_data',
          args: { filters: this.filters }
        })
        this.listData = response.message
      } catch (error) {
        this.$frappe.toast({
          title: 'Error loading data',
          text: error.message,
          type: 'error'
        })
      } finally {
        this.isLoading = false
      }
    }
  }
}
</script>
```

## Integration Patterns

### docflow Integration Pattern
```python
# DocType with workflow integration
def setup_workflow_integration(self):
    """Set up docflow workflow integration"""
    workflow_config = {
        "workflow_name": "Custom Approval Process",
        "doctype": self.doctype,
        "states": [
            {"state": "Draft", "style": "info"},
            {"state": "Pending Approval", "style": "warning"},
            {"state": "Approved", "style": "success"},
            {"state": "Rejected", "style": "danger"}
        ],
        "transitions": [
            {
                "state": "Draft",
                "action": "Submit for Approval",
                "next_state": "Pending Approval",
                "allowed": ["System Manager", "Custom Role"]
            }
        ]
    }
    return workflow_config
```

### n8n_integration Automation Pattern
```python
# Automation hook integration
def trigger_automation(self):
    """Trigger n8n automation workflows"""
    automation_data = {
        "trigger_type": "document_update",
        "doctype": self.doctype,
        "doc_name": self.name,
        "event_data": {
            "status": self.status,
            "priority": self.priority,
            "assigned_to": self.assigned_to
        }
    }
    
    # Send to n8n_integration
    frappe.enqueue(
        "n8n_integration.api.trigger_workflow",
        queue="default",
        timeout=300,
        **automation_data
    )
```

## Quality Standards

### Framework Compliance Score
- **10/10:** Perfect Frappe pattern adherence, no external dependencies
- **8-9/10:** Excellent compliance with minor deviations
- **6-7/10:** Good compliance with some optimization opportunities
- **4-5/10:** Acceptable but needs improvement
- **1-3/10:** Poor compliance, requires significant refactoring

### Integration Quality Score
- **10/10:** Seamless multi-app integration with robust error handling
- **8-9/10:** Excellent integration with minor edge cases
- **6-7/10:** Good integration with some coordination needs
- **4-5/10:** Acceptable but may have integration issues
- **1-3/10:** Poor integration, likely to cause conflicts

### Mobile Responsiveness Score
- **10/10:** Perfect mobile experience with PWA features
- **8-9/10:** Excellent mobile experience with responsive design
- **6-7/10:** Good mobile compatibility with minor issues
- **4-5/10:** Acceptable mobile experience but needs improvement
- **1-3/10:** Poor mobile experience, requires redesign

## Common ERPNext Anti-Patterns to Avoid

### 1. External Library Dependency
```python
# BAD: Using external library when Frappe has built-in capability
import requests  # External HTTP library
import pandas   # External data processing

# GOOD: Using Frappe built-in capabilities
import frappe.utils
import frappe.client
```

### 2. Direct Database Access
```python
# BAD: Direct SQL queries bypassing Frappe ORM
frappe.db.sql("SELECT * FROM `tabCustom DocType` WHERE status = 'Active'")

# GOOD: Using Frappe ORM methods
frappe.get_all("Custom DocType", filters={"status": "Active"})
```

### 3. Ignoring Mobile Responsiveness
```css
/* BAD: Fixed width design */
.custom-container {
    width: 1200px;
    position: fixed;
}

/* GOOD: Responsive design */
.custom-container {
    width: 100%;
    max-width: 1200px;
    margin: 0 auto;
}
```

### 4. Poor API Security
```python
# BAD: No permission checking
@frappe.whitelist(allow_guest=True)
def get_sensitive_data():
    return frappe.get_all("Sensitive DocType")

# GOOD: Proper permission validation
@frappe.whitelist()
def get_sensitive_data():
    if not frappe.has_permission("Sensitive DocType", "read"):
        frappe.throw(_("Insufficient permissions"))
    return frappe.get_all("Sensitive DocType")
```

## Performance Optimization Guidelines

### Database Query Optimization
- Use appropriate field selections in `get_all()` queries
- Implement proper indexing for frequently queried fields
- Use batch operations for bulk data processing
- Cache frequently accessed data appropriately

### Frontend Performance
- Lazy load Vue components where appropriate
- Implement virtual scrolling for large lists
- Optimize image loading and caching
- Use Frappe UI's built-in performance features

### Integration Performance
- Implement asynchronous processing for heavy integrations
- Use proper error handling and retry mechanisms
- Monitor integration performance and set appropriate timeouts
- Cache integration data where feasible

## Troubleshooting Guide

### Common Development Issues
1. **Bench Command Failures** - Check bench environment and permissions
2. **DocType Installation Errors** - Validate JSON structure and relationships
3. **Permission Errors** - Review role assignments and permission matrix
4. **Integration Failures** - Check app compatibility and API endpoints
5. **Frontend Build Errors** - Validate Vue.js setup and Frappe UI integration

### Performance Issues
1. **Slow Page Loading** - Optimize database queries and frontend assets
2. **API Timeouts** - Review API complexity and implement caching
3. **Mobile Performance** - Optimize mobile-specific code and assets
4. **Integration Bottlenecks** - Review integration patterns and async processing

### Security Issues
1. **Permission Bypass** - Review API whitelisting and permission checks
2. **Data Exposure** - Validate field-level permissions and API responses
3. **Integration Security** - Review authentication and data validation
4. **Input Validation** - Implement comprehensive input sanitization

## Continuous Improvement Process

### Regular Health Checks
- Weekly framework compliance assessments
- Monthly integration stability reviews
- Quarterly performance optimization reviews
- Annual architecture and pattern updates

### Knowledge Sharing
- Regular team training on Frappe Framework updates
- Documentation of lessons learned and best practices
- Cross-team collaboration sessions
- External ERPNext community engagement

### Process Evolution
- Continuous refinement of BMAD ERPNext processes
- Integration of new Frappe Framework features
- Adaptation to ERPNext ecosystem changes
- Enhancement of automation and quality tools