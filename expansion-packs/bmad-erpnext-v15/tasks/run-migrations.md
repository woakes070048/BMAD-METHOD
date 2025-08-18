# Run Migrations

## Overview
This task guides you through running database migrations for your ERPNext application, including schema updates, data migrations, and handling complex migration scenarios safely.

## Prerequisites

### Required Knowledge
- [ ] Understanding of database schema concepts
- [ ] Basic knowledge of SQL and database operations
- [ ] Familiarity with Frappe's migration system
- [ ] Understanding of backup and recovery procedures

### System Requirements
- [ ] Database access with sufficient privileges
- [ ] Frappe bench environment is set up
- [ ] Site is accessible and running
- [ ] Adequate disk space for migration operations
- [ ] Current backup of the database

## Step-by-Step Process

### Step 1: Pre-Migration Preparation

#### Create Full Backup
```bash
# Create comprehensive backup before migrations
bench --site [site-name] backup --with-files

# Verify backup was created successfully
ls -la sites/[site-name]/private/backups/

# Note the backup filename for potential rollback
BACKUP_FILE=$(ls -1t sites/[site-name]/private/backups/*.sql.gz | head -n1)
echo "Backup created: $BACKUP_FILE"
```

#### Check Current Migration Status
```bash
# Check current database version
bench --site [site-name] console
```

```python
# In the console, check migration status
import frappe

# Check current migration index
print("Current migration index:", frappe.db.get_single_value("System Settings", "migration_index"))

# Check app versions
for app in frappe.get_installed_apps():
    version = frappe.get_version(app)
    print(f"{app}: {version}")

# Check for pending migrations
pending = frappe.get_all("Module", fields=["name", "app_name"])
print("Modules to check:", pending)
```

#### Verify Database Integrity
```python
# Check database tables and integrity
def check_database_integrity():
    """Verify database is in good state for migration"""
    
    # Check for table consistency
    all_tables = frappe.db.get_tables()
    print(f"Total tables in database: {len(all_tables)}")
    
    # Check for orphaned records
    doctypes = frappe.get_all("DocType", fields=["name"])
    for dt in doctypes[:10]:  # Check first 10 DocTypes
        try:
            count = frappe.db.count(dt.name)
            print(f"{dt.name}: {count} records")
        except Exception as e:
            print(f"Issue with {dt.name}: {e}")
    
    # Check critical system tables
    critical_tables = ["tabUser", "tabDocType", "tabRole", "tabModule Def"]
    for table in critical_tables:
        if table in all_tables:
            count = frappe.db.sql(f"SELECT COUNT(*) FROM `{table}`")[0][0]
            print(f"✓ {table}: {count} records")
        else:
            print(f"✗ Missing critical table: {table}")

check_database_integrity()
```

### Step 2: Review Pending Migrations

#### Check Migration Files
```bash
# Check for new migration files in your app
find apps/your_app -name "*.py" -path "*/patches/*" | sort

# Review recent migration files
ls -la apps/your_app/your_app/patches/
```

#### Analyze Migration Content
```python
# Review migration patches
import os
import glob

def review_migration_patches():
    """Review all pending migration patches"""
    
    apps = frappe.get_installed_apps()
    
    for app in apps:
        app_path = frappe.get_app_path(app)
        patches_path = os.path.join(app_path, "patches")
        
        if os.path.exists(patches_path):
            patch_files = glob.glob(os.path.join(patches_path, "**/*.py"), recursive=True)
            
            print(f"\n{app} patches:")
            for patch_file in sorted(patch_files):
                rel_path = os.path.relpath(patch_file, app_path)
                print(f"  {rel_path}")
                
                # Read first few lines to understand the patch
                try:
                    with open(patch_file, 'r') as f:
                        lines = f.readlines()[:10]
                        for line in lines:
                            if line.strip().startswith('def ') or line.strip().startswith('"""'):
                                print(f"    {line.strip()}")
                                break
                except:
                    pass

review_migration_patches()
```

### Step 3: Run Standard Migrations

#### Execute Basic Migration
```bash
# Run migrations for all apps
bench --site [site-name] migrate

# Run migration with verbose output
bench --site [site-name] migrate --verbose

# Run migration for specific app only
bench --site [site-name] migrate --skip-failing --skip-search-index
```

