# Frappe Template Rendering Guide
## Complete Guide to Using Frappe's Built-in Template System Instead of External Template Libraries

**CRITICAL**: NEVER use `import jinja2`, `from jinja2 import`, or `import django.template` - Frappe provides comprehensive template functionality built-in!

---

## 🚫 What NOT to Do

```python
# NEVER DO THIS - Anti-patterns
import jinja2                          # ❌ BLOCKED
from jinja2 import Template           # ❌ BLOCKED
import django.template                # ❌ BLOCKED
from django.template import Template  # ❌ BLOCKED

# WRONG WAY
template = jinja2.Template("Hello {{ name }}")
result = template.render(name="World")
```

---

## ✅ The Frappe Way - Complete Template Features

### 1. Basic Template Rendering

```python
import frappe

def render_email_template():
    """Basic template rendering with Frappe"""
    
    # Render template with context
    html_content = frappe.render_template(
        template="templates/emails/welcome.html",
        context={
            "customer_name": "John Doe",
            "company_name": "ACME Corp",
            "login_url": "https://portal.example.com"
        }
    )
    
    return html_content

def render_inline_template():
    """Render inline template string"""
    
    template_string = """
    <h1>Welcome {{ customer.customer_name }}!</h1>
    <p>Your account has been created successfully.</p>
    <p>Company: {{ customer.company }}</p>
    """
    
    customer = frappe.get_doc("Customer", "CUST-001")
    
    rendered = frappe.render_template(
        template=template_string,
        context={"customer": customer}
    )
    
    return rendered
```

### 2. Email Template Management

```python
import frappe

def send_templated_email(customer_name, template_name="welcome"):
    """Send email using Email Template DocType"""
    
    # Get customer data
    customer = frappe.get_doc("Customer", customer_name)
    
    # Get email template
    email_template = frappe.get_doc("Email Template", template_name)
    
    # Render subject and message
    subject = frappe.render_template(
        template=email_template.subject,
        context={"doc": customer}
    )
    
    message = frappe.render_template(
        template=email_template.response,
        context={
            "doc": customer,
            "company": frappe.get_doc("Company", customer.company)
        }
    )
    
    # Send email
    frappe.sendmail(
        recipients=[customer.email_id],
        subject=subject,
        message=message,
        reference_doctype="Customer",
        reference_name=customer.name
    )

def create_email_template():
    """Create email template programmatically"""
    
    template = frappe.get_doc({
        "doctype": "Email Template",
        "name": "customer_welcome",
        "subject": "Welcome to {{ doc.company }}!",
        "response": """
        <div style="font-family: Arial, sans-serif;">
            <h2>Welcome {{ doc.customer_name }}!</h2>
            
            <p>Thank you for choosing {{ company.company_name }}.</p>
            
            <div style="background: #f8f9fa; padding: 15px; margin: 20px 0;">
                <h3>Your Account Details:</h3>
                <ul>
                    <li><strong>Customer ID:</strong> {{ doc.name }}</li>
                    <li><strong>Territory:</strong> {{ doc.territory }}</li>
                    <li><strong>Customer Group:</strong> {{ doc.customer_group }}</li>
                </ul>
            </div>
            
            <p>If you have any questions, please contact us.</p>
            
            <p>Best regards,<br>
            {{ company.company_name }} Team</p>
        </div>
        """,
        "use_html": 1
    })
    
    template.insert()
    return template
```

### 3. Print Format Templates

```python
import frappe

def generate_custom_invoice_html(invoice_name):
    """Generate custom invoice HTML using templates"""
    
    # Get invoice document
    invoice = frappe.get_doc("Sales Invoice", invoice_name)
    
    # Render invoice template
    html = frappe.render_template(
        template="templates/print/custom_invoice.html",
        context={
            "doc": invoice,
            "company": frappe.get_doc("Company", invoice.company),
            "customer": frappe.get_doc("Customer", invoice.customer) if invoice.customer else None,
            "settings": frappe.get_single("Print Settings")
        }
    )
    
    return html

def create_print_format():
    """Create print format with custom template"""
    
    print_format = frappe.get_doc({
        "doctype": "Print Format",
        "name": "Custom Invoice Format",
        "doc_type": "Sales Invoice",
        "format_data": """
        <div class="invoice-container">
            <div class="header">
                <h1>{{ doc.company }}</h1>
                <div class="invoice-details">
                    <p><strong>Invoice:</strong> {{ doc.name }}</p>
                    <p><strong>Date:</strong> {{ frappe.utils.formatdate(doc.posting_date) }}</p>
                </div>
            </div>
            
            <div class="customer-details">
                <h3>Bill To:</h3>
                <p>{{ doc.customer_name }}</p>
                <p>{{ doc.customer_address }}</p>
            </div>
            
            <table class="item-table">
                <thead>
                    <tr>
                        <th>Item</th>
                        <th>Qty</th>
                        <th>Rate</th>
                        <th>Amount</th>
                    </tr>
                </thead>
                <tbody>
                    {% for item in doc.items %}
                    <tr>
                        <td>{{ item.item_name }}</td>
                        <td>{{ item.qty }}</td>
                        <td>{{ frappe.utils.fmt_money(item.rate) }}</td>
                        <td>{{ frappe.utils.fmt_money(item.amount) }}</td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
            
            <div class="totals">
                <p><strong>Total: {{ frappe.utils.fmt_money(doc.grand_total) }}</strong></p>
            </div>
        </div>
        """,
        "custom_format": 1,
        "standard": "No"
    })
    
    print_format.insert()
    return print_format
```

