# multi-app-deployment

## Task Description
Deploy and manage multiple interconnected Frappe/ERPNext applications across sites with dependency management and orchestration.

## Parameters
- `deployment_config`: Configuration defining apps, dependencies, and deployment order
- `target_sites`: List of sites for deployment
- `deployment_strategy`: rolling, blue-green, or all-at-once
- `rollback_on_failure`: Automatically rollback if deployment fails (default: true)

## Prerequisites
- All app repositories accessible
- Target sites configured and accessible
- Dependency resolution completed
- Backup strategy in place

## Steps

### 1. Deployment Planning
```python
def create_deployment_plan(apps, sites, dependencies=None):
    """Create comprehensive deployment plan for multiple apps"""
    
    # Analyze app dependencies
    dependency_graph = build_dependency_graph(apps, dependencies)
    
    # Determine deployment order
    deployment_order = topological_sort(dependency_graph)
    
    # Check for circular dependencies
    if has_circular_dependencies(dependency_graph):
        frappe.throw(_("Circular dependencies detected in apps"))
    
    # Create deployment stages
    deployment_stages = []
    
    for level in deployment_order:
        stage = {
            "level": len(deployment_stages) + 1,
            "apps": level,
            "parallel": can_deploy_parallel(level),
            "sites": sites,
            "pre_checks": generate_pre_checks(level),
            "post_checks": generate_post_checks(level)
        }
        deployment_stages.append(stage)
    
    return {
        "deployment_id": generate_deployment_id(),
        "timestamp": frappe.utils.now(),
        "apps": apps,
        "sites": sites,
        "stages": deployment_stages,
        "estimated_duration": estimate_deployment_duration(deployment_stages),
        "rollback_plan": create_rollback_plan(deployment_stages)
    }

def build_dependency_graph(apps, explicit_dependencies=None):
    """Build dependency graph for apps"""
    
    graph = {}
    
    for app in apps:
        # Get app dependencies from hooks.py
        app_deps = get_app_dependencies(app["name"])
        
        # Add explicit dependencies
        if explicit_dependencies and app["name"] in explicit_dependencies:
            app_deps.extend(explicit_dependencies[app["name"]])
        
        graph[app["name"]] = {
            "depends_on": app_deps,
            "version": app.get("version", "latest"),
            "source": app.get("source"),
            "config": app.get("config", {})
        }
    
    return graph
```

### 2. Pre-Deployment Validation
```python
def validate_deployment(deployment_plan):
    """Validate deployment plan before execution"""
    
    validation_results = {
        "passed": [],
        "failed": [],
        "warnings": []
    }
    
    # Check site availability
    for site in deployment_plan["sites"]:
        if not check_site_health(site):
            validation_results["failed"].append(f"Site {site} health check failed")
        else:
            validation_results["passed"].append(f"Site {site} is healthy")
    
    # Check app sources
    for stage in deployment_plan["stages"]:
        for app in stage["apps"]:
            if not validate_app_source(app):
                validation_results["failed"].append(f"App {app} source validation failed")
            else:
                validation_results["passed"].append(f"App {app} source valid")
    
    # Check disk space
    required_space = calculate_required_space(deployment_plan)
    available_space = get_available_disk_space()
    
    if available_space < required_space * 1.5:  # 50% buffer
        validation_results["failed"].append(f"Insufficient disk space. Required: {required_space}GB")
    
    # Check database connectivity
    for site in deployment_plan["sites"]:
        if not test_database_connection(site):
            validation_results["failed"].append(f"Database connection failed for {site}")
    
    # Check for running migrations
    for site in deployment_plan["sites"]:
        if has_running_migrations(site):
            validation_results["warnings"].append(f"Site {site} has running migrations")
    
    return {
        "valid": len(validation_results["failed"]) == 0,
        "results": validation_results
    }
```

