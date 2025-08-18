# ERPNext Native Vue Integration Guide
## Complete Reference for Native Vue.js Components in ERPNext v16

**Last Updated**: 2025-08-17  
**Framework Version**: Vue 3.4+ | ERPNext 16 | Frappe Framework 16  
**CRITICAL**: NO separate /frontend/ directory - Use native Frappe asset pipeline

---

## 🚨 CRITICAL: ERPNext v16 Native Vue Integration

**NO SEPARATE FRONTEND** - ERPNext v16 has Vue 3 natively integrated!

### ❌ OLD PATTERN (Don't use)
```
app_name/
├── backend/               # ❌ Remove
├── frontend/              # ❌ Remove - No longer needed!
│   ├── src/
│   ├── vite.config.js     # ❌ Remove
│   └── package.json       # ❌ Remove
```

### ✅ NEW PATTERN (Use this)
```
app_name/                  # Created by bench new-app
├── app_name/              # Main app package
│   ├── public/            # Static assets integrated with Frappe
│   │   └── js/           # Vue components + bundle entries
│   ├── [module]/         # Business modules
│   └── hooks.py          # App configuration
```

This guide covers NATIVE Vue integration using Frappe's built-in esbuild pipeline.
DO NOT create separate frontend applications with Vite/webpack.

## 🔌 Backend Integration Patterns

### 1. API Communication Setup

#### Frappe Request Configuration
```javascript
// Use native Frappe API - NO custom request wrapper needed
// All API communication should use frappe.call()

// Configure global error handling for frappe.call()
const originalCall = frappe.call;
frappe.call = function(options) {
  return originalCall.call(this, {
    ...options,
    error: (error) => {
      // Global error handling
      if (error.httpStatus === 401) {
        window.location.href = '/login';
      } else if (error.httpStatus === 403) {
        frappe.show_alert({
          message: __('You do not have permission to perform this action'),
          indicator: 'red'
        });
      } else if (error.httpStatus === 500) {
        frappe.show_alert({
          message: __('Server error occurred. Please try again later.'),
          indicator: 'red'
        });
      }
      if (options.error) options.error(error);
    }
  });
};

// Custom API wrapper for common operations
export const api = {
  // Get single document
  async getDoc(doctype, name, fields = '*') {
    const response = await frappe.call({
      method: 'frappe.client.get',
      args: { doctype, name, fields }
    });
    return response.message;
  },

  // Get list of documents
  async getList(doctype, options = {}) {
    const response = await frappe.call({
      method: 'frappe.client.get_list',
      args: {
        doctype,
        fields: ['*'],
        limit_page_length: 20,
        order_by: 'modified desc',
        ...options
      }
    });
    return response.message;
  },

  // Create new document
  async createDoc(doctype, doc) {
    return request({
      url: 'frappe.client.insert',
      params: { doc: { doctype, ...doc } }
    })
  },

  // Update document
  async updateDoc(doctype, name, doc) {
    return request({
      url: 'frappe.client.save',
      params: { doc: { doctype, name, ...doc } }
    })
  },

  // Set specific field value
  async setValue(doctype, name, fieldname, value) {
    return request({
      url: 'frappe.client.set_value',
      params: { doctype, name, fieldname, value }
    })
  },

  // Delete document
  async deleteDoc(doctype, name) {
    return request({
      url: 'frappe.client.delete',
      params: { doctype, name }
    })
  },

  // Call server method
  async call(method, args = {}) {
    return request({
      url: `frappe.client.get_value`,
      params: { method, ...args }
    })
  }
}
```

### 2. ERPNext DocType Integration

