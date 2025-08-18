# Task: Create Jinja Templates

## Description
Create and optimize Jinja2 templates for dynamic code generation in ERPNext development. This task involves designing reusable templates for generating Python controllers, JavaScript files, DocType definitions, and API endpoints.

## Required Agents
- jinja-template-specialist
- api-architect
- doctype-designer

## Input Requirements
1. **Template Requirements**:
   - Target code patterns
   - Variable data structures
   - Conditional logic needs
   - Loop requirements

2. **Generation Context**:
   - Output file types
   - Code standards
   - ERPNext patterns
   - Performance requirements

## Process Steps

### 1. Template Structure Design
```yaml
template_structure:
  base_templates:
    - controller.py.j2
    - client_script.js.j2
    - doctype.json.j2
    - api_endpoint.py.j2
    
  partial_templates:
    - _imports.j2
    - _methods.j2
    - _validations.j2
    - _hooks.j2
    
  macro_libraries:
    - field_generators.j2
    - permission_builders.j2
    - validation_helpers.j2
```

### 2. Python Controller Template
```jinja2
# controller.py.j2
import frappe
from frappe.model.document import Document
{% for import in custom_imports %}
{{ import }}
{% endfor %}

class {{ class_name }}(Document):
    {% if has_validation %}
    def validate(self):
        """Validate document before saving"""
        {% for validation in validations %}
        self.{{ validation.method }}()
        {% endfor %}
    {% endif %}
    
    {% for method in methods %}
    def {{ method.name }}(self{{ ', ' + method.params if method.params }}):
        """{{ method.description }}"""
        {% if method.implementation %}
        {{ method.implementation | indent(8) }}
        {% else %}
        pass
        {% endif %}
    {% endfor %}
    
    {% if has_hooks %}
    {% for hook in hooks %}
    def {{ hook.name }}(self):
        """{{ hook.description }}"""
        {{ hook.implementation | indent(8) }}
    {% endfor %}
    {% endif %}
```

### 3. API Endpoint Template
```jinja2
# api_endpoint.py.j2
import frappe
from frappe import _
{% if needs_validation %}
from frappe.utils import validate_email_address, cint, flt
{% endif %}

@frappe.whitelist({% if methods %}methods={{ methods }}{% endif %})
def {{ function_name }}({{ parameters | join(', ') }}):
    """
    {{ description }}
    
    Args:
        {% for param in parameter_docs %}
        {{ param.name }}: {{ param.description }}
        {% endfor %}
    
    Returns:
        {{ return_description }}
    """
    {% if check_permissions %}
    # Permission check
    if not frappe.has_permission("{{ doctype }}", "{{ permission_type }}"):
        frappe.throw(_("Insufficient permissions"), frappe.PermissionError)
    {% endif %}
    
    try:
        {% if validate_params %}
        # Parameter validation
        {% for validation in param_validations %}
        {{ validation }}
        {% endfor %}
        {% endif %}
        
        # Business logic
        {{ business_logic | indent(8) }}
        
        return {
            "success": True,
            "data": result,
            "message": _("{{ success_message }}")
        }
        
    except Exception as e:
        frappe.log_error(message=str(e), title="{{ error_title }}")
        return {
            "success": False,
            "error": str(e)
        }
```

### 4. DocType JSON Template
```jinja2
# doctype.json.j2
{
    "name": "{{ doctype_name }}",
    "module": "{{ module }}",
    "custom": {{ custom | tojson }},
    "is_submittable": {{ is_submittable | int }},
    "is_tree": {{ is_tree | int }},
    "track_changes": {{ track_changes | int }},
    "fields": [
        {% for field in fields %}
        {
            "fieldname": "{{ field.fieldname }}",
            "fieldtype": "{{ field.fieldtype }}",
            "label": "{{ field.label }}",
            {% if field.reqd %}"reqd": 1,{% endif %}
            {% if field.unique %}"unique": 1,{% endif %}
            {% if field.options %}"options": "{{ field.options }}",{% endif %}
            {% if field.default %}"default": "{{ field.default }}",{% endif %}
            {% if field.description %}"description": "{{ field.description }}",{% endif %}
            "permlevel": {{ field.permlevel | default(0) }}
        }{% if not loop.last %},{% endif %}
        {% endfor %}
    ],
    "permissions": [
        {% for perm in permissions %}
        {
            "role": "{{ perm.role }}",
            "read": {{ perm.read | int }},
            "write": {{ perm.write | int }},
            "create": {{ perm.create | int }},
            "delete": {{ perm.delete | int }},
            "submit": {{ perm.submit | int }},
            "cancel": {{ perm.cancel | int }}
        }{% if not loop.last %},{% endif %}
        {% endfor %}
    ]
}
```

