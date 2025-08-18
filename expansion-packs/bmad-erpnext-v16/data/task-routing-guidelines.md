# Task Routing Guidelines for ERPNext Development

## Overview

This document provides comprehensive guidelines for Alex, the ERPNext Development Coordinator, on how to route tasks and coordinate development activities across the BMAD-ERPNext team. It complements the technical preferences and PRD-to-Tasks methodology by defining clear routing logic for different types of development activities.

## Agent Role Matrix

### Core Development Agents

#### **erpnext-architect**
**Primary Responsibilities:**
- ERPNext module architecture design
- DocType relationship planning
- Integration pattern design
- Performance optimization strategy

**Route Tasks To:**
- Complex DocType relationship design
- Multi-module architecture planning
- Database schema optimization
- Integration strategy development
- Large-scale system design decisions

**Escalate To:** `main-dev-coordinator` for cross-project architectural decisions

---

#### **doctype-designer**
**Primary Responsibilities:**
- DocType schema creation and modification
- Field configuration and validation
- Permission setup
- Database migration scripts

**Route Tasks To:**
- Creating new DocTypes
- Modifying existing DocType schemas
- Field type selection and configuration
- Setting up relationships between DocTypes
- Database migration planning

**Escalate To:** `erpnext-architect` for complex relationships

---

#### **api-architect** & **api-developer**
**Primary Responsibilities:**
- API endpoint design and implementation
- Authentication and security
- Integration with external systems
- Performance optimization

**Route Tasks To:**
- **api-architect**: High-level API design, security architecture
- **api-developer**: Implementation of specific endpoints, CRUD operations

**Escalate To:** `erpnext-architect` for system-wide API design decisions

---

#### **vue-frontend-architect** & **frappe-ui-developer**
**Primary Responsibilities:**
- Frontend architecture and component design
- User experience optimization
- Mobile responsiveness
- Performance optimization

**Route Tasks To:**
- **vue-frontend-architect**: Overall frontend architecture, routing, state management
- **frappe-ui-developer**: Component implementation, UI/UX details, specific features

**Escalate To:** `pwa-specialist` for mobile-specific challenges

### Specialized Teams

#### **complete_app_scaffolding_team**
**Members:** `app-scaffold-coordinator`, `erpnext-architect`, `business-analyst`, `vue-frontend-architect`, `frappe-ui-developer`, `api-architect`

**Route Tasks To:**
- Complete application generation from existing ERPNext data
- Large-scale Vue frontend scaffolding
- Multi-DocType relationship analysis
- Comprehensive UI generation projects

#### **business_analysis_team**
**Members:** `business-analyst`, `erpnext-architect`, `doctype-designer`, `api-architect`, `jinja-template-specialist`

**Route Tasks To:**
- Requirements gathering and analysis
- Business process mapping
- DocType business logic design
- Functional specification creation

#### **mobile_team**
**Members:** `mobile-ui-specialist`, `pwa-specialist`, `vue-frontend-architect`, `api-architect`

**Route Tasks To:**
- Mobile-first design requirements
- PWA implementation
- Offline functionality
- Mobile performance optimization

#### **automation_team**
**Members:** `workflow-converter`, `trigger-mapper`, `workflow-specialist`, `api-developer`

**Route Tasks To:**
- Workflow automation setup
- n8n integration conversion
- Event trigger configuration
- Automated business process implementation

## Task Assignment Logic

### By Task Category

#### **DocType Tasks**
```yaml
Primary Agent: doctype-designer
Secondary: erpnext-architect (for complex relationships)
Escalation: main-dev-coordinator (for breaking changes)

Task Types:
  - Schema creation/modification
  - Field configuration
  - Permission setup
  - Migration scripts
```

#### **Business Logic Tasks**
```yaml
Primary Agent: api-developer
Secondary: erpnext-architect (for complex business rules)
Escalation: business-analyst (for requirement clarification)

Task Types:
  - Validation logic
  - Workflow implementation
  - Custom methods
  - Event handlers
```

#### **Frontend Tasks**
```yaml
Primary Agent: frappe-ui-developer
Secondary: vue-frontend-architect (for architecture decisions)
Escalation: mobile-ui-specialist (for mobile challenges)

Task Types:
  - Component development
  - Form creation
  - List views
  - Custom interfaces
```

#### **API Tasks**
```yaml
Primary Agent: api-developer
Secondary: api-architect (for design decisions)
Escalation: erpnext-architect (for system-wide impact)

Task Types:
  - Endpoint implementation
  - Authentication setup
  - Data serialization
  - Rate limiting
```

#### **Integration Tasks**
```yaml
Primary Agent: api-architect
Secondary: workflow-specialist (for docflow integration)
Escalation: erpnext-architect (for multi-app compatibility)

Task Types:
  - External API integration
  - Multi-app coordination
  - Data synchronization
  - Webhook setup
```

#### **Testing Tasks**
```yaml
Primary Agent: testing-specialist
Secondary: Relevant domain specialist
Escalation: erpnext-qa-lead (for testing strategy)

Task Types:
  - Unit test creation
  - Integration testing
  - Performance testing
  - User acceptance testing
```

### By Complexity Level

#### **Low Complexity** (< 4 hours)
- Single agent assignment
- Clear requirements
- Standard patterns
- Minimal dependencies

**Routing:** Direct assignment to primary agent

#### **Medium Complexity** (4-16 hours)
- May require secondary agent consultation
- Some architectural considerations
- Multiple components affected

**Routing:** Primary agent + secondary consultation

#### **High Complexity** (> 16 hours)
- Multi-agent collaboration required
- Significant architectural impact
- Cross-cutting concerns

**Routing:** Team assignment + coordination meeting

## Escalation Pathways

### Level 1: Domain Expert
When a task requires deeper expertise within the same domain.

