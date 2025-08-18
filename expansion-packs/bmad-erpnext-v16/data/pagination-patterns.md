# Pagination Patterns for ERPNext APIs

## Overview
Efficient pagination is crucial for handling large datasets in ERPNext applications. This guide covers both backend and frontend pagination patterns.

## Backend Pagination Patterns

### Basic Pagination API
```python
import frappe
from frappe import _

@frappe.whitelist()
def get_items_paginated(page=1, page_size=20, filters=None, sort_field="creation", sort_order="desc"):
    """
    Get paginated items with filtering and sorting.
    
    Args:
        page: Page number (1-indexed)
        page_size: Items per page (max 100)
        filters: JSON string of filters
        sort_field: Field to sort by
        sort_order: 'asc' or 'desc'
    """
    # Parse and validate inputs
    page = max(1, frappe.utils.cint(page))
    page_size = min(100, max(1, frappe.utils.cint(page_size)))
    
    if filters:
        filters = frappe.parse_json(filters)
    else:
        filters = {}
    
    # Validate sort field to prevent injection
    allowed_sort_fields = ["creation", "modified", "name", "item_name", "item_code"]
    if sort_field not in allowed_sort_fields:
        sort_field = "creation"
    
    if sort_order not in ["asc", "desc"]:
        sort_order = "desc"
    
    # Calculate offset
    start = (page - 1) * page_size
    
    # Get total count for pagination metadata
    total_count = frappe.db.count("Item", filters=filters)
    
    # Get paginated data
    items = frappe.get_all(
        "Item",
        fields=["name", "item_name", "item_code", "item_group", "standard_rate", "stock_uom"],
        filters=filters,
        order_by=f"{sort_field} {sort_order}",
        start=start,
        limit=page_size
    )
    
    # Calculate pagination metadata
    total_pages = (total_count + page_size - 1) // page_size
    has_next = page < total_pages
    has_prev = page > 1
    
    return {
        "data": items,
        "pagination": {
            "current_page": page,
            "page_size": page_size,
            "total_items": total_count,
            "total_pages": total_pages,
            "has_next": has_next,
            "has_prev": has_prev,
            "next_page": page + 1 if has_next else None,
            "prev_page": page - 1 if has_prev else None
        }
    }
```

### Cursor-Based Pagination
```python
@frappe.whitelist()
def get_items_cursor(cursor=None, limit=20, direction="next"):
    """
    Cursor-based pagination for better performance with large datasets.
    
    Args:
        cursor: Last item ID from previous page
        limit: Items per page
        direction: 'next' or 'prev'
    """
    limit = min(100, max(1, frappe.utils.cint(limit)))
    
    filters = {}
    order_by = "creation desc, name desc"
    
    if cursor:
        cursor_doc = frappe.db.get_value(
            "Item", 
            cursor, 
            ["creation", "name"], 
            as_dict=True
        )
        
        if cursor_doc:
            if direction == "next":
                filters = [
                    ["Item", "creation", "<", cursor_doc.creation],
                    ["Item", "name", "<", cursor]
                ]
            else:  # previous
                filters = [
                    ["Item", "creation", ">", cursor_doc.creation],
                    ["Item", "name", ">", cursor]
                ]
                order_by = "creation asc, name asc"
    
    items = frappe.get_all(
        "Item",
        fields=["name", "item_name", "item_code", "item_group", "standard_rate"],
        filters=filters,
        order_by=order_by,
        limit=limit + 1  # Get one extra to check if there's a next page
    )
    
    # Check if there are more items
    has_more = len(items) > limit
    if has_more:
        items = items[:limit]  # Remove the extra item
    
    # Reverse for previous page navigation
    if direction == "prev" and items:
        items.reverse()
    
    # Get cursors
    next_cursor = items[-1]["name"] if items and has_more else None
    prev_cursor = items[0]["name"] if items else None
    
    return {
        "data": items,
        "pagination": {
            "next_cursor": next_cursor,
            "prev_cursor": prev_cursor,
            "has_more": has_more,
            "limit": limit
        }
    }
```

