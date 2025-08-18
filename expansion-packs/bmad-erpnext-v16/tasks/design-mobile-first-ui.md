# Task: Design Mobile-First UI

## Description
Design and implement mobile-first responsive user interfaces for ERPNext applications using Vue 3, frappe-ui components, and modern mobile design patterns. Focus on touch interactions, performance, and offline capabilities.

## Required Agents
- mobile-ui-specialist
- vue-frontend-architect
- pwa-specialist
- frappe-ui-developer

## Input Requirements
1. **Application Requirements**:
   - Target mobile devices and screen sizes
   - User workflows and interactions
   - Performance requirements
   - Offline functionality needs

2. **Design Assets**:
   - Brand guidelines
   - Color schemes
   - Typography specifications
   - Icon sets

## Process Steps

### 1. Mobile Layout Design
```yaml
responsive_breakpoints:
  mobile_portrait: "320px - 480px"
  mobile_landscape: "481px - 768px"
  tablet: "769px - 1024px"
  desktop: "1025px+"
  
layout_strategy:
  mobile_first: true
  fluid_grids: true
  flexible_images: true
  css_grid_and_flexbox: true
```

### 2. Vue Component Structure
```vue
<!-- MobileLayout.vue -->
<template>
  <div class="mobile-container">
    <!-- Mobile Header -->
    <header class="mobile-header fixed top-0 w-full z-50">
      <div class="flex items-center justify-between p-4">
        <button @click="toggleMenu" class="menu-trigger">
          <Icon name="menu" size="24" />
        </button>
        <h1 class="text-lg font-semibold">{{ pageTitle }}</h1>
        <button @click="showActions" class="action-trigger">
          <Icon name="more-vertical" size="24" />
        </button>
      </div>
    </header>

    <!-- Slide-out Navigation -->
    <transition name="slide">
      <nav v-if="menuOpen" class="mobile-nav fixed left-0 top-0 h-full w-64 z-40">
        <MobileNavigation @close="menuOpen = false" />
      </nav>
    </transition>

    <!-- Main Content Area -->
    <main class="mobile-content pt-16 pb-20">
      <div class="container px-4">
        <slot />
      </div>
    </main>

    <!-- Bottom Navigation -->
    <nav class="mobile-bottom-nav fixed bottom-0 w-full z-50">
      <div class="flex justify-around py-2">
        <button
          v-for="tab in bottomTabs"
          :key="tab.name"
          @click="navigateTo(tab.route)"
          class="tab-item flex flex-col items-center p-2"
          :class="{ active: currentRoute === tab.route }"
        >
          <Icon :name="tab.icon" size="20" />
          <span class="text-xs mt-1">{{ tab.label }}</span>
        </button>
      </div>
    </nav>

    <!-- Floating Action Button -->
    <button
      v-if="showFAB"
      @click="primaryAction"
      class="fab fixed bottom-24 right-4 w-14 h-14 rounded-full shadow-lg z-30"
    >
      <Icon name="plus" size="24" />
    </button>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
// REMOVED: frappe-ui import - use native components

const route = useRoute()
const router = useRouter()

const menuOpen = ref(false)
const currentRoute = computed(() => route.path)

const bottomTabs = [
  { name: 'home', label: 'Home', icon: 'home', route: '/' },
  { name: 'list', label: 'Items', icon: 'list', route: '/items' },
  { name: 'reports', label: 'Reports', icon: 'bar-chart', route: '/reports' },
  { name: 'profile', label: 'Profile', icon: 'user', route: '/profile' }
]
</script>
```

### 3. Touch Interaction Implementation
```javascript
// touchInteractions.js
import { ref, onMounted, onUnmounted } from 'vue'

export function useSwipeGesture(element, options = {}) {
  const touchStart = ref({ x: 0, y: 0 })
  const touchEnd = ref({ x: 0, y: 0 })
  const minSwipeDistance = options.minDistance || 50

  const handleTouchStart = (e) => {
    touchStart.value = {
      x: e.touches[0].clientX,
      y: e.touches[0].clientY
    }
  }

  const handleTouchEnd = (e) => {
    touchEnd.value = {
      x: e.changedTouches[0].clientX,
      y: e.changedTouches[0].clientY
    }
    detectSwipe()
  }

  const detectSwipe = () => {
    const deltaX = touchEnd.value.x - touchStart.value.x
    const deltaY = touchEnd.value.y - touchStart.value.y

    if (Math.abs(deltaX) > Math.abs(deltaY)) {
      // Horizontal swipe
      if (Math.abs(deltaX) > minSwipeDistance) {
        if (deltaX > 0) {
          options.onSwipeRight?.()
        } else {
          options.onSwipeLeft?.()
        }
      }
    } else {
      // Vertical swipe
      if (Math.abs(deltaY) > minSwipeDistance) {
        if (deltaY > 0) {
          options.onSwipeDown?.()
        } else {
          options.onSwipeUp?.()
        }
      }
    }
  }

  onMounted(() => {
    element.value?.addEventListener('touchstart', handleTouchStart)
    element.value?.addEventListener('touchend', handleTouchEnd)
  })

  onUnmounted(() => {
    element.value?.removeEventListener('touchstart', handleTouchStart)
    element.value?.removeEventListener('touchend', handleTouchEnd)
  })
}

// Pull-to-refresh implementation
export function usePullToRefresh(onRefresh) {
  const isPulling = ref(false)
  const pullDistance = ref(0)
  const threshold = 80

  const handleTouchMove = (e) => {
    if (window.scrollY === 0 && e.touches[0].clientY > 0) {
      isPulling.value = true
      pullDistance.value = Math.min(e.touches[0].clientY, threshold * 1.5)
    }
  }

  const handleTouchEnd = async () => {
    if (isPulling.value && pullDistance.value > threshold) {
      await onRefresh()
    }
    isPulling.value = false
    pullDistance.value = 0
  }

  return { isPulling, pullDistance }
}
```

