# site-operations

## Task Description
Manage Frappe site operations including creation, backup, restore, migration, and maintenance tasks.

## Parameters
- `operation`: Type of site operation (create, backup, restore, migrate, etc.)
- `site_name`: Name of the site to operate on
- `options`: Operation-specific options
- `force`: Force operation without confirmation (default: false)

## Prerequisites
- Bench environment properly configured
- Required permissions for site operations
- Database access configured
- Sufficient disk space for operations

## Steps

### 1. Site Creation
```python
def create_site(site_name, db_name=None, db_password=None, admin_password=None, install_apps=None):
    """Create a new Frappe site"""
    
    # Validate site name
    if not validate_site_name(site_name):
        frappe.throw(_("Invalid site name"))
    
    # Check if site already exists
    if site_exists(site_name):
        frappe.throw(_("Site {0} already exists").format(site_name))
    
    # Build command
    command = ["bench", "new-site", site_name]
    
    if db_name:
        command.extend(["--db-name", db_name])
    
    if db_password:
        command.extend(["--mariadb-root-password", db_password])
    
    if admin_password:
        command.extend(["--admin-password", admin_password])
    
    if install_apps:
        for app in install_apps:
            command.extend(["--install-app", app])
    
    # Execute site creation
    result = execute_command(command)
    
    # Post-creation setup
    if result["success"]:
        setup_site_config(site_name)
        set_site_permissions(site_name)
    
    return result
```

### 2. Site Backup Operations
```python
def backup_site(site_name, with_files=True, compress=True, backup_path=None):
    """Create site backup with database and files"""
    
    import os
    from datetime import datetime
    
    # Validate site exists
    if not site_exists(site_name):
        frappe.throw(_("Site {0} does not exist").format(site_name))
    
    # Set backup path
    if not backup_path:
        backup_path = os.path.join(get_bench_path(), "backups", site_name)
    
    # Create backup directory
    os.makedirs(backup_path, exist_ok=True)
    
    # Generate backup filename
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_name = f"{site_name}_{timestamp}"
    
    # Build backup command
    command = [
        "bench", "--site", site_name, "backup",
        "--backup-path", backup_path
    ]
    
    if with_files:
        command.append("--with-files")
    
    if compress:
        command.append("--compress")
    
    # Execute backup
    result = execute_command(command)
    
    if result["success"]:
        # Verify backup files
        backup_files = verify_backup_files(backup_path, backup_name)
        result["backup_files"] = backup_files
        
        # Calculate backup size
        result["backup_size"] = calculate_backup_size(backup_files)
        
        # Cleanup old backups
        cleanup_old_backups(backup_path, retain_count=5)
    
    return result

def schedule_automatic_backups(site_name, frequency="daily", time="02:00", retention_days=7):
    """Schedule automatic site backups"""
    
    # Create cron job for backups
    cron_expression = get_cron_expression(frequency, time)
    
    backup_script = f"""
#!/bin/bash
cd {get_bench_path()}
bench --site {site_name} backup --with-files --compress
find {get_bench_path()}/backups/{site_name} -name "*.sql.gz" -mtime +{retention_days} -delete
"""
    
    # Add to crontab
    add_cron_job(cron_expression, backup_script)
    
    return {"status": "Backup schedule created", "frequency": frequency, "time": time}
```

### 3. Site Restore Operations
```python
def restore_site(site_name, backup_files, force=False):
    """Restore site from backup files"""
    
    # Validate backup files
    if not validate_backup_files(backup_files):
        frappe.throw(_("Invalid or missing backup files"))
    
    # Check if site exists
    if site_exists(site_name) and not force:
        frappe.throw(_("Site {0} already exists. Use force=True to overwrite").format(site_name))
    
    # Drop existing site if force
    if site_exists(site_name) and force:
        drop_site(site_name, force=True)
    
    # Create new site
    create_site_result = create_site(site_name)
    
    if not create_site_result["success"]:
        frappe.throw(_("Failed to create site for restore"))
    
    # Restore database
    command = [
        "bench", "--site", site_name, "restore",
        backup_files["database"]
    ]
    
    if "private_files" in backup_files:
        command.extend(["--with-private-files", backup_files["private_files"]])
    
    if "public_files" in backup_files:
        command.extend(["--with-public-files", backup_files["public_files"]])
    
    # Execute restore
    result = execute_command(command)
    
    if result["success"]:
        # Run post-restore tasks
        post_restore_tasks(site_name)
    
    return result

def post_restore_tasks(site_name):
    """Run tasks after site restore"""
    
    # Clear cache
    execute_command(["bench", "--site", site_name, "clear-cache"])
    
    # Run migrations
    execute_command(["bench", "--site", site_name, "migrate"])
    
    # Rebuild search index
    execute_command(["bench", "--site", site_name, "rebuild-search-index"])
    
    # Set maintenance mode off
    set_maintenance_mode(site_name, False)
```

