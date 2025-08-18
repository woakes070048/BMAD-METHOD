# Setup n8n Triggers

## Overview
This task guides you through setting up n8n workflow triggers that integrate with your ERPNext application, enabling automated workflows triggered by ERPNext events and external systems.

## Prerequisites

### Required Knowledge
- [ ] Understanding of n8n workflow automation platform
- [ ] Knowledge of ERPNext document events and hooks
- [ ] Familiarity with webhook concepts and HTTP APIs
- [ ] Basic understanding of JSON data structures
- [ ] Knowledge of authentication methods (API keys, tokens)

### System Requirements
- [ ] n8n instance is installed and accessible
- [ ] ERPNext development environment is set up
- [ ] Network connectivity between n8n and ERPNext
- [ ] Valid API credentials for ERPNext
- [ ] Admin access to both systems

## Step-by-Step Process

### Step 1: Configure ERPNext for n8n Integration

#### Create n8n Integration User
```python
# Create dedicated user for n8n integration
import frappe

def create_n8n_user():
    """Create dedicated user for n8n integration"""
    
    n8n_user_email = "n8n-integration@your-domain.com"
    
    if not frappe.db.exists("User", n8n_user_email):
        user = frappe.get_doc({
            "doctype": "User",
            "email": n8n_user_email,
            "first_name": "n8n",
            "last_name": "Integration",
            "user_type": "System User",
            "roles": [
                {"role": "System Manager"},  # Adjust based on requirements
                {"role": "API Access"}
            ]
        })
        user.insert()
        
        # Generate API keys
        user.generate_keys()
        
        print(f"n8n integration user created: {n8n_user_email}")
        print(f"API Key: {user.api_key}")
        print("Store these credentials securely in n8n")
    
    return frappe.get_doc("User", n8n_user_email)

# Create the user
create_n8n_user()
```

#### Configure Webhook Endpoints
```python
# your_app/api/n8n_webhooks.py

import frappe
import json
from frappe.utils import now_datetime

@frappe.whitelist(allow_guest=True)
def n8n_webhook_receiver(webhook_id=None):
    """Generic webhook receiver for n8n triggers"""
    
    try:
        # Get request data
        if frappe.request.method == "POST":
            data = json.loads(frappe.request.get_data())
        else:
            data = frappe.request.args
        
        # Log webhook call
        log_webhook_call(webhook_id, data, frappe.request.method)
        
        # Process webhook based on ID
        if webhook_id:
            result = process_webhook_by_id(webhook_id, data)
        else:
            result = {"status": "received", "message": "Webhook received successfully"}
        
        return result
        
    except Exception as e:
        frappe.log_error(f"n8n webhook error: {str(e)}", "n8n Webhook Error")
        frappe.response["http_status_code"] = 400
        return {"error": str(e)}

def log_webhook_call(webhook_id, data, method):
    """Log webhook calls for debugging"""
    
    webhook_log = frappe.get_doc({
        "doctype": "Webhook Log",
        "webhook_id": webhook_id or "unknown",
        "method": method,
        "data": json.dumps(data, default=str),
        "timestamp": now_datetime(),
        "source": "n8n"
    })
    webhook_log.insert(ignore_permissions=True)

def process_webhook_by_id(webhook_id, data):
    """Process webhook based on its ID"""
    
    webhook_handlers = {
        "customer_created": handle_customer_created,
        "order_status_changed": handle_order_status_changed,
        "payment_received": handle_payment_received,
        "inventory_low": handle_inventory_low,
        "task_completed": handle_task_completed
    }
    
    handler = webhook_handlers.get(webhook_id)
    if handler:
        return handler(data)
    else:
        return {"status": "unknown_webhook", "webhook_id": webhook_id}

def handle_customer_created(data):
    """Handle customer creation webhook"""
    
    customer_name = data.get("customer_name")
    email = data.get("email")
    
    if not customer_name or not email:
        return {"error": "Missing required fields: customer_name, email"}
    
    # Create customer in ERPNext
    try:
        customer = frappe.get_doc({
            "doctype": "Customer",
            "customer_name": customer_name,
            "email_id": email,
            "customer_group": data.get("customer_group", "Individual"),
            "territory": data.get("territory", "All Territories")
        })
        customer.insert()
        
        return {
            "status": "success",
            "customer_id": customer.name,
            "message": f"Customer {customer_name} created successfully"
        }
        
    except Exception as e:
        frappe.log_error(f"Customer creation error: {str(e)}")
        return {"error": f"Failed to create customer: {str(e)}"}

@frappe.whitelist()
def trigger_n8n_webhook(webhook_url, data, headers=None):
    """Trigger n8n webhook from ERPNext"""
    
    import requests
    
    try:
        # Prepare headers
        request_headers = {
            "Content-Type": "application/json"
        }
        if headers:
            request_headers.update(headers)
        
        # Send webhook
        response = requests.post(
            webhook_url,
            json=data,
            headers=request_headers,
            timeout=30
        )
        
        response.raise_for_status()
        
        return {
            "status": "success",
            "response": response.json() if response.content else None,
            "status_code": response.status_code
        }
        
    except requests.RequestException as e:
        frappe.log_error(f"n8n webhook trigger error: {str(e)}")
        return {"status": "error", "error": str(e)}
```

