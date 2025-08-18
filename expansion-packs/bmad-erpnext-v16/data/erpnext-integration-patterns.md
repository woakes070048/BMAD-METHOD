# ERPNext Integration Patterns

## Overview
This comprehensive guide outlines proven integration patterns for ERPNext implementations, covering various integration approaches, architectural patterns, and best practices for connecting ERPNext with external systems while maintaining data integrity, performance, and maintainability.

## 1. Integration Architecture Fundamentals

### 1.1 ERPNext Integration Capabilities

#### Native Integration Features
```yaml
erpnext_integration_features:
  api_framework:
    rest_api: "Full CRUD operations via REST endpoints"
    authentication: "Token-based and OAuth 2.0 support"
    rate_limiting: "Configurable request throttling"
    versioning: "API version management"
    
  webhook_system:
    outbound_webhooks: "Event-driven notifications to external systems"
    inbound_webhooks: "Receive data from external systems"
    retry_mechanisms: "Automatic retry with exponential backoff"
    security: "HMAC signature verification"
    
  data_import_export:
    bulk_operations: "Excel/CSV import/export for large datasets"
    data_templates: "Standardized import templates"
    validation: "Pre-import data validation and error reporting"
    
  email_integration:
    smtp_support: "Outbound email automation"
    imap_integration: "Inbound email processing"
    email_accounts: "Multiple email account configuration"
    
  file_management:
    api_access: "File upload/download via API"
    cloud_storage: "Integration with S3, Google Drive, etc."
    document_management: "Automated document attachment"
```

#### Integration Infrastructure Components
```yaml
infrastructure_components:
  frappe_framework:
    job_queue: "Background job processing with RQ (Redis Queue)"
    scheduler: "Cron-like scheduled job execution"
    hooks_system: "Event-driven custom code execution"
    
  database_layer:
    mariadb_mysql: "Primary database with replication support"
    connection_pooling: "Optimized database connections"
    transactions: "ACID compliant transaction management"
    
  caching_layer:
    redis: "In-memory caching and session management"
    application_cache: "Query result and object caching"
    distributed_cache: "Multi-server cache synchronization"
    
  message_queue:
    redis_queue: "Asynchronous job processing"
    pub_sub: "Real-time messaging between components"
    task_monitoring: "Job status tracking and failure handling"
```

### 1.2 Integration Architecture Patterns

#### Hub-and-Spoke Pattern
```yaml
hub_and_spoke_architecture:
  description: "ERPNext as central hub with direct connections to external systems"
  
  use_cases:
    - "Small to medium implementations (< 10 systems)"
    - "Systems with low integration complexity"
    - "Direct point-to-point integrations preferred"
    
  advantages:
    - "Simple architecture and maintenance"
    - "Lower infrastructure costs"
    - "Direct control over integration logic"
    
  disadvantages:
    - "Limited scalability with many systems"
    - "Tight coupling between systems"
    - "Complex error handling across multiple endpoints"
    
  implementation_example:
    erpnext_center:
      connections:
        - target: "Shopify E-commerce"
          method: "REST API"
          direction: "Bi-directional"
          data: ["Products", "Orders", "Inventory"]
          
        - target: "QuickBooks Accounting"
          method: "API Integration"
          direction: "ERPNext to QuickBooks"
          data: ["Customers", "Invoices", "Payments"]
          
        - target: "Salesforce CRM"
          method: "REST API"
          direction: "Salesforce to ERPNext"
          data: ["Leads", "Opportunities", "Contacts"]
```

#### Enterprise Service Bus (ESB) Pattern
```yaml
esb_architecture:
  description: "Integration middleware layer between ERPNext and external systems"
  
  use_cases:
    - "Large enterprises with multiple complex systems"
    - "High transaction volumes requiring message queuing"
    - "Complex data transformations needed"
    - "Enterprise-wide integration governance required"
    
  advantages:
    - "Loose coupling between systems"
    - "Centralized integration governance"
    - "Advanced error handling and monitoring"
    - "Scalable message processing"
    
  components:
    message_broker:
      technology: "Apache Kafka / RabbitMQ / Azure Service Bus"
      capabilities: ["Message routing", "Transformation", "Protocol translation"]
      
    integration_engine:
      technology: "MuleSoft / Apache Camel / Microsoft BizTalk"
      capabilities: ["Workflow orchestration", "Error handling", "Monitoring"]
      
    api_gateway:
      technology: "Kong / Apigee / Azure API Management"
      capabilities: ["Security", "Rate limiting", "Analytics"]
  
  implementation_architecture:
    erpnext_connection:
      method: "Single connection to ESB"
      protocol: "REST API / Message Queue"
      security: "OAuth 2.0 with API Gateway"
      
    external_systems:
      connection_method: "Through ESB only"
      isolation: "ERPNext isolated from external system changes"
      governance: "Centralized policy enforcement"
```

#### Event-Driven Architecture (EDA) Pattern
```yaml
event_driven_architecture:
  description: "Systems communicate through events without direct coupling"
  
  use_cases:
    - "Real-time data synchronization requirements"
    - "Microservices architecture implementations"
    - "High availability and resilience requirements"
    - "Audit trail and event sourcing needs"
    
  core_concepts:
    event_producers:
      erpnext_events: ["Customer created", "Order submitted", "Invoice paid"]
      external_events: ["Inventory updated", "Payment received", "Shipment dispatched"]
      
    event_consumers:
      erpnext_handlers: ["Update inventory", "Create invoice", "Send notifications"]
      external_handlers: ["Sync to CRM", "Update accounting", "Trigger fulfillment"]
      
    event_store:
      technology: "Apache Kafka / EventStore / AWS EventBridge"
      capabilities: ["Event persistence", "Replay", "Time-based queries"]
  
  implementation_pattern:
    event_publication:
      erpnext_hooks: "Custom hooks to publish events on document changes"
      event_format: "CloudEvents standard or custom JSON schema"
      
    event_consumption:
      background_jobs: "ERPNext background jobs consume external events"
      webhook_handlers: "Custom webhook endpoints for event ingestion"
      
    error_handling:
      dead_letter_queues: "Failed event processing handling"
      retry_policies: "Exponential backoff with maximum attempts"
```

## 2. Common Integration Patterns

### 2.1 Real-Time Synchronization Patterns

#### Webhook-Based Real-Time Sync
```python
# ERPNext Webhook Configuration
webhook_config = {
    "webhook_doctype": "Sales Order",
    "webhook_url": "https://external-system.com/api/webhooks/erpnext",
    "request_url": "https://external-system.com/api/webhooks/erpnext/sales_order",
    "webhook_headers": [
        {
            "key": "Authorization",
            "value": "Bearer {api_token}"
        },
        {
            "key": "Content-Type", 
            "value": "application/json"
        }
    ],
    "webhook_data": {
        "event_type": "sales_order_created",
        "document_name": "{{ doc.name }}",
        "customer": "{{ doc.customer }}",
        "grand_total": "{{ doc.grand_total }}",
        "items": "{{ doc.items }}",
        "timestamp": "{{ frappe.utils.now() }}"
    }
}

# Custom webhook handler for enhanced functionality
import frappe
import requests
import json
from frappe.integrations.utils import make_post_request

class CustomWebhookHandler:
    def __init__(self, webhook_config):
        self.config = webhook_config
        
    def send_webhook(self, doc, method):
        """Enhanced webhook with retry and error handling"""
        try:
            # Prepare payload
            payload = self.prepare_payload(doc, method)
            
            # Add security headers
            headers = self.get_headers()
            
            # Send webhook with retry logic
            response = self.send_with_retry(payload, headers)
            
            # Log success
            self.log_webhook_success(doc, response)
            
        except Exception as e:
            # Log error and queue for retry
            self.log_webhook_error(doc, str(e))
            self.queue_for_retry(doc, method)
    
    def prepare_payload(self, doc, method):
        """Prepare webhook payload with document data"""
        return {
            "event_type": f"{doc.doctype.lower()}_{method}",
            "document": {
                "name": doc.name,
                "doctype": doc.doctype,
                "data": doc.as_dict()
            },
            "timestamp": frappe.utils.now_datetime().isoformat(),
            "source": "ERPNext"
        }
    
    def send_with_retry(self, payload, headers, max_retries=3):
        """Send webhook with exponential backoff retry"""
        for attempt in range(max_retries):
            try:
                response = requests.post(
                    self.config['webhook_url'],
                    json=payload,
                    headers=headers,
                    timeout=30
                )
                response.raise_for_status()
                return response
                
            except requests.exceptions.RequestException as e:
                if attempt == max_retries - 1:
                    raise e
                
                # Exponential backoff
                wait_time = 2 ** attempt
                frappe.utils.sleep(wait_time)
```

