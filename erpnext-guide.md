# Complete Implementation Guide for Building BMAD ERPNext v15 Expansion Pack

**IMPORTANT**: This guide shows you how to create a **BMAD-METHOD Expansion Pack** for ERPNext v15 development, NOT an ERPNext app. A BMAD expansion pack provides specialized AI agents, templates, tasks, and workflows that work with the BMAD-METHOD framework to assist with ERPNext development in your existing environment.

## 1. Understanding Your Development Environment

### Your Current Setup
You already have a working ERPNext v15 development environment:
- **Home Directory**: `/home/frappe/`
- **Frappe Bench**: `/home/frappe/frappe-bench/`
- **Development Directory**: `/home/frappe/bmad-erpnext-development/`
- **Existing Site**: `prima-erpnext.pegashosting.com`
- **Existing Apps**: `frappe`, `erpnext`, `docflow`, `n8n_integration`
- **Framework Version**: Frappe Framework v15.75.0

### What We're Building
We will create a BMAD expansion pack structure like this:
```
/home/frappe/bmad-erpnext-development/bmad-erpnext-v15/
├── agents/          # AI agents specialized for ERPNext development
├── agent-teams/     # Teams of agents working together
├── checklists/      # Development and deployment checklists
├── data/            # ERPNext schemas and reference data
├── tasks/           # Specific ERPNext development tasks
├── templates/       # DocType, API, and code templates
├── workflows/       # Development workflows
└── config.yaml      # Expansion pack configuration
```

### Installing Claude Code (If Not Already Installed)
Claude Code provides AI-powered development assistance. If you haven't installed it yet:

```bash
# Install Claude Code globally
npm install -g @anthropic-ai/claude-code

# Navigate to your development directory
cd /home/frappe/bmad-erpnext-development

# Start Claude Code
claude
```

### Your Technology Stack (Already Setup)
- **Python 3.10+** ✓ (Already installed)
- **Frappe Framework v15.75.0** ✓ (Already installed)
- **ERPNext v15** ✓ (Available but may need installation on site)
- **MariaDB** ✓ (Already configured)
- **Redis** ✓ (Already configured)
- **Node.js 18** ✓ (Already installed)

### BMAD Expansion Pack Conventions
- Follow BMAD-METHOD structure
- Use YAML for agent configurations
- Create reusable templates
- Include validation checklists
- Document all agents and workflows

### Verify ERPNext Installation on Your Site

Since ERPNext is available but may not be installed on your main site, let's check and install if needed:

```bash
# Navigate to your bench
cd /home/frappe/frappe-bench

# Check what apps are installed on your site
bench --site prima-erpnext.pegashosting.com list-apps

# If ERPNext is not installed on your site, install it
bench --site prima-erpnext.pegashosting.com install-app erpnext

# If you need to install additional dependencies
bench --site prima-erpnext.pegashosting.com install-app payments

# Verify installation
bench --site prima-erpnext.pegashosting.com migrate
```

### Understanding Your Current Apps
Your bench already contains these apps:
- **frappe**: Core framework (v15.75.0)
- **erpnext**: ERP system (available for installation)
- **docflow**: Custom workflow management app
- **n8n_integration**: Workflow automation integration

The BMAD expansion pack will help you develop NEW apps or enhance existing ones using AI-powered agents.

### Setting Up BMAD-METHOD Repository

```bash
# Navigate to your development directory
cd /home/frappe/bmad-erpnext-development

# Clone or fork the BMAD-METHOD repository
git clone https://github.com/bmad-code-org/BMAD-METHOD.git
cd BMAD-METHOD

# If you plan to contribute back, fork first and add upstream
git remote add upstream https://github.com/bmad-code-org/BMAD-METHOD.git

# Create your expansion pack branch
git checkout -b bmad-erpnext-v15-expansion

# Install any dependencies
npm install
```

## 2. Building the BMAD ERPNext v15 Expansion Pack Structure

### Creating Directory Structure

Create the BMAD expansion pack structure in your development directory:

```bash
# Navigate to your BMAD-METHOD directory
cd /home/frappe/bmad-erpnext-development/BMAD-METHOD

# Create the ERPNext v15 expansion pack directory structure
mkdir -p expansion-packs/bmad-erpnext-v15/{agents,agent-teams,templates,tasks,checklists,data,workflows}
cd expansion-packs/bmad-erpnext-v15

# Create the main configuration file
touch config.yaml
touch README.md
```

### Creating BMAD Agent Configuration Files

**Create `agents/erpnext-architect.yaml`:**
```yaml
name: "erpnext-architect"
title: "Senior ERPNext Solution Architect"
description: "Expert in ERPNext v15 architecture, DocType design, and system integration"
version: "1.0.0"

metadata:
  role: "Solution Architecture and System Design"
  focus:
    - "ERPNext v15 module architecture"
    - "Frappe Framework patterns"
    - "Database schema optimization"
    - "Integration patterns and API design"
  style: "Technical, precise, best-practice focused"
  
environment:
  bench_path: "/home/frappe/frappe-bench"
  site: "prima-erpnext.pegashosting.com"
  existing_apps:
    - "frappe"
    - "erpnext" 
    - "docflow"
    - "n8n_integration"
  framework_version: "15.75.0"

persona:
  expertise:
    - "Frappe Framework architecture and patterns"
    - "ERPNext v15 module design and relationships"
    - "Database schema optimization for ERP systems"
    - "Integration patterns and API design"
    - "Performance optimization strategies"
    - "Multi-tenant architecture considerations"
    - "Working with existing custom apps like docflow and n8n_integration"

dependencies:
  templates:
    - "doctype-structure.yaml"
    - "module-architecture.yaml"
    - "integration-patterns.yaml"
  tasks:
    - "design-module.md"
    - "create-doctype-schema.md"
    - "plan-integrations.md"
  data:
    - "erpnext-patterns.yaml"
    - "frappe-conventions.yaml"

capabilities:
  - "Design ERPNext module architectures"
  - "Plan DocType relationships and dependencies"
  - "Create database migration strategies"
  - "Design API and integration patterns"
  - "Optimize for performance and scalability"
  - "Plan permission and workflow structures"
  - "Integrate with existing custom apps"

context_management:
  maintain_awareness:
    - "Current ERPNext v15 capabilities"
    - "Existing module dependencies"
    - "Performance implications"
    - "Security considerations"
    - "Upgrade compatibility"
    - "Impact on existing docflow and n8n_integration apps"

workflow_instructions:
  - "Analyze business requirements"
  - "Design module structure"
  - "Plan DocType relationships"
  - "Define integration points"
  - "Create migration strategy"
  - "Document architecture decisions"
  - "Consider integration with existing custom apps"
```

