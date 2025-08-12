# Comprehensive Testing Guide for ERPNext Vue Applications

## Overview
This guide covers testing strategies for ERPNext Vue applications using Vitest, Vue Test Utils, and Playwright.

## Testing Stack

- **Vitest**: Fast unit test framework with Vue support
- **Vue Test Utils**: Official testing utilities for Vue components  
- **Playwright**: Cross-browser E2E testing
- **Coverage**: Built-in coverage with v8

## Setup

### Install Dependencies
```bash
npm install -D vitest @vue/test-utils jsdom @vitest/ui @vitest/coverage-v8
npm install -D @playwright/test
```

### Vitest Configuration
```javascript
// vitest.config.js
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./tests/setup.js'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'tests/', '*.config.js']
    }
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      'frappe-ui': path.resolve(__dirname, './tests/mocks/frappe-ui.js')
    }
  }
})
```

### Test Setup File
```javascript
// tests/setup.js
import { config } from '@vue/test-utils'
import { vi } from 'vitest'

// Mock frappe global
global.frappe = {
  session: { user: 'test@example.com' },
  csrf_token: 'test-token',
  call: vi.fn(),
  db: {
    get_doc: vi.fn(),
    get_list: vi.fn()
  }
}

// Mock window properties
global.window.csrf_token = 'test-token'

// Configure Vue Test Utils
config.global.mocks = {
  $t: (key) => key, // Mock translation
}
```

## Unit Testing Components

### Basic Component Test
```javascript
import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import MyComponent from '@/components/MyComponent.vue'

describe('MyComponent', () => {
  it('renders properly', () => {
    const wrapper = mount(MyComponent, {
      props: {
        title: 'Test Title'
      }
    })
    
    expect(wrapper.text()).toContain('Test Title')
  })
  
  it('emits event on button click', async () => {
    const wrapper = mount(MyComponent)
    
    await wrapper.find('button').trigger('click')
    
    expect(wrapper.emitted()).toHaveProperty('click')
    expect(wrapper.emitted('click')).toHaveLength(1)
  })
})
```

### Testing with createResource
```javascript
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import DataList from '@/components/DataList.vue'

// Mock frappe-ui
vi.mock('frappe-ui', () => ({
  createResource: vi.fn(() => ({
    data: ref([
      { name: 'Item 1', status: 'Active' },
      { name: 'Item 2', status: 'Inactive' }
    ]),
    loading: ref(false),
    error: ref(null),
    reload: vi.fn()
  })),
  Button: { template: '<button><slot /></button>' }
}))

describe('DataList', () => {
  it('displays data from resource', async () => {
    const wrapper = mount(DataList)
    
    await wrapper.vm.$nextTick()
    
    const items = wrapper.findAll('.list-item')
    expect(items).toHaveLength(2)
    expect(items[0].text()).toContain('Item 1')
  })
  
  it('shows loading state', async () => {
    const { createResource } = await import('frappe-ui')
    createResource.mockReturnValueOnce({
      data: ref(null),
      loading: ref(true),
      error: ref(null),
      reload: vi.fn()
    })
    
    const wrapper = mount(DataList)
    
    expect(wrapper.find('.loading').exists()).toBe(true)
  })
})
```

## Testing Stores (Pinia)

```javascript
import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useUserStore } from '@/stores/user'

describe('User Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })
  
  it('fetches user data', async () => {
    const store = useUserStore()
    
    await store.fetchUser()
    
    expect(store.user).toBeDefined()
    expect(store.user.email).toBe('test@example.com')
  })
  
  it('computes full name', () => {
    const store = useUserStore()
    store.user = {
      first_name: 'John',
      last_name: 'Doe'
    }
    
    expect(store.fullName).toBe('John Doe')
  })
})
```

## Testing Composables

