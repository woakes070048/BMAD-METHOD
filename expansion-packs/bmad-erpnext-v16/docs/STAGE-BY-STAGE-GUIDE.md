# Complete Stage-by-Stage Guide for ERPNext Development

This guide shows EXACTLY which agents to use at each stage, what commands to run, and what files to work with. Each agent name matches the actual agent files in the expansion pack.

## 🚀 Quick Start: Agent Activation

```bash
# To activate any agent, use:
/bmadErpNext:agent:{agent-id}

# Examples:
/bmadErpNext:agent:business-analyst
/bmadErpNext:agent:erpnext-architect
/bmadErpNext:agent:erpnext-product-owner
```

---

## 📊 Complete Stage-Agent-File Matrix

| Stage | Agent ID | Agent Name | Commands | Input Files | Output Files |
|-------|----------|------------|----------|-------------|--------------|
| **1. Business Analysis** | `business-analyst` | Myka Bering | `*analyze-business`, `*identify-modules`, `*create-brief` | Market research, Process docs | `docs/brief.md`, `docs/process-maps/` |
| **2. Requirements (PRD)** | `erpnext-architect` | Artie Nielsen | `*generate-prd`, `*analyze-requirements` | `docs/brief.md` | `docs/prd.md` |
| **3. Architecture** | `erpnext-architect` | Artie Nielsen | `*design-architecture`, `*create-app-structure` | `docs/prd.md` | `docs/architecture.md` |
| **4. Frontend Design** | `vue-spa-architect` | Helena Wells | `*create-frontend-spec`, `*design-components` | `docs/prd.md` | `docs/frontend-spec.md` |
| **5. Risk Assessment** | `erpnext-test-architect` | Quinn | `*risk`, `*design` | `docs/prd.md`, `docs/architecture.md` | `docs/qa/assessments/*-risk.md` |
| **6. Validation** | `erpnext-product-owner` | Mrs. Frederic | `*execute-checklist-po`, `*validate-epic` | All docs | Validation report |
| **7. Document Sharding** | `erpnext-product-owner` | Mrs. Frederic | `*shard-doc` | `docs/prd.md`, `docs/architecture.md` | `docs/epics/`, `docs/stories/` |
| **8. Story Creation** | `erpnext-scrum-master` | Pete Lattimer | `*draft`, `*story-checklist` | `docs/epics/*.md` | `docs/stories/*.md` |
| **9. Task Routing** | `development-coordinator` | Claudia Donovan | `*route-task`, `*assign-work` | `docs/stories/*.md` | Task assignments |
| **10. DocType Development** | `doctype-designer` | Paracelsus | `*create-doctype`, `*design-schema` | Story files, schemas | DocType files |
| **11. API Development** | `api-developer` | Douglas Fargo | `*create-api`, `*implement-endpoint` | Story files, DocTypes | API files |
| **12. Frontend Development** | `vue-spa-architect` | Helena Wells | `*create-component`, `*implement-spa` | Story files, APIs | Vue components |
| **13. Testing** | `testing-specialist` | Steve Jinks | `*create-tests`, `*run-tests` | Code files | Test files |
| **14. Quality Review** | `erpnext-test-architect` | Quinn | `*review`, `*trace`, `*nfr`, `*gate` | All code | QA gates |
| **15. Deployment** | `bench-operator` | Larry Haberman | `*build`, `*migrate`, `*deploy` | App files | Deployment logs |

---

## 📋 Stage 1: Business Analysis

### Agent: `business-analyst` (Myka Bering)

**Activation**:
```bash
/bmadErpNext:agent:business-analyst
```

**Commands to Run**:
```bash
*help                     # See all available commands
*analyze-business "Your business domain and requirements"
*identify-modules "What ERPNext modules are needed"
*map-processes "Map business processes to ERPNext"
*create-brief            # Generate business brief
```

**Files to Provide**:
```
Input/
├── existing-processes.md     # Current business processes
├── pain-points.md           # Problems to solve
├── competitor-analysis.md   # Market research
└── user-interviews.md       # User feedback
```

