# Task: Generate Technical Documentation

## Description
Automatically generate comprehensive technical documentation for ERPNext applications including API documentation, code documentation, user guides, and system architecture documentation.

## Required Agents
- documentation-specialist
- api-architect
- erpnext-architect

## Input Requirements
1. **Documentation Scope**:
   - Target modules/apps
   - Documentation types needed
   - Target audience
   - Output formats

2. **Source Materials**:
   - Code repositories
   - Existing documentation
   - System configurations
   - API specifications

## Process Steps

### 1. Documentation Analysis
```yaml
documentation_assessment:
  existing_docs:
    - README files
    - Inline code comments
    - API docstrings
    - Wiki pages
    - User manuals
    
  gaps_identified:
    - Missing API documentation
    - Outdated user guides
    - No architecture diagrams
    - Incomplete setup guides
    
  documentation_needs:
    - API reference
    - Developer guide
    - User manual
    - Admin guide
    - Architecture docs
```

### 2. API Documentation Generation
```python
# api_documentation_generator.py
import frappe
import inspect
import json
from typing import Dict, List

class APIDocumentationGenerator:
    def __init__(self, app_name):
        self.app_name = app_name
        self.documentation = {
            'app': app_name,
            'version': self.get_app_version(),
            'endpoints': [],
            'models': [],
            'webhooks': []
        }
    
    def generate(self):
        """Generate complete API documentation"""
        
        # Scan for API endpoints
        self.scan_api_endpoints()
        
        # Document DocTypes
        self.document_doctypes()
        
        # Document webhooks
        self.document_webhooks()
        
        # Generate OpenAPI spec
        self.generate_openapi_spec()
        
        return self.documentation
    
    def scan_api_endpoints(self):
        """Scan and document all API endpoints"""
        
        import os
        import ast
        
        app_path = frappe.get_app_path(self.app_name)
        
        for root, dirs, files in os.walk(app_path):
            for file in files:
                if file.endswith('.py'):
                    filepath = os.path.join(root, file)
                    self.extract_api_methods(filepath)
    
    def extract_api_methods(self, filepath):
        """Extract whitelisted methods from Python file"""
        
        with open(filepath, 'r') as f:
            try:
                tree = ast.parse(f.read())
                
                for node in ast.walk(tree):
                    if isinstance(node, ast.FunctionDef):
                        # Check for @frappe.whitelist decorator
                        for decorator in node.decorator_list:
                            if self.is_whitelist_decorator(decorator):
                                api_doc = self.document_api_method(
                                    node, 
                                    filepath
                                )
                                self.documentation['endpoints'].append(api_doc)
                                
            except SyntaxError:
                pass
    
    def document_api_method(self, node, filepath):
        """Document a single API method"""
        
        # Extract docstring
        docstring = ast.get_docstring(node) or "No description available"
        
        # Parse parameters
        params = []
        for arg in node.args.args:
            if arg.arg != 'self':
                param_doc = {
                    'name': arg.arg,
                    'type': self.get_type_annotation(arg),
                    'required': arg.arg not in [d.arg for d in node.args.defaults],
                    'description': self.extract_param_description(docstring, arg.arg)
                }
                params.append(param_doc)
        
        # Generate endpoint path
        module_path = filepath.replace(frappe.get_app_path(self.app_name), '')
        endpoint_path = f"/api/method/{self.app_name}{module_path.replace('.py', '')}.{node.name}"
        
        return {
            'name': node.name,
            'path': endpoint_path,
            'method': 'POST',  # Default for whitelisted methods
            'description': docstring.split('\n')[0],
            'parameters': params,
            'responses': self.extract_response_info(docstring),
            'examples': self.extract_examples(docstring)
        }
    
    def generate_openapi_spec(self):
        """Generate OpenAPI 3.0 specification"""
        
        openapi_spec = {
            'openapi': '3.0.0',
            'info': {
                'title': f'{self.app_name} API',
                'version': self.documentation['version'],
                'description': f'API documentation for {self.app_name}'
            },
            'servers': [
                {
                    'url': frappe.utils.get_url(),
                    'description': 'Production server'
                }
            ],
            'paths': {},
            'components': {
                'schemas': {},
                'securitySchemes': {
                    'api_key': {
                        'type': 'apiKey',
                        'in': 'header',
                        'name': 'Authorization'
                    }
                }
            }
        }
        
        # Add endpoints to paths
        for endpoint in self.documentation['endpoints']:
            openapi_spec['paths'][endpoint['path']] = {
                endpoint['method'].lower(): {
                    'summary': endpoint['description'],
                    'parameters': self.convert_to_openapi_params(endpoint['parameters']),
                    'responses': endpoint['responses'],
                    'security': [{'api_key': []}]
                }
            }
        
        return openapi_spec
```