#### Customer Management Integration
```javascript
// stores/customers.js - Customer doctype integration
import { defineStore } from 'pinia'
// REMOVED: frappe-ui import - use native components
import { ref, computed } from 'vue'

export const customersStore = defineStore('customers', () => {
  // Customer data state
  const customers = ref([]);
  const loading = ref(false);
  
  // Fetch customers using native frappe.call
  async function fetchCustomers() {
    loading.value = true;
    try {
      const response = await frappe.call({
        method: 'frappe.client.get_list',
        args: {
          doctype: 'Customer',
          fields: [
            'name', 'customer_name', 'customer_type', 'territory', 'customer_group',
            'mobile_no', 'email_id', 'outstanding_amount', 'credit_limit',
            'is_frozen', 'disabled', 'modified'
          ],
          filters: { disabled: 0 },
          order_by: 'customer_name asc',
          limit_page_length: 0
        }
      });
      customers.value = response.message || [];
    } catch (error) {
      frappe.show_alert({
        message: __('Failed to load customers'),
        indicator: 'red'
      });
    } finally {
      loading.value = false;
    }
  }

  // Get single customer
  async function getCustomer(name) {
    try {
      const response = await frappe.call({
        method: 'frappe.client.get',
        args: {
          doctype: 'Customer',
          name: name
        }
      });
      return response.message;
    } catch (error) {
      frappe.show_alert({
        message: __('Failed to load customer'),
        indicator: 'red'
      });
      return null;
    }
  }

  // Customer addresses
  const customerAddresses = // REMOVED: createResource - use frappe.call()({
    url: 'frappe.client.get_list',
    makeParams: (customer) => ({
      doctype: 'Address',
      fields: ['name', 'address_title', 'address_line1', 'city', 'state', 'country', 'is_primary_address'],
      filters: { 
        link_doctype: 'Customer',
        link_name: customer
      }
    })
  })

  // Customer contacts
  const customerContacts = // REMOVED: createResource - use frappe.call()({
    url: 'frappe.client.get_list',
    makeParams: (customer) => ({
      doctype: 'Contact',
      fields: ['name', 'first_name', 'last_name', 'email_id', 'mobile_no', 'is_primary_contact'],
      filters: {
        link_doctype: 'Customer',
        link_name: customer
      }
    })
  })

  // Create new customer
  const createCustomer = // REMOVED: createResource - use frappe.call()({
    url: 'frappe.client.insert',
    onSuccess() {
      customers.reload()
    }
  })

  // Computed getters
  const activeCustomers = computed(() => {
    return customers.data?.filter(c => !c.disabled && !c.is_frozen) || []
  })

  const customersByTerritory = computed(() => {
    const groups = {}
    activeCustomers.value.forEach(customer => {
      const territory = customer.territory || 'Unassigned'
      if (!groups[territory]) groups[territory] = []
      groups[territory].push(customer)
    })
    return groups
  })

  // Actions
  const getCustomer = async (name) => {
    await customerResource.submit(name)
    return customerResource.data
  }

  const getCustomerAddresses = async (customer) => {
    await customerAddresses.submit(customer)
    return customerAddresses.data
  }

  const getCustomerContacts = async (customer) => {
    await customerContacts.submit(customer)
    return customerContacts.data
  }

  const createNewCustomer = async (customerData) => {
    await createCustomer.submit({
      doc: { doctype: 'Customer', ...customerData }
    })
  }

  return {
    // Resources
    customers,
    customerResource,
    customerAddresses,
    customerContacts,
    createCustomer,
    
    // Computed
    activeCustomers,
    customersByTerritory,
    
    // Actions
    getCustomer,
    getCustomerAddresses,
    getCustomerContacts,
    createNewCustomer
  }
})
```

