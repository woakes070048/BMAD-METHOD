# 🚨 PRINT FORMATS & PDF PATTERNS - DOCUMENT GENERATION

## CRITICAL: Professional Documents = Business Credibility

This document contains MANDATORY patterns for creating Print Formats, generating PDFs, and managing document templates in Frappe/ERPNext.

---

## 🔴 UNDERSTANDING FRAPPE'S PRINTING SYSTEM

### Print Format Types:

| Type | Use For | Complexity | Customization | Performance |
|------|---------|------------|---------------|-------------|
| **Standard** | Basic layouts | Low | Limited | Fast |
| **Modern** | Responsive designs | Medium | Good | Good |
| **Classic** | Traditional formats | Medium | Limited | Fast |
| **Custom** | Full control | High | Complete | Variable |

### Document Generation Flow:

1. **Print Format** - Template definition
2. **Letter Head** - Company branding
3. **Print Style** - CSS styling
4. **PDF Generation** - Server-side rendering
5. **Email/Download** - Delivery methods

---

## 🔴 PRINT FORMAT CREATION PATTERNS

### Standard Print Format Pattern:

```json
{
    "name": "Sales Invoice Modern",
    "doctype": "Print Format",
    "doc_type": "Sales Invoice",
    "format_data": [
        {
            "fieldname": "print_heading",
            "fieldtype": "Data",
            "label": "Invoice"
        },
        {
            "fieldname": "company_address",
            "fieldtype": "Section Break",
            "label": "Company Details"
        },
        {
            "fieldname": "customer_details",
            "fieldtype": "Section Break", 
            "label": "Bill To"
        },
        {
            "fieldname": "items",
            "fieldtype": "Table",
            "label": "Items",
            "print_hide": 0,
            "columns": [
                {"fieldname": "item_code", "label": "Item", "width": "30%"},
                {"fieldname": "description", "label": "Description", "width": "40%"},
                {"fieldname": "qty", "label": "Qty", "width": "10%"},
                {"fieldname": "rate", "label": "Rate", "width": "10%"},
                {"fieldname": "amount", "label": "Amount", "width": "10%"}
            ]
        },
        {
            "fieldname": "totals_section",
            "fieldtype": "Section Break",
            "label": "Totals"
        }
    ],
    "print_format_builder": 1,
    "print_format_type": "Jinja"
}
```

### Custom HTML Print Format:

```html
<!-- Custom Print Format using Jinja -->
{% set company = frappe.get_doc("Company", doc.company) %}

<div class="invoice-container">
    <!-- Header Section -->
    <div class="invoice-header">
        <div class="company-logo">
            {% if letter_head and letter_head.image %}
                <img src="{{ letter_head.image }}" style="height: 60px;">
            {% endif %}
        </div>
        <div class="company-details">
            <h2>{{ company.company_name }}</h2>
            <p>{{ company.address_line_1 }}<br>
               {{ company.city }}, {{ company.state }} {{ company.pincode }}<br>
               Phone: {{ company.phone_no }}<br>
               Email: {{ company.email_id }}</p>
        </div>
        <div class="invoice-title">
            <h1>INVOICE</h1>
            <p><strong>{{ doc.name }}</strong></p>
        </div>
    </div>

    <!-- Invoice Info -->
    <div class="invoice-info">
        <div class="invoice-meta">
            <table>
                <tr>
                    <td><strong>Date:</strong></td>
                    <td>{{ frappe.utils.formatdate(doc.posting_date) }}</td>
                </tr>
                <tr>
                    <td><strong>Due Date:</strong></td>
                    <td>{{ frappe.utils.formatdate(doc.due_date) }}</td>
                </tr>
                <tr>
                    <td><strong>Terms:</strong></td>
                    <td>{{ doc.payment_terms_template or "Net 30" }}</td>
                </tr>
            </table>
        </div>
        
        <!-- Customer Details -->
        <div class="customer-details">
            <h4>Bill To:</h4>
            {% set customer = frappe.get_doc("Customer", doc.customer) %}
            <p><strong>{{ customer.customer_name }}</strong><br>
               {% if doc.customer_address %}
                   {% set address = frappe.get_doc("Address", doc.customer_address) %}
                   {{ address.address_line1 }}<br>
                   {% if address.address_line2 %}{{ address.address_line2 }}<br>{% endif %}
                   {{ address.city }}, {{ address.state }} {{ address.pincode }}<br>
                   {{ address.country }}
               {% endif %}
            </p>
        </div>
    </div>

    <!-- Items Table -->
    <table class="items-table">
        <thead>
            <tr>
                <th style="width: 30%">Item</th>
                <th style="width: 40%">Description</th>
                <th style="width: 10%; text-align: center">Qty</th>
                <th style="width: 10%; text-align: right">Rate</th>
                <th style="width: 10%; text-align: right">Amount</th>
            </tr>
        </thead>
        <tbody>
            {% for item in doc.items %}
            <tr>
                <td>{{ item.item_code }}</td>
                <td>{{ item.description or item.item_name }}</td>
                <td style="text-align: center">{{ frappe.utils.fmt_money(item.qty, 0) }}</td>
                <td style="text-align: right">{{ frappe.utils.fmt_money(item.rate, 2, doc.currency) }}</td>
                <td style="text-align: right">{{ frappe.utils.fmt_money(item.amount, 2, doc.currency) }}</td>
            </tr>
            {% endfor %}
        </tbody>
    </table>

    <!-- Totals Section -->
    <div class="totals-section">
        <table class="totals-table">
            <tr>
                <td><strong>Subtotal:</strong></td>
                <td style="text-align: right">{{ frappe.utils.fmt_money(doc.total, 2, doc.currency) }}</td>
            </tr>
            {% for tax in doc.taxes %}
            <tr>
                <td>{{ tax.description }}:</td>
                <td style="text-align: right">{{ frappe.utils.fmt_money(tax.tax_amount, 2, doc.currency) }}</td>
            </tr>
            {% endfor %}
            <tr class="grand-total">
                <td><strong>Total:</strong></td>
                <td style="text-align: right"><strong>{{ frappe.utils.fmt_money(doc.grand_total, 2, doc.currency) }}</strong></td>
            </tr>
        </tbody>
    </table>

    <!-- Footer -->
    <div class="invoice-footer">
        {% if doc.terms %}
        <div class="terms">
            <h4>Terms & Conditions:</h4>
            <p>{{ doc.terms }}</p>
        </div>
        {% endif %}
        
        <div class="payment-info">
            <h4>Payment Information:</h4>
            <p>Please make payment within {{ doc.payment_terms_template or "30 days" }}.<br>
               Include invoice number {{ doc.name }} with payment.</p>
        </div>
    </div>
</div>

<style>
.invoice-container {
    font-family: Arial, sans-serif;
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
}

.invoice-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    border-bottom: 2px solid #333;
    padding-bottom: 20px;
    margin-bottom: 20px;
}

.company-details h2 {
    margin: 0 0 10px 0;
    color: #333;
}

.invoice-title {
    text-align: right;
}

.invoice-title h1 {
    margin: 0;
    color: #e74c3c;
    font-size: 2.5em;
}

.invoice-info {
    display: flex;
    justify-content: space-between;
    margin-bottom: 30px;
}

.invoice-meta table td {
    padding: 5px 20px 5px 0;
}

.items-table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 30px;
}

.items-table th,
.items-table td {
    padding: 12px;
    border-bottom: 1px solid #ddd;
}

.items-table th {
    background-color: #f8f9fa;
    font-weight: bold;
    text-align: left;
}

.totals-section {
    display: flex;
    justify-content: flex-end;
}

.totals-table {
    width: 300px;
}

.totals-table td {
    padding: 8px;
    border-bottom: 1px solid #eee;
}

.grand-total {
    border-top: 2px solid #333;
    font-size: 1.2em;
}

.invoice-footer {
    margin-top: 40px;
    border-top: 1px solid #eee;
    padding-top: 20px;
}

.terms,
.payment-info {
    margin-bottom: 20px;
}

@media print {
    .invoice-container {
        padding: 0;
    }
}
</style>
```

---

## 🔴 LETTER HEAD PATTERNS

### Creating Letter Head:

```json
{
    "name": "Company Letterhead",
    "doctype": "Letter Head",
    "letter_head_name": "Default",
    "is_default": 1,
    "image": "/files/company_logo.png",
    "content": """
    <div style="text-align: center; border-bottom: 3px solid #e74c3c; padding-bottom: 10px;">
        <img src="/files/company_logo.png" style="height: 60px; margin-bottom: 10px;">
        <h2 style="margin: 0; color: #2c3e50;">{{ company }}</h2>
        <p style="margin: 5px 0; color: #7f8c8d;">
            {{ address_line1 }}, {{ city }}, {{ state }} {{ pincode }}<br>
            Phone: {{ phone_no }} | Email: {{ email_id }} | Website: {{ website }}
        </p>
    </div>
    """,
    "footer": """
    <div style="text-align: center; border-top: 1px solid #bdc3c7; padding-top: 10px; margin-top: 20px; font-size: 12px; color: #7f8c8d;">
        <p>Thank you for your business! | {{ company }} | {{ phone_no }}</p>
    </div>
    """
}
```