### 3. Code Documentation Generation
```python
def generate_code_documentation():
    """Generate code documentation from source files"""
    
    documentation = {
        'modules': {},
        'classes': {},
        'functions': {},
        'constants': {}
    }
    
    # Parse Python modules
    for module_name in get_app_modules(app_name):
        module = importlib.import_module(module_name)
        
        # Document module
        documentation['modules'][module_name] = {
            'docstring': inspect.getdoc(module),
            'file': inspect.getfile(module),
            'classes': [],
            'functions': []
        }
        
        # Document classes
        for name, obj in inspect.getmembers(module, inspect.isclass):
            if obj.__module__ == module_name:
                class_doc = document_class(obj)
                documentation['classes'][f"{module_name}.{name}"] = class_doc
                documentation['modules'][module_name]['classes'].append(name)
        
        # Document functions
        for name, obj in inspect.getmembers(module, inspect.isfunction):
            if obj.__module__ == module_name:
                func_doc = document_function(obj)
                documentation['functions'][f"{module_name}.{name}"] = func_doc
                documentation['modules'][module_name]['functions'].append(name)
    
    return documentation

def document_class(cls):
    """Document a Python class"""
    
    return {
        'name': cls.__name__,
        'docstring': inspect.getdoc(cls),
        'base_classes': [base.__name__ for base in cls.__bases__],
        'methods': {
            name: document_method(method)
            for name, method in inspect.getmembers(cls, inspect.ismethod)
            if not name.startswith('_')
        },
        'properties': {
            name: document_property(prop)
            for name, prop in inspect.getmembers(cls, lambda x: isinstance(x, property))
        }
    }
```

### 4. User Guide Generation
```python
def generate_user_guide(app_name):
    """Generate user guide from DocTypes and workflows"""
    
    guide = {
        'app_name': app_name,
        'modules': {},
        'workflows': {},
        'reports': {}
    }
    
    # Document each module
    modules = frappe.get_all("Module Def", 
                            filters={"app_name": app_name},
                            fields=["name", "module_name"])
    
    for module in modules:
        guide['modules'][module.module_name] = document_module_usage(module)
    
    # Document workflows
    workflows = frappe.get_all("Workflow",
                              filters={"document_type": ("like", f"{app_name}%")},
                              fields=["name", "document_type"])
    
    for workflow in workflows:
        guide['workflows'][workflow.name] = document_workflow_usage(workflow)
    
    # Generate markdown output
    return generate_markdown_guide(guide)

def document_module_usage(module):
    """Document how to use a module"""
    
    doctypes = frappe.get_all("DocType",
                             filters={"module": module.module_name},
                             fields=["name", "description"])
    
    return {
        'description': f"Guide for using {module.module_name}",
        'doctypes': [
            {
                'name': dt.name,
                'description': dt.description,
                'fields': document_doctype_fields(dt.name),
                'permissions': document_doctype_permissions(dt.name),
                'workflows': get_doctype_workflows(dt.name)
            }
            for dt in doctypes
        ]
    }
```