### Step 2: Create ERPNext Event Handlers

#### Document Event Hooks for n8n
```python
# your_app/n8n/event_handlers.py

import frappe
from frappe.utils import now_datetime
import json

def on_customer_insert(doc, method):
    """Trigger n8n workflow when customer is created"""
    
    webhook_data = {
        "event": "customer_created",
        "timestamp": now_datetime(),
        "data": {
            "customer_id": doc.name,
            "customer_name": doc.customer_name,
            "email_id": doc.email_id,
            "mobile_no": doc.mobile_no,
            "customer_group": doc.customer_group,
            "territory": doc.territory,
            "creation": doc.creation
        }
    }
    
    trigger_n8n_workflows("customer_created", webhook_data)

def on_sales_order_update(doc, method):
    """Trigger n8n workflow when sales order status changes"""
    
    # Only trigger on status changes
    if doc.has_value_changed("status") or method == "on_submit":
        webhook_data = {
            "event": "sales_order_updated",
            "timestamp": now_datetime(),
            "data": {
                "order_id": doc.name,
                "customer": doc.customer,
                "status": doc.status,
                "grand_total": doc.grand_total,
                "delivery_date": doc.delivery_date,
                "workflow_state": getattr(doc, "workflow_state", None),
                "docstatus": doc.docstatus
            }
        }
        
        trigger_n8n_workflows("sales_order_updated", webhook_data)

def on_payment_entry_submit(doc, method):
    """Trigger n8n workflow when payment is received"""
    
    if doc.payment_type == "Receive":
        webhook_data = {
            "event": "payment_received",
            "timestamp": now_datetime(),
            "data": {
                "payment_id": doc.name,
                "party": doc.party,
                "party_name": doc.party_name,
                "paid_amount": doc.paid_amount,
                "reference_no": doc.reference_no,
                "reference_date": doc.reference_date,
                "mode_of_payment": doc.mode_of_payment
            }
        }
        
        trigger_n8n_workflows("payment_received", webhook_data)

def on_stock_ledger_update(doc, method):
    """Trigger n8n workflow for inventory level changes"""
    
    # Check if stock level is below threshold
    stock_level = frappe.db.get_value("Bin", 
        {"item_code": doc.item_code, "warehouse": doc.warehouse}, 
        "actual_qty") or 0
    
    item_reorder_level = frappe.db.get_value("Item", doc.item_code, "reorder_level") or 0
    
    if stock_level <= item_reorder_level:
        webhook_data = {
            "event": "inventory_low",
            "timestamp": now_datetime(),
            "data": {
                "item_code": doc.item_code,
                "warehouse": doc.warehouse,
                "current_stock": stock_level,
                "reorder_level": item_reorder_level,
                "shortage": item_reorder_level - stock_level
            }
        }
        
        trigger_n8n_workflows("inventory_low", webhook_data)

def trigger_n8n_workflows(event_type, webhook_data):
    """Trigger registered n8n workflows for an event"""
    
    # Get active n8n integrations for this event
    integrations = frappe.get_all("n8n Integration",
        filters={
            "event_type": event_type,
            "is_active": 1
        },
        fields=["name", "webhook_url", "authentication_type", "api_key"]
    )
    
    for integration in integrations:
        try:
            # Prepare headers based on authentication type
            headers = {}
            if integration.authentication_type == "API Key" and integration.api_key:
                headers["Authorization"] = f"Bearer {integration.api_key}"
            
            # Trigger webhook
            frappe.enqueue(
                "your_app.api.n8n_webhooks.trigger_n8n_webhook",
                webhook_url=integration.webhook_url,
                data=webhook_data,
                headers=headers,
                queue="short"
            )
            
        except Exception as e:
            frappe.log_error(f"n8n integration error for {integration.name}: {str(e)}")
```