**Files Created**:
```
docs/
├── brief.md                 # Business brief document
├── process-maps/
│   ├── sales-process.md
│   └── inventory-flow.md
└── module-mapping.md        # ERPNext module recommendations
```

---

## 📋 Stage 2: Requirements Definition (PRD)

### Agent: `erpnext-architect` (Artie Nielsen)

**Activation**:
```bash
/bmadErpNext:agent:erpnext-architect
```

**Commands to Run**:
```bash
*help                        # See all available commands
*analyze-requirements        # Analyze business requirements
*generate-prd               # Create PRD (interactive if no brief)
*define-components          # Define DocTypes, APIs, Reports
```

**Files to Provide**:
```
docs/
├── brief.md                # From business analyst
└── requirements-raw.md     # Any additional requirements
```

**Files Created**:
```
docs/
├── prd.md                  # Complete PRD with:
│                          # - Functional Requirements
│                          # - Non-Functional Requirements
│                          # - DocType specifications
│                          # - API requirements
│                          # - User roles
└── component-list.md       # List of all components needed
```

---

## 📋 Stage 3: Technical Architecture

### Agent: `erpnext-architect` (Artie Nielsen)

**Activation**:
```bash
/bmadErpNext:agent:erpnext-architect
```

**Commands to Run**:
```bash
*design-architecture        # Create technical architecture
*plan-integration          # Design integrations
*assess-impact            # Analyze system impact
*document-decisions       # Document architecture decisions
```

**Files to Provide**:
```
docs/
├── prd.md                 # Complete PRD
└── existing-apps.md       # List of existing apps if any
```

**Files Created**:
```
docs/
├── architecture.md        # Technical architecture with:
│                         # - System design
│                         # - DocType schemas
│                         # - API specifications
│                         # - Database design
│                         # - Integration points
├── schemas/
│   ├── doctype1.yaml
│   └── doctype2.yaml
└── api-specs/
    └── openapi.yaml
```

---

## 📋 Stage 4: Frontend Design (If Vue SPA Needed)

### Agent: `vue-spa-architect` (Helena Wells)

**Activation**:
```bash
/bmadErpNext:agent:vue-spa-architect
```

**Commands to Run**:
```bash
*help                      # See all available commands
*analyze-requirements      # Review frontend needs
*design-architecture      # Create Vue architecture
*plan-components         # Design component hierarchy
*create-spa-structure    # Generate SPA structure
```

**Files to Provide**:
```
docs/
├── prd.md               # Requirements
├── architecture.md      # Backend architecture
└── ui-mockups/         # UI designs if available
```

**Files Created**:
```
docs/
├── frontend-spec.md     # Vue SPA specification
├── component-tree.md    # Component hierarchy
└── state-design.md      # Pinia store design
```

---

## 📋 Stage 5: Risk Assessment & Test Strategy

### Agent: `erpnext-test-architect` (Quinn)

**Activation**:
```bash
/bmadErpNext:agent:erpnext-test-architect
```

**Commands to Run**:
```bash
*help                    # See all available commands
*risk {story/prd}       # Assess risks (creates risk profile)
*design {story/prd}     # Create test strategy
*trace {story}          # Verify requirements coverage
*nfr {story}           # Assess non-functional requirements
```

**Files to Provide**:
```
docs/
├── prd.md
├── architecture.md
└── frontend-spec.md    # If applicable
```

**Files Created**:
```
docs/qa/assessments/
├── project-risk-20240315.md      # Risk assessment
├── project-test-design-20240315.md # Test strategy
└── risk-mitigation.md            # Mitigation plans
```

---

## 📋 Stage 6: Validation & Alignment

### Agent: `erpnext-product-owner` (Mrs. Frederic)

**Activation**:
```bash
/bmadErpNext:agent:erpnext-product-owner
```

**Commands to Run**:
```bash
*help                          # See all available commands
*execute-checklist-po         # Run master checklist
*validate-epic               # Validate epics against PRD
*validate-integration       # Check multi-app compatibility
*correct-course             # Fix any misalignments
```

