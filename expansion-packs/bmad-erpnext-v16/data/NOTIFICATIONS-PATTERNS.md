# 🚨 NOTIFICATIONS PATTERNS - EMAIL & SMS AUTOMATION

## CRITICAL: Proper Communication = Customer Satisfaction

This document contains MANDATORY patterns for email notifications, SMS alerts, and communication automation in Frappe/ERPNext.

---

## 🔴 UNDERSTANDING FRAPPE'S NOTIFICATION SYSTEM

### Communication Channels:

| Channel | Use For | Delivery Speed | Cost | Reliability |
|---------|---------|---------------|------|-------------|
| **Email** | Documents, reports, alerts | Medium | Low | High |
| **SMS** | Urgent alerts, OTP | Fast | Medium | High |
| **Push Notifications** | Real-time updates | Instant | Low | Medium |
| **In-App Notifications** | System messages | Instant | None | High |

### Notification Triggers:

- **Document Events**: Save, submit, cancel, delete
- **Field Changes**: Value updates, status changes
- **Schedule Events**: Daily, weekly, monthly
- **Custom Events**: Business logic triggers
- **Workflow Events**: Approval, rejection, escalation

---

## 🔴 EMAIL NOTIFICATION PATTERNS

### Basic Email Notification:

```python
# [app]/notifications/email_notifications.py

import frappe
from frappe import _
from frappe.utils import formatdate, fmt_money

def send_order_confirmation(doc, method):
    """Send order confirmation email to customer"""
    
    if doc.doctype == "Sales Order" and method == "on_submit":
        
        # Get customer email
        customer_email = get_customer_email(doc.customer)
        if not customer_email:
            frappe.log_error(f"No email found for customer {doc.customer}")
            return
        
        # Prepare email content
        subject = f"Order Confirmation - {doc.name}"
        
        # Use Jinja template
        message = frappe.render_template("templates/emails/order_confirmation.html", {
            "doc": doc,
            "customer": frappe.get_doc("Customer", doc.customer),
            "company": frappe.get_doc("Company", doc.company)
        })
        
        # Send email
        frappe.sendmail(
            recipients=[customer_email],
            cc=get_sales_team_emails(doc),
            subject=subject,
            message=message,
            attachments=get_order_attachments(doc),
            delayed=False  # Send immediately
        )
        
        # Log communication
        frappe.get_doc({
            "doctype": "Communication",
            "communication_type": "Communication",
            "subject": subject,
            "content": message,
            "sent_or_received": "Sent",
            "reference_doctype": doc.doctype,
            "reference_name": doc.name,
            "recipients": customer_email
        }).insert(ignore_permissions=True)

def get_customer_email(customer):
    """Get customer primary email"""
    
    # Try contact first
    email = frappe.db.get_value("Contact", 
        {"customer": customer, "is_primary_contact": 1}, 
        "email_id")
    
    # Fallback to customer email
    if not email:
        email = frappe.db.get_value("Customer", customer, "email_id")
    
    return email

def get_sales_team_emails(doc):
    """Get sales team emails for CC"""
    
    emails = []
    
    # Sales person
    if doc.sales_person:
        sales_email = frappe.db.get_value("Sales Person", doc.sales_person, "email")
        if sales_email:
            emails.append(sales_email)
    
    # Territory manager
    if doc.territory:
        manager_email = frappe.db.get_value("Territory", doc.territory, "manager_email")
        if manager_email:
            emails.append(manager_email)
    
    return emails

def get_order_attachments(doc):
    """Get order-related attachments"""
    
    attachments = []
    
    # Attach order PDF
    pdf_content = frappe.get_print(
        doctype=doc.doctype,
        name=doc.name,
        print_format="Sales Order Modern",
        as_pdf=True
    )
    
    attachments.append({
        "fname": f"Order_{doc.name}.pdf",
        "fcontent": pdf_content
    })
    
    # Attach terms and conditions if available
    if doc.tc_name:
        tc_doc = frappe.get_doc("Terms and Conditions", doc.tc_name)
        if tc_doc.terms:
            attachments.append({
                "fname": "Terms_and_Conditions.pdf",
                "fcontent": frappe.get_print(
                    doctype="Terms and Conditions",
                    name=doc.tc_name,
                    as_pdf=True
                )
            })
    
    return attachments
```