### Step 3: Create n8n Integration Management

#### n8n Integration DocType
```json
{
    "doctype": "DocType",
    "name": "n8n Integration",
    "module": "Your App",
    "fields": [
        {
            "fieldname": "integration_name",
            "fieldtype": "Data",
            "label": "Integration Name",
            "required": 1
        },
        {
            "fieldname": "event_type",
            "fieldtype": "Select",
            "options": "customer_created\nsales_order_updated\npayment_received\ninventory_low\ntask_completed\ncustom_event",
            "label": "Event Type",
            "required": 1
        },
        {
            "fieldname": "webhook_url",
            "fieldtype": "Data",
            "label": "n8n Webhook URL",
            "required": 1
        },
        {
            "fieldname": "authentication_type",
            "fieldtype": "Select",
            "options": "None\nAPI Key\nBasic Auth\nCustom Header",
            "default": "None",
            "label": "Authentication Type"
        },
        {
            "fieldname": "api_key",
            "fieldtype": "Password",
            "label": "API Key",
            "depends_on": "eval:doc.authentication_type=='API Key'"
        },
        {
            "fieldname": "username",
            "fieldtype": "Data",
            "label": "Username",
            "depends_on": "eval:doc.authentication_type=='Basic Auth'"
        },
        {
            "fieldname": "password",
            "fieldtype": "Password",
            "label": "Password",
            "depends_on": "eval:doc.authentication_type=='Basic Auth'"
        },
        {
            "fieldname": "custom_headers",
            "fieldtype": "JSON",
            "label": "Custom Headers",
            "depends_on": "eval:doc.authentication_type=='Custom Header'"
        },
        {
            "fieldname": "is_active",
            "fieldtype": "Check",
            "default": 1,
            "label": "Is Active"
        },
        {
            "fieldname": "filter_conditions",
            "fieldtype": "JSON",
            "label": "Filter Conditions"
        },
        {
            "fieldname": "data_mapping",
            "fieldtype": "JSON",
            "label": "Data Mapping"
        },
        {
            "fieldname": "retry_count",
            "fieldtype": "Int",
            "default": 3,
            "label": "Retry Count"
        },
        {
            "fieldname": "timeout",
            "fieldtype": "Int",
            "default": 30,
            "label": "Timeout (seconds)"
        }
    ]
}
```

### Step 4: Set Up n8n Workflows

