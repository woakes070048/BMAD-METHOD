# performance-analysis

## Task Description
Analyze and optimize performance bottlenecks in ERPNext applications including database queries, API response times, frontend rendering, and resource utilization.

## Parameters
- `analysis_scope`: database, api, frontend, or comprehensive
- `target_areas`: Specific modules or operations to analyze
- `performance_threshold`: Performance criteria (response time, throughput)
- `optimization_level`: basic, standard, or aggressive
- `generate_report`: Generate detailed performance report (default: true)

## Prerequisites
- Performance monitoring tools configured
- Baseline metrics established
- Test data available
- Access to system metrics

## Steps

### 1. Database Performance Analysis
```python
def analyze_database_performance(site, modules=None):
    """Analyze database performance and identify bottlenecks"""
    
    analysis = {
        "site": site,
        "timestamp": frappe.utils.now(),
        "slow_queries": [],
        "missing_indexes": [],
        "table_statistics": [],
        "optimization_opportunities": []
    }
    
    # Analyze slow queries
    slow_queries = identify_slow_queries(site)
    analysis["slow_queries"] = slow_queries
    
    # Check for missing indexes
    missing_indexes = find_missing_indexes(site, modules)
    analysis["missing_indexes"] = missing_indexes
    
    # Analyze table sizes and growth
    table_stats = analyze_table_statistics(site)
    analysis["table_statistics"] = table_stats
    
    # Identify N+1 query problems
    n_plus_one = detect_n_plus_one_queries(site, modules)
    analysis["n_plus_one_queries"] = n_plus_one
    
    # Analyze query patterns
    query_patterns = analyze_query_patterns(site)
    analysis["query_patterns"] = query_patterns
    
    # Generate optimization recommendations
    analysis["optimization_opportunities"] = generate_db_optimizations(analysis)
    
    return analysis

def identify_slow_queries(site, threshold_ms=1000):
    """Identify queries taking longer than threshold"""
    
    slow_queries = []
    
    # Get slow query log
    query_log = frappe.db.sql("""
        SELECT 
            query_time,
            lock_time,
            rows_sent,
            rows_examined,
            sql_text
        FROM mysql.slow_log
        WHERE query_time > %s
        ORDER BY query_time DESC
        LIMIT 100
    """, (threshold_ms / 1000,), as_dict=True)
    
    for query in query_log:
        # Analyze query execution plan
        explain_plan = get_query_execution_plan(query["sql_text"])
        
        slow_queries.append({
            "query": query["sql_text"][:500],  # Truncate long queries
            "execution_time": query["query_time"],
            "rows_examined": query["rows_examined"],
            "rows_sent": query["rows_sent"],
            "efficiency_ratio": query["rows_sent"] / max(query["rows_examined"], 1),
            "execution_plan": explain_plan,
            "optimization_suggestions": suggest_query_optimizations(query, explain_plan)
        })
    
    return slow_queries

def find_missing_indexes(site, modules=None):
    """Identify missing database indexes"""
    
    missing_indexes = []
    
    # Get all tables for specified modules
    tables = get_module_tables(modules) if modules else get_all_tables()
    
    for table in tables:
        # Analyze table structure
        table_info = analyze_table_structure(table)
        
        # Check for common query patterns without indexes
        unindexed_queries = find_unindexed_queries(table)
        
        if unindexed_queries:
            missing_indexes.append({
                "table": table,
                "suggested_indexes": suggest_indexes(table, unindexed_queries),
                "impact": estimate_index_impact(table, unindexed_queries),
                "affected_queries": len(unindexed_queries)
            })
    
    return missing_indexes

def detect_n_plus_one_queries(site, modules=None):
    """Detect N+1 query problems in code"""
    
    n_plus_one_issues = []
    
    # Analyze code for loop patterns with queries
    code_files = get_module_python_files(modules) if modules else get_all_python_files()
    
    for file_path in code_files:
        with open(file_path, 'r') as f:
            content = f.read()
        
        # Pattern matching for N+1 queries
        patterns = [
            r'for .* in .*:\s*frappe\.get_doc',
            r'for .* in .*:\s*frappe\.db\.get_value',
            r'for .* in .*:\s*frappe\.db\.sql'
        ]
        
        import re
        for pattern in patterns:
            matches = re.finditer(pattern, content, re.MULTILINE)
            for match in matches:
                line_num = content[:match.start()].count('\n') + 1
                n_plus_one_issues.append({
                    "file": file_path,
                    "line": line_num,
                    "pattern": match.group(),
                    "suggestion": "Use frappe.get_all() or single query with JOIN",
                    "severity": "high"
                })
    
    return n_plus_one_issues
```

