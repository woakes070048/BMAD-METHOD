# coordinate-team-handoff

## Task Description
Coordinate handoffs between development team members and different project phases to ensure smooth transitions and knowledge transfer.

## Parameters
- `handoff_type`: phase_transition, role_handoff, or emergency_handoff
- `from_agent`: Agent/role handing off the work
- `to_agent`: Agent/role receiving the work
- `deliverables`: List of items being transferred
- `project_context`: Current project state and context

## Prerequisites
- Current work status documented
- Deliverables clearly defined
- Acceptance criteria established
- Next agent identified and available

## Steps

### 1. Handoff Preparation
```python
def prepare_handoff(handoff_data):
    """Prepare comprehensive handoff documentation"""
    
    handoff_package = {
        "handoff_id": generate_handoff_id(),
        "timestamp": frappe.utils.now(),
        "from_agent": handoff_data["from_agent"],
        "to_agent": handoff_data["to_agent"],
        "handoff_type": handoff_data["handoff_type"],
        "project_context": {},
        "deliverables": [],
        "status": "prepared",
        "checklist": []
    }
    
    # Gather current project context
    handoff_package["project_context"] = gather_project_context(handoff_data)
    
    # Validate deliverables
    handoff_package["deliverables"] = validate_deliverables(handoff_data["deliverables"])
    
    # Generate handoff checklist
    handoff_package["checklist"] = generate_handoff_checklist(handoff_data["handoff_type"])
    
    return handoff_package

def gather_project_context(handoff_data):
    """Gather comprehensive project context"""
    return {
        "current_phase": get_current_project_phase(),
        "completed_tasks": get_completed_tasks(),
        "pending_tasks": get_pending_tasks(),
        "blockers": get_current_blockers(),
        "dependencies": get_active_dependencies(),
        "recent_decisions": get_recent_decisions(),
        "environment_status": get_environment_status(),
        "code_branches": get_active_branches(),
        "test_results": get_latest_test_results()
    }
```

### 2. Deliverables Validation
```python
def validate_deliverables(deliverables):
    """Validate completeness and quality of deliverables"""
    
    validated_deliverables = []
    
    for deliverable in deliverables:
        validation_result = {
            "name": deliverable["name"],
            "type": deliverable["type"],
            "status": "pending",
            "validation_checks": [],
            "issues": [],
            "sign_off_required": deliverable.get("sign_off_required", False)
        }
        
        # Run type-specific validations
        if deliverable["type"] == "code":
            validation_result.update(validate_code_deliverable(deliverable))
        elif deliverable["type"] == "documentation":
            validation_result.update(validate_documentation_deliverable(deliverable))
        elif deliverable["type"] == "configuration":
            validation_result.update(validate_configuration_deliverable(deliverable))
        elif deliverable["type"] == "test_results":
            validation_result.update(validate_test_deliverable(deliverable))
        
        validated_deliverables.append(validation_result)
    
    return validated_deliverables

def validate_code_deliverable(deliverable):
    """Validate code-related deliverables"""
    checks = []
    issues = []
    
    # Check if code is committed
    if not check_code_committed(deliverable["location"]):
        issues.append("Code changes not committed to version control")
    else:
        checks.append("Code committed to version control")
    
    # Check if tests pass
    if not run_quick_tests(deliverable["location"]):
        issues.append("Tests failing")
    else:
        checks.append("Tests passing")
    
    # Check code quality
    quality_issues = check_code_quality(deliverable["location"])
    if quality_issues:
        issues.extend(quality_issues)
    else:
        checks.append("Code quality checks passed")
    
    return {
        "status": "ready" if not issues else "needs_attention",
        "validation_checks": checks,
        "issues": issues
    }
```

### 3. Handoff Types and Procedures

#### Phase Transition Handoff
```python
def execute_phase_transition_handoff(handoff_package):
    """Handle transition between project phases"""
    
    phase_transitions = {
        "analysis_to_design": {
            "required_deliverables": ["requirements_doc", "user_stories", "acceptance_criteria"],
            "validation_rules": ["all_requirements_reviewed", "stakeholder_sign_off"],
            "next_phase_setup": setup_design_phase
        },
        "design_to_development": {
            "required_deliverables": ["technical_design", "database_schema", "api_design"],
            "validation_rules": ["design_review_complete", "architecture_approved"],
            "next_phase_setup": setup_development_phase
        },
        "development_to_testing": {
            "required_deliverables": ["code_complete", "unit_tests", "deployment_scripts"],
            "validation_rules": ["code_review_complete", "builds_successfully"],
            "next_phase_setup": setup_testing_phase
        },
        "testing_to_deployment": {
            "required_deliverables": ["test_results", "performance_tests", "security_scan"],
            "validation_rules": ["all_tests_passed", "performance_acceptable"],
            "next_phase_setup": setup_deployment_phase
        }
    }
    
    current_transition = handoff_package["project_context"].get("current_phase_transition")
    
    if current_transition in phase_transitions:
        transition_config = phase_transitions[current_transition]
        
        # Validate required deliverables
        validate_phase_deliverables(handoff_package["deliverables"], 
                                   transition_config["required_deliverables"])
        
        # Run validation rules
        run_phase_validation_rules(handoff_package, transition_config["validation_rules"])
        
        # Setup next phase
        transition_config["next_phase_setup"](handoff_package)
        
        return {"status": "phase_transition_complete", "next_phase": get_next_phase()}
```