#### Create n8n Workflow Templates
```javascript
// n8n workflow template for ERPNext customer creation
{
  "name": "ERPNext Customer Created",
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "customer-created",
        "responseMode": "onReceived"
      },
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [240, 300]
    },
    {
      "parameters": {
        "conditions": {
          "string": [
            {
              "value1": "={{$json[\"data\"][\"customer_group\"]}}",
              "operation": "equal",
              "value2": "Corporate"
            }
          ]
        }
      },
      "name": "Check if Corporate Customer",
      "type": "n8n-nodes-base.if",
      "typeVersion": 1,
      "position": [460, 300]
    },
    {
      "parameters": {
        "to": "sales@company.com",
        "subject": "New Corporate Customer: {{$json[\"data\"][\"customer_name\"]}}",
        "text": "A new corporate customer has been created:\n\nName: {{$json[\"data\"][\"customer_name\"]}}\nEmail: {{$json[\"data\"][\"email_id\"]}}\nTerritory: {{$json[\"data\"][\"territory\"]}}\n\nPlease follow up for onboarding process."
      },
      "name": "Send Email to Sales Team",
      "type": "n8n-nodes-base.emailSend",
      "typeVersion": 1,
      "position": [680, 200]
    },
    {
      "parameters": {
        "url": "https://crm-system.com/api/contacts",
        "authentication": "headerAuth",
        "sendBody": true,
        "bodyParameters": {
          "parameters": [
            {
              "name": "name",
              "value": "={{$json[\"data\"][\"customer_name\"]}}"
            },
            {
              "name": "email",
              "value": "={{$json[\"data\"][\"email_id\"]}}"
            },
            {
              "name": "source",
              "value": "ERPNext"
            }
          ]
        }
      },
      "name": "Create Contact in CRM",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [680, 400]
    },
    {
      "parameters": {
        "webhook": "https://slack.com/api/chat.postMessage",
        "channel": "#sales-notifications",
        "text": "🎉 New customer created: {{$json[\"data\"][\"customer_name\"]}} ({{$json[\"data\"][\"customer_group\"]}})"
      },
      "name": "Slack Notification",
      "type": "n8n-nodes-base.slack",
      "typeVersion": 1,
      "position": [900, 300]
    }
  ],
  "connections": {
    "Webhook": {
      "main": [
        [
          {
            "node": "Check if Corporate Customer",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Check if Corporate Customer": {
      "main": [
        [
          {
            "node": "Send Email to Sales Team",
            "type": "main",
            "index": 0
          },
          {
            "node": "Create Contact in CRM",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Slack Notification",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Send Email to Sales Team": {
      "main": [
        [
          {
            "node": "Slack Notification",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Create Contact in CRM": {
      "main": [
        [
          {
            "node": "Slack Notification",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  }
}
```

#### Sales Order Processing Workflow
```javascript
// n8n workflow for sales order processing
{
  "name": "ERPNext Sales Order Processing",
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "sales-order-updated",
        "responseMode": "onReceived"
      },
      "name": "Sales Order Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [240, 300]
    },
    {
      "parameters": {
        "conditions": {
          "string": [
            {
              "value1": "={{$json[\"data\"][\"status\"]}}",
              "operation": "equal",
              "value2": "To Deliver"
            }
          ]
        }
      },
      "name": "Check if Ready to Deliver",
      "type": "n8n-nodes-base.if",
      "typeVersion": 1,
      "position": [460, 300]
    },
    {
      "parameters": {
        "url": "https://logistics-api.com/shipments",
        "authentication": "headerAuth",
        "sendBody": true,
        "bodyParameters": {
          "parameters": [
            {
              "name": "order_id",
              "value": "={{$json[\"data\"][\"order_id\"]}}"
            },
            {
              "name": "customer",
              "value": "={{$json[\"data\"][\"customer\"]}}"
            },
            {
              "name": "delivery_date",
              "value": "={{$json[\"data\"][\"delivery_date\"]}}"
            }
          ]
        }
      },
      "name": "Create Shipment",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [680, 200]
    },
    {
      "parameters": {
        "resource": "message",
        "channel": "customer-updates",
        "text": "📦 Order {{$json[\"data\"][\"order_id\"]}} is ready for delivery to {{$json[\"data\"][\"customer\"]}}"
      },
      "name": "Notify Team",
      "type": "n8n-nodes-base.slack",
      "typeVersion": 1,
      "position": [900, 200]
    }
  ]
}
```

### Step 5: Configure Advanced n8n Triggers