#### API Polling Pattern
```python
# Scheduled job for polling external systems
import frappe
from frappe.utils import now_datetime, add_to_date
import requests

class APIPollingService:
    def __init__(self, system_config):
        self.config = system_config
        self.last_sync = self.get_last_sync_time()
    
    def poll_external_system(self):
        """Poll external system for updates since last sync"""
        try:
            # Get updates since last sync
            updates = self.fetch_updates_since(self.last_sync)
            
            # Process each update
            for update in updates:
                self.process_update(update)
            
            # Update last sync time
            self.update_last_sync_time(now_datetime())
            
            # Log success
            frappe.logger().info(f"Successfully processed {len(updates)} updates")
            
        except Exception as e:
            frappe.log_error(f"Polling error: {str(e)}")
    
    def fetch_updates_since(self, timestamp):
        """Fetch updates from external system"""
        params = {
            "since": timestamp.isoformat(),
            "limit": 100,
            "format": "json"
        }
        
        response = requests.get(
            f"{self.config['api_url']}/updates",
            params=params,
            headers=self.get_auth_headers(),
            timeout=60
        )
        
        response.raise_for_status()
        return response.json().get('data', [])
    
    def process_update(self, update):
        """Process individual update from external system"""
        try:
            # Determine document type and action
            doctype = self.map_external_type(update['type'])
            action = update.get('action', 'update')
            
            # Process based on action
            if action == 'create':
                self.create_document(doctype, update['data'])
            elif action == 'update':
                self.update_document(doctype, update['data'])
            elif action == 'delete':
                self.delete_document(doctype, update['data'])
                
        except Exception as e:
            # Log error but continue processing other updates
            frappe.log_error(f"Update processing error: {str(e)}")

# Schedule the polling job
def schedule_polling_jobs():
    """Schedule polling jobs for all configured systems"""
    systems = frappe.get_all("Integration System", 
                           filters={"integration_type": "Polling"})
    
    for system in systems:
        frappe.enqueue(
            "custom_app.integrations.polling.poll_system",
            system_name=system.name,
            queue="long",
            timeout=300
        )
```

### 2.2 Batch Processing Patterns

#### File-Based Integration
```python
# File-based batch processing pattern
import frappe
import pandas as pd
from pathlib import Path
import shutil
from datetime import datetime

class FileBatchProcessor:
    def __init__(self, integration_config):
        self.config = integration_config
        self.input_dir = Path(self.config['input_directory'])
        self.processed_dir = Path(self.config['processed_directory'])
        self.error_dir = Path(self.config['error_directory'])
        
    def process_batch_files(self):
        """Process all files in the input directory"""
        try:
            # Get all files to process
            files_to_process = self.get_pending_files()
            
            for file_path in files_to_process:
                self.process_single_file(file_path)
                
        except Exception as e:
            frappe.log_error(f"Batch processing error: {str(e)}")
    
    def process_single_file(self, file_path):
        """Process a single batch file"""
        try:
            # Read and validate file
            data = self.read_and_validate_file(file_path)
            
            # Process records in batches
            batch_size = self.config.get('batch_size', 100)
            total_records = len(data)
            
            for i in range(0, total_records, batch_size):
                batch_data = data[i:i + batch_size]
                self.process_batch_records(batch_data, file_path.name)
            
            # Move file to processed directory
            self.move_file_to_processed(file_path)
            
            # Create processing summary
            self.create_processing_summary(file_path.name, total_records)
            
        except Exception as e:
            # Move file to error directory
            self.move_file_to_error(file_path, str(e))
            frappe.log_error(f"File processing error for {file_path.name}: {str(e)}")
    
    def read_and_validate_file(self, file_path):
        """Read file and perform basic validation"""
        # Determine file type and read accordingly
        if file_path.suffix.lower() == '.csv':
            data = pd.read_csv(file_path)
        elif file_path.suffix.lower() in ['.xlsx', '.xls']:
            data = pd.read_excel(file_path)
        else:
            raise ValueError(f"Unsupported file type: {file_path.suffix}")
        
        # Validate required columns
        required_columns = self.config.get('required_columns', [])
        missing_columns = set(required_columns) - set(data.columns)
        if missing_columns:
            raise ValueError(f"Missing required columns: {missing_columns}")
        
        return data
    
    def process_batch_records(self, batch_data, filename):
        """Process a batch of records with transaction management"""
        with frappe.db.transaction():
            try:
                for index, record in batch_data.iterrows():
                    self.process_single_record(record, filename, index)
                
                # Commit batch if all records processed successfully
                frappe.db.commit()
                
            except Exception as e:
                # Rollback batch on any error
                frappe.db.rollback()
                raise e
    
    def process_single_record(self, record, filename, row_index):
        """Process individual record from batch file"""
        try:
            # Map file data to ERPNext document
            doc_data = self.map_record_to_document(record)
            
            # Create or update document
            if self.config.get('update_existing', False):
                existing_doc = self.find_existing_document(doc_data)
                if existing_doc:
                    existing_doc.update(doc_data)
                    existing_doc.save()
                    return existing_doc
            
            # Create new document
            doc = frappe.get_doc(doc_data)
            doc.insert()
            
            # Log successful processing
            self.log_record_success(filename, row_index, doc.name)
            
            return doc
            
        except Exception as e:
            # Log individual record error
            self.log_record_error(filename, row_index, str(e), record.to_dict())
            raise e
```

#### Database-to-Database Sync
```python
# Direct database synchronization pattern
import frappe
from frappe.utils import now_datetime
import pymysql
import psycopg2

class DatabaseSyncService:
    def __init__(self, external_db_config):
        self.external_config = external_db_config
        self.sync_mappings = self.load_sync_mappings()
        
    def sync_from_external_database(self):
        """Sync data from external database to ERPNext"""
        try:
            # Connect to external database
            external_conn = self.connect_to_external_db()
            
            # Process each configured sync mapping
            for mapping in self.sync_mappings:
                self.sync_table_data(external_conn, mapping)
            
            external_conn.close()
            
        except Exception as e:
            frappe.log_error(f"Database sync error: {str(e)}")
    
    def connect_to_external_db(self):
        """Connect to external database"""
        config = self.external_config
        
        if config['db_type'] == 'mysql':
            return pymysql.connect(
                host=config['host'],
                user=config['user'],
                password=config['password'],
                database=config['database'],
                charset='utf8mb4'
            )
        elif config['db_type'] == 'postgresql':
            return psycopg2.connect(
                host=config['host'],
                user=config['user'],
                password=config['password'],
                database=config['database']
            )
    
    def sync_table_data(self, external_conn, mapping):
        """Sync data from external table to ERPNext DocType"""
        try:
            # Get data from external database since last sync
            last_sync = self.get_last_sync_time(mapping['name'])
            
            query = self.build_sync_query(mapping, last_sync)
            external_data = self.execute_external_query(external_conn, query)
            
            # Process each record
            for record in external_data:
                self.process_external_record(record, mapping)
            
            # Update last sync time
            self.update_last_sync_time(mapping['name'], now_datetime())
            
        except Exception as e:
            frappe.log_error(f"Table sync error for {mapping['name']}: {str(e)}")
    
    def build_sync_query(self, mapping, last_sync):
        """Build SQL query to fetch changed records"""
        base_query = f"SELECT * FROM {mapping['external_table']}"
        
        # Add timestamp filter if available
        if mapping.get('timestamp_column') and last_sync:
            base_query += f" WHERE {mapping['timestamp_column']} > '{last_sync}'"
        
        # Add custom filter if specified
        if mapping.get('custom_filter'):
            connector = " AND " if "WHERE" in base_query else " WHERE "
            base_query += f"{connector}{mapping['custom_filter']}"
        
        return base_query
    
    def process_external_record(self, record, mapping):
        """Process individual record from external database"""
        try:
            # Map external fields to ERPNext fields
            erpnext_data = self.map_external_to_erpnext(record, mapping)
            
            # Check if record exists in ERPNext
            existing_doc = self.find_existing_erpnext_record(erpnext_data, mapping)
            
            if existing_doc:
                # Update existing record
                for field, value in erpnext_data.items():
                    setattr(existing_doc, field, value)
                existing_doc.save()
            else:
                # Create new record
                doc = frappe.get_doc(mapping['erpnext_doctype'])
                doc.update(erpnext_data)
                doc.insert()
                
        except Exception as e:
            frappe.log_error(f"Record processing error: {str(e)}")
```

### 2.3 Message Queue Patterns

