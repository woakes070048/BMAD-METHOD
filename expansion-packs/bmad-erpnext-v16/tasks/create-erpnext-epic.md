# Create ERPNext Epic Task

## Purpose

Create a single ERPNext epic for focused enhancements that leverage the ERPNext framework. This task is for ERPNext-specific features or modifications that can be completed within a focused scope while maintaining Frappe Framework best practices and multi-app integration.

## When to Use This Task

**Use this task when:**

- The ERPNext enhancement can be completed in 1-5 stories
- No significant architectural changes to ERPNext core are required
- The enhancement follows existing Frappe Framework patterns
- DocType integration complexity is minimal to moderate
- Risk to existing ERPNext system is low
- Multi-app integration (docflow, n8n_integration) is straightforward

**Use the full ERPNext PRD/Architecture process when:**

- The enhancement requires multiple coordinated ERPNext modules
- Significant DocType relationship changes are needed
- Complex multi-app integration work is required
- Major Vue.js frontend architecture changes are necessary
- Risk assessment and ERPNext migration planning is required

## Instructions

### 1. ERPNext Project Analysis (Required)

Before creating the epic, gather essential information about the existing ERPNext project:

**Existing ERPNext Context:**

```yaml
erpnext_environment:
  bench_path: "/home/frappe/frappe-bench"
  site: "prima-erpnext.pegashosting.com"
  frappe_version: "15.75.0"
  erpnext_version: "15.x"
  
existing_apps:
  installed:
    - frappe
    - erpnext
    - docflow
    - n8n_integration
  available:
    - payments
    
current_doctypes:
  core: [list existing custom DocTypes]
  modules: [identify affected ERPNext modules]
  relationships: [map DocType relationships]
  
integration_points:
  docflow: [existing workflow integrations]
  n8n_integration: [current automation points]
  external_apis: [third-party integrations]
```

**Technical Stack Assessment:**
- Current Frappe UI implementation status
- Vue.js frontend architecture state
- Mobile responsiveness implementation
- PWA capabilities status
- API security and whitelisting current state

### 2. Epic Definition and Scope

#### 2.1 Define ERPNext Epic Scope

**Epic Title:** [Descriptive title with ERPNext context]

**Epic Description:**
```
As a [user type] working in ERPNext,
I want [capability/feature within ERPNext ecosystem]
So that [business value that leverages ERPNext strengths]
```

**ERPNext-Specific Constraints:**
- Must follow Frappe-first principles
- Must integrate seamlessly with existing DocTypes
- Must maintain multi-tenancy compatibility
- Must follow Frappe UI design patterns
- Must consider mobile-first approach
- Must validate against existing app integrations

#### 2.2 DocType Impact Analysis

**New DocTypes Required:**
```yaml
new_doctypes:
  - name: [DocType Name]
    module: [ERPNext Module]
    relationships: [Link fields, Child tables]
    permissions: [Role-based access]
    workflow_integration: [docflow compatibility]
```

**Modified DocTypes:**
```yaml
modified_doctypes:
  - name: [Existing DocType]
    changes: [Field additions, modifications]
    migration_required: [true/false]
    backward_compatibility: [impact assessment]
```

### 3. Story Breakdown and Planning

#### 3.1 Identify ERPNext Story Components

Break the epic into logical ERPNext development stories:

**Story Categories:**
1. **DocType Stories:** New DocType creation, existing DocType modifications
2. **Controller Stories:** Server-side business logic, validations, hooks
3. **API Stories:** Whitelisted API endpoints, integration points
4. **Frontend Stories:** Vue.js components, Frappe UI implementation
5. **Workflow Stories:** docflow integration, automation setup
6. **Integration Stories:** n8n_integration hooks, external API connections
7. **Testing Stories:** Unit tests, integration tests, UI tests
8. **Deployment Stories:** Migration scripts, bench commands

#### 3.2 Story Sequencing

Order stories based on ERPNext development dependencies:

1. **Foundation Stories:** DocType creation, basic controllers
2. **Logic Stories:** Business logic, validations, relationships
3. **API Stories:** Endpoint creation, security implementation
4. **Frontend Stories:** Vue components, Frappe UI integration
5. **Integration Stories:** Multi-app connections, automation
6. **Testing Stories:** Comprehensive testing across all layers
7. **Deployment Stories:** Migration and deployment procedures

### 4. ERPNext Integration Considerations

#### 4.1 Multi-App Integration Planning

**docflow Integration:**
- Workflow states and transitions
- Approval processes
- Document lifecycle management
- State change hooks and validations

**n8n_integration Integration:**
- Webhook trigger points
- Automation workflows
- External system synchronization
- Event-driven processes

#### 4.2 Frappe Framework Compliance

**Frappe-First Validation:**
- Use built-in Frappe capabilities over external libraries
- Follow Frappe naming conventions
- Implement proper permission frameworks
- Use Frappe field types and validations

**API Security Requirements:**
- Proper API whitelisting
- Authentication and authorization
- Rate limiting considerations
- Data sanitization and validation

### 5. Technical Architecture Planning

#### 5.1 Frontend Architecture

**Vue.js Components:**
- Frappe UI component usage
- Custom component requirements
- Mobile-responsive design patterns
- PWA implementation needs

**Data Flow:**
- Client-server communication patterns
- Real-time update requirements
- Caching strategies
- Offline functionality needs

#### 5.2 Backend Architecture

**Controller Design:**
- Business logic organization
- Validation frameworks
- Event handling patterns
- Performance considerations

**Database Schema:**
- Field type selections
- Index requirements
- Relationship modeling
- Migration strategy

### 6. Epic Documentation and Handoff

#### 6.1 Create Epic File

Using the `erpnext-epic-template.yaml`, create:
- `Epic-{number}-{title}.md`
- Include all story definitions
- Add technical specifications
- Document integration requirements
- Include testing strategies

#### 6.2 Quality Validation

**Epic Completeness Check:**
- All stories have clear acceptance criteria
- ERPNext-specific requirements are documented
- Multi-app integration is considered
- Frappe-first principles are enforced
- Testing strategy is comprehensive

#### 6.3 Handoff to ERPNext Scrum Master

- Epic marked as 'Ready for Story Creation'
- Technical context documented
- Integration points identified
- Risk assessment completed
- Story creation priority established

## Completion Criteria

- ERPNext epic created with complete technical context
- All stories identified and sequenced
- DocType impact analysis completed
- Multi-app integration requirements documented
- Frappe Framework compliance validated
- Frontend and backend architecture planned
- Epic marked as 'Ready for Story Creation'
- Handoff documentation prepared for Scrum Master

## Integration Points

- Coordinates with erpnext-product-owner for requirement validation
- Hands off to erpnext-scrum-master for story creation
- Integrates with existing ERPNext ecosystem
- Follows ERPNext development workflow patterns