#### Sales Order Integration
```javascript
// stores/salesOrders.js - Sales Order integration
import { defineStore } from 'pinia'
// REMOVED: frappe-ui import - use native components
import { ref, computed } from 'vue'

export const salesOrdersStore = defineStore('salesOrders', () => {
  // Sales Orders resource
  const salesOrders = // REMOVED: createResource - use frappe.call()({
    url: 'frappe.client.get_list',
    params: {
      doctype: 'Sales Order',
      fields: [
        'name',
        'customer',
        'customer_name',
        'transaction_date',
        'delivery_date',
        'grand_total',
        'outstanding_amount',
        'status',
        'per_delivered',
        'per_billed',
        'territory',
        'sales_partner'
      ],
      order_by: 'transaction_date desc'
    },
    auto: true
  })

  // Single sales order with items
  const salesOrderResource = // REMOVED: createResource - use frappe.call()({
    url: 'frappe.client.get',
    makeParams: (name) => ({
      doctype: 'Sales Order',
      name: name
    })
  })

  // Sales order items
  const salesOrderItems = // REMOVED: createResource - use frappe.call()({
    url: 'frappe.client.get_list',
    makeParams: (parentName) => ({
      doctype: 'Sales Order Item',
      fields: [
        'item_code',
        'item_name', 
        'description',
        'qty',
        'rate',
        'amount',
        'delivered_qty',
        'warehouse',
        'delivery_date'
      ],
      filters: { parent: parentName }
    })
  })

  // Create sales order
  const createSalesOrder = // REMOVED: createResource - use frappe.call()({
    url: 'frappe.client.insert',
    onSuccess(doc) {
      salesOrders.setData(data => [doc, ...data])
    }
  })

  // Update sales order
  const updateSalesOrder = // REMOVED: createResource - use frappe.call()({
    url: 'frappe.client.save',
    onSuccess() {
      salesOrders.reload()
    }
  })

  // Submit sales order
  const submitSalesOrder = // REMOVED: createResource - use frappe.call()({
    url: 'frappe.client.submit',
    onSuccess() {
      salesOrders.reload()
    }
  })

  // Cancel sales order
  const cancelSalesOrder = // REMOVED: createResource - use frappe.call()({
    url: 'frappe.client.cancel',
    onSuccess() {
      salesOrders.reload()
    }
  })

  // Computed values
  const ordersByStatus = computed(() => {
    if (!salesOrders.data) return {}
    
    return salesOrders.data.reduce((acc, order) => {
      const status = order.status
      if (!acc[status]) acc[status] = []
      acc[status].push(order)
      return acc
    }, {})
  })

  const pendingOrders = computed(() => {
    return salesOrders.data?.filter(order => 
      ['Draft', 'To Deliver and Bill', 'To Bill', 'To Deliver'].includes(order.status)
    ) || []
  })

  const overduOrders = computed(() => {
    const today = new Date()
    return salesOrders.data?.filter(order => {
      const deliveryDate = new Date(order.delivery_date)
      return deliveryDate < today && order.per_delivered < 100
    }) || []
  })

  // Actions
  const getSalesOrder = async (name) => {
    await salesOrderResource.submit(name)
    return salesOrderResource.data
  }

  const getSalesOrderItems = async (parentName) => {
    await salesOrderItems.submit(parentName)
    return salesOrderItems.data
  }

  const createNewSalesOrder = async (orderData) => {
    return await createSalesOrder.submit({
      doc: { doctype: 'Sales Order', ...orderData }
    })
  }

  const saveSalesOrder = async (orderData) => {
    return await updateSalesOrder.submit({
      doc: orderData
    })
  }

  const submitOrder = async (name) => {
    return await submitSalesOrder.submit({ doctype: 'Sales Order', name })
  }

  const cancelOrder = async (name) => {
    return await cancelSalesOrder.submit({ doctype: 'Sales Order', name })
  }

  return {
    // Resources
    salesOrders,
    salesOrderResource,
    salesOrderItems,
    createSalesOrder,
    updateSalesOrder,
    submitSalesOrder,
    cancelSalesOrder,
    
    // Computed
    ordersByStatus,
    pendingOrders,
    overduOrders,
    
    // Actions
    getSalesOrder,
    getSalesOrderItems,
    createNewSalesOrder,
    saveSalesOrder,
    submitOrder,
    cancelOrder
  }
})
```

### 3. ERPNext User & Permissions Integration