**Create `agents/bench-operator.yaml`:**
```yaml
name: "bench-operator"
title: "Frappe Bench Command Specialist"
description: "Expert in bench CLI operations for your specific ERPNext environment"
version: "1.0.0"

metadata:
  role: "Bench CLI Operations and Automation"
  focus:
    - "Site management for prima-erpnext.pegashosting.com"
    - "App deployment and management"
    - "Development operations"
    - "Working with multiple custom apps"
  style: "Precise, safety-focused, automation-oriented"

environment:
  bench_path: "/home/frappe/frappe-bench"
  primary_site: "prima-erpnext.pegashosting.com"
  user: "frappe"
  installed_apps:
    - "frappe"
    - "docflow"
    - "n8n_integration"
  available_apps:
    - "erpnext"
    - "payments"

persona:
  expertise:
    - "Frappe bench command-line operations"
    - "Site creation and management"
    - "App installation and updates"
    - "Database operations and migrations"
    - "Development server management"
    - "Multi-app environment management"
    - "Error recovery and troubleshooting"
    - "Working with existing docflow and n8n_integration apps"

dependencies:
  tasks:
    - "execute-bench-command.md"
    - "site-operations.md"
    - "app-management.md"
    - "multi-app-deployment.md"
  checklists:
    - "pre-deployment.md"
    - "post-update.md"
    - "multi-app-compatibility.md"

capabilities:
  - "Execute bench commands safely in multi-app environment"
  - "Manage prima-erpnext.pegashosting.com site operations"
  - "Handle app installations without affecting existing apps"
  - "Run database migrations across multiple apps"
  - "Manage development servers"
  - "Automate deployment workflows"
  - "Implement error recovery"
  - "Ensure compatibility between docflow, n8n_integration, and new apps"

workflow_instructions:
  - "Always specify site: --site prima-erpnext.pegashosting.com"
  - "Check app dependencies before installation"
  - "Validate impact on existing custom apps"
  - "Execute with proper context from /home/frappe/frappe-bench"
  - "Monitor execution progress"
  - "Handle errors gracefully"
  - "Log operations for audit"
  - "Test compatibility with docflow and n8n_integration"
```

### Creating BMAD Template Files

**Create `templates/doctype-template.yaml`:**
```yaml
name: "doctype-template"
title: "ERPNext DocType Template"
description: "Template for creating ERPNext DocTypes with proper structure and validation"
version: "1.0.0"

parameters:
  doctype_name:
    type: "string"
    required: true
    description: "Name of the DocType (PascalCase)"
  module_name:
    type: "string"
    required: true
    description: "Module where DocType will be created"
    default: "Custom"
  app_name:
    type: "string"
    required: true
    description: "App name where DocType belongs"
  naming_rule:
    type: "string"
    required: false
    description: "Naming rule for the DocType"
    default: "Autoincrement"
    options:
      - "Autoincrement"
      - "By fieldname"
      - "Prompt"
      - "Random"
  title_field:
    type: "string"
    required: false
    description: "Field to use as title"
  is_submittable:
    type: "boolean"
    required: false
    default: false
    description: "Whether the DocType is submittable"
  fields:
    type: "array"
    required: true
    description: "List of fields for the DocType"
    items:
      fieldname:
        type: "string"
        required: true
      fieldtype:
        type: "string"
        required: true
      label:
        type: "string"
        required: true
      required:
        type: "boolean"
        default: false
      options:
        type: "string"
        required: false

templates:
  doctype_json: |
    {
      "doctype": "DocType",
      "name": "{{doctype_name}}",
      "module": "{{module_name}}",
      "naming_rule": "{{naming_rule}}",
      "title_field": "{{title_field}}",
      "is_submittable": {{is_submittable}},
      "track_changes": 1,
      "permissions": [
        {
          "role": "System Manager",
          "read": 1,
          "write": 1,
          "create": 1,
          "delete": 1
        }
      ],
      "fields": [
        {{#each fields}}
        {
          "fieldname": "{{fieldname}}",
          "fieldtype": "{{fieldtype}}",
          "label": "{{label}}",
          "reqd": {{required}},
          "options": "{{options}}"
        }{{#unless @last}},{{/unless}}
        {{/each}}
      ]
    }
  
  controller_py: |
    import frappe
    from frappe.model.document import Document
    {{#if is_submittable}}
    from frappe import _
    {{/if}}
    
    class {{doctype_name}}(Document):
        def validate(self):
            """Validation logic before saving"""
            self.validate_required_fields()
            self.set_defaults()
        
        def before_save(self):
            """Pre-save operations"""
            pass
        
        def after_insert(self):
            """Post-creation operations"""
            self.create_related_documents()
        
        {{#if is_submittable}}
        def on_submit(self):
            """Actions on document submission"""
            self.update_linked_documents()
        
        def on_cancel(self):
            """Actions on document cancellation"""
            self.revert_linked_documents()
        {{/if}}
        
        @frappe.whitelist()
        def custom_method(self):
            """Custom API method"""
            return {"status": "success", "doctype": self.doctype, "name": self.name}
        
        def validate_required_fields(self):
            """Custom validation for required fields"""
            pass
        
        def set_defaults(self):
            """Set default values"""
            pass
        
        def create_related_documents(self):
            """Create related documents after insertion"""
            pass
        
        {{#if is_submittable}}
        def update_linked_documents(self):
            """Update linked documents on submission"""
            pass
        
        def revert_linked_documents(self):
            """Revert linked documents on cancellation"""
            pass
        {{/if}}

environment:
  bench_path: "/home/frappe/frappe-bench"
  site: "prima-erpnext.pegashosting.com"

instructions:
  creation:
    - "Navigate to {{app_name}} app directory"
    - "Create module directory if it doesn't exist"
    - "Create DocType directory structure"
    - "Generate {{doctype_name}}.json from template"
    - "Generate {{doctype_name}}.py controller from template"
    - "Run bench migrate to create in database"
    - "Test DocType creation and validation"
  
  validation:
    - "Verify DocType follows Frappe naming conventions"
    - "Check field types are valid"
    - "Ensure required permissions are set"
    - "Test with existing apps (docflow, n8n_integration) if integration needed"
```

### Creating BMAD Task Definitions

**Create `tasks/create-doctype.md`:**
```markdown
# Task: Create ERPNext DocType

## Purpose
Create a new DocType in your existing ERPNext environment with proper structure, validation, and controllers

## Environment Context
- **Bench Path**: /home/frappe/frappe-bench
- **Site**: prima-erpnext.pegashosting.com
- **Existing Apps**: frappe, docflow, n8n_integration
- **Available Apps**: erpnext, payments

## Input Specifications
```yaml
doctype_name: String (required) # PascalCase format
app_name: String (required) # Must be installed on site
module: String (required) # Must exist in app
fields:
  - fieldname: String # snake_case format
    fieldtype: String # Valid Frappe field type
    label: String # Human readable
    required: Boolean (default: false)
    options: String (optional) # For Select, Link, etc.
permissions:
  - role: String # Valid Frappe role
    read: Boolean
    write: Boolean
    create: Boolean
    delete: Boolean
