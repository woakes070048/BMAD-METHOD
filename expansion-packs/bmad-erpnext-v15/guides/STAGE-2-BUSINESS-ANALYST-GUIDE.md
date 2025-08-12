# Stage 2: Business Analyst Guide
## Breaking PRDs into Epics

### Role Overview

As a Business Analyst, you transform high-level product requirements into actionable epics. You analyze the PRD, identify logical groupings of functionality, and ensure technical feasibility while maintaining business value. You bridge the gap between Product Owner vision and development team execution.

### Key Responsibilities

1. **PRD Analysis**: Deep dive into product requirements
2. **Epic Definition**: Create logical feature groupings
3. **Dependency Mapping**: Identify inter-epic dependencies
4. **Technical Validation**: Ensure feasibility with dev team
5. **Documentation**: Create comprehensive epic documentation

## 🚀 BMAD Commands for Business Analysts

### Quick Start Commands

```bash
# 1. Activate the Business Analyst Agent
/bmadErpNext:agent:business-analyst

# 2. Essential Business Analysis tasks
/bmadErpNext:task:erpnext-requirements-elicitation
/bmadErpNext:task:facilitate-erpnext-brainstorm

# 3. Document project (for epic creation)
/bmadErpNext:task:document-erpnext-project
```

### Command Reference for Each Step

#### Step 1: PRD Analysis
```bash
# Analyze the incoming PRD
/bmadErpNext:agent:business-analyst
*analyze-requirements prd-document.md
*identify-patterns      # Find common patterns in requirements
*map-dependencies      # Create dependency map
*exit
```

#### Step 2: Epic Creation
```bash
# Use Product Owner agent to create epics from PRD analysis
/bmadErpNext:agent:erpnext-product-owner
*create-epic           # Create epic from your analysis
*shard-doc large-prd.md ./epics/  # Break large PRD into epic-sized chunks
*exit
```

#### Step 3: Technical Validation
```bash
# Review with architect for technical feasibility
/bmadErpNext:agent:erpnext-architect
*review-requirements   # Technical feasibility review
*validate-architecture # Ensure architecture supports requirements
*exit
```

## Epic Creation Process

### Step 1: PRD Analysis and Decomposition

#### 1.1 Requirement Clustering

**Group Related Requirements:**
```
PRD Requirements → Functional Groups → Epics

Example:
PRD: "Customer Portal"
├── Group: "Account Management"
│   ├── FR1: User Registration
│   ├── FR2: Profile Management
│   └── FR3: Password Reset
│   → Epic 1: "User Account Management"
│
├── Group: "Order Management"
│   ├── FR4: View Orders
│   ├── FR5: Track Shipments
│   └── FR6: Download Invoices
│   → Epic 2: "Order Self-Service"
│
└── Group: "Support"
    ├── FR7: Submit Tickets
    └── FR8: View FAQ
    → Epic 3: "Customer Support Portal"
```

#### 1.2 Epic Sizing Guidelines

**Ideal Epic Size:**
- **Duration**: 2-4 weeks of development
- **Stories**: 3-8 user stories
- **Scope**: Single business capability
- **Independence**: Can be released independently

**Too Large (Split It):**
- More than 8 stories
- Multiple business processes
- Crosses multiple modules
- Takes more than 1 month

**Too Small (Combine It):**
- Only 1-2 stories
- Less than 1 week of work
- No standalone value
- Heavy dependencies

### Step 2: Epic Definition Structure

#### 💻 BMAD Command: Create Epic Document
```bash
# Create epic using ERPNext epic template
/bmadErpNext:agent:erpnext-product-owner
*create-epic
# Follow prompts based on erpnext-epic-template.yaml
# The agent will guide you through epic creation process
*exit
```

#### Epic Document Template

