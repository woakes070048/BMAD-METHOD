# Stage 1: Product Owner Guide
## Creating Product Requirements Documents (PRD)

### Role Overview

As a Product Owner, you are responsible for defining WHAT needs to be built and WHY. You bridge the gap between business needs and technical implementation, ensuring the development team understands the business value and requirements.

### Key Responsibilities

1. **Vision Definition**: Articulate the product vision and goals
2. **Requirements Gathering**: Collect and document business requirements
3. **Stakeholder Management**: Coordinate with all stakeholders
4. **Success Criteria**: Define measurable outcomes
5. **Prioritization**: Determine feature priorities based on business value

## 🚀 BMAD Commands for Product Owners

### Quick Start Commands

```bash
# 1. Activate the Product Owner Agent
/bmadErpNext:agent:erpnext-product-owner

# 2. Once in agent mode, create your story/epic
*create-story    # Create a user story from requirements
*create-epic     # Create an epic for larger features
*help           # See all available commands
```

### Command Reference for Each Step

#### Step 1: Requirements Gathering
```bash
# Start requirements elicitation session
/bmadErpNext:task:erpnext-requirements-elicitation

# Run brainstorming session
/bmadErpNext:task:facilitate-erpnext-brainstorm
```

#### Step 2: Create PRD
```bash
# Activate Product Owner agent and create story/epic
/bmadErpNext:agent:erpnext-product-owner
*create-story   # Follow prompts to create PRD-based story
*create-epic    # For larger features requiring multiple stories
```

#### Step 3: Validate and Review
```bash
# In Product Owner agent mode:
*execute-checklist-po    # Run Product Owner validation checklist
*validate-story-draft requirements.md    # Validate specific requirements doc
```

#### Step 4: Break Down Large Documents
```bash
# In Product Owner agent mode:
*shard-doc large-requirements.md ./epics/    # Break large docs into smaller parts
```

## PRD Creation Process

### Step 1: Requirements Gathering

#### 1.1 Stakeholder Interviews

**Key Questions to Ask:**
- What business problem are we solving?
- Who are the users of this feature?
- What is the current process/pain point?
- What would success look like?
- What are the constraints (time, budget, technical)?

**Stakeholder Types:**
- End Users (daily system users)
- Business Managers (process owners)
- IT/Technical Team (system administrators)
- External Partners (if applicable)

#### 1.2 Current State Analysis

**Document:**
- Existing business processes
- Current system capabilities
- Pain points and inefficiencies
- Manual workarounds
- Data flow and touchpoints

**Tools:**
- Process flow diagrams
- User journey maps
- System architecture diagrams

#### 1.3 Future State Vision

**Define:**
- Desired business outcomes
- Improved processes
- User experience goals
- Integration requirements
- Performance expectations

### Step 2: PRD Structure

#### 💻 BMAD Command: Create PRD Template
```bash
# Use the ERPNext PRD template to get started
/bmadErpNext:agent:erpnext-product-owner
*create-story
# Follow the prompts - the agent will guide you through PRD creation
# based on the erpnext-prd-template.yaml
```

#### Core Sections of a PRD

```markdown
# [Product Name] Product Requirements Document

## 1. Executive Summary
Brief overview of the product/feature and its business value

## 2. Goals and Objectives
### Business Goals
- Goal 1: [Measurable business outcome]
- Goal 2: [Measurable business outcome]

### User Goals
- Enable [user type] to [achieve outcome]
- Reduce [metric] by [percentage]

## 3. Background and Context
### Current State
[Description of existing situation]

### Problem Statement
[Clear articulation of the problem]

### Proposed Solution
[High-level solution approach]

## 4. Scope
### In Scope
- Feature/capability 1
- Feature/capability 2

### Out of Scope
- Explicitly excluded items
- Future phase considerations

## 5. User Personas
### Primary Users
- **Role**: [User role]
- **Goals**: [What they want to achieve]
- **Pain Points**: [Current challenges]
- **Technical Proficiency**: [Level]

## 6. Functional Requirements
### FR1: [Requirement Name]
**Description**: [Detailed description]
**User Story**: As a [user], I want [feature] so that [benefit]
**Acceptance Criteria**:
- [ ] Criteria 1
- [ ] Criteria 2

## 7. Non-Functional Requirements
### Performance
- Page load time < 2 seconds
- Support 100 concurrent users

### Security
- Role-based access control
- Data encryption requirements

### Usability
- Mobile responsive design
- Accessibility compliance (WCAG 2.1)

## 8. Technical Specifications
### DocType Requirements
- New DocTypes needed
- Existing DocType modifications

### Integration Requirements
- External systems
- API requirements
- Data synchronization

## 9. Success Metrics
### KPIs
- Metric 1: [Measurement and target]
- Metric 2: [Measurement and target]

### Measurement Method
- How metrics will be tracked
- Reporting frequency

## 10. Dependencies
### Technical Dependencies
- System requirements
- Third-party services

### Business Dependencies
- Process changes
- Training requirements

## 11. Risks and Assumptions
### Risks
- Risk 1: [Description and mitigation]
- Risk 2: [Description and mitigation]

### Assumptions
- Assumption 1
- Assumption 2

## 12. Timeline
### Milestones
- Milestone 1: [Date]
- Milestone 2: [Date]

## 13. Appendices
### Mockups/Wireframes
### Process Flows
### Data Models
```

