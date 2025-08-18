# app-management

## Task Description
Manage Frappe/ERPNext application lifecycle including installation, updates, removal, and configuration.

## Parameters
- `operation`: Type of app operation (install, update, remove, etc.)
- `app_name`: Name of the application
- `site_name`: Target site for app operations
- `source`: Git repository URL or path for app source
- `branch`: Git branch to use (default: main/master)

## Prerequisites
- Bench environment configured
- Git access for app repositories
- Site exists for app installation
- Required permissions for app management

## Steps

### 1. App Installation
```python
def install_app(app_name, site_name=None, source=None, branch=None):
    """Install a Frappe app on site(s)"""
    
    # Step 1: Get app if not present
    if not app_exists_in_bench(app_name):
        if not source:
            frappe.throw(_("App source required for new installation"))
        
        get_app_result = get_app(app_name, source, branch)
        if not get_app_result["success"]:
            return get_app_result
    
    # Step 2: Install app on site
    if site_name:
        sites = [site_name]
    else:
        sites = get_all_sites()
    
    results = {}
    for site in sites:
        results[site] = install_app_on_site(app_name, site)
    
    return results

def get_app(app_name, source, branch=None):
    """Get app from repository"""
    
    command = ["bench", "get-app"]
    
    if branch:
        command.extend(["--branch", branch])
    
    command.extend([app_name, source])
    
    result = execute_command(command)
    
    if result["success"]:
        # Install Python dependencies
        install_app_requirements(app_name)
        
        # Build app assets
        build_app_assets(app_name)
    
    return result

def install_app_on_site(app_name, site_name):
    """Install app on specific site"""
    
    # Check if app already installed
    if is_app_installed(app_name, site_name):
        return {"status": "already_installed", "app": app_name, "site": site_name}
    
    # Check app dependencies
    missing_deps = check_app_dependencies(app_name, site_name)
    if missing_deps:
        return {"status": "error", "message": f"Missing dependencies: {missing_deps}"}
    
    # Install app
    command = ["bench", "--site", site_name, "install-app", app_name]
    result = execute_command(command)
    
    if result["success"]:
        # Run post-install hooks
        run_post_install_hooks(app_name, site_name)
        
        # Clear cache
        clear_site_cache(site_name)
    
    return result
```

### 2. App Updates
```python
def update_app(app_name, branch=None, sites=None, run_migrations=True):
    """Update app to latest version"""
    
    # Pull latest changes
    pull_result = pull_app_updates(app_name, branch)
    
    if not pull_result["success"]:
        return pull_result
    
    # Check for breaking changes
    breaking_changes = check_breaking_changes(app_name, pull_result["from_version"], pull_result["to_version"])
    
    if breaking_changes:
        handle_breaking_changes(breaking_changes)
    
    # Install new requirements
    install_app_requirements(app_name)
    
    # Build assets
    build_app_assets(app_name)
    
    # Run migrations on sites
    if run_migrations:
        if not sites:
            sites = get_sites_with_app(app_name)
        
        migration_results = {}
        for site in sites:
            migration_results[site] = migrate_site(site, app_name)
        
        return {
            "update_status": "success",
            "version": pull_result["to_version"],
            "migrations": migration_results
        }
    
    return pull_result

def pull_app_updates(app_name, branch=None):
    """Pull latest changes from git repository"""
    
    import subprocess
    import os
    
    app_path = get_app_path(app_name)
    
    # Store current version
    current_version = get_app_version(app_name)
    
    # Stash local changes if any
    subprocess.run(["git", "stash"], cwd=app_path)
    
    # Pull updates
    if branch:
        subprocess.run(["git", "checkout", branch], cwd=app_path)
    
    result = subprocess.run(["git", "pull"], cwd=app_path, capture_output=True, text=True)
    
    if result.returncode == 0:
        new_version = get_app_version(app_name)
        
        return {
            "success": True,
            "from_version": current_version,
            "to_version": new_version,
            "changes": get_git_log(app_path, current_version, new_version)
        }
    else:
        return {
            "success": False,
            "error": result.stderr
        }

def check_breaking_changes(app_name, from_version, to_version):
    """Check for breaking changes between versions"""
    
    breaking_changes = []
    
    # Check patches.txt for new patches
    new_patches = get_new_patches(app_name, from_version, to_version)
    if new_patches:
        breaking_changes.append({
            "type": "patches",
            "patches": new_patches
        })
    
    # Check for schema changes
    schema_changes = detect_schema_changes(app_name)
    if schema_changes:
        breaking_changes.append({
            "type": "schema",
            "changes": schema_changes
        })
    
    # Check for dependency changes
    dep_changes = check_dependency_changes(app_name)
    if dep_changes:
        breaking_changes.append({
            "type": "dependencies",
            "changes": dep_changes
        })
    
    return breaking_changes
```