**Files to Provide**:
```
docs/
├── prd.md
├── architecture.md
├── frontend-spec.md
└── qa/assessments/
```

**Files Created**:
```
docs/
├── validation-report.md
└── alignment-issues.md    # If any issues found
```

---

## 📋 Stage 7: Document Sharding

### Agent: `erpnext-product-owner` (Mrs. Frederic)

**Activation**:
```bash
/bmadErpNext:agent:erpnext-product-owner
```

**Commands to Run**:
```bash
*shard-doc "docs/prd.md" "docs/epics/"
*shard-doc "docs/architecture.md" "docs/technical/"
*doc-out                  # Output sharded documents
```

**Files to Provide**:
```
docs/
├── prd.md              # Complete PRD
└── architecture.md     # Complete architecture
```

**Files Created**:
```
docs/
├── epics/
│   ├── epic-001-user-management.md
│   ├── epic-002-core-features.md
│   └── epic-003-reporting.md
└── technical/
    ├── tech-001-doctypes.md
    ├── tech-002-apis.md
    └── tech-003-frontend.md
```

---

## 📋 Stage 8: Story Creation

### Agent: `erpnext-scrum-master` (Pete Lattimer)

**Activation**:
```bash
/bmadErpNext:agent:erpnext-scrum-master
```

**Commands to Run**:
```bash
*help                    # See all available commands
*draft                  # Create story from epic
*story-checklist       # Validate story completeness
*facilitate-session    # Brainstorm session if needed
```

**Files to Provide**:
```
docs/
├── epics/*.md          # Sharded epics
└── technical/*.md      # Technical specs
```

**Files Created**:
```
docs/stories/
├── epic-001.story-001.md
├── epic-001.story-002.md
└── epic-001.story-003.md
```

---

## 📋 Stage 9: Development Task Routing

### Agent: `development-coordinator` (Claudia Donovan)

**Activation**:
```bash
/bmadErpNext:agent:development-coordinator
```

**Commands to Run**:
```bash
*help                              # See all available commands
*safety-check                     # Analyze dependencies first
*route-task {task_description}   # Route to appropriate specialist
*assign-work {agent} {task}      # Direct assignment
*coordinate-handoff {from} {to}  # Manage handoffs
*check-progress                   # Review progress
```

**Task Routing Logic**:
| Task Type | Routes To | Agent ID |
|-----------|-----------|----------|
| DocType creation | Paracelsus | `doctype-designer` |
| API development | Douglas Fargo | `api-developer` |
| Vue frontend | Helena Wells | `vue-spa-architect` |
| Frappe UI | Holly Marten | `frappe-ui-developer` |
| Mobile UI | Todd Manning | `mobile-ui-specialist` |
| PWA features | Lexi Doig | `pwa-specialist` |
| Workflows | Zane Donovan | `workflow-specialist` |
| Data integration | Nathan Stark | `data-integration-expert` |
| Testing | Steve Jinks | `testing-specialist` |

---

## 📋 Stage 10: DocType Development

### Agent: `doctype-designer` (Paracelsus)

**Activation**:
```bash
/bmadErpNext:agent:doctype-designer
```

**Commands to Run**:
```bash
*help                     # See all available commands
*analyze-requirements    # Review DocType needs
*design-schema          # Design DocType structure
*create-doctype {name}  # Generate DocType
*setup-permissions      # Configure permissions
```

**Files to Provide**:
```
docs/
├── stories/current-story.md
├── technical/tech-001-doctypes.md
└── schemas/doctype-schema.yaml
```

**Files Created**:
```
app_name/app_name/doctype/
└── equipment_item/
    ├── equipment_item.py
    ├── equipment_item.json
    ├── equipment_item.js
    └── test_equipment_item.py
```

---

## 📋 Stage 11: API Development

### Agent: `api-developer` (Douglas Fargo)