### 4. Web Page Templates

```python
import frappe

def render_portal_page(customer):
    """Render customer portal page"""
    
    # Get customer data
    customer_doc = frappe.get_doc("Customer", customer)
    
    # Get recent orders
    orders = frappe.get_all("Sales Order",
        filters={"customer": customer, "docstatus": 1},
        fields=["name", "transaction_date", "grand_total", "status"],
        order_by="transaction_date desc",
        limit=10
    )
    
    # Render page template
    html = frappe.render_template(
        template="templates/web/customer_portal.html",
        context={
            "customer": customer_doc,
            "orders": orders,
            "total_orders": len(orders),
            "company": frappe.get_doc("Company", customer_doc.company)
        }
    )
    
    return html

def create_web_page_template():
    """Create web page with template"""
    
    web_page = frappe.get_doc({
        "doctype": "Web Page",
        "title": "Customer Portal",
        "route": "portal/customer",
        "content_type": "Rich Text",
        "main_section": """
        <div class="customer-portal">
            {% if customer %}
                <h1>Welcome, {{ customer.customer_name }}!</h1>
                
                <div class="dashboard-stats">
                    <div class="stat-card">
                        <h3>Total Orders</h3>
                        <p class="stat-number">{{ total_orders }}</p>
                    </div>
                    
                    <div class="stat-card">
                        <h3>Account Status</h3>
                        <p class="stat-status">{{ customer.status }}</p>
                    </div>
                </div>
                
                <div class="recent-orders">
                    <h2>Recent Orders</h2>
                    {% if orders %}
                        <table class="order-table">
                            <thead>
                                <tr>
                                    <th>Order</th>
                                    <th>Date</th>
                                    <th>Amount</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                {% for order in orders %}
                                <tr>
                                    <td><a href="/orders/{{ order.name }}">{{ order.name }}</a></td>
                                    <td>{{ frappe.utils.formatdate(order.transaction_date) }}</td>
                                    <td>{{ frappe.utils.fmt_money(order.grand_total) }}</td>
                                    <td><span class="status-{{ order.status.lower() }}">{{ order.status }}</span></td>
                                </tr>
                                {% endfor %}
                            </tbody>
                        </table>
                    {% else %}
                        <p>No orders found.</p>
                    {% endif %}
                </div>
            {% else %}
                <h1>Please log in to view your portal</h1>
            {% endif %}
        </div>
        """,
        "published": 1
    })
    
    web_page.insert()
    return web_page
```

### 5. Report Templates

