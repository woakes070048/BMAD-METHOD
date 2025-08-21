# Universal Folder Structure - MANDATORY FOR ALL AGENTS

## CRITICAL: This is the ONLY accepted folder structure. NO DEVIATIONS ALLOWED.

Every agent MUST use these exact paths. No searching, no guessing, no alternatives.

## Part 1: Expansion Pack Structure (BMAD Method)

```
/home/frappe/bmad-erpnext-development/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/
│
├── agents/                      # All agent definitions
│   ├── {agent-id}.md           # Individual agent files
│   └── README.md               # Agent registry
│
├── tasks/                      # Executable task workflows
│   ├── create-doctype.md
│   ├── create-api-endpoint.md
│   ├── scaffold-complete-app.md
│   └── [task-name].md
│
├── templates/                  # YAML/JSON templates
│   ├── doctype-structure.yaml
│   ├── handoff-template.yaml
│   ├── task-assignment-template.yaml
│   ├── project-structure-template.yaml
│   └── [template-name].yaml
│
├── workflows/                  # Multi-step workflows
│   ├── universal-context-detection-workflow.yaml
│   ├── quality-gate-enforcement-workflow.yaml
│   ├── bmad-planning-workflow.yaml
│   └── [workflow-name].yaml
│
├── checklists/                 # Validation checklists
│   ├── quality-gate-checklist.md
│   ├── pre-deployment.md
│   ├── post-deployment.md
│   └── [checklist-name].md
│
├── data/                       # Reference data files
│   ├── api-whitelisting-guide.md
│   ├── frappe-first-principles.md
│   ├── erpnext-best-practices.md
│   ├── native-vue-patterns-v16.md
│   └── [data-file].md
│
├── docs/                       # Documentation
│   ├── AGENT-ECOSYSTEM-ANALYSIS.md
│   ├── AGENT-ACTIVATION-SUMMARY.md
│   └── [doc-name].md
│
├── utils/                      # Utility scripts
│   └── [utility-name].py
│
├── CLAUDE.md                   # AI assistant guidelines
├── UNIVERSAL-FOLDER-STRUCTURE.md  # This file
├── FILE-REFERENCE-SYSTEM.md   # File discovery system
└── PROJECT-CONTEXT.yaml       # Dynamic project context
```

## THE THREE STRUCTURES - CRITICAL TO UNDERSTAND

### Structure 1: BMAD Expansion Pack (Lives in BMAD-METHOD directory)
**Location**: `/home/frappe/bmad-erpnext-development/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/`
**Purpose**: Agent definitions, templates, workflows - the AI tooling

### Structure 2: ERPNext App Code (Lives in frappe-bench/apps/)
**Location**: `/home/frappe/frappe-bench/apps/{app_name}/`
**Purpose**: The actual ERPNext application code (Python, DocTypes, APIs)

### Structure 3: BMAD Project Files (Lives in ERPNext app root)
**Location**: `/home/frappe/frappe-bench/apps/{app_name}/` (root level)
**Purpose**: Planning documents, project management, BMAD-specific files

## Part 2A: ERPNext App Code Structure (The Actual App)