### 3. App Removal
```python
def remove_app(app_name, sites=None, force=False):
    """Remove app from bench and sites"""
    
    # Get sites with app installed
    if not sites:
        sites = get_sites_with_app(app_name)
    
    # Uninstall from sites first
    uninstall_results = {}
    for site in sites:
        uninstall_results[site] = uninstall_app_from_site(app_name, site, force)
    
    # Check if any uninstall failed
    failed_sites = [s for s, r in uninstall_results.items() if not r.get("success")]
    
    if failed_sites and not force:
        return {
            "status": "error",
            "message": f"Failed to uninstall from sites: {failed_sites}",
            "results": uninstall_results
        }
    
    # Remove app from bench
    remove_result = remove_app_from_bench(app_name)
    
    return {
        "status": "success" if remove_result["success"] else "error",
        "uninstall_results": uninstall_results,
        "remove_result": remove_result
    }

def uninstall_app_from_site(app_name, site_name, force=False):
    """Uninstall app from specific site"""
    
    # Check if app is installed
    if not is_app_installed(app_name, site_name):
        return {"status": "not_installed", "app": app_name, "site": site_name}
    
    # Check for dependent apps
    dependent_apps = get_dependent_apps(app_name, site_name)
    if dependent_apps and not force:
        return {
            "status": "error",
            "message": f"Cannot uninstall. Dependent apps: {dependent_apps}"
        }
    
    # Backup before uninstall
    backup_site(site_name)
    
    # Uninstall app
    command = ["bench", "--site", site_name, "uninstall-app", app_name]
    
    if force:
        command.append("--force")
    
    result = execute_command(command)
    
    if result["success"]:
        # Clean up app data
        cleanup_app_data(app_name, site_name)
        
        # Clear cache
        clear_site_cache(site_name)
    
    return result

def remove_app_from_bench(app_name):
    """Remove app from bench"""
    
    command = ["bench", "remove-app", app_name]
    result = execute_command(command)
    
    if result["success"]:
        # Clean up app directory
        cleanup_app_directory(app_name)
    
    return result
```

### 4. App Configuration
```python
def configure_app(app_name, site_name, config):
    """Configure app settings for a site"""
    
    # Validate app is installed
    if not is_app_installed(app_name, site_name):
        frappe.throw(_("App {0} is not installed on site {1}").format(app_name, site_name))
    
    # Get app config handler
    config_handler = get_app_config_handler(app_name)
    
    # Validate configuration
    validation_result = config_handler.validate(config)
    if not validation_result["valid"]:
        return {
            "status": "error",
            "validation_errors": validation_result["errors"]
        }
    
    # Apply configuration
    apply_result = config_handler.apply(site_name, config)
    
    # Restart workers if needed
    if apply_result.get("restart_required"):
        restart_workers()
    
    return apply_result

def get_app_config(app_name, site_name):
    """Get current app configuration"""
    
    config_handler = get_app_config_handler(app_name)
    return config_handler.get_config(site_name)

def reset_app_config(app_name, site_name):
    """Reset app configuration to defaults"""
    
    config_handler = get_app_config_handler(app_name)
    default_config = config_handler.get_defaults()
    
    return configure_app(app_name, site_name, default_config)
```

### 5. App Dependencies Management
```python
def install_app_requirements(app_name):
    """Install Python requirements for app"""
    
    import subprocess
    import os
    
    app_path = get_app_path(app_name)
    requirements_file = os.path.join(app_path, "requirements.txt")
    
    if os.path.exists(requirements_file):
        command = ["pip", "install", "-r", requirements_file]
        result = subprocess.run(command, capture_output=True, text=True)
        
        if result.returncode != 0:
            frappe.throw(_("Failed to install requirements: {0}").format(result.stderr))
    
    return {"status": "requirements_installed"}

def check_app_dependencies(app_name, site_name):
    """Check if app dependencies are satisfied"""
    
    missing_deps = []
    
    # Check required apps
    required_apps = get_required_apps(app_name)
    installed_apps = get_installed_apps(site_name)
    
    for req_app in required_apps:
        if req_app not in installed_apps:
            missing_deps.append(req_app)
    
    # Check system dependencies
    system_deps = get_system_dependencies(app_name)
    for dep in system_deps:
        if not check_system_dependency(dep):
            missing_deps.append(f"system:{dep}")
    
    return missing_deps

def resolve_app_dependencies(app_name, site_name, auto_install=False):
    """Resolve app dependencies"""
    
    missing_deps = check_app_dependencies(app_name, site_name)
    
    if not missing_deps:
        return {"status": "all_dependencies_satisfied"}
    
    resolved = []
    failed = []
    
    for dep in missing_deps:
        if dep.startswith("system:"):
            # System dependency - needs manual installation
            failed.append(dep)
        else:
            # App dependency
            if auto_install:
                install_result = install_app(dep, site_name)
                if install_result.get("success"):
                    resolved.append(dep)
                else:
                    failed.append(dep)
            else:
                failed.append(dep)
    
    return {
        "resolved": resolved,
        "failed": failed,
        "status": "partial" if failed else "resolved"
    }
```