```python
import frappe

def generate_sales_report_html(filters=None):
    """Generate sales report using templates"""
    
    # Get sales data
    sales_data = frappe.db.sql("""
        SELECT 
            customer,
            customer_name,
            SUM(grand_total) as total_amount,
            COUNT(*) as order_count
        FROM `tabSales Invoice`
        WHERE posting_date BETWEEN %(from_date)s AND %(to_date)s
        AND docstatus = 1
        GROUP BY customer
        ORDER BY total_amount DESC
    """, filters, as_dict=1)
    
    # Calculate totals
    total_amount = sum(row.total_amount for row in sales_data)
    total_orders = sum(row.order_count for row in sales_data)
    
    # Render report template
    html = frappe.render_template(
        template="templates/reports/sales_report.html",
        context={
            "data": sales_data,
            "filters": filters,
            "total_amount": total_amount,
            "total_orders": total_orders,
            "report_date": frappe.utils.now_datetime(),
            "company": frappe.defaults.get_global_default("company")
        }
    )
    
    return html

def create_custom_report_format():
    """Create custom report format"""
    
    report_template = """
    <div class="report-container">
        <div class="report-header">
            <h1>Sales Report - {{ company }}</h1>
            <p>Period: {{ frappe.utils.formatdate(filters.from_date) }} to {{ frappe.utils.formatdate(filters.to_date) }}</p>
            <p>Generated: {{ frappe.utils.format_datetime(report_date) }}</p>
        </div>
        
        <div class="report-summary">
            <div class="summary-card">
                <h3>Total Sales</h3>
                <p class="amount">{{ frappe.utils.fmt_money(total_amount) }}</p>
            </div>
            <div class="summary-card">
                <h3>Total Orders</h3>
                <p class="count">{{ total_orders }}</p>
            </div>
        </div>
        
        <table class="report-table">
            <thead>
                <tr>
                    <th>Customer</th>
                    <th>Customer Name</th>
                    <th>Order Count</th>
                    <th>Total Amount</th>
                </tr>
            </thead>
            <tbody>
                {% for row in data %}
                <tr>
                    <td>{{ row.customer }}</td>
                    <td>{{ row.customer_name }}</td>
                    <td>{{ row.order_count }}</td>
                    <td>{{ frappe.utils.fmt_money(row.total_amount) }}</td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>
    """
    
    return report_template
```

### 6. Template Inheritance and Includes

```python
import frappe

def render_with_base_template():
    """Render template with base template inheritance"""
    
    # Base template: templates/base.html
    base_template = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>{{ title }} - {{ company }}</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
            .header { background: #007bff; color: white; padding: 20px; margin: -20px -20px 20px; }
            .content { max-width: 800px; margin: 0 auto; }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>{{ company }}</h1>
        </div>
        <div class="content">
            {{ content }}
        </div>
    </body>
    </html>
    """
    
    # Page content template
    page_content = """
    <h2>{{ page_title }}</h2>
    <p>{{ page_description }}</p>
    
    {% include "templates/includes/customer_list.html" %}
    """
    
    # Include template: templates/includes/customer_list.html
    customer_list_template = """
    <div class="customer-list">
        <h3>Customers</h3>
        <ul>
            {% for customer in customers %}
            <li>{{ customer.customer_name }} ({{ customer.name }})</li>
            {% endfor %}
        </ul>
    </div>
    """
    
    # Get data
    customers = frappe.get_all("Customer", 
        fields=["name", "customer_name"], 
        limit=10
    )
    
    # Render content first
    content = frappe.render_template(
        template=page_content,
        context={
            "page_title": "Customer Portal",
            "page_description": "Welcome to your customer portal",
            "customers": customers
        }
    )
    
    # Render with base template
    final_html = frappe.render_template(
        template=base_template,
        context={
            "title": "Customer Portal",
            "company": "ACME Corp",
            "content": content
        }
    )
    
    return final_html
```

### 7. Template Filters and Functions

```python
import frappe

def render_with_custom_filters():
    """Use Frappe's built-in template filters"""
    
    template = """
    <div class="document-info">
        <h1>{{ doc.title | title }}</h1>
        
        <p>Created: {{ doc.creation | format_datetime }}</p>
        <p>Amount: {{ doc.grand_total | fmt_money }}</p>
        <p>Status: {{ doc.status | upper }}</p>
        
        <!-- Custom date formatting -->
        <p>Due Date: {{ frappe.utils.formatdate(doc.due_date, "dd-mm-yyyy") }}</p>
        
        <!-- Conditional rendering -->
        {% if doc.grand_total > 10000 %}
            <p class="high-value">High Value Order</p>
        {% endif %}
        
        <!-- Loop with filters -->
        <ul>
            {% for item in doc.items %}
                <li>{{ item.item_name }} - {{ item.amount | fmt_money }}</li>
            {% endfor %}
        </ul>
        
        <!-- Translation -->
        <p>{{ _("Total Amount") }}: {{ doc.grand_total | fmt_money }}</p>
    </div>
    """
    
    # Get document
    doc = frappe.get_doc("Sales Invoice", "SINV-001")
    
    # Render with filters
    html = frappe.render_template(
        template=template,
        context={
            "doc": doc,
            "_": frappe._  # Translation function
        }
    )
    
    return html

def add_custom_template_functions():
    """Add custom functions to template context"""
    
    def get_customer_balance(customer):
        """Custom function to get customer balance"""
        return frappe.db.get_value("Customer", customer, "outstanding_amount") or 0
    
    def format_currency(amount, currency="USD"):
        """Custom currency formatting"""
        return f"{currency} {amount:,.2f}"
    
    template = """
    <div class="customer-summary">
        <h2>{{ customer.customer_name }}</h2>
        <p>Outstanding: {{ format_currency(get_customer_balance(customer.name)) }}</p>
        <p>Territory: {{ customer.territory }}</p>
    </div>
    """
    
    customer = frappe.get_doc("Customer", "CUST-001")
    
    html = frappe.render_template(
        template=template,
        context={
            "customer": customer,
            "get_customer_balance": get_customer_balance,
            "format_currency": format_currency
        }
    )
    
    return html
```

