# PWA Implementation Guide for ERPNext v16

This guide provides comprehensive patterns and best practices for implementing Progressive Web App (PWA) features in ERPNext v16 applications following Frappe team standards.

## Overview

Progressive Web Apps enhance ERPNext applications with native app-like experiences, including offline functionality, push notifications, and improved performance on mobile devices.

## Core PWA Components

### 1. Service Worker Implementation

#### Basic Service Worker Setup
```javascript
// public/sw.js
const CACHE_NAME = 'erpnext-app-v1';
const STATIC_ASSETS = [
  '/',
  '/app',
  '/assets/css/frappe-web.css',
  '/assets/js/frappe-web.min.js',
  '/assets/frappe/images/frappe-logo.png'
];

// Install event - cache static assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Caching static assets');
        return cache.addAll(STATIC_ASSETS);
      })
  );
});

// Fetch event - serve from cache, fallback to network
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Return cached version or fetch from network
        return response || fetch(event.request);
      })
  );
});
```

#### Advanced Caching Strategies
```javascript
// Dynamic caching for API responses
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  
  if (url.pathname.startsWith('/api/')) {
    // Network first strategy for API calls
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          const responseClone = response.clone();
          caches.open(CACHE_NAME)
            .then((cache) => {
              cache.put(event.request, responseClone);
            });
          return response;
        })
        .catch(() => {
          // Fallback to cache if network fails
          return caches.match(event.request);
        })
    );
  } else if (url.pathname.startsWith('/assets/')) {
    // Cache first strategy for static assets
    event.respondWith(
      caches.match(event.request)
        .then((response) => {
          return response || fetch(event.request);
        })
    );
  }
});
```

### 2. Web App Manifest

#### Complete Manifest Configuration
```json
// public/manifest.json
{
  "name": "ERPNext Business App",
  "short_name": "ERPNext",
  "description": "Complete business management solution",
  "start_url": "/app",
  "display": "standalone",
  "theme_color": "#5e64ff",
  "background_color": "#ffffff",
  "orientation": "portrait-primary",
  "categories": ["business", "productivity"],
  "lang": "en-US",
  "dir": "ltr",
  "icons": [
    {
      "src": "/assets/frappe/images/frappe-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/assets/frappe/images/frappe-512x512.png", 
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ],
  "screenshots": [
    {
      "src": "/assets/img/desktop-screenshot.png",
      "sizes": "1280x720",
      "type": "image/png",
      "form_factor": "wide"
    },
    {
      "src": "/assets/img/mobile-screenshot.png",
      "sizes": "414x896",
      "type": "image/png",
      "form_factor": "narrow"
    }
  ],
  "shortcuts": [
    {
      "name": "Dashboard",
      "short_name": "Dashboard",
      "url": "/app/dashboard",
      "icons": [
        {
          "src": "/assets/img/dashboard-icon.png",
          "sizes": "96x96",
          "type": "image/png"
        }
      ]
    },
    {
      "name": "New Order",
      "short_name": "Order",
      "url": "/app/sales-order/new",
      "icons": [
        {
          "src": "/assets/img/order-icon.png",
          "sizes": "96x96", 
          "type": "image/png"
        }
      ]
    }
  ]
}
```

### 3. PWA Registration in ERPNext

#### Frappe Integration
```python
# hooks.py
app_include_js = [
    "assets/your_app/js/pwa-setup.js"
]

website_context = {
    "pwa_enabled": True,
    "manifest_path": "/assets/your_app/manifest.json"
}
```

