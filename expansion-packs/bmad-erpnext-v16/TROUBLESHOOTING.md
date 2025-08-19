# TROUBLESHOOTING.md - Common Issues and Solutions

Comprehensive troubleshooting guide for the BMAD ERPNext v16 expansion pack.

## Table of Contents

- [Quick Diagnostics](#quick-diagnostics)
- [Installation Issues](#installation-issues)
- [Agent Issues](#agent-issues)
- [Development Issues](#development-issues)
- [Performance Issues](#performance-issues)
- [Security and Permissions](#security-and-permissions)
- [Integration Issues](#integration-issues)
- [Advanced Debugging](#advanced-debugging)

## Quick Diagnostics

### First Steps for Any Issue

```bash
# 1. Use the diagnostic specialist
/bmadErpNext:agent:diagnostic-specialist
"I'm experiencing [describe your issue]"

# 2. Check expansion pack status
*expansion-pack bmad-erpnext-v16*

# 3. Verify your environment
cd /home/frappe/frappe-bench
bench status
bench --site [your-site] console
>>> frappe.ping()
'pong'
```

### Health Check Command

Run this comprehensive health check:

```bash
# Check all critical components
/bmadErpNext:agent:diagnostic-specialist
"Run a complete health check of my ERPNext environment and BMAD setup"
```

## Installation Issues

### Issue: "Expansion pack not found"

**Symptoms:**
- Claude Code reports "expansion pack not found"
- Agents are not available
- Commands return "unknown expansion pack"

**Solutions:**

1. **Verify Installation Path**
   ```bash
   # Check if files exist
   ls -la /path/to/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/
   
   # Should show config.yaml and other files
   ```

2. **Reload Expansion Pack**
   ```bash
   # Reload in Claude Code
   *expansion-pack bmad-erpnext-v16*
   ```

3. **Reinstall if Necessary**
   ```bash
   # Clean reinstall
   cd /home/frappe/frappe-bench/apps/your-app
   npx bmad-method install --full --expansion-packs bmad-erpnext-v16 --force
   ```

### Issue: "Config file not found"

**Symptoms:**
- Error: "config.yaml not found"
- Default settings not loading

**Solutions:**

1. **Create Config from Template**
   ```bash
   cd /path/to/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/
   cp config.yaml.example config.yaml
   ```

2. **Fix File Permissions**
   ```bash
   chmod 644 config.yaml
   chown $(whoami):$(whoami) config.yaml
   ```

### Issue: "Node.js version incompatible"

**Symptoms:**
- Installation fails with Node.js errors
- "Version not supported" messages

**Solutions:**

1. **Update Node.js**
   ```bash
   # Using nvm (recommended)
   nvm install 20
   nvm use 20
   node --version  # Should show v20.x.x
   ```

2. **Alternative: Use NodeSource**
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

## Agent Issues

### Issue: "Agent not responding"

**Symptoms:**
- Agent command runs but no response
- Timeout errors
- Incomplete responses

**Solutions:**

1. **Check Agent Configuration**
   ```bash
   # Verify agent file exists
   cat agents/[agent-name].md
   
   # Look for syntax errors or incomplete configuration
   ```

2. **Restart Claude Code Session**
   ```bash
   # Exit and restart Claude Code
   exit
   # Start new session and reload expansion pack
   *expansion-pack bmad-erpnext-v16*
   ```

3. **Use Diagnostic Agent**
   ```bash
   /bmadErpNext:agent:diagnostic-specialist
   "Agent [agent-name] is not responding properly"
   ```

### Issue: "Agent access denied"

**Symptoms:**
- "Permission denied" when running agents
- "Agent not found" for valid agent names

**Solutions:**

1. **Verify Agent Path**
   ```bash
   # Check exact agent ID
   ls agents/
   # Use exact filename without .md extension
   ```

2. **Check Command Syntax**
   ```bash
   # Correct format
   /bmadErpNext:agent:exact-agent-id
   
   # Common mistakes
   /bmadErpNext:agent:exact_agent_id  # Wrong: uses underscores
   /bmadErpNext:exact-agent-id        # Wrong: missing :agent:
   ```

### Issue: "Universal workflow not running"

**Symptoms:**
- Agents skip safety protocols
- No context detection
- Missing workflow initialization

**Solutions:**

1. **Force Universal Workflow**
   ```bash
   /bmadErpNext:workflow:universal-context-detection
   "Initialize safety protocols for troubleshooting task"
   ```

2. **Check Workflow Configuration**
   ```bash
   cat workflows/universal-context-detection-workflow.yaml
   # Verify mandatory: true is set
   ```

## Development Issues

### Issue: "Bench commands fail"

**Symptoms:**
- "bench: command not found"
- Permission errors with bench
- Site operations fail

**Solutions:**

1. **Fix Bench Environment**
   ```bash
   # Navigate to bench directory
   cd /home/frappe/frappe-bench
   
   # Source environment
   source env/bin/activate
   
   # Verify bench works
   bench version
   ```

2. **Check Site Status**
   ```bash
   bench --site [your-site] status
   bench --site [your-site] doctor
   ```

3. **Use Bench Operator Agent**
   ```bash
   /bmadErpNext:agent:bench-operator
   "Help me troubleshoot bench command issues"
   ```

### Issue: "Vue components not building"

**Symptoms:**
- Frontend build failures
- Vue components not compiling
- Asset pipeline errors

**Solutions:**

1. **Clear Build Cache**
   ```bash
   cd /home/frappe/frappe-bench
   bench clear-cache
   bench build --app your-app
   ```

2. **Check Vue Setup**
   ```bash
   # Verify Vue files are in correct location
   ls apps/your-app/your-app/public/js/
   
   # Should show .vue files and .bundle.js files
   ```

3. **Use Vue Architect Agent**
   ```bash
   /bmadErpNext:agent:vue-spa-architect
   "My Vue components are not building properly"
   ```

### Issue: "API endpoints not working"

**Symptoms:**
- 404 errors on API calls
- Permission denied on API endpoints
- "Method not whitelisted" errors

**Solutions:**

1. **Check Whitelisting**
   ```python
   # Ensure @frappe.whitelist() decorator
   import frappe
   
   @frappe.whitelist()
   def your_api_method():
       return {"status": "success"}
   ```

2. **Verify API Module**
   ```bash
   # Check API file location
   ls apps/your-app/your-app/api/
   
   # Verify __init__.py exists
   ls apps/your-app/your-app/api/__init__.py
   ```

3. **Use API Architect Agent**
   ```bash
   /bmadErpNext:agent:api-architect
   "My API endpoints are returning 404 errors"
   ```

### Issue: "DocType creation fails"

**Symptoms:**
- Validation errors when creating DocTypes
- Field type errors
- Relationship setup issues

**Solutions:**

1. **Use DocType Designer Agent**
   ```bash
   /bmadErpNext:agent:doctype-designer
   "I'm having trouble creating a DocType with these requirements: [describe]"
   ```

2. **Check DocType JSON**
   ```bash
   # Verify DocType file structure
   cat apps/your-app/your-app/your_module/doctype/your_doctype/your_doctype.json
   ```

3. **Run Migration**
   ```bash
   bench --site [your-site] migrate
   ```

## Performance Issues

### Issue: "Slow agent responses"

**Symptoms:**
- Agents take a long time to respond
- Timeout errors
- Incomplete processing

**Solutions:**

1. **Check System Resources**
   ```bash
   # Monitor system load
   top
   htop
   
   # Check memory usage
   free -h
   
   # Check disk space
   df -h
   ```

2. **Optimize Configuration**
   ```yaml
   # In config.yaml
   settings:
     testing:
       test_timeout: 600  # Increase timeout
       run_parallel_tests: false  # Reduce load
   ```

3. **Use Performance Analysis**
   ```bash
   /bmadErpNext:task:performance-analysis
   "Analyze performance bottlenecks in my setup"
   ```

### Issue: "Database queries slow"

**Symptoms:**
- ERPNext operations are slow
- Database timeouts
- High CPU usage from database

**Solutions:**

1. **Check Database Health**
   ```bash
   bench --site [your-site] console
   >>> frappe.db.sql("SHOW PROCESSLIST")
   >>> exit()
   ```

2. **Optimize Queries**
   ```bash
   /bmadErpNext:agent:erpnext-qa-lead
   "Help me optimize slow database queries in my application"
   ```

3. **Add Database Indexes**
   ```python
   # In DocType hooks
   doc_events = {
       "Your DocType": {
           "on_update": "your_app.utils.add_indexes"
       }
   }
   ```

## Security and Permissions

### Issue: "Permission denied errors"

**Symptoms:**
- File permission errors
- API access denied
- Bench operation failures

**Solutions:**

1. **Fix File Permissions**
   ```bash
   # Fix expansion pack permissions
   chmod -R 755 /path/to/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/
   chmod 644 /path/to/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/config.yaml
   
   # Fix bench permissions
   cd /home/frappe/frappe-bench
   chown -R frappe:frappe .
   ```

2. **Check User Context**
   ```bash
   # Ensure you're running as correct user
   whoami  # Should show 'frappe' or your configured user
   
   # Switch to frappe user if needed
   sudo su - frappe
   ```

3. **Use Compliance Validator**
   ```bash
   /bmadErpNext:agent:frappe-compliance-validator
   "Check my ERPNext setup for permission and security issues"
   ```

### Issue: "API security violations"

**Symptoms:**
- Security warnings in logs
- Blocked API requests
- Authentication failures

**Solutions:**

1. **Review API Security**
   ```bash
   /bmadErpNext:agent:api-architect
   "Audit my API endpoints for security compliance"
   ```

2. **Check Whitelist Configuration**
   ```python
   # Ensure proper security
   @frappe.whitelist()
   def secure_api_method():
       if not frappe.has_permission("DocType", "read"):
           frappe.throw(_("Access denied"))
       return process_data()
   ```

## Integration Issues

### Issue: "DocFlow integration problems"

**Symptoms:**
- Workflow triggers not working
- DocFlow processes failing
- Integration errors

**Solutions:**

1. **Check DocFlow Status**
   ```bash
   bench --site [your-site] list-apps
   # Verify docflow is installed and active
   ```

2. **Use Workflow Specialist**
   ```bash
   /bmadErpNext:agent:workflow-specialist
   "Help me troubleshoot DocFlow integration issues"
   ```

3. **Test Integration**
   ```bash
   /bmadErpNext:task:integrate-docflow
   "Test and validate DocFlow integration"
   ```

### Issue: "n8n conversion errors"

**Symptoms:**
- n8n workflow conversion fails
- Mapping errors
- Trigger conversion issues

**Solutions:**

1. **Use n8n Conversion Team**
   ```bash
   /bmadErpNext:agent-team:n8n-conversion-team
   "I'm having trouble converting my n8n workflow: [describe issue]"
   ```

2. **Check Workflow JSON**
   ```bash
   # Validate n8n workflow format
   cat your-n8n-workflow.json | jq .
   ```

### Issue: "Airtable migration failures"

**Symptoms:**
- Data migration incomplete
- Field mapping errors
- Import failures

**Solutions:**

1. **Use Airtable Migration Team**
   ```bash
   /bmadErpNext:agent-team:airtable-migration-team
   "My Airtable migration is failing at [specific step]"
   ```

2. **Check API Limits**
   ```bash
   # Verify Airtable API quota
   # Check rate limiting in logs
   ```

## Advanced Debugging

### Enable Debug Mode

```yaml
# In config.yaml
settings:
  development:
    debug_mode: true
    log_level: "DEBUG"
```

### Agent-Specific Debugging

```bash
# Debug specific agent behavior
/bmadErpNext:agent:diagnostic-specialist
"Enable debug mode for [specific-agent] and trace execution"
```

### Workflow Debugging

```bash
# Debug workflow execution
/bmadErpNext:workflow:diagnostic-workflow
"Debug workflow: [workflow-name] with detailed logging"
```

### Log Analysis

```bash
# Check ERPNext logs
tail -f /home/frappe/frappe-bench/logs/web.log

# Check bench logs
bench --site [your-site] logs

# Check expansion pack logs (if available)
tail -f ~/.bmad-method/logs/debug.log
```

## Recovery Procedures

### Complete Reset

If all else fails, perform a complete reset:

```bash
# 1. Backup current configuration
cp config.yaml config.yaml.backup

# 2. Reinstall expansion pack
cd /home/frappe/frappe-bench/apps/your-app
npx bmad-method install --full --expansion-packs bmad-erpnext-v16 --force

# 3. Restore configuration
cp config.yaml.backup config.yaml

# 4. Test installation
*expansion-pack bmad-erpnext-v16*
```

### Selective Recovery

For specific component issues:

```bash
# Recover specific agents
/bmadErpNext:agent:diagnostic-specialist
"Recover and reinstall agent: [agent-name]"

# Recover workflows
/bmadErpNext:workflow:diagnostic-workflow
"Recover workflow configuration for: [workflow-name]"
```

## Getting Additional Help

### Built-in Help

```bash
# Use diagnostic specialist for any issue
/bmadErpNext:agent:diagnostic-specialist
"I need help with [describe your issue in detail]"

# Use specific specialist agents
/bmadErpNext:agent:bench-operator       # For bench issues
/bmadErpNext:agent:vue-spa-architect    # For frontend issues
/bmadErpNext:agent:api-architect        # For API issues
/bmadErpNext:agent:doctype-designer     # For DocType issues
```

### Community Support

1. **GitHub Issues**: Report bugs and get help from the community
2. **Documentation**: Check `CLAUDE.md` for comprehensive guidelines
3. **Examples**: Review template files in `/templates/` directory

### Professional Support

For complex enterprise deployments, consider professional support through the BMAD Method community.

## Common Error Messages

### "Module 'your_app' not found"

**Solution**: Install and configure your app properly
```bash
bench get-app your-app
bench --site [your-site] install-app your-app
```

### "ImportError: No module named 'frappe'"

**Solution**: Activate bench environment
```bash
cd /home/frappe/frappe-bench
source env/bin/activate
```

### "PermissionError: [Errno 13] Permission denied"

**Solution**: Fix file permissions
```bash
sudo chown -R frappe:frappe /home/frappe/frappe-bench
chmod -R 755 /home/frappe/frappe-bench
```

### "ValidationError: DocType not found"

**Solution**: Run migrations
```bash
bench --site [your-site] migrate
bench --site [your-site] clear-cache
```

---

## Still Having Issues?

If you're still experiencing problems after following this guide:

1. **Use the diagnostic specialist**: This is your first and best resource
2. **Check the logs**: Look for specific error messages
3. **Review configuration**: Ensure your `config.yaml` matches your environment
4. **Ask for help**: Provide detailed error messages and context when seeking help

The BMAD ERPNext v16 expansion pack is designed to be self-healing and diagnostic-capable. The agents can often solve their own issues when given proper context.