### 5. JavaScript Client Script Template
```jinja2
# client_script.js.j2
frappe.ui.form.on('{{ doctype }}', {
    {% if refresh_handler %}
    refresh: function(frm) {
        {{ refresh_handler | indent(8) }}
    },
    {% endif %}
    
    {% if setup_handler %}
    setup: function(frm) {
        {{ setup_handler | indent(8) }}
    },
    {% endif %}
    
    {% for field, handler in field_handlers.items() %}
    {{ field }}: function(frm) {
        {{ handler | indent(8) }}
    },
    {% endfor %}
    
    {% if custom_buttons %}
    onload: function(frm) {
        {% for button in custom_buttons %}
        frm.add_custom_button(__('{{ button.label }}'), function() {
            {{ button.action | indent(12) }}
        }{% if button.group %}, __('{{ button.group }}'){% endif %});
        {% endfor %}
    }
    {% endif %}
});

{% if child_table_handlers %}
{% for child_table, handlers in child_table_handlers.items() %}
frappe.ui.form.on('{{ child_table }}', {
    {% for event, handler in handlers.items() %}
    {{ event }}: function(frm, cdt, cdn) {
        {{ handler | indent(8) }}
    }{% if not loop.last %},{% endif %}
    {% endfor %}
});
{% endfor %}
{% endif %}
```

### 6. Template Helpers and Macros
```jinja2
# macros.j2
{% macro generate_field(field_config) %}
{
    "fieldname": "{{ field_config.name }}",
    "fieldtype": "{{ field_config.type }}",
    "label": "{{ field_config.label }}",
    {% if field_config.required %}"reqd": 1,{% endif %}
    {% if field_config.hidden %}"hidden": 1,{% endif %}
    {% if field_config.read_only %}"read_only": 1{% endif %}
}
{% endmacro %}

{% macro generate_permission(role, permissions) %}
{
    "role": "{{ role }}",
    {% for perm, value in permissions.items() %}
    "{{ perm }}": {{ value | int }}{% if not loop.last %},{% endif %}
    {% endfor %}
}
{% endmacro %}

{% macro generate_validation(field, validation_type) %}
{% if validation_type == "email" %}
if self.{{ field }} and not validate_email_address(self.{{ field }}):
    frappe.throw(_("Invalid email address in {{ field }}"))
{% elif validation_type == "positive" %}
if self.{{ field }} and self.{{ field }} < 0:
    frappe.throw(_("{{ field }} must be positive"))
{% elif validation_type == "required" %}
if not self.{{ field }}:
    frappe.throw(_("{{ field }} is required"))
{% endif %}
{% endmacro %}
```

## Output Format

### Generated Code Structure
```yaml
generated_files:
  controllers:
    - path: "app/module/doctype/controller.py"
      template: "controller.py.j2"
      variables: "controller_config.yaml"
      
  api_modules:
    - path: "app/api/endpoints.py"
      template: "api_endpoint.py.j2"
      variables: "api_config.yaml"
      
  client_scripts:
    - path: "app/public/js/doctype.js"
      template: "client_script.js.j2"
      variables: "client_config.yaml"
      
  doctypes:
    - path: "app/module/doctype/doctype.json"
      template: "doctype.json.j2"
      variables: "doctype_config.yaml"
```

## Success Criteria
- Templates generate valid Python/JavaScript code
- All ERPNext patterns correctly implemented
- Templates are reusable and maintainable
- Generated code passes linting
- Performance optimized (no unnecessary loops)
- Proper error handling included

## Common Patterns

### Template Best Practices
```yaml
best_practices:
  structure:
    - Use inheritance for base templates
    - Create reusable macros
    - Separate concerns into partials
    - Use consistent naming conventions
    
  performance:
    - Minimize template complexity
    - Avoid nested loops when possible
    - Pre-process data before rendering
    - Cache compiled templates
    
  maintainability:
    - Add comments in templates
    - Use meaningful variable names
    - Document template parameters
    - Version control templates
```

## Error Handling

### Template Errors
1. **Syntax Errors**: Validate Jinja2 syntax
2. **Missing Variables**: Provide defaults
3. **Type Errors**: Validate input types
4. **Encoding Issues**: Handle UTF-8 properly
5. **File I/O Errors**: Check write permissions

## Validation Steps
1. Test template rendering with sample data
2. Validate generated code syntax
3. Check ERPNext compatibility
4. Test edge cases and empty data
5. Verify performance with large datasets

## Dependencies
- Jinja2 library installed
- Template directory structure
- Configuration files
- ERPNext code standards
- File system write permissions

## Next Steps
After creating templates:
1. Test with various input configurations
2. Generate sample code for review
3. Optimize template performance
4. Document template usage
5. Create template test suite