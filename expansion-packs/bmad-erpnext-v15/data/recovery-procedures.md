# Recovery Procedures for ERPNext Applications

## Overview

This guide provides systematic recovery procedures for various failure scenarios in ERPNext/Frappe applications. These procedures are designed to restore system functionality with minimal data loss and downtime.

## Emergency Response Protocols

### Priority Classification

**Critical (P1) - System Down**
- Complete site outage
- Database corruption
- Security breach
- Data loss incidents
- Response time: Immediate (within 15 minutes)

**High (P2) - Major Functionality Loss**
- Key features unavailable
- Performance severely degraded
- Multiple users affected
- Response time: Within 1 hour

**Medium (P3) - Partial Functionality Loss**
- Some features unavailable
- Limited user impact
- Workarounds available
- Response time: Within 4 hours

**Low (P4) - Minor Issues**
- Cosmetic issues
- Single user impact
- Non-critical functionality
- Response time: Within 24 hours

## Site Recovery Procedures

### Complete Site Restoration

**Scenario:** Site completely inaccessible or corrupted

```bash
# 1. Assessment
bench status
bench list-sites
bench --site [site-name] console
# If console fails, proceed with restoration

# 2. Stop all processes
bench stop

# 3. Create emergency backup of current state
sudo cp -r sites/[site-name] sites/[site-name]-emergency-backup-$(date +%Y%m%d_%H%M%S)

# 4. Restore from latest backup
bench --site [site-name] restore [backup-file.sql.gz] --with-private-files [files-backup.tar]

# 5. Run migrations to ensure schema is current
bench --site [site-name] migrate

# 6. Rebuild assets
bench build

# 7. Start services
bench start

# 8. Verify site functionality
bench --site [site-name] console
>>> frappe.get_all("User", limit=1)  # Test basic functionality
```

**Validation Steps:**
- [ ] Site loads without errors
- [ ] User authentication works
- [ ] Basic CRUD operations function
- [ ] Background jobs are processing
- [ ] External integrations work

### Partial Site Recovery

**Scenario:** Site accessible but some apps/features broken

```bash
# 1. Identify affected apps
bench --site [site-name] list-apps

# 2. Check app-specific issues
bench --site [site-name] console
>>> frappe.get_installed_apps()

# 3. Reinstall problematic app
bench --site [site-name] uninstall-app [app-name] --force
bench get-app [app-name] [repository-url]
bench --site [site-name] install-app [app-name]

# 4. Restore app-specific data if needed
bench --site [site-name] restore [app-specific-backup.sql.gz] --only-tables

# 5. Run migrations
bench --site [site-name] migrate

# 6. Clear cache and rebuild
bench --site [site-name] clear-cache
bench build
```

## Database Recovery

### Database Corruption Recovery

**Scenario:** Database corruption detected

```bash
# 1. Stop all database writes immediately
bench stop

# 2. Backup corrupted database
bench --site [site-name] backup --with-files

# 3. Check database integrity
bench --site [site-name] mariadb
> CHECK TABLE `tabDocType`;
> REPAIR TABLE `tabDocType`;

# 4. If repair fails, restore from backup
bench new-site [temp-site-name]
bench --site [temp-site-name] restore [latest-good-backup.sql.gz]

# 5. Compare data integrity
bench --site [site-name] console
>>> original_count = frappe.db.count("User")
bench --site [temp-site-name] console  
>>> backup_count = frappe.db.count("User")

# 6. If backup is good, replace corrupted site
bench drop-site [site-name] --force
bench rename-site [temp-site-name] [site-name]

# 7. Start services
bench start
```

### Data Recovery from Backups

**Scenario:** Need to recover specific data

```bash
# 1. Create temporary site for data extraction
bench new-site temp-recovery-site

# 2. Restore backup to temporary site
bench --site temp-recovery-site restore [backup-file.sql.gz]

# 3. Extract specific data
bench --site temp-recovery-site console
>>> data = frappe.get_all("DocType Name", 
...     filters={"creation": [">=", "2024-01-01"]},
...     fields=["*"])
>>> frappe.desk.form.save.save_file("recovered_data.json", 
...     json.dumps(data, indent=2, default=str))

# 4. Import recovered data to main site
bench --site [main-site] console
>>> with open("recovered_data.json", "r") as f:
...     data = json.load(f)
>>> for record in data:
...     doc = frappe.new_doc("DocType Name")
...     doc.update(record)
...     doc.insert()

# 5. Clean up temporary site
bench drop-site temp-recovery-site --force
```