```
/home/frappe/frappe-bench/apps/{app_name}/     # e.g., /home/frappe/frappe-bench/apps/customer_portal/
│
├── {app_name}/                # Python package directory (ACTUAL CODE)
│   ├── __init__.py
│   ├── hooks.py              # App configuration (CRITICAL)
│   ├── modules.txt           # Module list
│   ├── patches.txt           # Database patches
│   │
│   ├── api/                  # API endpoints (MUST use @frappe.whitelist())
│   │   ├── __init__.py
│   │   ├── customer.py       # Customer APIs
│   │   ├── orders.py         # Order APIs
│   │   └── {resource}.py     # Resource-based APIs
│   │
│   ├── {module_name}/        # Module directory (e.g., customer_management)
│   │   ├── __init__.py
│   │   │
│   │   ├── doctype/         # DocType definitions
│   │   │   └── {doctype_name}/    # PascalCase naming
│   │   │       ├── {doctype_name}.json
│   │   │       ├── {doctype_name}.py
│   │   │       ├── {doctype_name}.js
│   │   │       └── test_{doctype_name}.py
│   │   │
│   │   ├── page/            # Frappe pages for Vue
│   │   │   └── {page_name}/
│   │   │       ├── {page_name}.json
│   │   │       └── {page_name}.js
│   │   │
│   │   ├── report/          # Server-side reports
│   │   │   └── {report_name}/
│   │   │       ├── {report_name}.json
│   │   │       └── {report_name}.py
│   │   │
│   │   ├── print_format/    # Print formats
│   │   └── workflow/        # Workflow definitions
│   │
│   ├── public/              # Frontend assets
│   │   ├── js/              # JavaScript and Vue components
│   │   │   ├── {feature}.bundle.js    # Entry points
│   │   │   └── {feature}/             # Feature directory
│   │   │       ├── {Feature}.vue      # Main component
│   │   │       ├── components/        # Sub-components
│   │   │       │   └── {Component}.vue
│   │   │       └── stores/            # Pinia stores
│   │   │           └── {store}.js
│   │   │
│   │   └── css/            # Stylesheets
│   │       └── {app_name}.css
│   │
│   └── www/                # Web pages
│       └── __init__.py
│
├── tests/                   # Test directory (REQUIRED)
│   ├── unit/               # Unit tests
│   │   └── test_{component}.py
│   ├── integration/        # Integration tests
│   ├── plans/             # Test plans
│   │   └── {feature}-test-plan.md
│   ├── results/           # Test results
│   │   └── {date}-{type}-results.json
│   ├── coverage/          # Coverage reports
│   └── compliance/        # Compliance reports
│       └── {date}-audit.md
│
├── PROJECT_CONTEXT.yaml    # Dynamic context (AUTO-GENERATED)
├── pyproject.toml         # Python configuration
├── LICENSE
└── README.md              # App documentation
```

## Part 2B: BMAD Project Structure (Lives in ERPNext App Root)

```
/home/frappe/frappe-bench/apps/{app_name}/     # Same root as ERPNext app
│
├── .bmad-erpnext-v16/         # BMAD METHOD FOLDER (CRITICAL - Note the dot prefix!)
│   ├── project-config.yaml    # Project-specific BMAD configuration
│   ├── handoffs/              # Active handoff documents
│   │   └── {date}-{from}-{to}.yaml
│   ├── session-logs/          # Agent session tracking
│   │   └── {date}-{agent}-session.log
│   └── quality-reports/       # Quality gate results
│       └── {date}-quality-gate.yaml
│
├── docs/                      # BMAD Planning Documents (NOT app docs)
│   ├── prd.md                # Product Requirements Document
│   ├── architecture.md       # Technical Architecture
│   ├── PROJECT_STRUCTURE.md  # Project structure reference (this maps everything!)
│   ├── epics/                # Epic documents from PRD sharding
│   │   └── epic-{number}-{name}.md
│   ├── stories/              # Story documents from epic breakdown
│   │   └── story-{number}-{name}.md
│   └── planning/             # Additional planning docs
│       └── {document}.md
│
├── tests/                     # Test artifacts (separate from app tests)
│   ├── plans/                # Test planning documents
│   │   └── {feature}-test-plan.md
│   ├── results/              # Test execution results
│   │   └── {date}-{type}-results.json
│   ├── coverage/             # Coverage reports
│   │   └── {date}-coverage.html
│   └── compliance/           # Frappe-first compliance reports
│       └── {date}-audit.md
│
├── PROJECT_CONTEXT.yaml      # Project registry (CREATED BY PROJECT-INIT-STRUCTURE.sh)
├── .bmad-init               # Marker file indicating BMAD is initialized
└── .bmad-erpnext-v16        # SYMLINK to expansion pack (DO NOT MODIFY)
```

## Part 3: How The Three Structures Work Together

### THE CRITICAL SETUP PROCESS (MUST HAPPEN FIRST)

