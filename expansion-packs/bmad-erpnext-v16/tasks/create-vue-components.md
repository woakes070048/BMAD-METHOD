# Task: Create Native Vue Components for ERPNext

## Purpose
Create native Vue 3 components that integrate directly with Frappe's asset pipeline - NO separate frontend application

## Prerequisites
- ERPNext app already created with `bench new-app`
- Understanding of Frappe's page system
- Vue 3 knowledge (Composition API)
- NO separate Node.js setup needed

## Input Requirements
```yaml
app_name: String # Name of the ERPNext app (snake_case)
feature_name: String # Name of the feature/page (snake_case)
page_title: String # Display title for the page
doctype: String # Primary DocType to work with
module_name: String # Module for the page (e.g., "Selling")
```

## Step-by-Step Implementation

### 1. Create Page Structure
```bash
# Navigate to your app
cd apps/{{app_name}}

# Create page directory
mkdir -p {{app_name}}/{{module_name}}/page/{{feature_name}}

# Create component directory
mkdir -p {{app_name}}/public/js/{{feature_name}}/components
```

### 2. Create the Page Definition
Create `{{app_name}}/{{module_name}}/page/{{feature_name}}/{{feature_name}}.json`:
```json
{
  "content": null,
  "creation": "2024-01-01 00:00:00.000000",
  "docstatus": 0,
  "doctype": "Page",
  "module": "{{module_name}}",
  "name": "{{feature_name}}",
  "page_name": "{{feature_name}}",
  "roles": [
    {"role": "System Manager"},
    {"role": "All"}
  ],
  "script": null,
  "standard": "Yes",
  "style": null,
  "title": "{{page_title}}"
}
```

### 3. Create the Page JavaScript
Create `{{app_name}}/{{module_name}}/page/{{feature_name}}/{{feature_name}}.js`:
```javascript
frappe.pages['{{feature_name}}'].on_page_load = function(wrapper) {
    frappe.require('{{feature_name}}.bundle.js').then(() => {
        new frappe.ui.{{feature_name|pascalcase}}(wrapper);
    });
}
```

### 4. Create the Bundle Entry Point
Create `{{app_name}}/public/js/{{feature_name}}.bundle.js`:
```javascript
import { createApp } from "vue";
import {{feature_name|pascalcase}}Component from "./{{feature_name}}/{{feature_name|pascalcase}}.vue";
import { createPinia } from "pinia";
import { useStore } from "./{{feature_name}}/store";

class {{feature_name|pascalcase}} {
    constructor(wrapper) {
        this.$wrapper = $(wrapper);
        this.page = wrapper.page;
        
        this.setup_page();
        this.mount_component();
    }
    
    setup_page() {
        this.page.set_title(__("{{page_title}}"));
        
        // Add page actions
        this.page.set_primary_action(__("Save"), () => {
            this.$store.save();
        });
        
        this.page.set_secondary_action(__("Refresh"), () => {
            this.$store.refresh();
        });
        
        // Add menu items
        this.page.add_menu_item(__("Export"), () => {
            this.$store.export();
        });
    }
    
    mount_component() {
        // Create Vue app
        const app = createApp({{feature_name|pascalcase}}Component);
        
        // CRITICAL: Set up Frappe globals
        SetVueGlobals(app);
        
        // Add Pinia for state management
        const pinia = createPinia();
        app.use(pinia);
        
        // Mount the app
        this.$component = app.mount(this.$wrapper.get(0));
        
        // Get store reference
        this.$store = useStore();
        
        // Initialize data
        this.$store.init();
    }
}

// Export for page use
frappe.provide("frappe.ui");
frappe.ui.{{feature_name|pascalcase}} = {{feature_name|pascalcase}};
```

### 5. Create the Main Vue Component
Create `{{app_name}}/public/js/{{feature_name}}/{{feature_name|pascalcase}}.vue`:
```vue
<template>
  <div class="{{feature_name}}-container">
    <div class="frappe-card">
      <!-- Header -->
      <div class="flex justify-between items-center mb-4">
        <h3>{{ __('{{page_title}}') }}</h3>
        <button 
          class="btn btn-primary btn-sm"
          @click="showCreateDialog = true"
        >
          {{ __('New') }}
        </button>
      </div>
      
      <!-- Filters -->
      <div class="row mb-3">
        <div class="col-md-4">
          <input 
            v-model="searchQuery"
            type="text"
            class="form-control"
            :placeholder="__('Search...')"
            @input="handleSearch"
          />
        </div>
      </div>
      
      <!-- List -->
      <ListView 
        :items="store.items"
        :loading="store.loading"
        @select="handleSelect"
        @edit="handleEdit"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useStore } from './store';
import ListView from './components/ListView.vue';

// Access Frappe globals
const { __ } = window;
const { frappe } = window;

// Store
const store = useStore();

// Local state
const searchQuery = ref('');
const showCreateDialog = ref(false);

// Methods
function handleSearch() {
  store.search(searchQuery.value);
}

function handleSelect(item) {
  store.selectItem(item);
}

function handleEdit(item) {
  frappe.set_route('Form', '{{doctype}}', item.name);
}

// Lifecycle
onMounted(() => {
  store.loadInitialData();
});
</script>

<style scoped>
.{{feature_name}}-container {
  padding: var(--padding-lg);
}
</style>
```