#### Asynchronous Message Processing
```python
# Redis Queue-based message processing
import frappe
import redis
import json
from rq import Queue, Worker
from datetime import datetime, timedelta

class MessageQueueIntegration:
    def __init__(self):
        self.redis_conn = redis.Redis.from_url(frappe.conf.redis_queue)
        self.queue = Queue('integration', connection=self.redis_conn)
        
    def publish_message(self, message_type, data, priority='normal'):
        """Publish message to integration queue"""
        message = {
            'type': message_type,
            'data': data,
            'timestamp': datetime.now().isoformat(),
            'source': 'ERPNext'
        }
        
        # Determine job priority and timeout
        job_timeout = self.get_job_timeout(message_type)
        
        # Enqueue message processing job
        job = self.queue.enqueue(
            'custom_app.integrations.message_processor.process_message',
            message,
            timeout=job_timeout,
            retry_attempts=3,
            job_id=f"{message_type}_{frappe.generate_hash()}",
            meta={
                'priority': priority,
                'created_at': datetime.now().isoformat()
            }
        )
        
        return job.id
    
    def process_message(self, message):
        """Process individual message from queue"""
        try:
            message_type = message['type']
            data = message['data']
            
            # Route to appropriate processor based on message type
            processor = self.get_message_processor(message_type)
            result = processor.process(data)
            
            # Log successful processing
            self.log_message_success(message, result)
            
            return result
            
        except Exception as e:
            # Log error and potentially retry
            self.log_message_error(message, str(e))
            
            # Determine if message should be retried
            if self.should_retry_message(message, e):
                self.retry_message(message)
            else:
                self.send_to_dead_letter_queue(message, str(e))
            
            raise e
    
    def get_message_processor(self, message_type):
        """Get appropriate processor for message type"""
        processors = {
            'customer_created': CustomerSyncProcessor(),
            'order_updated': OrderSyncProcessor(),
            'inventory_changed': InventorySyncProcessor(),
            'payment_received': PaymentProcessor()
        }
        
        if message_type not in processors:
            raise ValueError(f"Unknown message type: {message_type}")
        
        return processors[message_type]

class CustomerSyncProcessor:
    def process(self, data):
        """Process customer sync message"""
        # Extract customer data
        customer_data = data.get('customer_data')
        external_id = data.get('external_id')
        
        # Check if customer exists
        existing_customer = frappe.db.get_value(
            "Customer", 
            {"external_id": external_id}, 
            "name"
        )
        
        if existing_customer:
            # Update existing customer
            customer_doc = frappe.get_doc("Customer", existing_customer)
            customer_doc.update(customer_data)
            customer_doc.save()
        else:
            # Create new customer
            customer_doc = frappe.new_doc("Customer")
            customer_doc.update(customer_data)
            customer_doc.external_id = external_id
            customer_doc.insert()
        
        return {
            'status': 'success',
            'customer_name': customer_doc.name,
            'action': 'updated' if existing_customer else 'created'
        }

# Background worker setup
def setup_integration_workers():
    """Set up background workers for integration processing"""
    workers = []
    
    # Create multiple workers for different priorities
    high_priority_queue = Queue('integration_high', connection=redis_conn)
    normal_priority_queue = Queue('integration_normal', connection=redis_conn)
    low_priority_queue = Queue('integration_low', connection=redis_conn)
    
    # Start workers
    for queue_name, queue in [
        ('high', high_priority_queue),
        ('normal', normal_priority_queue), 
        ('low', low_priority_queue)
    ]:
        worker = Worker([queue], connection=redis_conn)
        worker.name = f"integration_worker_{queue_name}"
        workers.append(worker)
    
    return workers
```

## 3. Security Patterns

### 3.1 Authentication and Authorization

#### OAuth 2.0 Integration Pattern
```python
# OAuth 2.0 implementation for external system integration
import frappe
import requests
import jwt
from datetime import datetime, timedelta
import secrets

class OAuth2Integration:
    def __init__(self, client_config):
        self.client_id = client_config['client_id']
        self.client_secret = client_config['client_secret']
        self.auth_url = client_config['authorization_url']
        self.token_url = client_config['token_url']
        self.scope = client_config.get('scope', 'read write')
        
    def get_authorization_url(self, redirect_uri, state=None):
        """Generate authorization URL for OAuth flow"""
        if not state:
            state = secrets.token_urlsafe(32)
        
        params = {
            'client_id': self.client_id,
            'response_type': 'code',
            'redirect_uri': redirect_uri,
            'scope': self.scope,
            'state': state
        }
        
        # Store state for validation
        self.store_oauth_state(state)
        
        return f"{self.auth_url}?" + "&".join([f"{k}={v}" for k, v in params.items()])
    
    def exchange_code_for_token(self, authorization_code, redirect_uri):
        """Exchange authorization code for access token"""
        token_data = {
            'grant_type': 'authorization_code',
            'client_id': self.client_id,
            'client_secret': self.client_secret,
            'code': authorization_code,
            'redirect_uri': redirect_uri
        }
        
        response = requests.post(
            self.token_url,
            data=token_data,
            headers={'Content-Type': 'application/x-www-form-urlencoded'}
        )
        
        if response.status_code != 200:
            raise Exception(f"Token exchange failed: {response.text}")
        
        token_info = response.json()
        
        # Store tokens securely
        self.store_access_tokens(token_info)
        
        return token_info
    
    def refresh_access_token(self, refresh_token):
        """Refresh expired access token"""
        refresh_data = {
            'grant_type': 'refresh_token',
            'client_id': self.client_id,
            'client_secret': self.client_secret,
            'refresh_token': refresh_token
        }
        
        response = requests.post(self.token_url, data=refresh_data)
        
        if response.status_code != 200:
            raise Exception(f"Token refresh failed: {response.text}")
        
        new_token_info = response.json()
        self.store_access_tokens(new_token_info)
        
        return new_token_info
    
    def make_authenticated_request(self, url, method='GET', data=None):
        """Make API request with automatic token refresh"""
        access_token = self.get_valid_access_token()
        
        headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/json'
        }
        
        response = requests.request(method, url, headers=headers, json=data)
        
        # Handle token expiration
        if response.status_code == 401:
            # Try to refresh token and retry request
            refresh_token = self.get_stored_refresh_token()
            if refresh_token:
                self.refresh_access_token(refresh_token)
                headers['Authorization'] = f'Bearer {self.get_valid_access_token()}'
                response = requests.request(method, url, headers=headers, json=data)
        
        return response

# Secure token storage
class SecureTokenStorage:
    @staticmethod
    def encrypt_token(token, key):
        """Encrypt token for secure storage"""
        from cryptography.fernet import Fernet
        cipher_suite = Fernet(key)
        return cipher_suite.encrypt(token.encode()).decode()
    
    @staticmethod
    def decrypt_token(encrypted_token, key):
        """Decrypt stored token"""
        from cryptography.fernet import Fernet
        cipher_suite = Fernet(key)
        return cipher_suite.decrypt(encrypted_token.encode()).decode()
    
    @staticmethod
    def store_tokens(system_name, token_data):
        """Store OAuth tokens securely"""
        encryption_key = frappe.get_conf().get('integration_encryption_key')
        
        encrypted_access_token = SecureTokenStorage.encrypt_token(
            token_data['access_token'], 
            encryption_key
        )
        
        encrypted_refresh_token = SecureTokenStorage.encrypt_token(
            token_data.get('refresh_token', ''), 
            encryption_key
        )
        
        # Store in ERPNext
        token_doc = frappe.get_doc({
            'doctype': 'OAuth Token',
            'system_name': system_name,
            'encrypted_access_token': encrypted_access_token,
            'encrypted_refresh_token': encrypted_refresh_token,
            'expires_at': datetime.now() + timedelta(seconds=token_data['expires_in']),
            'token_type': token_data.get('token_type', 'Bearer'),
            'scope': token_data.get('scope', '')
        })
        token_doc.insert()
```

#### API Key Management Pattern
```python
# Secure API key management for integrations
import frappe
import hashlib
import secrets
from datetime import datetime, timedelta

class APIKeyManager:
    def __init__(self):
        self.key_length = 32
        self.hash_algorithm = 'sha256'
    
    def generate_api_key(self, system_name, permissions=None, expires_in_days=365):
        """Generate new API key for external system"""
        # Generate secure random key
        api_key = secrets.token_urlsafe(self.key_length)
        
        # Hash the key for storage
        key_hash = self.hash_api_key(api_key)
        
        # Create API key record
        api_key_doc = frappe.get_doc({
            'doctype': 'API Key',
            'system_name': system_name,
            'key_hash': key_hash,
            'permissions': frappe.as_json(permissions or {}),
            'created_by': frappe.session.user,
            'expires_at': datetime.now() + timedelta(days=expires_in_days),
            'is_active': 1,
            'last_used': None,
            'usage_count': 0
        })
        api_key_doc.insert()
        
        # Return plain key (only time it's available)
        return {
            'api_key': api_key,
            'key_id': api_key_doc.name,
            'expires_at': api_key_doc.expires_at
        }
    
    def validate_api_key(self, api_key, required_permissions=None):
        """Validate API key and check permissions"""
        # Hash provided key
        key_hash = self.hash_api_key(api_key)
        
        # Find matching key record
        key_doc = frappe.get_doc('API Key', {'key_hash': key_hash})
        
        if not key_doc:
            raise frappe.AuthenticationError("Invalid API key")
        
        # Check if key is active
        if not key_doc.is_active:
            raise frappe.AuthenticationError("API key is disabled")
        
        # Check expiration
        if key_doc.expires_at and datetime.now() > key_doc.expires_at:
            raise frappe.AuthenticationError("API key has expired")
        
        # Check permissions if required
        if required_permissions:
            self.check_permissions(key_doc, required_permissions)
        
        # Update usage statistics
        self.update_key_usage(key_doc)
        
        return key_doc
    
    def hash_api_key(self, api_key):
        """Hash API key for secure storage"""
        salt = frappe.get_conf().get('api_key_salt', 'default_salt')
        return hashlib.pbkdf2_hmac(
            self.hash_algorithm,
            api_key.encode(),
            salt.encode(),
            100000  # iterations
        ).hex()
    
    def check_permissions(self, key_doc, required_permissions):
        """Check if API key has required permissions"""
        key_permissions = frappe.parse_json(key_doc.permissions)
        
        for resource, actions in required_permissions.items():
            if resource not in key_permissions:
                raise frappe.PermissionError(f"API key lacks access to {resource}")
            
            allowed_actions = key_permissions[resource]
            for action in actions:
                if action not in allowed_actions:
                    raise frappe.PermissionError(
                        f"API key lacks {action} permission for {resource}"
                    )
    
    def revoke_api_key(self, key_id, reason="Manually revoked"):
        """Revoke API key"""
        key_doc = frappe.get_doc('API Key', key_id)
        key_doc.is_active = 0
        key_doc.revoked_at = datetime.now()
        key_doc.revocation_reason = reason
        key_doc.save()

# API key authentication decorator
def require_api_key(permissions=None):
    """Decorator for API endpoints requiring API key authentication"""
    def decorator(func):
        def wrapper(*args, **kwargs):
            # Get API key from header
            api_key = frappe.request.headers.get('X-API-Key')
            
            if not api_key:
                frappe.throw("API key required", frappe.AuthenticationError)
            
            # Validate API key
            key_manager = APIKeyManager()
            try:
                key_doc = key_manager.validate_api_key(api_key, permissions)
                
                # Set context for the request
                frappe.local.api_key_doc = key_doc
                
                # Execute original function
                return func(*args, **kwargs)
                
            except frappe.AuthenticationError as e:
                frappe.throw(str(e), frappe.AuthenticationError)
            except frappe.PermissionError as e:
                frappe.throw(str(e), frappe.PermissionError)
                
        return wrapper
    return decorator

# Usage example
@frappe.whitelist(allow_guest=True)
@require_api_key({'customers': ['read', 'write'], 'orders': ['read']})
def external_api_endpoint():
    """Example API endpoint with API key authentication"""
    # API key is validated, proceed with business logic
    return {"status": "success", "message": "Authenticated request processed"}
```