#### JavaScript Registration
```javascript
// public/js/pwa-setup.js
frappe.ready(() => {
    if ('serviceWorker' in navigator) {
        // Register service worker
        navigator.serviceWorker.register('/assets/your_app/sw.js')
            .then((registration) => {
                console.log('SW registered:', registration);
                
                // Check for updates
                registration.addEventListener('updatefound', () => {
                    const newWorker = registration.installing;
                    newWorker.addEventListener('statechange', () => {
                        if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
                            // New version available
                            showUpdateNotification();
                        }
                    });
                });
            })
            .catch((error) => {
                console.error('SW registration failed:', error);
            });
    }

    // Add to home screen prompt
    let deferredPrompt;
    window.addEventListener('beforeinstallprompt', (e) => {
        e.preventDefault();
        deferredPrompt = e;
        showInstallButton();
    });
});

function showInstallButton() {
    const installButton = document.createElement('button');
    installButton.textContent = 'Install App';
    installButton.className = 'btn btn-primary';
    
    installButton.addEventListener('click', async () => {
        if (deferredPrompt) {
            deferredPrompt.prompt();
            const choiceResult = await deferredPrompt.userChoice;
            
            if (choiceResult.outcome === 'accepted') {
                console.log('App installed');
            }
            
            deferredPrompt = null;
        }
    });
    
    document.querySelector('.navbar').appendChild(installButton);
}
```

## Offline Functionality

### 1. Offline Data Storage

#### IndexedDB Integration
```javascript
// public/js/offline-storage.js
class OfflineStorage {
    constructor() {
        this.dbName = 'ERPNextOfflineDB';
        this.dbVersion = 1;
        this.db = null;
    }

    async init() {
        return new Promise((resolve, reject) => {
            const request = indexedDB.open(this.dbName, this.dbVersion);
            
            request.onerror = () => reject(request.error);
            request.onsuccess = () => {
                this.db = request.result;
                resolve(this.db);
            };
            
            request.onupgradeneeded = (event) => {
                const db = event.target.result;
                
                // Create object stores
                if (!db.objectStoreNames.contains('customers')) {
                    const customerStore = db.createObjectStore('customers', { keyPath: 'name' });
                    customerStore.createIndex('customer_name', 'customer_name', { unique: false });
                }
                
                if (!db.objectStoreNames.contains('sales_orders')) {
                    const orderStore = db.createObjectStore('sales_orders', { keyPath: 'name' });
                    orderStore.createIndex('customer', 'customer', { unique: false });
                }
                
                if (!db.objectStoreNames.contains('offline_queue')) {
                    db.createObjectStore('offline_queue', { keyPath: 'id', autoIncrement: true });
                }
            };
        });
    }

    async storeData(storeName, data) {
        const transaction = this.db.transaction([storeName], 'readwrite');
        const store = transaction.objectStore(storeName);
        
        if (Array.isArray(data)) {
            for (const item of data) {
                await store.put(item);
            }
        } else {
            await store.put(data);
        }
        
        return transaction.complete;
    }

    async getData(storeName, key = null) {
        const transaction = this.db.transaction([storeName], 'readonly');
        const store = transaction.objectStore(storeName);
        
        if (key) {
            return store.get(key);
        } else {
            return store.getAll();
        }
    }

    async queueAction(action, data) {
        const queueItem = {
            action: action,
            data: data,
            timestamp: new Date().toISOString(),
            synced: false
        };
        
        return this.storeData('offline_queue', queueItem);
    }
}

// Global instance
const offlineStorage = new OfflineStorage();
```

#### Offline Form Handling
```javascript
// Handle form submission when offline
frappe.ui.form.on('Sales Order', {
    before_save: function(frm) {
        if (!navigator.onLine) {
            // Store form data for later sync
            offlineStorage.queueAction('save', {
                doctype: frm.doctype,
                name: frm.docname,
                doc: frm.doc
            });
            
            frappe.msgprint({
                title: 'Offline Mode',
                message: 'Document saved offline. Will sync when connection is restored.',
                indicator: 'orange'
            });
            
            return false; // Prevent normal save
        }
    }
});
```

### 2. Sync Management