```markdown
# Epic [Number]: [Epic Title]

## Epic Overview

### Epic Statement
As a [user type],
I want [capability],
So that [business value]

### Business Value
[2-3 paragraphs explaining the business impact and value]

### Success Metrics
- Metric 1: [Specific measurable outcome]
- Metric 2: [Specific measurable outcome]

## Scope Definition

### In Scope
- Feature/capability included
- User groups served
- Business processes covered

### Out of Scope
- Explicitly excluded features
- Deferred to future epics
- Dependent on other systems

## ERPNext Context

### Affected Modules
- Module 1: [How it's impacted]
- Module 2: [How it's impacted]

### DocType Analysis
#### New DocTypes Required
| DocType Name | Purpose | Key Fields | Relationships |
|--------------|---------|------------|---------------|
| [Name] | [Purpose] | [Fields] | [Links] |

#### Modified DocTypes
| DocType Name | Modifications | Impact | Migration |
|--------------|---------------|---------|-----------|
| [Name] | [Changes] | [Impact] | [Required?] |

### Integration Points
- docflow workflows: [Requirements]
- n8n automations: [Requirements]
- External APIs: [Requirements]

## Technical Architecture

### High-Level Design
[Architecture diagram or description]

### Component Breakdown
- Backend Components
  - Controllers needed
  - API endpoints
  - Business logic
  
- Frontend Components
  - Vue.js components
  - UI/UX requirements
  - Mobile considerations

### Data Flow
[How data moves through the system]

## Story Breakdown

### Story List
| Story # | Title | Description | Priority | Effort | Dependencies |
|---------|-------|-------------|----------|---------|--------------|
| [#.1] | [Title] | [Brief description] | [H/M/L] | [Points] | [Dependencies] |
| [#.2] | [Title] | [Brief description] | [H/M/L] | [Points] | [Dependencies] |

### Story Sequence
```
Phase 1: Foundation
├── Story #.1: [Core infrastructure]
└── Story #.2: [Basic functionality]

Phase 2: Enhancement
├── Story #.3: [Advanced features]
└── Story #.4: [Integration]

Phase 3: Polish
└── Story #.5: [UI/UX improvements]
```

## Dependencies

### Internal Dependencies
- Epic [X] must complete before this epic
- Shared components with Epic [Y]
- Data from Epic [Z] required

### External Dependencies
- Third-party service availability
- Customer data migration
- Business process changes

## Risk Assessment

### Technical Risks
| Risk | Probability | Impact | Mitigation |
|------|-------------|---------|------------|
| [Risk description] | [H/M/L] | [H/M/L] | [Mitigation plan] |

### Business Risks
| Risk | Probability | Impact | Mitigation |
|------|-------------|---------|------------|
| [Risk description] | [H/M/L] | [H/M/L] | [Mitigation plan] |

## Acceptance Criteria

### Epic-Level Acceptance Criteria
1. [High-level criteria for epic completion]
2. [Business process validation]
3. [Integration verification]
4. [Performance requirements met]
5. [Security requirements satisfied]

## Effort Estimation

### Resource Requirements
- Development: [X] developers for [Y] weeks
- Testing: [X] QA for [Y] weeks
- Infrastructure: [Requirements]

### Timeline
- Start Date: [Planned start]
- End Date: [Planned end]
- Milestones:
  - Milestone 1: [Date] - [Deliverable]
  - Milestone 2: [Date] - [Deliverable]

## Appendices

### Mockups/Wireframes
[Links or embedded images]

### Process Flows
[Business process diagrams]

### Technical Specifications
[Detailed technical requirements]
```

### Step 3: Epic Analysis Techniques

#### 3.1 Business Process Mapping

**Current State → Future State Analysis:**

```
Current Process:
Customer → Email → Support → Manual Check → Response (2 days)

Future Process (Epic):
Customer → Portal → Automated Check → Instant Response
                  ↓
            Complex Issue → Support Ticket → Agent (4 hours)
```

#### 3.2 User Journey Mapping

**Map User Interactions:**
```
User Journey: Order Tracking
1. Login to Portal
2. Navigate to Orders
3. View Order List
4. Select Specific Order
5. View Order Details
6. Track Shipment
7. Download Invoice

Stories Identified:
- Story 1: Portal Authentication
- Story 2: Order List View
- Story 3: Order Detail View
- Story 4: Shipment Tracking Integration
- Story 5: Invoice Generation
```

#### 3.3 Technical Dependency Analysis