### 3.2 Data Validation and Sanitization

#### Input Validation Pattern
```python
# Comprehensive input validation for integration endpoints
import frappe
import re
from datetime import datetime
from decimal import Decimal, InvalidOperation

class IntegrationValidator:
    def __init__(self, validation_rules):
        self.rules = validation_rules
        self.errors = []
    
    def validate_data(self, data, context=""):
        """Validate data according to defined rules"""
        self.errors = []
        
        for field_name, field_rules in self.rules.items():
            if field_name in data:
                value = data[field_name]
                self.validate_field(field_name, value, field_rules, context)
            elif field_rules.get('required', False):
                self.errors.append(f"{context}{field_name} is required")
        
        return len(self.errors) == 0, self.errors
    
    def validate_field(self, field_name, value, rules, context=""):
        """Validate individual field"""
        # Check data type
        if 'type' in rules:
            if not self.validate_type(value, rules['type']):
                self.errors.append(f"{context}{field_name} must be of type {rules['type']}")
                return
        
        # Check length constraints
        if 'max_length' in rules and len(str(value)) > rules['max_length']:
            self.errors.append(f"{context}{field_name} exceeds maximum length of {rules['max_length']}")
        
        if 'min_length' in rules and len(str(value)) < rules['min_length']:
            self.errors.append(f"{context}{field_name} is shorter than minimum length of {rules['min_length']}")
        
        # Check value constraints
        if 'min_value' in rules and float(value) < rules['min_value']:
            self.errors.append(f"{context}{field_name} is below minimum value of {rules['min_value']}")
        
        if 'max_value' in rules and float(value) > rules['max_value']:
            self.errors.append(f"{context}{field_name} exceeds maximum value of {rules['max_value']}")
        
        # Check format patterns
        if 'pattern' in rules and not re.match(rules['pattern'], str(value)):
            self.errors.append(f"{context}{field_name} does not match required format")
        
        # Check allowed values
        if 'allowed_values' in rules and value not in rules['allowed_values']:
            self.errors.append(f"{context}{field_name} must be one of: {rules['allowed_values']}")
        
        # Custom validation function
        if 'custom_validator' in rules:
            custom_result = rules['custom_validator'](value)
            if not custom_result['valid']:
                self.errors.append(f"{context}{field_name}: {custom_result['message']}")
    
    def validate_type(self, value, expected_type):
        """Validate data type"""
        type_validators = {
            'string': lambda x: isinstance(x, str),
            'integer': lambda x: isinstance(x, int),
            'float': lambda x: isinstance(x, (int, float)),
            'boolean': lambda x: isinstance(x, bool),
            'email': lambda x: self.validate_email(x),
            'date': lambda x: self.validate_date(x),
            'currency': lambda x: self.validate_currency(x)
        }
        
        validator = type_validators.get(expected_type)
        if validator:
            return validator(value)
        
        return True  # Unknown type, skip validation
    
    def validate_email(self, email):
        """Validate email format"""
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return isinstance(email, str) and re.match(pattern, email) is not None
    
    def validate_date(self, date_value):
        """Validate date format"""
        if isinstance(date_value, str):
            try:
                datetime.strptime(date_value, '%Y-%m-%d')
                return True
            except ValueError:
                return False
        return isinstance(date_value, datetime)
    
    def validate_currency(self, amount):
        """Validate currency amount"""
        try:
            decimal_amount = Decimal(str(amount))
            return decimal_amount >= 0
        except (InvalidOperation, ValueError):
            return False

# Example validation rules
customer_validation_rules = {
    'customer_name': {
        'required': True,
        'type': 'string',
        'max_length': 100,
        'min_length': 2
    },
    'email': {
        'required': True,
        'type': 'email'
    },
    'phone': {
        'required': False,
        'type': 'string',
        'pattern': r'^\+?[\d\s\-\(\)]+$'
    },
    'credit_limit': {
        'required': False,
        'type': 'currency',
        'min_value': 0,
        'max_value': 1000000
    },
    'customer_group': {
        'required': True,
        'type': 'string',
        'custom_validator': lambda x: {
            'valid': frappe.db.exists('Customer Group', x),
            'message': 'Customer group does not exist'
        }
    }
}

# Usage in integration endpoint
@frappe.whitelist(allow_guest=True)
def create_customer_via_api():
    """API endpoint with comprehensive validation"""
    try:
        # Get request data
        data = frappe.request.get_json()
        
        # Validate input data
        validator = IntegrationValidator(customer_validation_rules)
        is_valid, errors = validator.validate_data(data, "Customer: ")
        
        if not is_valid:
            return {
                'status': 'error',
                'message': 'Validation failed',
                'errors': errors
            }
        
        # Sanitize data
        sanitized_data = sanitize_customer_data(data)
        
        # Create customer
        customer_doc = frappe.get_doc({
            'doctype': 'Customer',
            **sanitized_data
        })
        customer_doc.insert()
        
        return {
            'status': 'success',
            'customer_id': customer_doc.name,
            'message': 'Customer created successfully'
        }
        
    except Exception as e:
        frappe.log_error(f"Customer creation error: {str(e)}")
        return {
            'status': 'error',
            'message': 'Internal server error'
        }

def sanitize_customer_data(data):
    """Sanitize customer data before processing"""
    sanitized = {}
    
    # String fields - strip whitespace and escape
    string_fields = ['customer_name', 'email', 'phone']
    for field in string_fields:
        if field in data:
            sanitized[field] = frappe.utils.escape_html(str(data[field]).strip())
    
    # Numeric fields - ensure proper type
    numeric_fields = ['credit_limit']
    for field in numeric_fields:
        if field in data:
            try:
                sanitized[field] = float(data[field])
            except (ValueError, TypeError):
                sanitized[field] = 0.0
    
    return sanitized
```

## 4. Error Handling and Recovery Patterns

### 4.1 Retry Mechanisms