### 8. Template Caching

```python
import frappe

def render_cached_template(template_name, cache_key, context):
    """Render template with caching"""
    
    # Check cache first
    cached_result = frappe.cache().get_value(cache_key)
    if cached_result:
        return cached_result
    
    # Render template
    html = frappe.render_template(
        template=template_name,
        context=context
    )
    
    # Cache for 1 hour
    frappe.cache().set_value(cache_key, html, expires_in_sec=3600)
    
    return html

def clear_template_cache(pattern):
    """Clear template cache by pattern"""
    cache_keys = frappe.cache().get_keys(pattern)
    for key in cache_keys:
        frappe.cache().delete_value(key)

# Usage
def get_product_catalog():
    """Get product catalog with caching"""
    
    products = frappe.get_all("Item",
        fields=["name", "item_name", "description", "standard_rate"],
        filters={"is_sales_item": 1}
    )
    
    html = render_cached_template(
        template_name="templates/catalog/product_list.html",
        cache_key="product_catalog_html",
        context={"products": products}
    )
    
    return html
```

---

## 📋 Template Best Practices

### 1. File Organization

```
your_app/
├── templates/
│   ├── emails/
│   │   ├── welcome.html
│   │   ├── invoice_reminder.html
│   │   └── password_reset.html
│   ├── print/
│   │   ├── invoice.html
│   │   ├── quotation.html
│   │   └── purchase_order.html
│   ├── reports/
│   │   ├── sales_report.html
│   │   └── inventory_report.html
│   ├── web/
│   │   ├── customer_portal.html
│   │   └── product_catalog.html
│   └── includes/
│       ├── header.html
│       ├── footer.html
│       └── navigation.html
```

### 2. Template Security

```python
# ✅ CORRECT - Safe template rendering
safe_html = frappe.render_template(
    template="<p>Hello {{ customer.customer_name | e }}</p>",  # |e escapes HTML
    context={"customer": customer}
)

# ✅ CORRECT - Using safe filters
template = """
<div>
    {{ content | safe }}  <!-- Only use |safe for trusted content -->
    {{ user_input | e }}  <!-- Always escape user input -->
</div>
"""

# ❌ AVOID - Unescaped user input
dangerous_template = """
<div>{{ user_comment }}</div>  <!-- Could be XSS vulnerable -->
"""
```

---

## 📊 Quick Reference

| Need | Don't Use | Use Instead |
|------|-----------|-------------|
| Template rendering | `jinja2.Template()` | `frappe.render_template()` |
| Email templates | Manual string format | Email Template DocType |
| Print formats | Custom HTML generation | Print Format DocType |
| Web pages | Django templates | Web Page DocType |
| Template inheritance | Jinja2 extends | Frappe template system |
| Custom filters | Jinja2 filters | Frappe built-in filters |

---

## ⚠️ Common Mistakes to Avoid

```python
# ❌ WRONG - Using Jinja2 directly
import jinja2
template = jinja2.Template("Hello {{ name }}")
result = template.render(name="World")

# ✅ CORRECT - Using Frappe
result = frappe.render_template("Hello {{ name }}", {"name": "World"})

# ❌ WRONG - Manual email formatting
email_body = f"Hello {customer.name}, your order {order.name} is ready"

# ✅ CORRECT - Using Email Template
frappe.sendmail(
    recipients=[customer.email],
    template="order_ready",
    args={"customer": customer, "order": order}
)

# ❌ WRONG - Hardcoded HTML in Python
html = "<h1>" + doc.title + "</h1><p>" + doc.description + "</p>"

# ✅ CORRECT - Using templates
html = frappe.render_template(
    template="templates/document_view.html",
    context={"doc": doc}
)
```

---

*Remember: Frappe provides a comprehensive template system with inheritance, filters, caching, and security features. There's NO reason to use external template libraries!*