### 2. API Performance Analysis
```python
def analyze_api_performance(site, endpoints=None):
    """Analyze API endpoint performance"""
    
    api_analysis = {
        "endpoints": [],
        "response_times": {},
        "throughput": {},
        "error_rates": {},
        "bottlenecks": []
    }
    
    # Get all API endpoints or specified ones
    api_endpoints = endpoints or discover_api_endpoints(site)
    
    for endpoint in api_endpoints:
        # Measure response times
        response_metrics = measure_api_response_time(endpoint)
        
        # Analyze throughput
        throughput_metrics = measure_api_throughput(endpoint)
        
        # Check error rates
        error_metrics = analyze_api_errors(endpoint)
        
        api_analysis["endpoints"].append({
            "endpoint": endpoint,
            "avg_response_time": response_metrics["average"],
            "p95_response_time": response_metrics["p95"],
            "p99_response_time": response_metrics["p99"],
            "throughput": throughput_metrics["requests_per_second"],
            "error_rate": error_metrics["error_percentage"],
            "bottlenecks": identify_api_bottlenecks(endpoint, response_metrics)
        })
    
    return api_analysis

def measure_api_response_time(endpoint, iterations=100):
    """Measure API endpoint response times"""
    
    response_times = []
    
    for _ in range(iterations):
        start_time = time.time()
        
        try:
            # Make API request
            response = make_api_request(endpoint)
            response_time = (time.time() - start_time) * 1000  # Convert to ms
            response_times.append(response_time)
        except Exception as e:
            # Log error but continue
            frappe.log_error(f"API performance test error: {e}")
    
    # Calculate statistics
    response_times.sort()
    
    return {
        "min": min(response_times) if response_times else 0,
        "max": max(response_times) if response_times else 0,
        "average": sum(response_times) / len(response_times) if response_times else 0,
        "median": response_times[len(response_times) // 2] if response_times else 0,
        "p95": response_times[int(len(response_times) * 0.95)] if response_times else 0,
        "p99": response_times[int(len(response_times) * 0.99)] if response_times else 0,
        "samples": len(response_times)
    }

def identify_api_bottlenecks(endpoint, response_metrics):
    """Identify bottlenecks in API endpoints"""
    
    bottlenecks = []
    
    # Profile API execution
    import cProfile
    import pstats
    from io import StringIO
    
    profiler = cProfile.Profile()
    profiler.enable()
    
    # Execute API endpoint
    make_api_request(endpoint)
    
    profiler.disable()
    
    # Analyze profile results
    stream = StringIO()
    stats = pstats.Stats(profiler, stream=stream)
    stats.sort_stats('cumulative')
    stats.print_stats(20)  # Top 20 time-consuming functions
    
    # Parse profiling results
    profile_output = stream.getvalue()
    
    # Identify slow operations
    if response_metrics["p95"] > 1000:  # Over 1 second
        bottlenecks.append({
            "type": "slow_response",
            "severity": "high",
            "details": "P95 response time exceeds 1 second",
            "profile": profile_output[:1000]  # First 1000 chars of profile
        })
    
    # Check for database bottlenecks
    if "frappe.db" in profile_output:
        bottlenecks.append({
            "type": "database_intensive",
            "severity": "medium",
            "details": "Significant time spent in database operations"
        })
    
    return bottlenecks
```