#### Scheduled ERPNext Data Sync
```python
# your_app/n8n/scheduled_sync.py

import frappe
from frappe.utils import now_datetime, add_days, get_datetime
import requests

@frappe.whitelist()
def sync_daily_reports_to_n8n():
    """Send daily reports to n8n for processing"""
    
    # Get sales summary for yesterday
    yesterday = add_days(now_datetime(), -1).date()
    
    sales_summary = frappe.db.sql("""
        SELECT 
            COUNT(*) as order_count,
            SUM(grand_total) as total_sales,
            AVG(grand_total) as avg_order_value
        FROM `tabSales Order`
        WHERE DATE(creation) = %s
        AND docstatus = 1
    """, [yesterday], as_dict=True)[0]
    
    # Get top customers
    top_customers = frappe.db.sql("""
        SELECT 
            customer,
            COUNT(*) as order_count,
            SUM(grand_total) as total_spent
        FROM `tabSales Order`
        WHERE DATE(creation) = %s
        AND docstatus = 1
        GROUP BY customer
        ORDER BY total_spent DESC
        LIMIT 5
    """, [yesterday], as_dict=True)
    
    # Get inventory alerts
    low_stock_items = frappe.db.sql("""
        SELECT 
            b.item_code,
            b.actual_qty,
            i.reorder_level,
            i.item_name
        FROM `tabBin` b
        JOIN `tabItem` i ON b.item_code = i.name
        WHERE b.actual_qty <= i.reorder_level
        AND i.is_stock_item = 1
    """, as_dict=True)
    
    report_data = {
        "date": str(yesterday),
        "sales_summary": sales_summary,
        "top_customers": top_customers,
        "low_stock_items": low_stock_items,
        "generated_at": now_datetime()
    }
    
    # Send to n8n webhook
    webhook_url = frappe.db.get_single_value("n8n Settings", "daily_report_webhook")
    if webhook_url:
        try:
            response = requests.post(webhook_url, json=report_data, timeout=30)
            response.raise_for_status()
            
            frappe.log_error(f"Daily report sent to n8n successfully", "n8n Daily Report")
            
        except Exception as e:
            frappe.log_error(f"Failed to send daily report to n8n: {str(e)}", "n8n Daily Report Error")

def setup_scheduled_jobs():
    """Set up scheduled jobs for n8n integration"""
    
    # Add to hooks.py
    scheduler_events = {
        "daily": [
            "your_app.n8n.scheduled_sync.sync_daily_reports_to_n8n"
        ]
    }
```