### 3. Multi-App Installation
```python
def deploy_apps_to_sites(deployment_plan, strategy="rolling"):
    """Deploy multiple apps to multiple sites"""
    
    deployment_log = {
        "deployment_id": deployment_plan["deployment_id"],
        "start_time": frappe.utils.now(),
        "stages": [],
        "status": "in_progress"
    }
    
    try:
        # Execute deployment stages
        for stage in deployment_plan["stages"]:
            stage_result = execute_deployment_stage(stage, strategy)
            deployment_log["stages"].append(stage_result)
            
            if stage_result["status"] == "failed":
                if deployment_plan.get("rollback_on_failure", True):
                    rollback_deployment(deployment_log)
                    deployment_log["status"] = "rolled_back"
                else:
                    deployment_log["status"] = "failed"
                break
        else:
            deployment_log["status"] = "completed"
        
        deployment_log["end_time"] = frappe.utils.now()
        
    except Exception as e:
        deployment_log["status"] = "error"
        deployment_log["error"] = str(e)
        
        if deployment_plan.get("rollback_on_failure", True):
            rollback_deployment(deployment_log)
            deployment_log["status"] = "rolled_back"
    
    finally:
        # Save deployment log
        save_deployment_log(deployment_log)
    
    return deployment_log

def execute_deployment_stage(stage, strategy):
    """Execute single deployment stage"""
    
    stage_result = {
        "stage_level": stage["level"],
        "apps": stage["apps"],
        "start_time": frappe.utils.now(),
        "site_results": {}
    }
    
    # Run pre-checks
    pre_check_results = run_stage_pre_checks(stage)
    if not pre_check_results["passed"]:
        stage_result["status"] = "failed"
        stage_result["pre_check_failures"] = pre_check_results["failures"]
        return stage_result
    
    # Deploy based on strategy
    if strategy == "rolling":
        deployment_results = rolling_deployment(stage)
    elif strategy == "blue-green":
        deployment_results = blue_green_deployment(stage)
    else:  # all-at-once
        deployment_results = parallel_deployment(stage)
    
    stage_result["site_results"] = deployment_results
    
    # Run post-checks
    post_check_results = run_stage_post_checks(stage)
    stage_result["post_checks"] = post_check_results
    
    # Determine overall status
    failed_sites = [s for s, r in deployment_results.items() if r["status"] == "failed"]
    stage_result["status"] = "failed" if failed_sites else "completed"
    
    stage_result["end_time"] = frappe.utils.now()
    
    return stage_result
```

### 4. Deployment Strategies

#### Rolling Deployment
```python
def rolling_deployment(stage, batch_size=1, wait_time=30):
    """Deploy apps to sites one at a time or in small batches"""
    
    results = {}
    sites = stage["sites"]
    
    for i in range(0, len(sites), batch_size):
        batch = sites[i:i + batch_size]
        
        # Deploy to batch
        for site in batch:
            results[site] = deploy_apps_to_site(stage["apps"], site)
            
            # Health check after deployment
            if not wait_and_verify_site(site, wait_time):
                results[site]["status"] = "failed"
                results[site]["reason"] = "Post-deployment health check failed"
                
                # Stop rolling deployment on failure
                return results
        
        # Wait between batches
        if i + batch_size < len(sites):
            time.sleep(wait_time)
    
    return results

def deploy_apps_to_site(apps, site):
    """Deploy multiple apps to single site"""
    
    site_result = {
        "site": site,
        "apps_deployed": [],
        "apps_failed": [],
        "start_time": frappe.utils.now()
    }
    
    # Set maintenance mode
    set_maintenance_mode(site, True)
    
    try:
        # Backup site before deployment
        backup_result = backup_site(site)
        site_result["backup"] = backup_result
        
        # Deploy each app
        for app in apps:
            app_result = deploy_single_app(app, site)
            
            if app_result["success"]:
                site_result["apps_deployed"].append(app)
            else:
                site_result["apps_failed"].append({
                    "app": app,
                    "error": app_result.get("error")
                })
                
                # Stop on first failure
                break
        
        # Run migrations if all apps deployed
        if not site_result["apps_failed"]:
            migration_result = migrate_site(site)
            site_result["migration"] = migration_result
            
            if migration_result["success"]:
                site_result["status"] = "completed"
            else:
                site_result["status"] = "failed"
                site_result["reason"] = "Migration failed"
        else:
            site_result["status"] = "failed"
            site_result["reason"] = "App deployment failed"
    
    except Exception as e:
        site_result["status"] = "error"
        site_result["error"] = str(e)
    
    finally:
        # Turn off maintenance mode
        set_maintenance_mode(site, False)
        site_result["end_time"] = frappe.utils.now()
    
    return site_result
```