### 3. Frontend Performance Analysis
```python
def analyze_frontend_performance(site, pages=None):
    """Analyze frontend performance metrics"""
    
    frontend_analysis = {
        "pages": [],
        "bundle_sizes": {},
        "render_times": {},
        "resource_loading": {},
        "optimizations": []
    }
    
    # Get pages to analyze
    test_pages = pages or get_critical_pages(site)
    
    for page in test_pages:
        # Measure page load time
        load_metrics = measure_page_load_time(page)
        
        # Analyze bundle sizes
        bundle_analysis = analyze_bundle_sizes(page)
        
        # Check render performance
        render_metrics = measure_render_performance(page)
        
        # Analyze resource loading
        resource_analysis = analyze_resource_loading(page)
        
        frontend_analysis["pages"].append({
            "page": page,
            "load_time": load_metrics,
            "bundle_size": bundle_analysis,
            "render_metrics": render_metrics,
            "resources": resource_analysis,
            "optimization_suggestions": suggest_frontend_optimizations(
                load_metrics, bundle_analysis, render_metrics
            )
        })
    
    return frontend_analysis

def measure_page_load_time(page_url):
    """Measure page load time using browser automation"""
    
    from selenium import webdriver
    from selenium.webdriver.common.by import By
    from selenium.webdriver.support.ui import WebDriverWait
    from selenium.webdriver.support import expected_conditions as EC
    
    # Configure headless browser
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    
    driver = webdriver.Chrome(options=options)
    
    try:
        # Navigate to page
        start_time = time.time()
        driver.get(page_url)
        
        # Wait for page to be interactive
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.TAG_NAME, "body"))
        )
        
        # Get performance timing
        navigation_start = driver.execute_script("return window.performance.timing.navigationStart")
        dom_complete = driver.execute_script("return window.performance.timing.domComplete")
        load_event_end = driver.execute_script("return window.performance.timing.loadEventEnd")
        
        # Calculate metrics
        metrics = {
            "dom_complete": (dom_complete - navigation_start) / 1000,
            "load_complete": (load_event_end - navigation_start) / 1000,
            "time_to_interactive": time.time() - start_time,
            "first_contentful_paint": driver.execute_script(
                "return performance.getEntriesByType('paint')[0].startTime / 1000"
            ) if driver.execute_script("return performance.getEntriesByType('paint').length > 0") else None
        }
        
    finally:
        driver.quit()
    
    return metrics

def analyze_bundle_sizes(page):
    """Analyze JavaScript and CSS bundle sizes"""
    
    bundle_analysis = {
        "javascript": {},
        "css": {},
        "total_size": 0,
        "recommendations": []
    }
    
    # Get all JavaScript files
    js_files = get_page_javascript_files(page)
    
    for js_file in js_files:
        file_size = get_file_size(js_file)
        bundle_analysis["javascript"][js_file] = file_size
        bundle_analysis["total_size"] += file_size
        
        # Check if file is too large
        if file_size > 500 * 1024:  # 500KB
            bundle_analysis["recommendations"].append({
                "file": js_file,
                "issue": "Large bundle size",
                "suggestion": "Consider code splitting or lazy loading"
            })
    
    # Get all CSS files
    css_files = get_page_css_files(page)
    
    for css_file in css_files:
        file_size = get_file_size(css_file)
        bundle_analysis["css"][css_file] = file_size
        bundle_analysis["total_size"] += file_size
        
        # Check for unused CSS
        unused_css = detect_unused_css(css_file, page)
        if unused_css > 0.3:  # More than 30% unused
            bundle_analysis["recommendations"].append({
                "file": css_file,
                "issue": f"{unused_css * 100:.1f}% unused CSS",
                "suggestion": "Remove unused CSS or use PurgeCSS"
            })
    
    return bundle_analysis
```

