# Task: Design Responsive Layouts

## Description
Design and implement responsive, accessible, and user-friendly layouts for ERPNext applications using modern UI/UX principles, Frappe UI components, and mobile-first design approaches.

## Required Agents
- ui-layout-designer
- frappe-ui-developer
- mobile-ui-specialist

## Input Requirements
1. **Design Requirements**:
   - Target devices and screen sizes
   - User personas and workflows
   - Brand guidelines
   - Accessibility requirements

2. **Technical Constraints**:
   - Browser support requirements
   - Performance targets
   - Framework limitations
   - Integration requirements

## Process Steps

### 1. Layout Planning
```yaml
layout_strategy:
  design_system:
    grid_system: "12-column responsive grid"
    breakpoints:
      xs: "0-575px"     # Mobile portrait
      sm: "576-767px"   # Mobile landscape
      md: "768-991px"   # Tablet
      lg: "992-1199px"  # Desktop
      xl: "1200px+"     # Large desktop
      
  layout_patterns:
    dashboard:
      mobile: "Single column cards"
      tablet: "2-column grid"
      desktop: "3-4 column grid with sidebar"
      
    list_view:
      mobile: "Card layout"
      tablet: "Condensed table"
      desktop: "Full table with filters"
      
    form_view:
      mobile: "Single column"
      tablet: "2-column sections"
      desktop: "Multi-column with sidebar"
      
  spacing_system:
    base_unit: "8px"
    spacing_scale:
      xs: "4px"
      sm: "8px"
      md: "16px"
      lg: "24px"
      xl: "32px"
      xxl: "48px"
```

### 2. Component Layout Design
```vue
<!-- ResponsiveLayout.vue -->
<template>
  <div class="responsive-layout">
    <!-- Mobile Navigation -->
    <nav 
      v-if="isMobile" 
      class="mobile-nav fixed bottom-0 left-0 right-0 z-50 bg-white border-t"
    >
      <div class="flex justify-around py-2">
        <button 
          v-for="item in mobileNavItems" 
          :key="item.name"
          @click="navigateTo(item.route)"
          class="flex flex-col items-center p-2"
        >
          <Icon :name="item.icon" size="20" />
          <span class="text-xs mt-1">{{ item.label }}</span>
        </button>
      </div>
    </nav>
    
    <!-- Desktop Sidebar -->
    <aside 
      v-if="!isMobile"
      class="sidebar"
      :class="{ 'collapsed': sidebarCollapsed }"
    >
      <div class="sidebar-header">
        <img :src="logo" alt="Logo" class="h-8" />
        <button 
          @click="toggleSidebar"
          class="ml-auto"
        >
          <Icon :name="sidebarCollapsed ? 'menu' : 'x'" />
        </button>
      </div>
      
      <nav class="sidebar-nav">
        <ul class="space-y-1">
          <li v-for="item in navItems" :key="item.name">
            <router-link
              :to="item.route"
              class="nav-link flex items-center px-4 py-2 hover:bg-gray-100"
              active-class="bg-blue-50 text-blue-600"
            >
              <Icon :name="item.icon" class="mr-3" />
              <span v-if="!sidebarCollapsed">{{ item.label }}</span>
            </router-link>
          </li>
        </ul>
      </nav>
    </aside>
    
    <!-- Main Content Area -->
    <main 
      class="main-content"
      :class="{ 'with-sidebar': !isMobile, 'sidebar-collapsed': sidebarCollapsed }"
    >
      <!-- Page Header -->
      <header class="page-header sticky top-0 bg-white border-b z-40">
        <div class="flex items-center justify-between px-4 py-3">
          <div class="flex items-center flex-1">
            <button 
              v-if="isMobile"
              @click="showMobileMenu = true"
              class="mr-3"
            >
              <Icon name="menu" />
            </button>
            
            <Breadcrumbs :items="breadcrumbs" class="hidden md:flex" />
            <h1 class="text-lg font-semibold md:hidden">{{ pageTitle }}</h1>
          </div>
          
          <div class="flex items-center space-x-2">
            <Button 
              v-if="showSearch"
              variant="ghost"
              @click="openSearch"
            >
              <Icon name="search" />
            </Button>
            
            <NotificationDropdown />
            <UserMenu />
          </div>
        </div>
      </header>
      
      <!-- Page Content -->
      <div class="page-content">
        <div class="container-responsive">
          <slot />
        </div>
      </div>
    </main>
    
    <!-- Mobile Menu Drawer -->
    <Drawer v-model="showMobileMenu" position="left">
      <div class="p-4">
        <h2 class="text-lg font-semibold mb-4">Menu</h2>
        <nav>
          <ul class="space-y-2">
            <li v-for="item in navItems" :key="item.name">
              <router-link
                :to="item.route"
                @click="showMobileMenu = false"
                class="flex items-center p-2 rounded hover:bg-gray-100"
              >
                <Icon :name="item.icon" class="mr-3" />
                <span>{{ item.label }}</span>
              </router-link>
            </li>
          </ul>
        </nav>
      </div>
    </Drawer>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useBreakpoints } from '@/composables/useBreakpoints'

const { isMobile, isTablet, isDesktop } = useBreakpoints()
const sidebarCollapsed = ref(false)
const showMobileMenu = ref(false)

// Responsive container classes
const containerClasses = computed(() => {
  return {
    'px-4': isMobile.value,
    'px-6': isTablet.value,
    'px-8': isDesktop.value,
    'max-w-7xl mx-auto': isDesktop.value
  }
})
</script>
```

