# Stage 4: Developer Guide
## Task Implementation and Technical Execution

### Role Overview

As a Developer, you transform user stories and tasks into working ERPNext features. You implement business logic, create user interfaces, ensure data integrity, and maintain code quality while following Frappe Framework best practices and ERPNext development standards.

### Key Responsibilities

1. **Task Implementation**: Convert tasks into working code
2. **Code Quality**: Write clean, maintainable, tested code  
3. **Framework Compliance**: Follow Frappe/ERPNext patterns
4. **Integration**: Ensure compatibility with existing systems
5. **Documentation**: Document code and functionality

## 🚀 BMAD Commands for Developers

### Quick Start Commands

```bash
# 1. DocType Development
npx bmad-method activate:agent bmad-erpnext-v15 doctype-designer
*create-doctype Customer_Portal_Settings

# 2. API Development
npx bmad-method activate:agent bmad-erpnext-v15 api-developer
*create-api customer
*create-api-endpoint get_customer_orders

# 3. Vue Frontend Development  
npx bmad-method activate:agent bmad-erpnext-v15 vue-frontend-architect
*setup-vue-spa
*create-component CustomerDashboard

# 4. Complete App Creation
npx bmad-method run:task bmad-erpnext-v15 create-vue-spa --app-name customer_portal
```

### Command Reference for Each Development Phase

#### Phase 1: Backend Development
```bash
# Create DocTypes
npx bmad-method run:task bmad-erpnext-v15 create-doctype

# Create API module  
npx bmad-method run:task bmad-erpnext-v15 create-api-module --module customer

# Create specific API endpoints
npx bmad-method run:task bmad-erpnext-v15 create-api-endpoint --name get_orders
```

#### Phase 2: Frontend Development
```bash
# Setup Vue SPA with Frappe UI
npx bmad-method run:task bmad-erpnext-v15 setup-frappe-ui --app-name customer_portal

# Create Vue components
npx bmad-method run:task bmad-erpnext-v15 create-vue-components

# Add PWA support
npx bmad-method run:task bmad-erpnext-v15 implement-pwa --app-name customer_portal
```

#### Phase 3: Testing & Deployment
```bash
# Create unit tests
npx bmad-method run:task bmad-erpnext-v15 create-unit-tests

# Run all tests
npx bmad-method run:task bmad-erpnext-v15 run-tests

# Build frontend assets
npx bmad-method run:task bmad-erpnext-v15 build-frontend

# Install app on site
npx bmad-method run:task bmad-erpnext-v15 install-app --app-name customer_portal
```

#### Phase 4: Advanced Features
```bash
# Setup workflows
npx bmad-method run:task bmad-erpnext-v15 setup-workflow

# Integrate with docflow
npx bmad-method run:task bmad-erpnext-v15 integrate-docflow

# Setup n8n triggers
npx bmad-method run:task bmad-erpnext-v15 setup-n8n-triggers
```

## Development Environment Setup

### Step 1: Bench Environment

#### 1.1 Initial Setup

```bash
# Install Frappe Bench
pip3 install frappe-bench

# Initialize bench
bench init frappe-bench --frappe-branch version-15

# Create new site
cd frappe-bench
bench new-site erp.local
bench use erp.local

# Get ERPNext
bench get-app erpnext --branch version-15
bench --site erp.local install-app erpnext

# Get custom apps
bench get-app docflow
bench get-app n8n_integration
bench --site erp.local install-app docflow
bench --site erp.local install-app n8n_integration

# Start development server
bench start
```

#### 1.2 Development Tools

**Essential VS Code Extensions:**
```json
{
  "recommendations": [
    "ms-python.python",
    "ms-python.vscode-pylance",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "octref.vetur",
    "vue.volar",
    "redhat.vscode-yaml",
    "yzhang.markdown-all-in-one"
  ]
}
```

**Git Configuration:**
```bash
# Configure git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Create feature branch
git checkout -b feature/story-1-1-user-login

# Set up pre-commit hooks
pip install pre-commit
pre-commit install
```

## Task Implementation Process

### Step 2: DocType Development

#### 2.1 Creating a New DocType