```javascript
import { describe, it, expect } from 'vitest'
import { useCounter } from '@/composables/useCounter'

describe('useCounter', () => {
  it('increments counter', () => {
    const { count, increment } = useCounter()
    
    expect(count.value).toBe(0)
    
    increment()
    expect(count.value).toBe(1)
    
    increment()
    expect(count.value).toBe(2)
  })
  
  it('resets counter', () => {
    const { count, increment, reset } = useCounter(10)
    
    increment()
    expect(count.value).toBe(11)
    
    reset()
    expect(count.value).toBe(10)
  })
})
```

## Testing API Calls

```javascript
import { describe, it, expect, vi } from 'vitest'
import { api } from '@/services/api'

// Mock fetch
global.fetch = vi.fn()

describe('API Service', () => {
  it('makes GET request', async () => {
    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => ({ data: 'test' })
    })
    
    const result = await api.get('/test')
    
    expect(fetch).toHaveBeenCalledWith(
      '/api/method/test',
      expect.objectContaining({
        method: 'GET',
        headers: expect.objectContaining({
          'X-Frappe-CSRF-Token': 'test-token'
        })
      })
    )
    expect(result.data).toBe('test')
  })
  
  it('handles API errors', async () => {
    fetch.mockResolvedValueOnce({
      ok: false,
      status: 404,
      statusText: 'Not Found'
    })
    
    await expect(api.get('/notfound')).rejects.toThrow('Not Found')
  })
})
```

## Testing Forms

```javascript
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import LoginForm from '@/components/LoginForm.vue'

describe('LoginForm', () => {
  it('validates required fields', async () => {
    const wrapper = mount(LoginForm)
    
    // Submit empty form
    await wrapper.find('form').trigger('submit.prevent')
    
    // Check for validation errors
    expect(wrapper.find('.error').text()).toContain('Email is required')
  })
  
  it('submits valid form', async () => {
    const wrapper = mount(LoginForm)
    
    // Fill form
    await wrapper.find('input[name="email"]').setValue('test@example.com')
    await wrapper.find('input[name="password"]').setValue('password123')
    
    // Submit
    await wrapper.find('form').trigger('submit.prevent')
    
    // Check emitted event
    expect(wrapper.emitted('submit')).toBeTruthy()
    expect(wrapper.emitted('submit')[0][0]).toEqual({
      email: 'test@example.com',
      password: 'password123'
    })
  })
})
```

## E2E Testing with Playwright

### Configuration
```javascript
// playwright.config.js
export default {
  testDir: './tests/e2e',
  timeout: 30000,
  use: {
    baseURL: 'http://localhost:5173',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure'
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } }
  ]
}
```

### E2E Test Example
```javascript
import { test, expect } from '@playwright/test'

test.describe('User Journey', () => {
  test('complete order flow', async ({ page }) => {
    // Login
    await page.goto('/login')
    await page.fill('input[name="email"]', 'user@example.com')
    await page.fill('input[name="password"]', 'password')
    await page.click('button[type="submit"]')
    
    // Navigate to products
    await page.click('text=Products')
    await page.waitForSelector('.product-grid')
    
    // Select product
    await page.click('.product-card:first-child')
    await page.click('text=Add to Cart')
    
    // Checkout
    await page.click('text=Cart')
    await page.click('text=Checkout')
    
    // Fill shipping
    await page.fill('input[name="address"]', '123 Main St')
    await page.fill('input[name="city"]', 'New York')
    
    // Complete order
    await page.click('text=Place Order')
    
    // Verify success
    await expect(page.locator('.success-message')).toContainText('Order placed successfully')
  })
})
```

## Testing Best Practices

### 1. Test Structure
```javascript
describe('Component/Feature', () => {
  // Setup
  beforeEach(() => {
    // Common setup
  })
  
  // Cleanup
  afterEach(() => {
    // Cleanup
  })
  
  describe('specific functionality', () => {
    it('should do something specific', () => {
      // Arrange
      const input = setupInput()
      
      // Act
      const result = performAction(input)
      
      // Assert
      expect(result).toBe(expected)
    })
  })
})
```