**Activation**:
```bash
/bmadErpNext:agent:api-developer
```

**Commands to Run**:
```bash
*help                      # See all available commands
*analyze-api-needs        # Review API requirements
*create-endpoint         # Create API endpoint
*add-whitelisting       # Add @frappe.whitelist()
*implement-security     # Add permission checks
```

**Files to Provide**:
```
docs/
├── stories/current-story.md
├── technical/tech-002-apis.md
├── api-specs/openapi.yaml
└── app_name/doctype/    # Created DocTypes
```

**Files Created**:
```
app_name/
├── api/
│   ├── __init__.py
│   ├── equipment.py
│   └── rental.py
└── api_docs/
    └── equipment_api.md
```

---

## 📋 Stage 12: Frontend Development (Vue)

### Agent: `vue-spa-architect` (Helena Wells)

**Activation**:
```bash
/bmadErpNext:agent:vue-spa-architect
```

**Commands to Run**:
```bash
*help                     # See all available commands
*create-component        # Create Vue component
*setup-store           # Create Pinia store
*implement-routing     # Setup page routing
*integrate-api         # Connect to backend
```

**Files to Provide**:
```
docs/
├── stories/current-story.md
├── frontend-spec.md
└── app_name/api/        # Backend APIs
```

**Files Created**:
```
app_name/public/js/
├── equipment_dashboard.bundle.js
└── equipment_dashboard/
    ├── EquipmentDashboard.vue
    ├── components/
    │   ├── EquipmentList.vue
    │   └── EquipmentDetail.vue
    └── store.js
```

---

## 📋 Stage 13: Testing

### Agent: `testing-specialist` (Steve Jinks)

**Activation**:
```bash
/bmadErpNext:agent:testing-specialist
```

**Commands to Run**:
```bash
*help                    # See all available commands
*analyze-test-needs     # Review what needs testing
*create-unit-tests      # Create unit tests
*create-integration-tests # Create integration tests
*run-tests             # Execute tests
*generate-coverage     # Generate coverage report
```

**Files to Provide**:
```
app_name/
├── doctype/           # All DocTypes
├── api/              # All APIs
├── public/js/        # Frontend code
└── docs/stories/     # Requirements
```

**Files Created**:
```
app_name/tests/
├── test_equipment.py
├── test_api.py
├── test_integration.py
└── coverage/
    └── index.html
```

---

## 📋 Stage 14: Quality Review

### Agent: `erpnext-test-architect` (Quinn)

**Activation**:
```bash
/bmadErpNext:agent:erpnext-test-architect
```

**Commands to Run**:
```bash
*review {story}         # Comprehensive review
*trace {story}         # Check requirements coverage
*nfr {story}          # Check non-functional requirements
*gate {story}         # Create/update quality gate
```

**Files to Provide**:
```
ALL files related to the story:
app_name/             # Complete codebase
docs/stories/         # Story requirements
tests/               # Test files
```

**Files Created**:
```
docs/
├── stories/
│   └── {story}.md    # Updated with QA Results section
└── qa/
    └── gates/
        └── {story}-{date}.yml
```

---

## 📋 Stage 15: Deployment

### Agent: `bench-operator` (Larry Haberman)

**Activation**:
```bash
/bmadErpNext:agent:bench-operator
```

**Commands to Run**:
```bash
*help                    # See all available commands
*validate-app           # Check app structure
*build {app}           # Build frontend assets
*run-migrations        # Apply database changes
*run-tests            # Final test run
*deploy-staging       # Deploy to staging
*deploy-production    # Deploy to production
```

**Files to Provide**:
```
app_name/              # Complete app
deployment/
├── config.yaml       # Deployment config
└── requirements.txt  # Dependencies
```

**Files Created**:
```
logs/
├── build.log
├── migration.log
├── test.log
└── deployment.log
```

---

## 🔄 Special Purpose Agents

### For Troubleshooting

**Agent: `diagnostic-specialist` (No specific character)**
```bash
/bmadErpNext:agent:diagnostic-specialist
*diagnose-error "Error message"
*analyze-logs
*trace-issue
```