#### Monitor Migration Progress
```bash
# Run migration with detailed logging
bench --site [site-name] migrate 2>&1 | tee migration.log

# Check for errors in the log
grep -i error migration.log
grep -i fail migration.log
grep -i exception migration.log
```

### Step 4: Handle Schema Migrations

#### Verify Schema Changes
```python
# Check for schema changes after migration
def verify_schema_changes():
    """Verify database schema after migration"""
    
    # Check new tables
    current_tables = set(frappe.db.get_tables())
    print(f"Total tables after migration: {len(current_tables)}")
    
    # Check specific DocType tables
    doctypes = frappe.get_all("DocType", {"custom": 0}, "name")
    
    for dt in doctypes[:20]:  # Check first 20
        table_name = f"tab{dt.name}"
        if table_name in current_tables:
            # Check table structure
            columns = frappe.db.get_table_columns(dt.name)
            print(f"✓ {dt.name}: {len(columns)} columns")
        else:
            print(f"✗ Missing table for {dt.name}")

verify_schema_changes()
```

#### Create Custom Schema Patch
```python
# Create custom schema migration
# File: apps/your_app/your_app/patches/v1_0/add_custom_fields.py

import frappe

def execute():
    """Add custom fields to existing DocTypes"""
    
    # Add custom field to Customer
    if not frappe.db.exists("Custom Field", {"dt": "Customer", "fieldname": "custom_region"}):
        custom_field = frappe.get_doc({
            "doctype": "Custom Field",
            "dt": "Customer",
            "fieldname": "custom_region",
            "label": "Region",
            "fieldtype": "Select",
            "options": "North\nSouth\nEast\nWest",
            "insert_after": "territory"
        })
        custom_field.insert()
        print("Added custom_region field to Customer")
    
    # Update existing records with default values
    frappe.db.sql("""
        UPDATE `tabCustomer` 
        SET custom_region = 'North' 
        WHERE custom_region IS NULL OR custom_region = ''
    """)
    
    frappe.db.commit()
    print("Updated existing Customer records with default region")
```

### Step 5: Handle Data Migrations

#### Create Data Migration Script
```python
# File: apps/your_app/your_app/patches/v1_0/migrate_customer_data.py

import frappe
from frappe.utils import cstr

def execute():
    """Migrate customer data to new format"""
    
    print("Starting customer data migration...")
    
    # Get all customers that need migration
    customers = frappe.db.sql("""
        SELECT name, customer_name, email_id
        FROM `tabCustomer`
        WHERE custom_migration_status IS NULL
    """, as_dict=True)
    
    print(f"Found {len(customers)} customers to migrate")
    
    migrated_count = 0
    error_count = 0
    
    for customer in customers:
        try:
            migrate_single_customer(customer)
            migrated_count += 1
            
            if migrated_count % 100 == 0:
                print(f"Migrated {migrated_count} customers...")
                frappe.db.commit()
                
        except Exception as e:
            error_count += 1
            frappe.log_error(f"Customer migration error for {customer.name}: {str(e)}")
            
            if error_count > 10:
                print("Too many errors, stopping migration")
                break
    
    frappe.db.commit()
    print(f"Migration completed: {migrated_count} success, {error_count} errors")

def migrate_single_customer(customer_data):
    """Migrate a single customer record"""
    
    # Update customer with new data structure
    frappe.db.sql("""
        UPDATE `tabCustomer`
        SET 
            custom_full_name = %(customer_name)s,
            custom_primary_email = %(email_id)s,
            custom_migration_status = 'Completed',
            custom_migration_date = NOW()
        WHERE name = %(name)s
    """, customer_data)
```

#### Execute Data Migration with Progress Tracking
```python
# Execute data migration with monitoring
def run_monitored_data_migration():
    """Run data migration with progress monitoring"""
    
    import time
    from datetime import datetime
    
    start_time = time.time()
    print(f"Starting migration at {datetime.now()}")
    
    try:
        # Import and execute the migration
        from your_app.patches.v1_0.migrate_customer_data import execute
        execute()
        
        end_time = time.time()
        duration = end_time - start_time
        print(f"Migration completed in {duration:.2f} seconds")
        
        # Verify migration results
        verify_migration_results()
        
    except Exception as e:
        print(f"Migration failed: {str(e)}")
        frappe.log_error(frappe.get_traceback(), "Data Migration Error")
        raise

def verify_migration_results():
    """Verify the results of data migration"""
    
    # Check migration completion status
    completed = frappe.db.count("Customer", {"custom_migration_status": "Completed"})
    total = frappe.db.count("Customer")
    
    print(f"Migration verification: {completed}/{total} customers migrated")
    
    if completed != total:
        unmigrated = frappe.db.get_all("Customer", 
            {"custom_migration_status": ["is", "not set"]}, 
            ["name", "customer_name"]
        )
        print(f"Unmigrated customers: {[c.name for c in unmigrated[:5]]}")

# Run the monitored migration
run_monitored_data_migration()
```

