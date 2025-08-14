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
1. **Pre-Creation Validation**
   - Check bench path exists
   - Verify site is active
   - Confirm app is installed on site
   - Validate module exists in app
   - Run frappe-compliance-validator pre-check
   - Verify no naming conflicts with existing DocTypes
   - Check field type compatibility with Frappe Framework

2. **Validate Input Parameters**
   - DocType name follows PascalCase
   - Field names follow snake_case
   - Field types are valid Frappe types (reference frappe-field-types.yaml)
   - At least one field specified
   - Validate field relationships and Link field targets
   - Check permission matrix for role completeness
   - Verify naming series format if custom naming used

3. **Security and Compliance Pre-Check**
   - Run security validation on field configurations
   - Check for potential data exposure risks
   - Validate permission design against principle of least privilege
   - Ensure no anti-patterns in field design
   - Verify compliance with data protection requirements

4. **Create DocType Structure**
   ```bash
   cd /home/frappe/frappe-bench
   mkdir -p apps/{{app_name}}/{{app_name}}/{{module}}/doctype/{{doctype_name_snake}}
   ```

5. **Generate Files with Validation**
   - Create {{doctype_name}}.json using doctype-template with validation
   - Create {{doctype_name}}.py controller with error handling
   - Create {{doctype_name}}.js client script with validation (if needed)
   - Create test_{{doctype_name}}.py with comprehensive test coverage
   - Run frappe-compliance-validator on generated files

6. **Code Quality Validation**
   - Run static code analysis on Python controller
   - Validate JavaScript follows Frappe UI patterns
   - Check for anti-patterns in controller logic
   - Ensure proper error handling implementation
   - Verify logging and debugging capabilities

7. **Apply to Database with Safety Checks**
   ```bash
   cd /home/frappe/frappe-bench
   # Backup before migration
   bench --site prima-erpnext.pegashosting.com backup
   # Run migration
   bench --site prima-erpnext.pegashosting.com migrate
   ```

8. **Post-Creation Verification**
   - Verify DocType creation successful
   - Test basic CRUD operations
   - Validate permissions work correctly
   - Run unit tests for the new DocType
   - Check database table structure integrity

9. **Integration Validation**
   - Test DocType creation doesn't conflict with docflow
   - Verify n8n_integration compatibility if workflows needed
   - Check multi-app compatibility with existing apps
   - Validate API endpoint accessibility
   - Test frontend rendering and interactions

10. **Performance and Security Testing**
    - Run performance tests on DocType operations
    - Validate query optimization for list views
    - Test security boundaries and access controls
    - Check for potential SQL injection vulnerabilities
    - Verify data validation and sanitization

11. **Documentation and Handoff Validation**
    - Generate DocType documentation
    - Create user guide if needed
    - Document any special configurations
    - Validate all documentation is accurate
    - Prepare handoff notes for team

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