### Dynamic Letter Head with Jinja:

```html
<!-- Letter Head with conditional content -->
<div class="letterhead">
    {% if image %}
        <img src="{{ image }}" class="company-logo">
    {% endif %}
    
    <div class="company-info">
        <h1>{{ company }}</h1>
        {% if tagline %}
            <p class="tagline">{{ tagline }}</p>
        {% endif %}
        
        <div class="contact-info">
            {% if address_line1 %}
                <p>{{ address_line1 }}{% if address_line2 %}, {{ address_line2 }}{% endif %}</p>
                <p>{{ city }}, {{ state }} {{ pincode }}</p>
            {% endif %}
            
            {% if phone_no or email_id %}
                <p>
                    {% if phone_no %}Phone: {{ phone_no }}{% endif %}
                    {% if phone_no and email_id %} | {% endif %}
                    {% if email_id %}Email: {{ email_id }}{% endif %}
                </p>
            {% endif %}
        </div>
    </div>
</div>

<style>
.letterhead {
    text-align: center;
    border-bottom: 3px solid #3498db;
    padding-bottom: 20px;
    margin-bottom: 30px;
}

.company-logo {
    max-height: 80px;
    margin-bottom: 15px;
}

.company-info h1 {
    margin: 0 0 5px 0;
    color: #2c3e50;
    font-size: 2.2em;
}

.tagline {
    font-style: italic;
    color: #7f8c8d;
    margin: 0 0 15px 0;
}

.contact-info {
    font-size: 0.9em;
    color: #34495e;
}

.contact-info p {
    margin: 5px 0;
}
</style>
```

---

## 🔴 PDF GENERATION PATTERNS

### Programmatic PDF Generation:

```python
# Generate PDF from Print Format
import frappe
from frappe.utils.pdf import get_pdf

def generate_invoice_pdf(sales_invoice_name):
    """Generate PDF for Sales Invoice"""
    
    # Get document
    doc = frappe.get_doc("Sales Invoice", sales_invoice_name)
    
    # Check permissions
    if not frappe.has_permission("Sales Invoice", "read", doc.name):
        frappe.throw(_("Insufficient permissions"))
    
    # Get print format
    print_format = frappe.get_doc("Print Format", "Sales Invoice Modern")
    
    # Generate HTML
    html = frappe.get_print(
        doctype="Sales Invoice",
        name=sales_invoice_name,
        print_format="Sales Invoice Modern",
        letterhead=True
    )
    
    # Generate PDF
    pdf = get_pdf(html)
    
    # Save as file
    file_doc = frappe.get_doc({
        "doctype": "File",
        "file_name": f"Invoice_{sales_invoice_name}.pdf",
        "content": pdf,
        "is_private": 1,
        "attached_to_doctype": "Sales Invoice",
        "attached_to_name": sales_invoice_name
    })
    file_doc.insert()
    
    return file_doc.file_url

@frappe.whitelist()
def email_invoice_pdf(sales_invoice_name, recipients):
    """Email invoice PDF to recipients"""
    
    # Generate PDF
    pdf_url = generate_invoice_pdf(sales_invoice_name)
    
    # Get document
    doc = frappe.get_doc("Sales Invoice", sales_invoice_name)
    
    # Send email
    frappe.sendmail(
        recipients=recipients,
        subject=f"Invoice {doc.name} from {doc.company}",
        message=f"""
        <p>Dear Customer,</p>
        <p>Please find attached your invoice {doc.name} for the amount of 
           {frappe.utils.fmt_money(doc.grand_total, 2, doc.currency)}.</p>
        <p>Thank you for your business!</p>
        <p>Best regards,<br>{doc.company}</p>
        """,
        attachments=[{
            "fname": f"Invoice_{doc.name}.pdf",
            "fcontent": frappe.get_file(pdf_url).get_content()
        }]
    )
    
    return {"success": True, "message": "Invoice emailed successfully"}
```

### Bulk PDF Generation:

```python
def generate_bulk_invoices(filters):
    """Generate PDFs for multiple invoices"""
    
    # Get invoices
    invoices = frappe.get_all("Sales Invoice",
        filters=filters,
        fields=["name", "customer", "grand_total"]
    )
    
    # Create zip file with all PDFs
    import zipfile
    import io
    
    zip_buffer = io.BytesIO()
    
    with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zip_file:
        for invoice in invoices:
            try:
                # Generate PDF
                html = frappe.get_print(
                    doctype="Sales Invoice",
                    name=invoice.name,
                    print_format="Sales Invoice Modern"
                )
                pdf = get_pdf(html)
                
                # Add to zip
                zip_file.writestr(f"Invoice_{invoice.name}.pdf", pdf)
                
            except Exception as e:
                frappe.log_error(f"Failed to generate PDF for {invoice.name}: {str(e)}")
    
    # Save zip file
    zip_content = zip_buffer.getvalue()
    
    file_doc = frappe.get_doc({
        "doctype": "File",
        "file_name": f"Invoices_Bulk_{frappe.utils.today()}.zip",
        "content": zip_content,
        "is_private": 1
    })
    file_doc.insert()
    
    return file_doc.file_url
```

---

## 🔴 PRINT STYLE PATTERNS

### Custom Print CSS:

```css
/* Custom Print Style */
@media screen {
    .print-format {
        max-width: 21cm;
        margin: 0 auto;
        background: white;
        box-shadow: 0 0 10px rgba(0,0,0,0.1);
        padding: 1cm;
    }
}

@media print {
    body { margin: 0; }
    .print-format { 
        box-shadow: none; 
        padding: 0;
    }
    .no-print { display: none !important; }
}

/* Typography */
.print-format {
    font-family: 'Helvetica Neue', Arial, sans-serif;
    font-size: 11pt;
    line-height: 1.4;
    color: #333;
}

.print-format h1 { 
    font-size: 24pt; 
    margin: 0 0 10pt 0;
    color: #2c3e50;
}

.print-format h2 { 
    font-size: 16pt; 
    margin: 15pt 0 8pt 0;
    color: #34495e;
}

.print-format h3 { 
    font-size: 12pt; 
    margin: 10pt 0 5pt 0;
    color: #34495e;
}

/* Tables */
.print-format table {
    width: 100%;
    border-collapse: collapse;
    margin: 10pt 0;
}

.print-format table th {
    background-color: #ecf0f1;
    font-weight: bold;
    padding: 8pt;
    border: 1pt solid #bdc3c7;
    text-align: left;
}

.print-format table td {
    padding: 6pt 8pt;
    border: 1pt solid #bdc3c7;
    vertical-align: top;
}

.print-format table tr:nth-child(even) {
    background-color: #f8f9fa;
}

/* Numbers and Currency */
.text-right { text-align: right; }
.text-center { text-align: center; }
.currency { font-family: 'Courier New', monospace; }

/* Signatures */
.signature-section {
    margin-top: 40pt;
    border-top: 1pt solid #bdc3c7;
    padding-top: 20pt;
}

.signature-box {
    display: inline-block;
    width: 200pt;
    text-align: center;
    margin: 0 20pt;
}

.signature-line {
    border-bottom: 1pt solid #333;
    height: 30pt;
    margin-bottom: 5pt;
}

/* Footer */
.print-footer {
    position: fixed;
    bottom: 1cm;
    left: 0;
    right: 0;
    text-align: center;
    font-size: 9pt;
    color: #7f8c8d;
}

/* Page breaks */
.page-break {
    page-break-before: always;
}

.avoid-break {
    page-break-inside: avoid;
}
```

---

## 🔴 DYNAMIC CONTENT PATTERNS

### Conditional Content Display:

```html
<!-- Conditional sections based on document data -->
{% if doc.discount_amount > 0 %}
<div class="discount-section">
    <h4>Discount Applied</h4>
    <p>Discount: {{ frappe.utils.fmt_money(doc.discount_amount, 2, doc.currency) }}
       ({{ doc.additional_discount_percentage }}%)</p>
</div>
{% endif %}

{% if doc.payment_schedule %}
<div class="payment-schedule">
    <h4>Payment Schedule</h4>
    <table>
        <tr>
            <th>Due Date</th>
            <th>Amount</th>
            <th>Status</th>
        </tr>
        {% for payment in doc.payment_schedule %}
        <tr>
            <td>{{ frappe.utils.formatdate(payment.due_date) }}</td>
            <td>{{ frappe.utils.fmt_money(payment.payment_amount, 2, doc.currency) }}</td>
            <td>{{ payment.status or "Pending" }}</td>
        </tr>
        {% endfor %}
    </table>
</div>
{% endif %}

<!-- Multi-language support -->
{% set lang = frappe.local.lang %}
{% if lang == "hi" %}
    <p>धन्यवाद!</p>
{% elif lang == "es" %}
    <p>¡Gracias!</p>
{% else %}
    <p>Thank you!</p>
{% endif %}
```