### Infinite Scroll Pagination
```python
@frappe.whitelist()
def get_items_infinite(last_id=None, limit=20, filters=None):
    """
    Pagination optimized for infinite scroll.
    
    Args:
        last_id: ID of last item from previous batch
        limit: Items to load
        filters: Additional filters
    """
    limit = min(50, max(1, frappe.utils.cint(limit)))
    
    if filters:
        filters = frappe.parse_json(filters)
    else:
        filters = []
    
    # Add cursor condition if provided
    if last_id:
        last_creation = frappe.db.get_value("Item", last_id, "creation")
        filters.append(["Item", "creation", "<", last_creation])
    
    items = frappe.get_all(
        "Item",
        fields=["name", "item_name", "item_code", "item_group", "standard_rate", "image"],
        filters=filters,
        order_by="creation desc",
        limit=limit + 1
    )
    
    # Check if there are more items
    has_more = len(items) > limit
    if has_more:
        items = items[:limit]
    
    return {
        "data": items,
        "has_more": has_more,
        "last_id": items[-1]["name"] if items else None
    }
```

### Aggregated Pagination with Totals
```python
@frappe.whitelist()
def get_sales_orders_with_totals(page=1, page_size=20, filters=None):
    """
    Paginated data with aggregated totals.
    """
    page = max(1, frappe.utils.cint(page))
    page_size = min(100, max(1, frappe.utils.cint(page_size)))
    
    if filters:
        filters = frappe.parse_json(filters)
    else:
        filters = {}
    
    start = (page - 1) * page_size
    
    # Get paginated orders
    orders = frappe.get_all(
        "Sales Order",
        fields=["name", "customer", "transaction_date", "grand_total", "status"],
        filters=filters,
        order_by="transaction_date desc",
        start=start,
        limit=page_size
    )
    
    # Get aggregated totals for current filters
    totals = frappe.db.sql("""
        SELECT 
            COUNT(*) as total_orders,
            SUM(grand_total) as total_amount,
            AVG(grand_total) as average_amount
        FROM `tabSales Order`
        WHERE docstatus = 1
            {conditions}
    """.format(
        conditions=build_conditions(filters)
    ), as_dict=True)[0]
    
    total_count = totals.total_orders or 0
    total_pages = (total_count + page_size - 1) // page_size
    
    return {
        "data": orders,
        "aggregates": {
            "total_amount": totals.total_amount or 0,
            "average_amount": totals.average_amount or 0,
            "total_orders": total_count
        },
        "pagination": {
            "current_page": page,
            "page_size": page_size,
            "total_items": total_count,
            "total_pages": total_pages,
            "has_next": page < total_pages,
            "has_prev": page > 1
        }
    }

def build_conditions(filters):
    """Build SQL conditions from filters."""
    conditions = []
    for key, value in filters.items():
        if isinstance(value, list):
            # Handle operators like ['>', 100]
            operator, val = value
            conditions.append(f"AND {key} {operator} {frappe.db.escape(val)}")
        else:
            conditions.append(f"AND {key} = {frappe.db.escape(value)}")
    return " ".join(conditions)
```

## Frontend Pagination Components