### Email Template System:

```html
<!-- [app]/templates/emails/order_confirmation.html -->

<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
    <!-- Header -->
    <div style="background-color: #f8f9fa; padding: 20px; text-align: center; border-bottom: 3px solid #007bff;">
        {% if company.letter_head %}
            <img src="{{ company.letter_head }}" style="max-height: 60px;" alt="{{ company.company_name }}">
        {% endif %}
        <h1 style="color: #007bff; margin: 10px 0;">Order Confirmed!</h1>
    </div>
    
    <!-- Order Information -->
    <div style="padding: 20px;">
        <h2>Hello {{ customer.customer_name }},</h2>
        <p>Thank you for your order! We're excited to confirm that we've received your order and it's being processed.</p>
        
        <div style="background-color: #e9ecef; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <h3 style="margin: 0 0 10px 0;">Order Details</h3>
            <table style="width: 100%; border-collapse: collapse;">
                <tr>
                    <td style="padding: 5px 0;"><strong>Order Number:</strong></td>
                    <td style="padding: 5px 0;">{{ doc.name }}</td>
                </tr>
                <tr>
                    <td style="padding: 5px 0;"><strong>Order Date:</strong></td>
                    <td style="padding: 5px 0;">{{ frappe.utils.formatdate(doc.transaction_date) }}</td>
                </tr>
                <tr>
                    <td style="padding: 5px 0;"><strong>Expected Delivery:</strong></td>
                    <td style="padding: 5px 0;">{{ frappe.utils.formatdate(doc.delivery_date) if doc.delivery_date else 'TBD' }}</td>
                </tr>
                <tr>
                    <td style="padding: 5px 0;"><strong>Total Amount:</strong></td>
                    <td style="padding: 5px 0; font-size: 18px; font-weight: bold; color: #28a745;">
                        {{ frappe.utils.fmt_money(doc.grand_total, doc.currency) }}
                    </td>
                </tr>
            </table>
        </div>
        
        <!-- Items Table -->
        <h3>Ordered Items</h3>
        <table style="width: 100%; border-collapse: collapse; border: 1px solid #dee2e6;">
            <thead style="background-color: #f8f9fa;">
                <tr>
                    <th style="padding: 10px; border: 1px solid #dee2e6; text-align: left;">Item</th>
                    <th style="padding: 10px; border: 1px solid #dee2e6; text-align: center;">Qty</th>
                    <th style="padding: 10px; border: 1px solid #dee2e6; text-align: right;">Rate</th>
                    <th style="padding: 10px; border: 1px solid #dee2e6; text-align: right;">Amount</th>
                </tr>
            </thead>
            <tbody>
                {% for item in doc.items %}
                <tr>
                    <td style="padding: 10px; border: 1px solid #dee2e6;">
                        <strong>{{ item.item_code }}</strong><br>
                        <small>{{ item.description or item.item_name }}</small>
                    </td>
                    <td style="padding: 10px; border: 1px solid #dee2e6; text-align: center;">
                        {{ item.qty }}
                    </td>
                    <td style="padding: 10px; border: 1px solid #dee2e6; text-align: right;">
                        {{ frappe.utils.fmt_money(item.rate, doc.currency) }}
                    </td>
                    <td style="padding: 10px; border: 1px solid #dee2e6; text-align: right;">
                        {{ frappe.utils.fmt_money(item.amount, doc.currency) }}
                    </td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
        
        <!-- Shipping Information -->
        {% if doc.shipping_address %}
        <div style="margin: 20px 0;">
            <h3>Shipping Address</h3>
            <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px;">
                {{ frappe.get_doc("Address", doc.shipping_address).get_display() }}
            </div>
        </div>
        {% endif %}
        
        <!-- Next Steps -->
        <div style="background-color: #d1ecf1; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <h3 style="color: #0c5460; margin: 0 0 10px 0;">What happens next?</h3>
            <ul style="margin: 0; padding-left: 20px;">
                <li>Your order is being prepared for shipment</li>
                <li>You'll receive a tracking number once shipped</li>
                <li>Expected delivery: {{ frappe.utils.formatdate(doc.delivery_date) if doc.delivery_date else '5-7 business days' }}</li>
            </ul>
        </div>
        
        <!-- Support Information -->
        <div style="text-align: center; margin: 20px 0;">
            <p>Questions about your order?</p>
            <p>
                <a href="mailto:{{ company.email_id }}" style="color: #007bff; text-decoration: none;">
                    Email: {{ company.email_id }}
                </a>
                {% if company.phone_no %}
                | Phone: {{ company.phone_no }}
                {% endif %}
            </p>
        </div>
    </div>
    
    <!-- Footer -->
    <div style="background-color: #6c757d; color: white; padding: 20px; text-align: center;">
        <p style="margin: 0;">Thank you for choosing {{ company.company_name }}!</p>
        <p style="margin: 5px 0 0 0; font-size: 12px;">
            This is an automated message. Please do not reply to this email.
        </p>
    </div>
</div>
```