#### Background Sync Implementation
```javascript
// Service Worker background sync
self.addEventListener('sync', (event) => {
    if (event.tag === 'erpnext-background-sync') {
        event.waitUntil(syncOfflineData());
    }
});

async function syncOfflineData() {
    try {
        const queueItems = await getQueuedActions();
        
        for (const item of queueItems) {
            try {
                await syncAction(item);
                await markAsSynced(item.id);
            } catch (error) {
                console.error('Sync failed for item:', item, error);
            }
        }
    } catch (error) {
        console.error('Background sync failed:', error);
    }
}

async function syncAction(queueItem) {
    const { action, data } = queueItem;
    
    switch (action) {
        case 'save':
            return fetch('/api/method/frappe.desk.form.save.savedocs', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    doc: JSON.stringify(data.doc),
                    action: 'Save'
                })
            });
        
        case 'submit':
            return fetch(`/api/method/frappe.desk.form.utils.add_comment`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    reference_doctype: data.doctype,
                    reference_name: data.name,
                    content: 'Document submitted offline',
                    comment_email: data.user
                })
            });
        
        default:
            throw new Error(`Unknown action: ${action}`);
    }
}
```

## Push Notifications

### 1. Server-Side Push Setup

#### Python Notification Handler
```python
# your_app/notifications.py
import json
from pywebpush import webpush, WebPushException
import frappe
from frappe import _

def send_push_notification(user, title, message, data=None):
    """Send push notification to user"""
    
    # Get user's push subscriptions
    subscriptions = frappe.get_all("Push Subscription",
        filters={"user": user},
        fields=["subscription_data"]
    )
    
    if not subscriptions:
        return
    
    notification_data = {
        "title": title,
        "body": message,
        "icon": "/assets/frappe/images/frappe-logo.png",
        "badge": "/assets/frappe/images/notification-badge.png",
        "data": data or {}
    }
    
    vapid_claims = {
        "sub": frappe.get_conf().get("vapid_subject", "mailto:admin@yoursite.com")
    }
    
    for subscription in subscriptions:
        try:
            webpush(
                subscription_info=json.loads(subscription.subscription_data),
                data=json.dumps(notification_data),
                vapid_private_key=frappe.get_conf().get("vapid_private_key"),
                vapid_claims=vapid_claims
            )
        except WebPushException as e:
            frappe.log_error(f"Push notification failed: {str(e)}")

@frappe.whitelist()
def subscribe_to_push_notifications(subscription_data):
    """Subscribe user to push notifications"""
    
    if frappe.db.exists("Push Subscription", {"user": frappe.session.user}):
        # Update existing subscription
        doc = frappe.get_doc("Push Subscription", {"user": frappe.session.user})
        doc.subscription_data = subscription_data
        doc.save()
    else:
        # Create new subscription
        doc = frappe.get_doc({
            "doctype": "Push Subscription",
            "user": frappe.session.user,
            "subscription_data": subscription_data
        })
        doc.insert()
    
    return {"success": True}
```

#### DocType Hook Integration
```python
# Document event handlers
def on_sales_order_submit(doc, method):
    """Send notification when sales order is submitted"""
    
    send_push_notification(
        user=doc.owner,
        title="Sales Order Submitted",
        message=f"Sales Order {doc.name} has been submitted successfully",
        data={
            "doctype": "Sales Order",
            "name": doc.name,
            "action": "view"
        }
    )

# In hooks.py
doc_events = {
    "Sales Order": {
        "on_submit": "your_app.notifications.on_sales_order_submit"
    }
}
```

### 2. Client-Side Push Integration

#### Subscription Management
```javascript
// public/js/push-notifications.js
class PushNotificationManager {
    constructor() {
        this.vapidPublicKey = 'YOUR_VAPID_PUBLIC_KEY';
        this.serviceWorkerRegistration = null;
    }

    async init() {
        if ('serviceWorker' in navigator && 'PushManager' in window) {
            this.serviceWorkerRegistration = await navigator.serviceWorker.ready;
            await this.checkPermissionAndSubscribe();
        }
    }

    async checkPermissionAndSubscribe() {
        const permission = await Notification.requestPermission();
        
        if (permission === 'granted') {
            await this.subscribeToPushNotifications();
        }
    }

    async subscribeToPushNotifications() {
        try {
            const subscription = await this.serviceWorkerRegistration.pushManager.subscribe({
                userVisibleOnly: true,
                applicationServerKey: this.urlB64ToUint8Array(this.vapidPublicKey)
            });

            // Send subscription to server
            await frappe.call({
                method: 'your_app.notifications.subscribe_to_push_notifications',
                args: {
                    subscription_data: JSON.stringify(subscription)
                }
            });

            console.log('Push subscription successful');
        } catch (error) {
            console.error('Push subscription failed:', error);
        }
    }

    urlB64ToUint8Array(base64String) {
        const padding = '='.repeat((4 - base64String.length % 4) % 4);
        const base64 = (base64String + padding)
            .replace(/\-/g, '+')
            .replace(/_/g, '/');

        const rawData = window.atob(base64);
        const outputArray = new Uint8Array(rawData.length);

        for (let i = 0; i < rawData.length; ++i) {
            outputArray[i] = rawData.charCodeAt(i);
        }
        return outputArray;
    }
}

// Initialize when DOM is ready
frappe.ready(() => {
    const pushManager = new PushNotificationManager();
    pushManager.init();
});
```