#### Blue-Green Deployment
```python
def blue_green_deployment(stage):
    """Deploy to green environment, then switch traffic"""
    
    results = {
        "strategy": "blue-green",
        "blue_environment": [],
        "green_environment": [],
        "switch_time": None
    }
    
    # Identify blue (current) and green (new) environments
    blue_sites = stage["sites"]
    green_sites = create_green_environment(blue_sites)
    
    results["blue_environment"] = blue_sites
    results["green_environment"] = green_sites
    
    # Deploy to green environment
    green_deployment = {}
    for site in green_sites:
        green_deployment[site] = deploy_apps_to_site(stage["apps"], site)
    
    results["green_deployment"] = green_deployment
    
    # Validate green environment
    green_validation = validate_green_environment(green_sites, stage["apps"])
    
    if green_validation["passed"]:
        # Switch traffic to green
        switch_result = switch_traffic_to_green(blue_sites, green_sites)
        results["switch_time"] = frappe.utils.now()
        results["switch_result"] = switch_result
        results["status"] = "completed"
        
        # Keep blue environment for rollback
        results["blue_retained"] = True
    else:
        # Deployment failed, stay on blue
        results["status"] = "failed"
        results["validation_failures"] = green_validation["failures"]
        
        # Clean up green environment
        cleanup_green_environment(green_sites)
    
    return results

def create_green_environment(blue_sites):
    """Create parallel green environment"""
    
    green_sites = []
    
    for blue_site in blue_sites:
        # Create green site name
        green_site = f"{blue_site}_green_{frappe.utils.now_datetime().strftime('%Y%m%d_%H%M%S')}"
        
        # Clone blue site to green
        clone_site(blue_site, green_site)
        green_sites.append(green_site)
    
    return green_sites

def switch_traffic_to_green(blue_sites, green_sites):
    """Switch traffic from blue to green environment"""
    
    switch_results = []
    
    for blue_site, green_site in zip(blue_sites, green_sites):
        # Update nginx/proxy configuration
        update_proxy_config(blue_site, green_site)
        
        # Update DNS if needed
        update_dns_records(blue_site, green_site)
        
        # Verify traffic switch
        verify_result = verify_traffic_switch(green_site)
        
        switch_results.append({
            "blue": blue_site,
            "green": green_site,
            "switched": verify_result["success"]
        })
    
    return switch_results
```

### 5. Dependency Management
```python
def resolve_app_dependencies_for_deployment(apps):
    """Resolve all app dependencies before deployment"""
    
    resolution = {
        "resolved": [],
        "missing": [],
        "conflicts": []
    }
    
    # Build complete dependency tree
    dependency_tree = {}
    
    for app in apps:
        app_deps = get_app_dependencies_recursive(app)
        dependency_tree[app] = app_deps
    
    # Check for version conflicts
    version_conflicts = check_version_conflicts(dependency_tree)
    if version_conflicts:
        resolution["conflicts"] = version_conflicts
        return resolution
    
    # Resolve dependencies in order
    resolved_order = []
    unresolved = set(dependency_tree.keys())
    
    while unresolved:
        # Find apps with all dependencies resolved
        ready = []
        for app in unresolved:
            deps = dependency_tree[app]
            if all(d in resolved_order for d in deps):
                ready.append(app)
        
        if not ready:
            # Circular dependency or missing dependency
            resolution["missing"] = list(unresolved)
            break
        
        resolved_order.extend(ready)
        unresolved -= set(ready)
    
    resolution["resolved"] = resolved_order
    
    return resolution

def get_app_dependencies_recursive(app, visited=None):
    """Get all dependencies recursively"""
    
    if visited is None:
        visited = set()
    
    if app in visited:
        return []
    
    visited.add(app)
    
    direct_deps = get_app_dependencies(app)
    all_deps = direct_deps.copy()
    
    for dep in direct_deps:
        sub_deps = get_app_dependencies_recursive(dep, visited)
        all_deps.extend(sub_deps)
    
    return list(set(all_deps))
```

