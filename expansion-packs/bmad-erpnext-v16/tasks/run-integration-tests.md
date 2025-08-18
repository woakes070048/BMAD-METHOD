# run-integration-tests

## Task Description
Execute comprehensive integration tests for ERPNext applications to verify multi-component functionality and system interactions.

## Parameters
- `test_suite`: Name of integration test suite to run
- `test_scope`: full, smoke, regression, or custom
- `apps`: List of apps to test integration between
- `site`: Target site for testing
- `parallel`: Run tests in parallel (default: false)
- `coverage`: Generate coverage report (default: true)

## Prerequisites
- Test environment configured
- Test data prepared
- All apps installed and configured
- Test dependencies available

## Steps

### 1. Test Environment Setup
```python
def setup_integration_test_environment(site, apps, test_data=None):
    """Setup isolated test environment for integration testing"""
    
    test_env = {
        "site": site,
        "apps": apps,
        "test_id": generate_test_id(),
        "timestamp": frappe.utils.now(),
        "original_state": {}
    }
    
    # Backup current state
    test_env["original_state"] = capture_site_state(site)
    
    # Set test mode
    set_test_mode(site, True)
    
    # Load test fixtures
    if test_data:
        load_test_fixtures(site, test_data)
    else:
        load_default_test_fixtures(site, apps)
    
    # Configure test settings
    configure_test_settings(site, {
        "disable_emails": True,
        "disable_scheduler": True,
        "enable_test_mode": True,
        "log_level": "DEBUG"
    })
    
    # Initialize test database
    initialize_test_database(site)
    
    # Warm up caches
    warm_up_test_caches(site, apps)
    
    return test_env

def capture_site_state(site):
    """Capture current site state for restoration"""
    
    state = {
        "config": get_site_config(site),
        "database_snapshot": create_database_snapshot(site),
        "file_system_snapshot": create_file_system_snapshot(site),
        "cache_state": capture_cache_state(site)
    }
    
    return state

def load_test_fixtures(site, test_data):
    """Load test data fixtures"""
    
    fixtures_loaded = []
    
    for fixture in test_data:
        if fixture["type"] == "json":
            load_json_fixtures(site, fixture["path"])
        elif fixture["type"] == "sql":
            load_sql_fixtures(site, fixture["path"])
        elif fixture["type"] == "csv":
            load_csv_fixtures(site, fixture["path"])
        elif fixture["type"] == "factory":
            load_factory_fixtures(site, fixture["factory"])
        
        fixtures_loaded.append(fixture)
    
    return fixtures_loaded
```

### 2. Integration Test Execution
```python
def run_integration_test_suite(test_suite, test_env, options=None):
    """Run complete integration test suite"""
    
    test_run = {
        "suite": test_suite,
        "test_env": test_env,
        "start_time": frappe.utils.now(),
        "tests": [],
        "results": {
            "passed": 0,
            "failed": 0,
            "skipped": 0,
            "errors": 0
        }
    }
    
    # Load test suite configuration
    suite_config = load_test_suite_config(test_suite)
    
    # Discover tests
    tests = discover_integration_tests(suite_config, test_env["apps"])
    
    # Execute tests based on scope
    if options and options.get("parallel"):
        test_results = run_tests_parallel(tests, test_env)
    else:
        test_results = run_tests_sequential(tests, test_env)
    
    # Process results
    for result in test_results:
        test_run["tests"].append(result)
        test_run["results"][result["status"]] += 1
    
    test_run["end_time"] = frappe.utils.now()
    test_run["duration"] = calculate_duration(test_run)
    
    # Generate coverage report if requested
    if options and options.get("coverage"):
        test_run["coverage"] = generate_coverage_report(test_run)
    
    return test_run

def discover_integration_tests(suite_config, apps):
    """Discover all integration tests"""
    
    tests = []
    
    # Discover app-to-app integration tests
    for app in apps:
        app_tests = discover_app_integration_tests(app)
        tests.extend(app_tests)
    
    # Discover cross-app integration tests
    cross_app_tests = discover_cross_app_tests(apps)
    tests.extend(cross_app_tests)
    
    # Discover API integration tests
    api_tests = discover_api_integration_tests(apps)
    tests.extend(api_tests)
    
    # Discover workflow integration tests
    workflow_tests = discover_workflow_integration_tests(apps)
    tests.extend(workflow_tests)
    
    # Filter based on suite configuration
    if suite_config.get("include_patterns"):
        tests = filter_tests_by_pattern(tests, suite_config["include_patterns"])
    
    if suite_config.get("exclude_patterns"):
        tests = exclude_tests_by_pattern(tests, suite_config["exclude_patterns"])
    
    return tests
```