**Identify Technical Layers:**
```
Epic: Customer Portal
├── Data Layer
│   ├── Customer DocType Extension
│   ├── Portal Settings DocType
│   └── Session Management
├── Business Logic Layer
│   ├── Authentication Controller
│   ├── Order Retrieval Logic
│   └── Permission Validation
├── API Layer
│   ├── REST Endpoints
│   ├── Authentication
│   └── Rate Limiting
└── Presentation Layer
    ├── Vue.js Components
    ├── Mobile Responsive Design
    └── PWA Features
```

### Step 4: Story Identification

#### Story Patterns for ERPNext

**CRUD Stories:**
```
- Create [Entity]: User can create new records
- Read [Entity]: User can view records
- Update [Entity]: User can modify records
- Delete [Entity]: User can remove records
```

**Integration Stories:**
```
- Sync with [System]: Data synchronization
- Import from [Source]: Data migration
- Export to [Format]: Data extraction
- Webhook for [Event]: Real-time updates
```

**Workflow Stories:**
```
- Submit for Approval: Workflow initiation
- Approve/Reject: Decision points
- Escalate: Exception handling
- Notify: Communication triggers
```

**Reporting Stories:**
```
- View [Report]: Data visualization
- Filter [Data]: Data refinement
- Export [Report]: Report distribution
- Schedule [Report]: Automated reporting
```

### Step 5: Epic Validation

#### 5.1 Completeness Checklist

**Business Completeness:**
- [ ] All PRD requirements mapped to stories
- [ ] Business value clearly articulated
- [ ] Success metrics defined
- [ ] User personas addressed
- [ ] Edge cases considered

**Technical Completeness:**
- [ ] DocType design validated
- [ ] Integration points identified
- [ ] Performance requirements specified
- [ ] Security requirements addressed
- [ ] Mobile requirements included

#### 5.2 Feasibility Assessment

**Technical Feasibility:**
- Framework capabilities sufficient?
- Performance achievable?
- Integration possible?
- Security maintainable?

**Resource Feasibility:**
- Skills available?
- Timeline realistic?
- Budget adequate?
- Infrastructure ready?

### Step 6: Handoff to Scrum Master

#### Handoff Package

1. **Epic Documents**
   - Complete epic definitions
   - Story breakdowns
   - Dependency maps
   - Risk assessments

2. **Technical Specifications**
   - DocType designs
   - API specifications
   - Integration requirements
   - Architecture diagrams

3. **Resource Planning**
   - Effort estimates
   - Skill requirements
   - Timeline proposals
   - Dependency schedule

4. **Validation Results**
   - Technical review feedback
   - Business approval
   - Risk mitigation plans
   - Assumption validations

## Best Practices

### DO's:
- ✅ Maintain traceability to PRD requirements
- ✅ Include technical team in epic definition
- ✅ Create visual representations (diagrams, flows)
- ✅ Consider non-functional requirements
- ✅ Document assumptions and decisions
- ✅ Plan for iterative refinement
- ✅ Include buffer for unknowns

### DON'Ts:
- ❌ Create epics larger than 1 month
- ❌ Ignore dependencies between epics
- ❌ Skip technical feasibility validation
- ❌ Forget about data migration
- ❌ Overlook security implications
- ❌ Assume sequential execution only

## Common Pitfalls

### Pitfall 1: Epics Too Large
**Problem**: Epic takes 3 months to complete
**Solution**: Break into smaller, releasable chunks

### Pitfall 2: Missing Dependencies
**Problem**: Epic blocked by another team's work
**Solution**: Map all dependencies upfront, plan accordingly

### Pitfall 3: Unclear Boundaries
**Problem**: Overlap between epics causes confusion
**Solution**: Clear scope definition and ownership

### Pitfall 4: Technical Debt Ignored
**Problem**: Epic doesn't address existing issues
**Solution**: Include refactoring stories where needed

### Pitfall 5: No Business Value
**Problem**: Epic is purely technical with no user benefit
**Solution**: Tie technical work to business outcomes

## Analysis Tools and Techniques