#### Service Worker Push Handler
```javascript
// public/sw.js - Push event handler
self.addEventListener('push', (event) => {
    const options = event.data ? event.data.json() : {};
    
    const notificationOptions = {
        body: options.body,
        icon: options.icon || '/assets/frappe/images/frappe-logo.png',
        badge: options.badge || '/assets/frappe/images/notification-badge.png',
        data: options.data,
        actions: [
            {
                action: 'view',
                title: 'View',
                icon: '/assets/img/view-icon.png'
            },
            {
                action: 'dismiss',
                title: 'Dismiss',
                icon: '/assets/img/dismiss-icon.png'
            }
        ],
        requireInteraction: true,
        tag: options.data?.doctype || 'general'
    };

    event.waitUntil(
        self.registration.showNotification(options.title, notificationOptions)
    );
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
    event.notification.close();

    if (event.action === 'view' && event.notification.data) {
        const { doctype, name } = event.notification.data;
        const url = `/app/${doctype.toLowerCase().replace(' ', '-')}/${name}`;
        
        event.waitUntil(
            clients.openWindow(url)
        );
    }
});
```

## Mobile Optimization

### 1. Touch and Gesture Support

#### Touch-Friendly Form Controls
```javascript
// Enhanced mobile form behavior
frappe.ui.form.on('Sales Order', {
    refresh: function(frm) {
        if (frappe.utils.is_mobile()) {
            // Enhance mobile UX
            frm.page.add_action_icon('fa-mobile', () => {
                // Mobile-specific actions
            });
            
            // Add swipe gestures for form navigation
            addSwipeGestures(frm);
        }
    }
});

function addSwipeGestures(frm) {
    let startX, startY;
    
    frm.wrapper.addEventListener('touchstart', (e) => {
        startX = e.touches[0].clientX;
        startY = e.touches[0].clientY;
    });
    
    frm.wrapper.addEventListener('touchend', (e) => {
        const endX = e.changedTouches[0].clientX;
        const endY = e.changedTouches[0].clientY;
        
        const deltaX = endX - startX;
        const deltaY = endY - startY;
        
        // Horizontal swipe
        if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 50) {
            if (deltaX > 0) {
                // Swipe right - go to previous
                if (frm.page.current_view > 0) {
                    frm.page.set_view(frm.page.current_view - 1);
                }
            } else {
                // Swipe left - go to next
                if (frm.page.current_view < frm.page.views.length - 1) {
                    frm.page.set_view(frm.page.current_view + 1);
                }
            }
        }
    });
}
```

### 2. Responsive Design Enhancements

#### Mobile-First CSS
```css
/* public/css/mobile-enhancements.css */

/* Mobile-optimized form layouts */
@media (max-width: 768px) {
    .form-layout {
        padding: 10px;
    }
    
    .form-column {
        flex: 100%;
        max-width: 100%;
    }
    
    .btn-group-vertical .btn {
        margin-bottom: 5px;
        width: 100%;
    }
    
    /* Touch-friendly buttons */
    .btn {
        min-height: 44px;
        min-width: 44px;
        padding: 12px 16px;
    }
    
    /* Improved table scrolling */
    .datatable {
        overflow-x: auto;
        -webkit-overflow-scrolling: touch;
    }
    
    /* Better modal sizing */
    .modal-dialog {
        margin: 10px;
        max-width: calc(100vw - 20px);
    }
}

/* PWA-specific styles */
@media all and (display-mode: standalone) {
    /* Hide browser-specific elements */
    .navbar-brand {
        padding-left: 0;
    }
    
    /* Add safe area padding for notched devices */
    body {
        padding-top: env(safe-area-inset-top);
        padding-bottom: env(safe-area-inset-bottom);
    }
}
```