### Step 6: Handle Complex Migrations

#### Multi-Step Migration Process
```python
# File: apps/your_app/your_app/patches/v1_0/complex_migration.py

import frappe
import json

def execute():
    """Complex migration with multiple steps"""
    
    migration_steps = [
        ("backup_existing_data", "Backup existing data"),
        ("create_new_structure", "Create new data structure"),
        ("migrate_data", "Migrate existing data"),
        ("validate_migration", "Validate migrated data"),
        ("cleanup_old_data", "Clean up old data structure")
    ]
    
    migration_log = []
    
    for step_func, step_name in migration_steps:
        print(f"Executing: {step_name}")
        
        try:
            step_result = globals()[step_func]()
            migration_log.append({
                "step": step_name,
                "status": "success",
                "result": step_result,
                "timestamp": frappe.utils.now()
            })
            print(f"✓ {step_name} completed")
            
        except Exception as e:
            migration_log.append({
                "step": step_name,
                "status": "error", 
                "error": str(e),
                "timestamp": frappe.utils.now()
            })
            print(f"✗ {step_name} failed: {str(e)}")
            
            # Log detailed error
            frappe.log_error(frappe.get_traceback(), f"Migration Step Error: {step_name}")
            
            # Decide whether to continue or stop
            if step_func in ["backup_existing_data", "create_new_structure"]:
                # Critical steps - stop migration
                raise Exception(f"Critical migration step failed: {step_name}")
            else:
                # Non-critical steps - continue with warning
                print(f"Warning: {step_name} failed but migration continues")
    
    # Save migration log
    save_migration_log(migration_log)
    print("Complex migration completed")

def backup_existing_data():
    """Backup existing data before migration"""
    
    # Create backup table
    frappe.db.sql("""
        CREATE TABLE `tabCustomer_Migration_Backup` AS
        SELECT * FROM `tabCustomer`
    """)
    
    backup_count = frappe.db.sql("SELECT COUNT(*) FROM `tabCustomer_Migration_Backup`")[0][0]
    return f"Backed up {backup_count} records"

def create_new_structure():
    """Create new data structure"""
    
    # Add new fields or tables as needed
    if not frappe.db.exists("DocType", "Customer Profile"):
        # Create new DocType programmatically
        customer_profile_doctype = {
            "doctype": "DocType",
            "name": "Customer Profile",
            "module": "Your App",
            "custom": 1,
            "fields": [
                {"fieldname": "customer", "fieldtype": "Link", "options": "Customer"},
                {"fieldname": "profile_data", "fieldtype": "JSON"}
            ]
        }
        
        doc = frappe.get_doc(customer_profile_doctype)
        doc.insert()
        
        return "Created Customer Profile DocType"
    
    return "New structure already exists"

def migrate_data():
    """Migrate data to new structure"""
    
    customers = frappe.get_all("Customer", fields=["name", "customer_name"])
    migrated = 0
    
    for customer in customers:
        profile_data = {
            "name": customer.customer_name,
            "created_from_migration": True
        }
        
        profile = frappe.get_doc({
            "doctype": "Customer Profile",
            "customer": customer.name,
            "profile_data": json.dumps(profile_data)
        })
        profile.insert()
        migrated += 1
    
    return f"Migrated {migrated} customer profiles"

def validate_migration():
    """Validate migrated data"""
    
    customer_count = frappe.db.count("Customer")
    profile_count = frappe.db.count("Customer Profile")
    
    if customer_count != profile_count:
        raise Exception(f"Validation failed: {customer_count} customers but {profile_count} profiles")
    
    return f"Validation passed: {profile_count} profiles created"

def cleanup_old_data():
    """Clean up old data structure"""
    
    # Remove backup table after successful migration
    # frappe.db.sql("DROP TABLE IF EXISTS `tabCustomer_Migration_Backup`")
    
    # Note: Commented out for safety - remove manually after verification
    return "Cleanup prepared (manual removal required)"

def save_migration_log(migration_log):
    """Save migration log for future reference"""
    
    log_doc = frappe.get_doc({
        "doctype": "Migration Log",  # Assuming this DocType exists
        "migration_name": "Complex Customer Migration",
        "migration_data": json.dumps(migration_log),
        "status": "Completed" if all(log["status"] == "success" for log in migration_log) else "Partial"
    })
    log_doc.insert()
```