### Advanced Email Automation:

```python
# [app]/notifications/advanced_email.py

import frappe
from frappe.utils import add_days, today, now_datetime
from frappe.utils.background_jobs import enqueue

def schedule_payment_reminders():
    """Schedule payment reminder emails"""
    
    # Get overdue invoices
    overdue_invoices = frappe.get_all("Sales Invoice",
        filters={
            "docstatus": 1,
            "outstanding_amount": [">", 0],
            "due_date": ["<", today()]
        },
        fields=["name", "customer", "outstanding_amount", "due_date", "currency"]
    )
    
    for invoice in overdue_invoices:
        days_overdue = (today() - invoice.due_date).days
        
        # Send reminders at different intervals
        if days_overdue in [1, 7, 15, 30]:
            send_payment_reminder(invoice, days_overdue)

def send_payment_reminder(invoice, days_overdue):
    """Send payment reminder email"""
    
    invoice_doc = frappe.get_doc("Sales Invoice", invoice.name)
    customer_email = get_customer_email(invoice.customer)
    
    if not customer_email:
        return
    
    # Determine urgency level
    if days_overdue >= 30:
        urgency = "urgent"
        subject_prefix = "URGENT - "
    elif days_overdue >= 15:
        urgency = "high"
        subject_prefix = "IMPORTANT - "
    else:
        urgency = "normal"
        subject_prefix = ""
    
    subject = f"{subject_prefix}Payment Reminder - Invoice {invoice.name}"
    
    message = frappe.render_template("templates/emails/payment_reminder.html", {
        "invoice": invoice_doc,
        "customer": frappe.get_doc("Customer", invoice.customer),
        "days_overdue": days_overdue,
        "urgency": urgency,
        "payment_link": generate_payment_link(invoice.name)
    })
    
    # Send email
    frappe.sendmail(
        recipients=[customer_email],
        cc=get_accounts_team_emails(),
        subject=subject,
        message=message,
        attachments=[{
            "fname": f"Invoice_{invoice.name}.pdf",
            "fcontent": frappe.get_print("Sales Invoice", invoice.name, as_pdf=True)
        }]
    )
    
    # Log reminder
    frappe.get_doc({
        "doctype": "Communication",
        "communication_type": "Communication",
        "subject": subject,
        "content": f"Payment reminder sent for invoice {invoice.name}",
        "sent_or_received": "Sent",
        "reference_doctype": "Sales Invoice",
        "reference_name": invoice.name,
        "recipients": customer_email
    }).insert(ignore_permissions=True)

def send_bulk_newsletter(newsletter_doc):
    """Send newsletter to subscriber list"""
    
    # Get subscribers
    subscribers = frappe.get_all("Newsletter Subscriber",
        filters={"enabled": 1},
        fields=["email", "name"]
    )
    
    if not subscribers:
        return
    
    # Process in batches to avoid overwhelming the email server
    batch_size = 50
    batches = [subscribers[i:i + batch_size] for i in range(0, len(subscribers), batch_size)]
    
    for batch in batches:
        enqueue(
            send_newsletter_batch,
            queue='long',
            timeout=600,
            newsletter=newsletter_doc.name,
            subscriber_batch=batch
        )

def send_newsletter_batch(newsletter, subscriber_batch):
    """Send newsletter to a batch of subscribers"""
    
    newsletter_doc = frappe.get_doc("Newsletter", newsletter)
    
    for subscriber in subscriber_batch:
        try:
            # Personalize content
            unsubscribe_link = f"{frappe.utils.get_url()}/api/method/unsubscribe?email={subscriber.email}&token={generate_unsubscribe_token(subscriber.email)}"
            
            personalized_content = newsletter_doc.content.replace(
                "{{unsubscribe_link}}", unsubscribe_link
            )
            
            # Send email
            frappe.sendmail(
                recipients=[subscriber.email],
                subject=newsletter_doc.subject,
                message=personalized_content,
                delayed=True  # Use queue for bulk sending
            )
            
        except Exception as e:
            frappe.log_error(f"Failed to send newsletter to {subscriber.email}: {str(e)}")

def generate_unsubscribe_token(email):
    """Generate secure unsubscribe token"""
    import hashlib
    import time
    
    secret = frappe.get_single("System Settings").encryption_key or "default_secret"
    timestamp = str(int(time.time()))
    
    token_string = f"{email}:{timestamp}:{secret}"
    return hashlib.sha256(token_string.encode()).hexdigest()[:16]
```