#### User Session Management
```javascript
// data/session.js - ERPNext session integration
import { reactive } from 'vue'
// REMOVED: frappe-ui import - use native components

// Get session user from cookies
function getSessionUser() {
  let cookies = new URLSearchParams(document.cookie.split('; ').join('&'))
  let user = cookies.get('user_id')
  if (user === 'Guest') user = null
  return user
}

// Reactive session state
export const session = reactive({
  user: getSessionUser(),
  isLoggedIn: !!getSessionUser()
})

// User resource
export const userResource = // REMOVED: createResource - use frappe.call()({
  url: 'frappe.client.get',
  params: {
    doctype: 'User',
    name: session.user
  },
  auto: session.isLoggedIn,
  onSuccess(data) {
    session.user = data.name
    session.isLoggedIn = true
  },
  onError() {
    session.user = null
    session.isLoggedIn = false
  }
})

// User permissions resource
export const userPermissions = // REMOVED: createResource - use frappe.call()({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'User Permission',
    fields: ['for_value', 'allow'],
    filters: { user: session.user }
  },
  auto: session.isLoggedIn
})

// User roles resource
export const userRoles = // REMOVED: createResource - use frappe.call()({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'Has Role',
    fields: ['role'],
    filters: { parent: session.user }
  },
  auto: session.isLoggedIn
})

// Permission checker
export function hasPermission(doctype, permission = 'read', doc = null) {
  if (!session.isLoggedIn) return false
  
  // System Manager has all permissions
  const roles = userRoles.data?.map(r => r.role) || []
  if (roles.includes('System Manager')) return true
  
  // Check specific permission logic here
  // This would typically call a server method
  return true // Simplified for example
}

// Login function
export const login = // REMOVED: createResource - use frappe.call()({
  url: 'login',
  onSuccess() {
    session.user = getSessionUser()
    session.isLoggedIn = true
    userResource.reload()
    userPermissions.reload()
    userRoles.reload()
    window.location.href = '/'
  }
})

// Logout function
export const logout = // REMOVED: createResource - use frappe.call()({
  url: 'logout',
  onSuccess() {
    session.user = null
    session.isLoggedIn = false
    userResource.reset()
    userPermissions.reset()
    userRoles.reset()
    window.location.href = '/login'
  }
})
```

#### Employee Profile Integration (HRMS Pattern)
```javascript
// data/employee.js - Employee profile integration
// REMOVED: frappe-ui import - use native components
import { session } from './session'

export const employeeResource = // REMOVED: createResource - use frappe.call()({
  url: 'frappe.client.get_list',
  params: {
    doctype: 'Employee',
    fields: [
      'name',
      'employee_name',
      'user_id',
      'department',
      'designation',
      'company',
      'image',
      'cell_number',
      'personal_email',
      'current_address',
      'date_of_joining',
      'employment_type',
      'status'
    ],
    filters: { user_id: session.user },
    limit_page_length: 1
  },
  auto: session.isLoggedIn,
  transform(data) {
    return data?.[0] || null
  }
})

// Employee attendance
export const employeeAttendance = // REMOVED: createResource - use frappe.call()({
  url: 'frappe.client.get_list',
  makeParams: (filters = {}) => ({
    doctype: 'Attendance',
    fields: ['attendance_date', 'status', 'in_time', 'out_time', 'working_hours'],
    filters: {
      employee: employeeResource.data?.name,
      ...filters
    },
    order_by: 'attendance_date desc',
    limit_page_length: 30
  })
})

// Employee leaves
export const employeeLeaves = // REMOVED: createResource - use frappe.call()({
  url: 'frappe.client.get_list',
  makeParams: (filters = {}) => ({
    doctype: 'Leave Application',
    fields: [
      'name', 'leave_type', 'from_date', 'to_date', 
      'total_leave_days', 'description', 'status'
    ],
    filters: {
      employee: employeeResource.data?.name,
      ...filters
    },
    order_by: 'from_date desc'
  })
})

// Check-in resource
export const checkIn = // REMOVED: createResource - use frappe.call()({
  url: 'hrms.api.check_in',
  onSuccess() {
    employeeAttendance.reload()
  }
})

// Check-out resource
export const checkOut = // REMOVED: createResource - use frappe.call()({
  url: 'hrms.api.check_out',
  onSuccess() {
    employeeAttendance.reload()
  }
})
```

### 4. Custom Server Methods Integration