### Impact Analysis Matrix
| Component | Impact Level | Changes Required | Risk |
|-----------|-------------|------------------|------|
| Sales Module | High | New fields, workflows | Medium |
| Customer DocType | Medium | Additional fields | Low |
| API Layer | High | New endpoints | Medium |

### Dependency Matrix
| Epic | Depends On | Blocks | Critical Path |
|------|------------|--------|---------------|
| Epic 1 | None | Epic 2, 3 | Yes |
| Epic 2 | Epic 1 | Epic 4 | Yes |
| Epic 3 | Epic 1 | None | No |

### Story Point Estimation
| Story Complexity | Points | Example |
|------------------|--------|---------|
| Trivial | 1 | Change label text |
| Simple | 2-3 | Add new field to form |
| Medium | 5-8 | Create new DocType |
| Complex | 13 | Integration with external API |
| Very Complex | 21 | Major architectural change |

## Quality Checklist

Before epic handoff:

- [ ] **Alignment**: Epic aligns with PRD goals
- [ ] **Completeness**: All aspects documented
- [ ] **Clarity**: Stories are well-defined
- [ ] **Feasibility**: Technical validation complete
- [ ] **Dependencies**: All dependencies mapped
- [ ] **Risks**: Risks identified and mitigated
- [ ] **Estimates**: Effort estimates provided
- [ ] **Acceptance**: Criteria clearly defined

## 🎯 Complete Workflow Example

### Example: Converting Customer Portal PRD to Epics

```bash
# Step 1: Receive PRD from Product Owner
# Review customer-portal-prd.md

# Step 2: Analyze and decompose requirements
/bmadErpNext:agent:business-analyst
*analyze-requirements customer-portal-prd.md
*identify-patterns
*map-dependencies
*exit

# Step 3: Create epics based on analysis
/bmadErpNext:agent:erpnext-product-owner
*create-epic
# Epic 1: "User Account Management"
# - User registration
# - Profile management  
# - Password reset

*create-epic
# Epic 2: "Order Self-Service"
# - View order history
# - Track shipments
# - Download invoices

*create-epic
# Epic 3: "Customer Support Portal"
# - Submit support tickets
# - View knowledge base
# - Chat integration
*exit

# Step 4: Validate technical feasibility
/bmadErpNext:agent:erpnext-architect
*review-requirements
*validate-architecture
*exit

# Step 5: Document and hand off to Scrum Master
/bmadErpNext:task:document-erpnext-project
```

### Ready for Handoff ✅

Your epics are now ready to hand off to the Scrum Master for story breakdown and sprint planning.

## Next Steps

After epic approval:

1. **Schedule Story Planning** with Scrum Master
2. **Technical Deep Dive** with Development Team
3. **Create Story Details** for each identified story
4. **Set up Tracking** for epic progress
5. **Establish Review Cadence** with stakeholders

### 💻 Next Stage Command
```bash
# Move to Stage 3 - Sprint Planning
# Hand off your completed epics to the Scrum Master
# They will use: /bmadErpNext:agent:erpnext-scrum-master
```

## Templates

### Epic Summary Template
```yaml
Epic:
  Number: [#]
  Title: [Epic Title]
  Value: [Business Value Statement]
  Duration: [Estimated Weeks]
  Stories: [Count]
  Priority: [High/Medium/Low]
  Dependencies: [List]
  Risks: [Count]
  Status: [Planning/Ready/In Progress/Done]
```

### Story Mapping Template
```
Epic Title
├── Must Have Stories
│   ├── Story 1: [Critical Feature]
│   └── Story 2: [Core Functionality]
├── Should Have Stories
│   ├── Story 3: [Important Feature]
│   └── Story 4: [Enhancement]
└── Could Have Stories
    └── Story 5: [Nice to Have]
```

## Resources

- [Epic Best Practices](./references/epic-practices.md)
- [Story Identification Guide](./references/story-guide.md)
- [ERPNext Module Guide](./references/module-guide.md)
- [Estimation Techniques](./references/estimation.md)

---

*Remember: Good epic definition sets the foundation for successful development. Take time to get it right, involve the right people, and document thoroughly.*