### For Code Cleanup

**Agent: `code-cleanup-specialist` (No specific character)**
```bash
/bmadErpNext:agent:code-cleanup-specialist
*analyze-code
*remove-unused
*optimize-imports
*fix-patterns
```

### For Compliance

**Agent: `frappe-compliance-validator` (Eva Thorne)**
```bash
/bmadErpNext:agent:frappe-compliance-validator
*validate-patterns
*check-anti-patterns
*enforce-frappe-first
```

### For Workspace Design

**Agent: `workspace-architect` (Beverly Barlowe)**
```bash
/bmadErpNext:agent:workspace-architect
*design-workspace
*create-dashboard
*setup-shortcuts
```

---

## 🎯 Complete Workflow Example

Here's a complete example workflow for building a new app:

```bash
# Stage 1: Business Analysis
/bmadErpNext:agent:business-analyst
*analyze-business "Equipment rental management system"
*create-brief

# Stage 2: Requirements
/bmadErpNext:agent:erpnext-architect
*generate-prd

# Stage 3: Architecture
/bmadErpNext:agent:erpnext-architect
*design-architecture

# Stage 4: Frontend Design (if needed)
/bmadErpNext:agent:vue-spa-architect
*create-frontend-spec

# Stage 5: Risk Assessment
/bmadErpNext:agent:erpnext-test-architect
*risk --prd "docs/prd.md"
*design --prd "docs/prd.md"

# Stage 6: Validation
/bmadErpNext:agent:erpnext-product-owner
*execute-checklist-po

# Stage 7: Sharding
/bmadErpNext:agent:erpnext-product-owner
*shard-doc "docs/prd.md" "docs/epics/"

# Stage 8: Story Creation
/bmadErpNext:agent:erpnext-scrum-master
*draft

# Stage 9: Task Routing
/bmadErpNext:agent:development-coordinator
*route-task "Create Equipment DocType"

# Stage 10: DocType Development
/bmadErpNext:agent:doctype-designer
*create-doctype "Equipment"

# Stage 11: API Development
/bmadErpNext:agent:api-developer
*create-endpoint

# Stage 12: Frontend (if needed)
/bmadErpNext:agent:vue-spa-architect
*create-component

# Stage 13: Testing
/bmadErpNext:agent:testing-specialist
*create-tests

# Stage 14: Review
/bmadErpNext:agent:erpnext-test-architect
*review "epic-001.story-001"

# Stage 15: Deployment
/bmadErpNext:agent:bench-operator
*deploy-staging
```

---

## 📁 Optimal File Structure

```
project/
├── docs/                      # Stage 1-8 outputs
│   ├── brief.md              # Stage 1: business-analyst
│   ├── prd.md                # Stage 2: erpnext-architect
│   ├── architecture.md       # Stage 3: erpnext-architect
│   ├── frontend-spec.md      # Stage 4: vue-spa-architect
│   ├── epics/                # Stage 7: erpnext-product-owner
│   ├── stories/              # Stage 8: erpnext-scrum-master
│   └── qa/                   # Stage 5,14: erpnext-test-architect
│       ├── assessments/
│       └── gates/
│
└── app_name/                  # Stage 10-13 outputs
    ├── doctype/              # Stage 10: doctype-designer
    ├── api/                  # Stage 11: api-developer
    ├── public/js/            # Stage 12: vue-spa-architect
    └── tests/                # Stage 13: testing-specialist
```

---

## ⚠️ Important Notes

1. **Agent IDs are exact** - Use the exact agent-id shown in this guide
2. **Commands require asterisk** - All commands use `*command` format
3. **Files build on each other** - Each stage uses outputs from previous stages
4. **Some agents serve multiple stages** - Like erpnext-architect and erpnext-test-architect
5. **Frappe-first is enforced** - All agents block external libraries when Frappe provides equivalent

This guide ensures you always know exactly which agent to activate and what commands to run at each stage of ERPNext development.