---

## 🔴 SMS NOTIFICATION PATTERNS

### SMS Integration Setup:

```python
# [app]/notifications/sms_notifications.py

import frappe
from frappe import _
import requests
import json

class SMSProvider:
    def __init__(self):
        self.settings = frappe.get_single("SMS Settings")
        
    def send_sms(self, phone_number, message):
        """Send SMS via configured provider"""
        
        # Validate phone number
        phone_number = self.format_phone_number(phone_number)
        if not phone_number:
            frappe.throw(_("Invalid phone number"))
        
        # Check message length
        if len(message) > 160:
            frappe.throw(_("SMS message too long (max 160 characters)"))
        
        # Send via provider
        if self.settings.provider == "Twilio":
            return self.send_via_twilio(phone_number, message)
        elif self.settings.provider == "AWS SNS":
            return self.send_via_aws_sns(phone_number, message)
        else:
            frappe.throw(_("SMS provider not configured"))
    
    def format_phone_number(self, phone):
        """Format phone number for SMS"""
        
        # Remove all non-digits
        digits = ''.join(filter(str.isdigit, phone))
        
        # Add country code if missing
        if len(digits) == 10:  # US number without country code
            digits = "1" + digits
        
        # Validate length
        if len(digits) < 10 or len(digits) > 15:
            return None
        
        return f"+{digits}"
    
    def send_via_twilio(self, phone_number, message):
        """Send SMS via Twilio"""
        
        try:
            from twilio.rest import Client
            
            client = Client(
                self.settings.twilio_account_sid,
                frappe.utils.password.get_decrypted_password(
                    "SMS Settings", "SMS Settings", "twilio_auth_token"
                )
            )
            
            message = client.messages.create(
                body=message,
                from_=self.settings.twilio_phone_number,
                to=phone_number
            )
            
            return {"success": True, "message_sid": message.sid}
            
        except Exception as e:
            frappe.log_error(f"Twilio SMS failed: {str(e)}")
            return {"success": False, "error": str(e)}
    
    def send_via_aws_sns(self, phone_number, message):
        """Send SMS via AWS SNS"""
        
        try:
            import boto3
            
            sns = boto3.client(
                'sns',
                aws_access_key_id=self.settings.aws_access_key,
                aws_secret_access_key=frappe.utils.password.get_decrypted_password(
                    "SMS Settings", "SMS Settings", "aws_secret_key"
                ),
                region_name=self.settings.aws_region
            )
            
            response = sns.publish(
                PhoneNumber=phone_number,
                Message=message
            )
            
            return {"success": True, "message_id": response['MessageId']}
            
        except Exception as e:
            frappe.log_error(f"AWS SNS SMS failed: {str(e)}")
            return {"success": False, "error": str(e)}

@frappe.whitelist()
def send_otp_sms(phone_number, purpose="verification"):
    """Send OTP via SMS"""
    
    # Generate OTP
    import random
    otp = str(random.randint(100000, 999999))
    
    # Store OTP with expiry
    frappe.cache().set_value(
        f"otp:{phone_number}:{purpose}",
        otp,
        expires_in_sec=300  # 5 minutes
    )
    
    # Send SMS
    sms_provider = SMSProvider()
    message = f"Your OTP is: {otp}. Valid for 5 minutes. Do not share this code."
    
    result = sms_provider.send_sms(phone_number, message)
    
    if result["success"]:
        # Log SMS
        frappe.get_doc({
            "doctype": "SMS Log",
            "phone_number": phone_number,
            "message": message,
            "status": "Sent",
            "purpose": purpose
        }).insert(ignore_permissions=True)
        
        return {"success": True, "message": "OTP sent successfully"}
    else:
        return {"success": False, "error": result["error"]}

@frappe.whitelist()
def verify_otp(phone_number, otp, purpose="verification"):
    """Verify OTP"""
    
    cached_otp = frappe.cache().get_value(f"otp:{phone_number}:{purpose}")
    
    if not cached_otp:
        return {"success": False, "error": "OTP expired or not found"}
    
    if cached_otp == otp:
        # Clear OTP after successful verification
        frappe.cache().delete_value(f"otp:{phone_number}:{purpose}")
        return {"success": True, "message": "OTP verified successfully"}
    else:
        return {"success": False, "error": "Invalid OTP"}

def send_order_status_sms(doc, method):
    """Send SMS notification for order status changes"""
    
    if doc.doctype == "Sales Order" and doc.has_value_changed("status"):
        
        # Get customer phone
        phone = get_customer_phone(doc.customer)
        if not phone:
            return
        
        # Create status message
        status_messages = {
            "Confirmed": "Your order {order} has been confirmed. Expected delivery: {delivery_date}",
            "Shipped": "Great news! Your order {order} has been shipped. Track at: {tracking_url}",
            "Delivered": "Your order {order} has been delivered. Thank you for your business!",
            "Cancelled": "Your order {order} has been cancelled. Please contact us for assistance."
        }
        
        message_template = status_messages.get(doc.status)
        if message_template:
            message = message_template.format(
                order=doc.name,
                delivery_date=frappe.utils.formatdate(doc.delivery_date) if doc.delivery_date else "TBD",
                tracking_url=f"{frappe.utils.get_url()}/track-order/{doc.name}"
            )
            
            # Send SMS
            sms_provider = SMSProvider()
            result = sms_provider.send_sms(phone, message)
            
            if result["success"]:
                # Log SMS
                frappe.get_doc({
                    "doctype": "SMS Log",
                    "phone_number": phone,
                    "message": message,
                    "status": "Sent",
                    "reference_doctype": doc.doctype,
                    "reference_name": doc.name
                }).insert(ignore_permissions=True)

def get_customer_phone(customer):
    """Get customer mobile number"""
    
    # Try contact first
    phone = frappe.db.get_value("Contact",
        {"customer": customer, "is_primary_contact": 1},
        "mobile_no")
    
    # Fallback to customer mobile
    if not phone:
        phone = frappe.db.get_value("Customer", customer, "mobile_no")
    
    return phone
```

