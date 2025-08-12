# BMAD ERPNext v15 - Troubleshooting Guide

## Quick Diagnostic Commands

Before diving into specific issues, run these diagnostic commands to get system status:

```bash
# Check expansion pack status
*expansion-pack bmad-erpnext-v15*

# Run system diagnostics
*agent bench-operator*
"Run comprehensive bench and ERPNext diagnostics"

# Check available agents
*list-agents*

# Check available workflows
*list-workflows*
```

## Common Issues & Solutions

### 1. Expansion Pack Issues

#### ❌ "Expansion pack not found" 
**Symptoms**: Claude can't load the bmad-erpnext-v15 expansion pack

**Solutions**:
```bash
# Check directory structure
ls -la BMAD-METHOD/expansion-packs/
ls -la BMAD-METHOD/expansion-packs/bmad-erpnext-v15/

# Verify config.yaml exists
cat BMAD-METHOD/expansion-packs/bmad-erpnext-v15/config.yaml

# Re-clone if necessary
git clone https://github.com/bmad-code-org/BMAD-METHOD.git

# Reload expansion pack
*expansion-pack bmad-erpnext-v15*
```

#### ❌ "Agent not found" errors
**Symptoms**: Specific agents like `vue-spa-architect` are not available

**Solutions**:
```bash
# Check agent files exist
ls -la BMAD-METHOD/expansion-packs/bmad-erpnext-v15/agents/

# Check config.yaml agent listings
grep -A 20 "agents:" config.yaml

# Verify agent file syntax
*agent bench-operator*
"Validate all agent configuration files"
```

#### ❌ "Workflow not found" errors
**Symptoms**: Workflows like `business-analysis-to-app` are not available

**Solutions**:
```bash
# Check workflow files exist
ls -la BMAD-METHOD/expansion-packs/bmad-erpnext-v15/workflows/

# Validate workflow configuration
grep -A 10 "workflows:" config.yaml

# Test specific workflow
*workflow enhancement*
"Test workflow functionality"
```

### 2. ERPNext Environment Issues

#### ❌ Bench commands fail
**Symptoms**: `bench --version` fails or bench operations error

**Solutions**:
```bash
# Check bench installation
which bench
bench --version

# Check current directory
pwd
# Should be in frappe-bench directory

# Navigate to bench directory
cd /path/to/your/frappe-bench

# Check bench status
bench doctor

# Fix common bench issues
*agent bench-operator*
"Diagnose and fix bench environment issues"
```

#### ❌ Site not accessible
**Symptoms**: ERPNext site returns 502/503 errors or won't load

**Solutions**:
```bash
# Check site status
bench --site your-site.com doctor

# Check processes
bench status

# Start bench if stopped
bench start

# Check site configuration
*agent erpnext-architect*
"Diagnose site accessibility issues and verify configuration"
```

#### ❌ Permission denied errors
**Symptoms**: Cannot create files, access directories, or execute commands

**Solutions**:
```bash
# Check file permissions
ls -la /path/to/frappe-bench/

# Fix ownership issues (run from bench directory)
sudo chown -R $(whoami):$(whoami) .

# Check ERPNext permissions
*agent erpnext-architect*
"Check and fix ERPNext file and directory permissions"

# Verify user permissions in ERPNext
bench --site your-site.com add-system-manager your-email@domain.com
```

### 3. Development Issues

#### ❌ Vue/Frontend build failures
**Symptoms**: Frontend compilation errors, missing dependencies

**Common Frontend Errors & Solutions**:

**Module resolution errors:**
```bash
Error: Failed to resolve import "frappe-ui" from "src/main.js"

# Solution:
# Check if frappe-ui is installed
yarn list frappe-ui

# Reinstall if missing
yarn add frappe-ui

# Clear cache and rebuild
rm -rf node_modules/.vite
yarn dev
```

**Build fails with "Cannot resolve module":**
```bash
ERROR: [vite:esbuild] Transform failed with 1 error:
node_modules/frappe-ui/src/index.js:1:7: ERROR: No loader is configured for ".vue" files

# Solution - vite.config.js - ensure Vue plugin is configured:
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  optimizeDeps: {
    include: ['frappe-ui']
  }
})
```