#### Exponential Backoff Pattern
```python
# Robust retry mechanism with exponential backoff
import frappe
import time
import random
from functools import wraps
from datetime import datetime, timedelta

class RetryManager:
    def __init__(self, max_attempts=3, base_delay=1, max_delay=60, backoff_factor=2):
        self.max_attempts = max_attempts
        self.base_delay = base_delay
        self.max_delay = max_delay
        self.backoff_factor = backoff_factor
    
    def retry_with_backoff(self, operation, *args, **kwargs):
        """Execute operation with exponential backoff retry"""
        last_exception = None
        
        for attempt in range(self.max_attempts):
            try:
                return operation(*args, **kwargs)
                
            except Exception as e:
                last_exception = e
                
                # Log the attempt
                frappe.logger().info(
                    f"Attempt {attempt + 1} failed for operation {operation.__name__}: {str(e)}"
                )
                
                # Don't retry on final attempt
                if attempt == self.max_attempts - 1:
                    break
                
                # Calculate delay with jitter
                delay = min(
                    self.base_delay * (self.backoff_factor ** attempt),
                    self.max_delay
                )
                jitter = random.uniform(0.1, 0.9) * delay
                total_delay = delay + jitter
                
                frappe.logger().info(f"Retrying in {total_delay:.2f} seconds...")
                time.sleep(total_delay)
        
        # All attempts failed
        raise last_exception
    
    def should_retry(self, exception):
        """Determine if exception warrants a retry"""
        # Define retryable exceptions
        retryable_exceptions = (
            requests.exceptions.ConnectionError,
            requests.exceptions.Timeout,
            requests.exceptions.HTTPError
        )
        
        # Don't retry client errors (4xx), but retry server errors (5xx)
        if hasattr(exception, 'response'):
            status_code = getattr(exception.response, 'status_code', None)
            if status_code:
                return status_code >= 500  # Only retry server errors
        
        return isinstance(exception, retryable_exceptions)

# Decorator for automatic retry
def retry_on_failure(max_attempts=3, base_delay=1, exceptions=None):
    """Decorator to add retry logic to functions"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            retry_manager = RetryManager(max_attempts, base_delay)
            
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                    
                except Exception as e:
                    # Check if we should retry this exception
                    if exceptions and not isinstance(e, exceptions):
                        raise e
                    
                    if attempt == max_attempts - 1:
                        raise e
                    
                    # Calculate delay
                    delay = base_delay * (2 ** attempt)
                    time.sleep(delay)
                    
        return wrapper
    return decorator

# Usage example
@retry_on_failure(max_attempts=3, exceptions=(requests.exceptions.RequestException,))
def sync_customer_to_external_system(customer_data):
    """Sync customer data to external system with retry"""
    response = requests.post(
        "https://external-system.com/api/customers",
        json=customer_data,
        timeout=30
    )
    response.raise_for_status()
    return response.json()
```

#### Circuit Breaker Pattern
```python
# Circuit breaker implementation for external service calls
import frappe
from datetime import datetime, timedelta
from enum import Enum
import threading

class CircuitState(Enum):
    CLOSED = "closed"      # Normal operation
    OPEN = "open"          # Circuit is open, requests fail fast
    HALF_OPEN = "half_open" # Testing if service is back

class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60, expected_exception=Exception):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.expected_exception = expected_exception
        
        self.failure_count = 0
        self.last_failure_time = None
        self.state = CircuitState.CLOSED
        self._lock = threading.Lock()
    
    def call(self, func, *args, **kwargs):
        """Execute function through circuit breaker"""
        with self._lock:
            if self.state == CircuitState.OPEN:
                if self._should_attempt_reset():
                    self.state = CircuitState.HALF_OPEN
                    frappe.logger().info("Circuit breaker entering HALF_OPEN state")
                else:
                    raise Exception("Circuit breaker is OPEN")
            
            try:
                result = func(*args, **kwargs)
                self._on_success()
                return result
                
            except self.expected_exception as e:
                self._on_failure()
                raise e
    
    def _should_attempt_reset(self):
        """Check if enough time has passed to try resetting"""
        return (datetime.now() - self.last_failure_time).seconds >= self.timeout
    
    def _on_success(self):
        """Handle successful call"""
        if self.state == CircuitState.HALF_OPEN:
            frappe.logger().info("Circuit breaker reset to CLOSED state")
            
        self.failure_count = 0
        self.state = CircuitState.CLOSED
    
    def _on_failure(self):
        """Handle failed call"""
        self.failure_count += 1
        self.last_failure_time = datetime.now()
        
        if self.failure_count >= self.failure_threshold:
            self.state = CircuitState.OPEN
            frappe.logger().warning(
                f"Circuit breaker opened after {self.failure_count} failures"
            )

# Global circuit breakers for different services
circuit_breakers = {}

def get_circuit_breaker(service_name, config=None):
    """Get or create circuit breaker for service"""
    if service_name not in circuit_breakers:
        config = config or {}
        circuit_breakers[service_name] = CircuitBreaker(
            failure_threshold=config.get('failure_threshold', 5),
            timeout=config.get('timeout', 60),
            expected_exception=config.get('expected_exception', Exception)
        )
    
    return circuit_breakers[service_name]

# Usage in integration service
class ExternalSystemClient:
    def __init__(self, service_config):
        self.base_url = service_config['base_url']
        self.circuit_breaker = get_circuit_breaker(
            service_config['service_name'],
            service_config.get('circuit_breaker', {})
        )
    
    def make_request(self, endpoint, method='GET', data=None):
        """Make request through circuit breaker"""
        try:
            return self.circuit_breaker.call(
                self._perform_request,
                endpoint,
                method,
                data
            )
        except Exception as e:
            # Log circuit breaker failures
            frappe.logger().error(f"Circuit breaker blocked request to {endpoint}: {str(e)}")
            
            # Return fallback response or raise
            return self._get_fallback_response(endpoint, method)
    
    def _perform_request(self, endpoint, method, data):
        """Actual HTTP request implementation"""
        url = f"{self.base_url}/{endpoint}"
        response = requests.request(method, url, json=data, timeout=30)
        
        # Consider HTTP 5xx as failures for circuit breaker
        if response.status_code >= 500:
            raise requests.exceptions.HTTPError(f"Server error: {response.status_code}")
        
        response.raise_for_status()
        return response.json()
    
    def _get_fallback_response(self, endpoint, method):
        """Provide fallback response when circuit is open"""
        # Return cached data or default response
        return {
            'status': 'fallback',
            'message': 'Service temporarily unavailable',
            'data': self._get_cached_data(endpoint) or {}
        }
```

### 4.2 Dead Letter Queue Pattern

#### Failed Message Handling
```python
# Dead letter queue implementation for failed integrations
import frappe
import json
from datetime import datetime, timedelta

class DeadLetterQueueManager:
    def __init__(self):
        self.dlq_doctype = "Integration Dead Letter Queue"
        self.max_retry_attempts = 3
        self.retry_delay_minutes = [5, 15, 60]  # Progressive delay
    
    def send_to_dlq(self, failed_message, error_info, source_system):
        """Send failed message to dead letter queue"""
        dlq_entry = frappe.get_doc({
            'doctype': self.dlq_doctype,
            'source_system': source_system,
            'message_type': failed_message.get('type', 'unknown'),
            'original_message': json.dumps(failed_message),
            'error_message': str(error_info),
            'error_timestamp': datetime.now(),
            'retry_count': 0,
            'status': 'Failed',
            'next_retry_at': datetime.now() + timedelta(minutes=self.retry_delay_minutes[0])
        })
        dlq_entry.insert()
        
        frappe.logger().error(
            f"Message sent to DLQ: {failed_message.get('type')} - {str(error_info)}"
        )
        
        return dlq_entry.name
    
    def process_dlq_retries(self):
        """Process messages in DLQ that are ready for retry"""
        # Get messages ready for retry
        ready_messages = frappe.get_all(
            self.dlq_doctype,
            filters={
                'status': 'Failed',
                'retry_count': ['<', self.max_retry_attempts],
                'next_retry_at': ['<=', datetime.now()]
            },
            fields=['name', 'original_message', 'retry_count', 'source_system', 'message_type']
        )
        
        for message_info in ready_messages:
            self.retry_dlq_message(message_info)
    
    def retry_dlq_message(self, message_info):
        """Retry processing a message from DLQ"""
        try:
            # Get full DLQ entry
            dlq_doc = frappe.get_doc(self.dlq_doctype, message_info['name'])
            
            # Parse original message
            original_message = json.loads(dlq_doc.original_message)
            
            # Attempt to process message again
            processor = self.get_message_processor(dlq_doc.message_type)
            result = processor.process(original_message['data'])
            
            # Success - remove from DLQ
            dlq_doc.status = 'Processed'
            dlq_doc.processed_at = datetime.now()
            dlq_doc.processing_result = json.dumps(result)
            dlq_doc.save()
            
            frappe.logger().info(f"DLQ message {dlq_doc.name} processed successfully")
            
        except Exception as e:
            # Update retry count and schedule next retry
            dlq_doc.retry_count += 1
            dlq_doc.last_retry_at = datetime.now()
            dlq_doc.last_error_message = str(e)
            
            if dlq_doc.retry_count >= self.max_retry_attempts:
                # Max retries reached - mark as permanently failed
                dlq_doc.status = 'Permanently Failed'
                dlq_doc.final_failure_at = datetime.now()
                
                # Notify administrators
                self.notify_permanent_failure(dlq_doc)
            else:
                # Schedule next retry with progressive delay
                delay_minutes = self.retry_delay_minutes[dlq_doc.retry_count - 1]
                dlq_doc.next_retry_at = datetime.now() + timedelta(minutes=delay_minutes)
            
            dlq_doc.save()
            
            frappe.logger().warning(
                f"DLQ retry failed for {dlq_doc.name}: {str(e)}. "
                f"Retry {dlq_doc.retry_count}/{self.max_retry_attempts}"
            )
    
    def notify_permanent_failure(self, dlq_doc):
        """Notify administrators of permanent message failure"""
        subject = f"Integration Message Permanently Failed: {dlq_doc.message_type}"
        
        message = f"""
        A message in the dead letter queue has permanently failed after {self.max_retry_attempts} retry attempts.
        
        Details:
        - Message Type: {dlq_doc.message_type}
        - Source System: {dlq_doc.source_system}
        - Original Error: {dlq_doc.error_message}
        - Last Error: {dlq_doc.last_error_message}
        - Failed At: {dlq_doc.final_failure_at}
        
        Please investigate and take appropriate action.
        
        Original Message:
        {dlq_doc.original_message}
        """
        
        # Send email to integration team
        frappe.sendmail(
            recipients=frappe.get_all('User', filters={'role': 'Integration Administrator'}, pluck='email'),
            subject=subject,
            message=message
        )
    
    def get_dlq_statistics(self, days=7):
        """Get DLQ statistics for monitoring"""
        from_date = datetime.now() - timedelta(days=days)
        
        stats = {
            'total_messages': frappe.db.count(self.dlq_doctype, {'error_timestamp': ['>=', from_date]}),
            'processed_successfully': frappe.db.count(self.dlq_doctype, {
                'status': 'Processed',
                'error_timestamp': ['>=', from_date]
            }),
            'permanently_failed': frappe.db.count(self.dlq_doctype, {
                'status': 'Permanently Failed',
                'error_timestamp': ['>=', from_date]
            }),
            'pending_retry': frappe.db.count(self.dlq_doctype, {
                'status': 'Failed',
                'retry_count': ['<', self.max_retry_attempts]
            })
        }
        
        # Calculate success rate
        if stats['total_messages'] > 0:
            stats['success_rate'] = (stats['processed_successfully'] / stats['total_messages']) * 100
        else:
            stats['success_rate'] = 100
        
        return stats

# Scheduled job to process DLQ
def process_dead_letter_queue():
    """Scheduled job to process DLQ retries"""
    dlq_manager = DeadLetterQueueManager()
    dlq_manager.process_dlq_retries()

# Add to hooks.py for scheduled execution
scheduler_events = {
    "cron": {
        "0/15 * * * *": [  # Every 15 minutes
            "custom_app.integrations.dlq.process_dead_letter_queue"
        ]
    }
}
```