### 4. Mobile-Optimized List View
```vue
<!-- MobileListView.vue -->
<template>
  <div class="mobile-list-view">
    <!-- Search and Filter Bar -->
    <div class="search-filter-bar sticky top-0 bg-white z-10 p-4">
      <div class="flex gap-2">
        <Input
          v-model="searchQuery"
          type="search"
          placeholder="Search..."
          class="flex-1"
          @input="debouncedSearch"
        />
        <Button variant="ghost" @click="showFilters = true">
          <Icon name="filter" />
        </Button>
      </div>
    </div>

    <!-- Virtual Scroll List -->
    <RecycleScroller
      :items="filteredItems"
      :item-size="80"
      key-field="name"
      v-slot="{ item }"
      class="scroller"
    >
      <div class="list-item p-4 border-b" @click="selectItem(item)">
        <div class="flex items-center justify-between">
          <div class="flex-1">
            <h3 class="font-medium">{{ item.title }}</h3>
            <p class="text-sm text-gray-600">{{ item.description }}</p>
          </div>
          <Icon name="chevron-right" class="text-gray-400" />
        </div>
      </div>
    </RecycleScroller>

    <!-- Empty State -->
    <div v-if="!filteredItems.length" class="empty-state p-8 text-center">
      <Icon name="inbox" size="48" class="text-gray-400 mb-4" />
      <p class="text-gray-600">No items found</p>
    </div>

    <!-- Filter Sheet -->
    <BottomSheet v-model="showFilters">
      <FilterPanel @apply="applyFilters" @reset="resetFilters" />
    </BottomSheet>
  </div>
</template>
```

### 5. Performance Optimization
```javascript
// mobileOptimizations.js

// Lazy load images
export const lazyLoadImages = {
  mounted(el) {
    const imageObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target
          img.src = img.dataset.src
          img.classList.add('loaded')
          imageObserver.unobserve(img)
        }
      })
    })
    imageObserver.observe(el)
  }
}

// Debounce touch events
export function debounceTouch(func, wait = 100) {
  let timeout
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout)
      func(...args)
    }
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
  }
}

// Request idle callback for non-critical updates
export function scheduleIdleTask(callback) {
  if ('requestIdleCallback' in window) {
    requestIdleCallback(callback)
  } else {
    setTimeout(callback, 1)
  }
}
```

### 6. Offline Support
```javascript
// offlineSync.js
import { ref, computed } from 'vue'

export function useOfflineSync() {
  const isOnline = ref(navigator.onLine)
  const pendingSync = ref([])

  // Monitor connection status
  window.addEventListener('online', () => {
    isOnline.value = true
    syncPendingData()
  })

  window.addEventListener('offline', () => {
    isOnline.value = false
  })

  const queueForSync = (action) => {
    pendingSync.value.push({
      id: Date.now(),
      action,
      timestamp: new Date().toISOString()
    })
    
    // Store in IndexedDB for persistence
    saveToIndexedDB(pendingSync.value)
  }

  const syncPendingData = async () => {
    if (!isOnline.value || pendingSync.value.length === 0) return

    for (const item of pendingSync.value) {
      try {
        await executeAction(item.action)
        pendingSync.value = pendingSync.value.filter(i => i.id !== item.id)
      } catch (error) {
        console.error('Sync failed for item:', item.id)
      }
    }
  }

  return {
    isOnline,
    pendingSync,
    queueForSync,
    syncPendingData
  }
}
```

## Output Format

### Mobile UI Implementation
```yaml
mobile_ui_components:
  layouts:
    - MobileLayout.vue
    - TabletLayout.vue
    - ResponsiveWrapper.vue
    
  navigation:
    - BottomNavigation.vue
    - SlideMenu.vue
    - MobileHeader.vue
    
  interactions:
    - SwipeableList.vue
    - PullToRefresh.vue
    - TouchGestures.vue
    
  optimizations:
    - VirtualScroll.vue
    - LazyLoad.vue
    - OfflineIndicator.vue
```

## Success Criteria
- Responsive on all mobile devices
- Touch interactions smooth and intuitive
- Load time under 3 seconds on 3G
- Offline functionality working
- Accessibility standards met (WCAG 2.1)
- Performance score > 90 on Lighthouse

## Common Patterns

### Mobile Design Patterns
```yaml
ui_patterns:
  navigation:
    - Bottom navigation (3-5 items)
    - Hamburger menu for secondary items
    - Swipe navigation between screens
    - Tab bars for content sections
    
  interactions:
    - Swipe to delete/archive
    - Pull to refresh
    - Long press for context menu
    - Pinch to zoom
    
  feedback:
    - Haptic feedback for actions
    - Loading skeletons
    - Progress indicators
    - Toast notifications
```

## Error Handling

### Mobile-Specific Issues
1. **Network Connectivity**: Show offline indicator
2. **Touch Failures**: Provide fallback interactions
3. **Small Targets**: Ensure 44x44px minimum
4. **Orientation Changes**: Handle layout shifts
5. **Memory Constraints**: Implement cleanup

## Validation Steps
1. Test on real devices (iOS and Android)
2. Check different screen sizes
3. Verify touch interactions
4. Test offline functionality
5. Validate performance metrics

## Dependencies
- Vue 3 with Composition API
- frappe-ui components
- TailwindCSS for styling
- Service Worker for offline
- IndexedDB for local storage

## Next Steps
After mobile UI implementation:
1. Conduct user testing
2. Optimize performance bottlenecks
3. Add PWA features
4. Implement push notifications
5. Create app store builds