```bash
# 1. Create new ERPNext app
cd /home/frappe/frappe-bench
bench new-app {app_name}

# 2. Initialize BMAD structure (MANDATORY)
cd apps/{app_name}
/home/frappe/bmad-erpnext-development/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/utils/PROJECT-INIT-STRUCTURE.sh {app_name} {module_name}

# This script:
# - Creates all required folders
# - Sets up .bmad-erpnext-v16 symlink
# - Generates initial PROJECT_CONTEXT.yaml
# - Creates .bmad-init marker
# - Ensures structure compliance
```

### 1. BMAD Expansion Pack → ERPNext App
```yaml
# Agents access expansion pack via local symlink
working_directory: /home/frappe/frappe-bench/apps/{app_name}/
expansion_access: .bmad-erpnext-v16/  # Local symlink

# Example: Agent loads task
agent: "development-coordinator"
loads: ".bmad-erpnext-v16/tasks/create-doctype.md"
creates: "{app_name}/{module_name}/doctype/CustomerOrder/"
```

### 2. ERPNext App Code ← BMAD Planning
```yaml
# Planning documents inform code structure
planning_doc: /home/frappe/frappe-bench/apps/{app_name}/docs/architecture.md
creates_code: /home/frappe/frappe-bench/apps/{app_name}/{app_name}/api/customer.py
```

### 3. BMAD Project Files Track Everything
```yaml
# PROJECT_CONTEXT.yaml knows all locations
project_root: /home/frappe/frappe-bench/apps/{app_name}/
tracks:
  - expansion_pack: ../../../bmad-erpnext-development/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/
  - app_code: {app_name}/
  - planning_docs: docs/
  - test_artifacts: tests/
  - bmad_files: .bmad-erpnext-v16/
```

## Part 4: HOW THE .bmad-erpnext-v16 FOLDER WORKS (CRITICAL)

### The Bridge Between Expansion Pack and App

The `.bmad-erpnext-v16` folder is a **SYMLINK** created during project initialization:

```bash
# During project setup (AUTOMATIC via PROJECT-INIT-STRUCTURE.sh)
cd /home/frappe/frappe-bench/apps/{app_name}/
ln -s /home/frappe/bmad-erpnext-development/BMAD-METHOD/expansion-packs/bmad-erpnext-v16 .bmad-erpnext-v16

# Result: Agents can access expansion pack resources locally
.bmad-erpnext-v16 → /home/frappe/bmad-erpnext-development/BMAD-METHOD/expansion-packs/bmad-erpnext-v16
```

### Why This Matters
- Agents working in app context can access expansion pack resources via `.bmad-erpnext-v16/`
- No path confusion - always use local `.bmad-erpnext-v16/` prefix
- Automatically maintained - symlink never changes

## Part 5: Absolute Path Mappings (NO EXCEPTIONS)

### Expansion Pack Resources (Accessed via symlink from app)
```yaml
# From within ERPNext app, use local symlink
agents:        ".bmad-erpnext-v16/agents/{agent-id}.md"
tasks:         ".bmad-erpnext-v16/tasks/{task-name}.md"
templates:     ".bmad-erpnext-v16/templates/{template-name}.yaml"
workflows:     ".bmad-erpnext-v16/workflows/{workflow-name}.yaml"
checklists:    ".bmad-erpnext-v16/checklists/{checklist-name}.md"
data:          ".bmad-erpnext-v16/data/{data-file}.md"
```

### ERPNext App Resources (Within app)
```yaml
# EXACT paths - {app_name} and {module_name} are variables
prd:           "docs/prd.md"
architecture:  "docs/architecture.md"
project_struct: "docs/PROJECT_STRUCTURE.md"
epics:         "docs/epics/epic-{number}-{name}.md"
stories:       "docs/stories/story-{number}-{name}.md"
apis:          "{app_name}/api/{resource}.py"
doctypes:      "{app_name}/{module_name}/doctype/{doctype_name}/"
vue_bundles:   "{app_name}/public/js/{feature}.bundle.js"
vue_components: "{app_name}/public/js/{feature}/components/"
pages:         "{app_name}/{module_name}/page/{page_name}/"
tests:         "tests/{type}/"
test_results:  "tests/results/{date}-{type}-results.json"
hooks:         "{app_name}/hooks.py"
```

