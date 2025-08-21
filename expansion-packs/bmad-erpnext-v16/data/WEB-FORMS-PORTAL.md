# 🚨 WEB FORMS & PORTAL PATTERNS - GUEST USER INTERACTIONS

## CRITICAL: Secure Guest Access = Business Growth

This document contains MANDATORY patterns for creating Web Forms, Portal pages, and guest user interactions in Frappe/ERPNext.

---

## 🔴 UNDERSTANDING FRAPPE'S PORTAL SYSTEM

### Guest User Interaction Types:

| Type | Authentication | Use For | Security Level |
|------|---------------|---------|----------------|
| **Web Forms** | Optional | Lead capture, feedback | Low-Medium |
| **Portal Pages** | Required | Customer self-service | High |
| **Public Pages** | None | Marketing, info | Low |
| **Website Pages** | None | Content management | Low |

### Portal vs Web Form Decision:

- **Web Forms**: Simple data collection (contact, feedback, applications)
- **Portal Pages**: Customer dashboards, order tracking, account management
- **Public Pages**: Marketing content, product showcases
- **Website**: Blog, news, static content

---

## 🔴 WEB FORMS PATTERNS (GUEST DATA COLLECTION)

### Creating a Web Form:

1. Go to: **Website → Web Form**
2. Select DocType to collect data for
3. Configure fields and validations
4. Set up email notifications

### Basic Web Form Configuration:

```json
{
    "name": "Contact Us Form",
    "doctype": "Web Form",
    "doc_type": "Lead",
    "route": "contact-us",
    "title": "Contact Us",
    "introduction_text": "We'd love to hear from you. Send us a message and we'll get back to you soon.",
    "success_message": "Thank you for your interest! We'll contact you within 24 hours.",
    "is_published": 1,
    "allow_multiple": 1,
    "allow_edit": 0,
    "allow_delete": 0,
    "show_sidebar": 0,
    "allow_print": 0,
    "allow_comments": 0,
    "breadcrumbs": [
        {"label": "Home", "route": "/"},
        {"label": "Contact", "route": "/contact-us"}
    ]
}
```

### Web Form Fields Configuration:

```json
{
    "web_form_fields": [
        {
            "fieldname": "lead_name",
            "label": "Full Name",
            "fieldtype": "Data",
            "reqd": 1,
            "max_length": 100
        },
        {
            "fieldname": "email_id",
            "label": "Email Address",
            "fieldtype": "Data",
            "reqd": 1,
            "options": "Email"
        },
        {
            "fieldname": "phone",
            "label": "Phone Number",
            "fieldtype": "Data",
            "reqd": 0
        },
        {
            "fieldname": "company_name",
            "label": "Company Name",
            "fieldtype": "Data",
            "reqd": 0
        },
        {
            "fieldname": "source",
            "label": "How did you hear about us?",
            "fieldtype": "Select",
            "options": "Website\nSocial Media\nReferral\nAdvertisement\nOther",
            "reqd": 0
        },
        {
            "fieldname": "message",
            "label": "Message",
            "fieldtype": "Text",
            "reqd": 1,
            "description": "Please describe your inquiry"
        },
        {
            "fieldname": "marketing_consent",
            "label": "I agree to receive marketing communications",
            "fieldtype": "Check",
            "reqd": 0
        }
    ]
}
```

### Advanced Web Form with Validation:

```python
# Custom server-side validation
import frappe
from frappe import _

def validate_web_form_data(doc, method):
    """Custom validation for web form submissions"""
    
    # Email domain validation for business forms
    if doc.doctype == "Lead" and doc.email_id:
        if not validate_business_email(doc.email_id):
            frappe.throw(_("Please use a business email address"))
    
    # Phone number formatting
    if doc.phone:
        doc.phone = format_phone_number(doc.phone)
    
    # Spam protection
    if is_potential_spam(doc):
        frappe.throw(_("Your submission could not be processed. Please try again later."))
    
    # Set additional fields
    doc.status = "Open"
    doc.source = "Website"
    doc.lead_owner = get_round_robin_sales_person()

def validate_business_email(email):
    """Check if email is from business domain"""
    blocked_domains = ["gmail.com", "yahoo.com", "hotmail.com", "outlook.com"]
    domain = email.split("@")[1].lower()
    return domain not in blocked_domains

def format_phone_number(phone):
    """Format phone number"""
    import re
    # Remove all non-digits
    digits = re.sub(r'\D', '', phone)
    
    # Format US phone numbers
    if len(digits) == 10:
        return f"({digits[:3]}) {digits[3:6]}-{digits[6:]}"
    elif len(digits) == 11 and digits[0] == '1':
        return f"+1 ({digits[1:4]}) {digits[4:7]}-{digits[7:]}"
    
    return phone

def is_potential_spam(doc):
    """Basic spam detection"""
    spam_keywords = ["viagra", "casino", "lottery", "miracle", "guarantee"]
    message = (doc.message or "").lower()
    
    return any(keyword in message for keyword in spam_keywords)

def get_round_robin_sales_person():
    """Assign lead to sales person in round-robin fashion"""
    sales_people = frappe.get_all("User",
        filters={"role": "Sales Person", "enabled": 1},
        fields=["name"]
    )
    
    if not sales_people:
        return frappe.db.get_single_value("Selling Settings", "default_sales_person")
    
    # Get next in rotation
    last_assigned = frappe.cache().get_value("last_assigned_sales_person") or ""
    try:
        current_index = [sp.name for sp in sales_people].index(last_assigned)
        next_index = (current_index + 1) % len(sales_people)
    except ValueError:
        next_index = 0
    
    next_sales_person = sales_people[next_index].name
    frappe.cache().set_value("last_assigned_sales_person", next_sales_person)
    
    return next_sales_person
```

### Web Form Email Notifications:

```python
# Server Script - After Insert for Lead
if doc.source == "Website":
    # Send confirmation email to lead
    send_lead_confirmation_email(doc)
    
    # Notify sales team
    send_sales_notification(doc)

def send_lead_confirmation_email(lead):
    """Send confirmation email to the lead"""
    
    frappe.sendmail(
        recipients=[lead.email_id],
        subject=f"Thank you for your interest, {lead.lead_name}!",
        template="lead_confirmation",
        args={
            "lead_name": lead.lead_name,
            "lead_id": lead.name,
            "company": frappe.db.get_single_value("Global Defaults", "default_company")
        },
        delayed=False
    )

def send_sales_notification(lead):
    """Notify assigned sales person"""
    
    if lead.lead_owner:
        sales_person = frappe.get_doc("User", lead.lead_owner)
        
        frappe.sendmail(
            recipients=[sales_person.email],
            subject=f"New Lead Assignment: {lead.lead_name}",
            message=f"""
            <h3>New Lead Assigned</h3>
            <p><strong>Name:</strong> {lead.lead_name}</p>
            <p><strong>Email:</strong> {lead.email_id}</p>
            <p><strong>Phone:</strong> {lead.phone or 'Not provided'}</p>
            <p><strong>Company:</strong> {lead.company_name or 'Not provided'}</p>
            <p><strong>Source:</strong> {lead.source}</p>
            <p><strong>Message:</strong> {lead.message}</p>
            
            <p><a href="{frappe.utils.get_url()}/app/lead/{lead.name}">View Lead</a></p>
            """,
            delayed=False
        )
```

---

## 🔴 PORTAL PAGES PATTERNS (AUTHENTICATED USERS)

### Customer Portal Configuration:

```python
# Portal settings for Customer role
portal_settings = {
    "role": "Customer",
    "home_page": "/me",
    "custom_base_template": "templates/portal.html",
    "hide_standard_sidebar": 0,
    "show_sidebar": 1,
    "default_portal_role": "Customer"
}
```

### Customer Portal Dashboard:

```python
# [app]/[module]/page/customer_portal/customer_portal.py

import frappe
from frappe import _

def get_context(context):
    """Customer portal dashboard context"""
    
    # Check if user is logged in
    if frappe.session.user == "Guest":
        frappe.local.flags.redirect_location = "/login"
        raise frappe.Redirect
    
    # Get customer
    customer = get_customer_from_user()
    if not customer:
        frappe.throw(_("Customer not found for this user"))
    
    context.customer = frappe.get_doc("Customer", customer)
    context.recent_orders = get_recent_orders(customer)
    context.outstanding_invoices = get_outstanding_invoices(customer)
    context.support_tickets = get_support_tickets(customer)
    context.credit_summary = get_credit_summary(customer)
    
    return context

def get_customer_from_user():
    """Get customer linked to current user"""
    return frappe.db.get_value("Contact", 
        {"email_id": frappe.session.user}, 
        "customer")

def get_recent_orders(customer):
    """Get recent sales orders"""
    return frappe.get_all("Sales Order",
        filters={
            "customer": customer,
            "docstatus": ["!=", 2]
        },
        fields=[
            "name", "transaction_date", "status", 
            "grand_total", "currency", "delivery_date"
        ],
        order_by="transaction_date desc",
        limit=5
    )

def get_outstanding_invoices(customer):
    """Get unpaid invoices"""
    return frappe.get_all("Sales Invoice",
        filters={
            "customer": customer,
            "outstanding_amount": [">", 0],
            "docstatus": 1
        },
        fields=[
            "name", "posting_date", "due_date", 
            "grand_total", "outstanding_amount", "currency"
        ],
        order_by="due_date asc"
    )

def get_support_tickets(customer):
    """Get recent support tickets"""
    return frappe.get_all("Issue",
        filters={
            "customer": customer,
            "status": ["not in", ["Closed", "Resolved"]]
        },
        fields=[
            "name", "creation", "subject", "status", "priority"
        ],
        order_by="creation desc",
        limit=5
    )

def get_credit_summary(customer):
    """Get customer credit information"""
    customer_doc = frappe.get_doc("Customer", customer)
    
    return {
        "credit_limit": customer_doc.credit_limit or 0,
        "outstanding_amount": customer_doc.total_outstanding or 0,
        "available_credit": (customer_doc.credit_limit or 0) - (customer_doc.total_outstanding or 0)
    }
```

### Portal Template Structure:

```html
<!-- [app]/templates/pages/customer_portal.html -->

{% extends "templates/web.html" %}

{% block page_content %}
<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-3">
            <div class="portal-sidebar">
                <h4>{{ customer.customer_name }}</h4>
                <ul class="list-unstyled">
                    <li><a href="/me">Dashboard</a></li>
                    <li><a href="/orders">My Orders</a></li>
                    <li><a href="/invoices">Invoices</a></li>
                    <li><a href="/support">Support Tickets</a></li>
                    <li><a href="/profile">Profile</a></li>
                    <li><a href="/logout">Logout</a></li>
                </ul>
            </div>
        </div>

        <!-- Main Content -->
        <div class="col-md-9">
            <div class="portal-content">
                <h2>Welcome, {{ customer.customer_name }}</h2>
                
                <!-- Credit Summary -->
                <div class="row">
                    <div class="col-md-4">
                        <div class="card text-center">
                            <div class="card-body">
                                <h5 class="card-title">Credit Limit</h5>
                                <h3 class="text-primary">
                                    {{ frappe.utils.fmt_money(credit_summary.credit_limit, currency="USD") }}
                                </h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card text-center">
                            <div class="card-body">
                                <h5 class="card-title">Outstanding</h5>
                                <h3 class="text-warning">
                                    {{ frappe.utils.fmt_money(credit_summary.outstanding_amount, currency="USD") }}
                                </h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card text-center">
                            <div class="card-body">
                                <h5 class="card-title">Available Credit</h5>
                                <h3 class="text-success">
                                    {{ frappe.utils.fmt_money(credit_summary.available_credit, currency="USD") }}
                                </h3>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Orders -->
                <div class="mt-4">
                    <h4>Recent Orders</h4>
                    {% if recent_orders %}
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Order #</th>
                                    <th>Date</th>
                                    <th>Status</th>
                                    <th>Amount</th>
                                    <th>Delivery Date</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                {% for order in recent_orders %}
                                <tr>
                                    <td>{{ order.name }}</td>
                                    <td>{{ frappe.utils.formatdate(order.transaction_date) }}</td>
                                    <td>
                                        <span class="badge badge-{{ 'success' if order.status == 'Completed' else 'warning' }}">
                                            {{ order.status }}
                                        </span>
                                    </td>
                                    <td>{{ frappe.utils.fmt_money(order.grand_total, currency=order.currency) }}</td>
                                    <td>{{ frappe.utils.formatdate(order.delivery_date) if order.delivery_date else '-' }}</td>
                                    <td>
                                        <a href="/order/{{ order.name }}" class="btn btn-sm btn-outline-primary">
                                            View
                                        </a>
                                    </td>
                                </tr>
                                {% endfor %}
                            </tbody>
                        </table>
                    </div>
                    {% else %}
                    <p class="text-muted">No recent orders found.</p>
                    {% endif %}
                </div>

                <!-- Outstanding Invoices -->
                {% if outstanding_invoices %}
                <div class="mt-4">
                    <h4>Outstanding Invoices</h4>
                    <div class="alert alert-warning">
                        <strong>Action Required:</strong> You have {{ outstanding_invoices|length }} unpaid invoice(s).
                    </div>
                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Invoice #</th>
                                    <th>Date</th>
                                    <th>Due Date</th>
                                    <th>Total</th>
                                    <th>Outstanding</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                {% for invoice in outstanding_invoices %}
                                <tr class="{{ 'table-danger' if invoice.due_date < frappe.utils.today() else '' }}">
                                    <td>{{ invoice.name }}</td>
                                    <td>{{ frappe.utils.formatdate(invoice.posting_date) }}</td>
                                    <td>{{ frappe.utils.formatdate(invoice.due_date) }}</td>
                                    <td>{{ frappe.utils.fmt_money(invoice.grand_total, currency=invoice.currency) }}</td>
                                    <td>{{ frappe.utils.fmt_money(invoice.outstanding_amount, currency=invoice.currency) }}</td>
                                    <td>
                                        <a href="/invoice/{{ invoice.name }}" class="btn btn-sm btn-outline-primary">
                                            View
                                        </a>
                                        <button class="btn btn-sm btn-success" onclick="payInvoice('{{ invoice.name }}')">
                                            Pay Now
                                        </button>
                                    </td>
                                </tr>
                                {% endfor %}
                            </tbody>
                        </table>
                    </div>
                </div>
                {% endif %}
            </div>
        </div>
    </div>
</div>

<script>
function payInvoice(invoiceName) {
    // Integrate with payment gateway
    frappe.call({
        method: "app.api.create_payment_request",
        args: {
            invoice: invoiceName
        },
        callback: function(r) {
            if (r.message && r.message.payment_url) {
                window.location.href = r.message.payment_url;
            }
        }
    });
}
</script>
{% endblock %}
```