---

## 🔴 PUSH NOTIFICATION PATTERNS

### Web Push Notifications:

```javascript
// [app]/public/js/push_notifications.js

class PushNotificationManager {
    constructor() {
        this.vapidPublicKey = frappe.boot.push_notification_vapid_key;
        this.registration = null;
    }
    
    async initialize() {
        if ('serviceWorker' in navigator && 'PushManager' in window) {
            try {
                // Register service worker
                this.registration = await navigator.serviceWorker.register('/sw.js');
                console.log('Service Worker registered');
                
                // Check for existing subscription
                const existingSubscription = await this.registration.pushManager.getSubscription();
                if (existingSubscription) {
                    await this.updateSubscription(existingSubscription);
                }
                
            } catch (error) {
                console.error('Service Worker registration failed:', error);
            }
        }
    }
    
    async requestPermission() {
        const permission = await Notification.requestPermission();
        if (permission === 'granted') {
            await this.subscribeToPush();
            return true;
        }
        return false;
    }
    
    async subscribeToPush() {
        try {
            const subscription = await this.registration.pushManager.subscribe({
                userVisibleOnly: true,
                applicationServerKey: this.urlBase64ToUint8Array(this.vapidPublicKey)
            });
            
            // Send subscription to server
            await this.updateSubscription(subscription);
            
        } catch (error) {
            console.error('Push subscription failed:', error);
        }
    }
    
    async updateSubscription(subscription) {
        try {
            await frappe.call({
                method: 'app.api.update_push_subscription',
                args: {
                    subscription: JSON.stringify(subscription)
                }
            });
        } catch (error) {
            console.error('Failed to update subscription:', error);
        }
    }
    
    urlBase64ToUint8Array(base64String) {
        const padding = '='.repeat((4 - base64String.length % 4) % 4);
        const base64 = (base64String + padding)
            .replace(/-/g, '+')
            .replace(/_/g, '/');
        
        const rawData = window.atob(base64);
        const outputArray = new Uint8Array(rawData.length);
        
        for (let i = 0; i < rawData.length; ++i) {
            outputArray[i] = rawData.charCodeAt(i);
        }
        return outputArray;
    }
}

// Initialize push notifications
$(document).ready(function() {
    const pushManager = new PushNotificationManager();
    pushManager.initialize();
    
    // Add notification permission button to navbar
    if ('Notification' in window && Notification.permission === 'default') {
        const button = $(`
            <button class="btn btn-sm btn-secondary" id="enable-notifications">
                <i class="fa fa-bell"></i> Enable Notifications
            </button>
        `);
        
        $('.navbar-right').prepend(button);
        
        button.click(async function() {
            const granted = await pushManager.requestPermission();
            if (granted) {
                $(this).remove();
                frappe.show_alert('Notifications enabled!', 5);
            }
        });
    }
});
```