### 4. Site Migration
```python
def migrate_site(site_name, skip_failing=True, skip_search_index=False):
    """Run database migrations for site"""
    
    # Check site exists
    if not site_exists(site_name):
        frappe.throw(_("Site {0} does not exist").format(site_name))
    
    # Set maintenance mode
    set_maintenance_mode(site_name, True)
    
    try:
        # Backup before migration
        backup_result = backup_site(site_name, compress=True)
        
        # Build migration command
        command = ["bench", "--site", site_name, "migrate"]
        
        if skip_failing:
            command.append("--skip-failing")
        
        if skip_search_index:
            command.append("--skip-search-index")
        
        # Execute migration
        result = execute_command(command)
        
        if result["success"]:
            # Clear cache after migration
            execute_command(["bench", "--site", site_name, "clear-cache"])
            
            # Rebuild search index if not skipped
            if not skip_search_index:
                execute_command(["bench", "--site", site_name, "rebuild-search-index"])
        
        return result
        
    finally:
        # Always turn off maintenance mode
        set_maintenance_mode(site_name, False)
```

### 5. Site Configuration Management
```python
def update_site_config(site_name, config_updates):
    """Update site configuration"""
    
    import json
    import os
    
    site_config_path = os.path.join(
        get_bench_path(), "sites", site_name, "site_config.json"
    )
    
    # Read existing config
    with open(site_config_path, 'r') as f:
        config = json.load(f)
    
    # Update config
    config.update(config_updates)
    
    # Validate config
    if not validate_site_config(config):
        frappe.throw(_("Invalid site configuration"))
    
    # Backup original config
    backup_config_file(site_config_path)
    
    # Write updated config
    with open(site_config_path, 'w') as f:
        json.dump(config, f, indent=2)
    
    # Clear cache for config changes to take effect
    execute_command(["bench", "--site", site_name, "clear-cache"])
    
    return {"status": "Config updated", "config": config}

def get_site_config(site_name):
    """Get current site configuration"""
    
    import json
    import os
    
    site_config_path = os.path.join(
        get_bench_path(), "sites", site_name, "site_config.json"
    )
    
    if not os.path.exists(site_config_path):
        frappe.throw(_("Site config not found"))
    
    with open(site_config_path, 'r') as f:
        config = json.load(f)
    
    # Mask sensitive information
    masked_config = mask_sensitive_config(config)
    
    return masked_config
```

### 6. Site Maintenance Operations
```python
def set_maintenance_mode(site_name, enable=True):
    """Enable or disable maintenance mode"""
    
    config_updates = {"maintenance_mode": 1 if enable else 0}
    update_site_config(site_name, config_updates)
    
    return {"status": f"Maintenance mode {'enabled' if enable else 'disabled'}"}

def clear_site_cache(site_name):
    """Clear all cache for site"""
    
    command = ["bench", "--site", site_name, "clear-cache"]
    result = execute_command(command)
    
    # Also clear Redis cache
    clear_redis_cache(site_name)
    
    return result

def rebuild_site_indexes(site_name):
    """Rebuild database indexes"""
    
    # Rebuild search index
    execute_command(["bench", "--site", site_name, "rebuild-search-index"])
    
    # Optimize database tables
    optimize_database_tables(site_name)
    
    return {"status": "Indexes rebuilt"}

def cleanup_site_data(site_name, cleanup_types=None):
    """Cleanup unnecessary site data"""
    
    cleanup_types = cleanup_types or [
        "error_logs",
        "email_queue",
        "activity_logs",
        "version_logs",
        "deleted_documents"
    ]
    
    results = {}
    
    for cleanup_type in cleanup_types:
        if cleanup_type == "error_logs":
            results["error_logs"] = cleanup_error_logs(site_name)
        elif cleanup_type == "email_queue":
            results["email_queue"] = cleanup_email_queue(site_name)
        elif cleanup_type == "activity_logs":
            results["activity_logs"] = cleanup_activity_logs(site_name)
        elif cleanup_type == "version_logs":
            results["version_logs"] = cleanup_version_logs(site_name)
        elif cleanup_type == "deleted_documents":
            results["deleted_documents"] = cleanup_deleted_documents(site_name)
    
    return results
```

### 7. Site Monitoring
```python
def check_site_health(site_name):
    """Check site health status"""
    
    health_checks = {
        "site_accessible": check_site_accessible(site_name),
        "database_connection": check_database_connection(site_name),
        "disk_usage": check_disk_usage(site_name),
        "error_rate": check_error_rate(site_name),
        "response_time": check_response_time(site_name),
        "scheduled_jobs": check_scheduled_jobs(site_name),
        "background_jobs": check_background_jobs(site_name)
    }
    
    # Calculate overall health score
    health_score = calculate_health_score(health_checks)
    
    return {
        "site": site_name,
        "health_score": health_score,
        "checks": health_checks,
        "status": get_health_status(health_score)
    }

def get_site_statistics(site_name):
    """Get comprehensive site statistics"""
    
    stats = {
        "database_size": get_database_size(site_name),
        "file_storage_size": get_file_storage_size(site_name),
        "user_count": get_user_count(site_name),
        "document_count": get_document_count(site_name),
        "active_sessions": get_active_sessions(site_name),
        "error_count_24h": get_error_count(site_name, hours=24),
        "email_queue_size": get_email_queue_size(site_name),
        "background_jobs_pending": get_pending_jobs_count(site_name)
    }
    
    return stats
```