### 3. Test Categories

#### API Integration Tests
```python
def run_api_integration_tests(apps, test_env):
    """Test API endpoints across multiple apps"""
    
    api_tests = []
    
    # Test inter-app API calls
    for source_app in apps:
        for target_app in apps:
            if source_app != target_app:
                test = test_app_to_app_api_integration(source_app, target_app, test_env)
                api_tests.append(test)
    
    # Test API authentication flow
    auth_test = test_api_authentication_flow(apps, test_env)
    api_tests.append(auth_test)
    
    # Test API rate limiting
    rate_limit_test = test_api_rate_limiting(apps, test_env)
    api_tests.append(rate_limit_test)
    
    # Test API error handling
    error_handling_test = test_api_error_handling(apps, test_env)
    api_tests.append(error_handling_test)
    
    return api_tests

def test_app_to_app_api_integration(source_app, target_app, test_env):
    """Test API integration between two apps"""
    
    test_result = {
        "test_name": f"api_integration_{source_app}_to_{target_app}",
        "start_time": frappe.utils.now(),
        "steps": []
    }
    
    try:
        # Step 1: Get API endpoints from target app
        endpoints = get_app_api_endpoints(target_app)
        
        # Step 2: Test each endpoint from source app context
        for endpoint in endpoints:
            step_result = test_api_endpoint_integration(
                source_app, 
                target_app, 
                endpoint, 
                test_env
            )
            test_result["steps"].append(step_result)
        
        # Step 3: Test data consistency
        consistency_result = verify_data_consistency_after_api_calls(
            source_app, 
            target_app, 
            test_env
        )
        test_result["steps"].append(consistency_result)
        
        # Determine overall result
        failed_steps = [s for s in test_result["steps"] if s["status"] == "failed"]
        test_result["status"] = "failed" if failed_steps else "passed"
        
    except Exception as e:
        test_result["status"] = "error"
        test_result["error"] = str(e)
        test_result["traceback"] = frappe.get_traceback()
    
    test_result["end_time"] = frappe.utils.now()
    
    return test_result
```

#### Database Integration Tests
```python
def run_database_integration_tests(apps, test_env):
    """Test database integrity across apps"""
    
    db_tests = []
    
    # Test foreign key relationships
    fk_test = test_foreign_key_integrity(apps, test_env)
    db_tests.append(fk_test)
    
    # Test transaction integrity
    transaction_test = test_transaction_integrity(apps, test_env)
    db_tests.append(transaction_test)
    
    # Test concurrent access
    concurrency_test = test_concurrent_database_access(apps, test_env)
    db_tests.append(concurrency_test)
    
    # Test data migration
    migration_test = test_data_migration_integrity(apps, test_env)
    db_tests.append(migration_test)
    
    return db_tests

def test_foreign_key_integrity(apps, test_env):
    """Test foreign key relationships between app tables"""
    
    test_result = {
        "test_name": "foreign_key_integrity",
        "violations": []
    }
    
    # Get all foreign key relationships
    fk_relationships = get_foreign_key_relationships(apps)
    
    for relationship in fk_relationships:
        # Test referential integrity
        violations = check_referential_integrity(relationship)
        
        if violations:
            test_result["violations"].extend(violations)
    
    test_result["status"] = "failed" if test_result["violations"] else "passed"
    
    return test_result

def test_transaction_integrity(apps, test_env):
    """Test transaction handling across apps"""
    
    test_scenarios = [
        {
            "name": "rollback_on_error",
            "scenario": test_rollback_on_error_scenario
        },
        {
            "name": "nested_transactions",
            "scenario": test_nested_transaction_scenario
        },
        {
            "name": "distributed_transaction",
            "scenario": test_distributed_transaction_scenario
        }
    ]
    
    results = []
    
    for scenario in test_scenarios:
        result = scenario["scenario"](apps, test_env)
        results.append(result)
    
    return {
        "test_name": "transaction_integrity",
        "scenarios": results,
        "status": "passed" if all(r["status"] == "passed" for r in results) else "failed"
    }
```

