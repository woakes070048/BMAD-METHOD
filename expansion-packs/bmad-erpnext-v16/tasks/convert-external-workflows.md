# Task: Convert External Workflows

## Description
Convert workflows from external automation platforms (n8n, Zapier, Make, etc.) to native ERPNext automation using server scripts, scheduled jobs, and DocType hooks.

## Required Agents
- workflow-converter
- trigger-mapper
- api-developer

## Input Requirements
1. **Workflow Export**:
   - JSON/YAML workflow definition
   - Node configurations
   - Credentials and connections
   - Test data samples

2. **Target Requirements**:
   - ERPNext modules involved
   - Performance requirements
   - Error handling needs
   - Monitoring requirements

## Process Steps

### 1. Workflow Analysis
```yaml
workflow_analysis:
  structure:
    - Identify trigger nodes
    - Map action sequences
    - Document conditionals
    - Extract data transformations
    - Note external integrations
    
  components:
    triggers:
      - webhook_receivers
      - scheduled_events
      - file_watchers
      - email_monitors
      
    actions:
      - database_operations
      - api_calls
      - email_sends
      - file_operations
      
    logic:
      - conditional_branches
      - loops_and_iterations
      - error_handlers
      - data_transformations
```

### 2. Node Mapping to ERPNext
```yaml
node_mappings:
  # Trigger Nodes
  webhook_node:
    erpnext_equivalent: "Web Form / API Endpoint"
    implementation: |
      @frappe.whitelist(allow_guest=True)
      def webhook_handler(**kwargs):
          # Process webhook data
          return {"success": True}
          
  schedule_node:
    erpnext_equivalent: "Scheduled Job"
    implementation: |
      # In hooks.py
      scheduler_events = {
          "cron": {
              "0 9 * * *": [
                  "app.module.daily_task"
              ]
          }
      }
      
  database_trigger:
    erpnext_equivalent: "DocType Hook"
    implementation: |
      def after_insert(doc, method):
          # Trigger workflow on insert
          execute_workflow(doc)
          
  # Action Nodes
  http_request_node:
    erpnext_equivalent: "requests in Server Script"
    implementation: |
      import requests
      response = requests.post(
          url,
          json=payload,
          headers=headers
      )
      
  database_node:
    erpnext_equivalent: "frappe.db operations"
    implementation: |
      frappe.db.set_value(
          "DocType",
          name,
          fieldname,
          value
      )
      
  email_node:
    erpnext_equivalent: "frappe.sendmail"
    implementation: |
      frappe.sendmail(
          recipients=email_list,
          subject=subject,
          message=content,
          delayed=False
      )
```

### 3. Workflow Conversion Templates
```python
# workflow_converter.py
class WorkflowConverter:
    def __init__(self, workflow_json):
        self.workflow = workflow_json
        self.erpnext_code = []
        
    def convert(self):
        """Main conversion process"""
        # Parse workflow structure
        self.parse_workflow()
        
        # Convert triggers
        self.convert_triggers()
        
        # Convert actions
        self.convert_actions()
        
        # Generate ERPNext implementation
        return self.generate_code()
        
    def convert_triggers(self):
        """Convert trigger nodes to ERPNext events"""
        for node in self.workflow['nodes']:
            if node['type'] == 'trigger':
                if node['subtype'] == 'webhook':
                    self.create_webhook_endpoint(node)
                elif node['subtype'] == 'schedule':
                    self.create_scheduled_job(node)
                elif node['subtype'] == 'database':
                    self.create_doctype_hook(node)
                    
    def create_webhook_endpoint(self, node):
        """Generate webhook API endpoint"""
        code = f'''
@frappe.whitelist(allow_guest={node.get('allow_guest', False)})
def {node['name']}_webhook(**kwargs):
    """Auto-generated webhook from {node['name']}"""
    
    # Validate webhook signature if configured
    if not validate_webhook_signature(kwargs):
        frappe.throw("Invalid webhook signature")
    
    # Process webhook data
    data = frappe.parse_json(kwargs.get('data'))
    
    # Execute workflow actions
    {self.generate_action_chain(node['connections'])}
    
    return {{"success": True, "message": "Webhook processed"}}
'''
        self.erpnext_code.append(code)
        
    def create_scheduled_job(self, node):
        """Generate scheduled job configuration"""
        schedule = node['schedule']
        
        if schedule['type'] == 'cron':
            cron_expression = schedule['expression']
        else:
            # Convert interval to cron
            cron_expression = self.interval_to_cron(schedule)
            
        config = {
            'scheduler_events': {
                'cron': {
                    cron_expression: [
                        f"app.workflows.{node['name']}_scheduled"
                    ]
                }
            }
        }
        
        # Generate the scheduled function
        code = f'''
def {node['name']}_scheduled():
    """Auto-generated scheduled job from {node['name']}"""
    try:
        # Execute workflow actions
        {self.generate_action_chain(node['connections'])}
        
        # Log success
        frappe.log("Scheduled workflow executed: {node['name']}")
        
    except Exception as e:
        frappe.log_error(
            message=str(e),
            title=f"Scheduled workflow error: {node['name']}"
        )
'''
        self.erpnext_code.append(code)
```