#### Custom API Methods
```python
# Custom server methods in your ERPNext app
# File: custom_app/api.py

import frappe
from frappe import _

@frappe.whitelist()
def get_customer_dashboard_data(customer):
    """Get comprehensive customer data for dashboard"""
    
    # Get customer doc
    customer_doc = frappe.get_doc("Customer", customer)
    
    # Get recent orders
    recent_orders = frappe.get_all(
        "Sales Order",
        filters={"customer": customer},
        fields=["name", "transaction_date", "grand_total", "status"],
        order_by="transaction_date desc",
        limit=10
    )
    
    # Get outstanding invoices
    outstanding_invoices = frappe.get_all(
        "Sales Invoice",
        filters={"customer": customer, "outstanding_amount": [">", 0]},
        fields=["name", "posting_date", "grand_total", "outstanding_amount"],
        order_by="posting_date desc"
    )
    
    # Get payment history
    payments = frappe.get_all(
        "Payment Entry",
        filters={"party": customer, "party_type": "Customer"},
        fields=["name", "posting_date", "paid_amount", "reference_no"],
        order_by="posting_date desc",
        limit=10
    )
    
    return {
        "customer": customer_doc.as_dict(),
        "recent_orders": recent_orders,
        "outstanding_invoices": outstanding_invoices,
        "payments": payments,
        "total_outstanding": sum(inv.outstanding_amount for inv in outstanding_invoices)
    }

@frappe.whitelist()
def create_sales_order_from_quotation(quotation_name):
    """Convert quotation to sales order"""
    
    quotation = frappe.get_doc("Quotation", quotation_name)
    
    if quotation.status != "Submitted":
        frappe.throw(_("Quotation must be submitted first"))
    
    # Create sales order
    so = frappe.new_doc("Sales Order")
    so.customer = quotation.party_name
    so.quotation_no = quotation.name
    
    # Copy items
    for item in quotation.items:
        so.append("items", {
            "item_code": item.item_code,
            "qty": item.qty,
            "rate": item.rate,
            "warehouse": item.warehouse
        })
    
    so.save()
    
    return so.name

@frappe.whitelist()
def get_item_stock_levels(item_codes=None):
    """Get current stock levels for items"""
    
    filters = {}
    if item_codes:
        filters["item_code"] = ["in", item_codes]
    
    stock_levels = frappe.get_all(
        "Bin",
        filters=filters,
        fields=[
            "item_code", "warehouse", "actual_qty", 
            "reserved_qty", "projected_qty"
        ]
    )
    
    # Group by item code
    result = {}
    for stock in stock_levels:
        item = stock.item_code
        if item not in result:
            result[item] = []
        result[item].append(stock)
    
    return result
```

#### Frontend Integration of Custom Methods
```javascript
// composables/useCustomApi.js - Custom API integration
// REMOVED: frappe-ui import - use native components
import { ref, computed } from 'vue'

export function useCustomerDashboard(customer) {
  const dashboardData = // REMOVED: createResource - use frappe.call()({
    url: 'custom_app.api.get_customer_dashboard_data',
    makeParams: () => ({ customer }),
    auto: !!customer
  })

  const totalOutstanding = computed(() => {
    return dashboardData.data?.total_outstanding || 0
  })

  const recentOrdersCount = computed(() => {
    return dashboardData.data?.recent_orders?.length || 0
  })

  return {
    dashboardData,
    totalOutstanding,
    recentOrdersCount
  }
}

export function useQuotationConverter() {
  const convertToSalesOrder = // REMOVED: createResource - use frappe.call()({
    url: 'custom_app.api.create_sales_order_from_quotation',
    onSuccess(salesOrderName) {
      // Navigate to new sales order
      router.push(`/sales-order/${salesOrderName}`)
    }
  })

  const convert = async (quotationName) => {
    await convertToSalesOrder.submit({ quotation_name: quotationName })
    return convertToSalesOrder.data
  }

  return {
    convertToSalesOrder,
    convert
  }
}

export function useStockLevels() {
  const stockLevels = // REMOVED: createResource - use frappe.call()({
    url: 'custom_app.api.get_item_stock_levels'
  })

  const getStockForItems = async (itemCodes) => {
    await stockLevels.submit({ item_codes: itemCodes })
    return stockLevels.data
  }

  const isInStock = computed(() => (itemCode, warehouse = null) => {
    const stock = stockLevels.data?.[itemCode]
    if (!stock) return false
    
    if (warehouse) {
      const warehouseStock = stock.find(s => s.warehouse === warehouse)
      return warehouseStock && warehouseStock.actual_qty > 0
    }
    
    return stock.some(s => s.actual_qty > 0)
  })

  return {
    stockLevels,
    getStockForItems,
    isInStock
  }
}
```