**CSRF Token Issues - 403 Forbidden on API calls:**
```javascript
POST http://localhost:8000/api/method/your_app.api.test 403 (Forbidden)

// For development - add to site_config.json
{
  "ignore_csrf": 1
}

// For production - ensure CSRF token is available
// main.js
import { setConfig, frappeRequest } from 'frappe-ui'

frappeRequest.configure({
  headers: {
    'X-Frappe-CSRF-Token': window.csrf_token || ''
  }
})
```

**Router Issues - Routes not working in production:**
```python
# hooks.py - ensure SPA routing is configured
website_route_rules = [
    {"from_route": "/your_app/<path:app_path>", "to_route": "your_app"},
]
```

**General Diagnostics**:
```bash
# Check Node.js version
node --version  # Should be 18+
npm --version

# Clear npm cache
npm cache clean --force

# Check frontend setup
*agent vue-spa-architect*
"Diagnose frontend development environment and fix build issues"

# Rebuild frontend assets
*agent bench-operator*
"Build frontend assets and resolve dependencies"
```

#### ❌ Python import errors
**Symptoms**: ImportError, ModuleNotFoundError in ERPNext

**Solutions**:
```bash
# Check Python environment
python3 --version
which python3

# Check virtual environment
source env/bin/activate  # From bench directory

# Install missing dependencies
bench setup requirements

# Fix import issues
*agent erpnext-architect*
"Resolve Python import errors and dependencies"
```

#### ❌ Database connection issues
**Symptoms**: Database errors, connection refused

**Solutions**:
```bash
# Check MariaDB status
sudo systemctl status mariadb

# Check database connectivity
mysql -u root -p
SHOW DATABASES;

# Fix database issues
*agent erpnext-architect*
"Diagnose and resolve database connectivity issues"

# Regenerate database configuration
bench --site your-site.com set-admin-password newpassword
```

### 4. API and Integration Issues

#### ❌ API authentication failures
**Symptoms**: 403 Forbidden, authentication errors

**API Permission Errors:**
```python
frappe.exceptions.PermissionError: No permission for Customer

# Solution - Check user permissions in API method:
@frappe.whitelist()
def your_api_method():
    # Debug permissions
    user = frappe.session.user
    roles = frappe.get_roles(user)
    print(f"User: {user}, Roles: {roles}")
    
    # Check specific permission
    if not frappe.has_permission("Customer", "read"):
        frappe.throw("No permission to read customers")
```

**General API Diagnostics:**
```bash
# Check API key configuration
*agent api-architect*
"Diagnose API authentication issues and verify key configuration"

# Generate new API keys
bench --site your-site.com add-system-manager api-user@domain.com

# Test API endpoints
curl -X GET "http://your-site.com/api/resource/User" \
  -H "Authorization: token api_key:api_secret"
```

#### ❌ CORS errors in frontend
**Symptoms**: Cross-origin request errors in browser

**Solutions**:
```bash
# Check CORS configuration
*agent api-architect*
"Configure CORS settings for frontend-backend communication"

# Update site_config.json
*agent erpnext-architect*
"Update CORS configuration in site_config.json"
```

#### ❌ Webhook/integration failures
**Symptoms**: External integrations not working

**Solutions**:
```bash
# Check webhook configuration
*agent integration-engineer*
"Diagnose webhook and external integration issues"

# Test webhook endpoints
*agent automation-specialist*
"Test and validate webhook functionality"

# Check firewall/network issues
ping external-service.com
telnet external-service.com 443
```

### 5. Performance Issues

#### ❌ Slow page loads
**Symptoms**: ERPNext pages load slowly, timeouts

**Frontend Performance Issues:**

**Large bundle size causing slow loading:**
```javascript
// Implement code splitting
const Dashboard = () => import('@/pages/Dashboard.vue')
const CustomerList = () => import('@/pages/CustomerList.vue')

const routes = [
  { path: '/dashboard', component: Dashboard },
  { path: '/customers', component: CustomerList }
]
```

**General Performance Diagnostics:**
```bash
# Check system resources
top
df -h

# Analyze performance
*agent monitoring-specialist*
"Analyze system performance and identify bottlenecks"

# Optimize database
bench --site your-site.com optimize-database

# Clear cache
bench --site your-site.com clear-cache
```

#### ❌ High memory usage
**Symptoms**: System running out of memory, processes killed

**Solutions**:
```bash
# Check memory usage
free -h
ps aux --sort=-%mem | head

# Optimize memory usage
*agent deployment-engineer*
"Optimize memory usage and configure swap if necessary"

# Restart services
bench restart
```