---

## 🔴 PORTAL API PATTERNS

### Portal Data API:

```python
# [app]/api/portal.py

import frappe
from frappe import _

@frappe.whitelist()
def get_order_details(order_name):
    """Get detailed order information for portal user"""
    
    # Verify user has access to this order
    customer = get_customer_from_user()
    order = frappe.get_doc("Sales Order", order_name)
    
    if order.customer != customer:
        frappe.throw(_("Access denied"), frappe.PermissionError)
    
    # Get order items
    items = []
    for item in order.items:
        items.append({
            "item_code": item.item_code,
            "item_name": item.item_name,
            "description": item.description,
            "qty": item.qty,
            "rate": item.rate,
            "amount": item.amount,
            "delivered_qty": item.delivered_qty,
            "status": get_item_delivery_status(item)
        })
    
    # Get delivery information
    delivery_notes = frappe.get_all("Delivery Note Item",
        filters={"against_sales_order": order_name},
        fields=["parent", "delivered_qty", "creation"],
        group_by="parent"
    )
    
    return {
        "order": {
            "name": order.name,
            "transaction_date": order.transaction_date,
            "delivery_date": order.delivery_date,
            "status": order.status,
            "grand_total": order.grand_total,
            "currency": order.currency
        },
        "items": items,
        "delivery_notes": delivery_notes,
        "shipping_address": get_formatted_address(order.shipping_address_name),
        "billing_address": get_formatted_address(order.customer_address)
    }

@frappe.whitelist()
def create_support_ticket(subject, description, priority="Medium"):
    """Create support ticket from portal"""
    
    customer = get_customer_from_user()
    if not customer:
        frappe.throw(_("Customer not found"))
    
    # Create issue
    issue = frappe.get_doc({
        "doctype": "Issue",
        "customer": customer,
        "subject": subject,
        "description": description,
        "priority": priority,
        "issue_type": "Portal Request",
        "raised_by": frappe.session.user
    })
    issue.insert(ignore_permissions=True)
    
    # Send confirmation email
    frappe.sendmail(
        recipients=[frappe.session.user],
        subject=f"Support Ticket Created: {issue.name}",
        message=f"""
        <p>Your support ticket has been created successfully.</p>
        <p><strong>Ticket ID:</strong> {issue.name}</p>
        <p><strong>Subject:</strong> {subject}</p>
        <p><strong>Priority:</strong> {priority}</p>
        <p>We'll get back to you within 24 hours.</p>
        """
    )
    
    return {"success": True, "ticket_id": issue.name}

@frappe.whitelist()
def update_profile(customer_name, email_id, mobile_no, billing_address):
    """Update customer profile from portal"""
    
    customer = get_customer_from_user()
    if customer != customer_name:
        frappe.throw(_("Access denied"), frappe.PermissionError)
    
    # Update customer
    customer_doc = frappe.get_doc("Customer", customer)
    customer_doc.customer_name = customer_name
    customer_doc.save(ignore_permissions=True)
    
    # Update contact
    contact = frappe.get_doc("Contact", {"email_id": frappe.session.user})
    contact.email_id = email_id
    contact.mobile_no = mobile_no
    contact.save(ignore_permissions=True)
    
    # Update address if provided
    if billing_address:
        update_customer_address(customer, billing_address)
    
    return {"success": True, "message": "Profile updated successfully"}

def get_item_delivery_status(item):
    """Get delivery status for order item"""
    if item.delivered_qty >= item.qty:
        return "Delivered"
    elif item.delivered_qty > 0:
        return "Partially Delivered"
    else:
        return "Pending"

def get_formatted_address(address_name):
    """Get formatted address"""
    if not address_name:
        return None
    
    address = frappe.get_doc("Address", address_name)
    return {
        "address_line1": address.address_line1,
        "address_line2": address.address_line2,
        "city": address.city,
        "state": address.state,
        "pincode": address.pincode,
        "country": address.country
    }
```