### 5. Architecture Documentation
```python
def generate_architecture_documentation():
    """Generate system architecture documentation"""
    
    architecture = {
        'overview': generate_system_overview(),
        'components': document_components(),
        'data_model': document_data_model(),
        'integrations': document_integrations(),
        'deployment': document_deployment()
    }
    
    # Generate diagrams
    architecture['diagrams'] = {
        'system_architecture': generate_architecture_diagram(),
        'data_flow': generate_data_flow_diagram(),
        'deployment': generate_deployment_diagram()
    }
    
    return architecture

def generate_architecture_diagram():
    """Generate architecture diagram using mermaid"""
    
    return """
    graph TB
        subgraph "Client Layer"
            WEB[Web Browser]
            MOB[Mobile App]
            API[API Client]
        end
        
        subgraph "Application Layer"
            NGINX[Nginx]
            FRAPPE[Frappe Server]
            WORKER[Background Workers]
        end
        
        subgraph "Data Layer"
            REDIS[(Redis Cache)]
            MARIADB[(MariaDB)]
            FILES[File Storage]
        end
        
        WEB --> NGINX
        MOB --> NGINX
        API --> NGINX
        NGINX --> FRAPPE
        FRAPPE --> REDIS
        FRAPPE --> MARIADB
        FRAPPE --> FILES
        WORKER --> REDIS
        WORKER --> MARIADB
    """
```

### 6. Documentation Templates
```markdown
# API Documentation Template

## {{ endpoint.name }}

{{ endpoint.description }}

### Endpoint
```
{{ endpoint.method }} {{ endpoint.path }}
```

### Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
{% for param in endpoint.parameters %}
| {{ param.name }} | {{ param.type }} | {{ param.required }} | {{ param.description }} |
{% endfor %}

### Request Example
```json
{{ endpoint.request_example | tojson(indent=2) }}
```

### Response Example
```json
{{ endpoint.response_example | tojson(indent=2) }}
```

### Error Responses

| Status Code | Description |
|-------------|-------------|
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Invalid authentication |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 500 | Internal Server Error |
```

## Output Format

### Generated Documentation Structure
```yaml
documentation:
  api_reference:
    format: "OpenAPI 3.0"
    file: "api-reference.json"
    endpoints_documented: 45
    
  code_documentation:
    format: "Sphinx"
    files:
      - "docs/source/modules.rst"
      - "docs/source/api.rst"
    coverage: "92%"
    
  user_guides:
    format: "Markdown"
    files:
      - "docs/user-guide.md"
      - "docs/admin-guide.md"
    pages: 120
    
  architecture:
    format: "Markdown + Mermaid"
    files:
      - "docs/architecture.md"
      - "docs/data-model.md"
    diagrams: 8
    
  deployment:
    format: "Markdown"
    files:
      - "docs/deployment.md"
      - "docs/configuration.md"
```

## Success Criteria
- Complete API documentation coverage
- All public methods documented
- User guides for all modules
- Architecture diagrams created
- Examples for all endpoints
- Documentation validates successfully

## Common Patterns

### Documentation Standards
```yaml
standards:
  api_documentation:
    - Include request/response examples
    - Document all parameters
    - Specify authentication requirements
    - List possible error codes
    
  code_documentation:
    - Docstrings for all public methods
    - Type hints where applicable
    - Usage examples in docstrings
    - Link to related documentation
    
  user_documentation:
    - Step-by-step instructions
    - Screenshots where helpful
    - Common use cases
    - Troubleshooting section
```

## Error Handling

### Documentation Generation Issues
1. **Missing Docstrings**: Generate placeholder documentation
2. **Invalid Code**: Skip and log for manual review
3. **Large Codebases**: Process in batches
4. **Complex Relationships**: Simplify diagrams
5. **Version Conflicts**: Document version-specific features

## Dependencies
- Python AST module
- Sphinx documentation generator
- Mermaid for diagrams
- Markdown processor
- OpenAPI validator

## Next Steps
After documentation generation:
1. Review generated documentation
2. Fill in missing descriptions
3. Add examples and use cases
4. Publish to documentation site
5. Set up automated updates