### Server-Side Push Implementation:

```python
# [app]/api/push_notifications.py

import frappe
from frappe import _
import json
from pywebpush import webpush, WebPushException

@frappe.whitelist()
def update_push_subscription(subscription):
    """Update user's push notification subscription"""
    
    subscription_data = json.loads(subscription)
    
    # Store or update subscription
    existing = frappe.db.get_value("Push Subscription",
        {"user": frappe.session.user},
        "name")
    
    if existing:
        doc = frappe.get_doc("Push Subscription", existing)
        doc.subscription_data = subscription
        doc.save()
    else:
        doc = frappe.get_doc({
            "doctype": "Push Subscription",
            "user": frappe.session.user,
            "subscription_data": subscription,
            "enabled": 1
        })
        doc.insert()
    
    return {"success": True}

def send_push_notification(user, title, body, data=None, actions=None):
    """Send push notification to user"""
    
    # Get user's subscription
    subscription_data = frappe.db.get_value("Push Subscription",
        {"user": user, "enabled": 1},
        "subscription_data")
    
    if not subscription_data:
        return {"success": False, "error": "No subscription found"}
    
    try:
        subscription = json.loads(subscription_data)
        
        # Prepare notification payload
        payload = {
            "title": title,
            "body": body,
            "icon": "/assets/app_name/images/notification-icon.png",
            "badge": "/assets/app_name/images/notification-badge.png",
            "data": data or {},
            "actions": actions or []
        }
        
        # Get VAPID keys from settings
        settings = frappe.get_single("Push Notification Settings")
        
        # Send notification
        response = webpush(
            subscription_info=subscription,
            data=json.dumps(payload),
            vapid_private_key=frappe.utils.password.get_decrypted_password(
                "Push Notification Settings", "Push Notification Settings", "vapid_private_key"
            ),
            vapid_claims={
                "sub": f"mailto:{settings.contact_email}"
            }
        )
        
        # Log notification
        frappe.get_doc({
            "doctype": "Push Notification Log",
            "user": user,
            "title": title,
            "body": body,
            "status": "Sent",
            "response_code": response.status_code
        }).insert(ignore_permissions=True)
        
        return {"success": True, "status_code": response.status_code}
        
    except WebPushException as e:
        frappe.log_error(f"Push notification failed: {str(e)}")
        return {"success": False, "error": str(e)}

def notify_document_assigned(doc, method):
    """Send push notification when document is assigned"""
    
    if hasattr(doc, '_assign'):
        assigned_users = json.loads(doc._assign or "[]")
        
        for user in assigned_users:
            send_push_notification(
                user=user,
                title=f"New Assignment: {doc.doctype}",
                body=f"{doc.doctype} {doc.name} has been assigned to you",
                data={
                    "doctype": doc.doctype,
                    "docname": doc.name,
                    "action": "assignment"
                },
                actions=[
                    {
                        "action": "view",
                        "title": "View Document",
                        "icon": "/assets/app_name/images/view-icon.png"
                    },
                    {
                        "action": "dismiss",
                        "title": "Dismiss",
                        "icon": "/assets/app_name/images/dismiss-icon.png"
                    }
                ]
            )
```

