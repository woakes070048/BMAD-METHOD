# generate-api-documentation

**Task:** Generate comprehensive REST API documentation for ERPNext applications

**Agent:** documentation-specialist  
**Category:** Documentation  
**Elicit:** true  
**Prerequisites:** Working API endpoints, understanding of authentication methods  

## Overview

This task generates complete REST API documentation including endpoint descriptions, request/response schemas, authentication details, and code examples.

## Input Requirements

**Required:**
- Application name and version
- List of API endpoints to document
- Authentication methods used
- Base URL for the API

**Optional:**
- Existing API code or controllers
- Postman/Insomnia collections
- Error code definitions
- Rate limiting configurations
- Custom headers or parameters

## Process Steps

### Step 1: API Discovery and Analysis
1. **Identify all API endpoints:**
   ```python
   # Scan for whitelisted methods in ERPNext
   import frappe
   import ast
   import os
   
   def find_api_endpoints(app_name):
       endpoints = []
       app_path = frappe.get_app_path(app_name)
       
       for root, dirs, files in os.walk(app_path):
           for file in files:
               if file.endswith('.py'):
                   filepath = os.path.join(root, file)
                   with open(filepath, 'r') as f:
                       try:
                           tree = ast.parse(f.read())
                           for node in ast.walk(tree):
                               if isinstance(node, ast.FunctionDef):
                                   # Check for @frappe.whitelist() decorator
                                   for decorator in node.decorator_list:
                                       if hasattr(decorator, 'id') and decorator.id == 'whitelist':
                                           endpoints.append({
                                               'name': node.name,
                                               'file': filepath,
                                               'docstring': ast.get_docstring(node)
                                           })
                       except:
                           pass
       return endpoints
   ```

2. **Categorize endpoints by functionality:**
   - CRUD operations (Create, Read, Update, Delete)
   - Search and filter endpoints
   - Bulk operations
   - Custom business logic endpoints
   - Authentication endpoints
   - File upload/download endpoints

3. **Extract endpoint metadata:**
   - HTTP methods supported
   - Required parameters
   - Optional parameters
   - Response formats
   - Error codes

### Step 2: Generate OpenAPI Specification
1. **Create OpenAPI structure:**
   ```yaml
   openapi: 3.0.0
   info:
     title: ERPNext Custom App API
     version: 1.0.0
     description: REST API for ERPNext custom application
     contact:
       name: API Support
       email: api@example.com
   
   servers:
     - url: https://your-site.com
       description: Production server
     - url: https://staging.your-site.com
       description: Staging server
   
   security:
     - ApiKeyAuth: []
     - BearerAuth: []
   
   paths:
     /api/resource/Customer:
       get:
         summary: List Customers
         description: Returns a paginated list of customers
         parameters:
           - name: fields
             in: query
             description: Fields to return
             schema:
               type: array
               items:
                 type: string
           - name: filters
             in: query
             description: Filter conditions
             schema:
               type: object
           - name: limit
             in: query
             description: Number of results
             schema:
               type: integer
               default: 20
         responses:
           200:
             description: Successful response
             content:
               application/json:
                 schema:
                   $ref: '#/components/schemas/CustomerList'
   ```

2. **Define schemas for all DocTypes:**
   ```yaml
   components:
     schemas:
       Customer:
         type: object
         required:
           - customer_name
           - customer_type
         properties:
           name:
             type: string
             description: Customer ID
           customer_name:
             type: string
             description: Customer display name
           customer_type:
             type: string
             enum: [Company, Individual]
           customer_group:
             type: string
             description: Customer group classification
   ```

### Step 3: Document Standard ERPNext API Patterns
1. **Document CRUD operations:**
   ```markdown
   ## Standard CRUD Operations
   
   ### Create Document
   **POST** `/api/resource/[DocType]`
   
   Creates a new document of the specified DocType.
   
   **Request:**
   ```json
   {
     "field1": "value1",
     "field2": "value2"
   }
   ```
   
   **Response:**
   ```json
   {
     "data": {
       "name": "DOC-00001",
       "field1": "value1",
       "field2": "value2"
     }
   }
   ```
   
   ### Read Document
   **GET** `/api/resource/[DocType]/[name]`
   
   Retrieves a specific document by name.
   
   ### Update Document
   **PUT** `/api/resource/[DocType]/[name]`
   
   Updates an existing document.
   
   ### Delete Document
   **DELETE** `/api/resource/[DocType]/[name]`
   
   Deletes a document (usually soft delete).
   ```

2. **Document authentication methods:**
   ```markdown
   ## Authentication
   
   ### API Key Authentication
   Generate API keys from User Settings.
   
   **Header:**
   ```
   Authorization: token api_key:api_secret
   ```
   
   ### Session Authentication
   Use session cookies after login.
   
   **Login:**
   ```bash
   curl -X POST https://site.com/api/method/login \
     -d "usr=user@example.com&pwd=password"
   ```
   
   ### OAuth 2.0
   For third-party integrations.
   
   **Authorization URL:**
   ```
   https://site.com/api/method/frappe.integrations.oauth2.authorize
   ```
   ```

