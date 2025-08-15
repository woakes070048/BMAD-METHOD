# Task: Analyze Airtable Base

## Description
Comprehensive analysis of an Airtable base structure to prepare for migration to ERPNext. This task involves examining tables, fields, relationships, views, automations, and formulas to create a complete migration plan.

## Required Agents
- airtable-analyzer
- business-analyst
- doctype-designer

## Input Requirements
1. **Airtable Base Access**:
   - Base ID or share link
   - API key or access token
   - Read permissions to all tables

2. **Migration Context**:
   - Business objectives for migration
   - Timeline and constraints
   - Data volume estimates

## Process Steps

### 1. Base Structure Analysis
```yaml
analyze_base:
  - Extract all table names and descriptions
  - Document table relationships and dependencies
  - Identify primary keys and unique identifiers
  - Map table hierarchy and data flow
```

### 2. Field Type Mapping
```yaml
field_analysis:
  for_each_table:
    - List all fields with their types
    - Identify required vs optional fields
    - Document field validation rules
    - Note calculated/formula fields
    - Identify attachment fields
    - Map lookup and rollup fields
```

### 3. Relationship Documentation
```yaml
relationships:
  - Map linked record relationships
  - Document one-to-many relationships
  - Identify many-to-many relationships
  - Note cascading dependencies
  - Document lookup field chains
```

### 4. View Analysis
```yaml
views:
  for_each_view:
    - Document view type (Grid, Kanban, Calendar, etc.)
    - Extract filter conditions
    - Note sorting and grouping rules
    - Identify hidden fields
    - Document view-specific configurations
```

### 5. Automation Review
```yaml
automations:
  - List all active automations
  - Document trigger conditions
  - Map action sequences
  - Identify external integrations
  - Note webhook configurations
```

### 6. Formula Conversion Planning
```yaml
formulas:
  for_each_formula:
    - Document formula logic
    - Identify ERPNext equivalent functions
    - Plan conversion strategy
    - Note complex calculations requiring custom code
```

### 7. Data Volume Assessment
```yaml
data_metrics:
  - Count records per table
  - Calculate storage requirements
  - Identify large attachment volumes
  - Estimate migration time
  - Plan batch processing strategy
```

## Output Format

### Analysis Report Structure
```yaml
airtable_base_analysis:
  base_info:
    name: "Base Name"
    id: "base_id"
    total_tables: 10
    total_records: 50000
    
  tables:
    - name: "Customers"
      record_count: 5000
      fields:
        - name: "customer_name"
          type: "single_line_text"
          required: true
          erpnext_mapping: "Data"
        - name: "orders"
          type: "linked_record"
          linked_table: "Orders"
          erpnext_mapping: "Table MultiSelect"
      
  relationships:
    - type: "one_to_many"
      parent: "Customers"
      child: "Orders"
      link_field: "customer"
      
  automations:
    - name: "New Customer Welcome"
      trigger: "record_created"
      table: "Customers"
      actions: ["send_email", "create_task"]
      
  migration_plan:
    estimated_duration: "4 hours"
    batch_size: 1000
    priority_order:
      1: "Customers"
      2: "Products"
      3: "Orders"
```

## Success Criteria
- All tables and fields documented
- Relationships clearly mapped
- Field type conversions identified
- Automation migration strategy defined
- Data volume assessed and batching planned
- No missing dependencies

## Common Patterns

### Field Type Mappings
```yaml
airtable_to_erpnext:
  single_line_text: "Data"
  long_text: "Text Editor"
  number: "Float"
  currency: "Currency"
  percent: "Percent"
  single_select: "Select"
  multiple_select: "Table MultiSelect"
  date: "Date"
  datetime: "Datetime"
  checkbox: "Check"
  url: "Data (with URL validation)"
  email: "Data (with email validation)"
  phone: "Phone"
  attachment: "Attach"
  linked_record: "Link"
  lookup: "Read Only (with custom logic)"
  rollup: "Read Only (with aggregation)"
  formula: "Read Only (with server script)"
```

## Error Handling

### Common Issues
1. **Access Denied**: Verify API key and permissions
2. **Rate Limiting**: Implement exponential backoff
3. **Large Datasets**: Use pagination and chunking
4. **Complex Formulas**: Flag for manual review
5. **Circular Dependencies**: Document and plan resolution

## Validation Steps
1. Cross-reference record counts
2. Verify all relationships documented
3. Test sample data extraction
4. Validate field mappings
5. Confirm automation requirements captured

## Dependencies
- Airtable API access
- Network connectivity
- Sufficient memory for large datasets
- ERPNext target environment identified

## Next Steps
After completing analysis:
1. Review with stakeholders
2. Create DocType designs based on tables
3. Plan data transformation scripts
4. Design automation replacements
5. Schedule migration windows