**Using Bench Command:**
```bash
bench new-doctype "Customer Portal Settings"
```

**DocType Definition (JSON):**
```json
{
  "name": "Customer Portal Settings",
  "module": "Customer",
  "custom": 1,
  "naming": "field:customer",
  "fields": [
    {
      "fieldname": "customer",
      "fieldtype": "Link",
      "label": "Customer",
      "options": "Customer",
      "reqd": 1,
      "unique": 1
    },
    {
      "fieldname": "portal_user",
      "fieldtype": "Link",
      "label": "Portal User",
      "options": "User",
      "reqd": 1
    },
    {
      "fieldname": "access_level",
      "fieldtype": "Select",
      "label": "Access Level",
      "options": "Basic\nStandard\nPremium",
      "default": "Basic"
    },
    {
      "fieldname": "enabled",
      "fieldtype": "Check",
      "label": "Enabled",
      "default": 1
    },
    {
      "fieldname": "section_break_1",
      "fieldtype": "Section Break",
      "label": "Access Permissions"
    },
    {
      "fieldname": "can_view_orders",
      "fieldtype": "Check",
      "label": "Can View Orders"
    },
    {
      "fieldname": "can_download_invoices",
      "fieldtype": "Check",
      "label": "Can Download Invoices"
    }
  ],
  "permissions": [
    {
      "role": "System Manager",
      "read": 1,
      "write": 1,
      "create": 1,
      "delete": 1
    },
    {
      "role": "Customer",
      "read": 1,
      "write": 0,
      "if_owner": 1
    }
  ],
  "track_changes": 1,
  "sort_field": "modified",
  "sort_order": "DESC"
}
```

#### 2.2 Controller Implementation

**Python Controller (customer_portal_settings.py):**
```python
import frappe
from frappe.model.document import Document
from frappe import _

class CustomerPortalSettings(Document):
    def validate(self):
        """Validate portal settings before save"""
        self.validate_customer()
        self.validate_user()
        self.set_access_permissions()
    
    def validate_customer(self):
        """Ensure customer exists and is enabled"""
        if not frappe.db.exists("Customer", self.customer):
            frappe.throw(_("Customer {0} does not exist").format(self.customer))
        
        customer = frappe.get_doc("Customer", self.customer)
        if customer.disabled:
            frappe.throw(_("Customer {0} is disabled").format(self.customer))
    
    def validate_user(self):
        """Ensure user exists and has customer role"""
        if not frappe.db.exists("User", self.portal_user):
            frappe.throw(_("User {0} does not exist").format(self.portal_user))
        
        user = frappe.get_doc("User", self.portal_user)
        if "Customer" not in [r.role for r in user.roles]:
            frappe.throw(_("User {0} does not have Customer role").format(
                self.portal_user
            ))
    
    def set_access_permissions(self):
        """Set permissions based on access level"""
        access_mapping = {
            "Basic": {
                "can_view_orders": 1,
                "can_download_invoices": 0
            },
            "Standard": {
                "can_view_orders": 1,
                "can_download_invoices": 1
            },
            "Premium": {
                "can_view_orders": 1,
                "can_download_invoices": 1
            }
        }
        
        if self.access_level in access_mapping:
            permissions = access_mapping[self.access_level]
            for field, value in permissions.items():
                setattr(self, field, value)
    
    def on_update(self):
        """Actions to perform after saving"""
        self.update_user_permissions()
        self.clear_cache()
    
    def update_user_permissions(self):
        """Update user permissions based on settings"""
        # Add user permission for customer
        if not frappe.db.exists("User Permission", {
            "user": self.portal_user,
            "allow": "Customer",
            "for_value": self.customer
        }):
            frappe.get_doc({
                "doctype": "User Permission",
                "user": self.portal_user,
                "allow": "Customer",
                "for_value": self.customer
            }).insert(ignore_permissions=True)
    
    def clear_cache(self):
        """Clear relevant caches"""
        frappe.clear_cache(user=self.portal_user)
        frappe.publish_realtime("portal_settings_updated", {
            "customer": self.customer,
            "user": self.portal_user
        })

    @frappe.whitelist()
    def get_portal_access(self):
        """Get portal access details for current user"""
        return {
            "access_level": self.access_level,
            "can_view_orders": self.can_view_orders,
            "can_download_invoices": self.can_download_invoices,
            "enabled": self.enabled
        }
```