### 6. Orchestration and Coordination
```python
def orchestrate_complex_deployment(deployment_config):
    """Orchestrate complex multi-app, multi-site deployment"""
    
    orchestration = {
        "id": generate_orchestration_id(),
        "config": deployment_config,
        "phases": [],
        "status": "planning"
    }
    
    # Phase 1: Preparation
    preparation_phase = {
        "name": "preparation",
        "tasks": [
            validate_deployment_config(deployment_config),
            check_resource_availability(deployment_config),
            create_deployment_backups(deployment_config),
            notify_stakeholders("deployment_starting", deployment_config)
        ]
    }
    orchestration["phases"].append(preparation_phase)
    
    # Phase 2: Dependency Resolution
    dependency_phase = {
        "name": "dependency_resolution",
        "tasks": [
            resolve_app_dependencies_for_deployment(deployment_config["apps"]),
            download_required_apps(deployment_config["apps"]),
            verify_app_compatibility(deployment_config["apps"])
        ]
    }
    orchestration["phases"].append(dependency_phase)
    
    # Phase 3: Deployment Execution
    deployment_phase = {
        "name": "deployment",
        "tasks": []
    }
    
    # Create deployment plan
    deployment_plan = create_deployment_plan(
        deployment_config["apps"],
        deployment_config["sites"],
        deployment_config.get("dependencies")
    )
    
    # Execute deployment with monitoring
    deployment_task = execute_monitored_deployment(deployment_plan)
    deployment_phase["tasks"].append(deployment_task)
    
    orchestration["phases"].append(deployment_phase)
    
    # Phase 4: Validation
    validation_phase = {
        "name": "validation",
        "tasks": [
            run_deployment_tests(deployment_config),
            verify_app_functionality(deployment_config),
            check_integration_points(deployment_config)
        ]
    }
    orchestration["phases"].append(validation_phase)
    
    # Phase 5: Finalization
    finalization_phase = {
        "name": "finalization",
        "tasks": [
            update_documentation(deployment_config),
            notify_stakeholders("deployment_completed", deployment_config),
            cleanup_temporary_resources(deployment_config)
        ]
    }
    orchestration["phases"].append(finalization_phase)
    
    # Execute orchestration
    return execute_orchestration(orchestration)

def execute_monitored_deployment(deployment_plan):
    """Execute deployment with real-time monitoring"""
    
    monitoring = {
        "deployment_id": deployment_plan["deployment_id"],
        "metrics": {},
        "alerts": [],
        "status_updates": []
    }
    
    # Start monitoring thread
    monitor_thread = start_deployment_monitoring(deployment_plan, monitoring)
    
    try:
        # Execute deployment
        result = deploy_apps_to_sites(deployment_plan)
        
        # Collect final metrics
        monitoring["metrics"]["final"] = collect_deployment_metrics(result)
        
    except Exception as e:
        monitoring["alerts"].append({
            "level": "critical",
            "message": str(e),
            "timestamp": frappe.utils.now()
        })
        raise
    
    finally:
        # Stop monitoring
        stop_deployment_monitoring(monitor_thread)
    
    return {
        "deployment_result": result,
        "monitoring": monitoring
    }
```