### 5. File Upload & Attachment Handling

#### File Upload Component
```vue
<!-- components/FileUpload.vue -->
<template>
  <div class="space-y-4">
    <!-- File input -->
    <div class="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
      <input
        ref="fileInput"
        type="file"
        :multiple="multiple"
        :accept="accept"
        @change="handleFileSelect"
        class="hidden"
      />
      
      <div class="space-y-2">
        <FeatherIcon name="upload" class="w-8 h-8 mx-auto text-gray-400" />
        <div>
          <button
            type="button"
            @click="$refs.fileInput.click()"
            class="text-blue-600 hover:text-blue-500"
          >
            Click to upload
          </button>
          <span class="text-gray-500"> or drag and drop</span>
        </div>
        <p class="text-xs text-gray-500">{{ acceptDescription }}</p>
      </div>
    </div>

    <!-- File list -->
    <div v-if="files.length > 0" class="space-y-2">
      <div
        v-for="(file, index) in files"
        :key="index"
        class="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
      >
        <div class="flex items-center space-x-3">
          <FeatherIcon name="file" class="w-4 h-4 text-gray-500" />
          <div>
            <p class="text-sm font-medium">{{ file.name }}</p>
            <p class="text-xs text-gray-500">{{ formatFileSize(file.size) }}</p>
          </div>
        </div>
        
        <div class="flex items-center space-x-2">
          <div v-if="file.uploading" class="text-xs text-blue-600">
            Uploading... {{ file.progress }}%
          </div>
          <Button
            v-if="!file.uploading"
            icon="x"
            variant="ghost"
            size="sm"
            @click="removeFile(index)"
          />
        </div>
      </div>
    </div>

    <!-- Upload button -->
    <div v-if="files.length > 0 && !allFilesUploaded">
      <Button
        :loading="uploading"
        @click="uploadFiles"
        class="w-full"
      >
        Upload {{ files.length }} {{ files.length === 1 ? 'File' : 'Files' }}
      </Button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
// REMOVED: frappe-ui import - use native components

const props = defineProps({
  doctype: String,
  docname: String,
  multiple: { type: Boolean, default: false },
  accept: { type: String, default: '*/*' },
  acceptDescription: { type: String, default: 'Any file type' }
})

const emit = defineEmits(['uploaded', 'error'])

const files = ref([])
const uploading = ref(false)

const uploadResource = // REMOVED: createResource - use frappe.call()({
  url: 'frappe.client.attach_file',
  onSuccess(attachment) {
    emit('uploaded', attachment)
  },
  onError(error) {
    emit('error', error)
  }
})

const allFilesUploaded = computed(() => {
  return files.value.every(file => file.uploaded)
})

const handleFileSelect = (event) => {
  const selectedFiles = Array.from(event.target.files)
  
  selectedFiles.forEach(file => {
    files.value.push({
      name: file.name,
      size: file.size,
      file: file,
      uploading: false,
      uploaded: false,
      progress: 0
    })
  })
}

const removeFile = (index) => {
  files.value.splice(index, 1)
}

const uploadFiles = async () => {
  uploading.value = true
  
  try {
    for (let i = 0; i < files.value.length; i++) {
      const fileObj = files.value[i]
      
      if (fileObj.uploaded) continue
      
      fileObj.uploading = true
      
      const formData = new FormData()
      formData.append('file', fileObj.file)
      formData.append('doctype', props.doctype)
      formData.append('docname', props.docname)
      formData.append('is_private', 0)
      
      // Use XMLHttpRequest for progress tracking
      await new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest()
        
        xhr.upload.addEventListener('progress', (e) => {
          if (e.lengthComputable) {
            fileObj.progress = Math.round((e.loaded / e.total) * 100)
          }
        })
        
        xhr.addEventListener('load', () => {
          if (xhr.status === 200) {
            const response = JSON.parse(xhr.responseText)
            fileObj.uploaded = true
            fileObj.uploading = false
            emit('uploaded', response.message)
            resolve(response)
          } else {
            reject(new Error('Upload failed'))
          }
        })
        
        xhr.addEventListener('error', () => {
          reject(new Error('Upload failed'))
        })
        
        xhr.open('POST', '/api/method/frappe.client.attach_file')
        xhr.send(formData)
      })
    }
  } catch (error) {
    emit('error', error)
  } finally {
    uploading.value = false
  }
}

const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}
</script>
```