### 8. Multi-Site Operations
```python
def list_all_sites():
    """List all sites in bench"""
    
    import os
    
    sites_path = os.path.join(get_bench_path(), "sites")
    sites = []
    
    for item in os.listdir(sites_path):
        site_path = os.path.join(sites_path, item)
        if os.path.isdir(site_path) and item not in ["assets", "common_site_config.json"]:
            site_info = {
                "name": item,
                "status": get_site_status(item),
                "config": get_site_config(item),
                "health": check_site_health(item)
            }
            sites.append(site_info)
    
    return sites

def batch_site_operation(operation, sites=None, options=None):
    """Execute operation on multiple sites"""
    
    if not sites:
        sites = [s["name"] for s in list_all_sites()]
    
    results = {}
    
    for site in sites:
        try:
            if operation == "backup":
                results[site] = backup_site(site, **options)
            elif operation == "migrate":
                results[site] = migrate_site(site, **options)
            elif operation == "clear_cache":
                results[site] = clear_site_cache(site)
            elif operation == "update_config":
                results[site] = update_site_config(site, options)
            else:
                results[site] = {"error": f"Unknown operation: {operation}"}
        except Exception as e:
            results[site] = {"error": str(e)}
    
    return results
```

### 9. Site Security Operations
```python
def reset_admin_password(site_name, new_password):
    """Reset administrator password for site"""
    
    command = [
        "bench", "--site", site_name,
        "set-admin-password", new_password
    ]
    
    result = execute_command(command)
    
    # Log password reset for audit
    log_security_event(site_name, "admin_password_reset")
    
    return result

def update_site_limits(site_name, limits):
    """Update site usage limits"""
    
    valid_limits = {
        "users": limits.get("users"),
        "space": limits.get("space"),
        "emails": limits.get("emails"),
        "expiry": limits.get("expiry")
    }
    
    # Remove None values
    valid_limits = {k: v for k, v in valid_limits.items() if v is not None}
    
    config_updates = {"limits": valid_limits}
    return update_site_config(site_name, config_updates)

def enable_site_ssl(site_name, ssl_certificate=None, ssl_key=None):
    """Enable SSL for site"""
    
    if ssl_certificate and ssl_key:
        # Custom SSL certificate
        setup_custom_ssl(site_name, ssl_certificate, ssl_key)
    else:
        # Let's Encrypt
        command = ["bench", "setup", "lets-encrypt", site_name]
        execute_command(command)
    
    # Update site config
    update_site_config(site_name, {"ssl_certificate": True})
    
    return {"status": "SSL enabled for site"}
```

### 10. Site Deletion
```python
def drop_site(site_name, force=False, no_backup=False):
    """Delete a site permanently"""
    
    # Create backup before deletion unless specified
    if not no_backup:
        backup_site(site_name, compress=True)
    
    # Build drop command
    command = ["bench", "drop-site", site_name]
    
    if force:
        command.append("--force")
    
    if no_backup:
        command.append("--no-backup")
    
    # Execute site deletion
    result = execute_command(command)
    
    # Clean up site files
    if result["success"]:
        cleanup_site_files(site_name)
    
    return result
```

## Error Handling
```python
def handle_site_operation_error(operation, site_name, error):
    """Handle errors during site operations"""
    
    error_handlers = {
        "create": handle_creation_error,
        "backup": handle_backup_error,
        "restore": handle_restore_error,
        "migrate": handle_migration_error,
        "drop": handle_deletion_error
    }
    
    handler = error_handlers.get(operation, handle_generic_error)
    return handler(site_name, error)

def handle_migration_error(site_name, error):
    """Handle migration errors"""
    
    # Check if it's a known migration issue
    if "duplicate column" in str(error).lower():
        # Try to fix duplicate column issue
        fix_duplicate_column(site_name)
        return {"status": "fixed", "action": "duplicate_column_removed"}
    
    elif "syntax error" in str(error).lower():
        # Log syntax error for manual review
        log_migration_error(site_name, error)
        return {"status": "error", "action": "manual_review_required"}
    
    else:
        # Unknown error, restore from backup
        restore_from_latest_backup(site_name)
        return {"status": "error", "action": "restored_from_backup"}
```

## Best Practices
1. **Always backup before destructive operations**
2. **Use maintenance mode during migrations**
3. **Monitor site health regularly**
4. **Keep backup retention policy**
5. **Test restore procedures periodically**
6. **Document custom configurations**
7. **Use force flags cautiously**
8. **Clear cache after configuration changes**

## Integration Points
- **Bench Operator**: Primary agent using this task
- **System Administrator**: Site monitoring and maintenance
- **DevOps**: Automated site operations
- **Testing Specialist**: Test site management