### Step 3: API Development

#### 3.1 Creating Whitelisted API Endpoints

**API Module (api.py):**
```python
import frappe
from frappe import _
from frappe.utils import cint, getdate, nowdate
import json

@frappe.whitelist()
def get_customer_orders(filters=None, page_length=20, page_start=0):
    """
    Get customer orders for portal
    
    Args:
        filters: JSON string of filters
        page_length: Number of records per page
        page_start: Starting record number
    
    Returns:
        Dictionary with orders and metadata
    """
    # Check authentication
    if frappe.session.user == "Guest":
        frappe.throw(_("Authentication required"), frappe.AuthenticationError)
    
    # Get customer for current user
    customer = get_customer_for_user()
    if not customer:
        frappe.throw(_("No customer linked to user"))
    
    # Check portal access
    portal_settings = frappe.get_value(
        "Customer Portal Settings",
        {"customer": customer, "portal_user": frappe.session.user},
        ["enabled", "can_view_orders"],
        as_dict=True
    )
    
    if not portal_settings or not portal_settings.enabled:
        frappe.throw(_("Portal access not enabled"))
    
    if not portal_settings.can_view_orders:
        frappe.throw(_("You don't have permission to view orders"))
    
    # Parse filters
    if filters:
        filters = json.loads(filters)
    else:
        filters = {}
    
    # Add customer filter
    filters["customer"] = customer
    filters["docstatus"] = 1  # Only submitted orders
    
    # Get orders
    orders = frappe.get_list(
        "Sales Order",
        fields=[
            "name", "transaction_date", "delivery_date",
            "total", "status", "currency"
        ],
        filters=filters,
        order_by="transaction_date desc",
        limit_page_length=page_length,
        limit_start=page_start
    )
    
    # Get total count
    total_count = frappe.db.count("Sales Order", filters)
    
    # Enhance order data
    for order in orders:
        order["items_count"] = frappe.db.count(
            "Sales Order Item",
            {"parent": order.name}
        )
        order["can_download"] = portal_settings.get("can_download_invoices", 0)
    
    return {
        "orders": orders,
        "total": total_count,
        "page_length": page_length,
        "page_start": page_start
    }

@frappe.whitelist()
def get_order_details(order_id):
    """Get detailed information for a specific order"""
    # Validate access
    customer = get_customer_for_user()
    if not customer:
        frappe.throw(_("No customer linked to user"))
    
    # Check if order belongs to customer
    order = frappe.get_doc("Sales Order", order_id)
    if order.customer != customer:
        frappe.throw(_("You don't have permission to view this order"))
    
    # Return order details
    return {
        "order": order.as_dict(),
        "items": [item.as_dict() for item in order.items],
        "taxes": [tax.as_dict() for tax in order.taxes],
        "payment_schedule": [
            payment.as_dict() for payment in order.payment_schedule
        ] if hasattr(order, 'payment_schedule') else []
    }

@frappe.whitelist()
def download_invoice(invoice_id):
    """Download invoice PDF"""
    # Check permissions
    customer = get_customer_for_user()
    portal_settings = frappe.get_value(
        "Customer Portal Settings",
        {"customer": customer, "portal_user": frappe.session.user},
        "can_download_invoices"
    )
    
    if not portal_settings:
        frappe.throw(_("You don't have permission to download invoices"))
    
    # Verify invoice belongs to customer
    invoice_customer = frappe.db.get_value(
        "Sales Invoice", invoice_id, "customer"
    )
    if invoice_customer != customer:
        frappe.throw(_("You don't have permission to download this invoice"))
    
    # Generate PDF
    pdf = frappe.get_print(
        "Sales Invoice", invoice_id, print_format="Standard", as_pdf=True
    )
    
    # Return PDF
    frappe.local.response.filename = f"invoice_{invoice_id}.pdf"
    frappe.local.response.filecontent = pdf
    frappe.local.response.type = "pdf"

def get_customer_for_user():
    """Get customer linked to current user"""
    # Check if user has direct customer link
    customer = frappe.db.get_value(
        "Contact",
        {"user": frappe.session.user},
        "link_name"
    )
    
    if not customer:
        # Check portal settings
        customer = frappe.db.get_value(
            "Customer Portal Settings",
            {"portal_user": frappe.session.user, "enabled": 1},
            "customer"
        )
    
    return customer
```