is_submittable: Boolean (default: false)
naming_rule: String (default: "Autoincrement")
```

## Execution Steps
1. **Validate Environment**
   - Check bench path exists
   - Verify site is active
   - Confirm app is installed on site
   - Validate module exists in app

2. **Validate Input Parameters**
   - DocType name follows PascalCase
   - Field names follow snake_case
   - Field types are valid Frappe types
   - At least one field specified

3. **Create DocType Structure**
   ```bash
   cd /home/frappe/frappe-bench
   mkdir -p apps/{{app_name}}/{{app_name}}/{{module}}/doctype/{{doctype_name_snake}}
   ```

4. **Generate Files**
   - Create {{doctype_name}}.json using doctype-template
   - Create {{doctype_name}}.py controller
   - Create {{doctype_name}}.js client script (if needed)
   - Create test_{{doctype_name}}.py

5. **Apply to Database**
   ```bash
   cd /home/frappe/frappe-bench
   bench --site prima-erpnext.pegashosting.com migrate
   ```

6. **Validate Integration**
   - Test DocType creation doesn't conflict with docflow
   - Verify n8n_integration compatibility if workflows needed
   - Check permissions work correctly

## Output Specifications
- DocType JSON: `apps/{{app}}/{{app}}/{{module}}/doctype/{{doctype_name_snake}}/{{doctype_name_snake}}.json`
- Controller: `apps/{{app}}/{{app}}/{{module}}/doctype/{{doctype_name_snake}}/{{doctype_name_snake}}.py`
- Client Script: `apps/{{app}}/{{app}}/{{module}}/doctype/{{doctype_name_snake}}/{{doctype_name_snake}}.js`
- Test File: `apps/{{app}}/{{app}}/{{module}}/doctype/{{doctype_name_snake}}/test_{{doctype_name_snake}}.py`
- Database table created on site

## Validation Rules
- DocType name must be PascalCase (e.g., "CustomDocType")
- Directory name must be snake_case (e.g., "custom_doc_type")
- Field names must be snake_case (e.g., "field_name")
- At least one field required
- Module must exist in specified app
- App must be installed on prima-erpnext.pegashosting.com
- No naming conflicts with existing DocTypes
- Compatible with existing custom apps (docflow, n8n_integration)

## Error Handling
- If app not installed: Suggest installation command
- If module doesn't exist: Provide module creation steps
- If naming conflict: Suggest alternative names
- If migration fails: Check dependencies and permissions

## Integration Considerations
- **docflow**: Check if new DocType needs workflow integration
- **n8n_integration**: Consider if automation triggers needed
- **ERPNext**: Ensure compliance with ERPNext patterns if extending core modules
```

## 3. Creating Additional BMAD Agents

### DocType Designer Agent

**Create `agents/doctype-designer.yaml`:**

```yaml
name: "doctype-designer"
title: "ERPNext DocType Designer"
description: "Specialized agent for designing and creating ERPNext DocTypes"
version: "1.0.0"

metadata:
  role: "DocType Design and Development"
  focus:
    - "DocType schema design"
    - "Field type selection and validation"
    - "Relationship modeling"
    - "Permission setup"
  style: "Detail-oriented, validation-focused"

environment:
  bench_path: "/home/frappe/frappe-bench"
  site: "prima-erpnext.pegashosting.com"
  available_apps:
    - "frappe"
    - "erpnext"
    - "docflow"
    - "n8n_integration"

persona:
  expertise:
    - "Frappe field types and their use cases"
    - "DocType relationships (Link, Table, etc.)"
    - "Naming conventions and patterns"
    - "Permission matrix design"
    - "Workflow integration considerations"
    - "Performance implications of field choices"

dependencies:
  templates:
    - "doctype-template.yaml"
    - "field-validation-template.yaml"
  tasks:
    - "create-doctype.md"
    - "validate-doctype-schema.md"
  data:
    - "frappe-field-types.yaml"
    - "common-patterns.yaml"

capabilities:
  - "Design DocType schemas based on business requirements"
  - "Select appropriate field types for data validation"
  - "Model relationships between DocTypes"
  - "Configure permissions for different user roles"
  - "Ensure integration compatibility with docflow workflows"
  - "Consider n8n_integration automation possibilities"

workflow_instructions:
  - "Analyze business requirements thoroughly"
  - "Choose field types that enforce data integrity"
  - "Design relationships that maintain referential integrity"
  - "Set up permissions following principle of least privilege"
  - "Consider workflow stages if docflow integration needed"
  - "Plan for automation triggers if n8n_integration required"
  - "Validate schema before implementation"
```

### API Developer Agent

**Create `agents/api-developer.yaml`:**

```yaml
name: "api-developer"
title: "ERPNext API Developer"
description: "Expert in creating ERPNext APIs and integrations"
version: "1.0.0"

metadata:
  role: "API Development and Integration"
  focus:
    - "REST API creation"
    - "Authentication and authorization"
    - "Data serialization"
    - "Integration patterns"
  style: "Security-conscious, performance-focused"

environment:
  bench_path: "/home/frappe/frappe-bench"
  site: "prima-erpnext.pegashosting.com"
  existing_integrations:
    - "docflow APIs"
    - "n8n_integration webhooks"

persona:
  expertise:
    - "Frappe whitelist decorators and API security"
    - "JSON serialization and data transformation"
    - "Error handling and status codes"
    - "Rate limiting and performance optimization"
    - "Integration with external systems"
    - "Webhook design and implementation"

dependencies:
  templates:
    - "api-endpoint-template.yaml"
    - "webhook-template.yaml"
  tasks:
    - "create-api-endpoint.md"
    - "setup-webhook.md"
  data:
    - "api-patterns.yaml"
    - "security-guidelines.yaml"

capabilities:
  - "Create secure API endpoints using @frappe.whitelist()"
  - "Implement proper authentication and authorization"
  - "Design RESTful APIs following best practices"
  - "Create webhooks for external integrations"
  - "Integrate with existing docflow and n8n_integration APIs"
  - "Handle errors gracefully with proper HTTP status codes"

workflow_instructions:
  - "Always use @frappe.whitelist() for API endpoints"
  - "Validate all input parameters"
  - "Check user permissions before data access"
  - "Return consistent JSON response format"
  - "Log API usage for monitoring"
  - "Consider rate limiting for external APIs"
  - "Test integration with existing system APIs"
```

### Workflow Specialist Agent

**Create `agents/workflow-specialist.yaml`:**

```yaml
name: "workflow-specialist"
title: "ERPNext Workflow Specialist"
description: "Expert in ERPNext workflows and docflow integration"
version: "1.0.0"

metadata:
  role: "Workflow Design and Implementation"
  focus:
    - "ERPNext native workflows"
    - "docflow integration"
    - "State management"
    - "Approval processes"
  style: "Process-oriented, systematic"

environment:
  bench_path: "/home/frappe/frappe-bench"
  site: "prima-erpnext.pegashosting.com"
  workflow_apps:
    - "docflow"
    - "n8n_integration"

persona:
  expertise:
    - "ERPNext Workflow DocType configuration"
    - "docflow integration patterns"
    - "State transitions and validation"
    - "Email notifications and alerts"
    - "Role-based approvals"
    - "n8n workflow automation"

dependencies:
  templates:
    - "workflow-template.yaml"
    - "workflow-state-template.yaml"
  tasks:
    - "create-workflow.md"
    - "integrate-docflow.md"
  data:
    - "workflow-patterns.yaml"
    - "docflow-integration-guide.yaml"

capabilities:
  - "Design ERPNext native workflows"
  - "Integrate with existing docflow processes"
  - "Configure state transitions and validations"
  - "Set up approval hierarchies"
  - "Create automated notifications"
  - "Design n8n integration triggers"

workflow_instructions:
  - "Understand existing docflow patterns first"
  - "Map business process to workflow states"
  - "Define clear state transition rules"
  - "Set up appropriate user permissions for each state"
  - "Configure email notifications for stakeholders"
  - "Test integration with existing docflow workflows"
  - "Consider n8n automation opportunities"
```

