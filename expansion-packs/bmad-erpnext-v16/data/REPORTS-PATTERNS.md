# 🚨 REPORTS PATTERNS - MANDATORY FOR DATA INSIGHTS

## CRITICAL: Proper Reports = Informed Business Decisions

This document contains MANDATORY patterns for creating Script Reports, Query Reports, and Report Builder reports in Frappe/ERPNext.

---

## 🔴 UNDERSTANDING FRAPPE'S REPORT TYPES

### Three Types of Reports:

| Report Type | Use For | Complexity | Performance | Customization |
|------------|---------|------------|-------------|---------------|
| **Report Builder** | Simple lists | Low | Fast | Limited |
| **Query Report** | SQL-based reports | Medium | Very Fast | SQL only |
| **Script Report** | Complex logic | High | Variable | Full Python |

### When to Use Each:

- **Report Builder**: Quick lists, basic filters, no calculations
- **Query Report**: Aggregations, joins, SQL expertise required
- **Script Report**: Complex business logic, API calls, dynamic columns

---

## 🔴 SCRIPT REPORT PATTERNS (MOST FLEXIBLE)

### Script Report Structure:

```python
# [app_name]/[module]/report/[report_name]/[report_name].py

import frappe
from frappe import _
from frappe.utils import flt, getdate, cstr

def execute(filters=None):
    """Main report execution function"""
    
    # 1. Validate filters and permissions
    validate_filters(filters)
    check_permissions()
    
    # 2. Get report columns
    columns = get_columns(filters)
    
    # 3. Get report data
    data = get_data(filters)
    
    # 4. Get report summary (optional)
    report_summary = get_report_summary(data)
    
    # 5. Get chart data (optional)
    chart = get_chart_data(data)
    
    # 6. Add messages (optional)
    messages = get_messages(filters)
    
    return columns, data, messages, chart, report_summary

def validate_filters(filters):
    """Validate report filters"""
    if not filters.get("company"):
        frappe.throw(_("Company is mandatory"))
    
    if filters.get("from_date") and filters.get("to_date"):
        if getdate(filters.from_date) > getdate(filters.to_date):
            frappe.throw(_("From Date cannot be after To Date"))

def check_permissions():
    """Check user permissions"""
    if not frappe.has_permission("Sales Order", "read"):
        frappe.throw(_("Insufficient permissions to access this report"))

def get_columns(filters):
    """Define report columns"""
    columns = [
        {
            "fieldname": "customer",
            "label": _("Customer"),
            "fieldtype": "Link",
            "options": "Customer",
            "width": 200
        },
        {
            "fieldname": "customer_name",
            "label": _("Customer Name"),
            "fieldtype": "Data",
            "width": 200
        },
        {
            "fieldname": "total_orders",
            "label": _("Total Orders"),
            "fieldtype": "Int",
            "width": 120
        },
        {
            "fieldname": "total_amount",
            "label": _("Total Amount"),
            "fieldtype": "Currency",
            "options": "currency",
            "width": 150
        },
        {
            "fieldname": "avg_order_value",
            "label": _("Average Order Value"),
            "fieldtype": "Currency",
            "options": "currency",
            "width": 150
        },
        {
            "fieldname": "last_order_date",
            "label": _("Last Order Date"),
            "fieldtype": "Date",
            "width": 120
        }
    ]
    
    # Add dynamic columns based on filters
    if filters.get("show_territory"):
        columns.append({
            "fieldname": "territory",
            "label": _("Territory"),
            "fieldtype": "Link",
            "options": "Territory",
            "width": 150
        })
    
    return columns

def get_data(filters):
    """Get report data"""
    conditions = get_conditions(filters)
    
    data = frappe.db.sql("""
        SELECT
            so.customer,
            c.customer_name,
            COUNT(DISTINCT so.name) as total_orders,
            SUM(so.grand_total) as total_amount,
            AVG(so.grand_total) as avg_order_value,
            MAX(so.transaction_date) as last_order_date,
            c.territory,
            so.currency
        FROM
            `tabSales Order` so
        INNER JOIN
            `tabCustomer` c ON so.customer = c.name
        WHERE
            so.docstatus = 1
            {conditions}
        GROUP BY
            so.customer
        ORDER BY
            total_amount DESC
    """.format(conditions=conditions), filters, as_dict=1)
    
    # Process data
    for row in data:
        # Add calculations
        row["customer_rank"] = get_customer_rank(row["total_amount"])
        
        # Format values
        row["total_amount"] = flt(row["total_amount"], 2)
        row["avg_order_value"] = flt(row["avg_order_value"], 2)
    
    return data

def get_conditions(filters):
    """Build SQL conditions from filters"""
    conditions = []
    
    if filters.get("company"):
        conditions.append("so.company = %(company)s")
    
    if filters.get("from_date"):
        conditions.append("so.transaction_date >= %(from_date)s")
    
    if filters.get("to_date"):
        conditions.append("so.transaction_date <= %(to_date)s")
    
    if filters.get("customer_group"):
        conditions.append("c.customer_group = %(customer_group)s")
    
    if filters.get("territory"):
        conditions.append("c.territory = %(territory)s")
    
    return " AND " + " AND ".join(conditions) if conditions else ""

def get_customer_rank(amount):
    """Calculate customer rank based on total amount"""
    if amount >= 1000000:
        return "Platinum"
    elif amount >= 500000:
        return "Gold"
    elif amount >= 100000:
        return "Silver"
    else:
        return "Bronze"

def get_report_summary(data):
    """Get report summary cards"""
    if not data:
        return []
    
    total_customers = len(data)
    total_revenue = sum(d.get("total_amount", 0) for d in data)
    total_orders = sum(d.get("total_orders", 0) for d in data)
    
    return [
        {
            "value": total_customers,
            "label": _("Total Customers"),
            "datatype": "Int",
            "indicator": "blue"
        },
        {
            "value": total_revenue,
            "label": _("Total Revenue"),
            "datatype": "Currency",
            "indicator": "green"
        },
        {
            "value": total_orders,
            "label": _("Total Orders"),
            "datatype": "Int",
            "indicator": "orange"
        },
        {
            "value": total_revenue / total_customers if total_customers else 0,
            "label": _("Revenue per Customer"),
            "datatype": "Currency",
            "indicator": "purple"
        }
    ]

def get_chart_data(data):
    """Get chart configuration"""
    if not data:
        return None
    
    # Top 10 customers by revenue
    top_customers = sorted(data, key=lambda x: x.get("total_amount", 0), reverse=True)[:10]
    
    return {
        "data": {
            "labels": [d.get("customer_name") for d in top_customers],
            "datasets": [
                {
                    "name": _("Revenue"),
                    "values": [d.get("total_amount") for d in top_customers]
                }
            ]
        },
        "type": "bar",
        "colors": ["#7cd6fd"],
        "height": 300
    }

def get_messages(filters):
    """Get report messages/warnings"""
    messages = []
    
    if not filters.get("from_date") or not filters.get("to_date"):
        messages.append("Note: Showing all-time data. Set date range for specific period.")
    
    return messages
```

