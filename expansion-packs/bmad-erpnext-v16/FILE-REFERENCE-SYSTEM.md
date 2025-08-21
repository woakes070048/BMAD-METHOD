# File Reference System for Agent Handoffs

## Overview
This document defines how agents discover and access files during handoffs, ensuring every agent knows exactly where to find referenced documents, test results, and work artifacts.

## The Core Problem
When agents hand off work, they reference files that downstream agents need to find:
- ERPNext Architect creates PRD → Scrum Master needs to find it
- Developer creates code → Testing Specialist needs to find it
- Testing creates reports → Compliance Validator needs to find them

## Solution: Three-Layer Reference System

### Layer 1: Project Context Registry
**Location**: `PROJECT_CONTEXT.yaml` (root of each project)

```yaml
project_context:
  project_name: "customer_portal"
  created_date: "2024-12-20"
  
  # Core documents created by planning agents
  planning_documents:
    prd:
      path: "docs/prd.md"
      created_by: "erpnext-architect"
      created_date: "2024-12-20T10:00:00"
      version: "1.0.0"
      
    architecture:
      path: "docs/architecture.md"
      created_by: "erpnext-architect"
      created_date: "2024-12-20T11:00:00"
      depends_on: ["prd"]
      
    project_structure:
      path: "docs/PROJECT_STRUCTURE.md"
      created_by: "erpnext-architect"
      created_date: "2024-12-20T11:30:00"
      purpose: "Master reference for all project components"
      
  # Epics and stories created during sharding
  development_documents:
    epics:
      directory: "docs/epics/"
      created_by: "erpnext-product-owner"
      files:
        - "epic-001-user-authentication.md"
        - "epic-002-dashboard-creation.md"
        
    stories:
      directory: "docs/stories/"
      created_by: "erpnext-scrum-master"
      files:
        - "story-001-login-page.md"
        - "story-002-user-registration.md"
        
  # Test artifacts
  testing_documents:
    test_plans:
      directory: "tests/plans/"
      created_by: "testing-specialist"
      
    test_results:
      directory: "tests/results/"
      latest: "tests/results/2024-12-20-full-suite.json"
      
    compliance_reports:
      directory: "tests/compliance/"
      created_by: "frappe-compliance-validator"
      latest: "tests/compliance/2024-12-20-audit.md"
      
  # Code locations for validators
  code_structure:
    backend:
      api_endpoints: "{{app_name}}/api/"
      doctypes: "{{app_name}}/{{module_name}}/doctype/"
      controllers: "{{app_name}}/{{module_name}}/"
      
    frontend:
      vue_components: "{{app_name}}/public/js/"
      pages: "{{app_name}}/{{module_name}}/page/"
      bundles: "{{app_name}}/public/js/*.bundle.js"
```

### Layer 2: Handoff File References
Every handoff includes explicit file paths:

```yaml
# In handoff-template.yaml
work_completed:
  deliverables:
    - type: "documentation"
      description: "Product Requirements Document"
      location: "docs/prd.md"  # EXPLICIT PATH
      hash: "sha256:abc123..."  # File integrity check
      
    - type: "code"
      description: "Customer API endpoints"
      location: "customer_portal/api/customer.py"
      methods:
        - "get_customer_data: line 45"
        - "update_customer: line 78"
```

### Layer 3: Agent Discovery Patterns

#### Pattern 1: Context-First Discovery
```python
# Every agent starts by loading project context
def load_project_context():
    """Load PROJECT_CONTEXT.yaml to understand file structure"""
    context_path = "PROJECT_CONTEXT.yaml"
    if not os.path.exists(context_path):
        # Fallback to standard structure
        return get_standard_structure()
    
    with open(context_path) as f:
        return yaml.safe_load(f)

def find_referenced_file(file_type, file_name=None):
    """Find files using project context"""
    context = load_project_context()
    
    if file_type == "prd":
        return context['planning_documents']['prd']['path']
    elif file_type == "test_results":
        return context['testing_documents']['test_results']['latest']
    # ... etc
```