---

## 🔴 NOTIFICATION SCHEDULING AND AUTOMATION

### Scheduled Notification System:

```python
# [app]/notifications/scheduler.py

import frappe
from frappe.utils import add_days, today, now_datetime
from datetime import datetime, timedelta

def send_daily_digest():
    """Send daily digest email to users"""
    
    # Get all users who want daily digest
    users = frappe.get_all("User",
        filters={"enabled": 1, "send_daily_digest": 1},
        fields=["name", "email", "full_name"]
    )
    
    for user in users:
        digest_data = compile_user_digest(user.name)
        
        if digest_data["has_content"]:
            send_digest_email(user, digest_data)

def compile_user_digest(user):
    """Compile daily digest data for user"""
    
    today_start = datetime.combine(today(), datetime.min.time())
    today_end = datetime.combine(today(), datetime.max.time())
    
    digest = {
        "has_content": False,
        "pending_tasks": 0,
        "new_assignments": 0,
        "overdue_items": 0,
        "notifications": [],
        "summary": {}
    }
    
    # Get pending ToDos
    todos = frappe.get_all("ToDo",
        filters={
            "allocated_to": user,
            "status": "Open"
        },
        fields=["name", "description", "priority", "date"]
    )
    digest["pending_tasks"] = len(todos)
    
    # Get new assignments today
    assignments = frappe.get_all("Assignment Rule",
        filters={
            "user": user,
            "creation": ["between", [today_start, today_end]]
        }
    )
    digest["new_assignments"] = len(assignments)
    
    # Get overdue items
    overdue_items = get_overdue_items_for_user(user)
    digest["overdue_items"] = len(overdue_items)
    
    # Get recent notifications
    notifications = frappe.get_all("Notification Log",
        filters={
            "for_user": user,
            "creation": ["between", [today_start, today_end]]
        },
        fields=["subject", "type", "document_type", "document_name"],
        limit=10,
        order_by="creation desc"
    )
    digest["notifications"] = notifications
    
    # Check if there's content worth sending
    digest["has_content"] = (
        digest["pending_tasks"] > 0 or
        digest["new_assignments"] > 0 or
        digest["overdue_items"] > 0 or
        len(digest["notifications"]) > 0
    )
    
    return digest

def send_digest_email(user, digest_data):
    """Send digest email to user"""
    
    subject = f"Daily Digest - {today()}"
    
    message = frappe.render_template("templates/emails/daily_digest.html", {
        "user": user,
        "digest": digest_data,
        "date": today()
    })
    
    frappe.sendmail(
        recipients=[user.email],
        subject=subject,
        message=message,
        delayed=True
    )

def send_reminder_notifications():
    """Send reminder notifications for various events"""
    
    # Payment due reminders
    send_payment_due_reminders()
    
    # Contract expiry reminders
    send_contract_expiry_reminders()
    
    # Birthday reminders
    send_birthday_reminders()
    
    # Follow-up reminders
    send_followup_reminders()

def send_payment_due_reminders():
    """Send payment due reminders"""
    
    # Invoices due in 3 days
    due_soon = frappe.get_all("Sales Invoice",
        filters={
            "docstatus": 1,
            "outstanding_amount": [">", 0],
            "due_date": add_days(today(), 3)
        },
        fields=["name", "customer", "outstanding_amount", "due_date"]
    )
    
    for invoice in due_soon:
        customer_email = get_customer_email(invoice.customer)
        if customer_email:
            send_payment_due_notification(invoice, customer_email, days_until_due=3)

def send_contract_expiry_reminders():
    """Send contract expiry reminders"""
    
    # Contracts expiring in 30 days
    expiring_soon = frappe.get_all("Contract",
        filters={
            "status": "Active",
            "end_date": add_days(today(), 30)
        },
        fields=["name", "party_name", "end_date", "contract_value"]
    )
    
    for contract in expiring_soon:
        # Notify account manager
        send_contract_expiry_notification(contract)

def send_escalation_notifications():
    """Send escalation notifications for overdue items"""
    
    # Find overdue support tickets
    overdue_tickets = frappe.get_all("Issue",
        filters={
            "status": ["not in", ["Closed", "Resolved"]],
            "creation": ["<", add_days(today(), -2)]  # Older than 2 days
        },
        fields=["name", "subject", "priority", "assigned_to", "creation"]
    )
    
    for ticket in overdue_tickets:
        days_overdue = (today() - ticket.creation.date()).days
        
        # Escalate based on priority and age
        if ticket.priority == "High" and days_overdue >= 1:
            escalate_to_manager(ticket)
        elif ticket.priority == "Medium" and days_overdue >= 3:
            escalate_to_manager(ticket)
        elif days_overdue >= 7:
            escalate_to_manager(ticket)

# Scheduler configuration (add to hooks.py)
scheduler_events = {
    "cron": {
        "0 9 * * *": [  # Daily at 9 AM
            "app_name.notifications.scheduler.send_daily_digest"
        ],
        "0 10 * * *": [  # Daily at 10 AM
            "app_name.notifications.scheduler.send_reminder_notifications"
        ],
        "0 */4 * * *": [  # Every 4 hours
            "app_name.notifications.scheduler.send_escalation_notifications"
        ]
    }
}
```

---

## 📋 NOTIFICATION CHECKLIST

Before deploying notification features:

- [ ] Configure email server settings
- [ ] Test SMS provider integration
- [ ] Set up push notification keys
- [ ] Create email templates
- [ ] Test notification delivery
- [ ] Add unsubscribe options
- [ ] Implement rate limiting
- [ ] Add delivery tracking
- [ ] Test mobile notifications
- [ ] Configure scheduler events
- [ ] Add notification preferences
- [ ] Test error handling

---

**REMEMBER**: Good notifications inform without overwhelming - always provide value and respect user preferences!