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