---

## 🔴 PAYMENT INTEGRATION PATTERNS

### Payment Gateway Integration:

```python
# [app]/api/payments.py

import frappe
from frappe import _
import requests
import hashlib

@frappe.whitelist()
def create_payment_request(invoice):
    """Create payment request for invoice"""
    
    # Verify access
    customer = get_customer_from_user()
    invoice_doc = frappe.get_doc("Sales Invoice", invoice)
    
    if invoice_doc.customer != customer:
        frappe.throw(_("Access denied"), frappe.PermissionError)
    
    # Create payment request
    payment_request = frappe.get_doc({
        "doctype": "Payment Request",
        "payment_request_type": "Inward",
        "party_type": "Customer",
        "party": customer,
        "reference_doctype": "Sales Invoice",
        "reference_name": invoice,
        "payment_gateway": "Stripe",  # Or your preferred gateway
        "grand_total": invoice_doc.outstanding_amount,
        "currency": invoice_doc.currency,
        "email_to": frappe.session.user
    })
    payment_request.insert(ignore_permissions=True)
    payment_request.submit()
    
    # Generate payment URL
    payment_url = generate_payment_url(payment_request)
    
    return {
        "success": True,
        "payment_request": payment_request.name,
        "payment_url": payment_url,
        "amount": invoice_doc.outstanding_amount
    }

def generate_payment_url(payment_request):
    """Generate secure payment URL"""
    
    # Create payment session with gateway
    gateway_settings = frappe.get_single("Payment Gateway Settings")
    
    payment_data = {
        "amount": int(payment_request.grand_total * 100),  # Convert to cents
        "currency": payment_request.currency.lower(),
        "description": f"Payment for {payment_request.reference_name}",
        "payment_request_id": payment_request.name,
        "success_url": f"{frappe.utils.get_url()}/payment-success",
        "cancel_url": f"{frappe.utils.get_url()}/payment-cancel"
    }
    
    # Create signature for security
    signature = create_payment_signature(payment_data, gateway_settings.secret_key)
    payment_data["signature"] = signature
    
    # Return gateway-specific URL
    return f"{gateway_settings.gateway_url}/checkout?{urllib.parse.urlencode(payment_data)}"

@frappe.whitelist(allow_guest=True)
def payment_callback(payment_request_id, status, transaction_id, signature):
    """Handle payment gateway callback"""
    
    # Verify signature
    if not verify_payment_signature(payment_request_id, status, transaction_id, signature):
        frappe.throw(_("Invalid payment signature"))
    
    payment_request = frappe.get_doc("Payment Request", payment_request_id)
    
    if status == "success":
        # Create payment entry
        payment_entry = frappe.get_doc({
            "doctype": "Payment Entry",
            "payment_type": "Receive",
            "party_type": "Customer",
            "party": payment_request.party,
            "paid_amount": payment_request.grand_total,
            "received_amount": payment_request.grand_total,
            "reference_no": transaction_id,
            "reference_date": frappe.utils.today(),
            "references": [{
                "reference_doctype": payment_request.reference_doctype,
                "reference_name": payment_request.reference_name,
                "allocated_amount": payment_request.grand_total
            }]
        })
        payment_entry.insert(ignore_permissions=True)
        payment_entry.submit()
        
        # Update payment request
        payment_request.db_set("status", "Paid")
        
        return {"success": True, "payment_entry": payment_entry.name}
    
    else:
        # Handle failed payment
        payment_request.db_set("status", "Failed")
        return {"success": False, "message": "Payment failed"}
```