### Step 3: Requirements Prioritization

#### MoSCoW Method

**Must Have**: Critical for launch
- Core functionality
- Regulatory requirements
- Security essentials

**Should Have**: Important but not critical
- Significant value additions
- Efficiency improvements

**Could Have**: Nice to have
- User experience enhancements
- Additional features

**Won't Have**: Future consideration
- Out of scope items
- Phase 2 features

#### Priority Matrix

```
High Impact / Low Effort = Quick Wins (Do First)
High Impact / High Effort = Major Projects (Plan Carefully)
Low Impact / Low Effort = Fill-ins (Do if Time)
Low Impact / High Effort = Avoid
```

### Step 4: ERPNext-Specific Considerations

#### DocType Planning

**Questions to Answer:**
- What data entities are needed?
- How do they relate to existing DocTypes?
- What fields and field types are required?
- What are the permission requirements?

**Template:**
```yaml
DocType: CustomerPortal
Module: Customer
Fields:
  - fieldname: portal_user
    fieldtype: Link
    options: User
    reqd: 1
  - fieldname: access_level
    fieldtype: Select
    options: "Basic\nStandard\nPremium"
Permissions:
  - role: Customer
    read: 1
    write: 0
  - role: System Manager
    read: 1
    write: 1
```

#### Workflow Requirements

**Define:**
- Approval processes
- State transitions
- Role assignments
- Notification triggers

#### Integration Points

**Document:**
- Existing app integrations
- External system connections
- API requirements
- Data synchronization needs

### Step 5: Validation and Review

#### 💻 BMAD Commands: Validation Process
```bash
# Run the Product Owner master checklist
/bmadErpNext:agent:erpnext-product-owner
*execute-checklist-po    # Comprehensive PO validation checklist

# Validate specific story/epic documents
*validate-story-draft customer-portal-requirements.md
*correct-course         # Course correction if issues found
```

#### Stakeholder Review Checklist

- [ ] All stakeholders have reviewed the PRD
- [ ] Business requirements are clear and complete
- [ ] Technical feasibility confirmed
- [ ] Success metrics are measurable
- [ ] Risks are identified with mitigations
- [ ] Dependencies are documented
- [ ] Timeline is realistic

#### Technical Review Checklist

- [ ] DocType design is optimal
- [ ] Integration requirements are feasible
- [ ] Performance requirements are achievable
- [ ] Security requirements are addressed
- [ ] Scalability is considered

### Step 6: Handoff to Business Analyst

#### Handoff Package Includes:

1. **Approved PRD Document**
   - Signed off by all stakeholders
   - Version controlled
   - Clearly marked sections

2. **Supporting Documents**
   - Process flows
   - Mockups/wireframes
   - Data models
   - User research findings

3. **Priority Matrix**
   - Feature priorities
   - Phase planning
   - MVP definition

4. **Communication Plan**
   - Stakeholder contact list
   - Review schedule
   - Escalation path

## Best Practices

### DO's:
- ✅ Be specific and measurable
- ✅ Include visual aids (diagrams, mockups)
- ✅ Validate with actual users
- ✅ Consider edge cases
- ✅ Document assumptions
- ✅ Keep language clear and jargon-free
- ✅ Version control all changes

### DON'Ts:
- ❌ Include implementation details
- ❌ Make technical decisions
- ❌ Skip stakeholder validation
- ❌ Ignore non-functional requirements
- ❌ Forget about maintenance/support
- ❌ Assume everyone understands context

## Common Pitfalls and How to Avoid Them

### Pitfall 1: Vague Requirements
**Problem**: "The system should be fast"
**Solution**: "Page load time should be under 2 seconds for 95% of requests"

### Pitfall 2: Scope Creep
**Problem**: Requirements keep expanding
**Solution**: Clearly document "Out of Scope" items and defer to future phases

### Pitfall 3: Missing User Input
**Problem**: Requirements based on assumptions
**Solution**: Conduct user interviews and validate with prototypes

### Pitfall 4: Technical Constraints Ignored
**Problem**: Requirements that are technically infeasible
**Solution**: Include technical team in early reviews

### Pitfall 5: No Success Metrics
**Problem**: Cannot measure if product is successful
**Solution**: Define specific, measurable KPIs upfront

## Templates and Tools