## Application Recovery

### App Installation Failure Recovery

**Scenario:** App installation failed and broke site

```bash
# 1. Try to uninstall the problematic app
bench --site [site-name] uninstall-app [app-name]

# 2. If uninstall fails, manually remove from database
bench --site [site-name] console
>>> frappe.delete_doc("Module Def", [app-name], force=1)
>>> frappe.db.sql("DELETE FROM `tabInstalled Application` WHERE name = %s", [app-name])
>>> frappe.db.commit()

# 3. Remove app directory if it exists
rm -rf apps/[app-name]

# 4. Reset site to clean state
bench --site [site-name] migrate
bench --site [site-name] clear-cache
bench build

# 5. If still broken, restore from pre-installation backup
bench --site [site-name] restore [pre-installation-backup.sql.gz]
```

### Custom App Recovery

**Scenario:** Custom app causing issues

```bash
# 1. Identify the problematic custom app
bench --site [site-name] console
>>> frappe.get_installed_apps()

# 2. Check app status and recent changes
cd apps/[custom-app]
git log --oneline -10
git diff HEAD~1

# 3. Try rolling back recent changes
git revert [problematic-commit-hash]
bench restart

# 4. If revert doesn't work, disable app temporarily
bench --site [site-name] console
>>> frappe.db.set_value("Installed Application", [app-name], "enabled", 0)
>>> frappe.db.commit()
bench restart

# 5. Fix the issues and re-enable
# After fixing...
>>> frappe.db.set_value("Installed Application", [app-name], "enabled", 1)
>>> frappe.db.commit()
```

## Performance Recovery

### System Performance Issues

**Scenario:** System extremely slow or unresponsive

```bash
# 1. Immediate assessment
top
df -h
free -m
bench status

# 2. Check database performance
bench --site [site-name] mariadb
> SHOW PROCESSLIST;
> SHOW ENGINE INNODB STATUS;

# 3. Kill long-running queries if necessary
> KILL [process-id];

# 4. Clear cache and temporary files
bench --site [site-name] clear-cache
rm -rf logs/*
find . -name "*.pyc" -delete

# 5. Restart with fresh state
bench restart
bench build

# 6. Monitor resource usage
watch -n 5 'bench status; echo "---"; ps aux | head -20'
```

### Memory Recovery

**Scenario:** System running out of memory

```bash
# 1. Immediate memory check
free -h
ps aux --sort=-%mem | head -10

# 2. Restart bench processes to free memory
bench restart

# 3. Increase swap if available
sudo swapon --show
# If no swap:
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 4. Optimize database memory usage
bench --site [site-name] mariadb
> SET GLOBAL innodb_buffer_pool_size = [appropriate-size];

# 5. Monitor memory usage
watch -n 10 free -h
```

## Configuration Recovery

### Site Configuration Issues

**Scenario:** Site configuration corrupted

```bash
# 1. Backup current config
cp sites/[site-name]/site_config.json sites/[site-name]/site_config.json.backup

# 2. Check config syntax
python -c "import json; json.load(open('sites/[site-name]/site_config.json'))"

# 3. If syntax error, restore from backup or recreate
bench --site [site-name] set-config [key] [value]

# 4. Essential configs to verify
bench --site [site-name] console
>>> frappe.conf.db_name
>>> frappe.conf.db_password
>>> frappe.conf.encryption_key

# 5. If encryption key is lost, regenerate (will lose encrypted data)
bench --site [site-name] console
>>> from frappe.utils import generate_hash
>>> new_key = generate_hash()
>>> frappe.conf.encryption_key = new_key
```

### Nginx/Proxy Configuration Recovery

**Scenario:** Web server configuration issues

```bash
# 1. Test nginx configuration
sudo nginx -t

# 2. Restore from backup if syntax error
sudo cp /etc/nginx/sites-available/[site-name].backup /etc/nginx/sites-available/[site-name]

# 3. Regenerate nginx config if needed
bench setup nginx
sudo ln -sf /path/to/frappe-bench/config/nginx.conf /etc/nginx/sites-enabled/[site-name]

# 4. Restart nginx
sudo systemctl restart nginx

# 5. Verify web access
curl -I http://[site-domain]
```

## Security Incident Recovery

### Security Breach Response

**Scenario:** Suspected security breach