---

## 🔴 SECURITY PATTERNS FOR PORTAL

### Access Control:

```python
def validate_portal_access(user, doctype, doc_name):
    """Validate portal user access to documents"""
    
    # Get customer from user
    customer = get_customer_from_user(user)
    if not customer:
        return False
    
    # Check document-specific access
    if doctype == "Sales Order":
        doc = frappe.get_doc(doctype, doc_name)
        return doc.customer == customer
    
    elif doctype == "Sales Invoice":
        doc = frappe.get_doc(doctype, doc_name)
        return doc.customer == customer
    
    elif doctype == "Issue":
        doc = frappe.get_doc(doctype, doc_name)
        return doc.customer == customer
    
    return False

def get_customer_from_user(user=None):
    """Get customer linked to user"""
    user = user or frappe.session.user
    
    # Check in Contact
    customer = frappe.db.get_value("Contact", 
        {"email_id": user}, "customer")
    
    # Check in User if not found in Contact
    if not customer:
        customer = frappe.db.get_value("User", user, "customer")
    
    return customer

def portal_permission_check():
    """Decorator for portal permission checking"""
    def decorator(func):
        def wrapper(*args, **kwargs):
            if frappe.session.user == "Guest":
                frappe.throw(_("Please log in to access this page"), frappe.AuthenticationError)
            
            customer = get_customer_from_user()
            if not customer:
                frappe.throw(_("No customer account found"), frappe.PermissionError)
            
            return func(*args, **kwargs)
        return wrapper
    return decorator
```

### Rate Limiting:

```python
import frappe
from frappe.utils import now_datetime, add_to_date

def check_rate_limit(user, action, limit=10, window_minutes=60):
    """Rate limiting for portal actions"""
    
    cache_key = f"rate_limit:{user}:{action}"
    current_time = now_datetime()
    window_start = add_to_date(current_time, minutes=-window_minutes)
    
    # Get recent attempts
    attempts = frappe.cache().get_value(cache_key) or []
    
    # Filter attempts within window
    valid_attempts = [
        attempt for attempt in attempts 
        if attempt > window_start.isoformat()
    ]
    
    if len(valid_attempts) >= limit:
        frappe.throw(_("Rate limit exceeded. Please try again later."))
    
    # Add current attempt
    valid_attempts.append(current_time.isoformat())
    frappe.cache().set_value(cache_key, valid_attempts, expires_in_sec=window_minutes*60)

@frappe.whitelist()
def submit_contact_form(name, email, message):
    """Rate-limited contact form submission"""
    
    # Check rate limit
    check_rate_limit(frappe.session.user, "contact_form", limit=5, window_minutes=60)
    
    # Process form submission
    lead = frappe.get_doc({
        "doctype": "Lead",
        "lead_name": name,
        "email_id": email,
        "message": message,
        "source": "Website"
    })
    lead.insert(ignore_permissions=True)
    
    return {"success": True, "lead_id": lead.name}
```

---

## 📋 PORTAL CHECKLIST

Before deploying portal features:

- [ ] Configure proper permissions
- [ ] Test guest user access
- [ ] Implement rate limiting
- [ ] Add CSRF protection
- [ ] Validate all user inputs
- [ ] Test payment integration
- [ ] Check mobile responsiveness
- [ ] Add proper error handling
- [ ] Implement session management
- [ ] Test email notifications
- [ ] Add analytics tracking
- [ ] Document user workflows

---

**REMEMBER**: Portal security is critical - always validate permissions and sanitize inputs!