### Step 4: Frontend Development

#### 4.1 Vue.js Component Development

**OrderList.vue Component:**
```vue
<template>
  <div class="order-list-container">
    <div class="order-filters">
      <input
        v-model="searchTerm"
        type="text"
        placeholder="Search orders..."
        class="form-control"
        @input="debouncedSearch"
      >
      
      <select v-model="statusFilter" @change="filterOrders" class="form-control">
        <option value="">All Status</option>
        <option value="Draft">Draft</option>
        <option value="Submitted">Submitted</option>
        <option value="Delivered">Delivered</option>
      </select>
    </div>

    <div v-if="loading" class="text-center">
      <div class="spinner-border" role="status">
        <span class="sr-only">Loading...</span>
      </div>
    </div>

    <div v-else-if="orders.length === 0" class="empty-state">
      <i class="fa fa-shopping-cart fa-3x"></i>
      <p>No orders found</p>
    </div>

    <div v-else class="order-list">
      <div v-for="order in orders" :key="order.name" class="order-card">
        <div class="order-header">
          <h5>{{ order.name }}</h5>
          <span :class="getStatusClass(order.status)">
            {{ order.status }}
          </span>
        </div>
        
        <div class="order-details">
          <div class="detail-row">
            <span class="label">Date:</span>
            <span>{{ formatDate(order.transaction_date) }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Total:</span>
            <span>{{ order.currency }} {{ order.total }}</span>
          </div>
          <div class="detail-row">
            <span class="label">Items:</span>
            <span>{{ order.items_count }}</span>
          </div>
        </div>
        
        <div class="order-actions">
          <button @click="viewOrder(order.name)" class="btn btn-primary btn-sm">
            View Details
          </button>
          <button
            v-if="order.can_download"
            @click="downloadInvoice(order.name)"
            class="btn btn-secondary btn-sm"
          >
            Download Invoice
          </button>
        </div>
      </div>
    </div>

    <div v-if="hasMore" class="load-more">
      <button @click="loadMore" class="btn btn-outline-primary">
        Load More
      </button>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { debounce } from 'lodash'

export default {
  name: 'OrderList',
  setup() {
    const orders = ref([])
    const loading = ref(false)
    const searchTerm = ref('')
    const statusFilter = ref('')
    const pageStart = ref(0)
    const pageLength = ref(20)
    const totalOrders = ref(0)

    const hasMore = computed(() => {
      return pageStart.value + pageLength.value < totalOrders.value
    })

    const fetchOrders = async (reset = false) => {
      loading.value = true
      
      if (reset) {
        pageStart.value = 0
        orders.value = []
      }

      const filters = {}
      if (searchTerm.value) {
        filters.name = ['like', `%${searchTerm.value}%`]
      }
      if (statusFilter.value) {
        filters.status = statusFilter.value
      }

      try {
        const response = await frappe.call({
          method: 'customer_portal.api.get_customer_orders',
          args: {
            filters: JSON.stringify(filters),
            page_length: pageLength.value,
            page_start: pageStart.value
          }
        })

        if (reset) {
          orders.value = response.message.orders
        } else {
          orders.value.push(...response.message.orders)
        }
        
        totalOrders.value = response.message.total
      } catch (error) {
        frappe.msgprint({
          title: 'Error',
          indicator: 'red',
          message: error.message || 'Failed to fetch orders'
        })
      } finally {
        loading.value = false
      }
    }

    const debouncedSearch = debounce(() => {
      fetchOrders(true)
    }, 500)

    const filterOrders = () => {
      fetchOrders(true)
    }

    const loadMore = () => {
      pageStart.value += pageLength.value
      fetchOrders()
    }

    const viewOrder = (orderId) => {
      frappe.set_route('portal', 'order', orderId)
    }

    const downloadInvoice = async (orderId) => {
      try {
        const response = await frappe.call({
          method: 'customer_portal.api.download_invoice',
          args: { invoice_id: orderId }
        })
        
        // Handle PDF download
        const blob = new Blob([response.message], { type: 'application/pdf' })
        const url = window.URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = `invoice_${orderId}.pdf`
        a.click()
        window.URL.revokeObjectURL(url)
      } catch (error) {
        frappe.msgprint({
          title: 'Error',
          indicator: 'red',
          message: 'Failed to download invoice'
        })
      }
    }

    const formatDate = (date) => {
      return new Date(date).toLocaleDateString()
    }

    const getStatusClass = (status) => {
      const statusClasses = {
        'Draft': 'badge badge-secondary',
        'Submitted': 'badge badge-primary',
        'Delivered': 'badge badge-success',
        'Cancelled': 'badge badge-danger'
      }
      return statusClasses[status] || 'badge badge-light'
    }

    onMounted(() => {
      fetchOrders()
    })

    return {
      orders,
      loading,
      searchTerm,
      statusFilter,
      hasMore,
      debouncedSearch,
      filterOrders,
      loadMore,
      viewOrder,
      downloadInvoice,
      formatDate,
      getStatusClass
    }
  }
}
</script>

<style scoped>
.order-list-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.order-filters {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.order-filters input,
.order-filters select {
  flex: 1;
}

.order-list {
  display: grid;
  gap: 15px;
}

.order-card {
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 15px;
  background: white;
  transition: box-shadow 0.3s;
}

.order-card:hover {
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.order-details {
  margin-bottom: 15px;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  padding: 5px 0;
}

.detail-row .label {
  font-weight: 600;
  color: #666;
}

.order-actions {
  display: flex;
  gap: 10px;
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: #999;
}

.load-more {
  text-align: center;
  margin-top: 20px;
}

/* Mobile Responsive */
@media (max-width: 768px) {
  .order-filters {
    flex-direction: column;
  }
  
  .order-actions {
    flex-direction: column;
  }
  
  .order-actions button {
    width: 100%;
  }
}
</style>
```