#### Workflow Integration Tests
```python
def run_workflow_integration_tests(apps, test_env):
    """Test workflow integration across apps"""
    
    workflow_tests = []
    
    # Test workflow transitions
    transition_test = test_workflow_transitions(apps, test_env)
    workflow_tests.append(transition_test)
    
    # Test workflow permissions
    permission_test = test_workflow_permissions(apps, test_env)
    workflow_tests.append(permission_test)
    
    # Test workflow notifications
    notification_test = test_workflow_notifications(apps, test_env)
    workflow_tests.append(notification_test)
    
    # Test workflow automation
    automation_test = test_workflow_automation(apps, test_env)
    workflow_tests.append(automation_test)
    
    return workflow_tests

def test_workflow_transitions(apps, test_env):
    """Test workflow state transitions"""
    
    test_result = {
        "test_name": "workflow_transitions",
        "transitions_tested": [],
        "failures": []
    }
    
    # Get all workflows
    workflows = get_all_workflows(apps)
    
    for workflow in workflows:
        # Test each transition
        for transition in workflow["transitions"]:
            transition_result = test_single_workflow_transition(
                workflow, 
                transition, 
                test_env
            )
            
            test_result["transitions_tested"].append(transition_result)
            
            if transition_result["status"] == "failed":
                test_result["failures"].append(transition_result)
    
    test_result["status"] = "failed" if test_result["failures"] else "passed"
    
    return test_result
```

#### UI Integration Tests
```python
def run_ui_integration_tests(apps, test_env):
    """Test UI component integration"""
    
    ui_tests = []
    
    # Test form interactions
    form_test = test_form_integration(apps, test_env)
    ui_tests.append(form_test)
    
    # Test list view integration
    list_test = test_list_view_integration(apps, test_env)
    ui_tests.append(list_test)
    
    # Test report integration
    report_test = test_report_integration(apps, test_env)
    ui_tests.append(report_test)
    
    # Test dashboard integration
    dashboard_test = test_dashboard_integration(apps, test_env)
    ui_tests.append(dashboard_test)
    
    return ui_tests

def test_form_integration(apps, test_env):
    """Test form interactions between apps"""
    
    test_result = {
        "test_name": "form_integration",
        "forms_tested": []
    }
    
    # Get all forms with cross-app fields
    cross_app_forms = get_cross_app_forms(apps)
    
    for form in cross_app_forms:
        form_test = {
            "form": form["name"],
            "tests": []
        }
        
        # Test field interactions
        field_test = test_cross_app_field_interactions(form, test_env)
        form_test["tests"].append(field_test)
        
        # Test validations
        validation_test = test_cross_app_validations(form, test_env)
        form_test["tests"].append(validation_test)
        
        # Test triggers
        trigger_test = test_cross_app_triggers(form, test_env)
        form_test["tests"].append(trigger_test)
        
        test_result["forms_tested"].append(form_test)
    
    # Determine overall status
    failed_forms = [f for f in test_result["forms_tested"] 
                   if any(t["status"] == "failed" for t in f["tests"])]
    test_result["status"] = "failed" if failed_forms else "passed"
    
    return test_result
```