### Step 7: Handle Migration Rollbacks

#### Create Rollback Strategy
```python
def create_rollback_plan():
    """Create rollback plan before running migrations"""
    
    rollback_info = {
        "timestamp": frappe.utils.now(),
        "database_backup": None,
        "schema_snapshot": {},
        "data_counts": {}
    }
    
    # Capture current schema state
    doctypes = frappe.get_all("DocType", {"custom": 0})
    for dt in doctypes:
        try:
            columns = frappe.db.get_table_columns(dt.name)
            rollback_info["schema_snapshot"][dt.name] = columns
            
            count = frappe.db.count(dt.name)
            rollback_info["data_counts"][dt.name] = count
        except:
            pass
    
    # Save rollback information
    with open(f"rollback_plan_{frappe.utils.now().replace(':', '-')}.json", "w") as f:
        import json
        json.dump(rollback_info, f, indent=2, default=str)
    
    print("Rollback plan created")
    return rollback_info

def execute_rollback(backup_file):
    """Execute rollback to previous state"""
    
    print(f"Starting rollback using backup: {backup_file}")
    
    # Stop all services
    # This would typically be done via bench commands
    
    try:
        # Restore database
        import subprocess
        result = subprocess.run([
            "bench", "--site", frappe.local.site,
            "restore", backup_file
        ], capture_output=True, text=True)
        
        if result.returncode != 0:
            raise Exception(f"Restore failed: {result.stderr}")
        
        print("Database restored successfully")
        print("Please restart services: bench restart")
        
    except Exception as e:
        print(f"Rollback failed: {str(e)}")
        raise
```

### Step 8: Post-Migration Verification

#### Comprehensive Verification
```python
def post_migration_verification():
    """Comprehensive verification after migration"""
    
    verification_results = {
        "schema_check": False,
        "data_integrity": False,
        "functionality_test": False,
        "performance_check": False
    }
    
    print("Starting post-migration verification...")
    
    # 1. Schema verification
    try:
        verify_schema_integrity()
        verification_results["schema_check"] = True
        print("✓ Schema verification passed")
    except Exception as e:
        print(f"✗ Schema verification failed: {e}")
    
    # 2. Data integrity check
    try:
        verify_data_integrity()
        verification_results["data_integrity"] = True
        print("✓ Data integrity check passed")
    except Exception as e:
        print(f"✗ Data integrity check failed: {e}")
    
    # 3. Functionality test
    try:
        test_basic_functionality()
        verification_results["functionality_test"] = True
        print("✓ Functionality test passed")
    except Exception as e:
        print(f"✗ Functionality test failed: {e}")
    
    # 4. Performance check
    try:
        basic_performance_check()
        verification_results["performance_check"] = True
        print("✓ Performance check passed")
    except Exception as e:
        print(f"✗ Performance check failed: {e}")
    
    # Summary
    passed_checks = sum(verification_results.values())
    total_checks = len(verification_results)
    
    print(f"\nVerification Summary: {passed_checks}/{total_checks} checks passed")
    
    if passed_checks == total_checks:
        print("🎉 All verification checks passed! Migration successful.")
    else:
        print("⚠️ Some verification checks failed. Review the issues above.")
    
    return verification_results

def verify_schema_integrity():
    """Verify database schema integrity"""
    
    # Check all DocTypes have corresponding tables
    doctypes = frappe.get_all("DocType", {"istable": 0})
    missing_tables = []
    
    for dt in doctypes[:50]:  # Check first 50
        table_name = f"tab{dt.name}"
        if not frappe.db.has_table(table_name):
            missing_tables.append(dt.name)
    
    if missing_tables:
        raise Exception(f"Missing tables for DocTypes: {missing_tables}")

def verify_data_integrity():
    """Verify data integrity after migration"""
    
    # Check for NULL values in required fields
    issues = []
    
    # Check User table
    null_users = frappe.db.sql("SELECT COUNT(*) FROM `tabUser` WHERE name IS NULL OR name = ''")[0][0]
    if null_users > 0:
        issues.append(f"{null_users} users with NULL names")
    
    # Check DocType table
    null_doctypes = frappe.db.sql("SELECT COUNT(*) FROM `tabDocType` WHERE name IS NULL OR name = ''")[0][0]
    if null_doctypes > 0:
        issues.append(f"{null_doctypes} DocTypes with NULL names")
    
    if issues:
        raise Exception(f"Data integrity issues: {', '.join(issues)}")

def test_basic_functionality():
    """Test basic system functionality"""
    
    # Test document creation
    test_doc = frappe.get_doc({
        "doctype": "ToDo",
        "description": "Migration test todo",
        "status": "Open"
    })
    test_doc.insert()
    
    # Test document reading
    retrieved_doc = frappe.get_doc("ToDo", test_doc.name)
    if retrieved_doc.description != "Migration test todo":
        raise Exception("Document read/write test failed")
    
    # Clean up test data
    retrieved_doc.delete()

def basic_performance_check():
    """Basic performance check after migration"""
    
    import time
    
    # Test query performance
    start_time = time.time()
    frappe.get_all("User", limit=100)
    query_time = time.time() - start_time
    
    if query_time > 2.0:  # 2 seconds threshold
        raise Exception(f"Query performance degraded: {query_time:.2f}s")

# Run the verification
post_migration_verification()
```