### Step 5: Testing Implementation

#### 5.1 Unit Tests

**Python Unit Test (test_customer_portal.py):**
```python
import frappe
import unittest
from frappe.test_runner import make_test_records

class TestCustomerPortal(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """Set up test data"""
        cls.customer = create_test_customer()
        cls.user = create_test_user()
        cls.portal_settings = create_portal_settings(
            cls.customer, cls.user
        )
        cls.sales_order = create_test_sales_order(cls.customer)
    
    def test_portal_settings_validation(self):
        """Test portal settings validation"""
        settings = frappe.get_doc(
            "Customer Portal Settings",
            self.portal_settings
        )
        
        # Test valid settings
        settings.validate()
        
        # Test invalid customer
        settings.customer = "Invalid Customer"
        self.assertRaises(frappe.ValidationError, settings.validate)
    
    def test_access_level_permissions(self):
        """Test access level permission mapping"""
        settings = frappe.get_doc(
            "Customer Portal Settings",
            self.portal_settings
        )
        
        # Test Basic level
        settings.access_level = "Basic"
        settings.set_access_permissions()
        self.assertEqual(settings.can_view_orders, 1)
        self.assertEqual(settings.can_download_invoices, 0)
        
        # Test Premium level
        settings.access_level = "Premium"
        settings.set_access_permissions()
        self.assertEqual(settings.can_view_orders, 1)
        self.assertEqual(settings.can_download_invoices, 1)
    
    def test_get_customer_orders(self):
        """Test customer orders API"""
        frappe.set_user(self.user)
        
        from customer_portal.api import get_customer_orders
        
        # Test successful fetch
        result = get_customer_orders()
        self.assertIn("orders", result)
        self.assertIn("total", result)
        
        # Test with filters
        result = get_customer_orders(
            filters='{"status": "Submitted"}'
        )
        self.assertTrue(len(result["orders"]) > 0)
        
        # Test pagination
        result = get_customer_orders(page_length=5, page_start=0)
        self.assertTrue(len(result["orders"]) <= 5)
    
    def test_order_access_control(self):
        """Test order access control"""
        frappe.set_user(self.user)
        
        from customer_portal.api import get_order_details
        
        # Test valid order
        result = get_order_details(self.sales_order)
        self.assertIn("order", result)
        self.assertIn("items", result)
        
        # Test invalid order (different customer)
        other_customer = create_test_customer("Other Customer")
        other_order = create_test_sales_order(other_customer)
        
        self.assertRaises(
            frappe.PermissionError,
            get_order_details,
            other_order
        )
    
    @classmethod
    def tearDownClass(cls):
        """Clean up test data"""
        frappe.db.rollback()

def create_test_customer(name="Test Customer"):
    """Create test customer"""
    if not frappe.db.exists("Customer", name):
        customer = frappe.get_doc({
            "doctype": "Customer",
            "customer_name": name,
            "customer_group": "Individual",
            "territory": "All Territories"
        })
        customer.insert()
        return customer.name
    return name

def create_test_user(email="test@example.com"):
    """Create test user"""
    if not frappe.db.exists("User", email):
        user = frappe.get_doc({
            "doctype": "User",
            "email": email,
            "first_name": "Test",
            "last_name": "User",
            "roles": [{"role": "Customer"}]
        })
        user.insert()
        return user.name
    return email

def create_portal_settings(customer, user):
    """Create test portal settings"""
    settings = frappe.get_doc({
        "doctype": "Customer Portal Settings",
        "customer": customer,
        "portal_user": user,
        "access_level": "Standard",
        "enabled": 1
    })
    settings.insert()
    return settings.name

def create_test_sales_order(customer):
    """Create test sales order"""
    order = frappe.get_doc({
        "doctype": "Sales Order",
        "customer": customer,
        "transaction_date": frappe.utils.today(),
        "delivery_date": frappe.utils.add_days(frappe.utils.today(), 7),
        "items": [{
            "item_code": "Test Item",
            "qty": 1,
            "rate": 100
        }]
    })
    order.insert()
    order.submit()
    return order.name
```