### Vue Pagination with // REMOVED: createResource - use frappe.call()
```vue
<template>
  <div class="pagination-container">
    <!-- Data Table -->
    <div v-if="!listResource.loading" class="data-table">
      <table class="w-full">
        <thead>
          <tr>
            <th @click="sort('name')" class="cursor-pointer">
              Name
              <SortIcon :field="'name'" :current="sortField" :order="sortOrder" />
            </th>
            <th @click="sort('created')" class="cursor-pointer">
              Created
              <SortIcon :field="'created'" :current="sortField" :order="sortOrder" />
            </th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in listResource.data" :key="item.name">
            <td>{{ item.name }}</td>
            <td>{{ formatDate(item.created) }}</td>
            <td>
              <Button size="sm" @click="viewItem(item)">View</Button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    
    <!-- Loading State -->
    <div v-else class="flex justify-center py-8">
      <LoadingIndicator />
    </div>
    
    <!-- Pagination Controls -->
    <div class="pagination-controls flex justify-between items-center mt-4">
      <div class="flex gap-2">
        <Button
          :disabled="currentPage === 1"
          @click="goToPage(1)"
        >
          First
        </Button>
        <Button
          :disabled="currentPage === 1"
          @click="goToPage(currentPage - 1)"
        >
          Previous
        </Button>
      </div>
      
      <div class="page-info">
        <span>Page {{ currentPage }} of {{ totalPages }}</span>
        <span class="ml-4 text-gray-500">
          ({{ totalItems }} total items)
        </span>
      </div>
      
      <div class="flex gap-2">
        <Button
          :disabled="currentPage === totalPages"
          @click="goToPage(currentPage + 1)"
        >
          Next
        </Button>
        <Button
          :disabled="currentPage === totalPages"
          @click="goToPage(totalPages)"
        >
          Last
        </Button>
      </div>
    </div>
    
    <!-- Page Size Selector -->
    <div class="flex items-center gap-2 mt-4">
      <label>Items per page:</label>
      <select v-model="pageSize" @change="handlePageSizeChange">
        <option :value="10">10</option>
        <option :value="20">20</option>
        <option :value="50">50</option>
        <option :value="100">100</option>
      </select>
    </div>
    
    <!-- Quick Page Jump -->
    <div class="flex items-center gap-2 mt-4">
      <label>Go to page:</label>
      <input
        type="number"
        v-model.number="jumpToPage"
        :min="1"
        :max="totalPages"
        @keyup.enter="goToPage(jumpToPage)"
        class="w-20 px-2 py-1 border rounded"
      />
      <Button @click="goToPage(jumpToPage)">Go</Button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
// REMOVED: frappe-ui import - use native components
// REMOVED: frappe-ui import - use native components

const props = defineProps({
  doctype: String,
  filters: Object
})

const currentPage = ref(1)
const pageSize = ref(20)
const sortField = ref('creation')
const sortOrder = ref('desc')
const jumpToPage = ref(1)

const listResource = // REMOVED: createResource - use frappe.call()({
  url: 'custom_app.api.pagination.get_items_paginated',
  params: computed(() => ({
    page: currentPage.value,
    page_size: pageSize.value,
    filters: props.filters,
    sort_field: sortField.value,
    sort_order: sortOrder.value
  })),
  auto: true,
  onSuccess(data) {
    console.log('Data loaded:', data)
  }
})

const totalItems = computed(() => 
  listResource.data?.pagination?.total_items || 0
)

const totalPages = computed(() => 
  listResource.data?.pagination?.total_pages || 1
)

function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    jumpToPage.value = page
    listResource.reload()
  }
}

function handlePageSizeChange() {
  currentPage.value = 1  // Reset to first page
  listResource.reload()
}

function sort(field) {
  if (sortField.value === field) {
    sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortField.value = field
    sortOrder.value = 'asc'
  }
  currentPage.value = 1  // Reset to first page when sorting
  listResource.reload()
}

function viewItem(item) {
  // Handle item view
  console.log('View item:', item)
}

function formatDate(dateStr) {
  return new Date(dateStr).toLocaleDateString()
}

// Watch for filter changes
watch(() => props.filters, () => {
  currentPage.value = 1
  listResource.reload()
}, { deep: true })
</script>
```

### Infinite Scroll Component
```vue
<template>
  <div class="infinite-scroll-container" ref="scrollContainer">
    <!-- Items Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div
        v-for="item in items"
        :key="item.name"
        class="item-card border rounded-lg p-4"
      >
        <img 
          v-if="item.image" 
          :src="item.image" 
          :alt="item.item_name"
          class="w-full h-48 object-cover rounded"
        />
        <h3 class="font-semibold mt-2">{{ item.item_name }}</h3>
        <p class="text-gray-600">{{ item.item_code }}</p>
        <p class="text-lg font-bold mt-2">${{ item.standard_rate }}</p>
      </div>
    </div>
    
    <!-- Loading Indicator -->
    <div v-if="loading" class="flex justify-center py-8">
      <LoadingIndicator />
    </div>
    
    <!-- End of List Message -->
    <div v-if="!hasMore && items.length > 0" class="text-center py-8 text-gray-500">
      No more items to load
    </div>
    
    <!-- Empty State -->
    <div v-if="!loading && items.length === 0" class="text-center py-8">
      <p class="text-gray-500">No items found</p>
    </div>
    
    <!-- Intersection Observer Target -->
    <div ref="observerTarget" class="h-10"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
// REMOVED: frappe-ui import - use native components

const props = defineProps({
  filters: Object
})

const items = ref([])
const lastId = ref(null)
const hasMore = ref(true)
const loading = ref(false)
const observerTarget = ref(null)
const scrollContainer = ref(null)

let observer = null

const loadMoreResource = // REMOVED: createResource - use frappe.call()({
  url: 'custom_app.api.pagination.get_items_infinite',
  auto: false,
  onSuccess(data) {
    items.value.push(...data.data)
    hasMore.value = data.has_more
    lastId.value = data.last_id
    loading.value = false
  },
  onError(error) {
    console.error('Failed to load items:', error)
    loading.value = false
  }
})

async function loadMore() {
  if (loading.value || !hasMore.value) return
  
  loading.value = true
  
  await loadMoreResource.submit({
    last_id: lastId.value,
    limit: 20,
    filters: props.filters
  })
}

function setupIntersectionObserver() {
  const options = {
    root: scrollContainer.value,
    rootMargin: '100px',
    threshold: 0.1
  }
  
  observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting && hasMore.value) {
        loadMore()
      }
    })
  }, options)
  
  if (observerTarget.value) {
    observer.observe(observerTarget.value)
  }
}

onMounted(() => {
  loadMore()  // Initial load
  setupIntersectionObserver()
})

onUnmounted(() => {
  if (observer) {
    observer.disconnect()
  }
})

// Reset on filter change
watch(() => props.filters, () => {
  items.value = []
  lastId.value = null
  hasMore.value = true
  loadMore()
}, { deep: true })
</script>
```