### Script Report Configuration (.js):

```javascript
// [app_name]/[module]/report/[report_name]/[report_name].js

frappe.query_reports["Customer Revenue Analysis"] = {
    "filters": [
        {
            "fieldname": "company",
            "label": __("Company"),
            "fieldtype": "Link",
            "options": "Company",
            "default": frappe.defaults.get_user_default("Company"),
            "reqd": 1
        },
        {
            "fieldname": "from_date",
            "label": __("From Date"),
            "fieldtype": "Date",
            "default": frappe.datetime.add_months(frappe.datetime.get_today(), -1),
            "reqd": 1
        },
        {
            "fieldname": "to_date",
            "label": __("To Date"),
            "fieldtype": "Date",
            "default": frappe.datetime.get_today(),
            "reqd": 1
        },
        {
            "fieldname": "customer_group",
            "label": __("Customer Group"),
            "fieldtype": "Link",
            "options": "Customer Group"
        },
        {
            "fieldname": "territory",
            "label": __("Territory"),
            "fieldtype": "Link",
            "options": "Territory"
        },
        {
            "fieldname": "show_territory",
            "label": __("Show Territory Column"),
            "fieldtype": "Check",
            "default": 0
        }
    ],
    
    "formatter": function(value, row, column, data, default_formatter) {
        value = default_formatter(value, row, column, data);
        
        // Color code based on rank
        if (column.fieldname == "customer_rank") {
            if (data.customer_rank == "Platinum") {
                value = `<span style="color: purple; font-weight: bold">${value}</span>`;
            } else if (data.customer_rank == "Gold") {
                value = `<span style="color: gold; font-weight: bold">${value}</span>`;
            }
        }
        
        // Highlight high value customers
        if (column.fieldname == "total_amount" && data.total_amount > 500000) {
            value = `<span style="color: green; font-weight: bold">${value}</span>`;
        }
        
        return value;
    },
    
    "onload": function(report) {
        // Add custom buttons
        report.page.add_inner_button(__("Export to Excel"), function() {
            frappe.query_report.export_report("xlsx");
        });
        
        report.page.add_inner_button(__("Email Report"), function() {
            frappe.query_report.email_report();
        });
    }
};
```