### Step 6: Code Quality and Best Practices

#### 6.1 Frappe Framework Best Practices

**DO's:**
```python
# ✅ Use Frappe's built-in methods
frappe.get_doc("DocType", name)
frappe.get_list("DocType", filters={})
frappe.db.get_value("DocType", name, "field")

# ✅ Use translations for user-facing strings
frappe.throw(_("Error message"))

# ✅ Use proper permission checks
frappe.has_permission("DocType", "read")

# ✅ Use Frappe's caching
@frappe.whitelist(allow_guest=False, cache=True)
def cached_method():
    pass

# ✅ Use Frappe's validation patterns
def validate(self):
    self.validate_field()
    
def validate_field(self):
    if not self.field:
        frappe.throw(_("Field is required"))
```

**DON'Ts:**
```python
# ❌ Direct database queries when Frappe methods exist
cursor.execute("SELECT * FROM tabDocType")

# ❌ Hardcoded strings
frappe.throw("Error message")

# ❌ Skip permission checks
doc.insert(ignore_permissions=True)  # Only in specific cases

# ❌ Global variables
global_var = "value"  # Use frappe.cache instead

# ❌ Synchronous external API calls
requests.get("https://api.example.com")  # Use background jobs
```

#### 6.2 Performance Optimization

**Database Optimization:**
```python
# Use get_list with specific fields
orders = frappe.get_list(
    "Sales Order",
    fields=["name", "total"],  # Only fetch needed fields
    filters={"customer": customer},
    limit=20  # Always paginate
)

# Use get_value for single fields
total = frappe.db.get_value("Sales Order", order_id, "total")

# Use bulk operations
frappe.db.sql("""
    UPDATE `tabSales Order`
    SET status = %s
    WHERE customer = %s
""", ("Delivered", customer))

# Add database indexes
# In DocType JSON: "search_index": 1 for frequently searched fields
```