## Part 6: PROJECT_CONTEXT.yaml Specification (AUTO-GENERATED)

```yaml
# PROJECT_CONTEXT.yaml - Created by PROJECT-INIT-STRUCTURE.sh
# Location: /home/frappe/frappe-bench/apps/{app_name}/PROJECT_CONTEXT.yaml

project_context:
  # Basic project info (set during init)
  app_name: "customer_portal"
  module_name: "customer_management"
  created_date: "2024-12-20T10:00:00"
  bmad_version: "v16"
  
  # Paths (automatically maintained)
  paths:
    app_root: "/home/frappe/frappe-bench/apps/customer_portal/"
    expansion_pack: ".bmad-erpnext-v16/"  # Symlink
    
  # Document registry (updated as documents are created)
  documents:
    planning:
      prd: 
        exists: false
        path: "docs/prd.md"
        created_by: null
        created_date: null
      architecture:
        exists: false
        path: "docs/architecture.md"
      project_structure:
        exists: false
        path: "docs/PROJECT_STRUCTURE.md"
        
    development:
      epics: []  # Updated when epics are created
      stories: []  # Updated when stories are created
      
    testing:
      latest_results: null
      coverage_report: null
      
  # Component registry (updated as components are created)
  components:
    doctypes: []  # List of created DocTypes
    apis: []  # List of created API endpoints
    pages: []  # List of created pages
    vue_components: []  # List of Vue components
    
  # Quality metrics (updated by quality gates)
  quality:
    last_quality_gate: null
    compliance_status: "not_checked"
    test_coverage: 0
    
  # Handoff tracking
  handoffs:
    active: []
    completed: []
```

## Part 7: Agent Folder Knowledge (HARDCODED)

Every agent MUST have this in their configuration:

```yaml
folder_knowledge:
  # Expansion pack paths (relative to expansion pack root)
  expansion_pack:
    agents: "agents/"
    tasks: "tasks/"
    templates: "templates/"
    workflows: "workflows/"
    checklists: "checklists/"
    data: "data/"
    docs: "docs/"
    
  # ERPNext app paths (relative to app root)
  erpnext_app:
    # Documentation
    prd: "docs/prd.md"
    architecture: "docs/architecture.md"
    project_structure: "docs/PROJECT_STRUCTURE.md"
    epics: "docs/epics/"
    stories: "docs/stories/"
    
    # Code
    api: "{app_name}/api/"
    doctypes: "{app_name}/{module_name}/doctype/"
    pages: "{app_name}/{module_name}/page/"
    reports: "{app_name}/{module_name}/report/"
    
    # Frontend
    vue_bundles: "{app_name}/public/js/*.bundle.js"
    vue_components: "{app_name}/public/js/{feature}/"
    css: "{app_name}/public/css/"
    
    # Testing
    tests: "tests/"
    test_plans: "tests/plans/"
    test_results: "tests/results/"
    coverage: "tests/coverage/"
    compliance: "tests/compliance/"
    
    # Configuration
    hooks: "{app_name}/hooks.py"
    modules: "{app_name}/modules.txt"
    patches: "{app_name}/patches.txt"
    project_context: "PROJECT_CONTEXT.yaml"
```

## Part 5: File Resolution Algorithm (MANDATORY)