---

## 🔴 QUERY REPORT PATTERNS (SQL-BASED)

### Query Report SQL:

```sql
-- [app_name]/[module]/report/[report_name]/[report_name].sql

SELECT
    -- Basic fields
    si.posting_date as `Date:Date:100`,
    si.name as `Invoice:Link/Sales Invoice:120`,
    si.customer as `Customer:Link/Customer:150`,
    c.customer_name as `Customer Name:Data:200`,
    
    -- Calculations
    si.grand_total as `Total:Currency/currency:120`,
    si.outstanding_amount as `Outstanding:Currency/currency:120`,
    
    -- Status with color coding
    CASE
        WHEN si.outstanding_amount = 0 THEN 'Paid'
        WHEN si.outstanding_amount = si.grand_total THEN 'Unpaid'
        ELSE 'Partial'
    END as `Status:Data:100`,
    
    -- Aging buckets
    CASE
        WHEN DATEDIFF(CURDATE(), si.due_date) <= 0 THEN 'Current'
        WHEN DATEDIFF(CURDATE(), si.due_date) <= 30 THEN '1-30 Days'
        WHEN DATEDIFF(CURDATE(), si.due_date) <= 60 THEN '31-60 Days'
        WHEN DATEDIFF(CURDATE(), si.due_date) <= 90 THEN '61-90 Days'
        ELSE 'Over 90 Days'
    END as `Aging:Data:120`,
    
    -- Hidden fields for filtering
    si.company as `Company:Link/Company:150`,
    si.currency as `currency:Link/Currency:50`

FROM
    `tabSales Invoice` si
INNER JOIN
    `tabCustomer` c ON si.customer = c.name
    
WHERE
    si.docstatus = 1
    AND si.company = %(company)s
    AND si.posting_date BETWEEN %(from_date)s AND %(to_date)s
    AND (%(customer)s IS NULL OR si.customer = %(customer)s)
    AND si.outstanding_amount > 0
    
ORDER BY
    si.posting_date DESC, si.name DESC
```

### Query Report Configuration:

```json
{
    "report_name": "Accounts Receivable Aging",
    "ref_doctype": "Sales Invoice",
    "report_type": "Query Report",
    "query": "... SQL query above ...",
    "filters": [
        {
            "fieldname": "company",
            "label": "Company",
            "fieldtype": "Link",
            "options": "Company",
            "default": "{company}",
            "reqd": 1
        },
        {
            "fieldname": "from_date",
            "label": "From Date",
            "fieldtype": "Date",
            "default": "{from_date}"
        },
        {
            "fieldname": "to_date",
            "label": "To Date",
            "fieldtype": "Date",
            "default": "{to_date}"
        },
        {
            "fieldname": "customer",
            "label": "Customer",
            "fieldtype": "Link",
            "options": "Customer"
        }
    ]
}
```

---

## 🔴 REPORT BUILDER PATTERNS (SIMPLE)

### Creating Report Builder Report:

1. Go to: **Build → Report**
2. Select DocType
3. Add filters
4. Select columns
5. Save report

### Report Builder Configuration:

```javascript
// Via UI - no code needed, but can be exported as JSON
{
    "name": "Active Customers Report",
    "ref_doctype": "Customer",
    "report_type": "Report Builder",
    "json": {
        "filters": [
            ["Customer", "disabled", "=", 0],
            ["Customer", "customer_type", "=", "Company"]
        ],
        "fields": [
            ["name", "Customer"],
            ["customer_name", "Customer"],
            ["customer_group", "Customer"],
            ["territory", "Customer"],
            ["credit_limit", "Customer"]
        ],
        "order_by": "Customer.customer_name asc",
        "add_totals_row": 0,
        "page_length": 20
    }
}
```

---

## 🔴 ADVANCED REPORT FEATURES

### Drill-Down Reports:

```python
def get_columns(filters):
    """Columns with drill-down links"""
    return [
        {
            "fieldname": "voucher_no",
            "label": _("Voucher"),
            "fieldtype": "Dynamic Link",
            "options": "voucher_type",  # Reference to another column
            "width": 150
        },
        {
            "fieldname": "voucher_type",
            "label": _("Voucher Type"),
            "fieldtype": "Data",
            "width": 120
        }
    ]
```

