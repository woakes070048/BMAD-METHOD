# Task: Diagnose System Issues

## Description
Systematically diagnose and troubleshoot ERPNext system issues including performance problems, errors, data inconsistencies, and integration failures using comprehensive diagnostic tools and techniques.

## Required Agents
- diagnostic-specialist
- testing-specialist
- bench-operator

## Input Requirements
1. **Issue Description**:
   - Error messages or symptoms
   - When issue started occurring
   - Affected modules/features
   - User impact assessment

2. **System Information**:
   - ERPNext version
   - Frappe version
   - Server specifications
   - Recent changes or deployments

## Process Steps

### 1. Initial Assessment
```yaml
initial_diagnosis:
  system_health_check:
    - Check server resources (CPU, RAM, Disk)
    - Review error logs
    - Check database connectivity
    - Verify Redis/cache status
    - Check background job queue
    
  quick_diagnostics:
    commands:
      - "bench doctor"
      - "bench --site [site] doctor"
      - "bench --site [site] mariadb"
      - "bench --site [site] console"
    
  log_analysis:
    locations:
      - "frappe-bench/logs/bench.log"
      - "frappe-bench/logs/worker.log"
      - "frappe-bench/logs/web.error.log"
      - "frappe-bench/logs/scheduler.log"
```

### 2. Performance Diagnostics
```python
# performance_diagnostics.py
import frappe
from frappe.utils import nowtime
import psutil
import time

class PerformanceDiagnostics:
    def __init__(self):
        self.metrics = {}
        
    def run_diagnostics(self):
        """Run comprehensive performance diagnostics"""
        
        # System resources
        self.check_system_resources()
        
        # Database performance
        self.check_database_performance()
        
        # Cache performance
        self.check_cache_performance()
        
        # Background jobs
        self.check_job_queue()
        
        # API response times
        self.check_api_performance()
        
        return self.generate_report()
    
    def check_system_resources(self):
        """Check CPU, memory, and disk usage"""
        self.metrics['system'] = {
            'cpu_percent': psutil.cpu_percent(interval=1),
            'memory_percent': psutil.virtual_memory().percent,
            'disk_percent': psutil.disk_usage('/').percent,
            'load_average': psutil.getloadavg(),
            'process_count': len(psutil.pids())
        }
        
        # Check for resource bottlenecks
        if self.metrics['system']['cpu_percent'] > 80:
            self.add_warning("High CPU usage detected")
        if self.metrics['system']['memory_percent'] > 90:
            self.add_warning("High memory usage detected")
            
    def check_database_performance(self):
        """Analyze database performance metrics"""
        
        # Check slow queries
        slow_queries = frappe.db.sql("""
            SELECT query_time, sql_text 
            FROM mysql.slow_log 
            ORDER BY query_time DESC 
            LIMIT 10
        """, as_dict=True)
        
        # Check table sizes
        large_tables = frappe.db.sql("""
            SELECT 
                table_name,
                round(((data_length + index_length) / 1024 / 1024), 2) as size_mb,
                table_rows
            FROM information_schema.TABLES
            WHERE table_schema = %s
            ORDER BY (data_length + index_length) DESC
            LIMIT 10
        """, frappe.conf.db_name, as_dict=True)
        
        # Check for missing indexes
        missing_indexes = self.analyze_missing_indexes()
        
        self.metrics['database'] = {
            'slow_queries': slow_queries,
            'large_tables': large_tables,
            'missing_indexes': missing_indexes,
            'connection_count': self.get_db_connections()
        }
        
    def check_cache_performance(self):
        """Check Redis cache performance"""
        import redis
        
        r = redis.Redis.from_url(frappe.conf.redis_cache)
        info = r.info()
        
        self.metrics['cache'] = {
            'used_memory': info['used_memory_human'],
            'connected_clients': info['connected_clients'],
            'evicted_keys': info.get('evicted_keys', 0),
            'hit_rate': self.calculate_hit_rate(info),
            'keyspace': info.get('db0', {})
        }
        
        if info.get('evicted_keys', 0) > 0:
            self.add_warning(f"Cache eviction detected: {info['evicted_keys']} keys")
```