### Testing Specialist Agent

**Create `agents/testing-specialist.yaml`:**

```yaml
name: "testing-specialist"
title: "ERPNext Testing Specialist"
description: "Expert in testing ERPNext applications and integrations"
version: "1.0.0"

metadata:
  role: "Quality Assurance and Testing"
  focus:
    - "Unit testing"
    - "Integration testing"
    - "Multi-app compatibility"
    - "Performance testing"
  style: "Methodical, comprehensive, quality-focused"

environment:
  bench_path: "/home/frappe/frappe-bench"
  site: "prima-erpnext.pegashosting.com"
  test_apps:
    - "frappe"
    - "erpnext"
    - "docflow"
    - "n8n_integration"

persona:
  expertise:
    - "Frappe test framework"
    - "Unit test patterns for DocTypes"
    - "API endpoint testing"
    - "Multi-app integration testing"
    - "Performance benchmarking"
    - "Data integrity validation"

dependencies:
  templates:
    - "test-template.yaml"
    - "integration-test-template.yaml"
  tasks:
    - "create-unit-tests.md"
    - "run-integration-tests.md"
  data:
    - "test-patterns.yaml"
    - "performance-benchmarks.yaml"

capabilities:
  - "Create comprehensive unit tests for DocTypes"
  - "Test API endpoints with various scenarios"
  - "Validate integration between apps"
  - "Perform compatibility testing with docflow and n8n_integration"
  - "Run performance benchmarks"
  - "Create test data fixtures"

workflow_instructions:
  - "Use bench --site prima-erpnext.pegashosting.com run-tests for execution"
  - "Test DocType creation, validation, and business logic"
  - "Verify API endpoints with different user permissions"
  - "Check compatibility with existing custom apps"
  - "Validate data integrity across app boundaries"
  - "Test error handling and edge cases"
  - "Measure performance impact on existing system"
```

## 4. Creating Expansion Pack Configuration

### Main Configuration File

**Create `config.yaml`:**

```yaml
name: "bmad-erpnext-v15"
title: "BMAD ERPNext v15 Expansion Pack"
description: "Complete BMAD expansion pack for ERPNext v15 development"
version: "1.0.0"
author: "Your Name"
license: "MIT"

metadata:
  target_framework: "Frappe Framework v15"
  target_application: "ERPNext v15"
  compatibility:
    frappe: ">=15.0.0,<16.0.0"
    erpnext: ">=15.0.0,<16.0.0"
  dependencies:
    - "frappe"
    - "erpnext"
  optional_dependencies:
    - "payments"

environment:
  bench_path: "/home/frappe/frappe-bench"
  primary_site: "prima-erpnext.pegashosting.com"
  user: "frappe"
  development_directory: "/home/frappe/bmad-erpnext-development"
  
existing_apps:
  installed:
    - name: "frappe"
      version: "15.75.0"
      status: "active"
    - name: "docflow"
      type: "custom"
      description: "Workflow management system"
      integration_points:
        - "workflow_engine"
        - "approval_processes"
    - name: "n8n_integration"
      type: "custom"
      description: "Automation and workflow integration"
      integration_points:
        - "webhook_triggers"
        - "external_apis"
  available:
    - name: "erpnext"
      version: "15.x"
      status: "ready_to_install"
    - name: "payments"
      version: "15.x"
      status: "ready_to_install"

agents:
  core:
    - "erpnext-architect"
    - "bench-operator"
    - "doctype-designer"
    - "api-developer"
    - "workflow-specialist"
    - "testing-specialist"
  
agent_teams:
  development_team:
    - "erpnext-architect"
    - "doctype-designer"
    - "api-developer"
  deployment_team:
    - "bench-operator"
    - "testing-specialist"
  workflow_team:
    - "workflow-specialist"
    - "api-developer"
    - "testing-specialist"

templates:
  core:
    - "doctype-template.yaml"
    - "api-endpoint-template.yaml"
    - "workflow-template.yaml"
    - "test-template.yaml"

tasks:
  development:
    - "create-doctype.md"
    - "create-api-endpoint.md"
    - "setup-workflow.md"
    - "create-unit-tests.md"
  deployment:
    - "install-app.md"
    - "run-migrations.md"
    - "run-tests.md"
  integration:
    - "integrate-docflow.md"
    - "setup-n8n-triggers.md"

workflows:
  app_development:
    - "analyze_requirements"
    - "design_architecture"
    - "create_doctypes"
    - "build_apis"
    - "setup_workflows"
    - "create_tests"
    - "deploy_and_validate"
  
  enhancement:
    - "analyze_existing_system"
    - "plan_integration"
    - "implement_changes"
    - "test_compatibility"
    - "deploy_updates"

data:
  reference:
    - "frappe-field-types.yaml"
    - "erpnext-patterns.yaml"
    - "api-patterns.yaml"
    - "workflow-patterns.yaml"
    - "testing-patterns.yaml"

checklists:
  development:
    - "pre-development.md"
    - "code-quality.md"
    - "security-review.md"
  deployment:
    - "pre-deployment.md"
    - "post-deployment.md"
    - "rollback-procedure.md"
  integration:
    - "docflow-compatibility.md"
    - "n8n-integration-check.md"
    - "multi-app-testing.md"

integration:
  existing_systems:
    docflow:
      description: "Workflow management system"
      integration_points:
        - "Use docflow for complex approval processes"
        - "Leverage existing workflow templates"
        - "Maintain compatibility with docflow APIs"
      considerations:
        - "Check docflow version compatibility"
        - "Test workflow triggers"
        - "Validate data flow between systems"
    
    n8n_integration:
      description: "Automation platform integration"
      integration_points:
        - "Webhook triggers for external systems"
        - "Automated data synchronization"
        - "Event-driven processes"
      considerations:
        - "Test webhook endpoints"
        - "Validate n8n workflow configurations"
        - "Check authentication and security"

settings:
  development:
    auto_reload: true
    debug_mode: true
    log_level: "DEBUG"
  
  testing:
    run_parallel_tests: false
    test_timeout: 300
    coverage_threshold: 80
  
  deployment:
    backup_before_deploy: true
    validate_before_deploy: true
    rollback_on_failure: true
```

## 5. Development Workflows Using BMAD Agents

### Workflow 1: Creating a New ERPNext App

This workflow uses BMAD agents to guide you through creating a new ERPNext app in your existing environment.

**Step 1: Planning with erpnext-architect Agent**
```bash
# Navigate to your development directory
cd /home/frappe/bmad-erpnext-development

# Use Claude Code with BMAD expansion pack
# Agent: erpnext-architect
# Task: Analyze requirements and design app architecture
```

Example conversation with erpnext-architect:
```
*agent erpnext-architect*
"I need to create a library management app for ERPNext. It should integrate with our existing docflow for approval processes and use n8n_integration for external notifications. The app needs book tracking, member management, and issue/return workflows."
```

**Step 2: Create the App Structure**
```bash
# Navigate to frappe-bench
cd /home/frappe/frappe-bench

# Create new app (guided by bench-operator agent)
bench new-app library_management

# Install on your site
bench --site prima-erpnext.pegashosting.com install-app library_management
```

