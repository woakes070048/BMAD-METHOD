# 🚨 BACKGROUND JOBS & ASYNC PATTERNS - MANDATORY

## CRITICAL: Proper Async Handling = Responsive Apps

This document contains MANDATORY patterns for background jobs, schedulers, and async operations in Frappe/ERPNext.

---

## 🔴 UNDERSTANDING FRAPPE'S ASYNC SYSTEM

### Three Ways to Run Background Tasks:

1. **Scheduler Events** - Periodic tasks (cron, hourly, daily)
2. **Background Jobs (RQ)** - One-time async tasks
3. **Long Running Jobs** - Tasks > 5 minutes

### 🚨 NEVER Block the Main Thread!

```python
# ❌ WRONG - Blocks the UI
def process_large_dataset():
    for i in range(10000):
        process_record(i)  # Takes 10 minutes!
    return "Done"  # User waits 10 minutes!

# ✅ CORRECT - Runs in background
from frappe.utils.background_jobs import enqueue

def trigger_processing():
    enqueue(
        process_large_dataset,
        queue='long',
        timeout=3000
    )
    frappe.msgprint("Processing started in background")
```

---

## 🔴 BACKGROUND JOBS (RQ) PATTERNS

### Basic Background Job Pattern:

```python
# your_app/api.py
import frappe
from frappe import _
from frappe.utils.background_jobs import enqueue

@frappe.whitelist()
def process_data_async(data_id):
    """Trigger background processing"""
    
    # Quick validation (< 1 second)
    if not frappe.db.exists("Data Record", data_id):
        frappe.throw(_("Data record not found"))
    
    # Enqueue the actual processing
    job = enqueue(
        # Function to run
        "your_app.processing.process_heavy_data",
        
        # Arguments
        data_id=data_id,
        user=frappe.session.user,
        
        # Queue configuration
        queue='default',  # or 'long' for > 5 min tasks
        timeout=300,  # 5 minutes
        
        # Job tracking
        job_name=f"process_{data_id}",  # Unique name
        
        # Progress reporting
        is_async=True,
        
        # Notification on completion
        enqueue_after_commit=True
    )
    
    return {
        "success": True,
        "message": _("Processing started"),
        "job_id": job.id
    }

# your_app/processing.py
def process_heavy_data(data_id, user):
    """The actual heavy processing - runs in background"""
    
    # Set user context (important!)
    frappe.set_user(user)
    
    try:
        # Get the data
        data_record = frappe.get_doc("Data Record", data_id)
        
        # Update status
        data_record.db_set("status", "Processing")
        frappe.db.commit()
        
        # Heavy processing
        total_items = len(data_record.items)
        for idx, item in enumerate(data_record.items):
            # Process each item
            process_single_item(item)
            
            # Report progress
            frappe.publish_progress(
                percent=(idx + 1) * 100 / total_items,
                title=_("Processing..."),
                description=_("Processing item {0} of {1}").format(idx + 1, total_items)
            )
        
        # Update final status
        data_record.db_set("status", "Completed")
        data_record.db_set("processed_on", frappe.utils.now())
        frappe.db.commit()
        
        # Send notification
        frappe.sendmail(
            recipients=[user],
            subject=_("Processing Complete"),
            message=_("Your data has been processed successfully")
        )
        
    except Exception as e:
        # Log error
        frappe.log_error(message=str(e), title="Background Job Failed")
        
        # Update status
        frappe.db.set_value("Data Record", data_id, "status", "Failed")
        frappe.db.commit()
        
        # Notify user
        frappe.publish_realtime(
            "background_job_failed",
            {"message": str(e)},
            user=user
        )
        raise
```

### Queue Types and When to Use:

```python
# 1. SHORT QUEUE (default) - Tasks < 5 minutes
enqueue(
    quick_task,
    queue='short',
    timeout=300  # 5 minutes max
)

# 2. DEFAULT QUEUE - Standard tasks
enqueue(
    standard_task,
    queue='default',
    timeout=600  # 10 minutes
)

# 3. LONG QUEUE - Heavy processing > 5 minutes
enqueue(
    heavy_processing,
    queue='long',
    timeout=3000  # 50 minutes
)
```

---

## 🔴 SCHEDULER EVENTS PATTERNS

### Configuring in hooks.py:

```python
# hooks.py
scheduler_events = {
    # Run every minute
    "all": [
        "your_app.tasks.check_critical_alerts"
    ],
    
    # Hourly tasks
    "hourly": [
        "your_app.tasks.sync_external_data"
    ],
    
    # Hourly long-running (> 5 min)
    "hourly_long": [
        "your_app.tasks.generate_complex_reports"
    ],
    
    # Daily tasks
    "daily": [
        "your_app.tasks.send_daily_digest",
        "your_app.tasks.cleanup_old_logs"
    ],
    
    # Daily long-running
    "daily_long": [
        "your_app.tasks.process_all_pending_orders"
    ],
    
    # Weekly tasks
    "weekly": [
        "your_app.tasks.weekly_backup"
    ],
    
    # Monthly tasks
    "monthly": [
        "your_app.tasks.generate_monthly_statements"
    ],
    
    # Cron format for specific times
    "cron": {
        # Every 5 minutes
        "*/5 * * * *": [
            "your_app.tasks.check_queue_health"
        ],
        
        # Daily at 2 AM
        "0 2 * * *": [
            "your_app.tasks.nightly_data_sync"
        ],
        
        # Every Monday at 9 AM
        "0 9 * * 1": [
            "your_app.tasks.weekly_report"
        ],
        
        # First day of month at midnight
        "0 0 1 * *": [
            "your_app.tasks.monthly_reconciliation"
        ]
    }
}
```