### 6. Create the Pinia Store
Create `{{app_name}}/public/js/{{feature_name}}/store.js`:
```javascript
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const useStore = defineStore('{{feature_name}}', () => {
  // State
  const items = ref([]);
  const loading = ref(false);
  const selectedItems = ref([]);
  
  // Actions
  async function init() {
    await loadInitialData();
  }
  
  async function loadInitialData() {
    loading.value = true;
    try {
      const response = await frappe.call({
        method: 'frappe.client.get_list',
        args: {
          doctype: '{{doctype}}',
          fields: ['*'],
          order_by: 'modified desc',
          limit: 100
        }
      });
      items.value = response.message || [];
    } catch (error) {
      frappe.throw(__('Failed to load data'));
    } finally {
      loading.value = false;
    }
  }
  
  async function search(query) {
    // Implement search logic
    loading.value = true;
    try {
      const response = await frappe.call({
        method: 'frappe.client.get_list',
        args: {
          doctype: '{{doctype}}',
          filters: [
            ['name', 'like', `%${query}%`]
          ],
          fields: ['*']
        }
      });
      items.value = response.message || [];
    } finally {
      loading.value = false;
    }
  }
  
  function selectItem(item) {
    selectedItems.value.push(item);
  }
  
  async function save() {
    frappe.show_alert(__('Saving...'));
    // Implement save logic
  }
  
  async function refresh() {
    await loadInitialData();
  }
  
  async function export() {
    frappe.show_alert(__('Exporting...'));
    // Implement export logic
  }
  
  return {
    // State
    items,
    loading,
    selectedItems,
    
    // Actions
    init,
    loadInitialData,
    search,
    selectItem,
    save,
    refresh,
    export
  };
});
```

### 7. Create a List Component
Create `{{app_name}}/public/js/{{feature_name}}/components/ListView.vue`:
```vue
<template>
  <div class="list-view">
    <div v-if="loading" class="text-center py-4">
      <span class="text-muted">{{ __('Loading...') }}</span>
    </div>
    
    <div v-else-if="!items.length" class="text-center py-8">
      <p class="text-muted">{{ __('No items found') }}</p>
    </div>
    
    <div v-else>
      <div 
        v-for="item in items" 
        :key="item.name"
        class="list-item border-bottom py-2"
        @click="$emit('select', item)"
      >
        <div class="row">
          <div class="col-md-6">
            <strong>{{ item.name }}</strong>
          </div>
          <div class="col-md-4">
            {{ item.status || '-' }}
          </div>
          <div class="col-md-2 text-right">
            <button 
              class="btn btn-xs btn-default"
              @click.stop="$emit('edit', item)"
            >
              {{ __('Edit') }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  items: Array,
  loading: Boolean
});

defineEmits(['select', 'edit']);

const { __ } = window;
</script>

<style scoped>
.list-item {
  cursor: pointer;
  transition: background-color 0.2s;
}

.list-item:hover {
  background-color: var(--bg-light);
}
</style>
```

### 8. Build the Assets
```bash
# Build your app's assets
bench build --app {{app_name}}

# In development, use watch mode
bench start
```

### 9. Access Your Page
```bash
# Clear cache
bench --site [site-name] clear-cache

# Access at:
# http://[site-name]:8000/app/{{feature_name}}
```

## Key Differences from Traditional Vue Apps

### What You DON'T Need:
- ❌ No `/frontend/` directory
- ❌ No separate package.json
- ❌ No Vite/webpack configuration
- ❌ No Vue Router
- ❌ No axios for API calls
- ❌ No separate dev server

### What You MUST Do:
- ✅ Use `.bundle.js` entry points
- ✅ Call `SetVueGlobals(app)`
- ✅ Use `frappe.call()` for APIs
- ✅ Use Frappe's page system
- ✅ Build with `bench build`
- ✅ Structure in `public/js/`

## API Integration

Always use Frappe's methods:
```javascript
// ✅ CORRECT
await frappe.call({
  method: 'app.api.method',
  args: { param: value }
});

// ❌ WRONG
await axios.post('/api/method', { param: value });
```

## Styling

Use Frappe's built-in classes:
- Bootstrap 4 classes
- Frappe utility classes
- CSS variables (--padding-lg, --border-color, etc.)

## Common Patterns

### Loading States
```javascript
const loading = ref(false);
async function fetchData() {
  loading.value = true;
  try {
    // fetch data
  } finally {
    loading.value = false;
  }
}
```

### Error Handling
```javascript
try {
  // operation
} catch (error) {
  frappe.msgprint({
    title: __('Error'),
    message: error.message,
    indicator: 'red'
  });
}
```

### Success Messages
```javascript
frappe.show_alert({
  message: __('Saved successfully'),
  indicator: 'green'
});
```

## Validation Checklist
- [ ] Page loads without errors
- [ ] Vue DevTools detects the app
- [ ] Components render correctly
- [ ] API calls work via frappe.call()
- [ ] Styles apply correctly
- [ ] Build completes without errors
- [ ] No console errors in browser

## Next Steps
1. Add more components as needed
2. Implement business logic
3. Add validations
4. Test thoroughly
5. Deploy to production