**Step 3: Design DocTypes with doctype-designer Agent**
```
*agent doctype-designer*
"Create a Book DocType for the library management app with the following requirements:
- Book title, author, ISBN
- Category and subcategory
- Total copies and available copies tracking
- Integration with docflow for book acquisition approval
- API methods for issue/return operations"
```

The doctype-designer agent will guide you through:
1. Field selection and validation
2. Relationship modeling
3. Permission setup
4. Integration considerations

**Step 4: Implement APIs with api-developer Agent**
```
*agent api-developer*
"Create REST APIs for the library management system:
- Book search and availability check
- Member registration and validation
- Issue/return operations with proper validation
- Integration endpoints for n8n_integration webhooks"
```

Example API implementation guided by the agent:
```python
# In library_management/api.py
import frappe
from frappe import _

@frappe.whitelist()
def search_available_books(query=None, category=None, limit=20):
    """Search for available books"""
    filters = {"available_copies": (">" , 0)}
    
    if category:
        filters["category"] = category
    
    books = frappe.get_all("Book",
        fields=["name", "title", "author", "isbn", "available_copies", "category"],
        filters=filters,
        limit=limit
    )
    
    if query:
        books = [b for b in books if query.lower() in b.title.lower() or query.lower() in b.author.lower()]
    
    return {"status": "success", "books": books}

@frappe.whitelist()
def issue_book_to_member(book_id, member_id):
    """Issue a book to a library member with workflow integration"""
    # Validate book availability
    book = frappe.get_doc("Book", book_id)
    if book.available_copies <= 0:
        frappe.throw(_("Book not available for issue"))
    
    # Check if docflow approval required for certain categories
    if book.category in ["Reference", "Rare Books"]:
        # Trigger docflow workflow
        workflow_doc = frappe.get_doc({
            "doctype": "Book Issue Request",
            "book": book_id,
            "member": member_id,
            "status": "Pending Approval"
        })
        workflow_doc.insert()
        
        # Trigger n8n_integration webhook for notifications
        frappe.enqueue("library_management.utils.trigger_approval_notification",
                      request_id=workflow_doc.name,
                      queue="short")
        
        return {"status": "approval_required", "request_id": workflow_doc.name}
    else:
        # Direct issue for regular books
        return book.issue_book(member_id)
```

**Step 5: Setup Workflows with workflow-specialist Agent**
```
*agent workflow-specialist*
"Setup approval workflows for the library management system:
- Book acquisition requests need manager approval
- Rare book issues require librarian approval
- Overdue notifications through existing docflow
- Integration with n8n for external system notifications"
```

The workflow-specialist will help you:
1. Design workflow states and transitions
2. Integrate with existing docflow patterns
3. Setup approval hierarchies
4. Configure n8n_integration triggers

**Step 6: Create Tests with testing-specialist Agent**
```
*agent testing-specialist*
"Create comprehensive tests for the library management system:
- Unit tests for all DocTypes
- API endpoint testing
- Integration tests with docflow workflows
- Compatibility tests with n8n_integration
- Performance tests for search operations"
```

Example test structure:
```python
# In library_management/tests/test_book.py
import unittest
import frappe
from frappe.tests.utils import FrappeTestCase

class TestBook(FrappeTestCase):
    def setUp(self):
        # Create test data
        self.book = frappe.get_doc({
            "doctype": "Book",
            "title": "Test Book",
            "author": "Test Author",
            "isbn": "1234567890123",
            "total_copies": 5,
            "available_copies": 5,
            "category": "Fiction"
        }).insert()
        
    def test_book_validation(self):
        """Test book validation logic"""
        self.assertEqual(self.book.available_copies, 5)
        self.assertTrue(self.book.book_code.startswith("BOOK-"))
        
    def test_docflow_integration(self):
        """Test integration with existing docflow app"""
        # Test that docflow workflows are triggered for special categories
        rare_book = frappe.get_doc({
            "doctype": "Book",
            "title": "Rare Book",
            "category": "Rare Books",
            "total_copies": 1
        }).insert()
        
        # This should trigger docflow approval
        result = rare_book.issue_book("test-member")
        self.assertEqual(result.get("status"), "approval_required")
        
    def test_n8n_integration_compatibility(self):
        """Test that n8n_integration webhooks work correctly"""
        # Test webhook triggers don't conflict with existing n8n workflows
        pass
        
    def tearDown(self):
        frappe.delete_doc("Book", self.book.name)
```

**Step 7: Deployment with bench-operator Agent**
```
*agent bench-operator*
"Deploy the library management app to the prima-erpnext.pegashosting.com site:
- Install app dependencies
- Run database migrations
- Test compatibility with docflow and n8n_integration
- Validate all services are working
- Setup production monitoring"
```

Deployment commands guided by bench-operator:
```bash
# Navigate to bench directory
cd /home/frappe/frappe-bench

# Install any additional dependencies
bench --site prima-erpnext.pegashosting.com install-app payments  # if needed

# Run migrations for the new app
bench --site prima-erpnext.pegashosting.com migrate

# Clear cache to ensure proper loading
bench --site prima-erpnext.pegashosting.com clear-cache

# Run tests to validate deployment
bench --site prima-erpnext.pegashosting.com run-tests --app library_management

# Test integration with existing apps
bench --site prima-erpnext.pegashosting.com run-tests --app docflow --verbose
bench --site prima-erpnext.pegashosting.com run-tests --app n8n_integration --verbose

# Build assets if needed
bench build

# Restart services
bench restart
```

### Workflow 2: Enhancing Existing Apps

Use BMAD agents to enhance your existing `docflow` or `n8n_integration` apps:

**Example: Adding ERPNext Integration to docflow**
```
*agent erpnext-architect*
"I want to enhance the existing docflow app to better integrate with ERPNext's native workflow system. The goal is to:
- Leverage ERPNext's workflow DocType
- Maintain backward compatibility
- Add ERPNext-specific workflow actions
- Integrate with ERPNext's notification system"
```

The agent will guide you through:
1. Analyzing current docflow structure
2. Planning ERPNext integration points
3. Designing migration strategy
4. Ensuring backward compatibility

### Workflow 3: Multi-App Integration Testing

Use the testing-specialist agent to ensure all apps work together:

```
*agent testing-specialist*
"Create integration tests that validate:
- Library management works with docflow approval processes
- n8n_integration webhooks trigger correctly from library events
- All apps can coexist without conflicts
- Database integrity across app boundaries
- Performance impact is minimal"
```

Integration test example:
```python
# In library_management/tests/test_integration.py
import frappe
import unittest
from frappe.tests.utils import FrappeTestCase

class TestMultiAppIntegration(FrappeTestCase):
    def test_docflow_workflow_integration(self):
        """Test that library workflows integrate with docflow"""
        # Create a book that requires approval
        book = frappe.get_doc({
            "doctype": "Book",
            "title": "Rare Manuscript",
            "category": "Rare Books",
            "total_copies": 1
        }).insert()
        
        # Issue should trigger docflow workflow
        from library_management.api import issue_book_to_member
        result = issue_book_to_member(book.name, "test-member")
        
        self.assertEqual(result["status"], "approval_required")
        
        # Check that docflow workflow was created
        workflows = frappe.get_all("Book Issue Request", 
                                  filters={"book": book.name})
        self.assertTrue(len(workflows) > 0)
        
    def test_n8n_webhook_integration(self):
        """Test that n8n_integration webhooks work correctly"""
        # Test that library events trigger n8n workflows
        # without breaking existing n8n_integration functionality
        pass
        
    def test_database_integrity(self):
        """Test that all apps maintain database integrity"""
        # Verify no foreign key conflicts
        # Check that app-specific tables don't conflict
        pass
```