### 4. Memory and Resource Analysis
```python
def analyze_resource_utilization(site):
    """Analyze system resource utilization"""
    
    resource_analysis = {
        "memory": {},
        "cpu": {},
        "disk_io": {},
        "network": {},
        "recommendations": []
    }
    
    # Memory analysis
    memory_stats = analyze_memory_usage(site)
    resource_analysis["memory"] = memory_stats
    
    # CPU analysis
    cpu_stats = analyze_cpu_usage(site)
    resource_analysis["cpu"] = cpu_stats
    
    # Disk I/O analysis
    disk_stats = analyze_disk_io(site)
    resource_analysis["disk_io"] = disk_stats
    
    # Network analysis
    network_stats = analyze_network_usage(site)
    resource_analysis["network"] = network_stats
    
    # Generate recommendations
    resource_analysis["recommendations"] = generate_resource_recommendations(
        memory_stats, cpu_stats, disk_stats, network_stats
    )
    
    return resource_analysis

def analyze_memory_usage(site):
    """Analyze memory usage patterns"""
    
    import psutil
    import gc
    
    memory_stats = {
        "current_usage": {},
        "memory_leaks": [],
        "large_objects": [],
        "cache_usage": {}
    }
    
    # Get current memory usage
    process = psutil.Process()
    memory_info = process.memory_info()
    
    memory_stats["current_usage"] = {
        "rss": memory_info.rss / (1024 * 1024),  # MB
        "vms": memory_info.vms / (1024 * 1024),  # MB
        "percent": process.memory_percent(),
        "available": psutil.virtual_memory().available / (1024 * 1024)  # MB
    }
    
    # Check for memory leaks
    gc.collect()
    objects = gc.get_objects()
    
    # Group objects by type
    type_counts = {}
    for obj in objects:
        obj_type = type(obj).__name__
        type_counts[obj_type] = type_counts.get(obj_type, 0) + 1
    
    # Find potential leaks (high object counts)
    for obj_type, count in type_counts.items():
        if count > 10000:  # Threshold for potential leak
            memory_stats["memory_leaks"].append({
                "type": obj_type,
                "count": count,
                "severity": "high" if count > 50000 else "medium"
            })
    
    # Find large objects
    for obj in objects:
        try:
            size = sys.getsizeof(obj)
            if size > 1024 * 1024:  # Objects larger than 1MB
                memory_stats["large_objects"].append({
                    "type": type(obj).__name__,
                    "size": size / (1024 * 1024),  # MB
                    "id": id(obj)
                })
        except:
            pass
    
    # Analyze cache usage
    cache_stats = analyze_cache_usage(site)
    memory_stats["cache_usage"] = cache_stats
    
    return memory_stats

def analyze_cache_usage(site):
    """Analyze cache performance and usage"""
    
    cache_stats = {
        "redis": {},
        "in_memory": {},
        "hit_rate": 0,
        "recommendations": []
    }
    
    # Redis cache stats
    redis_client = frappe.cache()
    redis_info = redis_client.info()
    
    cache_stats["redis"] = {
        "used_memory": redis_info.get("used_memory_human"),
        "hit_rate": calculate_hit_rate(redis_info),
        "evicted_keys": redis_info.get("evicted_keys", 0),
        "connected_clients": redis_info.get("connected_clients", 0)
    }
    
    # Check cache hit rate
    if cache_stats["redis"]["hit_rate"] < 0.8:  # Less than 80% hit rate
        cache_stats["recommendations"].append({
            "issue": "Low cache hit rate",
            "suggestion": "Review cache key strategy and TTL settings"
        })
    
    return cache_stats
```