### 4. Performance Integration Tests
```python
def run_performance_integration_tests(apps, test_env):
    """Test performance across integrated apps"""
    
    perf_tests = []
    
    # Test response times
    response_time_test = test_integrated_response_times(apps, test_env)
    perf_tests.append(response_time_test)
    
    # Test throughput
    throughput_test = test_integrated_throughput(apps, test_env)
    perf_tests.append(throughput_test)
    
    # Test resource usage
    resource_test = test_integrated_resource_usage(apps, test_env)
    perf_tests.append(resource_test)
    
    # Test scalability
    scalability_test = test_integrated_scalability(apps, test_env)
    perf_tests.append(scalability_test)
    
    return perf_tests

def test_integrated_response_times(apps, test_env):
    """Test response times for integrated operations"""
    
    test_result = {
        "test_name": "integrated_response_times",
        "operations": []
    }
    
    # Define integrated operations to test
    operations = [
        {
            "name": "create_sales_order_with_items",
            "apps": ["erpnext", "custom_app"],
            "expected_time": 500  # milliseconds
        },
        {
            "name": "generate_complex_report",
            "apps": ["frappe", "erpnext", "custom_app"],
            "expected_time": 2000
        },
        {
            "name": "bulk_data_import",
            "apps": ["frappe", "erpnext"],
            "expected_time": 5000
        }
    ]
    
    for operation in operations:
        # Measure response time
        start_time = time.time()
        
        try:
            execute_integrated_operation(operation, test_env)
            response_time = (time.time() - start_time) * 1000  # Convert to ms
            
            operation_result = {
                "operation": operation["name"],
                "response_time": response_time,
                "expected_time": operation["expected_time"],
                "status": "passed" if response_time <= operation["expected_time"] else "failed"
            }
            
        except Exception as e:
            operation_result = {
                "operation": operation["name"],
                "status": "error",
                "error": str(e)
            }
        
        test_result["operations"].append(operation_result)
    
    # Determine overall status
    failed_ops = [o for o in test_result["operations"] if o["status"] != "passed"]
    test_result["status"] = "failed" if failed_ops else "passed"
    
    return test_result
```

### 5. Security Integration Tests
```python
def run_security_integration_tests(apps, test_env):
    """Test security across integrated apps"""
    
    security_tests = []
    
    # Test authentication flow
    auth_test = test_integrated_authentication(apps, test_env)
    security_tests.append(auth_test)
    
    # Test authorization across apps
    authz_test = test_cross_app_authorization(apps, test_env)
    security_tests.append(authz_test)
    
    # Test data isolation
    isolation_test = test_data_isolation_between_apps(apps, test_env)
    security_tests.append(isolation_test)
    
    # Test injection vulnerabilities
    injection_test = test_injection_vulnerabilities(apps, test_env)
    security_tests.append(injection_test)
    
    return security_tests

def test_cross_app_authorization(apps, test_env):
    """Test authorization across app boundaries"""
    
    test_result = {
        "test_name": "cross_app_authorization",
        "scenarios": []
    }
    
    # Test scenarios
    scenarios = [
        {
            "name": "user_access_control",
            "description": "Test if user permissions are enforced across apps",
            "test_func": test_user_access_control_scenario
        },
        {
            "name": "role_based_access",
            "description": "Test if roles are properly enforced",
            "test_func": test_role_based_access_scenario
        },
        {
            "name": "api_key_access",
            "description": "Test API key authorization",
            "test_func": test_api_key_access_scenario
        }
    ]
    
    for scenario in scenarios:
        scenario_result = scenario["test_func"](apps, test_env)
        test_result["scenarios"].append({
            "name": scenario["name"],
            "description": scenario["description"],
            "result": scenario_result
        })
    
    # Determine overall status
    failed_scenarios = [s for s in test_result["scenarios"] 
                       if s["result"]["status"] == "failed"]
    test_result["status"] = "failed" if failed_scenarios else "passed"
    
    return test_result
```