### 6. App Asset Management
```python
def build_app_assets(app_name=None, production=False):
    """Build frontend assets for app"""
    
    command = ["bench", "build"]
    
    if app_name:
        command.extend(["--app", app_name])
    
    if production:
        command.append("--production")
    
    result = execute_command(command)
    
    if result["success"]:
        # Clear browser cache
        clear_browser_cache()
        
        # Update asset version
        update_asset_version()
    
    return result

def watch_app_assets(app_name=None):
    """Watch and rebuild assets on change"""
    
    command = ["bench", "watch"]
    
    if app_name:
        command.extend(["--app", app_name])
    
    # Run in background
    return execute_command_background(command)

def optimize_app_assets(app_name):
    """Optimize app assets for production"""
    
    # Minify JavaScript
    minify_javascript(app_name)
    
    # Optimize images
    optimize_images(app_name)
    
    # Generate critical CSS
    generate_critical_css(app_name)
    
    # Create asset manifest
    create_asset_manifest(app_name)
    
    return {"status": "assets_optimized"}
```

### 7. App Version Management
```python
def get_app_version(app_name):
    """Get current app version"""
    
    import os
    
    app_path = get_app_path(app_name)
    
    # Try to get version from __version__.py
    version_file = os.path.join(app_path, app_name, "__version__.py")
    if os.path.exists(version_file):
        with open(version_file) as f:
            version_content = f.read()
            # Extract version string
            import re
            match = re.search(r'__version__\s*=\s*["\']([^"\']+)["\']', version_content)
            if match:
                return match.group(1)
    
    # Fall back to git tag
    import subprocess
    result = subprocess.run(
        ["git", "describe", "--tags", "--abbrev=0"],
        cwd=app_path,
        capture_output=True,
        text=True
    )
    
    if result.returncode == 0:
        return result.stdout.strip()
    
    return "unknown"

def switch_app_version(app_name, version):
    """Switch app to specific version"""
    
    import subprocess
    
    app_path = get_app_path(app_name)
    
    # Stash local changes
    subprocess.run(["git", "stash"], cwd=app_path)
    
    # Checkout version
    result = subprocess.run(
        ["git", "checkout", version],
        cwd=app_path,
        capture_output=True,
        text=True
    )
    
    if result.returncode == 0:
        # Install requirements for this version
        install_app_requirements(app_name)
        
        # Build assets
        build_app_assets(app_name)
        
        return {"status": "success", "version": version}
    else:
        return {"status": "error", "message": result.stderr}

def list_app_versions(app_name):
    """List available app versions"""
    
    import subprocess
    
    app_path = get_app_path(app_name)
    
    # Get tags
    result = subprocess.run(
        ["git", "tag", "-l"],
        cwd=app_path,
        capture_output=True,
        text=True
    )
    
    tags = result.stdout.strip().split('\n') if result.stdout else []
    
    # Get branches
    result = subprocess.run(
        ["git", "branch", "-r"],
        cwd=app_path,
        capture_output=True,
        text=True
    )
    
    branches = [b.strip() for b in result.stdout.strip().split('\n')] if result.stdout else []
    
    return {
        "tags": tags,
        "branches": branches,
        "current": get_app_version(app_name)
    }
```