#### Complex Conditional Triggers
```python
# your_app/n8n/conditional_triggers.py

import frappe
import json

def check_customer_lifecycle_stage(customer_id):
    """Determine customer lifecycle stage and trigger appropriate n8n workflow"""
    
    customer = frappe.get_doc("Customer", customer_id)
    
    # Calculate customer metrics
    total_orders = frappe.db.count("Sales Order", {"customer": customer_id, "docstatus": 1})
    total_spent = frappe.db.sql("""
        SELECT COALESCE(SUM(grand_total), 0)
        FROM `tabSales Order`
        WHERE customer = %s AND docstatus = 1
    """, [customer_id])[0][0]
    
    last_order_date = frappe.db.sql("""
        SELECT MAX(transaction_date)
        FROM `tabSales Order`
        WHERE customer = %s AND docstatus = 1
    """, [customer_id])[0][0]
    
    # Determine lifecycle stage
    stage = "new"
    if total_orders == 0:
        stage = "prospect"
    elif total_orders == 1:
        stage = "first_time"
    elif total_orders >= 2 and total_spent >= 10000:
        stage = "vip"
    elif total_orders >= 2:
        stage = "repeat"
    
    # Check for churned customers
    if last_order_date:
        days_since_last_order = (frappe.utils.today() - last_order_date).days
        if days_since_last_order > 90:
            stage = "at_risk"
        elif days_since_last_order > 180:
            stage = "churned"
    
    # Trigger appropriate n8n workflow
    workflow_data = {
        "customer_id": customer_id,
        "customer_name": customer.customer_name,
        "lifecycle_stage": stage,
        "total_orders": total_orders,
        "total_spent": total_spent,
        "last_order_date": str(last_order_date) if last_order_date else None,
        "metrics": {
            "avg_order_value": total_spent / max(total_orders, 1),
            "days_since_last_order": days_since_last_order if last_order_date else None
        }
    }
    
    trigger_n8n_workflows(f"customer_lifecycle_{stage}", workflow_data)

def monitor_sales_performance():
    """Monitor sales performance and trigger alerts"""
    
    # Get current month performance
    current_month_sales = frappe.db.sql("""
        SELECT COALESCE(SUM(grand_total), 0)
        FROM `tabSales Order`
        WHERE MONTH(transaction_date) = MONTH(CURDATE())
        AND YEAR(transaction_date) = YEAR(CURDATE())
        AND docstatus = 1
    """)[0][0]
    
    # Get target (could be from a settings doc)
    monthly_target = frappe.db.get_single_value("Sales Settings", "monthly_target") or 0
    
    # Calculate performance percentage
    performance_pct = (current_month_sales / monthly_target * 100) if monthly_target > 0 else 0
    
    # Trigger different workflows based on performance
    if performance_pct < 50:
        trigger_type = "sales_performance_low"
    elif performance_pct < 80:
        trigger_type = "sales_performance_moderate"
    elif performance_pct >= 100:
        trigger_type = "sales_target_achieved"
    else:
        trigger_type = "sales_performance_good"
    
    performance_data = {
        "current_sales": current_month_sales,
        "monthly_target": monthly_target,
        "performance_percentage": performance_pct,
        "month": frappe.utils.today().strftime("%B %Y"),
        "alert_level": trigger_type.replace("sales_performance_", "").replace("sales_target_", "")
    }
    
    trigger_n8n_workflows(trigger_type, performance_data)
```

### Step 6: Create n8n Response Handlers

#### Handle n8n Responses
```python
# your_app/api/n8n_responses.py

import frappe
import json

@frappe.whitelist()
def handle_n8n_response(integration_id, response_data, status="success"):
    """Handle responses from n8n workflows"""
    
    try:
        response_data = json.loads(response_data) if isinstance(response_data, str) else response_data
        
        # Log the response
        response_log = frappe.get_doc({
            "doctype": "n8n Response Log",
            "integration_id": integration_id,
            "status": status,
            "response_data": json.dumps(response_data, default=str),
            "timestamp": frappe.utils.now_datetime()
        })
        response_log.insert()
        
        # Process response based on integration type
        integration = frappe.get_doc("n8n Integration", integration_id)
        
        if integration.event_type == "customer_created":
            handle_customer_creation_response(response_data)
        elif integration.event_type == "sales_order_updated":
            handle_order_update_response(response_data)
        elif integration.event_type == "payment_received":
            handle_payment_response(response_data)
        
        return {"status": "success", "message": "Response processed successfully"}
        
    except Exception as e:
        frappe.log_error(f"n8n response handling error: {str(e)}")
        return {"status": "error", "error": str(e)}

def handle_customer_creation_response(response_data):
    """Handle response from customer creation workflow"""
    
    customer_id = response_data.get("customer_id")
    external_id = response_data.get("external_customer_id")
    
    if customer_id and external_id:
        # Update customer with external system ID
        frappe.db.set_value("Customer", customer_id, "external_customer_id", external_id)
        
        # Create comment
        customer_doc = frappe.get_doc("Customer", customer_id)
        customer_doc.add_comment("Info", f"Customer synced to external system with ID: {external_id}")

@frappe.whitelist()
def n8n_callback_handler():
    """Generic callback handler for n8n workflows"""
    
    try:
        data = json.loads(frappe.request.get_data())
        
        callback_type = data.get("callback_type")
        workflow_id = data.get("workflow_id")
        status = data.get("status", "completed")
        result_data = data.get("data", {})
        
        # Process based on callback type
        if callback_type == "workflow_completed":
            handle_workflow_completion(workflow_id, result_data)
        elif callback_type == "workflow_failed":
            handle_workflow_failure(workflow_id, result_data)
        elif callback_type == "user_action_required":
            handle_user_action_request(workflow_id, result_data)
        
        return {"status": "received"}
        
    except Exception as e:
        frappe.log_error(f"n8n callback error: {str(e)}")
        frappe.response["http_status_code"] = 400
        return {"error": str(e)}

def handle_workflow_completion(workflow_id, result_data):
    """Handle completed n8n workflow"""
    
    # Create completion record
    completion = frappe.get_doc({
        "doctype": "n8n Workflow Completion",
        "workflow_id": workflow_id,
        "completion_date": frappe.utils.now_datetime(),
        "result_data": json.dumps(result_data, default=str),
        "status": "Completed"
    })
    completion.insert()
    
    # Process results if needed
    if "created_records" in result_data:
        for record in result_data["created_records"]:
            # Handle created records
            pass
```

