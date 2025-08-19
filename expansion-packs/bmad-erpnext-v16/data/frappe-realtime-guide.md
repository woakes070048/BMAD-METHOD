# Frappe Real-time Communication Guide
## Complete Guide to Using Frappe's Built-in Real-time Features Instead of WebSocket Libraries

**CRITICAL**: NEVER use `import websocket`, `import socketio`, or `flask-socketio` - Frappe provides all real-time functionality built-in!

---

## 🚫 What NOT to Do

```python
# NEVER DO THIS - Anti-patterns
import websocket       # ❌ BLOCKED
import socketio        # ❌ BLOCKED
import ws4py          # ❌ BLOCKED
from flask_socketio import SocketIO  # ❌ BLOCKED

# WRONG WAY
socketio = SocketIO(app)
websocket.send("message")
```

---

## ✅ The Frappe Way - Complete Real-time Features

### 1. Basic Real-time Publishing

```python
import frappe

def send_realtime_update():
    """Send real-time updates using Frappe's built-in system"""
    
    # Send to specific user
    frappe.publish_realtime(
        event="doc_update",
        message={
            "doctype": "Customer",
            "name": "CUST-001",
            "action": "updated",
            "data": {"status": "Active"}
        },
        user="user@example.com"
    )
    
    # Send to all users (broadcast)
    frappe.publish_realtime(
        event="system_announcement", 
        message={
            "title": "Maintenance Notice",
            "message": "System will be down for 30 minutes",
            "type": "warning"
        }
    )
    
    # Send to users in a room/channel
    frappe.publish_realtime(
        event="chat_message",
        message={
            "from": frappe.session.user,
            "message": "Hello team!",
            "timestamp": frappe.utils.now()
        },
        room="project_team_chat"
    )
```

### 2. Progress Bar Updates

```python
import frappe
from frappe.utils import cint

def process_bulk_data(items):
    """Process items with real-time progress updates"""
    
    total_items = len(items)
    
    for i, item in enumerate(items):
        # Calculate progress percentage
        progress = cint((i / total_items) * 100)
        
        # Send progress update
        frappe.publish_progress(
            percent=progress,
            title="Processing Customer Data",
            description=f"Processing {item.get('name', 'Unknown')} ({i+1} of {total_items})"
        )
        
        # Process the item
        try:
            process_customer_data(item)
        except Exception as e:
            # Send error in progress
            frappe.publish_progress(
                percent=progress,
                title="Processing Customer Data", 
                description=f"Error processing {item.get('name')}: {str(e)}"
            )
            continue
    
    # Send completion
    frappe.publish_progress(
        percent=100,
        title="Processing Complete",
        description=f"Successfully processed {total_items} items"
    )

@frappe.whitelist()
def start_bulk_processing():
    """Start bulk processing with progress tracking"""
    
    # Get data to process
    customers = frappe.get_all("Customer", fields=["name", "customer_name"])
    
    # Start background job with progress
    frappe.enqueue(
        method="myapp.api.process_bulk_data",
        queue="long",
        timeout=3600,
        items=customers
    )
    
    return {"message": "Processing started", "total_items": len(customers)}
```

### 3. Document Update Notifications

```python
import frappe
from frappe.model.document import Document

class CustomDocType(Document):
    def after_insert(self):
        """Send real-time notification after document creation"""
        self.send_creation_notification()
    
    def on_update(self):
        """Send real-time notification after document update"""
        if self.has_value_changed("status"):
            self.send_status_change_notification()
    
    def on_submit(self):
        """Send real-time notification after document submission"""
        self.send_submission_notification()
    
    def send_creation_notification(self):
        """Notify relevant users about new document"""
        # Notify assignee
        if self.assigned_to:
            frappe.publish_realtime(
                event="doc_created",
                message={
                    "doctype": self.doctype,
                    "name": self.name,
                    "title": self.title or self.name,
                    "assigned_to": self.assigned_to,
                    "created_by": self.owner
                },
                user=self.assigned_to
            )
        
        # Notify team members in the same role
        team_members = frappe.get_all("User",
            filters={"role_profile_name": "Sales Team"},
            fields=["email"]
        )
        
        for member in team_members:
            frappe.publish_realtime(
                event="team_notification",
                message={
                    "type": "document_created",
                    "doctype": self.doctype,
                    "name": self.name,
                    "message": f"New {self.doctype} created: {self.name}"
                },
                user=member.email
            )
    
    def send_status_change_notification(self):
        """Notify about status changes"""
        old_status = self.get_doc_before_save().status if self.get_doc_before_save() else None
        
        # Notify all followers of this document
        followers = self.get_followers()
        
        for follower in followers:
            frappe.publish_realtime(
                event="status_changed",
                message={
                    "doctype": self.doctype,
                    "name": self.name,
                    "old_status": old_status,
                    "new_status": self.status,
                    "changed_by": frappe.session.user,
                    "timestamp": frappe.utils.now()
                },
                user=follower
            )
    
    def get_followers(self):
        """Get list of users following this document"""
        # This could be based on assignments, mentions, or explicit follows
        followers = set()
        
        # Add assigned user
        if self.assigned_to:
            followers.add(self.assigned_to)
        
        # Add owner
        followers.add(self.owner)
        
        # Add users who commented on this document
        comments = frappe.get_all("Comment",
            filters={
                "reference_doctype": self.doctype,
                "reference_name": self.name
            },
            fields=["owner"]
        )
        
        for comment in comments:
            followers.add(comment.owner)
        
        return list(followers)
```