### 5. Query Optimization
```python
def optimize_database_queries(analysis_results):
    """Generate and apply query optimizations"""
    
    optimizations = {
        "applied": [],
        "suggested": [],
        "performance_impact": {}
    }
    
    # Optimize slow queries
    for slow_query in analysis_results["slow_queries"]:
        optimization = optimize_single_query(slow_query)
        
        if optimization["can_auto_apply"]:
            apply_result = apply_query_optimization(optimization)
            optimizations["applied"].append(apply_result)
        else:
            optimizations["suggested"].append(optimization)
    
    # Add missing indexes
    for missing_index in analysis_results["missing_indexes"]:
        index_optimization = create_index_optimization(missing_index)
        
        if index_optimization["safe_to_apply"]:
            apply_result = apply_index_optimization(index_optimization)
            optimizations["applied"].append(apply_result)
        else:
            optimizations["suggested"].append(index_optimization)
    
    # Measure performance impact
    optimizations["performance_impact"] = measure_optimization_impact(
        optimizations["applied"]
    )
    
    return optimizations

def optimize_single_query(slow_query):
    """Optimize individual slow query"""
    
    optimization = {
        "original_query": slow_query["query"],
        "optimized_query": None,
        "optimization_type": [],
        "expected_improvement": 0,
        "can_auto_apply": False
    }
    
    # Parse query
    parsed_query = parse_sql_query(slow_query["query"])
    
    # Check for SELECT *
    if "SELECT *" in slow_query["query"]:
        optimization["optimization_type"].append("remove_select_star")
        optimization["optimized_query"] = replace_select_star(parsed_query)
        optimization["expected_improvement"] += 20
    
    # Check for missing WHERE clause on large table
    if not has_where_clause(parsed_query) and is_large_table(parsed_query["table"]):
        optimization["optimization_type"].append("add_limit")
        optimization["optimized_query"] = add_limit_clause(parsed_query, 1000)
        optimization["expected_improvement"] += 50
    
    # Check for OR conditions that can be UNION
    if has_or_conditions(parsed_query):
        optimization["optimization_type"].append("or_to_union")
        optimization["optimized_query"] = convert_or_to_union(parsed_query)
        optimization["expected_improvement"] += 30
    
    # Check for subqueries that can be JOINs
    if has_subqueries(parsed_query):
        optimization["optimization_type"].append("subquery_to_join")
        optimization["optimized_query"] = convert_subquery_to_join(parsed_query)
        optimization["expected_improvement"] += 40
    
    return optimization
```

### 6. Caching Strategy Analysis
```python
def analyze_caching_strategy(site):
    """Analyze and optimize caching strategy"""
    
    caching_analysis = {
        "current_strategy": {},
        "cache_effectiveness": {},
        "missed_opportunities": [],
        "recommendations": []
    }
    
    # Analyze current caching
    current_cache = analyze_current_caching(site)
    caching_analysis["current_strategy"] = current_cache
    
    # Measure cache effectiveness
    effectiveness = measure_cache_effectiveness(site)
    caching_analysis["cache_effectiveness"] = effectiveness
    
    # Find missed caching opportunities
    missed = find_caching_opportunities(site)
    caching_analysis["missed_opportunities"] = missed
    
    # Generate caching recommendations
    recommendations = generate_caching_recommendations(
        current_cache, effectiveness, missed
    )
    caching_analysis["recommendations"] = recommendations
    
    return caching_analysis

def find_caching_opportunities(site):
    """Find operations that could benefit from caching"""
    
    opportunities = []
    
    # Find frequently executed identical queries
    frequent_queries = find_frequent_queries(site)
    
    for query_pattern in frequent_queries:
        if not is_cached(query_pattern) and is_cacheable(query_pattern):
            opportunities.append({
                "type": "query_result",
                "pattern": query_pattern,
                "frequency": frequent_queries[query_pattern],
                "suggested_ttl": suggest_cache_ttl(query_pattern),
                "expected_benefit": calculate_caching_benefit(query_pattern)
            })
    
    # Find expensive computations
    expensive_operations = find_expensive_operations(site)
    
    for operation in expensive_operations:
        if not is_cached(operation) and is_deterministic(operation):
            opportunities.append({
                "type": "computation",
                "operation": operation,
                "cost": expensive_operations[operation],
                "suggested_strategy": "memoization",
                "expected_benefit": calculate_computation_caching_benefit(operation)
            })
    
    # Find static content without caching
    static_content = find_static_content_without_cache(site)
    
    for content in static_content:
        opportunities.append({
            "type": "static_content",
            "resource": content,
            "suggested_strategy": "browser_cache",
            "cache_control": suggest_cache_control_header(content)
        })
    
    return opportunities
```