## 5. Monitoring and Observability

### 5.1 Integration Health Monitoring

#### Health Check Framework
```python
# Comprehensive health monitoring for integrations
import frappe
import requests
import time
from datetime import datetime, timedelta

class IntegrationHealthMonitor:
    def __init__(self):
        self.health_check_timeout = 30
        self.response_time_threshold = 5000  # milliseconds
        
    def check_all_integrations(self):
        """Check health of all configured integrations"""
        integration_systems = frappe.get_all(
            "Integration System",
            filters={"is_active": 1},
            fields=["name", "system_type", "health_check_url", "api_endpoint"]
        )
        
        health_results = {}
        
        for system in integration_systems:
            health_results[system['name']] = self.check_system_health(system)
        
        # Store overall health status
        self.store_health_status(health_results)
        
        return health_results
    
    def check_system_health(self, system_config):
        """Check health of individual integration system"""
        start_time = time.time()
        
        health_result = {
            'system_name': system_config['name'],
            'system_type': system_config['system_type'],
            'timestamp': datetime.now(),
            'status': 'unknown',
            'response_time': 0,
            'error_message': None,
            'details': {}
        }
        
        try:
            # Perform health check based on system type
            if system_config.get('health_check_url'):
                # HTTP health check
                health_result.update(self.http_health_check(system_config))
            elif system_config['system_type'] == 'database':
                # Database health check
                health_result.update(self.database_health_check(system_config))
            elif system_config['system_type'] == 'file_system':
                # File system health check
                health_result.update(self.file_system_health_check(system_config))
            else:
                # Generic API health check
                health_result.update(self.api_health_check(system_config))
            
            # Calculate response time
            health_result['response_time'] = int((time.time() - start_time) * 1000)
            
            # Determine overall status
            if health_result['response_time'] > self.response_time_threshold:
                health_result['status'] = 'degraded'
                health_result['error_message'] = f"Response time {health_result['response_time']}ms exceeds threshold"
            elif health_result.get('status') != 'error':
                health_result['status'] = 'healthy'
                
        except Exception as e:
            health_result['status'] = 'error'
            health_result['error_message'] = str(e)
            health_result['response_time'] = int((time.time() - start_time) * 1000)
        
        # Log health check result
        self.log_health_check(health_result)
        
        return health_result
    
    def http_health_check(self, system_config):
        """Perform HTTP-based health check"""
        response = requests.get(
            system_config['health_check_url'],
            timeout=self.health_check_timeout,
            headers={'User-Agent': 'ERPNext-Health-Monitor'}
        )
        
        result = {'status': 'healthy' if response.status_code == 200 else 'error'}
        
        if response.status_code != 200:
            result['error_message'] = f"HTTP {response.status_code}: {response.text}"
        
        # Try to parse JSON response for additional details
        try:
            response_data = response.json()
            result['details'] = response_data
        except:
            pass
        
        return result
    
    def api_health_check(self, system_config):
        """Perform API health check by calling a simple endpoint"""
        # Try to call a simple API endpoint
        test_endpoint = f"{system_config['api_endpoint'].rstrip('/')}/health"
        
        response = requests.get(
            test_endpoint,
            timeout=self.health_check_timeout,
            headers=self.get_auth_headers(system_config['name'])
        )
        
        return {
            'status': 'healthy' if response.status_code in [200, 404] else 'error',
            'details': {
                'status_code': response.status_code,
                'endpoint_tested': test_endpoint
            }
        }
    
    def database_health_check(self, system_config):
        """Perform database connectivity health check"""
        # Implementation depends on database type
        # This is a placeholder for database-specific health checks
        return {
            'status': 'healthy',
            'details': {'connection': 'established'}
        }
    
    def store_health_status(self, health_results):
        """Store health check results for historical tracking"""
        for system_name, result in health_results.items():
            health_log = frappe.get_doc({
                'doctype': 'Integration Health Log',
                'system_name': system_name,
                'check_timestamp': result['timestamp'],
                'status': result['status'],
                'response_time': result['response_time'],
                'error_message': result.get('error_message'),
                'details': frappe.as_json(result.get('details', {}))
            })
            health_log.insert()
        
        # Update current status in Integration System
        for system_name, result in health_results.items():
            frappe.db.set_value('Integration System', system_name, {
                'current_status': result['status'],
                'last_health_check': result['timestamp'],
                'last_response_time': result['response_time']
            })
    
    def check_integration_trends(self, system_name, hours=24):
        """Analyze health trends for a system"""
        from_time = datetime.now() - timedelta(hours=hours)
        
        health_logs = frappe.get_all(
            'Integration Health Log',
            filters={
                'system_name': system_name,
                'check_timestamp': ['>=', from_time]
            },
            fields=['status', 'response_time', 'check_timestamp'],
            order_by='check_timestamp asc'
        )
        
        if not health_logs:
            return {'status': 'no_data', 'message': 'No health data available'}
        
        # Calculate metrics
        total_checks = len(health_logs)
        healthy_checks = len([log for log in health_logs if log['status'] == 'healthy'])
        avg_response_time = sum(log['response_time'] for log in health_logs) / total_checks
        
        # Determine trend
        recent_checks = health_logs[-10:]  # Last 10 checks
        recent_healthy = len([log for log in recent_checks if log['status'] == 'healthy'])
        
        return {
            'availability_percentage': (healthy_checks / total_checks) * 100,
            'average_response_time': avg_response_time,
            'recent_availability': (recent_healthy / len(recent_checks)) * 100,
            'total_checks': total_checks,
            'trend': 'improving' if recent_healthy > healthy_checks * 0.8 else 'stable' if recent_healthy >= healthy_checks * 0.6 else 'degrading'
        }

# Alerting system for health issues
class IntegrationAlerting:
    def __init__(self):
        self.alert_thresholds = {
            'availability': 95,  # Alert if availability < 95%
            'response_time': 5000,  # Alert if avg response time > 5s
            'consecutive_failures': 3  # Alert after 3 consecutive failures
        }
    
    def check_and_send_alerts(self):
        """Check for alert conditions and send notifications"""
        systems = frappe.get_all("Integration System", filters={"is_active": 1})
        
        for system in systems:
            self.check_system_alerts(system['name'])
    
    def check_system_alerts(self, system_name):
        """Check alert conditions for specific system"""
        monitor = IntegrationHealthMonitor()
        trends = monitor.check_integration_trends(system_name, hours=1)  # Last hour
        
        alerts_to_send = []
        
        # Check availability threshold
        if trends.get('availability_percentage', 100) < self.alert_thresholds['availability']:
            alerts_to_send.append({
                'type': 'availability',
                'message': f"System availability is {trends['availability_percentage']:.1f}%"
            })
        
        # Check response time threshold
        if trends.get('average_response_time', 0) > self.alert_thresholds['response_time']:
            alerts_to_send.append({
                'type': 'performance',
                'message': f"Average response time is {trends['average_response_time']:.0f}ms"
            })
        
        # Check for consecutive failures
        consecutive_failures = self.count_consecutive_failures(system_name)
        if consecutive_failures >= self.alert_thresholds['consecutive_failures']:
            alerts_to_send.append({
                'type': 'consecutive_failures',
                'message': f"{consecutive_failures} consecutive health check failures"
            })
        
        # Send alerts
        for alert in alerts_to_send:
            self.send_alert(system_name, alert)
    
    def count_consecutive_failures(self, system_name):
        """Count consecutive health check failures"""
        recent_logs = frappe.get_all(
            'Integration Health Log',
            filters={'system_name': system_name},
            fields=['status'],
            order_by='check_timestamp desc',
            limit=10
        )
        
        consecutive_count = 0
        for log in recent_logs:
            if log['status'] != 'healthy':
                consecutive_count += 1
            else:
                break
        
        return consecutive_count
    
    def send_alert(self, system_name, alert_info):
        """Send alert notification"""
        subject = f"Integration Alert: {system_name} - {alert_info['type']}"
        message = f"""
        Integration system '{system_name}' has triggered an alert:
        
        Alert Type: {alert_info['type']}
        Message: {alert_info['message']}
        Timestamp: {datetime.now()}
        
        Please investigate and take appropriate action.
        """
        
        # Get alert recipients
        recipients = frappe.get_all(
            'User',
            filters={'role': 'Integration Administrator'},
            pluck='email'
        )
        
        if recipients:
            frappe.sendmail(
                recipients=recipients,
                subject=subject,
                message=message,
                delayed=False
            )
        
        # Log the alert
        frappe.get_doc({
            'doctype': 'Integration Alert',
            'system_name': system_name,
            'alert_type': alert_info['type'],
            'message': alert_info['message'],
            'sent_at': datetime.now(),
            'recipients': ', '.join(recipients)
        }).insert()

# Scheduled jobs for monitoring
def run_integration_health_checks():
    """Scheduled job for health checks"""
    monitor = IntegrationHealthMonitor()
    results = monitor.check_all_integrations()
    
    # Check for alerts
    alerting = IntegrationAlerting()
    alerting.check_and_send_alerts()
    
    return results

# Dashboard data provider
@frappe.whitelist()
def get_integration_dashboard_data():
    """Get data for integration monitoring dashboard"""
    monitor = IntegrationHealthMonitor()
    
    # Get current status of all systems
    systems = frappe.get_all(
        "Integration System",
        filters={"is_active": 1},
        fields=["name", "system_type", "current_status", "last_health_check", "last_response_time"]
    )
    
    # Get trend data for each system
    dashboard_data = {
        'systems': [],
        'overall_health': 'healthy',
        'total_systems': len(systems),
        'healthy_systems': 0,
        'degraded_systems': 0,
        'error_systems': 0
    }
    
    for system in systems:
        trends = monitor.check_integration_trends(system['name'], hours=24)
        
        system_data = {
            'name': system['name'],
            'type': system['system_type'],
            'status': system['current_status'],
            'last_check': system['last_health_check'],
            'response_time': system['last_response_time'],
            'availability_24h': trends.get('availability_percentage', 100),
            'trend': trends.get('trend', 'stable')
        }
        
        dashboard_data['systems'].append(system_data)
        
        # Count by status
        if system['current_status'] == 'healthy':
            dashboard_data['healthy_systems'] += 1
        elif system['current_status'] == 'degraded':
            dashboard_data['degraded_systems'] += 1
        else:
            dashboard_data['error_systems'] += 1
    
    # Determine overall health
    if dashboard_data['error_systems'] > 0:
        dashboard_data['overall_health'] = 'error'
    elif dashboard_data['degraded_systems'] > 0:
        dashboard_data['overall_health'] = 'degraded'
    
    return dashboard_data
```