#### Role-Based Handoff
```python
def execute_role_handoff(handoff_package):
    """Handle handoff between different roles/agents"""
    
    role_handoffs = {
        "business_analyst_to_architect": {
            "knowledge_transfer": [
                "business_requirements_walkthrough",
                "stakeholder_expectations_review", 
                "constraint_discussion"
            ],
            "deliverables_review": ["requirements_doc", "user_stories", "process_flows"],
            "setup_actions": ["create_architecture_workspace", "schedule_design_sessions"]
        },
        "architect_to_developer": {
            "knowledge_transfer": [
                "technical_architecture_walkthrough",
                "design_decisions_rationale",
                "integration_points_review"
            ],
            "deliverables_review": ["technical_design", "database_design", "api_specs"],
            "setup_actions": ["setup_dev_environment", "create_development_tasks"]
        },
        "developer_to_tester": {
            "knowledge_transfer": [
                "feature_functionality_demo",
                "edge_cases_discussion",
                "known_limitations_review"
            ],
            "deliverables_review": ["completed_features", "test_data", "deployment_guides"],
            "setup_actions": ["setup_test_environment", "create_test_scenarios"]
        }
    }
    
    handoff_key = f"{handoff_package['from_agent']}_to_{handoff_package['to_agent']}"
    
    if handoff_key in role_handoffs:
        handoff_config = role_handoffs[handoff_key]
        
        # Execute knowledge transfer sessions
        execute_knowledge_transfer(handoff_config["knowledge_transfer"], handoff_package)
        
        # Review deliverables with receiving agent
        conduct_deliverables_review(handoff_config["deliverables_review"], handoff_package)
        
        # Execute setup actions
        execute_setup_actions(handoff_config["setup_actions"], handoff_package)
```

### 4. Knowledge Transfer Sessions
```python
def execute_knowledge_transfer(transfer_sessions, handoff_package):
    """Conduct structured knowledge transfer sessions"""
    
    transfer_log = []
    
    for session_type in transfer_sessions:
        session_result = conduct_transfer_session(session_type, handoff_package)
        transfer_log.append(session_result)
    
    # Document knowledge transfer
    document_knowledge_transfer(transfer_log, handoff_package)
    
    return transfer_log

def conduct_transfer_session(session_type, handoff_package):
    """Conduct individual knowledge transfer session"""
    
    session_templates = {
        "business_requirements_walkthrough": {
            "agenda": [
                "Review business objectives",
                "Discuss user personas and use cases",
                "Explain business rules and constraints",
                "Review acceptance criteria",
                "Q&A session"
            ],
            "duration": 60,
            "required_materials": ["requirements_doc", "user_stories"]
        },
        "technical_architecture_walkthrough": {
            "agenda": [
                "Review system architecture diagram",
                "Explain technology choices and rationale",
                "Discuss integration points",
                "Review security considerations",
                "Explain scalability considerations"
            ],
            "duration": 90,
            "required_materials": ["architecture_doc", "technical_design"]
        },
        "feature_functionality_demo": {
            "agenda": [
                "Demonstrate completed features",
                "Explain user workflows", 
                "Show data validation rules",
                "Discuss error handling",
                "Review performance considerations"
            ],
            "duration": 45,
            "required_materials": ["working_demo", "test_data"]
        }
    }
    
    if session_type in session_templates:
        template = session_templates[session_type]
        
        return {
            "session_type": session_type,
            "agenda_completed": template["agenda"],
            "duration": template["duration"],
            "materials_used": template["required_materials"],
            "status": "completed",
            "notes": generate_session_notes(session_type, handoff_package),
            "action_items": identify_action_items(session_type, handoff_package)
        }
```