### 6. Data Consistency Tests
```python
def run_data_consistency_tests(apps, test_env):
    """Test data consistency across integrated apps"""
    
    consistency_tests = []
    
    # Test referential integrity
    ref_test = test_referential_integrity(apps, test_env)
    consistency_tests.append(ref_test)
    
    # Test data synchronization
    sync_test = test_data_synchronization(apps, test_env)
    consistency_tests.append(sync_test)
    
    # Test cascade operations
    cascade_test = test_cascade_operations(apps, test_env)
    consistency_tests.append(cascade_test)
    
    # Test data validation
    validation_test = test_cross_app_data_validation(apps, test_env)
    consistency_tests.append(validation_test)
    
    return consistency_tests

def test_data_synchronization(apps, test_env):
    """Test data synchronization between apps"""
    
    test_result = {
        "test_name": "data_synchronization",
        "sync_points": []
    }
    
    # Identify sync points between apps
    sync_points = identify_data_sync_points(apps)
    
    for sync_point in sync_points:
        # Create test data in source app
        test_data = create_test_data_in_app(sync_point["source_app"], test_env)
        
        # Wait for sync
        time.sleep(sync_point.get("sync_delay", 1))
        
        # Verify data in target app
        verification_result = verify_synced_data(
            sync_point["target_app"],
            test_data,
            test_env
        )
        
        test_result["sync_points"].append({
            "source": sync_point["source_app"],
            "target": sync_point["target_app"],
            "data_type": sync_point["data_type"],
            "verification": verification_result
        })
    
    # Determine overall status
    failed_syncs = [s for s in test_result["sync_points"] 
                   if not s["verification"]["success"]]
    test_result["status"] = "failed" if failed_syncs else "passed"
    
    return test_result
```

### 7. Test Result Processing
```python
def process_integration_test_results(test_run):
    """Process and analyze integration test results"""
    
    analysis = {
        "summary": generate_test_summary(test_run),
        "failed_tests": extract_failed_tests(test_run),
        "error_patterns": analyze_error_patterns(test_run),
        "performance_metrics": extract_performance_metrics(test_run),
        "coverage_analysis": analyze_test_coverage(test_run),
        "recommendations": generate_test_recommendations(test_run)
    }
    
    return analysis

def generate_test_summary(test_run):
    """Generate test execution summary"""
    
    total_tests = len(test_run["tests"])
    
    summary = {
        "test_suite": test_run["suite"],
        "execution_time": test_run["duration"],
        "total_tests": total_tests,
        "passed": test_run["results"]["passed"],
        "failed": test_run["results"]["failed"],
        "skipped": test_run["results"]["skipped"],
        "errors": test_run["results"]["errors"],
        "pass_rate": (test_run["results"]["passed"] / total_tests * 100) if total_tests > 0 else 0,
        "status": "passed" if test_run["results"]["failed"] == 0 and test_run["results"]["errors"] == 0 else "failed"
    }
    
    return summary

def analyze_error_patterns(test_run):
    """Analyze patterns in test failures"""
    
    error_patterns = {
        "by_type": {},
        "by_app": {},
        "by_component": {},
        "common_causes": []
    }
    
    for test in test_run["tests"]:
        if test["status"] in ["failed", "error"]:
            # Categorize by error type
            error_type = extract_error_type(test)
            if error_type not in error_patterns["by_type"]:
                error_patterns["by_type"][error_type] = []
            error_patterns["by_type"][error_type].append(test["test_name"])
            
            # Categorize by app
            affected_apps = extract_affected_apps(test)
            for app in affected_apps:
                if app not in error_patterns["by_app"]:
                    error_patterns["by_app"][app] = []
                error_patterns["by_app"][app].append(test["test_name"])
    
    # Identify common causes
    error_patterns["common_causes"] = identify_common_error_causes(error_patterns)
    
    return error_patterns
```