## 6. Integration Instructions for Existing Custom Apps

### Working with docflow App

Your existing `docflow` app provides workflow management capabilities. Here's how to integrate new developments with it:

**Understanding docflow Integration Points:**
```yaml
# In your BMAD expansion pack data/docflow-integration.yaml
name: "docflow-integration-guide"
description: "Guide for integrating with existing docflow app"

docflow_features:
  workflow_engine:
    description: "Core workflow processing engine"
    integration_method: "Inherit from workflow base classes"
    api_endpoints:
      - "/api/method/docflow.api.create_workflow"
      - "/api/method/docflow.api.trigger_workflow"
      - "/api/method/docflow.api.get_workflow_status"
  
  approval_processes:
    description: "Multi-level approval system"
    integration_method: "Use existing approval templates"
    doctype_hooks:
      - "before_submit"
      - "on_submit"
      - "on_cancel"

  stage_processors:
    description: "Automated processing at workflow stages"
    integration_method: "Register custom processors"
    processor_types:
      - "ai_services_processor"
      - "n8n_processor"
      - "rag_services_processor"

integration_patterns:
  new_doctype_workflow:
    steps:
      - "Create DocType with workflow fields"
      - "Register with docflow workflow engine"
      - "Define approval stages and transitions"
      - "Configure stage processors if needed"
    example_code: |
      # In your DocType controller
      def on_submit(self):
          # Trigger docflow workflow
          workflow_doc = frappe.get_doc({
              "doctype": "Workflow Instance",
              "reference_doctype": self.doctype,
              "reference_name": self.name,
              "workflow_template": "Your Custom Workflow"
          })
          workflow_doc.insert()
          workflow_doc.submit()
  
  custom_approval_process:
    description: "Add custom approval logic to existing workflows"
    implementation: |
      # Register custom approval function
      @frappe.whitelist()
      def custom_approval_logic(doc, method):
          if doc.doctype == "Your DocType":
              # Custom validation logic
              if doc.amount > 10000:
                  # Trigger higher approval level
                  return "manager_approval_required"
              return "approved"
```

### Working with n8n_integration App

Your `n8n_integration` app provides automation capabilities. Integration considerations:

**Understanding n8n_integration Patterns:**
```yaml
# In your BMAD expansion pack data/n8n-integration.yaml
name: "n8n-integration-guide"
description: "Guide for integrating with existing n8n_integration app"

n8n_features:
  webhook_management:
    description: "Webhook endpoint management"
    base_url: "https://prima-erpnext.pegashosting.com/api/method/n8n_integration.webhook"
    authentication: "API key based"
    
  workflow_triggers:
    description: "Event-based workflow triggers"
    supported_events:
      - "on_submit"
      - "after_insert"
      - "on_update"
      - "on_cancel"
    
  external_integrations:
    description: "External system connections"
    supported_systems:
      - "Email providers"
      - "SMS gateways"
      - "External APIs"
      - "File storage systems"

integration_patterns:
  webhook_trigger:
    description: "Trigger n8n workflows from your DocTypes"
    implementation: |
      # In your DocType controller
      def after_insert(self):
          # Trigger n8n workflow
          frappe.enqueue(
              "n8n_integration.utils.trigger_workflow",
              queue="short",
              webhook_id="your_workflow_webhook_id",
              data={
                  "doctype": self.doctype,
                  "name": self.name,
                  "event": "created",
                  "data": self.as_dict()
              }
          )
  
  external_notification:
    description: "Send notifications through n8n"
    implementation: |
      @frappe.whitelist()
      def send_custom_notification(docname, notification_type):
          doc = frappe.get_doc("Your DocType", docname)
          
          # Use n8n_integration for external notifications
          n8n_data = {
              "notification_type": notification_type,
              "recipient": doc.email,
              "subject": f"Update on {doc.title}",
              "message": f"Your document {doc.name} has been updated"
          }
          
          frappe.get_doc({
              "doctype": "N8N Webhook Log",
              "webhook_url": "notification_workflow",
              "payload": frappe.as_json(n8n_data)
          }).insert()
```

### Compatibility Testing Checklist

**Create `checklists/multi-app-compatibility.md`:**

```markdown
# Multi-App Compatibility Checklist

## Pre-Development Checks
- [ ] Verify docflow app version and API compatibility
- [ ] Check n8n_integration webhook endpoints are accessible
- [ ] Confirm no DocType name conflicts between apps
- [ ] Validate database table namespace separation

## Development Phase Checks
- [ ] Test new DocTypes don't interfere with docflow workflows
- [ ] Verify API endpoints don't conflict with existing routes
- [ ] Check webhook triggers work with n8n_integration
- [ ] Validate permission inheritance works correctly

## Integration Testing
- [ ] Create test workflow that spans multiple apps
- [ ] Test data flow between your app and docflow
- [ ] Verify n8n_integration triggers fire correctly
- [ ] Check error handling doesn't break existing functionality

## Performance Testing
- [ ] Measure impact on existing app performance
- [ ] Test database query performance with additional tables
- [ ] Verify memory usage doesn't increase significantly
- [ ] Check that background jobs don't interfere

## Deployment Checks
- [ ] Backup database before deploying new app
- [ ] Test migration scripts with existing data
- [ ] Verify all apps start correctly after deployment
- [ ] Check log files for any conflict errors

## Post-Deployment Validation
- [ ] Test existing docflow workflows still function
- [ ] Verify n8n_integration webhooks still trigger
- [ ] Check user permissions work across all apps
- [ ] Monitor system performance for 24 hours

## Rollback Procedure
- [ ] Document steps to uninstall new app if needed
- [ ] Prepare database rollback scripts
- [ ] Have backup restoration procedure ready
- [ ] Test rollback process in development environment
```

### Integration Best Practices

**Create `data/integration-best-practices.yaml`:**

```yaml
name: "integration-best-practices"
description: "Best practices for integrating with existing custom apps"

best_practices:
  database_design:
    - "Use unique prefixes for custom fields to avoid conflicts"
    - "Don't modify existing DocType structures from other apps"
    - "Create Link fields instead of duplicating data"
    - "Use proper indexes for cross-app queries"
  
  api_design:
    - "Namespace your API endpoints to avoid conflicts"
    - "Use consistent authentication with existing apps"
    - "Handle errors gracefully without breaking other apps"
    - "Document integration points clearly"
  
  workflow_integration:
    - "Extend existing workflows rather than replacing them"
    - "Use docflow's workflow engine for complex processes"
    - "Trigger n8n workflows for external integrations"
    - "Maintain backward compatibility"
  
  performance_optimization:
    - "Cache frequently accessed cross-app data"
    - "Use background jobs for heavy integrations"
    - "Optimize database queries that span multiple apps"
    - "Monitor resource usage impact"

common_patterns:
  extending_docflow_workflow:
    description: "Add custom stages to existing docflow workflows"
    example: |
      # Register custom stage processor
      def setup():
          from docflow.workflow_engine import register_stage_processor
          register_stage_processor('custom_validation', custom_validation_processor)
      
      def custom_validation_processor(workflow_instance, stage_data):
          # Your custom validation logic
          return {'status': 'approved', 'next_stage': 'final_approval'}
  
  n8n_webhook_integration:
    description: "Send data to external systems via n8n"
    example: |
      def trigger_external_sync(doc, method):
          if doc.doctype == "Your DocType" and doc.sync_required:
              webhook_data = {
                  'event': 'sync_required',
                  'document': doc.as_dict(),
                  'timestamp': frappe.utils.now()
              }
              
              # Use existing n8n_integration infrastructure
              frappe.get_doc({
                  'doctype': 'N8N Webhook Queue',
                  'webhook_name': 'external_sync_webhook',
                  'payload': json.dumps(webhook_data)
              }).insert()

error_handling:
  graceful_degradation:
    - "If docflow is unavailable, queue workflows for later"
    - "If n8n_integration fails, log errors but don't block processes"
    - "Provide fallback mechanisms for critical integrations"
  
  monitoring_integration:
    - "Log all cross-app interactions"
    - "Set up alerts for integration failures"
    - "Monitor performance impact on existing apps"
    - "Track usage patterns for optimization"
```