### 2. Mocking Strategies
```javascript
// Mock modules
vi.mock('@/services/api', () => ({
  api: {
    get: vi.fn(),
    post: vi.fn()
  }
}))

// Mock components
vi.mock('@/components/Heavy.vue', () => ({
  default: { template: '<div>Mocked Heavy Component</div>' }
}))

// Mock stores
vi.mock('@/stores/user', () => ({
  useUserStore: () => ({
    user: { id: 1, name: 'Test User' },
    isLoggedIn: true
  })
}))
```

### 3. Testing Async Code
```javascript
it('handles async operations', async () => {
  const wrapper = mount(AsyncComponent)
  
  // Wait for async operation
  await flushPromises()
  
  // Or wait for specific condition
  await waitFor(() => {
    expect(wrapper.find('.loaded').exists()).toBe(true)
  })
  
  // Or use Vue's nextTick
  await wrapper.vm.$nextTick()
  
  expect(wrapper.text()).toContain('Data loaded')
})
```

### 4. Testing Utilities
```javascript
// tests/utils/helpers.js
export function createWrapper(component, options = {}) {
  return mount(component, {
    global: {
      plugins: [createPinia(), router],
      stubs: {
        teleport: true,
        transition: false
      },
      ...options.global
    },
    ...options
  })
}

export function waitFor(condition, timeout = 1000) {
  return new Promise((resolve, reject) => {
    const interval = setInterval(() => {
      if (condition()) {
        clearInterval(interval)
        resolve()
      }
    }, 50)
    
    setTimeout(() => {
      clearInterval(interval)
      reject(new Error('Timeout waiting for condition'))
    }, timeout)
  })
}
```

## Coverage Requirements

### Setting Coverage Thresholds
```javascript
// vitest.config.js
export default {
  test: {
    coverage: {
      threshold: {
        branches: 80,
        functions: 80,
        lines: 80,
        statements: 80
      },
      include: ['src/**/*.{js,vue}'],
      exclude: ['src/**/*.spec.js', 'src/main.js']
    }
  }
}
```

## CI/CD Integration

### GitHub Actions
```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run unit tests
        run: npm test
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
      
      - name: Run E2E tests
        run: |
          npx playwright install
          npm run test:e2e
```

## Common Testing Patterns

### 1. Testing Router Navigation
```javascript
it('navigates to detail page', async () => {
  const router = createRouter({
    history: createWebHistory(),
    routes: [{ path: '/items/:id', component: ItemDetail }]
  })
  
  const wrapper = mount(ItemList, {
    global: { plugins: [router] }
  })
  
  await wrapper.find('.item-link').trigger('click')
  await router.isReady()
  
  expect(router.currentRoute.value.path).toBe('/items/1')
})
```

### 2. Testing Permissions
```javascript
it('shows admin features for admin users', () => {
  const wrapper = mount(Dashboard, {
    global: {
      mocks: {
        $user: { role: 'admin' }
      }
    }
  })
  
  expect(wrapper.find('.admin-panel').exists()).toBe(true)
})
```

### 3. Testing Real-time Updates
```javascript
it('updates on socket message', async () => {
  const wrapper = mount(RealtimeComponent)
  
  // Simulate socket message
  wrapper.vm.$socket.emit('update', { data: 'new value' })
  
  await wrapper.vm.$nextTick()
  
  expect(wrapper.text()).toContain('new value')
})
```

## Debugging Tests

### Visual Debugging
```bash
# Run tests with UI
npm run test:ui

# Debug specific test
npm test -- --reporter=verbose MyComponent.spec.js
```

### Using Browser DevTools
```javascript
it.only('debug this test', async () => {
  const wrapper = mount(Component)
  
  // Add debugger statement
  debugger
  
  // Or log wrapper
  console.log(wrapper.html())
  console.log(wrapper.vm)
})
```