### 7. Load Testing and Stress Analysis
```python
def perform_load_testing(site, scenarios=None):
    """Perform load testing to identify performance limits"""
    
    load_test_results = {
        "scenarios": [],
        "breaking_points": {},
        "bottlenecks": [],
        "recommendations": []
    }
    
    # Define test scenarios
    test_scenarios = scenarios or get_default_load_scenarios()
    
    for scenario in test_scenarios:
        scenario_result = run_load_scenario(site, scenario)
        load_test_results["scenarios"].append(scenario_result)
        
        # Identify breaking points
        if scenario_result["failed_at"]:
            load_test_results["breaking_points"][scenario["name"]] = {
                "concurrent_users": scenario_result["failed_at"]["users"],
                "requests_per_second": scenario_result["failed_at"]["rps"],
                "failure_reason": scenario_result["failure_reason"]
            }
    
    # Identify bottlenecks
    load_test_results["bottlenecks"] = identify_load_bottlenecks(load_test_results)
    
    # Generate recommendations
    load_test_results["recommendations"] = generate_load_test_recommendations(
        load_test_results
    )
    
    return load_test_results

def run_load_scenario(site, scenario):
    """Run single load testing scenario"""
    
    from locust import HttpUser, task, between
    import subprocess
    import json
    
    scenario_result = {
        "name": scenario["name"],
        "description": scenario["description"],
        "metrics": [],
        "failed_at": None,
        "max_successful_load": {}
    }
    
    # Progressive load increase
    user_counts = [10, 50, 100, 250, 500, 1000]
    
    for user_count in user_counts:
        # Run load test
        metrics = run_locust_test(
            site=site,
            users=user_count,
            spawn_rate=scenario["spawn_rate"],
            duration=scenario["duration"],
            tasks=scenario["tasks"]
        )
        
        scenario_result["metrics"].append({
            "users": user_count,
            "response_time_avg": metrics["response_time_avg"],
            "response_time_p95": metrics["response_time_p95"],
            "requests_per_second": metrics["rps"],
            "failure_rate": metrics["failure_rate"],
            "cpu_usage": metrics["cpu_usage"],
            "memory_usage": metrics["memory_usage"]
        })
        
        # Check if system failed
        if metrics["failure_rate"] > 0.01 or metrics["response_time_p95"] > 5000:
            scenario_result["failed_at"] = {
                "users": user_count,
                "rps": metrics["rps"]
            }
            scenario_result["failure_reason"] = determine_failure_reason(metrics)
            break
        else:
            scenario_result["max_successful_load"] = {
                "users": user_count,
                "rps": metrics["rps"]
            }
    
    return scenario_result
```

### 8. Performance Report Generation
```python
def generate_performance_report(analysis_results):
    """Generate comprehensive performance analysis report"""
    
    report = {
        "executive_summary": {},
        "detailed_findings": {},
        "optimization_plan": {},
        "expected_improvements": {},
        "implementation_priority": []
    }
    
    # Executive Summary
    report["executive_summary"] = create_executive_summary(analysis_results)
    
    # Detailed Findings
    report["detailed_findings"] = {
        "database_performance": format_database_findings(analysis_results["database"]),
        "api_performance": format_api_findings(analysis_results["api"]),
        "frontend_performance": format_frontend_findings(analysis_results["frontend"]),
        "resource_utilization": format_resource_findings(analysis_results["resources"]),
        "caching_analysis": format_caching_findings(analysis_results["caching"])
    }
    
    # Optimization Plan
    report["optimization_plan"] = create_optimization_plan(analysis_results)
    
    # Expected Improvements
    report["expected_improvements"] = calculate_expected_improvements(
        analysis_results,
        report["optimization_plan"]
    )
    
    # Implementation Priority
    report["implementation_priority"] = prioritize_optimizations(
        report["optimization_plan"],
        report["expected_improvements"]
    )
    
    # Generate visualizations
    report["visualizations"] = generate_performance_charts(analysis_results)
    
    return report

def create_executive_summary(analysis_results):
    """Create executive summary of performance analysis"""
    
    summary = {
        "overall_health": determine_overall_health(analysis_results),
        "critical_issues": [],
        "quick_wins": [],
        "long_term_improvements": [],
        "estimated_performance_gain": 0
    }
    
    # Identify critical issues
    for category, results in analysis_results.items():
        critical = find_critical_issues(results)
        summary["critical_issues"].extend(critical)
    
    # Identify quick wins
    for category, results in analysis_results.items():
        quick_wins = find_quick_wins(results)
        summary["quick_wins"].extend(quick_wins)
    
    # Calculate total estimated gain
    for optimization in summary["quick_wins"]:
        summary["estimated_performance_gain"] += optimization.get("expected_improvement", 0)
    
    return summary

def prioritize_optimizations(optimization_plan, expected_improvements):
    """Prioritize optimizations based on impact and effort"""
    
    prioritized = []
    
    for optimization in optimization_plan:
        # Calculate priority score
        impact = expected_improvements.get(optimization["id"], {}).get("impact", 0)
        effort = optimization.get("effort", 5)  # 1-10 scale
        risk = optimization.get("risk", 5)  # 1-10 scale
        
        # Priority formula: high impact, low effort, low risk = high priority
        priority_score = (impact * 10) / (effort * risk)
        
        prioritized.append({
            "optimization": optimization,
            "priority_score": priority_score,
            "impact": impact,
            "effort": effort,
            "risk": risk,
            "category": categorize_priority(priority_score)
        })
    
    # Sort by priority score
    prioritized.sort(key=lambda x: x["priority_score"], reverse=True)
    
    return prioritized

def categorize_priority(score):
    """Categorize priority based on score"""
    
    if score > 10:
        return "critical"
    elif score > 5:
        return "high"
    elif score > 2:
        return "medium"
    else:
        return "low"
```