### 3. Responsive Grid System
```css
/* Responsive Grid System */
.grid-responsive {
  display: grid;
  gap: var(--grid-gap, 1rem);
}

/* Mobile First Grid */
@media (min-width: 0) {
  .grid-responsive {
    grid-template-columns: 1fr;
  }
}

@media (min-width: 576px) {
  .grid-responsive {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 768px) {
  .grid-responsive {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (min-width: 992px) {
  .grid-responsive {
    grid-template-columns: repeat(4, 1fr);
  }
}

@media (min-width: 1200px) {
  .grid-responsive {
    grid-template-columns: repeat(6, 1fr);
  }
}

/* Flexible Grid with Auto-fit */
.grid-auto {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 250px), 1fr));
  gap: 1rem;
}

/* Asymmetric Layouts */
.layout-dashboard {
  display: grid;
  gap: 1rem;
  grid-template-areas:
    "header"
    "stats"
    "chart"
    "table"
    "sidebar";
}

@media (min-width: 768px) {
  .layout-dashboard {
    grid-template-columns: 1fr 1fr;
    grid-template-areas:
      "header header"
      "stats stats"
      "chart table"
      "sidebar sidebar";
  }
}

@media (min-width: 1200px) {
  .layout-dashboard {
    grid-template-columns: 1fr 1fr 300px;
    grid-template-areas:
      "header header sidebar"
      "stats stats sidebar"
      "chart table sidebar";
  }
}
```