### Step 7: Monitor and Debug n8n Integration

#### Create Monitoring Dashboard
```python
# your_app/n8n/monitoring.py

import frappe
from frappe.utils import now_datetime, add_days

def get_n8n_integration_stats():
    """Get statistics for n8n integration monitoring"""
    
    # Total integrations
    total_integrations = frappe.db.count("n8n Integration", {"is_active": 1})
    
    # Webhook calls in last 24 hours
    last_24h = add_days(now_datetime(), -1)
    recent_calls = frappe.db.count("Webhook Log", {
        "timestamp": [">=", last_24h],
        "source": "n8n"
    })
    
    # Failed webhooks
    failed_calls = frappe.db.count("Webhook Log", {
        "timestamp": [">=", last_24h],
        "source": "n8n",
        "status": "failed"
    })
    
    # Success rate
    success_rate = ((recent_calls - failed_calls) / max(recent_calls, 1)) * 100
    
    # Most active integrations
    active_integrations = frappe.db.sql("""
        SELECT 
            ni.integration_name,
            COUNT(wl.name) as call_count
        FROM `tabn8n Integration` ni
        LEFT JOIN `tabWebhook Log` wl ON wl.integration_id = ni.name
        WHERE wl.timestamp >= %s
        GROUP BY ni.name
        ORDER BY call_count DESC
        LIMIT 5
    """, [last_24h], as_dict=True)
    
    return {
        "total_integrations": total_integrations,
        "recent_calls": recent_calls,
        "failed_calls": failed_calls,
        "success_rate": round(success_rate, 2),
        "active_integrations": active_integrations,
        "last_updated": now_datetime()
    }

@frappe.whitelist()
def test_n8n_integration(integration_name):
    """Test n8n integration with sample data"""
    
    integration = frappe.get_doc("n8n Integration", integration_name)
    
    # Create test data based on event type
    test_data = get_test_data_for_event(integration.event_type)
    
    # Send test webhook
    try:
        import requests
        
        headers = {"Content-Type": "application/json"}
        if integration.authentication_type == "API Key" and integration.api_key:
            headers["Authorization"] = f"Bearer {integration.api_key}"
        
        response = requests.post(
            integration.webhook_url,
            json=test_data,
            headers=headers,
            timeout=integration.timeout or 30
        )
        
        response.raise_for_status()
        
        return {
            "status": "success",
            "response_code": response.status_code,
            "response_data": response.json() if response.content else None,
            "test_data": test_data
        }
        
    except Exception as e:
        return {
            "status": "error",
            "error": str(e),
            "test_data": test_data
        }

def get_test_data_for_event(event_type):
    """Generate test data for different event types"""
    
    test_data_templates = {
        "customer_created": {
            "event": "customer_created",
            "data": {
                "customer_id": "TEST-CUST-001",
                "customer_name": "Test Customer",
                "email_id": "test@example.com",
                "customer_group": "Individual",
                "territory": "All Territories"
            }
        },
        "sales_order_updated": {
            "event": "sales_order_updated",
            "data": {
                "order_id": "SO-TEST-001",
                "customer": "Test Customer",
                "status": "Draft",
                "grand_total": 1000.00,
                "delivery_date": "2024-01-15"
            }
        },
        "payment_received": {
            "event": "payment_received",
            "data": {
                "payment_id": "PE-TEST-001",
                "party": "Test Customer",
                "paid_amount": 500.00,
                "mode_of_payment": "Cash"
            }
        }
    }
    
    return test_data_templates.get(event_type, {"event": event_type, "data": {"test": True}})
```