## Performance Optimization

### 1. Resource Caching Strategy

#### Advanced Cache Management
```javascript
// public/sw.js - Advanced caching
const CACHE_NAMES = {
    static: 'erpnext-static-v2',
    dynamic: 'erpnext-dynamic-v2', 
    api: 'erpnext-api-v2'
};

const STATIC_ASSETS = [
    '/',
    '/app',
    '/assets/css/frappe-web.css',
    '/assets/js/frappe-web.min.js'
];

// Install - Cache static assets
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAMES.static)
            .then(cache => cache.addAll(STATIC_ASSETS))
    );
    self.skipWaiting();
});

// Activate - Clean old caches
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then(cacheNames => {
            return Promise.all(
                cacheNames.map(cacheName => {
                    if (!Object.values(CACHE_NAMES).includes(cacheName)) {
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
    self.clients.claim();
});

// Fetch - Sophisticated caching strategies
self.addEventListener('fetch', (event) => {
    const { request } = event;
    const url = new URL(request.url);
    
    // API caching with network-first strategy
    if (url.pathname.startsWith('/api/')) {
        event.respondWith(
            caches.open(CACHE_NAMES.api).then(cache => {
                return fetch(request)
                    .then(response => {
                        // Cache successful responses
                        if (response.status === 200) {
                            cache.put(request, response.clone());
                        }
                        return response;
                    })
                    .catch(() => {
                        // Return cached version on network failure
                        return cache.match(request);
                    });
            })
        );
    }
    
    // Static asset caching with cache-first strategy
    else if (url.pathname.startsWith('/assets/')) {
        event.respondWith(
            caches.match(request)
                .then(response => {
                    return response || fetch(request);
                })
        );
    }
    
    // HTML caching with stale-while-revalidate
    else if (request.headers.get('accept').includes('text/html')) {
        event.respondWith(
            caches.open(CACHE_NAMES.dynamic).then(cache => {
                return cache.match(request).then(response => {
                    const fetchPromise = fetch(request).then(networkResponse => {
                        cache.put(request, networkResponse.clone());
                        return networkResponse;
                    });
                    
                    return response || fetchPromise;
                });
            })
        );
    }
});
```

### 2. Image Optimization

#### Responsive Image Loading
```javascript
// Lazy loading implementation
class LazyImageLoader {
    constructor() {
        this.imageObserver = null;
        this.init();
    }
    
    init() {
        if ('IntersectionObserver' in window) {
            this.imageObserver = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        this.loadImage(entry.target);
                    }
                });
            });
            
            this.observeImages();
        }
    }
    
    observeImages() {
        const images = document.querySelectorAll('img[data-src]');
        images.forEach(img => this.imageObserver.observe(img));
    }
    
    loadImage(img) {
        img.src = img.dataset.src;
        img.classList.add('loaded');
        this.imageObserver.unobserve(img);
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new LazyImageLoader();
});
```

## Security Considerations

### 1. Content Security Policy

#### PWA-Optimized CSP
```python
# In your app's config
def get_website_context(context):
    csp_directives = [
        "default-src 'self'",
        "script-src 'self' 'unsafe-inline' 'unsafe-eval'",
        "style-src 'self' 'unsafe-inline'",
        "img-src 'self' data: https:",
        "font-src 'self' https://fonts.gstatic.com",
        "connect-src 'self' https://fcm.googleapis.com",
        "manifest-src 'self'"
    ]
    
    context.csp_header = "; ".join(csp_directives)
    return context
```

### 2. Service Worker Security