### 6. Print & Report Integration

#### Print Format Integration
```javascript
// composables/usePrint.js - Print format integration
// REMOVED: frappe-ui import - use native components

export function usePrint() {
  const printResource = // REMOVED: createResource - use frappe.call()({
    url: 'frappe.utils.print_format.download_pdf'
  })

  const printDoc = async (doctype, docname, printFormat = null) => {
    const params = {
      doctype,
      name: docname,
      format: printFormat || 'Standard',
      no_letterhead: 0
    }
    
    // Open print in new window
    const url = `/api/method/frappe.utils.print_format.download_pdf?` + 
                new URLSearchParams(params).toString()
    
    window.open(url, '_blank')
  }

  const downloadPDF = async (doctype, docname, printFormat = null) => {
    const params = {
      doctype,
      name: docname,
      format: printFormat || 'Standard',
      no_letterhead: 0
    }
    
    await printResource.submit(params)
    
    // Create download link
    const blob = new Blob([printResource.data], { type: 'application/pdf' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${doctype}-${docname}.pdf`
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
  }

  const emailDoc = async (doctype, docname, recipients, subject = null) => {
    const emailResource = // REMOVED: createResource - use frappe.call()({
      url: 'frappe.core.doctype.communication.email.make',
      onSuccess() {
        // Show success message
        console.log('Email sent successfully')
      }
    })

    await emailResource.submit({
      recipients: recipients.join(','),
      subject: subject || `${doctype}: ${docname}`,
      message: `Please find attached ${doctype}: ${docname}`,
      doctype,
      name: docname,
      send_email: 1,
      print_format: 'Standard',
      attach_document_print: 1
    })
  }

  return {
    printDoc,
    downloadPDF,
    emailDoc,
    printResource
  }
}
```

---

## 🔧 Development Tools & Debugging

### ERPNext Development Server Integration
```javascript
// utils/devServer.js - Development context setup
export const setupDevContext = async () => {
  if (import.meta.env.DEV) {
    try {
      const context = await frappeRequest({
        url: '/api/method/frappe.website.serve.get_context',
      })
      
      if (!window.frappe) window.frappe = {}
      window.frappe.boot = context
      
      console.log('Development context loaded:', context)
    } catch (error) {
      console.error('Failed to load development context:', error)
    }
  }
}
```

### Error Handling & Logging
```javascript
// utils/errorHandler.js - Comprehensive error handling
// REMOVED: frappe-ui import - use native components

export const handleError = (error, context = '') => {
  console.error(`Error in ${context}:`, error)
  
  let message = 'An unexpected error occurred'
  
  if (error.exc_type === 'ValidationError') {
    message = error.exc || 'Validation failed'
  } else if (error.exc_type === 'PermissionError') {
    message = 'You do not have permission to perform this action'
  } else if (error.httpStatus === 404) {
    message = 'The requested resource was not found'
  } else if (error.message) {
    message = error.message
  }
  
  createToast({
    title: 'Error',
    text: message,
    icon: 'x',
    iconClasses: 'text-red-600',
    timeout: 0 // Don't auto-dismiss errors
  })
  
  // Log to server if needed
  if (import.meta.env.PROD) {
    frappeRequest({
      url: '/api/method/frappe.client.insert',
      params: {
        doc: {
          doctype: 'Error Log',
          error: JSON.stringify(error),
          context: context,
          user_agent: navigator.userAgent,
          url: window.location.href
        }
      }
    }).catch(() => {
      // Ignore errors in error logging
    })
  }
}

// Global error handler
window.addEventListener('unhandledrejection', (event) => {
  handleError(event.reason, 'Unhandled Promise Rejection')
})

window.addEventListener('error', (event) => {
  handleError(event.error, 'JavaScript Error')
})
```

This comprehensive guide covers all aspects of integrating Vue.js frontends with ERPNext backends, providing production-ready patterns for building modern, scalable applications.