### Step 8: Error Handling and Retry Logic

#### Implement Retry Mechanism
```python
# your_app/n8n/retry_handler.py

import frappe
from frappe.utils import now_datetime, add_minutes
import requests

def retry_failed_webhooks():
    """Retry failed webhook calls"""
    
    # Get failed webhooks that haven't exceeded retry limit
    failed_webhooks = frappe.db.sql("""
        SELECT wl.name, wl.webhook_id, wl.data, ni.webhook_url, 
               ni.retry_count, ni.timeout
        FROM `tabWebhook Log` wl
        JOIN `tabn8n Integration` ni ON wl.integration_id = ni.name
        WHERE wl.status = 'failed'
        AND wl.retry_count < ni.retry_count
        AND wl.next_retry_time <= %s
    """, [now_datetime()], as_dict=True)
    
    for webhook in failed_webhooks:
        try:
            # Attempt retry
            retry_webhook(webhook)
            
        except Exception as e:
            frappe.log_error(f"Retry attempt failed for webhook {webhook.name}: {str(e)}")

def retry_webhook(webhook_data):
    """Retry a single webhook"""
    
    webhook_log = frappe.get_doc("Webhook Log", webhook_data.name)
    
    try:
        # Prepare request
        import json
        data = json.loads(webhook_data.data)
        
        response = requests.post(
            webhook_data.webhook_url,
            json=data,
            timeout=webhook_data.timeout or 30
        )
        
        response.raise_for_status()
        
        # Update webhook log as successful
        webhook_log.status = "success"
        webhook_log.retry_count += 1
        webhook_log.last_retry_time = now_datetime()
        webhook_log.response_data = response.text
        webhook_log.save()
        
    except Exception as e:
        # Update retry information
        webhook_log.retry_count += 1
        webhook_log.last_retry_time = now_datetime()
        webhook_log.error_message = str(e)
        
        # Calculate next retry time (exponential backoff)
        retry_delay = min(2 ** webhook_log.retry_count, 60)  # Max 60 minutes
        webhook_log.next_retry_time = add_minutes(now_datetime(), retry_delay)
        
        # Check if max retries reached
        if webhook_log.retry_count >= webhook_data.retry_count:
            webhook_log.status = "permanently_failed"
        
        webhook_log.save()
        raise
```

## Best Practices

### Security
- Use dedicated API users with minimal required permissions
- Implement proper authentication for all webhook endpoints
- Validate webhook signatures where possible
- Store sensitive credentials securely
- Implement rate limiting for webhook endpoints

### Performance
- Use background jobs for heavy processing
- Implement proper retry logic with exponential backoff
- Monitor webhook response times
- Clean up old logs periodically
- Use caching for frequently accessed data

### Reliability
- Implement comprehensive error handling
- Log all webhook activities for debugging
- Set up monitoring and alerting
- Test integrations regularly
- Plan for network failures and timeouts

### Monitoring
- Track integration performance metrics
- Monitor webhook success/failure rates
- Set up alerts for critical failures
- Create dashboards for operational visibility
- Regular health checks of n8n workflows

## Common Issues and Solutions

### Issue: Webhooks Not Triggering
**Solution**: Check ERPNext event hooks are properly configured and n8n Integration records are active

### Issue: Authentication Failures
**Solution**: Verify API credentials and authentication headers are correctly configured

### Issue: Timeout Errors
**Solution**: Increase timeout values and optimize n8n workflow performance

### Issue: Data Format Errors
**Solution**: Validate data structures and implement proper JSON serialization

---

*Your n8n integration is now complete with comprehensive trigger management, error handling, and monitoring capabilities. This enables powerful automation workflows between ERPNext and external systems.*