### 4. Complex Logic Conversion
```python
# Convert conditional logic
def convert_if_node(node_config):
    """Convert IF/ELSE logic nodes"""
    
    conditions = []
    for condition in node_config['conditions']:
        field = condition['field']
        operator = condition['operator']
        value = condition['value']
        
        # Map operators
        operator_map = {
            'equals': '==',
            'not_equals': '!=',
            'greater': '>',
            'less': '<',
            'contains': 'in',
            'not_contains': 'not in'
        }
        
        py_operator = operator_map.get(operator, '==')
        
        if operator in ['contains', 'not_contains']:
            conditions.append(f'"{value}" {py_operator} {field}')
        else:
            conditions.append(f'{field} {py_operator} "{value}"')
    
    # Generate Python if statement
    condition_str = ' and '.join(conditions)
    
    return f'''
if {condition_str}:
    # True branch actions
    {convert_nodes(node_config['true_branch'])}
else:
    # False branch actions
    {convert_nodes(node_config['false_branch'])}
'''

# Convert loop nodes
def convert_loop_node(node_config):
    """Convert loop/iteration nodes"""
    
    items = node_config['items']
    item_var = node_config['item_name'] or 'item'
    
    return f'''
for {item_var} in {items}:
    try:
        # Loop body actions
        {convert_nodes(node_config['loop_body'])}
        
    except Exception as e:
        # Handle errors in loop
        if {node_config.get('continue_on_error', False)}:
            frappe.log_error(f"Loop iteration error: {{e}}")
            continue
        else:
            raise
'''
```

### 5. Data Transformation Conversion
```python
def convert_data_transformation(transform_config):
    """Convert data transformation nodes"""
    
    transformations = []
    
    for transform in transform_config['operations']:
        if transform['type'] == 'set':
            # Set field value
            transformations.append(
                f"data['{transform['field']}'] = {transform['value']}"
            )
            
        elif transform['type'] == 'rename':
            # Rename field
            transformations.append(
                f"data['{transform['new_name']}'] = data.pop('{transform['old_name']}')"
            )
            
        elif transform['type'] == 'calculate':
            # Calculate value
            expression = transform['expression']
            transformations.append(
                f"data['{transform['field']}'] = {expression}"
            )
            
        elif transform['type'] == 'format':
            # Format value
            if transform['format'] == 'date':
                transformations.append(
                    f"data['{transform['field']}'] = frappe.utils.formatdate(data['{transform['field']}'])"
                )
                
    return '\n'.join(transformations)
```

### 6. Error Handling and Monitoring
```python
def add_error_handling(workflow_code):
    """Add comprehensive error handling"""
    
    return f'''
def execute_workflow_with_monitoring(data):
    """Execute workflow with error handling and monitoring"""
    
    workflow_id = frappe.utils.now()
    
    try:
        # Log workflow start
        frappe.get_doc({{
            "doctype": "Workflow Execution Log",
            "workflow_name": "{workflow_name}",
            "execution_id": workflow_id,
            "status": "Running",
            "start_time": frappe.utils.now()
        }}).insert()
        
        # Execute workflow
        {workflow_code}
        
        # Log success
        frappe.db.set_value(
            "Workflow Execution Log",
            workflow_id,
            {{
                "status": "Success",
                "end_time": frappe.utils.now()
            }}
        )
        
    except Exception as e:
        # Log failure
        frappe.db.set_value(
            "Workflow Execution Log",
            workflow_id,
            {{
                "status": "Failed",
                "error": str(e),
                "end_time": frappe.utils.now()
            }}
        )
        
        # Send alert if configured
        if "{alert_on_error}":
            frappe.sendmail(
                recipients=["{error_email}"],
                subject=f"Workflow Failed: {workflow_name}",
                message=f"Error: {{e}}"
            )
        
        raise
'''
```

## Output Format

### Conversion Result
```yaml
conversion_summary:
  workflow_name: "Order Processing Workflow"
  source_platform: "n8n"
  
  components_converted:
    triggers:
      - type: "webhook"
        erpnext: "API Endpoint"
        
      - type: "schedule"
        erpnext: "Cron Job"
        
    actions:
      - type: "http_request"
        count: 5
        erpnext: "Server Script"
        
      - type: "database"
        count: 3
        erpnext: "DocType Operations"
        
  generated_files:
    - path: "app/workflows/order_processing.py"
      type: "Python Module"
      
    - path: "app/workflows/hooks_config.py"
      type: "Scheduler Configuration"
      
    - path: "app/workflows/api_endpoints.py"
      type: "API Endpoints"
      
  validation:
    syntax_check: "PASS"
    test_execution: "PASS"
    performance_test: "PASS"
```

## Success Criteria
- All workflow nodes converted
- Logic preserved accurately
- Error handling implemented
- Performance comparable to original
- Monitoring in place
- Documentation generated

## Common Patterns

### Conversion Patterns
```yaml
patterns:
  triggers:
    webhook: "API Endpoint with validation"
    schedule: "Cron job in hooks.py"
    email: "Email account integration"
    file: "File watcher scheduled job"
    
  actions:
    api_call: "requests library in server script"
    database: "frappe.db operations"
    transform: "Python data manipulation"
    condition: "if/elif/else statements"
    
  error_handling:
    retry: "Exponential backoff implementation"
    fallback: "Alternative action paths"
    alert: "Email/SMS notifications"
    log: "Error doc creation"
```

## Dependencies
- Workflow export access
- ERPNext development environment
- Required Python libraries
- API credentials
- Test data

## Next Steps
After conversion:
1. Review generated code
2. Test in development
3. Optimize performance
4. Add monitoring
5. Deploy to production