### Scheduler Task Pattern:

```python
# your_app/tasks.py
import frappe
from frappe.utils import now_datetime, add_days, get_datetime

def daily_cleanup():
    """Daily cleanup task - runs at configured time"""
    
    # IMPORTANT: Scheduler tasks run as Administrator
    # No need to set user
    
    try:
        # 1. Clean old logs (> 30 days)
        cleanup_date = add_days(now_datetime(), -30)
        
        frappe.db.sql("""
            DELETE FROM `tabError Log` 
            WHERE creation < %s
        """, cleanup_date)
        
        # 2. Clear expired sessions
        frappe.db.sql("""
            DELETE FROM `tabSessions` 
            WHERE lastupdate < %s
        """, add_days(now_datetime(), -7))
        
        # 3. Clean temporary files
        cleanup_temp_files()
        
        # 4. Optimize database tables
        frappe.db.sql("OPTIMIZE TABLE `tabError Log`")
        
        # Commit changes
        frappe.db.commit()
        
        # Log success
        frappe.logger().info("Daily cleanup completed successfully")
        
    except Exception as e:
        frappe.log_error(message=str(e), title="Daily Cleanup Failed")
        # Don't raise - let scheduler continue

def hourly_sync():
    """Sync data every hour"""
    
    # Check if sync is enabled
    settings = frappe.get_single("Your App Settings")
    if not settings.enable_auto_sync:
        return
    
    # Use enqueue for long-running sync
    from frappe.utils.background_jobs import enqueue
    
    enqueue(
        "your_app.sync.perform_full_sync",
        queue="long",
        timeout=3000,
        is_async=True,
        job_name="hourly_sync_" + frappe.utils.now()
    )
```

---

## 🔴 PROGRESS REPORTING PATTERNS

### Real-time Progress Updates:

```python
def long_running_task(doc_name):
    """Task with progress reporting"""
    
    doc = frappe.get_doc("Large Document", doc_name)
    total = len(doc.items)
    
    for i, item in enumerate(doc.items):
        # Process item
        process_item(item)
        
        # Report progress every 10 items
        if i % 10 == 0:
            frappe.publish_progress(
                percent=(i + 1) * 100 / total,
                title=_("Processing Items"),
                description=_("{0} of {1} items processed").format(i + 1, total),
                doctype="Large Document",
                docname=doc_name
            )
    
    # Final notification
    frappe.publish_realtime(
        "processing_complete",
        {"docname": doc_name},
        doctype="Large Document",
        docname=doc_name
    )
```

### Client-side Progress Monitoring:

```javascript
// In your page/form script
frappe.realtime.on("progress", function(data) {
    // Update progress bar
    if (data.percent) {
        frappe.show_progress(data.title, data.percent, 100, data.description);
    }
});

frappe.realtime.on("processing_complete", function(data) {
    frappe.hide_progress();
    frappe.show_alert({
        message: __("Processing complete!"),
        indicator: "green"
    });
    // Refresh the form
    cur_frm.reload_doc();
});
```

---

## 🔴 JOB STATUS TRACKING

### Check Job Status:

```python
from rq import Queue
from frappe.utils.background_jobs import get_redis_conn

def check_job_status(job_id):
    """Check status of a background job"""
    
    conn = get_redis_conn()
    q = Queue('default', connection=conn)
    
    job = q.fetch_job(job_id)
    
    if job:
        return {
            "status": job.get_status(),
            "result": job.result,
            "started_at": job.started_at,
            "ended_at": job.ended_at,
            "exc_info": job.exc_info
        }
    else:
        return {"status": "not_found"}

@frappe.whitelist()
def get_running_jobs():
    """Get all running jobs for current user"""
    
    conn = get_redis_conn()
    queues = ['short', 'default', 'long']
    
    running_jobs = []
    for queue_name in queues:
        q = Queue(queue_name, connection=conn)
        
        # Get running jobs
        for job in q.get_jobs():
            if job.kwargs.get('user') == frappe.session.user:
                running_jobs.append({
                    "id": job.id,
                    "name": job.kwargs.get('job_name', 'Unknown'),
                    "status": job.get_status(),
                    "queue": queue_name
                })
    
    return running_jobs
```

---

## 🔴 ERROR HANDLING IN BACKGROUND JOBS

### Retry Pattern:

```python
from frappe.utils.background_jobs import enqueue

def reliable_background_task():
    """Task with retry logic"""
    
    try:
        # Your task logic
        result = perform_operation()
        return result
        
    except Exception as e:
        # Check retry count
        retry_count = frappe.cache().get(f"retry_{frappe.local.job_id}") or 0
        
        if retry_count < 3:
            # Increment retry count
            frappe.cache().set(f"retry_{frappe.local.job_id}", retry_count + 1)
            
            # Re-enqueue with delay
            enqueue(
                reliable_background_task,
                queue='default',
                timeout=300,
                at_time=frappe.utils.add_to_date(None, seconds=60)  # Retry after 1 minute
            )
            
            frappe.log_error(f"Task failed, retry {retry_count + 1}/3")
        else:
            # Final failure
            frappe.log_error("Task failed after 3 retries", "Critical Failure")
            send_failure_notification()
            raise
```

---

## 🔴 BULK OPERATIONS PATTERN

### Process Large Datasets Efficiently:

```python
def process_bulk_data(doctype, filters=None):
    """Process large dataset in chunks"""
    
    # Get total count
    total = frappe.db.count(doctype, filters)
    
    # Process in chunks of 100
    chunk_size = 100
    
    for start in range(0, total, chunk_size):
        # Enqueue chunk processing
        enqueue(
            process_chunk,
            doctype=doctype,
            filters=filters,
            start=start,
            limit=chunk_size,
            total=total,
            queue='long',
            job_name=f"process_chunk_{start}_{start + chunk_size}"
        )

def process_chunk(doctype, filters, start, limit, total):
    """Process a single chunk"""
    
    # Get chunk data
    docs = frappe.get_all(
        doctype,
        filters=filters,
        limit_start=start,
        limit_page_length=limit,
        fields=["name"]
    )
    
    for doc in docs:
        # Process each document
        process_single_doc(doctype, doc.name)
        
    # Report progress
    percent = min(100, (start + limit) * 100 / total)
    frappe.publish_progress(
        percent=percent,
        title="Bulk Processing",
        description=f"Processed {min(start + limit, total)} of {total}"
    )
```

---

## 🔴 SCHEDULED REPORTS PATTERN

### Generate Reports in Background:

```python
def generate_monthly_report():
    """Generate and email monthly report"""
    
    # Run on first day of month
    today = frappe.utils.today()
    if frappe.utils.get_day(today) != 1:
        return
    
    # Get last month's date range
    last_month_end = frappe.utils.add_days(today, -1)
    last_month_start = frappe.utils.get_first_day(last_month_end)
    
    # Enqueue report generation
    enqueue(
        create_and_send_report,
        start_date=last_month_start,
        end_date=last_month_end,
        queue='long',
        timeout=1800  # 30 minutes
    )

def create_and_send_report(start_date, end_date):
    """Create and send the actual report"""
    
    # Generate report data
    report_data = generate_report_data(start_date, end_date)
    
    # Create PDF
    pdf_content = create_pdf_report(report_data)
    
    # Get recipients
    recipients = frappe.get_all(
        "User",
        filters={"enabled": 1, "user_type": "System User"},
        fields=["email"],
        pluck="email"
    )
    
    # Send email with attachment
    frappe.sendmail(
        recipients=recipients,
        subject=f"Monthly Report - {frappe.utils.format_date(end_date, 'MMMM yyyy')}",
        message="Please find attached the monthly report.",
        attachments=[{
            "fname": f"report_{end_date}.pdf",
            "fcontent": pdf_content
        }]
    )
```

---

## 🔴 BEST PRACTICES & ANTI-PATTERNS

### ✅ DO THIS:
```python
# Use appropriate queue
enqueue(quick_task, queue='short')  # < 5 min
enqueue(long_task, queue='long')     # > 5 min

# Set reasonable timeouts
enqueue(task, timeout=300)  # Don't use excessive timeouts

# Report progress for long tasks
frappe.publish_progress(percent, title, description)

# Handle errors gracefully
try:
    process()
except Exception as e:
    frappe.log_error()
    # Don't crash silently

# Clean up after yourself
frappe.db.commit()  # Commit when done
```

### ❌ DON'T DO THIS:
```python
# Don't block the main thread
process_10000_records()  # BAD - blocks UI

# Don't use infinite timeouts
enqueue(task, timeout=999999)  # BAD

# Don't ignore errors
try:
    process()
except:
    pass  # BAD - silent failure

# Don't forget user context
def background_task():
    # BAD - no user context
    frappe.get_doc("DocType", "name")  # May fail with permissions
```

---

## 📋 BACKGROUND JOBS CHECKLIST

Before implementing background jobs:

- [ ] Identified tasks that take > 2 seconds
- [ ] Chosen appropriate queue (short/default/long)
- [ ] Set reasonable timeout values
- [ ] Implemented progress reporting for long tasks
- [ ] Added error handling and logging
- [ ] Tested job recovery on failure
- [ ] Documented scheduler events in hooks.py
- [ ] Added job status tracking if needed
- [ ] Implemented cleanup for old job data
- [ ] Tested with production-like data volumes

---

**REMEMBER**: Keep the UI responsive - anything over 2 seconds should run in background!