**Caching Strategy:**
```python
# Cache expensive operations
@frappe.whitelist()
def get_dashboard_data():
    cache_key = f"dashboard_data_{frappe.session.user}"
    
    # Try to get from cache
    data = frappe.cache().get_value(cache_key)
    if data:
        return data
    
    # Compute expensive data
    data = compute_dashboard_data()
    
    # Cache for 5 minutes
    frappe.cache().set_value(cache_key, data, expires_in_sec=300)
    
    return data

# Clear cache when data changes
def on_update(self):
    frappe.cache().delete_value(f"dashboard_data_{self.user}")
```

### Step 7: Documentation

#### 7.1 Code Documentation

**Docstring Format:**
```python
def process_order(order_id, action="submit"):
    """
    Process a sales order with specified action.
    
    This function handles various order processing actions including
    submission, cancellation, and status updates. It validates permissions
    and maintains audit trail.
    
    Args:
        order_id (str): The Sales Order document name
        action (str, optional): Action to perform. Defaults to "submit".
            Possible values: "submit", "cancel", "hold", "resume"
    
    Returns:
        dict: Processing result with following keys:
            - success (bool): Whether processing succeeded
            - message (str): Success or error message
            - order_status (str): New order status
    
    Raises:
        frappe.PermissionError: If user lacks permission
        frappe.ValidationError: If order is in invalid state
        ValueError: If action is not recognized
    
    Example:
        >>> result = process_order("SO-2024-001", "submit")
        >>> print(result["message"])
        "Order submitted successfully"
    """
    pass
```

#### 7.2 README Documentation

**Feature README.md:**
```markdown
# Customer Portal Feature

## Overview
Customer self-service portal for viewing orders and downloading invoices.

## Setup Instructions

### 1. Install Dependencies
```bash
bench get-app customer_portal
bench --site [site-name] install-app customer_portal
```

### 2. Configuration
1. Go to Customer Portal Settings
2. Link customer to portal user
3. Set access level
4. Enable required permissions

## API Endpoints

### Get Customer Orders
**Endpoint:** `/api/method/customer_portal.api.get_customer_orders`
**Method:** GET
**Parameters:**
- `filters` (optional): JSON filter object
- `page_length` (optional): Records per page (default: 20)
- `page_start` (optional): Starting record (default: 0)

**Response:**
```json
{
  "orders": [...],
  "total": 100,
  "page_length": 20,
  "page_start": 0
}
```

## Frontend Components

### OrderList Component
Vue.js component for displaying customer orders.

**Usage:**
```vue
<template>
  <OrderList :customer-id="customerId" />
</template>
```

## Testing
Run tests with:
```bash
bench --site [site-name] run-tests --app customer_portal
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Check Customer Portal Settings
   - Verify user has Customer role
   - Check User Permissions

2. **Orders Not Showing**
   - Verify orders are submitted
   - Check customer assignment
   - Review filters

## Support
Contact: support@example.com
```

## Deployment Process

### Step 8: Code Review and Deployment

#### 8.1 Pre-Deployment Checklist

- [ ] All acceptance criteria met
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Code reviewed by peer
- [ ] Documentation updated
- [ ] Migration scripts ready
- [ ] Performance tested
- [ ] Security validated

#### 8.2 Deployment Steps

```bash
# 1. Commit changes
git add .
git commit -m "feat: implement customer portal order view"

# 2. Push to feature branch
git push origin feature/story-1-1-customer-portal

# 3. Create pull request
# Via GitHub/GitLab UI or CLI

# 4. After PR approval, deploy to staging
bench --site staging.example.com migrate
bench --site staging.example.com clear-cache

# 5. Run smoke tests
bench --site staging.example.com run-tests --app customer_portal

# 6. Deploy to production
bench --site production.example.com migrate
bench --site production.example.com clear-cache
```

## Common Development Patterns

### DocType Patterns

**Single DocType:**
```python
# Get single document
doc = frappe.get_doc("DocType", name)

# Create new document
doc = frappe.get_doc({
    "doctype": "DocType",
    "field": "value"
})
doc.insert()