### 6. Mobile and PWA Issues

#### ❌ PWA not installing
**Symptoms**: Install prompt not showing, PWA features not working

**Solutions**:
```bash
# Check PWA configuration
*agent pwa-specialist*
"Diagnose PWA installation issues and verify service worker"

# Test PWA requirements
# - HTTPS enabled
# - Valid manifest.json
# - Service worker registered
```

#### ❌ Mobile app build failures
**Symptoms**: React Native/Flutter build errors

**Solutions**:
```bash
# Check mobile development environment
*agent mobile-team*
"Diagnose mobile development environment and dependencies"

# Platform-specific debugging:
# iOS: Check Xcode installation
# Android: Check Android SDK configuration
```

### 7. Deployment Issues

#### ❌ Production deployment failures
**Symptoms**: Deploy scripts fail, services won't start

**Solutions**:
```bash
# Check deployment configuration
*agent deployment-engineer*
"Diagnose production deployment issues and verify configuration"

# Check server resources
df -h
systemctl status nginx
systemctl status mysql

# Verify SSL certificates
*agent security-specialist*
"Check SSL certificate configuration and renewal"
```

#### ❌ Docker container issues
**Symptoms**: Containers not starting, port conflicts

**Solutions**:
```bash
# Check Docker status
docker ps -a
docker logs container-name

# Fix Docker issues
*agent deployment-team*
"Diagnose and resolve Docker container issues"

# Check port conflicts
netstat -tulpn | grep :8000
```

## Advanced Diagnostics

### System Health Check
```bash
*agent bench-operator*
"Run complete system health check including bench, database, and application status"
```

### Performance Analysis
```bash
*agent monitoring-specialist*
"Perform comprehensive performance analysis with recommendations"
```

### Security Audit
```bash
*agent security-specialist*
"Conduct security audit and identify potential vulnerabilities"
```

### Database Analysis
```bash
*agent erpnext-architect*
"Analyze database performance and identify optimization opportunities"
```

## Environment-Specific Issues

### Development Environment
- **Issue**: Frequent restarts needed
- **Solution**: Use `bench watch` for auto-reload during development

### Staging Environment
- **Issue**: Different behavior than development
- **Solution**: Ensure data and configuration parity

### Production Environment
- **Issue**: Performance degradation
- **Solution**: Implement monitoring and regular optimization

## Log Files to Check

### ERPNext Logs
```bash
# Application logs
tail -f logs/worker.error.log
tail -f logs/web.error.log

# Bench logs
tail -f logs/bench.log

# Database logs
sudo tail -f /var/log/mysql/error.log
```

### System Logs
```bash
# System messages
sudo tail -f /var/log/syslog

# Nginx logs (if using)
sudo tail -f /var/log/nginx/error.log
```

## Emergency Recovery

### Site Recovery
```bash
# Backup current state
bench --site your-site.com backup

# Restore from backup
bench --site your-site.com restore backup-file.sql

# Rebuild if necessary
bench build --app your-app
```

### Database Recovery
```bash
# Create database backup
mysqldump -u root -p database_name > backup.sql

# Restore database
mysql -u root -p database_name < backup.sql

# Run database migrations
bench --site your-site.com migrate
```

## Getting Additional Help

### Community Support
1. **BMAD-METHOD GitHub Issues**: Report bugs and get help
2. **Frappe Community Forum**: ERPNext-specific questions
3. **Frappe GitHub**: Framework-level issues

### Professional Support
1. **BMAD Consulting**: Expert ERPNext development support
2. **Frappe Cloud**: Managed ERPNext hosting
3. **Certified Partners**: Local ERPNext implementation partners

### Self-Service Resources
1. **ERPNext Documentation**: https://docs.erpnext.com/
2. **Frappe Framework Documentation**: https://frappeframework.com/docs/
3. **ERPNext YouTube Channel**: Video tutorials and guides

## Prevention Best Practices

1. **Regular Backups**: Automate daily backups
2. **Environment Parity**: Keep dev/staging/prod similar
3. **Monitoring**: Implement proactive monitoring
4. **Documentation**: Document customizations and processes
5. **Testing**: Test thoroughly before production deployment
6. **Updates**: Keep system and dependencies updated
7. **Security**: Regular security audits and updates

---

**Still having issues?** Use the diagnostic agents to get specific help for your situation, or reach out to the BMAD-METHOD community for support.