### Step 9: Update Migration Records

#### Update Migration Tracking
```python
def update_migration_records():
    """Update migration tracking records"""
    
    # Update the migration index
    current_index = frappe.db.get_single_value("System Settings", "migration_index")
    new_index = current_index + 1
    
    frappe.db.set_single_value("System Settings", "migration_index", new_index)
    
    # Log migration completion
    migration_log = frappe.get_doc({
        "doctype": "Migration Log",
        "migration_name": f"Migration {new_index}",
        "app": "your_app",
        "migration_date": frappe.utils.now(),
        "status": "Completed",
        "notes": "Automatic migration via task"
    })
    migration_log.insert()
    
    print(f"Migration index updated to: {new_index}")

update_migration_records()
```

### Step 10: Documentation and Cleanup

#### Document Migration Results
```python
def document_migration():
    """Document the migration process and results"""
    
    migration_report = {
        "migration_date": frappe.utils.now(),
        "site": frappe.local.site,
        "apps_migrated": frappe.get_installed_apps(),
        "total_tables": len(frappe.db.get_tables()),
        "issues_encountered": [],
        "recommendations": []
    }
    
    # Add any issues that were encountered
    # (This would be populated during the actual migration)
    
    # Save report
    import json
    report_filename = f"migration_report_{frappe.utils.now().replace(':', '-')}.json"
    with open(report_filename, 'w') as f:
        json.dump(migration_report, f, indent=2, default=str)
    
    print(f"Migration report saved as: {report_filename}")

document_migration()
```

## Best Practices

### Before Migration
- Always create full backups before running migrations
- Test migrations in development environment first
- Review all migration files before execution
- Check disk space and system resources
- Plan for potential downtime

### During Migration
- Monitor migration progress closely
- Keep logs of all operations
- Be prepared to rollback if issues arise
- Run migrations during low-usage periods
- Have a communication plan for users

### After Migration
- Verify all functionality works as expected
- Run comprehensive data integrity checks
- Monitor system performance
- Update documentation
- Train users on any changes

## Common Issues and Solutions

### Issue: Migration Fails Due to Foreign Key Constraints
**Solution**: Temporarily disable foreign key checks or handle dependencies in correct order

### Issue: Long-Running Migrations Timeout
**Solution**: Break large migrations into smaller chunks or increase timeout limits

### Issue: Data Loss During Migration
**Solution**: Always test with backups first and use transaction-based migrations

### Issue: Permission Issues During Migration
**Solution**: Ensure proper database user permissions and file system access

---

*Your database migrations are now complete. Continue monitoring the system to ensure everything operates correctly post-migration.*