### 8. App Health Monitoring
```python
def check_app_health(app_name, site_name=None):
    """Check app health status"""
    
    health_checks = {
        "installed": is_app_installed(app_name, site_name) if site_name else True,
        "version": get_app_version(app_name),
        "dependencies_satisfied": len(check_app_dependencies(app_name, site_name)) == 0 if site_name else True,
        "assets_built": check_assets_built(app_name),
        "migrations_pending": check_pending_migrations(app_name, site_name) if site_name else False,
        "errors_24h": get_app_error_count(app_name, hours=24),
        "custom_health_checks": run_custom_health_checks(app_name)
    }
    
    # Calculate health score
    health_score = calculate_app_health_score(health_checks)
    
    return {
        "app": app_name,
        "site": site_name,
        "health_score": health_score,
        "checks": health_checks,
        "status": "healthy" if health_score >= 80 else "unhealthy"
    }

def monitor_app_performance(app_name, site_name):
    """Monitor app performance metrics"""
    
    metrics = {
        "response_time": measure_app_response_time(app_name, site_name),
        "error_rate": calculate_error_rate(app_name, site_name),
        "throughput": measure_throughput(app_name, site_name),
        "resource_usage": get_app_resource_usage(app_name),
        "slow_queries": get_slow_queries(app_name, site_name),
        "background_job_success_rate": get_job_success_rate(app_name)
    }
    
    return metrics
```

### 9. App Development Tools
```python
def create_app_scaffold(app_name, app_title, app_description, app_publisher):
    """Create new app scaffold"""
    
    command = [
        "bench", "new-app",
        app_name,
        "--app-title", app_title,
        "--app-description", app_description,
        "--app-publisher", app_publisher
    ]
    
    result = execute_command(command)
    
    if result["success"]:
        # Initialize git repository
        initialize_git_repo(app_name)
        
        # Create initial structure
        create_app_structure(app_name)
        
        # Set up development tools
        setup_dev_tools(app_name)
    
    return result

def setup_app_development_environment(app_name):
    """Set up development environment for app"""
    
    # Install dev dependencies
    install_dev_dependencies(app_name)
    
    # Set up linting
    setup_linting(app_name)
    
    # Set up testing
    setup_testing_framework(app_name)
    
    # Set up pre-commit hooks
    setup_pre_commit_hooks(app_name)
    
    # Start file watcher
    watch_app_assets(app_name)
    
    return {"status": "development_environment_ready"}

def run_app_tests(app_name, site_name):
    """Run tests for app"""
    
    command = [
        "bench", "--site", site_name,
        "run-tests", "--app", app_name
    ]
    
    result = execute_command(command)
    
    # Parse test results
    test_results = parse_test_results(result["output"])
    
    return {
        "app": app_name,
        "site": site_name,
        "tests_run": test_results["total"],
        "tests_passed": test_results["passed"],
        "tests_failed": test_results["failed"],
        "coverage": test_results.get("coverage"),
        "details": test_results
    }
```

### 10. App Migration Tools
```python
def migrate_app_to_new_version(app_name, target_version, sites=None):
    """Migrate app to new version across sites"""
    
    # Create migration plan
    migration_plan = create_migration_plan(app_name, target_version)
    
    # Backup all affected sites
    for site in sites or get_sites_with_app(app_name):
        backup_site(site)
    
    # Execute migration steps
    results = {}
    
    for step in migration_plan["steps"]:
        if step["type"] == "update_code":
            results["code_update"] = switch_app_version(app_name, target_version)
        
        elif step["type"] == "run_patches":
            for site in sites or get_sites_with_app(app_name):
                results[f"patches_{site}"] = run_patches(app_name, site, step["patches"])
        
        elif step["type"] == "migrate_schema":
            for site in sites or get_sites_with_app(app_name):
                results[f"schema_{site}"] = migrate_site(site, app_name)
        
        elif step["type"] == "rebuild_assets":
            results["assets"] = build_app_assets(app_name, production=True)
    
    return {
        "migration_completed": True,
        "target_version": target_version,
        "results": results
    }

def rollback_app_migration(app_name, sites=None):
    """Rollback app migration if failed"""
    
    # Get rollback point
    rollback_version = get_rollback_version(app_name)
    
    # Switch to rollback version
    switch_app_version(app_name, rollback_version)
    
    # Restore sites from backup
    for site in sites or get_sites_with_app(app_name):
        restore_from_latest_backup(site)
    
    return {"status": "rolled_back", "version": rollback_version}
```

## Best Practices
1. **Always backup before app operations**
2. **Test app updates in staging first**
3. **Check dependencies before installation**
4. **Monitor app health after updates**
5. **Document custom app configurations**
6. **Use version control for custom apps**
7. **Run tests before production deployment**
8. **Keep apps updated for security**

## Integration Points
- **Bench Operator**: Primary agent using this task
- **Developer**: App development and testing
- **System Administrator**: App monitoring and maintenance
- **DevOps**: Automated app deployment