### 3. Error Pattern Analysis
```python
def analyze_error_patterns():
    """Analyze error logs for patterns"""
    
    import re
    from collections import Counter
    from datetime import datetime, timedelta
    
    # Get errors from last 24 hours
    since = datetime.now() - timedelta(hours=24)
    
    errors = frappe.get_all(
        "Error Log",
        filters={"creation": (">", since)},
        fields=["error", "method", "creation"],
        limit=1000
    )
    
    # Pattern analysis
    error_patterns = {
        'permission_errors': r'PermissionError|InsufficientPermissionError',
        'validation_errors': r'ValidationError|MandatoryError',
        'database_errors': r'ProgrammingError|OperationalError|IntegrityError',
        'import_errors': r'ImportError|ModuleNotFoundError',
        'timeout_errors': r'TimeoutError|ReadTimeoutError',
        'connection_errors': r'ConnectionError|ConnectionRefusedError'
    }
    
    categorized_errors = {category: [] for category in error_patterns}
    
    for error in errors:
        for category, pattern in error_patterns.items():
            if re.search(pattern, error.get('error', '')):
                categorized_errors[category].append(error)
                break
    
    # Find error frequency
    error_frequency = Counter([e.get('method') for e in errors])
    
    return {
        'total_errors': len(errors),
        'categorized': {k: len(v) for k, v in categorized_errors.items()},
        'top_errors': error_frequency.most_common(10),
        'error_timeline': generate_error_timeline(errors)
    }
```

### 4. Data Integrity Checks
```python
def check_data_integrity():
    """Check for data inconsistencies"""
    
    issues = []
    
    # Check for orphaned records
    orphaned = frappe.db.sql("""
        SELECT si.name, si.customer
        FROM `tabSales Invoice` si
        LEFT JOIN `tabCustomer` c ON si.customer = c.name
        WHERE c.name IS NULL AND si.docstatus = 1
    """, as_dict=True)
    
    if orphaned:
        issues.append({
            'type': 'orphaned_records',
            'severity': 'high',
            'count': len(orphaned),
            'description': 'Sales Invoices with non-existent customers'
        })
    
    # Check for duplicate records
    duplicates = frappe.db.sql("""
        SELECT COUNT(*) as count, customer_name
        FROM `tabCustomer`
        GROUP BY customer_name
        HAVING COUNT(*) > 1
    """, as_dict=True)
    
    if duplicates:
        issues.append({
            'type': 'duplicate_records',
            'severity': 'medium',
            'count': len(duplicates),
            'description': 'Duplicate customer names found'
        })
    
    # Check for invalid status transitions
    invalid_status = frappe.db.sql("""
        SELECT name, workflow_state, docstatus
        FROM `tabSales Order`
        WHERE workflow_state = 'Approved' AND docstatus = 0
    """, as_dict=True)
    
    if invalid_status:
        issues.append({
            'type': 'invalid_status',
            'severity': 'high',
            'count': len(invalid_status),
            'description': 'Documents with mismatched workflow state and docstatus'
        })
    
    return issues
```

### 5. Integration Diagnostics
```python
def diagnose_integrations():
    """Check external integration health"""
    
    integration_status = {}
    
    # Check API endpoints
    api_endpoints = frappe.get_all(
        "API Endpoint",
        fields=["name", "url", "last_response_code", "last_checked"]
    )
    
    for endpoint in api_endpoints:
        try:
            import requests
            response = requests.get(endpoint.url, timeout=5)
            integration_status[endpoint.name] = {
                'status': 'healthy' if response.status_code == 200 else 'degraded',
                'response_code': response.status_code,
                'response_time': response.elapsed.total_seconds()
            }
        except Exception as e:
            integration_status[endpoint.name] = {
                'status': 'failed',
                'error': str(e)
            }
    
    # Check webhooks
    webhooks = frappe.get_all(
        "Webhook",
        fields=["name", "webhook_url", "enabled"],
        filters={"enabled": 1}
    )
    
    for webhook in webhooks:
        # Check webhook logs for failures
        recent_failures = frappe.db.count(
            "Webhook Log",
            filters={
                "webhook": webhook.name,
                "status": "Failed",
                "creation": (">", frappe.utils.add_days(nowtime(), -1))
            }
        )
        
        integration_status[f"webhook_{webhook.name}"] = {
            'recent_failures': recent_failures,
            'status': 'healthy' if recent_failures == 0 else 'degraded'
        }
    
    return integration_status
```