### 7. Rollback Procedures
```python
def rollback_deployment(deployment_log):
    """Rollback failed deployment"""
    
    rollback_log = {
        "deployment_id": deployment_log["deployment_id"],
        "rollback_id": generate_rollback_id(),
        "start_time": frappe.utils.now(),
        "stages": []
    }
    
    # Rollback in reverse order
    for stage in reversed(deployment_log["stages"]):
        if stage["status"] in ["completed", "failed"]:
            stage_rollback = rollback_deployment_stage(stage)
            rollback_log["stages"].append(stage_rollback)
    
    rollback_log["end_time"] = frappe.utils.now()
    rollback_log["status"] = "completed"
    
    # Save rollback log
    save_rollback_log(rollback_log)
    
    return rollback_log

def rollback_deployment_stage(stage):
    """Rollback single deployment stage"""
    
    rollback_result = {
        "stage_level": stage["stage_level"],
        "rollback_actions": []
    }
    
    for site, site_result in stage["site_results"].items():
        if site_result["status"] in ["completed", "failed"]:
            # Restore from backup
            if "backup" in site_result:
                restore_result = restore_site_from_backup(
                    site,
                    site_result["backup"]
                )
                rollback_result["rollback_actions"].append({
                    "site": site,
                    "action": "restore_from_backup",
                    "result": restore_result
                })
            
            # Uninstall deployed apps
            for app in site_result.get("apps_deployed", []):
                uninstall_result = uninstall_app_from_site(app, site, force=True)
                rollback_result["rollback_actions"].append({
                    "site": site,
                    "action": f"uninstall_app_{app}",
                    "result": uninstall_result
                })
    
    rollback_result["status"] = "completed"
    
    return rollback_result
```

### 8. Monitoring and Reporting
```python
def monitor_deployment_progress(deployment_id):
    """Monitor ongoing deployment progress"""
    
    deployment_status = get_deployment_status(deployment_id)
    
    monitoring_data = {
        "deployment_id": deployment_id,
        "current_stage": deployment_status.get("current_stage"),
        "progress_percentage": calculate_progress_percentage(deployment_status),
        "sites_completed": deployment_status.get("sites_completed", []),
        "sites_pending": deployment_status.get("sites_pending", []),
        "sites_failed": deployment_status.get("sites_failed", []),
        "estimated_completion": estimate_completion_time(deployment_status),
        "active_tasks": get_active_deployment_tasks(deployment_id),
        "recent_logs": get_recent_deployment_logs(deployment_id, limit=50)
    }
    
    # Check for issues
    issues = detect_deployment_issues(deployment_status)
    if issues:
        monitoring_data["issues"] = issues
        monitoring_data["recommended_actions"] = get_recommended_actions(issues)
    
    return monitoring_data

def generate_deployment_report(deployment_id):
    """Generate comprehensive deployment report"""
    
    deployment_log = get_deployment_log(deployment_id)
    
    report = {
        "deployment_id": deployment_id,
        "summary": {
            "start_time": deployment_log["start_time"],
            "end_time": deployment_log["end_time"],
            "duration": calculate_duration(deployment_log),
            "status": deployment_log["status"],
            "apps_deployed": count_deployed_apps(deployment_log),
            "sites_affected": count_affected_sites(deployment_log),
            "success_rate": calculate_success_rate(deployment_log)
        },
        "details": {
            "stages": analyze_stages(deployment_log["stages"]),
            "app_metrics": collect_app_metrics(deployment_log),
            "site_metrics": collect_site_metrics(deployment_log),
            "error_analysis": analyze_errors(deployment_log)
        },
        "performance": {
            "deployment_speed": calculate_deployment_speed(deployment_log),
            "bottlenecks": identify_bottlenecks(deployment_log),
            "optimization_suggestions": get_optimization_suggestions(deployment_log)
        },
        "recommendations": generate_recommendations(deployment_log)
    }
    
    return report
```