```bash
# 1. IMMEDIATE - Isolate the system
bench stop
sudo ufw deny 80
sudo ufw deny 443
# Keep SSH access for administrators only

# 2. Assess damage
bench --site [site-name] console
>>> recent_users = frappe.get_all("User", 
...     filters={"last_login": [">=", "2024-01-01"]},
...     fields=["name", "last_login", "last_ip"])

# 3. Check for unauthorized changes
bench --site [site-name] mariadb
> SELECT * FROM `tabVersion` WHERE creation >= '2024-01-01' 
  ORDER BY creation DESC LIMIT 100;

# 4. Reset all user passwords
bench --site [site-name] console
>>> users = frappe.get_all("User", filters={"enabled": 1})
>>> for user in users:
...     frappe.db.set_value("User", user.name, "reset_password_key", 
...                        frappe.generate_hash())
...     # Force password reset on next login

# 5. Review system logs
grep -i "error\|failed\|unauthorized" logs/*.log
sudo journalctl -u nginx -S "2024-01-01"

# 6. Restore from clean backup if needed
bench --site [site-name] restore [clean-backup.sql.gz]

# 7. Implement security hardening before going back online
# Update all passwords, enable 2FA, review permissions
```

### Data Breach Recovery

**Scenario:** Sensitive data potentially compromised

```bash
# 1. Immediate containment
bench stop
# Document everything for compliance

# 2. Assess scope of data exposure
bench --site [site-name] console
>>> sensitive_docs = frappe.get_all("DocType", 
...     filters={"modified": [">=", "incident_date"]})

# 3. Implement data protection measures
# Encrypt sensitive data
# Update access controls
# Enable audit logging

# 4. Compliance reporting
# Generate audit trail
# Document incident response
# Prepare breach notifications if required
```

## Monitoring and Prevention

### Health Check Procedures

**Daily Health Check:**
```bash
#!/bin/bash
# health_check.sh

echo "=== Frappe Bench Health Check ==="
echo "Date: $(date)"
echo

# System resources
echo "## System Resources"
free -h
df -h /
echo

# Bench status
echo "## Bench Status"
bench status
echo

# Database connectivity
echo "## Database Check"
bench --site [site-name] console --execute "print('Database OK' if frappe.db.sql('SELECT 1') else 'Database ERROR')"
echo

# Background jobs
echo "## Background Jobs"
bench --site [site-name] console --execute "print('Jobs:', len(frappe.get_all('RQ Job')))"
echo

# Recent errors
echo "## Recent Errors"
tail -50 logs/bench.log | grep -i error | tail -10
echo

echo "Health check complete"
```

**Automated Monitoring:**
```bash
# Setup monitoring script
crontab -e
# Add: */15 * * * * /path/to/health_check.sh >> /path/to/health.log 2>&1
```

### Backup Verification

**Regular Backup Testing:**
```bash
#!/bin/bash
# backup_test.sh

# 1. Create test site from backup
bench new-site test-restore-site
bench --site test-restore-site restore [latest-backup.sql.gz]

# 2. Verify data integrity
bench --site test-restore-site console --execute "
import frappe
print('Users:', frappe.db.count('User'))
print('DocTypes:', frappe.db.count('DocType'))
print('Test: Basic query successful')
"

# 3. Clean up
bench drop-site test-restore-site --force
echo "Backup verification complete"
```

## Emergency Contacts and Escalation

### Contact Information
```yaml
Primary Administrator: [name@example.com] [phone]
Secondary Administrator: [name@example.com] [phone]
Database Administrator: [name@example.com] [phone]
Security Team: [security@example.com] [phone]
Business Stakeholder: [business@example.com] [phone]
```

### Escalation Matrix
1. **Technical Issues**: Technical Admin → Database Admin → External Support
2. **Security Issues**: Security Team → Management → Legal (if required)
3. **Data Loss**: Business Stakeholder → Technical Admin → External Recovery Service
4. **Performance Issues**: Technical Admin → Infrastructure Team → Vendor Support

### Documentation Requirements

**For All Incidents:**
- [ ] Incident start time
- [ ] Detection method
- [ ] Initial assessment
- [ ] Recovery steps taken
- [ ] Resolution time
- [ ] Root cause analysis
- [ ] Prevention measures implemented
- [ ] Lessons learned
- [ ] Documentation updates needed

**Post-Incident Review:**
- Schedule within 48 hours of resolution
- Include all stakeholders
- Document improvements needed
- Update recovery procedures
- Update monitoring and alerting
- Plan preventive measures