#### Secure Service Worker Patterns
```javascript
// Validate requests in service worker
self.addEventListener('fetch', (event) => {
    const url = new URL(event.request.url);
    
    // Only handle requests to our domain
    if (url.origin !== location.origin) {
        return;
    }
    
    // Validate API requests
    if (url.pathname.startsWith('/api/')) {
        // Ensure authentication headers are present
        if (!event.request.headers.get('Authorization') && 
            !event.request.headers.get('X-Frappe-CSRF-Token')) {
            return;
        }
    }
    
    // Continue with normal handling
    event.respondWith(handleRequest(event.request));
});
```

## Testing PWA Features

### 1. Service Worker Testing

#### Unit Tests for SW
```javascript
// tests/test-service-worker.js
describe('Service Worker', () => {
    let swContainer;
    
    beforeEach(() => {
        swContainer = new ServiceWorkerContainer();
    });
    
    test('should cache static assets on install', async () => {
        const event = new ExtendableEvent('install');
        await importScripts('sw.js');
        
        self.dispatchEvent(event);
        
        const cache = await caches.open('erpnext-static-v1');
        const cachedRequests = await cache.keys();
        
        expect(cachedRequests.length).toBeGreaterThan(0);
    });
    
    test('should serve from cache when offline', async () => {
        const request = new Request('/assets/css/frappe-web.css');
        const event = new FetchEvent('fetch', { request });
        
        // Simulate offline
        global.fetch = jest.fn().mockRejectedValue(new Error('Network error'));
        
        const response = await handleFetch(event);
        expect(response).toBeDefined();
    });
});
```

### 2. PWA Audit Integration

#### Automated PWA Testing
```javascript
// tests/pwa-audit.js
const lighthouse = require('lighthouse');
const chromeLauncher = require('chrome-launcher');

async function auditPWA() {
    const chrome = await chromeLauncher.launch({ chromeFlags: ['--headless'] });
    
    const options = {
        logLevel: 'info',
        output: 'json',
        onlyCategories: ['pwa'],
        port: chrome.port
    };
    
    const runnerResult = await lighthouse('http://localhost:8000', options);
    
    await chrome.kill();
    
    const pwaScore = runnerResult.lhr.categories.pwa.score;
    console.log('PWA Score:', pwaScore * 100);
    
    return pwaScore >= 0.9; // Require 90% PWA score
}
```

## Deployment Considerations

### 1. HTTPS Requirements

#### SSL Configuration
```nginx
# nginx configuration for PWA
server {
    listen 443 ssl http2;
    server_name your-erpnext-site.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    # PWA-specific headers
    add_header Service-Worker-Allowed /;
    add_header Cross-Origin-Embedder-Policy require-corp;
    add_header Cross-Origin-Opener-Policy same-origin;
    
    location /sw.js {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
    }
    
    location /manifest.json {
        add_header Cache-Control "public, max-age=31536000";
    }
    
    # Regular ERPNext configuration
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 2. Performance Monitoring

#### PWA Metrics Collection
```javascript
// Performance monitoring for PWA
class PWAMetrics {
    constructor() {
        this.metrics = {};
        this.init();
    }
    
    init() {
        // Track service worker performance
        navigator.serviceWorker.addEventListener('message', (event) => {
            if (event.data.type === 'CACHE_HIT') {
                this.recordMetric('cache_hit', event.data.url);
            }
        });
        
        // Track app install events
        window.addEventListener('beforeinstallprompt', () => {
            this.recordMetric('install_prompt_shown');
        });
        
        window.addEventListener('appinstalled', () => {
            this.recordMetric('app_installed');
        });
    }
    
    recordMetric(name, data = null) {
        this.metrics[name] = this.metrics[name] || 0;
        this.metrics[name]++;
        
        // Send to analytics
        if (typeof gtag !== 'undefined') {
            gtag('event', name, {
                custom_parameter: data
            });
        }
    }
    
    getMetrics() {
        return this.metrics;
    }
}

// Initialize metrics tracking
const pwaMetrics = new PWAMetrics();
```

This comprehensive PWA implementation guide provides the foundation for creating modern, offline-capable ERPNext applications that deliver native app-like experiences while maintaining the flexibility and power of web technologies.