**Examples:**
- `doctype-designer` → `erpnext-architect` (complex relationships)
- `frappe-ui-developer` → `vue-frontend-architect` (architecture decisions)
- `api-developer` → `api-architect` (security concerns)

### Level 2: Cross-Domain Coordination
When a task affects multiple domains or requires cross-functional collaboration.

**Examples:**
- Any agent → `main-dev-coordinator` (cross-project impact)
- Frontend agents → `business-analyst` (requirement clarification)
- Any agent → `erpnext-qa-lead` (quality concerns)

### Level 3: Strategic Decision
When a task requires strategic or business-level decisions.

**Examples:**
- Technical leads → `erpnext-product-owner` (business priority)
- Any agent → `erpnext-scrum-master` (process issues)

## Integration Coordination Guidelines

### Multi-App Integration (docflow, n8n_integration)

#### **docflow Integration**
```yaml
Primary Coordinator: workflow-specialist
Support Team: [api-developer, doctype-designer]
Integration Points:
  - Workflow state management
  - Document approval processes
  - State transition triggers
  - Permission integration
```

#### **n8n_integration**
```yaml
Primary Coordinator: workflow-converter
Support Team: [trigger-mapper, api-developer]
Integration Points:
  - Webhook configuration
  - Event trigger setup
  - Data transformation
  - External system connectivity
```

### External System Integration

#### **API Integration Process**
1. **Analysis Phase:** `api-architect` defines integration strategy
2. **Implementation Phase:** `api-developer` builds endpoints and connections
3. **Testing Phase:** `testing-specialist` validates integration
4. **Documentation Phase:** Domain specialist documents the integration

#### **Data Migration Process**
1. **Assessment Phase:** `data-integration-expert` analyzes source data
2. **Mapping Phase:** `business-analyst` defines business rules
3. **Implementation Phase:** `doctype-designer` + `api-developer` build migration
4. **Validation Phase:** `testing-specialist` validates data integrity

## Priority Matrix Framework

### Priority Levels

#### **P0 - Critical (Same Day)**
- Production system down
- Data corruption issues
- Security vulnerabilities
- Blocking other team members

**Routing:** Immediate assignment to senior agent + escalation notification

#### **P1 - High (1-2 Days)**
- Core functionality broken
- Customer-facing issues
- Dependency blockers
- Release-critical bugs

**Routing:** Priority assignment with daily check-ins

#### **P2 - Medium (3-5 Days)**
- Feature enhancement
- Performance optimization
- Documentation updates
- Non-blocking improvements

**Routing:** Standard assignment process

#### **P3 - Low (1-2 Weeks)**
- Nice-to-have features
- Refactoring tasks
- Experimental features
- Technical debt cleanup

**Routing:** Assign during low-priority periods

### Task Prioritization Factors

#### **Business Impact** (Weight: 40%)
- Customer-facing functionality
- Revenue impact
- User experience improvement
- Compliance requirements

#### **Technical Dependencies** (Weight: 30%)
- Blocking other development
- Infrastructure requirements
- Integration complexity
- Technical debt implications

#### **Effort vs Value** (Weight: 20%)
- Development time estimate
- Maintenance overhead
- Reusability potential
- Learning value for team

#### **Risk Assessment** (Weight: 10%)
- Implementation complexity
- Testing requirements
- Rollback difficulty
- Impact of failure

## Routing Decision Tree

```
New Task Received
├── Is it production critical?
│   ├── Yes → P0 Priority → Senior Agent + Escalation
│   └── No → Continue Assessment
├── Does it affect multiple domains?
│   ├── Yes → Team Assignment + Coordination
│   └── No → Single Agent Assignment
├── Is expertise clear?
│   ├── Yes → Route to Primary Agent
│   └── No → Route to erpnext-architect for triage
├── Are requirements clear?
│   ├── Yes → Proceed with assignment
│   └── No → Route to business-analyst first
└── Complexity assessment
    ├── Low → Direct assignment
    ├── Medium → Primary + Secondary consultation
    └── High → Team collaboration required
```

## Communication Protocols

### Daily Coordination

#### **Stand-up Format**
- What did you complete yesterday?
- What are you working on today?
- What blockers do you have?
- Do you need coordination with other agents?

#### **Escalation Communication**
- Always include context and business impact
- Provide clear action items
- Set expectation for response time
- Follow up on resolution

### Weekly Planning

#### **Capacity Planning**
- Review agent workloads
- Identify potential bottlenecks
- Plan cross-training opportunities
- Assess team skill gaps

#### **Priority Review**
- Reassess P2 and P3 priorities
- Align with business objectives
- Consider technical debt balance
- Plan knowledge sharing sessions

## Success Metrics

### Individual Agent Metrics
- Task completion rate
- Quality metrics (bugs/rework)
- Response time to assignments
- Knowledge sharing contributions

### Team Coordination Metrics
- Cross-functional collaboration frequency
- Escalation resolution time
- Knowledge transfer effectiveness
- Overall project velocity

### System Health Metrics
- Integration stability
- Performance benchmarks
- Security compliance
- Documentation completeness

## Continuous Improvement

### Monthly Reviews
- Analyze routing effectiveness
- Identify process bottlenecks
- Gather agent feedback
- Update routing guidelines

### Quarterly Assessments
- Review team structure
- Assess skill development needs
- Evaluate technology stack
- Plan strategic improvements

## Conclusion

These task routing guidelines ensure efficient coordination of ERPNext development activities while maintaining high quality standards and clear accountability. Regular review and updates of these guidelines help adapt to changing project needs and team capabilities.

For Alex, as the ERPNext Development Coordinator, these guidelines provide a structured framework for making routing decisions, managing escalations, and ensuring effective team collaboration throughout the development lifecycle.