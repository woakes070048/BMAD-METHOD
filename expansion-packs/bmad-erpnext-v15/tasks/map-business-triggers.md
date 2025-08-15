# Task: Map Business Triggers

## Description
Map business events and requirements to ERPNext system triggers, webhooks, and automation points. This task identifies all business process triggers and determines the appropriate ERPNext implementation strategy.

## Required Agents
- trigger-mapper
- workflow-specialist
- api-architect

## Input Requirements
1. **Business Process Documentation**:
   - Process flow diagrams
   - Event descriptions
   - Trigger conditions
   - Required actions

2. **System Context**:
   - Existing ERPNext modules
   - Custom DocTypes
   - Integration points
   - External systems

## Process Steps

### 1. Business Event Identification
```yaml
identify_events:
  document_events:
    - Create/Insert events
    - Update/Change events
    - Delete/Cancel events
    - Status transitions
    - Approval workflows
    
  time_based_events:
    - Scheduled tasks
    - Recurring processes
    - Deadline triggers
    - Escalation points
    
  external_events:
    - API calls
    - Webhook receipts
    - Email triggers
    - File uploads
```

### 2. ERPNext Trigger Mapping
```yaml
map_to_erpnext:
  doctype_hooks:
    before_insert: "Validation and defaults"
    after_insert: "Notifications and related docs"
    before_save: "Data transformation"
    after_save: "Update dependencies"
    before_submit: "Approval checks"
    after_submit: "Finalize processes"
    before_cancel: "Reversal checks"
    after_cancel: "Cleanup operations"
    
  server_scripts:
    event_type: "Document Event"
    doctype: "Target DocType"
    script_type: "Python"
    
  client_scripts:
    event_type: "Form Event"
    trigger: "refresh/validate/before_save"
```

### 3. Webhook Configuration
```yaml
webhooks:
  incoming:
    endpoint: "/api/method/app.module.handler"
    authentication: "token/signature"
    payload_validation: true
    
  outgoing:
    trigger_on: "doc_events"
    url: "external_endpoint"
    headers: "auth_headers"
    retry_policy: "exponential_backoff"
```

### 4. Scheduled Jobs Setup
```yaml
scheduler_events:
  all:
    - "app.module.function"
  hourly:
    - "app.tasks.hourly_sync"
  daily:
    - "app.tasks.daily_cleanup"
  weekly:
    - "app.tasks.weekly_report"
  monthly:
    - "app.tasks.monthly_aggregation"
  cron:
    "0 */6 * * *": "app.tasks.six_hour_task"
    "30 2 * * *": "app.tasks.nightly_batch"
```

### 5. Workflow State Triggers
```yaml
workflow_triggers:
  state_changes:
    from_state: "Draft"
    to_state: "Submitted"
    action: "send_approval_request"
    
  auto_transitions:
    condition: "doc.total > 10000"
    action: "escalate_to_manager"
    
  timeout_actions:
    duration: "48 hours"
    action: "auto_reject_or_escalate"
```

### 6. Integration Points
```yaml
integration_triggers:
  email_triggers:
    account: "support@company.com"
    subject_filter: "pattern"
    action: "create_ticket"
    
  file_watchers:
    directory: "/imports"
    pattern: "*.csv"
    action: "process_import"
    
  message_queues:
    broker: "redis"
    queue: "task_queue"
    handler: "process_task"
```

## Output Format

### Trigger Mapping Document
```yaml
business_trigger_map:
  process: "Order Fulfillment"
  
  triggers:
    - name: "New Order Received"
      business_event: "Customer places order"
      erpnext_implementation:
        type: "DocType Hook"
        doctype: "Sales Order"
        event: "after_insert"
        handler: "app.sales.auto_assign_warehouse"
        
    - name: "Payment Confirmation"
      business_event: "Payment gateway webhook"
      erpnext_implementation:
        type: "Webhook"
        endpoint: "/api/method/app.payments.confirm"
        validation: "signature_verification"
        
    - name: "Daily Inventory Check"
      business_event: "End of day stock validation"
      erpnext_implementation:
        type: "Scheduled Job"
        frequency: "daily"
        time: "23:00"
        handler: "app.inventory.daily_reconciliation"
        
    - name: "Approval Escalation"
      business_event: "Pending approval > 24 hours"
      erpnext_implementation:
        type: "Workflow Trigger"
        condition: "time_in_state > 24"
        action: "escalate_to_next_level"
```

## Success Criteria
- All business events identified and mapped
- Appropriate ERPNext triggers selected
- Handler functions specified
- Error handling defined
- Performance impact assessed
- Testing strategy documented

## Common Patterns

### Trigger Selection Guide
```yaml
trigger_selection:
  use_doctype_hooks_when:
    - Core business logic
    - Data validation required
    - Related documents need updates
    - Synchronous processing needed
    
  use_server_scripts_when:
    - Simple automation
    - No custom app needed
    - Quick prototyping
    - Client-specific logic
    
  use_webhooks_when:
    - External system integration
    - Asynchronous processing
    - Third-party notifications
    - API-based triggers
    
  use_scheduled_jobs_when:
    - Batch processing
    - Regular maintenance
    - Report generation
    - Data synchronization
```

## Error Handling

### Trigger Failure Strategies
1. **Retry Logic**: Implement exponential backoff
2. **Dead Letter Queue**: Store failed triggers
3. **Fallback Actions**: Define alternative flows
4. **Monitoring**: Log all trigger executions
5. **Alerts**: Notify on critical failures

## Validation Steps
1. Test each trigger in isolation
2. Verify trigger sequence and dependencies
3. Load test for performance impact
4. Validate error handling paths
5. Confirm logging and monitoring

## Dependencies
- ERPNext hooks.py configuration
- Server script permissions
- Webhook endpoints accessible
- Scheduler service running
- Workflow definitions created

## Next Steps
After mapping triggers:
1. Implement handler functions
2. Configure webhooks and APIs
3. Set up scheduled jobs
4. Create workflow definitions
5. Test end-to-end scenarios