### 4. Chat and Messaging System

```python
import frappe
import json

@frappe.whitelist()
def send_chat_message(room, message, message_type="text"):
    """Send chat message to a room"""
    
    # Validate user has access to room
    if not has_room_access(room, frappe.session.user):
        frappe.throw("Access denied to chat room")
    
    # Create message record
    chat_message = frappe.get_doc({
        "doctype": "Chat Message",
        "room": room,
        "sender": frappe.session.user,
        "message": message,
        "message_type": message_type,
        "timestamp": frappe.utils.now()
    })
    chat_message.insert()
    
    # Send real-time notification to room members
    frappe.publish_realtime(
        event="chat_message",
        message={
            "message_id": chat_message.name,
            "room": room,
            "sender": frappe.session.user,
            "sender_name": frappe.get_fullname(frappe.session.user),
            "message": message,
            "message_type": message_type,
            "timestamp": chat_message.timestamp
        },
        room=room
    )
    
    return {"status": "sent", "message_id": chat_message.name}

@frappe.whitelist()
def join_chat_room(room):
    """Join a chat room"""
    
    if not has_room_access(room, frappe.session.user):
        frappe.throw("Access denied to chat room")
    
    # Add user to room
    room_member = frappe.get_doc({
        "doctype": "Chat Room Member",
        "room": room,
        "user": frappe.session.user,
        "joined_on": frappe.utils.now()
    })
    room_member.insert()
    
    # Notify room about new member
    frappe.publish_realtime(
        event="user_joined",
        message={
            "room": room,
            "user": frappe.session.user,
            "user_name": frappe.get_fullname(frappe.session.user),
            "timestamp": frappe.utils.now()
        },
        room=room
    )

def has_room_access(room, user):
    """Check if user has access to chat room"""
    # Implement your room access logic here
    return True  # Simplified for example
```

### 5. Live Dashboard Updates

```python
import frappe

@frappe.whitelist()
def get_dashboard_data():
    """Get dashboard data with real-time updates"""
    
    data = {
        "sales_today": get_sales_today(),
        "pending_orders": get_pending_orders(),
        "active_users": get_active_users(),
        "system_status": get_system_status()
    }
    
    # Send initial data
    return data

def update_dashboard_realtime():
    """Send real-time dashboard updates"""
    
    # This would be called when relevant data changes
    updated_data = get_dashboard_data()
    
    # Send to all dashboard viewers
    frappe.publish_realtime(
        event="dashboard_update",
        message=updated_data,
        room="dashboard_viewers"
    )

# Hook this into document events
def on_sales_order_submit(doc, method):
    """Update dashboard when sales order is submitted"""
    update_dashboard_realtime()

def on_customer_update(doc, method):
    """Update dashboard when customer data changes"""
    update_dashboard_realtime()
```

### 6. Notification System

```python
import frappe

class NotificationManager:
    """Manage different types of real-time notifications"""
    
    @staticmethod
    def send_alert(user, title, message, alert_type="info"):
        """Send alert notification to user"""
        frappe.publish_realtime(
            event="alert",
            message={
                "title": title,
                "message": message,
                "type": alert_type,  # info, success, warning, error
                "timestamp": frappe.utils.now(),
                "auto_dismiss": True if alert_type == "success" else False
            },
            user=user
        )
    
    @staticmethod
    def send_task_notification(assignee, task_doc):
        """Send task assignment notification"""
        frappe.publish_realtime(
            event="task_assigned",
            message={
                "task_id": task_doc.name,
                "task_title": task_doc.subject,
                "due_date": task_doc.exp_end_date,
                "priority": task_doc.priority,
                "assigned_by": frappe.session.user,
                "description": task_doc.description
            },
            user=assignee
        )
    
    @staticmethod
    def send_approval_request(approver, document):
        """Send approval request notification"""
        frappe.publish_realtime(
            event="approval_request",
            message={
                "doctype": document.doctype,
                "name": document.name,
                "title": getattr(document, 'title', document.name),
                "requested_by": frappe.session.user,
                "amount": getattr(document, 'grand_total', None),
                "urgency": getattr(document, 'priority', 'Medium')
            },
            user=approver
        )

# Usage in document controllers
def request_approval(self):
    """Request approval for document"""
    approver = self.get_approver()
    
    if approver:
        NotificationManager.send_approval_request(approver, self)
        NotificationManager.send_alert(
            user=frappe.session.user,
            title="Approval Requested",
            message=f"Approval request sent to {frappe.get_fullname(approver)}",
            alert_type="success"
        )
```

### 7. Frontend Integration (JavaScript)