### 8. Test Reporting
```python
def generate_integration_test_report(test_run, analysis):
    """Generate comprehensive integration test report"""
    
    report = {
        "metadata": {
            "report_id": generate_report_id(),
            "test_suite": test_run["suite"],
            "execution_date": test_run["start_time"],
            "environment": test_run["test_env"],
            "generated_at": frappe.utils.now()
        },
        "executive_summary": create_executive_summary(analysis),
        "detailed_results": format_detailed_results(test_run),
        "failure_analysis": create_failure_analysis(analysis),
        "performance_report": create_performance_report(analysis),
        "coverage_report": create_coverage_report(analysis),
        "recommendations": format_recommendations(analysis),
        "appendix": {
            "test_logs": get_test_logs(test_run),
            "environment_details": get_environment_details(test_run["test_env"]),
            "test_data": get_test_data_summary(test_run)
        }
    }
    
    # Generate report in multiple formats
    formats = {
        "html": generate_html_report(report),
        "pdf": generate_pdf_report(report),
        "json": report
    }
    
    return formats

def create_executive_summary(analysis):
    """Create executive summary for report"""
    
    summary = analysis["summary"]
    
    executive_summary = f"""
    Integration Testing Executive Summary
    =====================================
    
    Test Suite: {summary['test_suite']}
    Execution Time: {summary['execution_time']}
    
    Overall Status: {summary['status'].upper()}
    
    Test Results:
    - Total Tests: {summary['total_tests']}
    - Passed: {summary['passed']} ({summary['pass_rate']:.1f}%)
    - Failed: {summary['failed']}
    - Errors: {summary['errors']}
    - Skipped: {summary['skipped']}
    
    Key Findings:
    {format_key_findings(analysis)}
    
    Recommendations:
    {format_key_recommendations(analysis['recommendations'])}
    """
    
    return executive_summary
```

### 9. Cleanup and Restoration
```python
def cleanup_integration_test_environment(test_env):
    """Clean up test environment after integration tests"""
    
    cleanup_log = {
        "test_id": test_env["test_id"],
        "cleanup_start": frappe.utils.now(),
        "actions": []
    }
    
    try:
        # Restore original site state
        if test_env.get("original_state"):
            restore_result = restore_site_state(test_env["site"], test_env["original_state"])
            cleanup_log["actions"].append({
                "action": "restore_state",
                "result": restore_result
            })
        
        # Clean up test data
        cleanup_result = cleanup_test_data(test_env["site"])
        cleanup_log["actions"].append({
            "action": "cleanup_test_data",
            "result": cleanup_result
        })
        
        # Reset test mode
        set_test_mode(test_env["site"], False)
        
        # Clear test caches
        clear_test_caches(test_env["site"])
        
        cleanup_log["status"] = "completed"
        
    except Exception as e:
        cleanup_log["status"] = "failed"
        cleanup_log["error"] = str(e)
    
    cleanup_log["cleanup_end"] = frappe.utils.now()
    
    return cleanup_log

def restore_site_state(site, original_state):
    """Restore site to original state"""
    
    restoration_steps = []
    
    # Restore configuration
    if "config" in original_state:
        update_site_config(site, original_state["config"])
        restoration_steps.append("config_restored")
    
    # Restore database
    if "database_snapshot" in original_state:
        restore_database_snapshot(site, original_state["database_snapshot"])
        restoration_steps.append("database_restored")
    
    # Restore file system
    if "file_system_snapshot" in original_state:
        restore_file_system_snapshot(site, original_state["file_system_snapshot"])
        restoration_steps.append("files_restored")
    
    # Restore cache state
    if "cache_state" in original_state:
        restore_cache_state(site, original_state["cache_state"])
        restoration_steps.append("cache_restored")
    
    return {
        "status": "completed",
        "steps": restoration_steps
    }
```

## Best Practices
1. **Isolate test environment from production**
2. **Use realistic test data**
3. **Test both positive and negative scenarios**
4. **Include edge cases in test scenarios**
5. **Monitor resource usage during tests**
6. **Clean up test data after execution**
7. **Version control test configurations**
8. **Run tests in CI/CD pipeline**
9. **Generate comprehensive test reports**
10. **Track test metrics over time**

## Integration Points
- **Testing Specialist**: Primary agent for execution
- **QA Lead**: Test planning and analysis
- **Developer**: Test implementation and debugging
- **DevOps**: CI/CD integration
- **System Administrator**: Test environment management