### User Story Template
```
As a [type of user]
I want [feature/capability]
So that [benefit/value]

Acceptance Criteria:
Given [context]
When [action]
Then [outcome]
```

### Requirement Traceability Matrix
| Req ID | Description | Priority | Epic | Story | Status |
|--------|-------------|----------|------|-------|--------|
| FR001  | User login  | Must     | 1    | 1.1   | Draft  |
| FR002  | Dashboard   | Should   | 1    | 1.2   | Draft  |

### Stakeholder Matrix
| Stakeholder | Role | Interest | Influence | Engagement |
|-------------|------|----------|-----------|------------|
| John Doe    | End User | High | Medium | Weekly reviews |
| Jane Smith  | Manager | High | High | Approval required |

## Quality Checklist

Before marking PRD as complete:

- [ ] **Completeness**: All sections filled out
- [ ] **Clarity**: Requirements are unambiguous
- [ ] **Measurability**: Success criteria are quantifiable
- [ ] **Feasibility**: Technical team has validated
- [ ] **Traceability**: Requirements are numbered and tracked
- [ ] **Approval**: All stakeholders have signed off
- [ ] **Prioritization**: Features are prioritized
- [ ] **Risk Assessment**: Risks identified and mitigated

## 🎯 Three Scenarios: Choose Your Starting Point

### Scenario 1: 🌱 Greenfield - Fresh Start
**When to use**: "We're starting completely from scratch with just a business idea"

```bash
# Step 1: Start requirements gathering
/bmadErpNext:task:erpnext-requirements-elicitation
# Follow prompts to gather stakeholder requirements

# Step 2: Create the epic/story
/bmadErpNext:agent:erpnext-product-owner
*create-epic
# Answer prompts:
# - Epic Name: "Customer Portal"
# - Business Value: "Allow customers self-service access"
# - Key Features: Login, Order History, Support Tickets
# - Success Metrics: 50% reduction in support calls

# Step 3: Validate the epic
*execute-checklist-po
*shard-doc customer-portal-epic.md ./stories/
*exit
```

### Scenario 2: 📋 Greenfield - With Existing Specs
**When to use**: "We have designs, mockups, API specs, or detailed requirements already"

```bash
# Step 1: Analyze existing specifications
/bmadErpNext:task:shard-erpnext-doc existing-specs.md ./requirements/
# Break down existing documentation into ERPNext-friendly format

# Step 2: Validate specs against ERPNext patterns
/bmadErpNext:agent:erpnext-architect
*validate-requirements existing-specs.md
*check-frappe-patterns    # Ensure specs align with Frappe/ERPNext
*exit

# Step 3: Create PRD from validated specs
/bmadErpNext:agent:erpnext-product-owner
*create-epic              # Use validated specs as input
*execute-checklist-po     # Quick validation
*exit
```

### Scenario 3: 🏗️ Brownfield - Existing ERPNext App
**When to use**: "We have an existing ERPNext app that needs new features or fixes"

```bash
# Step 1: Analyze existing app
/bmadErpNext:agent:erpnext-architect
*analyze-app existing-app-name
*audit-compliance        # Check current code quality
*identify-integration-points
*exit

# Step 2: Define enhancement requirements
/bmadErpNext:agent:erpnext-product-owner
*create-story           # For new feature additions
*document-enhancement   # Document what needs to be added/fixed

# Step 3: Plan integration with existing code
*validate-story-draft enhancement-requirements.md
*check-compatibility    # Ensure new features won't break existing
*exit
```

### 🤔 Quick Decision Guide

**Choose Scenario 1 if:**
- Starting completely fresh
- Only have high-level business ideas
- Need to do stakeholder interviews

**Choose Scenario 2 if:**
- Have Figma designs, API docs, or wireframes
- Specs exist but aren't ERPNext-specific
- Want to fast-track to development

**Choose Scenario 3 if:**
- Modifying existing ERPNext app
- Adding features to live system
- Fixing bugs or improving performance

### Ready for Handoff ✅

Your PRD is now ready to hand off to the Business Analyst for epic breakdown and story creation.

## Next Steps

Once PRD is approved:

1. **Schedule Handoff Meeting** with Business Analyst
2. **Create Epic Breakdown** workshop  
3. **Establish Communication Cadence**
4. **Set up Tracking Mechanisms**
5. **Begin Epic Definition Process**

### 💻 Next Stage Command
```bash
# Move to Stage 2 - Business Analysis
# Hand off your completed PRD to the Business Analyst
# They will use: /bmadErpNext:agent:business-analyst
```

## Resources

- [ERPNext Documentation](https://docs.erpnext.com)
- [Frappe Framework Docs](https://frappeframework.com/docs)
- [User Story Examples](./templates/user-stories.md)
- [PRD Template](./templates/prd-template.md)

---

*Remember: The PRD is a living document. It should be updated as new information becomes available, but changes should be controlled and communicated to all stakeholders.*