## 6. Performance Optimization Patterns

### 6.1 Caching Strategies

#### Multi-Layer Caching Pattern
```python
# Comprehensive caching strategy for integrations
import frappe
import json
import hashlib
from datetime import datetime, timedelta

class IntegrationCacheManager:
    def __init__(self):
        self.default_ttl = 3600  # 1 hour default TTL
        self.cache_prefix = "integration_cache"
        
    def get_cache_key(self, service_name, operation, parameters=None):
        """Generate consistent cache key"""
        key_parts = [self.cache_prefix, service_name, operation]
        
        if parameters:
            # Create hash of parameters for consistent key
            param_str = json.dumps(parameters, sort_keys=True)
            param_hash = hashlib.md5(param_str.encode()).hexdigest()
            key_parts.append(param_hash)
        
        return ":".join(key_parts)
    
    def get_cached_data(self, service_name, operation, parameters=None):
        """Get data from cache with fallback layers"""
        cache_key = self.get_cache_key(service_name, operation, parameters)
        
        # Layer 1: Redis cache (fastest)
        cached_data = frappe.cache().get_value(cache_key)
        if cached_data:
            return json.loads(cached_data)
        
        # Layer 2: Database cache (slower but persistent)
        db_cached = frappe.db.get_value(
            "Integration Cache",
            {"cache_key": cache_key, "expires_at": [">", datetime.now()]},
            ["cached_data", "created_at"],
            as_dict=True
        )
        
        if db_cached:
            # Restore to Redis cache
            redis_ttl = self.calculate_remaining_ttl(db_cached['created_at'])
            if redis_ttl > 0:
                frappe.cache().set_value(cache_key, db_cached['cached_data'], expires_in_sec=redis_ttl)
            
            return json.loads(db_cached['cached_data'])
        
        return None
    
    def set_cached_data(self, service_name, operation, data, ttl=None, parameters=None):
        """Set data in cache with multiple layers"""
        if ttl is None:
            ttl = self.default_ttl
            
        cache_key = self.get_cache_key(service_name, operation, parameters)
        data_json = json.dumps(data, default=str)
        
        # Layer 1: Redis cache
        frappe.cache().set_value(cache_key, data_json, expires_in_sec=ttl)
        
        # Layer 2: Database cache (for persistence across Redis restarts)
        try:
            # Remove old cache entry
            frappe.db.delete("Integration Cache", {"cache_key": cache_key})
            
            # Create new cache entry
            cache_doc = frappe.get_doc({
                "doctype": "Integration Cache",
                "cache_key": cache_key,
                "service_name": service_name,
                "operation": operation,
                "cached_data": data_json,
                "expires_at": datetime.now() + timedelta(seconds=ttl),
                "created_at": datetime.now()
            })
            cache_doc.insert(ignore_permissions=True)
            
        except Exception as e:
            frappe.logger().warning(f"Failed to store cache in database: {str(e)}")
    
    def invalidate_cache(self, service_name, operation=None, parameters=None):
        """Invalidate cache entries"""
        if operation:
            # Invalidate specific operation
            cache_key = self.get_cache_key(service_name, operation, parameters)
            frappe.cache().delete_value(cache_key)
            frappe.db.delete("Integration Cache", {"cache_key": cache_key})
        else:
            # Invalidate all cache for service
            pattern = f"{self.cache_prefix}:{service_name}:*"
            
            # Clear Redis cache
            cache_keys = frappe.cache().get_keys(pattern)
            for key in cache_keys:
                frappe.cache().delete_value(key)
            
            # Clear database cache
            frappe.db.delete("Integration Cache", {"service_name": service_name})
    
    def calculate_remaining_ttl(self, created_at, original_ttl=None):
        """Calculate remaining TTL for cache entry"""
        if original_ttl is None:
            original_ttl = self.default_ttl
            
        elapsed = (datetime.now() - created_at).total_seconds()
        remaining = max(0, original_ttl - elapsed)
        
        return int(remaining)
    
    def cleanup_expired_cache(self):
        """Remove expired cache entries from database"""
        frappe.db.delete("Integration Cache", {"expires_at": ["<", datetime.now()]})

# Cache decorator for integration methods
def cache_integration_result(service_name, operation=None, ttl=3600, cache_key_params=None):
    """Decorator to cache integration method results"""
    def decorator(func):
        def wrapper(*args, **kwargs):
            cache_manager = IntegrationCacheManager()
            
            # Determine operation name
            op_name = operation or func.__name__
            
            # Extract cache key parameters
            if cache_key_params:
                if callable(cache_key_params):
                    params = cache_key_params(*args, **kwargs)
                else:
                    params = {key: kwargs.get(key) for key in cache_key_params if key in kwargs}
            else:
                params = None
            
            # Try to get from cache
            cached_result = cache_manager.get_cached_data(service_name, op_name, params)
            if cached_result is not None:
                frappe.logger().debug(f"Cache hit for {service_name}:{op_name}")
                return cached_result
            
            # Execute function and cache result
            frappe.logger().debug(f"Cache miss for {service_name}:{op_name}")
            result = func(*args, **kwargs)
            
            # Cache the result
            cache_manager.set_cached_data(service_name, op_name, result, ttl, params)
            
            return result
        return wrapper
    return decorator

# Usage example
class CustomerSyncService:
    def __init__(self):
        self.service_name = "customer_sync"
    
    @cache_integration_result(
        service_name="customer_sync",
        operation="get_customer_details",
        ttl=1800,  # 30 minutes
        cache_key_params=['customer_id']
    )
    def get_customer_details(self, customer_id):
        """Get customer details with caching"""
        # Expensive operation - API call to external system
        response = requests.get(f"https://external-api.com/customers/{customer_id}")
        return response.json()
    
    @cache_integration_result(
        service_name="customer_sync",
        operation="get_customer_orders",
        ttl=900,  # 15 minutes
        cache_key_params=lambda customer_id, status=None: {'customer_id': customer_id, 'status': status}
    )
    def get_customer_orders(self, customer_id, status=None):
        """Get customer orders with caching"""
        params = {'customer_id': customer_id}
        if status:
            params['status'] = status
            
        response = requests.get("https://external-api.com/orders", params=params)
        return response.json()
```