### 4. Adaptive Components
```javascript
// adaptiveComponents.js
export const AdaptiveTable = {
  props: ['data', 'columns'],
  
  setup(props) {
    const { isMobile } = useBreakpoints()
    
    const displayMode = computed(() => {
      return isMobile.value ? 'cards' : 'table'
    })
    
    const visibleColumns = computed(() => {
      if (isMobile.value) {
        // Show only essential columns on mobile
        return props.columns.filter(col => col.priority === 'high')
      }
      return props.columns
    })
    
    return {
      displayMode,
      visibleColumns
    }
  },
  
  template: `
    <div class="adaptive-table">
      <!-- Mobile Card View -->
      <div v-if="displayMode === 'cards'" class="space-y-4">
        <div 
          v-for="row in data" 
          :key="row.id"
          class="card p-4 bg-white rounded-lg shadow"
        >
          <div v-for="col in visibleColumns" :key="col.key" class="mb-2">
            <span class="text-xs text-gray-500">{{ col.label }}:</span>
            <span class="ml-2 font-medium">{{ row[col.key] }}</span>
          </div>
        </div>
      </div>
      
      <!-- Desktop Table View -->
      <table v-else class="table w-full">
        <thead>
          <tr>
            <th v-for="col in visibleColumns" :key="col.key">
              {{ col.label }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in data" :key="row.id">
            <td v-for="col in visibleColumns" :key="col.key">
              {{ row[col.key] }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  `
}
```

### 5. Accessibility Features
```javascript
// accessibility.js
export const accessibilityMixin = {
  mounted() {
    // Keyboard navigation
    this.setupKeyboardNavigation()
    
    // Screen reader announcements
    this.setupAriaLive()
    
    // Focus management
    this.setupFocusManagement()
  },
  
  methods: {
    setupKeyboardNavigation() {
      document.addEventListener('keydown', (e) => {
        // Tab navigation
        if (e.key === 'Tab') {
          this.handleTabNavigation(e)
        }
        
        // Escape key
        if (e.key === 'Escape') {
          this.handleEscapeKey(e)
        }
        
        // Arrow key navigation
        if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(e.key)) {
          this.handleArrowNavigation(e)
        }
      })
    },
    
    setupAriaLive() {
      // Create aria-live region for announcements
      const liveRegion = document.createElement('div')
      liveRegion.setAttribute('aria-live', 'polite')
      liveRegion.setAttribute('aria-atomic', 'true')
      liveRegion.className = 'sr-only'
      document.body.appendChild(liveRegion)
      
      this.$ariaAnnounce = (message) => {
        liveRegion.textContent = message
      }
    },
    
    setupFocusManagement() {
      // Trap focus in modals
      this.$trapFocus = (element) => {
        const focusableElements = element.querySelectorAll(
          'a, button, input, textarea, select, [tabindex]:not([tabindex="-1"])'
        )
        
        const firstFocusable = focusableElements[0]
        const lastFocusable = focusableElements[focusableElements.length - 1]
        
        element.addEventListener('keydown', (e) => {
          if (e.key === 'Tab') {
            if (e.shiftKey && document.activeElement === firstFocusable) {
              e.preventDefault()
              lastFocusable.focus()
            } else if (!e.shiftKey && document.activeElement === lastFocusable) {
              e.preventDefault()
              firstFocusable.focus()
            }
          }
        })
      }
    }
  }
}
```

### 6. Performance Optimization
```javascript
// performanceOptimization.js
export const useLayoutPerformance = () => {
  // Lazy load components
  const lazyLoadComponent = (componentPath) => {
    return defineAsyncComponent(() => import(componentPath))
  }
  
  // Virtual scrolling for large lists
  const useVirtualScroll = (items, itemHeight = 50) => {
    const containerRef = ref(null)
    const scrollTop = ref(0)
    const containerHeight = ref(0)
    
    const visibleItems = computed(() => {
      const startIndex = Math.floor(scrollTop.value / itemHeight)
      const endIndex = Math.ceil(
        (scrollTop.value + containerHeight.value) / itemHeight
      )
      
      return items.value.slice(startIndex, endIndex)
    })
    
    return { containerRef, visibleItems }
  }
  
  // Debounce resize events
  const useResizeObserver = (callback, delay = 100) => {
    let timeoutId
    
    const observer = new ResizeObserver((entries) => {
      clearTimeout(timeoutId)
      timeoutId = setTimeout(() => {
        callback(entries)
      }, delay)
    })
    
    return observer
  }
  
  // Optimize images
  const optimizeImage = (src, options = {}) => {
    const { width, quality = 80, format = 'webp' } = options
    
    // Use image CDN or processing service
    return `${CDN_URL}/optimize?src=${src}&w=${width}&q=${quality}&f=${format}`
  }
  
  return {
    lazyLoadComponent,
    useVirtualScroll,
    useResizeObserver,
    optimizeImage
  }
}
```

## Output Format

### Layout Specifications
```yaml
layout_design:
  name: "ERPNext Dashboard Layout"
  version: "1.0.0"
  
  breakpoints:
    mobile: "320-767px"
    tablet: "768-1023px"
    desktop: "1024px+"
    
  grid_system:
    columns: 12
    gutter: "16px"
    margin: "auto"
    
  components:
    header:
      height: "64px"
      position: "sticky"
      z_index: 1000
      
    sidebar:
      width: "240px"
      collapsed_width: "64px"
      breakpoint: "tablet+"
      
    content:
      max_width: "1400px"
      padding:
        mobile: "16px"
        tablet: "24px"
        desktop: "32px"
        
  color_scheme:
    primary: "#1E40AF"
    secondary: "#10B981"
    background: "#F9FAFB"
    surface: "#FFFFFF"
    text: "#111827"
    
  typography:
    font_family: "Inter, system-ui, sans-serif"
    scale:
      xs: "12px"
      sm: "14px"
      base: "16px"
      lg: "18px"
      xl: "20px"
      2xl: "24px"
      3xl: "30px"
      
  animations:
    duration: "200ms"
    easing: "cubic-bezier(0.4, 0, 0.2, 1)"
```

## Success Criteria
- Responsive on all target devices
- Passes WCAG 2.1 AA accessibility
- Page load time < 3 seconds
- First contentful paint < 1.5s
- Consistent across browsers
- Touch-friendly on mobile

## Common Patterns

### Layout Patterns
```yaml
common_patterns:
  navigation:
    - Top navigation bar
    - Side navigation drawer
    - Bottom tab bar (mobile)
    - Breadcrumb navigation
    
  content:
    - Card-based layouts
    - List/grid toggles
    - Collapsible sections
    - Tab interfaces
    
  forms:
    - Single column (mobile)
    - Multi-column (desktop)
    - Inline validation
    - Progressive disclosure
    
  data_display:
    - Responsive tables
    - Chart adaptations
    - Card summaries
    - Data grids
```

## Error Handling

### Layout Issues
1. **Overflow Content**: Implement horizontal scroll
2. **Text Truncation**: Use ellipsis with tooltips
3. **Image Loading**: Show placeholders
4. **Layout Shift**: Reserve space for dynamic content
5. **Touch Targets**: Ensure minimum 44x44px

## Dependencies
- Vue 3 framework
- Frappe UI components
- TailwindCSS
- Breakpoint detection
- ResizeObserver API

## Next Steps
After layout design:
1. Create interactive prototypes
2. Conduct usability testing
3. Implement responsive components
4. Test on actual devices
5. Optimize performance