### Tree Reports:

```python
def execute(filters=None):
    """Tree structure report"""
    columns = get_columns()
    data = []
    
    # Get parent accounts
    parent_accounts = frappe.get_all("Account",
        filters={"is_group": 1, "company": filters.company},
        fields=["name", "parent_account", "account_name"])
    
    for account in parent_accounts:
        # Add parent row
        data.append({
            "account": account.name,
            "account_name": account.account_name,
            "indent": 0,
            "is_group": 1
        })
        
        # Add child accounts
        children = frappe.get_all("Account",
            filters={"parent_account": account.name},
            fields=["name", "account_name", "balance"])
        
        for child in children:
            data.append({
                "account": child.name,
                "account_name": child.account_name,
                "balance": child.balance,
                "indent": 1,
                "parent_account": account.name
            })
    
    return columns, data
```

### Report with Actions:

```javascript
frappe.query_reports["Stock Balance"] = {
    "filters": [...],
    
    "get_datatable_options": function(options) {
        return Object.assign(options, {
            checkboxColumn: true,
            events: {
                onCheckRow: function(data) {
                    // Handle row selection
                    if (data && data.length > 0) {
                        // Enable action buttons
                        report.page.set_primary_action(__("Create PO"), function() {
                            create_purchase_order(data);
                        });
                    }
                }
            }
        });
    }
};

function create_purchase_order(selected_items) {
    frappe.call({
        method: "app.api.create_po_from_items",
        args: {
            items: selected_items
        },
        callback: function(r) {
            if (r.message) {
                frappe.set_route("Form", "Purchase Order", r.message);
            }
        }
    });
}
```

---

## 🔴 PERFORMANCE OPTIMIZATION

### Query Optimization:

```python
def get_data_optimized(filters):
    """Optimized query with proper indexes"""
    
    # Use WITH clause for complex queries
    return frappe.db.sql("""
        WITH monthly_sales AS (
            SELECT
                customer,
                DATE_FORMAT(posting_date, '%Y-%m') as month,
                SUM(grand_total) as total
            FROM `tabSales Invoice`
            WHERE docstatus = 1
                AND company = %(company)s
            GROUP BY customer, month
        )
        SELECT
            ms.customer,
            c.customer_name,
            ms.month,
            ms.total
        FROM monthly_sales ms
        JOIN `tabCustomer` c ON ms.customer = c.name
        ORDER BY ms.customer, ms.month
    """, filters, as_dict=1)
```

### Pagination for Large Reports:

```python
def execute(filters=None):
    """Report with pagination"""
    page = filters.get("page", 1)
    page_length = 100
    
    # Get total count
    total_count = frappe.db.count("Sales Order", filters)
    
    # Get paginated data
    data = frappe.get_all("Sales Order",
        filters=filters,
        fields=["*"],
        limit_start=(page - 1) * page_length,
        limit_page_length=page_length
    )
    
    # Add pagination info
    report_summary = [{
        "value": f"Page {page} of {math.ceil(total_count/page_length)}",
        "label": "Pagination",
        "datatype": "Data"
    }]
    
    return columns, data, None, None, report_summary
```

---

## 🔴 REPORT PERMISSIONS

### Permission Check in Report:

```python
def check_permissions():
    """Check report access permissions"""
    
    # Role-based check
    if not frappe.has_role(["Accounts User", "Accounts Manager"]):
        frappe.throw(_("You don't have permission to access this report"))
    
    # Document-level check
    if not frappe.has_permission("Sales Invoice", "report"):
        frappe.throw(_("Insufficient permissions"))
    
    # Custom permission logic
    user_company = frappe.db.get_value("User Permission", 
        {"user": frappe.session.user, "allow": "Company"}, 
        "for_value")
    
    if user_company and filters.get("company") != user_company:
        frappe.throw(_("You can only view reports for {0}").format(user_company))
```

---

## 📋 REPORT CHECKLIST

Before deploying reports:

- [ ] Validate all filters
- [ ] Check user permissions
- [ ] Optimize SQL queries
- [ ] Add proper indexes
- [ ] Test with large datasets
- [ ] Format currency/date fields
- [ ] Add drill-down links
- [ ] Include summary cards
- [ ] Add chart visualization
- [ ] Test export functionality
- [ ] Document report purpose
- [ ] Add help text for filters

---

**REMEMBER**: Reports should be fast, accurate, and provide actionable insights!