### Cursor-Based Pagination Component
```vue
<template>
  <div class="cursor-pagination">
    <!-- Data List -->
    <div class="space-y-2">
      <div
        v-for="item in items"
        :key="item.name"
        class="p-4 border rounded hover:bg-gray-50"
      >
        <h3 class="font-semibold">{{ item.item_name }}</h3>
        <p class="text-sm text-gray-600">{{ item.item_code }}</p>
      </div>
    </div>
    
    <!-- Navigation -->
    <div class="flex justify-between mt-4">
      <Button
        :disabled="!canGoPrev"
        @click="navigate('prev')"
      >
        ← Previous
      </Button>
      
      <Button
        :disabled="!canGoNext"
        @click="navigate('next')"
      >
        Next →
      </Button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
// REMOVED: frappe-ui import - use native components

const items = ref([])
const currentCursor = ref(null)
const cursors = ref({
  next: null,
  prev: null
})
const navigationStack = ref([])

const cursorResource = // REMOVED: createResource - use frappe.call()({
  url: 'custom_app.api.pagination.get_items_cursor',
  auto: false,
  onSuccess(data) {
    items.value = data.data
    cursors.value = {
      next: data.pagination.next_cursor,
      prev: data.pagination.prev_cursor
    }
  }
})

const canGoNext = computed(() => cursors.value.next !== null)
const canGoPrev = computed(() => navigationStack.value.length > 0)

async function navigate(direction) {
  if (direction === 'next' && cursors.value.next) {
    navigationStack.value.push(currentCursor.value)
    currentCursor.value = cursors.value.next
  } else if (direction === 'prev' && navigationStack.value.length > 0) {
    currentCursor.value = navigationStack.value.pop()
  }
  
  await cursorResource.submit({
    cursor: currentCursor.value,
    direction: direction,
    limit: 20
  })
}

// Initial load
onMounted(() => {
  navigate('next')
})
</script>
```

## Pagination Patterns for Different Use Cases