### 5. Handoff Documentation
```python
def generate_handoff_document(handoff_package):
    """Generate comprehensive handoff documentation"""
    
    handoff_doc = {
        "handoff_summary": {
            "id": handoff_package["handoff_id"],
            "from_agent": handoff_package["from_agent"],
            "to_agent": handoff_package["to_agent"],
            "handoff_date": handoff_package["timestamp"],
            "handoff_type": handoff_package["handoff_type"]
        },
        "project_state": {
            "current_phase": handoff_package["project_context"]["current_phase"],
            "completion_percentage": calculate_completion_percentage(handoff_package),
            "next_milestones": get_next_milestones(handoff_package)
        },
        "deliverables_summary": generate_deliverables_summary(handoff_package["deliverables"]),
        "knowledge_transfer_log": handoff_package.get("knowledge_transfer_log", []),
        "action_items": extract_action_items(handoff_package),
        "risks_and_issues": identify_risks_and_issues(handoff_package),
        "recommendations": generate_recommendations(handoff_package)
    }
    
    # Save handoff document
    save_handoff_document(handoff_doc)
    
    return handoff_doc

def generate_deliverables_summary(deliverables):
    """Generate summary of all deliverables"""
    summary = {
        "total_deliverables": len(deliverables),
        "ready_deliverables": len([d for d in deliverables if d["status"] == "ready"]),
        "pending_deliverables": len([d for d in deliverables if d["status"] == "needs_attention"]),
        "deliverable_details": []
    }
    
    for deliverable in deliverables:
        summary["deliverable_details"].append({
            "name": deliverable["name"],
            "type": deliverable["type"],
            "status": deliverable["status"],
            "issues_count": len(deliverable.get("issues", [])),
            "validation_checks_passed": len(deliverable.get("validation_checks", []))
        })
    
    return summary
```

### 6. Handoff Checklist Templates
```python
def generate_handoff_checklist(handoff_type):
    """Generate checklist based on handoff type"""
    
    checklists = {
        "phase_transition": [
            "All phase deliverables completed and validated",
            "Phase exit criteria met",
            "Stakeholder sign-off obtained",
            "Next phase resources allocated",
            "Risk mitigation plans updated",
            "Project timeline updated",
            "Communication to stakeholders sent"
        ],
        "role_handoff": [
            "Knowledge transfer sessions completed",
            "All deliverables reviewed and accepted",
            "Access permissions transferred",
            "Tool accounts setup/transferred",
            "Contact lists shared",
            "Ongoing responsibilities clarified",
            "Escalation procedures explained",
            "Follow-up schedule established"
        ],
        "emergency_handoff": [
            "Critical information documented",
            "Immediate action items identified",
            "Emergency contacts shared",
            "System access credentials transferred securely",
            "Current issues and blockers documented",
            "Quick-start guide created",
            "Support resources identified",
            "Stakeholders notified of change"
        ]
    }
    
    base_checklist = [
        "Handoff documentation complete",
        "Receiving agent briefed",
        "Questions answered",
        "Next steps defined",
        "Success criteria agreed",
        "Communication channels established"
    ]
    
    return checklists.get(handoff_type, []) + base_checklist
```

### 7. Post-Handoff Follow-up
```python
def schedule_handoff_followup(handoff_package):
    """Schedule follow-up activities after handoff"""
    
    followup_schedule = {
        "immediate": {  # Within 24 hours
            "tasks": [
                "Verify receiving agent has access to all resources",
                "Confirm understanding of immediate next steps",
                "Address any urgent questions or issues"
            ]
        },
        "short_term": {  # Within 1 week
            "tasks": [
                "Review progress on handed-off work",
                "Identify any knowledge gaps",
                "Adjust processes based on initial feedback"
            ]
        },
        "long_term": {  # Within 1 month
            "tasks": [
                "Evaluate handoff effectiveness",
                "Document lessons learned",
                "Update handoff procedures if needed"
            ]
        }
    }
    
    # Create follow-up tasks
    for timeframe, activities in followup_schedule.items():
        for task in activities["tasks"]:
            create_followup_task(task, timeframe, handoff_package)

def create_followup_task(task_description, timeframe, handoff_package):
    """Create follow-up task in project management system"""
    due_dates = {
        "immediate": frappe.utils.add_days(frappe.utils.today(), 1),
        "short_term": frappe.utils.add_days(frappe.utils.today(), 7),
        "long_term": frappe.utils.add_days(frappe.utils.today(), 30)
    }
    
    task = {
        "task_name": f"Handoff Follow-up: {task_description}",
        "assigned_to": handoff_package["from_agent"],
        "due_date": due_dates[timeframe],
        "priority": "High" if timeframe == "immediate" else "Medium",
        "related_handoff": handoff_package["handoff_id"],
        "description": f"Follow-up task for handoff {handoff_package['handoff_id']}"
    }
    
    # Create task in system
    return create_project_task(task)
```

## Handoff Quality Metrics
```python
def measure_handoff_quality(handoff_id):
    """Measure the quality and effectiveness of handoff"""
    
    metrics = {
        "preparation_score": calculate_preparation_score(handoff_id),
        "deliverables_quality": assess_deliverables_quality(handoff_id),
        "knowledge_transfer_effectiveness": measure_knowledge_transfer(handoff_id),
        "receiving_agent_satisfaction": get_satisfaction_rating(handoff_id),
        "post_handoff_issues": count_post_handoff_issues(handoff_id),
        "time_to_productivity": measure_productivity_time(handoff_id)
    }
    
    # Calculate overall handoff quality score
    metrics["overall_score"] = calculate_overall_score(metrics)
    
    return metrics
```

## Integration Points
- **Main Dev Coordinator**: Primary agent using this task
- **All Development Agents**: Participants in handoff processes
- **Project Management**: Handoff tracking and metrics
- **Quality Assurance**: Handoff validation and improvement