### 6.2 Bulk Processing Optimization

#### Batch Processing with Parallel Execution
```python
# Optimized batch processing for large data volumes
import frappe
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading
from queue import Queue
import time

class OptimizedBatchProcessor:
    def __init__(self, batch_size=100, max_workers=4, transaction_batch_size=50):
        self.batch_size = batch_size
        self.max_workers = max_workers
        self.transaction_batch_size = transaction_batch_size
        self.results_queue = Queue()
        self.error_queue = Queue()
        self.processed_count = 0
        self.lock = threading.Lock()
        
    def process_large_dataset(self, data, processor_func):
        """Process large dataset with parallel batch processing"""
        start_time = time.time()
        total_records = len(data)
        
        # Split data into batches
        batches = [data[i:i + self.batch_size] for i in range(0, total_records, self.batch_size)]
        
        frappe.logger().info(f"Processing {total_records} records in {len(batches)} batches")
        
        # Process batches in parallel
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            # Submit all batch processing jobs
            future_to_batch = {
                executor.submit(self.process_batch, batch, processor_func, batch_idx): batch_idx
                for batch_idx, batch in enumerate(batches)
            }
            
            # Collect results as they complete
            for future in as_completed(future_to_batch):
                batch_idx = future_to_batch[future]
                try:
                    batch_result = future.result()
                    self.handle_batch_result(batch_result, batch_idx)
                except Exception as e:
                    self.handle_batch_error(e, batch_idx)
        
        # Process any remaining items in queues
        self.finalize_processing()
        
        elapsed_time = time.time() - start_time
        frappe.logger().info(
            f"Processed {self.processed_count}/{total_records} records in {elapsed_time:.2f} seconds"
        )
        
        return {
            'total_records': total_records,
            'processed_records': self.processed_count,
            'elapsed_time': elapsed_time,
            'records_per_second': self.processed_count / elapsed_time if elapsed_time > 0 else 0
        }
    
    def process_batch(self, batch, processor_func, batch_idx):
        """Process a single batch with transaction management"""
        batch_results = []
        batch_errors = []
        
        # Process batch in smaller transaction groups
        for i in range(0, len(batch), self.transaction_batch_size):
            transaction_batch = batch[i:i + self.transaction_batch_size]
            
            try:
                with frappe.db.transaction():
                    for record in transaction_batch:
                        try:
                            result = processor_func(record)
                            batch_results.append(result)
                            
                            with self.lock:
                                self.processed_count += 1
                                
                        except Exception as e:
                            error_info = {
                                'record': record,
                                'error': str(e),
                                'batch_idx': batch_idx
                            }
                            batch_errors.append(error_info)
                            frappe.logger().error(f"Record processing error: {str(e)}")
                    
                    # Commit transaction batch
                    frappe.db.commit()
                    
            except Exception as e:
                # Rollback transaction on batch error
                frappe.db.rollback()
                frappe.logger().error(f"Transaction batch error: {str(e)}")
                
                # Mark all records in transaction batch as errors
                for record in transaction_batch:
                    batch_errors.append({
                        'record': record,
                        'error': f"Transaction batch failed: {str(e)}",
                        'batch_idx': batch_idx
                    })
        
        return {
            'batch_idx': batch_idx,
            'processed_count': len(batch_results),
            'error_count': len(batch_errors),
            'results': batch_results,
            'errors': batch_errors
        }
    
    def handle_batch_result(self, batch_result, batch_idx):
        """Handle completed batch result"""
        frappe.logger().debug(
            f"Batch {batch_idx} completed: {batch_result['processed_count']} processed, "
            f"{batch_result['error_count']} errors"
        )
        
        # Queue errors for later processing
        for error in batch_result['errors']:
            self.error_queue.put(error)
    
    def handle_batch_error(self, error, batch_idx):
        """Handle batch processing error"""
        frappe.logger().error(f"Batch {batch_idx} failed: {str(error)}")
        self.error_queue.put({
            'batch_idx': batch_idx,
            'error': str(error),
            'type': 'batch_failure'
        })
    
    def finalize_processing(self):
        """Finalize processing and handle any remaining errors"""
        # Process errors from queue
        error_count = 0
        while not self.error_queue.empty():
            error = self.error_queue.get()
            self.log_processing_error(error)
            error_count += 1
        
        if error_count > 0:
            frappe.logger().warning(f"Total errors encountered: {error_count}")
    
    def log_processing_error(self, error_info):
        """Log processing error for later analysis"""
        try:
            error_log = frappe.get_doc({
                'doctype': 'Batch Processing Error',
                'batch_idx': error_info.get('batch_idx'),
                'error_type': error_info.get('type', 'record_error'),
                'error_message': error_info['error'],
                'record_data': frappe.as_json(error_info.get('record', {})),
                'timestamp': frappe.utils.now_datetime()
            })
            error_log.insert(ignore_permissions=True)
        except Exception as e:
            frappe.logger().error(f"Failed to log processing error: {str(e)}")

# Memory-efficient data streaming processor
class StreamingDataProcessor:
    def __init__(self, chunk_size=1000):
        self.chunk_size = chunk_size
        
    def process_data_stream(self, data_source, processor_func):
        """Process data in streaming fashion to minimize memory usage"""
        processed_count = 0
        error_count = 0
        
        # Process data in chunks
        chunk = []
        for record in self.get_data_iterator(data_source):
            chunk.append(record)
            
            if len(chunk) >= self.chunk_size:
                results = self.process_chunk(chunk, processor_func)
                processed_count += results['processed']
                error_count += results['errors']
                
                # Clear chunk to free memory
                chunk.clear()
                
                # Optional: Force garbage collection for large datasets
                if processed_count % (self.chunk_size * 10) == 0:
                    import gc
                    gc.collect()
        
        # Process remaining records
        if chunk:
            results = self.process_chunk(chunk, processor_func)
            processed_count += results['processed']
            error_count += results['errors']
        
        return {
            'processed_count': processed_count,
            'error_count': error_count
        }
    
    def get_data_iterator(self, data_source):
        """Get iterator for different data source types"""
        if isinstance(data_source, str):
            # File path - read line by line
            with open(data_source, 'r') as file:
                for line in file:
                    yield line.strip()
        elif hasattr(data_source, '__iter__'):
            # Iterable - yield items
            for item in data_source:
                yield item
        else:
            raise ValueError("Unsupported data source type")
    
    def process_chunk(self, chunk, processor_func):
        """Process a single chunk"""
        processed = 0
        errors = 0
        
        try:
            with frappe.db.transaction():
                for record in chunk:
                    try:
                        processor_func(record)
                        processed += 1
                    except Exception as e:
                        errors += 1
                        frappe.logger().error(f"Record processing error: {str(e)}")
                
                frappe.db.commit()
                
        except Exception as e:
            frappe.db.rollback()
            errors = len(chunk)  # All records failed
            frappe.logger().error(f"Chunk processing failed: {str(e)}")
        
        return {'processed': processed, 'errors': errors}

# Usage example
def bulk_customer_sync():
    """Example of bulk customer synchronization"""
    def process_customer_record(customer_data):
        """Process individual customer record"""
        # Validate customer data
        if not customer_data.get('email'):
            raise ValueError("Customer email is required")
        
        # Check if customer exists
        existing_customer = frappe.db.get_value(
            "Customer",
            {"email_id": customer_data['email']},
            "name"
        )
        
        if existing_customer:
            # Update existing customer
            customer_doc = frappe.get_doc("Customer", existing_customer)
            customer_doc.update(customer_data)
            customer_doc.save()
        else:
            # Create new customer
            customer_doc = frappe.new_doc("Customer")
            customer_doc.update(customer_data)
            customer_doc.insert()
        
        return customer_doc.name
    
    # Get customer data from external source
    customer_data = get_customer_data_from_external_system()
    
    # Process with optimized batch processor
    processor = OptimizedBatchProcessor(
        batch_size=200,
        max_workers=6,
        transaction_batch_size=50
    )
    
    results = processor.process_large_dataset(customer_data, process_customer_record)
    
    frappe.logger().info(f"Bulk sync completed: {results}")
    
    return results
```

This comprehensive integration patterns guide provides the foundation for building robust, scalable, and maintainable integrations with ERPNext. The patterns cover all aspects from basic connectivity to advanced monitoring and performance optimization, ensuring successful integration implementations that can handle real-world enterprise requirements.