```python
def resolve_file_path(file_type, file_name=None, app_name=None, module_name=None):
    """
    MANDATORY file resolution - no alternatives allowed
    """
    # Step 1: Check if expansion pack resource
    expansion_paths = {
        'agent': 'agents/{}.md',
        'task': 'tasks/{}.md',
        'template': 'templates/{}.yaml',
        'workflow': 'workflows/{}.yaml',
        'checklist': 'checklists/{}.md',
        'data': 'data/{}.md'
    }
    
    if file_type in expansion_paths:
        return f".bmad-erpnext-v16/{expansion_paths[file_type].format(file_name)}"
    
    # Step 2: Check if ERPNext app resource
    app_paths = {
        'prd': 'docs/prd.md',
        'architecture': 'docs/architecture.md',
        'project_structure': 'docs/PROJECT_STRUCTURE.md',
        'api': f'{app_name}/api/{file_name}.py',
        'doctype': f'{app_name}/{module_name}/doctype/{file_name}/',
        'page': f'{app_name}/{module_name}/page/{file_name}/',
        'vue_bundle': f'{app_name}/public/js/{file_name}.bundle.js',
        'test_result': f'tests/results/{file_name}.json',
        'hooks': f'{app_name}/hooks.py'
    }
    
    if file_type in app_paths:
        return app_paths[file_type]
    
    # Step 3: ERROR - unknown file type
    raise ValueError(f"Unknown file type: {file_type}. Must use standard structure.")
```

## Part 6: Naming Conventions (ENFORCED)

### File Names
```
agents:        kebab-case with .md extension (erpnext-architect.md)
tasks:         kebab-case with .md extension (create-doctype.md)
templates:     kebab-case with .yaml extension (handoff-template.yaml)
workflows:     kebab-case with .yaml extension (quality-gate-workflow.yaml)
checklists:    kebab-case with .md extension (pre-deployment.md)
python files:  snake_case with .py extension (customer_api.py)
vue files:     PascalCase with .vue extension (CustomerDashboard.vue)
js bundles:    kebab-case with .bundle.js extension (customer-dashboard.bundle.js)
```

### Directory Names
```
app_name:      snake_case (customer_portal)
module_name:   snake_case (customer_management)
doctype_name:  PascalCase (CustomerOrder)
page_name:     snake_case (customer_dashboard)
```

## Part 7: Enforcement Rules

### VIOLATIONS RESULT IN:
1. **Immediate work stoppage** - No agent can proceed with wrong structure
2. **Automatic correction** - System creates missing folders
3. **Validation failure** - Quality gates block handoffs
4. **Compliance alerts** - Reported in compliance audits

### MANDATORY CHECKS:
1. **Before any work** - Validate folder structure exists
2. **During handoffs** - Verify all referenced files use correct paths
3. **In quality gates** - Check structure compliance
4. **In testing** - Validate test files in correct locations

## Part 8: Quick Reference Card

```bash
# Finding files - NO SEARCHING NEEDED
PRD:           docs/prd.md
Architecture:  docs/architecture.md
APIs:          {app_name}/api/*.py
DocTypes:      {app_name}/{module_name}/doctype/{DocTypeName}/
Vue Bundles:   {app_name}/public/js/*.bundle.js
Vue Components: {app_name}/public/js/{feature}/*.vue
Tests:         tests/unit/test_*.py
Test Results:  tests/results/*.json
Hooks:         {app_name}/hooks.py

# Expansion pack resources
Agent:         .bmad-erpnext-v16/agents/{agent-id}.md
Task:          .bmad-erpnext-v16/tasks/{task-name}.md
Template:      .bmad-erpnext-v16/templates/{template-name}.yaml
Workflow:      .bmad-erpnext-v16/workflows/{workflow-name}.yaml
Checklist:     .bmad-erpnext-v16/checklists/{checklist-name}.md
```

## Part 9: Implementation Checklist

- [ ] Every agent configuration includes `folder_knowledge` section
- [ ] PROJECT_CONTEXT.yaml uses these exact paths
- [ ] Handoff templates reference these paths
- [ ] Workflows validate this structure
- [ ] No relative paths used anywhere
- [ ] No searching or pattern matching needed
- [ ] All paths are deterministic

## CRITICAL REMINDER

**THIS STRUCTURE IS LAW**

- No variations
- No alternatives
- No exceptions
- No searching
- No guessing

Every file has ONE location. Every agent knows that location. Period.