### 6. Diagnostic Report Generation
```python
def generate_diagnostic_report(diagnostics):
    """Generate comprehensive diagnostic report"""
    
    report = {
        'timestamp': nowtime(),
        'summary': {
            'health_score': calculate_health_score(diagnostics),
            'critical_issues': count_critical_issues(diagnostics),
            'warnings': count_warnings(diagnostics),
            'status': determine_overall_status(diagnostics)
        },
        'system_metrics': diagnostics['system'],
        'database_analysis': diagnostics['database'],
        'cache_metrics': diagnostics['cache'],
        'error_analysis': diagnostics['errors'],
        'data_integrity': diagnostics['integrity'],
        'integrations': diagnostics['integrations'],
        'recommendations': generate_recommendations(diagnostics)
    }
    
    # Save report
    frappe.get_doc({
        'doctype': 'Diagnostic Report',
        'report_data': json.dumps(report),
        'health_score': report['summary']['health_score'],
        'status': report['summary']['status']
    }).insert()
    
    return report
```

## Output Format

### Diagnostic Report Structure
```yaml
diagnostic_report:
  summary:
    health_score: 85
    status: "Warning"
    critical_issues: 2
    warnings: 5
    
  issues_found:
    - category: "Performance"
      severity: "High"
      issue: "Slow database queries"
      details: "5 queries taking > 10 seconds"
      recommendation: "Add indexes on frequently queried columns"
      
    - category: "Data Integrity"
      severity: "Critical"
      issue: "Orphaned records found"
      details: "23 invoices reference non-existent customers"
      recommendation: "Run data cleanup script"
      
  performance_metrics:
    database:
      query_time_avg: "250ms"
      slow_queries: 5
      connection_pool: "80% utilized"
      
    cache:
      hit_rate: "92%"
      memory_usage: "450MB"
      evicted_keys: 0
      
    system:
      cpu_usage: "65%"
      memory_usage: "78%"
      disk_io: "moderate"
      
  recommendations:
    immediate:
      - "Fix orphaned customer references"
      - "Add missing database indexes"
      
    short_term:
      - "Optimize slow queries"
      - "Increase cache memory"
      
    long_term:
      - "Consider database sharding"
      - "Implement read replicas"
```

## Success Criteria
- All critical issues identified
- Root causes determined
- Performance bottlenecks found
- Data integrity verified
- Clear action plan provided
- Monitoring established

## Common Patterns

### Diagnostic Patterns
```yaml
common_issues:
  performance:
    - Missing database indexes
    - Inefficient queries
    - Cache misconfigurations
    - Background job bottlenecks
    
  data_integrity:
    - Orphaned records
    - Duplicate entries
    - Invalid status combinations
    - Broken relationships
    
  integration:
    - API timeouts
    - Authentication failures
    - Rate limiting
    - Network connectivity
    
  system:
    - Resource exhaustion
    - Permission issues
    - Configuration errors
    - Version conflicts
```

## Error Handling

### Diagnostic Failures
1. **Access Denied**: Check diagnostic permissions
2. **Resource Limits**: Run diagnostics in batches
3. **Timeout Issues**: Increase diagnostic timeouts
4. **Missing Tools**: Install required diagnostic packages
5. **Incomplete Data**: Note limitations in report

## Dependencies
- System monitoring tools
- Database query access
- Log file access
- Redis connection
- Network diagnostic tools

## Next Steps
After diagnosis:
1. Prioritize issues by severity
2. Create fix implementation plan
3. Test fixes in staging
4. Deploy solutions
5. Monitor for improvement