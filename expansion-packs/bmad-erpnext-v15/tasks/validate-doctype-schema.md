# validate-doctype-schema

## Task Description
Validate DocType schema design against Frappe Framework standards and ERPNext best practices before implementation.

## Parameters
- `doctype_name`: Name of the DocType to validate
- `schema_data`: DocType field configuration and metadata
- `validation_level`: strict, standard, or basic (default: standard)

## Prerequisites
- DocType design completed
- Field specifications documented
- Business requirements understood

## Steps

### 1. Schema Structure Validation
```python
# Validate basic DocType structure
required_fields = ['doctype', 'name', 'fields', 'permissions']
validate_required_structure(schema_data, required_fields)

# Check naming conventions
validate_naming_convention(doctype_name)
```

### 2. Field Type Validation
```python
# Validate field types and configurations
for field in schema_data.get('fields', []):
    validate_field_configuration(field)
    check_field_constraints(field)
    validate_field_relationships(field)
```

### 3. Relationship Validation
```python
# Validate Link and Table relationships
validate_link_fields(schema_data)
validate_table_relationships(schema_data)
check_circular_dependencies(schema_data)
```

### 4. Permission Matrix Validation
```python
# Validate permission configuration
validate_role_permissions(schema_data.get('permissions', []))
check_permission_logic(schema_data)
```

### 5. Performance Considerations
```python
# Check for performance implications
validate_indexing_strategy(schema_data)
check_field_optimization(schema_data)
validate_query_patterns(schema_data)
```

### 6. Integration Compatibility
```python
# Check compatibility with existing systems
validate_docflow_integration(doctype_name)
validate_n8n_integration_points(schema_data)
check_erpnext_compatibility(schema_data)
```

## Validation Rules

### Field Naming
- Use snake_case for field names
- Avoid reserved keywords
- Maximum 140 characters for fieldnames
- Must start with letter or underscore

### Field Types
- **Data**: Max 140 characters, for short text
- **Text**: For longer text content
- **Link**: Must reference valid DocType
- **Select**: Provide valid options
- **Currency**: Use with precision setting
- **Date/Datetime**: Proper format validation

### Required Field Patterns
```yaml
mandatory_patterns:
  - name: Always auto-generated
  - creation: System managed
  - modified: System managed
  - owner: System managed
  - docstatus: Required for submittable docs
```

### Permission Validation
```yaml
permission_checks:
  - role_exists: Validate all referenced roles exist
  - permission_logic: Read < Write < Submit < Cancel
  - user_permission: Check user permission compatibility
```

## Output Format
```yaml
validation_result:
  status: "passed|failed|warnings"
  errors:
    - field: "field_name"
      error: "Error description"
      severity: "error|warning|info"
  recommendations:
    - category: "performance|security|usability"
      suggestion: "Improvement suggestion"
  compatibility:
    frappe_version: "Compatible/Incompatible"
    erpnext_integration: "Yes/No/Partial"
    docflow_ready: "Yes/No"
```

## Post-Validation Actions
1. Document validation results
2. Address critical errors before implementation
3. Consider performance recommendations
4. Update DocType design based on findings
5. Re-validate if major changes made

## Error Categories

### Critical Errors (Must Fix)
- Invalid field types
- Circular dependencies
- Reserved keyword usage
- Missing required system fields

### Warnings (Should Fix)
- Performance concerns
- Naming convention deviations
- Missing indexing opportunities
- Suboptimal relationship design

### Recommendations (Consider)
- UI/UX improvements
- Additional validation rules
- Enhanced security measures
- Integration enhancements

## Integration Points
- **DocType Designer**: Primary agent using this task
- **ERPNext Architect**: Schema architecture validation
- **Frappe Compliance Validator**: Framework compliance checks
- **Testing Specialist**: Test case generation from schema