#### Pattern 2: Standard Directory Structure
```bash
# Agents know standard locations as fallback
STANDARD_STRUCTURE = {
    "prd": "docs/prd.md",
    "architecture": "docs/architecture.md",
    "project_structure": "docs/PROJECT_STRUCTURE.md",
    "epics": "docs/epics/",
    "stories": "docs/stories/",
    "api": "{app_name}/api/",
    "doctypes": "{app_name}/{module_name}/doctype/",
    "tests": "tests/",
    "test_plans": "tests/plans/",
    "test_results": "tests/results/"
}
```

#### Pattern 3: Smart Search Fallback
```python
def find_files_intelligently(pattern, file_type):
    """If context and standard paths fail, search intelligently"""
    # 1. Try project context
    # 2. Try standard locations
    # 3. Search by pattern
    search_paths = [
        "docs/",
        "tests/",
        f"{app_name}/",
        "."
    ]
    
    for path in search_paths:
        matches = glob.glob(f"{path}/**/{pattern}", recursive=True)
        if matches:
            return matches[0]
```

## Agent-Specific File Discovery

### Testing Specialist Discovery
```yaml
testing_specialist:
  finds_files_by:
    1_project_context:
      - Load PROJECT_CONTEXT.yaml
      - Navigate to code_structure section
      - Find all code locations to test
      
    2_handoff_references:
      - Read handoff document
      - Extract explicit file paths
      - Note specific methods/lines to test
      
    3_standard_search:
      - Search for *.py files in app directory
      - Search for *.vue files in public/js
      - Search for test files in tests/
      
  creates_references_for:
    - Test results: "tests/results/[date]-[test-type].json"
    - Coverage reports: "tests/coverage/[date]-coverage.html"
    - Test plans: "tests/plans/[feature]-test-plan.md"
```

### Compliance Validator Discovery
```yaml
compliance_validator:
  finds_files_by:
    1_explicit_request:
      - User provides specific file paths
      - Handoff includes file list
      
    2_project_scan:
      - Load PROJECT_CONTEXT.yaml
      - Scan code_structure locations
      - Identify all Python and JavaScript files
      
    3_pattern_matching:
      - Find all @frappe.whitelist() decorators
      - Find all .bundle.js files
      - Find all DocType definitions
      
  validates_against:
    - Frappe-first principles
    - API whitelisting patterns
    - DocType naming conventions
    
  creates_references_for:
    - Compliance report: "tests/compliance/[date]-audit.md"
    - Violation list: "tests/compliance/violations.json"
    - Recommendations: "docs/compliance-recommendations.md"
```

### ERPNext Architect File Creation
```yaml
erpnext_architect:
  creates_core_documents:
    project_structure:
      path: "docs/PROJECT_STRUCTURE.md"
      content: |
        # Project Structure Document
        
        ## Overview
        [Project description and goals]
        
        ## File Organization
        ```
        {app_name}/
        ├── docs/
        │   ├── prd.md
        │   ├── architecture.md
        │   └── PROJECT_STRUCTURE.md (this file)
        ├── {module_name}/
        │   ├── doctype/
        │   │   └── {doctype_name}/
        │   └── page/
        └── tests/
        ```
        
        ## Component Locations
        - PRD: docs/prd.md
        - Architecture: docs/architecture.md
        - APIs: {app_name}/api/
        - DocTypes: {app_name}/{module_name}/doctype/
        - Vue Components: {app_name}/public/js/
        - Tests: tests/
        
        ## Key Files Reference
        [List of important files with descriptions]
        
    prd:
      path: "docs/prd.md"
      includes_structure_reference: true
      
    project_context:
      path: "PROJECT_CONTEXT.yaml"
      auto_generated: true
      updated_on_each_creation: true
```

## Implementation in Handoff Template