# Update document
doc = frappe.get_doc("DocType", name)
doc.field = "new value"
doc.save()
```

**Child DocType:**
```python
# Add child to parent
parent = frappe.get_doc("Parent DocType", name)
parent.append("child_table", {
    "field": "value"
})
parent.save()
```

### Workflow Patterns

**State Management:**
```python
def on_submit(self):
    self.status = "Submitted"
    self.submitted_by = frappe.session.user
    self.submitted_on = frappe.utils.now()

def on_cancel(self):
    self.status = "Cancelled"
    self.cancelled_by = frappe.session.user
    self.cancelled_on = frappe.utils.now()
```

## Troubleshooting Guide

### Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Import Error | Missing dependency | Run `bench setup requirements` |
| Permission Denied | Missing role | Add role in User document |
| DocType Not Found | Not installed | Run `bench migrate` |
| API Not Working | Not whitelisted | Add `@frappe.whitelist()` |
| Frontend Not Loading | Build issue | Run `bench build` |
| Cache Issues | Stale cache | Run `bench clear-cache` |

## 🎯 Complete Workflow Example

### Example: Implementing Story 1.1 - User Registration

```bash
# Step 1: Create the Customer Portal Settings DocType
npx bmad-method activate:agent bmad-erpnext-v15 doctype-designer
*create-doctype Customer_Portal_Settings
# Follow prompts to define fields: customer, portal_user, access_level, enabled

# Step 2: Create API endpoints for registration
npx bmad-method activate:agent bmad-erpnext-v15 api-developer
*create-api customer
*create-api-endpoint register_customer
*create-api-endpoint validate_registration

# Step 3: Setup Vue frontend for registration
npx bmad-method run:task bmad-erpnext-v15 create-vue-spa --app-name customer_portal
npx bmad-method run:task bmad-erpnext-v15 setup-frappe-ui --app-name customer_portal

# Step 4: Create registration components
npx bmad-method activate:agent bmad-erpnext-v15 vue-frontend-architect
*create-component RegistrationForm
*create-component EmailVerification
*setup-auth-flow

# Step 5: Add PWA support for mobile users
npx bmad-method run:task bmad-erpnext-v15 implement-pwa --app-name customer_portal

# Step 6: Create unit tests
npx bmad-method run:task bmad-erpnext-v15 create-unit-tests

# Step 7: Run tests and build
npx bmad-method run:task bmad-erpnext-v15 run-tests
npx bmad-method run:task bmad-erpnext-v15 build-frontend

# Step 8: Install and test
npx bmad-method run:task bmad-erpnext-v15 install-app --app-name customer_portal

# Step 9: Run compliance check
npx bmad-method activate:agent bmad-erpnext-v15 frappe-compliance-validator
*validate-code
*check-patterns
*exit
```

### Multi-Agent Development Team

For complex stories, use the development team:
```bash
# Activate the complete development team
npx bmad-method activate:team bmad-erpnext-v15 development-team
# The team coordinates:
# - DocType Designer: Creates data models
# - API Developer: Builds backend APIs
# - Vue Frontend Architect: Creates UI components
# - Testing Specialist: Writes tests
# - Frappe Compliance Validator: Ensures best practices
```

### Ready for QA ✅

Your feature is now implemented, tested, and ready for quality assurance.

## Next Steps

After task completion:
1. **Update Task Status** in project management tool
2. **Request Code Review** from peer developer
3. **Update Documentation** if needed
4. **Prepare for Demo** in sprint review
5. **Handoff to QA** for testing

### 💻 Next Stage Command
```bash
# Move to Stage 5 - QA Testing
# Hand off your completed feature to the QA Lead
# They will use: npx bmad-method activate:agent bmad-erpnext-v15 erpnext-qa-lead
```

## Resources

- [Frappe Framework Documentation](https://frappeframework.com/docs)
- [ERPNext Developer Guide](https://docs.erpnext.com/docs/user/manual/en/developer)
- [Vue.js Documentation](https://vuejs.org/guide/)
- [Python Style Guide](https://www.python.org/dev/peps/pep-0008/)
- [Git Best Practices](./references/git-workflow.md)

---

*Remember: Good code is not just working code. It's maintainable, tested, documented, and follows established patterns. Take pride in craftsmanship.*