## 7. Using the BMAD Expansion Pack with Claude Code

### Setting Up Claude Code Integration

Once you've created your BMAD expansion pack, integrate it with Claude Code:

**Create `.claude/config.yaml` in your development directory:**

```yaml
# /home/frappe/bmad-erpnext-development/.claude/config.yaml
expansion_packs:
  - path: "./BMAD-METHOD/expansion-packs/bmad-erpnext-v15"
    name: "bmad-erpnext-v15"
    enabled: true

environment:
  bench_path: "/home/frappe/frappe-bench"
  site: "prima-erpnext.pegashosting.com"
  working_directory: "/home/frappe/bmad-erpnext-development"

shortcuts:
  agents:
    arch: "erpnext-architect"
    bench: "bench-operator"
    dt: "doctype-designer"
    api: "api-developer"
    wf: "workflow-specialist"
    test: "testing-specialist"
```

### Custom Claude Code Commands

Create custom commands for your ERPNext development workflow:

**Create `.claude/commands/erpnext-dev.md`:**

```markdown
# ERPNext Development Commands with BMAD

## /arch
Invoke the ERPNext architect agent for system design

Usage: /arch "Design a customer portal module with user authentication"

## /dt
Create a new DocType using the doctype-designer agent

Usage: /dt "Customer Registration" "CRM" "customer_management"

## /api
Create API endpoints using the api-developer agent

Usage: /api "Customer portal login and registration APIs"

## /deploy
Deploy changes using bench-operator agent

Usage: /deploy "Install new app and run tests"

## /test-integration
Run integration tests with existing apps

Usage: /test-integration "Test compatibility with docflow and n8n_integration"
```

## 8. Testing and Validation of Your Expansion Pack

### Testing Your BMAD Expansion Pack

**Create `tests/test_expansion_pack.py`:**
```python
import unittest
import yaml
import os
from pathlib import Path

class TestBMADExpansionPack(unittest.TestCase):
    def setUp(self):
        self.expansion_pack_path = Path("/home/frappe/bmad-erpnext-development/BMAD-METHOD/expansion-packs/bmad-erpnext-v15")
        
    def test_expansion_pack_structure(self):
        """Test that expansion pack has required directories"""
        required_dirs = ['agents', 'templates', 'tasks', 'checklists', 'data', 'workflows']
        
        for dir_name in required_dirs:
            dir_path = self.expansion_pack_path / dir_name
            self.assertTrue(dir_path.exists(), f"Missing required directory: {dir_name}")
    
    def test_config_file_validity(self):
        """Test that config.yaml is valid"""
        config_path = self.expansion_pack_path / "config.yaml"
        self.assertTrue(config_path.exists(), "config.yaml not found")
        
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)
        
        required_keys = ['name', 'version', 'environment', 'agents']
        for key in required_keys:
            self.assertIn(key, config, f"Missing required config key: {key}")
    
    def test_agent_configurations(self):
        """Test that agent YAML files are valid"""
        agents_path = self.expansion_pack_path / "agents"
        
        for agent_file in agents_path.glob("*.yaml"):
            with open(agent_file, 'r') as f:
                agent_config = yaml.safe_load(f)
            
            required_keys = ['name', 'title', 'description', 'persona', 'capabilities']
            for key in required_keys:
                self.assertIn(key, agent_config, f"Missing key {key} in {agent_file.name}")
    
    def test_environment_paths(self):
        """Test that environment paths are correct for the user's setup"""
        config_path = self.expansion_pack_path / "config.yaml"
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)
        
        env = config['environment']
        self.assertEqual(env['bench_path'], "/home/frappe/frappe-bench")
        self.assertEqual(env['primary_site'], "prima-erpnext.pegashosting.com")
        self.assertEqual(env['user'], "frappe")

if __name__ == '__main__':
    unittest.main()
```

**Integration Testing with Your Environment:**
```bash
# Navigate to your bench directory
cd /home/frappe/frappe-bench

# Test that your expansion pack doesn't break existing functionality
# Test docflow app
bench --site prima-erpnext.pegashosting.com run-tests --app docflow

# Test n8n_integration app
bench --site prima-erpnext.pegashosting.com run-tests --app n8n_integration

# If you've created a new app using BMAD agents, test it
bench --site prima-erpnext.pegashosting.com run-tests --app your_new_app

# Test multi-app integration
python /home/frappe/bmad-erpnext-development/tests/test_expansion_pack.py
```

### Expansion Pack Validation Checklist

**Create `checklists/expansion-pack-validation.md`:**

```markdown
# BMAD ERPNext v15 Expansion Pack Validation Checklist

## Expansion Pack Structure
- [ ] All required directories exist (agents, templates, tasks, checklists, data, workflows)
- [ ] config.yaml is valid and complete
- [ ] README.md provides clear usage instructions
- [ ] All YAML files are properly formatted
- [ ] No hardcoded paths outside the user's environment

## Agent Configuration
- [ ] All agents have valid YAML configuration
- [ ] Agent personas are well-defined
- [ ] Dependencies between agents are documented
- [ ] Capabilities are clearly specified
- [ ] Environment paths are correct for user setup

## Templates Quality
- [ ] Templates use proper Handlebars syntax
- [ ] All template parameters are documented
- [ ] Templates generate valid ERPNext code
- [ ] Field types and validations are correct
- [ ] Templates follow Frappe naming conventions

## Tasks Definition
- [ ] All tasks have clear input/output specifications
- [ ] Execution steps are detailed and actionable
- [ ] Error handling procedures are defined
- [ ] Integration considerations are documented
- [ ] Validation rules are comprehensive

## Environment Integration
- [ ] Works with user's existing bench at /home/frappe/frappe-bench
- [ ] Compatible with prima-erpnext.pegashosting.com site
- [ ] Integrates with existing docflow app
- [ ] Compatible with n8n_integration app
- [ ] Respects existing app configurations

## Documentation Quality
- [ ] All agents are documented with usage examples
- [ ] Integration patterns are clearly explained
- [ ] Troubleshooting guide is comprehensive
- [ ] Best practices are documented
- [ ] Examples are tested and working

## Compatibility Testing
- [ ] Expansion pack structure tests pass
- [ ] Agent configurations are valid
- [ ] Templates generate correct code
- [ ] No conflicts with existing apps
- [ ] Multi-app integration works correctly
```