### 1. Data Table with Server-Side Sorting and Filtering
```javascript
// Composable for paginated data table
import { ref, computed, watch } from 'vue'
// REMOVED: frappe-ui import - use native components

export function usePaginatedTable(endpoint, defaultFilters = {}) {
  const page = ref(1)
  const pageSize = ref(20)
  const sortBy = ref('creation')
  const sortOrder = ref('desc')
  const filters = ref(defaultFilters)
  const searchQuery = ref('')
  
  const tableResource = // REMOVED: createResource - use frappe.call()({
    url: endpoint,
    params: computed(() => ({
      page: page.value,
      page_size: pageSize.value,
      sort_by: sortBy.value,
      sort_order: sortOrder.value,
      filters: {
        ...filters.value,
        ...(searchQuery.value && {
          name: ['like', `%${searchQuery.value}%`]
        })
      }
    })),
    auto: true,
    debounce: 300
  })
  
  const data = computed(() => tableResource.data?.data || [])
  const totalPages = computed(() => tableResource.data?.pagination?.total_pages || 1)
  const totalItems = computed(() => tableResource.data?.pagination?.total_items || 0)
  
  function updateSort(field) {
    if (sortBy.value === field) {
      sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
    } else {
      sortBy.value = field
      sortOrder.value = 'asc'
    }
    page.value = 1
  }
  
  function updatePage(newPage) {
    page.value = Math.max(1, Math.min(newPage, totalPages.value))
  }
  
  function updatePageSize(size) {
    pageSize.value = size
    page.value = 1
  }
  
  function updateFilters(newFilters) {
    filters.value = { ...filters.value, ...newFilters }
    page.value = 1
  }
  
  function search(query) {
    searchQuery.value = query
    page.value = 1
  }
  
  function refresh() {
    tableResource.reload()
  }
  
  // Auto-refresh when parameters change
  watch([page, pageSize, sortBy, sortOrder, filters, searchQuery], () => {
    tableResource.reload()
  }, { deep: true })
  
  return {
    // Data
    data,
    loading: tableResource.loading,
    error: tableResource.error,
    
    // Pagination
    page,
    pageSize,
    totalPages,
    totalItems,
    
    // Sorting
    sortBy,
    sortOrder,
    
    // Methods
    updateSort,
    updatePage,
    updatePageSize,
    updateFilters,
    search,
    refresh
  }
}
```

### 2. Virtual Scrolling for Large Lists
```vue
<template>
  <div 
    class="virtual-scroll-container"
    ref="container"
    @scroll="onScroll"
    :style="{ height: containerHeight + 'px', overflow: 'auto' }"
  >
    <div :style="{ height: totalHeight + 'px', position: 'relative' }">
      <div
        v-for="item in visibleItems"
        :key="item.id"
        :style="{
          position: 'absolute',
          top: item.top + 'px',
          left: 0,
          right: 0,
          height: itemHeight + 'px'
        }"
      >
        <slot :item="item.data" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  items: Array,
  itemHeight: {
    type: Number,
    default: 50
  },
  containerHeight: {
    type: Number,
    default: 400
  },
  buffer: {
    type: Number,
    default: 5
  }
})

const container = ref(null)
const scrollTop = ref(0)

const totalHeight = computed(() => props.items.length * props.itemHeight)

const visibleItems = computed(() => {
  const start = Math.floor(scrollTop.value / props.itemHeight)
  const visibleCount = Math.ceil(props.containerHeight / props.itemHeight)
  
  const startIndex = Math.max(0, start - props.buffer)
  const endIndex = Math.min(
    props.items.length - 1,
    start + visibleCount + props.buffer
  )
  
  const items = []
  for (let i = startIndex; i <= endIndex; i++) {
    items.push({
      id: props.items[i].id || i,
      data: props.items[i],
      top: i * props.itemHeight
    })
  }
  
  return items
})

function onScroll() {
  scrollTop.value = container.value.scrollTop
}

onMounted(() => {
  if (container.value) {
    container.value.addEventListener('scroll', onScroll, { passive: true })
  }
})

onUnmounted(() => {
  if (container.value) {
    container.value.removeEventListener('scroll', onScroll)
  }
})
</script>
```

## Performance Optimization Tips

1. **Use appropriate page sizes** - Balance between performance and UX
2. **Implement debouncing** for search and filter inputs
3. **Cache previous pages** for quick navigation
4. **Use cursor-based pagination** for real-time data
5. **Implement virtual scrolling** for very large lists
6. **Add loading skeletons** for better perceived performance
7. **Prefetch next page** for smoother navigation
8. **Use indexes** on sort and filter fields in database
9. **Implement server-side filtering** instead of client-side
10. **Consider using GraphQL** for flexible data fetching

## Best Practices

1. **Always validate page parameters** on the backend
2. **Set reasonable limits** on page size (e.g., max 100)
3. **Include metadata** in responses (total count, pages, etc.)
4. **Handle edge cases** (empty results, invalid page numbers)
5. **Provide multiple navigation options** (first, last, page jump)
6. **Show loading states** during data fetching
7. **Cache results** when appropriate
8. **Use meaningful error messages**
9. **Implement keyboard navigation** for accessibility
10. **Test with large datasets** to ensure performance