### Data Calculations in Templates:

```html
<!-- Calculate totals and percentages -->
{% set item_count = doc.items|length %}
{% set avg_rate = (doc.total / item_count) if item_count > 0 else 0 %}

<div class="summary-stats">
    <p>Total Items: {{ item_count }}</p>
    <p>Average Rate: {{ frappe.utils.fmt_money(avg_rate, 2, doc.currency) }}</p>
    
    {% if doc.taxes %}
        {% set total_tax = doc.taxes|sum(attribute='tax_amount') %}
        {% set tax_percentage = (total_tax / doc.total * 100) if doc.total > 0 else 0 %}
        <p>Total Tax: {{ frappe.utils.fmt_money(total_tax, 2, doc.currency) }} 
           ({{ "%.1f"|format(tax_percentage) }}%)</p>
    {% endif %}
</div>

<!-- Format dates and numbers -->
<p>Invoice Date: {{ doc.posting_date.strftime('%B %d, %Y') }}</p>
<p>Amount in Words: {{ frappe.utils.money_in_words(doc.grand_total, doc.currency) }}</p>
```

---

## 🔴 ADVANCED PRINT FORMAT FEATURES

### QR Code Integration:

```html
<!-- Add QR code to invoice -->
{% set qr_data = doc.name + "|" + doc.customer + "|" + str(doc.grand_total) %}
<div class="qr-code">
    <img src="/api/method/frappe.utils.qr.generate_qr?text={{ qr_data }}" 
         style="width: 100px; height: 100px;">
    <p>Scan for verification</p>
</div>
```

### Barcode Integration:

```html
<!-- Add barcode -->
<div class="barcode">
    <img src="/api/method/frappe.utils.barcode.generate?text={{ doc.name }}&format=code128" 
         style="height: 50px;">
    <p>{{ doc.name }}</p>
</div>
```

### Multi-page Layout:

```html
<!-- Page headers and footers -->
<div class="page-header">
    <h3>{{ doc.company }} - {{ doc.doctype }} {{ doc.name }}</h3>
</div>

<div class="page-content">
    <!-- Main content here -->
    
    {% if doc.items|length > 20 %}
        <div class="page-break"></div>
        <h3>Items Continued...</h3>
    {% endif %}
</div>

<div class="page-footer">
    <p>Page <span class="page-number"></span> of <span class="total-pages"></span></p>
    <p>Generated on {{ frappe.utils.format_datetime(frappe.utils.now()) }}</p>
</div>
```

---

## 🔴 PERFORMANCE OPTIMIZATION

### Efficient Template Patterns:

```html
<!-- Cache expensive operations -->
{% set customer_doc = frappe.get_doc("Customer", doc.customer) %}
{% set address_doc = frappe.get_doc("Address", doc.customer_address) if doc.customer_address else None %}

<!-- Use get_value for single fields -->
{% set territory_name = frappe.db.get_value("Territory", customer_doc.territory, "territory_name") %}

<!-- Optimize loops -->
{% for item in doc.items %}
    <!-- Pre-calculate in template if needed -->
    {% set item_total = item.qty * item.rate %}
    <tr>
        <td>{{ item.item_code }}</td>
        <td>{{ item_total }}</td>
    </tr>
{% endfor %}
```

---

## 📋 PRINT FORMAT CHECKLIST

Before deploying print formats:

- [ ] Test with sample data
- [ ] Check all conditional sections
- [ ] Verify currency formatting
- [ ] Test multi-page documents
- [ ] Check mobile responsiveness
- [ ] Validate Jinja syntax
- [ ] Test PDF generation
- [ ] Verify letter head integration
- [ ] Check print preview
- [ ] Test email attachments
- [ ] Validate permissions
- [ ] Check performance with large docs

---

**REMEMBER**: Print formats represent your business - make them professional and error-free!