### Common Issues and Troubleshooting

Create `docs/troubleshooting.md`:

```markdown
# Troubleshooting Guide

## Common Issues

### 1. Bench Command Failures
**Error:** "Command not found: bench"
**Solution:**
```bash
# Add to PATH
export PATH="$PATH:~/.local/bin"
# Or use full path
/home/user/.local/bin/bench
```

### 2. Database Connection Errors
**Error:** "Can't connect to MySQL server"
**Solution:**
```bash
# Check MariaDB status
sudo systemctl status mariadb
# Restart if needed
sudo systemctl restart mariadb
```

### 3. Permission Errors
**Error:** "Permission denied"
**Solution:**
```bash
# Fix ownership
sudo chown -R $USER:$USER ~/frappe-bench
# Fix permissions
chmod -R 755 ~/frappe-bench
```

### 4. Import Errors
**Error:** "Module not found"
**Solution:**
```bash
# Reinstall dependencies
bench setup requirements
# Clear cache
bench clear-cache
```

### 5. Migration Failures
**Error:** "Migration failed"
**Solution:**
```bash
# Run migrations manually
bench --site site-name migrate
# Check error log
bench --site site-name console
```
```

## 9. Contributing Your Expansion Pack to BMAD-METHOD

### Preparing Your Expansion Pack for Contribution

Once you've tested your expansion pack thoroughly, you can contribute it back to the BMAD-METHOD project:

**Step 1: Clean Up and Document**
```bash
# Navigate to your BMAD-METHOD directory
cd /home/frappe/bmad-erpnext-development/BMAD-METHOD

# Ensure all files are properly organized
ls expansion-packs/bmad-erpnext-v15/

# Validate your expansion pack
python /home/frappe/bmad-erpnext-development/tests/test_expansion_pack.py
```

**Step 2: Create Comprehensive Documentation**

**Update `expansion-packs/bmad-erpnext-v15/README.md`:**

```markdown
# BMAD ERPNext v15 Expansion Pack

## Overview
Complete BMAD expansion pack for ERPNext v15 development, providing specialized AI agents for ERPNext application development, DocType creation, API development, and multi-app integration.

## Features
- 🤖 6 specialized ERPNext development agents
- 📝 Production-ready DocType and API templates
- 🔄 Integration patterns for existing ERPNext environments
- ✅ Comprehensive testing and validation tools
- 🔧 Multi-app compatibility (docflow, n8n_integration)

## Prerequisites
- Existing ERPNext v15 installation
- Frappe Framework v15.75.0+
- Active Frappe bench environment
- Claude Code with BMAD-METHOD support

## Quick Start
```bash
# Clone BMAD-METHOD repository
git clone https://github.com/bmad-code-org/BMAD-METHOD.git
cd BMAD-METHOD

# Navigate to the expansion pack
cd expansion-packs/bmad-erpnext-v15

# Configure for your environment
cp config.yaml.example config.yaml
# Edit config.yaml with your bench path and site details

# Use with Claude Code
claude
*expansion-pack bmad-erpnext-v15*
```

## Agents
- **erpnext-architect**: System architecture and design
- **bench-operator**: Bench command operations
- **doctype-designer**: DocType creation and modeling
- **api-developer**: REST API development
- **workflow-specialist**: ERPNext workflow integration
- **testing-specialist**: Testing and validation

## Integration Support
This expansion pack is designed to work with existing ERPNext environments and supports:
- Integration with custom apps like docflow
- Compatibility with automation tools like n8n_integration
- Multi-app development workflows
- Production deployment patterns

## Contributing
Contributions welcome! Please read [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines.

## License
MIT License - see [LICENSE](../../LICENSE) for details.
```

**Step 3: Create Example Usage Documentation**

**Create `expansion-packs/bmad-erpnext-v15/EXAMPLES.md`:**

```markdown
# ERPNext v15 Expansion Pack Examples

## Example 1: Creating a Custom DocType

```bash
# Start Claude Code with BMAD expansion pack
claude
*expansion-pack bmad-erpnext-v15*

# Use the doctype-designer agent
*agent doctype-designer*
"Create a Customer Feedback DocType with rating, comments, and follow-up fields"
```

The agent will guide you through:
1. Field selection and validation
2. Relationship modeling
3. Permission setup
4. Integration with existing apps

## Example 2: Building APIs with Integration

```bash
*agent api-developer*
"Create REST APIs for customer portal with:
- User authentication
- Profile management
- Integration with existing docflow for approval processes
- Webhook triggers for n8n_integration notifications"
```

## Example 3: Multi-App Integration Workflow

```bash
*agent erpnext-architect*
"Design a purchase requisition system that:
- Uses ERPNext's existing Purchase Request DocType
- Integrates with docflow for multi-level approvals
- Triggers n8n_integration for vendor notifications
- Maintains compatibility with existing custom apps"
```

## Example 4: Testing Multi-App Compatibility

```bash
*agent testing-specialist*
"Create integration tests that validate:
- New purchase requisition workflow works with existing docflow
- n8n_integration webhooks trigger correctly
- No conflicts with existing custom apps
- Performance impact is minimal"
```

## Real-World Implementation

Based on an actual ERPNext environment with:
- Bench: /home/frappe/frappe-bench
- Site: prima-erpnext.pegashosting.com
- Existing apps: docflow, n8n_integration
- Framework: Frappe v15.75.0

This expansion pack was designed and tested in this specific environment to ensure real-world applicability.
```

### Contributing Back to BMAD METHOD

Create `CONTRIBUTING.md`:

```markdown
# Contributing to BMAD ERPNext Expansion Pack

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/bmad-erpnext-expansion
   cd bmad-erpnext-expansion
   ```

3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/bmad-code-org/BMAD-METHOD
   ```

4. Create feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Process

1. Make your changes
2. Write/update tests
3. Update documentation
4. Run validation:
   ```bash
   # Run tests
   python -m pytest tests/
   
   # Check code style
   flake8 src/
   
   # Build documentation
   mkdocs build
   ```

5. Commit changes:
   ```bash
   git add .
   git commit -m "feat: description of changes"
   ```

6. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

7. Create Pull Request

## Code Standards

- Follow PEP-8 for Python
- Use ESLint for JavaScript
- Write comprehensive tests
- Document all public APIs
- Add entries to CHANGELOG.md

## Testing Requirements

- Maintain >80% code coverage
- All tests must pass
- Include integration tests
- Test with ERPNext v15

## Pull Request Process

1. Ensure all tests pass
2. Update relevant documentation
3. Add changelog entry
4. Request review from maintainers
5. Address review feedback
6. Squash commits if requested

## Release Process

1. Update version in setup.py
2. Update CHANGELOG.md
3. Create git tag:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push upstream v1.0.0
   ```

4. Create GitHub release
5. Publish to package registry

## Questions?

- Open an issue for bugs
- Use discussions for questions
- Join our Discord community
```

This comprehensive guide provides everything needed to build a production-ready BMAD ERPNext v15 expansion pack, with practical examples, actual code, and clear step-by-step instructions that can be followed to create a working implementation.