### Step 4: Create Code Examples
1. **Generate examples in multiple languages:**
   ```markdown
   ## Code Examples
   
   ### Python
   ```python
   import requests
   
   # API configuration
   api_key = "your_api_key"
   api_secret = "your_api_secret"
   base_url = "https://your-site.com"
   
   # Get customer list
   response = requests.get(
       f"{base_url}/api/resource/Customer",
       headers={"Authorization": f"token {api_key}:{api_secret}"},
       params={"fields": '["name", "customer_name"]', "limit": 10}
   )
   customers = response.json()
   ```
   
   ### JavaScript (Node.js)
   ```javascript
   const axios = require('axios');
   
   const api = axios.create({
     baseURL: 'https://your-site.com',
     headers: {
       'Authorization': 'token api_key:api_secret'
     }
   });
   
   // Get customer list
   async function getCustomers() {
     const response = await api.get('/api/resource/Customer', {
       params: {
         fields: JSON.stringify(['name', 'customer_name']),
         limit: 10
       }
     });
     return response.data;
   }
   ```
   
   ### cURL
   ```bash
   curl -H "Authorization: token api_key:api_secret" \
        "https://your-site.com/api/resource/Customer?limit=10"
   ```
   ```

### Step 5: Document Error Handling
1. **Standard error responses:**
   ```markdown
   ## Error Responses
   
   ### 400 Bad Request
   Invalid input data or parameters.
   
   ```json
   {
     "exc_type": "ValidationError",
     "exception": "Missing required field: customer_name"
   }
   ```
   
   ### 401 Unauthorized
   Authentication failed or missing.
   
   ```json
   {
     "exc_type": "AuthenticationError",
     "exception": "Invalid API credentials"
   }
   ```
   
   ### 403 Forbidden
   User lacks required permissions.
   
   ```json
   {
     "exc_type": "PermissionError",
     "exception": "Insufficient permissions for Customer"
   }
   ```
   
   ### 404 Not Found
   Requested resource doesn't exist.
   
   ```json
   {
     "exc_type": "DoesNotExistError",
     "exception": "Customer CUST-99999 not found"
   }
   ```
   
   ### 500 Internal Server Error
   Server-side error occurred.
   
   ```json
   {
     "exc_type": "ServerError",
     "exception": "An internal error occurred"
   }
   ```
   ```

### Step 6: Generate Testing Collections
1. **Create Postman collection:**
   ```json
   {
     "info": {
       "name": "ERPNext API",
       "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
     },
     "auth": {
       "type": "apikey",
       "apikey": [
         {
           "key": "key",
           "value": "Authorization"
         },
         {
           "key": "value",
           "value": "token {{api_key}}:{{api_secret}}"
         }
       ]
     },
     "item": [
       {
         "name": "Customer",
         "item": [
           {
             "name": "List Customers",
             "request": {
               "method": "GET",
               "url": "{{base_url}}/api/resource/Customer"
             }
           },
           {
             "name": "Create Customer",
             "request": {
               "method": "POST",
               "url": "{{base_url}}/api/resource/Customer",
               "body": {
                 "mode": "raw",
                 "raw": "{\"customer_name\": \"Test Customer\"}"
               }
             }
           }
         ]
       }
     ]
   }
   ```

## Deliverables

### 1. API Documentation (Markdown)
Complete API.md file with:
- API overview and getting started
- Authentication guide
- Endpoint reference
- Request/response examples
- Error handling
- Rate limiting
- Versioning
- Code samples

### 2. OpenAPI Specification
swagger.yaml or openapi.json with:
- Complete endpoint definitions
- Schema definitions
- Security schemes
- Server configurations
- Tags and grouping

### 3. Testing Collections
- Postman collection JSON
- Insomnia workspace export
- Example environment variables
- Test scripts for validation

### 4. Quick Reference Guide
- Common operations cheat sheet
- Authentication quick start
- Error code reference
- API changelog

## Quality Checks

- [ ] All endpoints documented
- [ ] Authentication methods explained
- [ ] Request/response examples provided
- [ ] Error codes documented
- [ ] Code samples tested and working
- [ ] OpenAPI spec validates correctly
- [ ] Postman collection imports successfully
- [ ] Documentation is searchable
- [ ] Version information included
- [ ] Contact information provided

## Success Criteria

1. **Completeness**
   - 100% of public endpoints documented
   - All parameters described
   - All response formats shown
   - Error scenarios covered

2. **Accuracy**
   - Examples work when tested
   - Schemas match actual responses
   - Authentication steps verified
   - Error codes correct

3. **Usability**
   - Easy to navigate
   - Clear examples
   - Consistent formatting
   - Helpful descriptions

4. **Maintainability**
   - Version controlled
   - Update process defined
   - Automated where possible
   - Change tracking enabled

## Next Steps

After generating API documentation:
1. Set up automated documentation generation in CI/CD
2. Create interactive API explorer (Swagger UI)
3. Implement API versioning strategy
4. Set up documentation hosting
5. Create developer portal
6. Gather feedback and iterate