### 9. Configuration Management
```python
def validate_deployment_config(config):
    """Validate deployment configuration"""
    
    required_fields = ["apps", "sites", "strategy"]
    
    # Check required fields
    for field in required_fields:
        if field not in config:
            frappe.throw(_("Missing required field: {0}").format(field))
    
    # Validate apps configuration
    for app in config["apps"]:
        if not app.get("name"):
            frappe.throw(_("App name is required"))
        
        if app.get("source") and not validate_git_url(app["source"]):
            frappe.throw(_("Invalid git URL for app {0}").format(app["name"]))
    
    # Validate sites
    for site in config["sites"]:
        if not site_exists(site):
            frappe.throw(_("Site {0} does not exist").format(site))
    
    # Validate strategy
    valid_strategies = ["rolling", "blue-green", "all-at-once"]
    if config["strategy"] not in valid_strategies:
        frappe.throw(_("Invalid deployment strategy. Must be one of: {0}").format(", ".join(valid_strategies)))
    
    return {"valid": True}

# Sample deployment configuration
sample_deployment_config = {
    "apps": [
        {
            "name": "frappe",
            "version": "v16.0.0",
            "source": "https://github.com/frappe/frappe"
        },
        {
            "name": "erpnext",
            "version": "v16.0.0",
            "source": "https://github.com/frappe/erpnext"
        },
        {
            "name": "custom_app",
            "version": "v1.0.0",
            "source": "https://github.com/company/custom_app",
            "config": {
                "enable_feature_x": true,
                "api_key": "xxx"
            }
        }
    ],
    "sites": ["site1.local", "site2.local", "site3.local"],
    "strategy": "rolling",
    "options": {
        "batch_size": 1,
        "wait_time": 60,
        "rollback_on_failure": true,
        "backup_before_deployment": true,
        "run_tests": true,
        "notify_users": true
    },
    "dependencies": {
        "custom_app": ["erpnext"],
        "erpnext": ["frappe"]
    }
}
```

### 10. Health Checks and Validation
```python
def run_post_deployment_validation(deployment_log):
    """Run comprehensive validation after deployment"""
    
    validation_results = {
        "deployment_id": deployment_log["deployment_id"],
        "timestamp": frappe.utils.now(),
        "checks": []
    }
    
    # For each deployed site
    for stage in deployment_log["stages"]:
        for site, site_result in stage.get("site_results", {}).items():
            if site_result["status"] == "completed":
                site_validation = validate_deployed_site(site, site_result["apps_deployed"])
                validation_results["checks"].append(site_validation)
    
    # Aggregate results
    validation_results["summary"] = {
        "total_checks": len(validation_results["checks"]),
        "passed": sum(1 for c in validation_results["checks"] if c["passed"]),
        "failed": sum(1 for c in validation_results["checks"] if not c["passed"]),
        "overall_status": "passed" if all(c["passed"] for c in validation_results["checks"]) else "failed"
    }
    
    return validation_results

def validate_deployed_site(site, deployed_apps):
    """Validate single site after deployment"""
    
    validation = {
        "site": site,
        "apps": deployed_apps,
        "checks": {},
        "passed": True
    }
    
    # Check site accessibility
    validation["checks"]["accessible"] = check_site_accessible(site)
    
    # Check app installation
    for app in deployed_apps:
        validation["checks"][f"app_{app}_installed"] = is_app_installed(app, site)
    
    # Check database integrity
    validation["checks"]["database_integrity"] = check_database_integrity(site)
    
    # Check scheduled jobs
    validation["checks"]["scheduled_jobs"] = check_scheduled_jobs_running(site)
    
    # Check error logs
    validation["checks"]["no_critical_errors"] = check_no_critical_errors(site, hours=1)
    
    # Run app-specific health checks
    for app in deployed_apps:
        app_health = check_app_health(app, site)
        validation["checks"][f"app_{app}_health"] = app_health["status"] == "healthy"
    
    # Determine overall status
    validation["passed"] = all(validation["checks"].values())
    
    return validation
```

## Best Practices
1. **Always create deployment plan before execution**
2. **Validate all dependencies upfront**
3. **Use appropriate deployment strategy for your needs**
4. **Monitor deployment progress in real-time**
5. **Have rollback plan ready**
6. **Test deployments in staging first**
7. **Document deployment configurations**
8. **Keep deployment logs for audit**
9. **Notify stakeholders of deployment status**
10. **Run validation after deployment**

## Integration Points
- **Bench Operator**: Primary agent for execution
- **DevOps Engineer**: Deployment orchestration
- **System Administrator**: Environment preparation
- **Testing Specialist**: Post-deployment validation
- **Main Dev Coordinator**: Multi-team coordination