```javascript
// Client-side real-time event handling

// Listen for real-time events
frappe.realtime.on("doc_update", function(data) {
    // Handle document updates
    console.log("Document updated:", data);
    
    // Update UI if the document is currently displayed
    if (cur_frm && cur_frm.doctype === data.doctype && cur_frm.docname === data.name) {
        cur_frm.reload_doc();
    }
});

frappe.realtime.on("chat_message", function(data) {
    // Handle chat messages
    if (window.chat_room === data.room) {
        appendChatMessage(data);
    }
    
    // Show notification
    frappe.show_alert({
        message: `${data.sender_name}: ${data.message}`,
        indicator: 'blue'
    });
});

frappe.realtime.on("alert", function(data) {
    // Handle alert notifications
    frappe.show_alert({
        message: data.message,
        indicator: data.type === 'error' ? 'red' : 'green'
    });
});

// Send real-time data from frontend
function sendChatMessage(message) {
    frappe.call({
        method: 'myapp.api.send_chat_message',
        args: {
            room: window.current_chat_room,
            message: message
        },
        callback: function(r) {
            if (r.message.status === 'sent') {
                // Message sent successfully
                console.log("Message sent");
            }
        }
    });
}

// Custom Vue component for real-time updates
const RealtimeComponent = {
    template: `
        <div class="realtime-updates">
            <div v-for="notification in notifications" :key="notification.id" 
                 class="notification" :class="notification.type">
                {{ notification.message }}
            </div>
        </div>
    `,
    data() {
        return {
            notifications: []
        };
    },
    mounted() {
        // Subscribe to real-time events
        frappe.realtime.on("notification", (data) => {
            this.notifications.unshift({
                id: Date.now(),
                message: data.message,
                type: data.type || 'info'
            });
            
            // Auto-remove after 5 seconds
            setTimeout(() => {
                this.notifications = this.notifications.filter(n => n.id !== data.id);
            }, 5000);
        });
    }
};
```

---

## 🔒 Security and Best Practices

### 1. Room-based Permissions

```python
def check_room_permissions(room, user):
    """Check if user has access to room"""
    
    # Room naming convention: doctype:name:field
    if ":" in room:
        parts = room.split(":")
        if len(parts) >= 2:
            doctype, name = parts[0], parts[1]
            
            # Check if user has read permission on document
            if not frappe.has_permission(doctype, "read", name, user=user):
                return False
    
    return True

@frappe.whitelist()
def join_room(room):
    """Join a real-time room with permission check"""
    if not check_room_permissions(room, frappe.session.user):
        frappe.throw("Access denied to room")
    
    # Room joined successfully
    return {"status": "joined", "room": room}
```

### 2. Rate Limiting

```python
import frappe
from frappe.utils import cint, now_datetime, add_to_date

def check_rate_limit(user, action, limit_per_minute=60):
    """Check rate limit for real-time actions"""
    
    cache_key = f"rate_limit:{user}:{action}"
    current_count = frappe.cache().get_value(cache_key) or 0
    
    if cint(current_count) >= limit_per_minute:
        frappe.throw("Rate limit exceeded. Please try again later.")
    
    # Increment counter
    frappe.cache().set_value(cache_key, cint(current_count) + 1, expires_in_sec=60)

@frappe.whitelist()
def send_message(room, message):
    """Send message with rate limiting"""
    
    # Check rate limit (10 messages per minute)
    check_rate_limit(frappe.session.user, "send_message", 10)
    
    # Send message
    frappe.publish_realtime(
        event="chat_message",
        message={"room": room, "message": message, "user": frappe.session.user},
        room=room
    )
```

---

## 📋 Quick Reference

| Need | Don't Use | Use Instead |
|------|-----------|-------------|
| Real-time updates | `websocket.send()` | `frappe.publish_realtime()` |
| Progress bars | Custom WebSocket | `frappe.publish_progress()` |
| Chat systems | Socket.IO | `frappe.publish_realtime()` with rooms |
| Notifications | Custom sockets | `frappe.publish_realtime()` |
| Live dashboards | WebSocket polling | Event-driven `frappe.publish_realtime()` |
| Document updates | Manual refresh | Automatic real-time updates |

---

## ⚠️ Common Mistakes to Avoid

```python
# ❌ WRONG - Using external WebSocket libraries
import socketio
sio = socketio.Client()
sio.emit('message', data)

# ✅ CORRECT - Using Frappe real-time
frappe.publish_realtime('message', data)

# ❌ WRONG - Manual polling
setInterval(() => {
    fetch('/api/get_updates').then(...)
}, 1000);

# ✅ CORRECT - Event-driven updates
frappe.realtime.on('update', (data) => {
    updateUI(data);
});

# ❌ WRONG - No permission checks
frappe.publish_realtime('sensitive_data', data)  # Broadcasts to all

# ✅ CORRECT - Proper permission checks
if frappe.has_permission("DocType", "read", user=user):
    frappe.publish_realtime('data_update', data, user=user)
```

---

*Remember: Frappe provides comprehensive real-time functionality. There's NO reason to use external WebSocket libraries!*