```yaml
# Updated handoff-template.yaml section
file_references:
  project_context:
    location: "PROJECT_CONTEXT.yaml"
    last_updated: "{timestamp}"
    
  explicit_paths:
    documentation:
      - path: "docs/prd.md"
        description: "Product Requirements Document"
        hash: "sha256:..."
        
    code_files:
      - path: "{app_name}/api/customer.py"
        description: "Customer API endpoints"
        methods:
          - "get_customer_data: line 45-67"
          - "update_customer: line 78-102"
          
      - path: "{app_name}/public/js/dashboard.bundle.js"
        description: "Dashboard Vue entry point"
        components:
          - "Dashboard.vue: Main component"
          - "MetricCard.vue: Metric display"
          
    test_artifacts:
      - path: "tests/results/latest.json"
        description: "Latest test run results"
        coverage: "87%"
        
  search_hints:
    - "All API endpoints contain @frappe.whitelist()"
    - "Vue components are in public/js/{feature}/"
    - "Test files mirror source structure in tests/"
```

## Workflow Integration

### 1. Project Initialization
```python
# ERPNext Architect creates initial structure
def initialize_project_structure(project_name):
    # Create PROJECT_CONTEXT.yaml
    context = {
        'project_context': {
            'project_name': project_name,
            'created_date': now(),
            'planning_documents': {},
            'development_documents': {},
            'testing_documents': {},
            'code_structure': get_standard_code_structure()
        }
    }
    
    with open('PROJECT_CONTEXT.yaml', 'w') as f:
        yaml.dump(context, f)
    
    # Create PROJECT_STRUCTURE.md
    create_project_structure_document(project_name)
    
    # Update context with created files
    update_project_context('planning_documents', 'project_structure', {
        'path': 'docs/PROJECT_STRUCTURE.md',
        'created_by': 'erpnext-architect',
        'created_date': now()
    })
```

### 2. During Handoffs
```python
# Every handoff updates references
def prepare_handoff(from_agent, to_agent, work_completed):
    handoff = load_handoff_template()
    
    # Add explicit file references
    handoff['file_references'] = {
        'project_context': {
            'location': 'PROJECT_CONTEXT.yaml',
            'last_updated': get_file_modified_time('PROJECT_CONTEXT.yaml')
        },
        'explicit_paths': extract_file_paths(work_completed)
    }
    
    # Update project context
    update_project_context_with_handoff(handoff)
    
    return handoff
```

### 3. Agent File Discovery
```python
# Standard discovery method for all agents
class AgentFileDiscovery:
    def __init__(self, agent_id):
        self.agent_id = agent_id
        self.context = self.load_project_context()
        
    def find_file(self, file_type, name=None):
        # 1. Check project context
        if file_path := self.check_context(file_type, name):
            return file_path
            
        # 2. Check standard locations
        if file_path := self.check_standard(file_type, name):
            return file_path
            
        # 3. Smart search
        if file_path := self.smart_search(file_type, name):
            return file_path
            
        # 4. Ask user
        return self.ask_user_for_path(file_type, name)
```

## Benefits of This System

1. **Explicit References**: Every handoff contains exact file paths
2. **Central Registry**: PROJECT_CONTEXT.yaml is the single source of truth
3. **Fallback Options**: Multiple discovery methods ensure files are found
4. **Version Tracking**: File hashes ensure agents work with correct versions
5. **Self-Documenting**: PROJECT_STRUCTURE.md provides human-readable reference

## Example: Complete Flow

1. **ERPNext Architect** creates:
   - `docs/prd.md`
   - `docs/architecture.md`
   - `docs/PROJECT_STRUCTURE.md`
   - Updates `PROJECT_CONTEXT.yaml`

2. **Handoff to Scrum Master** includes:
   ```yaml
   file_references:
     explicit_paths:
       documentation:
         - path: "docs/prd.md"
         - path: "docs/architecture.md"
         - path: "docs/PROJECT_STRUCTURE.md"
   ```

3. **Scrum Master** finds files by:
   - Reading handoff file_references
   - Loading PROJECT_CONTEXT.yaml
   - Following paths exactly as specified

4. **Testing Specialist** receives handoff with:
   ```yaml
   file_references:
     explicit_paths:
       code_files:
         - path: "customer_portal/api/customer.py"
           methods: ["get_customer_data: line 45"]
   ```

5. **Compliance Validator** discovers files by:
   - Loading PROJECT_CONTEXT.yaml
   - Reading code_structure section
   - Scanning specified directories
   - Validating against patterns

This system ensures no agent ever has to guess where files are located!