### 9. Continuous Monitoring Setup
```python
def setup_continuous_monitoring(site, config=None):
    """Setup continuous performance monitoring"""
    
    monitoring_setup = {
        "monitors": [],
        "alerts": [],
        "dashboards": [],
        "automation": []
    }
    
    # Setup performance monitors
    monitors = [
        setup_response_time_monitor(site),
        setup_database_monitor(site),
        setup_resource_monitor(site),
        setup_error_rate_monitor(site),
        setup_cache_monitor(site)
    ]
    monitoring_setup["monitors"] = monitors
    
    # Configure alerts
    alerts = configure_performance_alerts(site, config)
    monitoring_setup["alerts"] = alerts
    
    # Create dashboards
    dashboards = create_performance_dashboards(site)
    monitoring_setup["dashboards"] = dashboards
    
    # Setup automation
    automation = setup_performance_automation(site, config)
    monitoring_setup["automation"] = automation
    
    return monitoring_setup

def configure_performance_alerts(site, config):
    """Configure performance alerting rules"""
    
    alerts = []
    
    # Response time alerts
    alerts.append({
        "name": "high_response_time",
        "condition": "avg_response_time > 2000",  # 2 seconds
        "severity": "warning",
        "notification": "email,slack",
        "cooldown": 300  # 5 minutes
    })
    
    # Error rate alerts
    alerts.append({
        "name": "high_error_rate",
        "condition": "error_rate > 0.05",  # 5% error rate
        "severity": "critical",
        "notification": "email,slack,pagerduty",
        "cooldown": 60  # 1 minute
    })
    
    # Resource alerts
    alerts.append({
        "name": "high_memory_usage",
        "condition": "memory_percent > 90",
        "severity": "warning",
        "notification": "email",
        "cooldown": 600  # 10 minutes
    })
    
    # Database alerts
    alerts.append({
        "name": "slow_queries",
        "condition": "slow_query_count > 10",
        "severity": "warning",
        "notification": "email",
        "cooldown": 1800  # 30 minutes
    })
    
    return alerts
```

## Best Practices
1. **Establish performance baselines first**
2. **Monitor continuously, not just during issues**
3. **Test with realistic data volumes**
4. **Profile before optimizing**
5. **Measure impact of each optimization**
6. **Consider trade-offs (memory vs speed)**
7. **Document performance requirements**
8. **Automate performance testing**
9. **Set up alerting for degradation**
10. **Regular performance reviews**

## Performance Targets
- API response time: < 200ms (p50), < 1s (p95)
- Page load time: < 2s
- Database queries: < 100ms
- Cache hit rate: > 80%
- Error rate: < 0.1%
- CPU usage: < 70% sustained
- Memory usage: < 80%

## Integration Points
- **DevOps Engineer**: Infrastructure optimization
- **Database Administrator**: Query optimization
- **Frontend Developer**: UI performance
- **System Administrator**: Resource management
- **Testing Specialist**: Load testing