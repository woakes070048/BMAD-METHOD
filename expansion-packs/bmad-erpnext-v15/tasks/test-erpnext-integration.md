# test-erpnext-integration

## Task Description
Comprehensive testing of ERPNext module integrations, business workflows, and cross-module data flow to ensure seamless operation.

## Parameters
- `test_modules`: List of ERPNext modules to test (e.g., Sales, Purchase, Stock, Accounting)
- `test_depth`: basic, standard, or comprehensive
- `integration_points`: Specific integration points to focus on
- `site`: Target site for testing
- `generate_report`: Generate detailed test report (default: true)

## Prerequisites
- ERPNext installed and configured
- Test data available
- Test users with appropriate permissions
- Business scenarios documented

## Steps

### 1. Module Integration Testing
```python
def test_erpnext_module_integration(modules, site):
    """Test integration between ERPNext modules"""
    
    test_suite = {
        "site": site,
        "modules": modules,
        "test_id": generate_test_id(),
        "start_time": frappe.utils.now(),
        "results": {}
    }
    
    # Test individual modules first
    for module in modules:
        module_result = test_individual_module(module, site)
        test_suite["results"][module] = module_result
    
    # Test cross-module integrations
    integration_tests = []
    
    # Sales to Stock integration
    if "Sales" in modules and "Stock" in modules:
        sales_stock_test = test_sales_stock_integration(site)
        integration_tests.append(sales_stock_test)
    
    # Purchase to Stock integration
    if "Purchase" in modules and "Stock" in modules:
        purchase_stock_test = test_purchase_stock_integration(site)
        integration_tests.append(purchase_stock_test)
    
    # Stock to Accounting integration
    if "Stock" in modules and "Accounts" in modules:
        stock_accounts_test = test_stock_accounting_integration(site)
        integration_tests.append(stock_accounts_test)
    
    # Manufacturing integration
    if "Manufacturing" in modules:
        manufacturing_test = test_manufacturing_integration(site)
        integration_tests.append(manufacturing_test)
    
    test_suite["integration_tests"] = integration_tests
    test_suite["end_time"] = frappe.utils.now()
    
    return test_suite

def test_individual_module(module, site):
    """Test individual ERPNext module functionality"""
    
    module_tests = {
        "module": module,
        "doctypes_tested": [],
        "workflows_tested": [],
        "reports_tested": [],
        "permissions_tested": [],
        "status": "in_progress"
    }
    
    # Get module doctypes
    doctypes = get_module_doctypes(module)
    
    # Test CRUD operations for each doctype
    for doctype in doctypes:
        doctype_test = test_doctype_operations(doctype, site)
        module_tests["doctypes_tested"].append(doctype_test)
    
    # Test module workflows
    workflows = get_module_workflows(module)
    for workflow in workflows:
        workflow_test = test_workflow_execution(workflow, site)
        module_tests["workflows_tested"].append(workflow_test)
    
    # Test module reports
    reports = get_module_reports(module)
    for report in reports:
        report_test = test_report_generation(report, site)
        module_tests["reports_tested"].append(report_test)
    
    # Test module permissions
    permission_test = test_module_permissions(module, site)
    module_tests["permissions_tested"] = permission_test
    
    # Determine overall status
    failed_tests = [
        t for t in module_tests["doctypes_tested"] if t["status"] == "failed"
    ]
    module_tests["status"] = "failed" if failed_tests else "passed"
    
    return module_tests
```

### 2. Sales Cycle Testing
```python
def test_sales_cycle_integration(site):
    """Test complete sales cycle from lead to payment"""
    
    sales_cycle_test = {
        "test_name": "sales_cycle_integration",
        "stages": [],
        "data_flow": {},
        "validations": []
    }
    
    try:
        # Stage 1: Lead Creation
        lead = create_test_lead()
        sales_cycle_test["stages"].append({
            "stage": "lead_creation",
            "document": lead.name,
            "status": "completed"
        })
        
        # Stage 2: Lead to Opportunity
        opportunity = convert_lead_to_opportunity(lead)
        sales_cycle_test["stages"].append({
            "stage": "opportunity_creation",
            "document": opportunity.name,
            "status": "completed"
        })
        
        # Stage 3: Opportunity to Quotation
        quotation = create_quotation_from_opportunity(opportunity)
        sales_cycle_test["stages"].append({
            "stage": "quotation_creation",
            "document": quotation.name,
            "status": "completed"
        })
        
        # Stage 4: Quotation to Sales Order
        sales_order = convert_quotation_to_sales_order(quotation)
        sales_cycle_test["stages"].append({
            "stage": "sales_order_creation",
            "document": sales_order.name,
            "status": "completed"
        })
        
        # Stage 5: Sales Order to Delivery Note
        delivery_note = create_delivery_note_from_sales_order(sales_order)
        sales_cycle_test["stages"].append({
            "stage": "delivery_note_creation",
            "document": delivery_note.name,
            "status": "completed"
        })
        
        # Stage 6: Delivery Note to Sales Invoice
        sales_invoice = create_sales_invoice_from_delivery_note(delivery_note)
        sales_cycle_test["stages"].append({
            "stage": "sales_invoice_creation",
            "document": sales_invoice.name,
            "status": "completed"
        })
        
        # Stage 7: Payment Entry
        payment_entry = create_payment_entry_for_invoice(sales_invoice)
        sales_cycle_test["stages"].append({
            "stage": "payment_entry_creation",
            "document": payment_entry.name,
            "status": "completed"
        })
        
        # Validate data flow
        sales_cycle_test["data_flow"] = validate_sales_cycle_data_flow({
            "lead": lead,
            "opportunity": opportunity,
            "quotation": quotation,
            "sales_order": sales_order,
            "delivery_note": delivery_note,
            "sales_invoice": sales_invoice,
            "payment_entry": payment_entry
        })
        
        # Validate accounting entries
        accounting_validation = validate_sales_accounting_entries(sales_invoice, payment_entry)
        sales_cycle_test["validations"].append(accounting_validation)
        
        # Validate stock entries
        stock_validation = validate_stock_movement(delivery_note)
        sales_cycle_test["validations"].append(stock_validation)
        
        sales_cycle_test["status"] = "passed"
        
    except Exception as e:
        sales_cycle_test["status"] = "failed"
        sales_cycle_test["error"] = str(e)
        sales_cycle_test["traceback"] = frappe.get_traceback()
    
    return sales_cycle_test

def validate_sales_cycle_data_flow(documents):
    """Validate data consistency across sales documents"""
    
    validations = []
    
    # Validate customer consistency
    customer = documents["quotation"].party_name
    for doc_type, doc in documents.items():
        if hasattr(doc, "customer") and doc.customer:
            if doc.customer != customer:
                validations.append({
                    "check": "customer_consistency",
                    "status": "failed",
                    "message": f"Customer mismatch in {doc_type}"
                })
    
    # Validate item consistency
    quotation_items = {item.item_code: item.qty for item in documents["quotation"].items}
    sales_order_items = {item.item_code: item.qty for item in documents["sales_order"].items}
    
    if quotation_items != sales_order_items:
        validations.append({
            "check": "item_consistency",
            "status": "failed",
            "message": "Item mismatch between quotation and sales order"
        })
    
    # Validate pricing consistency
    quotation_total = documents["quotation"].grand_total
    sales_order_total = documents["sales_order"].grand_total
    
    if abs(quotation_total - sales_order_total) > 0.01:
        validations.append({
            "check": "pricing_consistency",
            "status": "failed",
            "message": "Price mismatch between quotation and sales order"
        })
    
    return validations
```

### 3. Purchase Cycle Testing
```python
def test_purchase_cycle_integration(site):
    """Test complete purchase cycle from requisition to payment"""
    
    purchase_cycle_test = {
        "test_name": "purchase_cycle_integration",
        "stages": [],
        "validations": []
    }
    
    try:
        # Stage 1: Material Request
        material_request = create_test_material_request()
        purchase_cycle_test["stages"].append({
            "stage": "material_request",
            "document": material_request.name,
            "status": "completed"
        })
        
        # Stage 2: Request for Quotation
        rfq = create_rfq_from_material_request(material_request)
        purchase_cycle_test["stages"].append({
            "stage": "request_for_quotation",
            "document": rfq.name,
            "status": "completed"
        })
        
        # Stage 3: Supplier Quotation
        supplier_quotation = create_supplier_quotation_from_rfq(rfq)
        purchase_cycle_test["stages"].append({
            "stage": "supplier_quotation",
            "document": supplier_quotation.name,
            "status": "completed"
        })
        
        # Stage 4: Purchase Order
        purchase_order = create_purchase_order_from_quotation(supplier_quotation)
        purchase_cycle_test["stages"].append({
            "stage": "purchase_order",
            "document": purchase_order.name,
            "status": "completed"
        })
        
        # Stage 5: Purchase Receipt
        purchase_receipt = create_purchase_receipt_from_order(purchase_order)
        purchase_cycle_test["stages"].append({
            "stage": "purchase_receipt",
            "document": purchase_receipt.name,
            "status": "completed"
        })
        
        # Stage 6: Purchase Invoice
        purchase_invoice = create_purchase_invoice_from_receipt(purchase_receipt)
        purchase_cycle_test["stages"].append({
            "stage": "purchase_invoice",
            "document": purchase_invoice.name,
            "status": "completed"
        })
        
        # Stage 7: Payment to Supplier
        payment = create_payment_entry_for_purchase(purchase_invoice)
        purchase_cycle_test["stages"].append({
            "stage": "payment_entry",
            "document": payment.name,
            "status": "completed"
        })
        
        # Validate purchase cycle
        purchase_validations = validate_purchase_cycle({
            "material_request": material_request,
            "purchase_order": purchase_order,
            "purchase_receipt": purchase_receipt,
            "purchase_invoice": purchase_invoice
        })
        purchase_cycle_test["validations"] = purchase_validations
        
        purchase_cycle_test["status"] = "passed"
        
    except Exception as e:
        purchase_cycle_test["status"] = "failed"
        purchase_cycle_test["error"] = str(e)
    
    return purchase_cycle_test
```

### 4. Stock Management Testing
```python
def test_stock_management_integration(site):
    """Test stock management and inventory tracking"""
    
    stock_test = {
        "test_name": "stock_management",
        "operations": [],
        "validations": []
    }
    
    # Test stock entry types
    stock_entry_types = [
        "Material Receipt",
        "Material Issue",
        "Material Transfer",
        "Material Transfer for Manufacture",
        "Manufacture",
        "Repack",
        "Send to Subcontractor"
    ]
    
    for entry_type in stock_entry_types:
        operation_test = test_stock_entry_type(entry_type, site)
        stock_test["operations"].append(operation_test)
    
    # Test stock reconciliation
    reconciliation_test = test_stock_reconciliation(site)
    stock_test["operations"].append(reconciliation_test)
    
    # Test batch tracking
    batch_test = test_batch_tracking(site)
    stock_test["operations"].append(batch_test)
    
    # Test serial number tracking
    serial_test = test_serial_number_tracking(site)
    stock_test["operations"].append(serial_test)
    
    # Test warehouse management
    warehouse_test = test_warehouse_operations(site)
    stock_test["operations"].append(warehouse_test)
    
    # Validate stock levels
    stock_level_validation = validate_stock_levels(site)
    stock_test["validations"].append(stock_level_validation)
    
    # Validate stock valuation
    valuation_test = validate_stock_valuation(site)
    stock_test["validations"].append(valuation_test)
    
    return stock_test

def test_stock_entry_type(entry_type, site):
    """Test specific stock entry type"""
    
    test_result = {
        "entry_type": entry_type,
        "test_cases": []
    }
    
    # Create test stock entry
    stock_entry = create_test_stock_entry(entry_type)
    
    # Test submission
    submission_test = {
        "test": "submission",
        "status": "passed" if stock_entry.docstatus == 1 else "failed"
    }
    test_result["test_cases"].append(submission_test)
    
    # Test stock ledger entries
    sle_test = validate_stock_ledger_entries(stock_entry)
    test_result["test_cases"].append(sle_test)
    
    # Test general ledger entries
    gle_test = validate_general_ledger_entries(stock_entry)
    test_result["test_cases"].append(gle_test)
    
    # Test cancellation
    cancellation_test = test_stock_entry_cancellation(stock_entry)
    test_result["test_cases"].append(cancellation_test)
    
    return test_result
```

### 5. Manufacturing Testing
```python
def test_manufacturing_integration(site):
    """Test manufacturing module integration"""
    
    manufacturing_test = {
        "test_name": "manufacturing_integration",
        "bom_tests": [],
        "work_order_tests": [],
        "production_tests": []
    }
    
    # Test BOM creation and validation
    bom = create_test_bom()
    bom_validation = validate_bom_structure(bom)
    manufacturing_test["bom_tests"].append(bom_validation)
    
    # Test multi-level BOM
    multi_level_bom = create_multi_level_bom()
    multi_level_validation = validate_multi_level_bom(multi_level_bom)
    manufacturing_test["bom_tests"].append(multi_level_validation)
    
    # Test Work Order creation
    work_order = create_work_order_from_bom(bom)
    wo_validation = validate_work_order(work_order)
    manufacturing_test["work_order_tests"].append(wo_validation)
    
    # Test production planning
    production_plan = create_production_plan()
    plan_validation = validate_production_plan(production_plan)
    manufacturing_test["production_tests"].append(plan_validation)
    
    # Test material transfer for manufacture
    material_transfer = create_material_transfer_for_manufacture(work_order)
    transfer_validation = validate_material_transfer(material_transfer)
    manufacturing_test["production_tests"].append(transfer_validation)
    
    # Test manufacture entry
    manufacture_entry = create_manufacture_entry(work_order)
    manufacture_validation = validate_manufacture_entry(manufacture_entry)
    manufacturing_test["production_tests"].append(manufacture_validation)
    
    # Test capacity planning
    capacity_test = test_capacity_planning(site)
    manufacturing_test["production_tests"].append(capacity_test)
    
    return manufacturing_test

def validate_bom_structure(bom):
    """Validate BOM structure and costing"""
    
    validation = {
        "bom": bom.name,
        "checks": []
    }
    
    # Check for circular reference
    circular_check = check_bom_circular_reference(bom)
    validation["checks"].append({
        "check": "circular_reference",
        "status": "passed" if not circular_check else "failed"
    })
    
    # Validate raw material cost
    cost_validation = validate_bom_cost(bom)
    validation["checks"].append({
        "check": "cost_calculation",
        "status": "passed" if cost_validation["accurate"] else "failed",
        "details": cost_validation
    })
    
    # Validate item availability
    availability_check = check_raw_material_availability(bom)
    validation["checks"].append({
        "check": "material_availability",
        "status": "passed" if availability_check["available"] else "warning",
        "details": availability_check
    })
    
    return validation
```

### 6. Accounting Integration Testing
```python
def test_accounting_integration(site):
    """Test accounting module integration"""
    
    accounting_test = {
        "test_name": "accounting_integration",
        "journal_entries": [],
        "payment_entries": [],
        "reconciliation": [],
        "reports": []
    }
    
    # Test journal entry posting
    journal_entry = create_test_journal_entry()
    je_validation = validate_journal_entry(journal_entry)
    accounting_test["journal_entries"].append(je_validation)
    
    # Test payment entry
    payment_entry = create_test_payment_entry()
    pe_validation = validate_payment_entry(payment_entry)
    accounting_test["payment_entries"].append(pe_validation)
    
    # Test bank reconciliation
    reconciliation = test_bank_reconciliation(site)
    accounting_test["reconciliation"].append(reconciliation)
    
    # Test payment reconciliation
    payment_reconciliation = test_payment_reconciliation(site)
    accounting_test["reconciliation"].append(payment_reconciliation)
    
    # Test financial reports
    report_tests = [
        test_profit_and_loss_statement(site),
        test_balance_sheet(site),
        test_cash_flow_statement(site),
        test_general_ledger(site),
        test_trial_balance(site)
    ]
    accounting_test["reports"] = report_tests
    
    # Test multi-currency transactions
    multi_currency_test = test_multi_currency_transactions(site)
    accounting_test["multi_currency"] = multi_currency_test
    
    # Test tax calculations
    tax_test = test_tax_calculations(site)
    accounting_test["tax_calculations"] = tax_test
    
    return accounting_test

def validate_journal_entry(journal_entry):
    """Validate journal entry posting"""
    
    validation = {
        "document": journal_entry.name,
        "checks": []
    }
    
    # Check debit credit match
    total_debit = sum(acc.debit for acc in journal_entry.accounts)
    total_credit = sum(acc.credit for acc in journal_entry.accounts)
    
    validation["checks"].append({
        "check": "debit_credit_match",
        "status": "passed" if total_debit == total_credit else "failed",
        "debit": total_debit,
        "credit": total_credit
    })
    
    # Check GL entries created
    gl_entries = frappe.get_all(
        "GL Entry",
        filters={"voucher_no": journal_entry.name},
        fields=["account", "debit", "credit"]
    )
    
    validation["checks"].append({
        "check": "gl_entries_created",
        "status": "passed" if len(gl_entries) > 0 else "failed",
        "gl_entries": len(gl_entries)
    })
    
    # Check account types
    for acc in journal_entry.accounts:
        account_type = frappe.db.get_value("Account", acc.account, "account_type")
        validation["checks"].append({
            "check": f"account_type_{acc.account}",
            "status": "passed",
            "account_type": account_type
        })
    
    return validation
```

### 7. HR Module Testing
```python
def test_hr_integration(site):
    """Test HR module integration"""
    
    hr_test = {
        "test_name": "hr_integration",
        "employee_lifecycle": [],
        "payroll": [],
        "attendance": [],
        "leave_management": []
    }
    
    # Test employee lifecycle
    employee_test = test_employee_lifecycle(site)
    hr_test["employee_lifecycle"] = employee_test
    
    # Test payroll processing
    payroll_test = test_payroll_processing(site)
    hr_test["payroll"] = payroll_test
    
    # Test attendance management
    attendance_test = test_attendance_management(site)
    hr_test["attendance"] = attendance_test
    
    # Test leave management
    leave_test = test_leave_management(site)
    hr_test["leave_management"] = leave_test
    
    # Test expense claims
    expense_test = test_expense_claims(site)
    hr_test["expense_claims"] = expense_test
    
    return hr_test

def test_payroll_processing(site):
    """Test complete payroll cycle"""
    
    payroll_test = {
        "test_name": "payroll_processing",
        "stages": []
    }
    
    # Create test employee
    employee = create_test_employee_with_salary_structure()
    payroll_test["stages"].append({
        "stage": "employee_setup",
        "status": "completed"
    })
    
    # Process salary slip
    salary_slip = process_salary_slip(employee)
    payroll_test["stages"].append({
        "stage": "salary_slip_generation",
        "document": salary_slip.name,
        "status": "completed"
    })
    
    # Validate calculations
    calculation_validation = validate_salary_calculations(salary_slip)
    payroll_test["stages"].append({
        "stage": "calculation_validation",
        "status": "passed" if calculation_validation["accurate"] else "failed",
        "details": calculation_validation
    })
    
    # Create journal entry
    journal_entry = create_salary_journal_entry(salary_slip)
    payroll_test["stages"].append({
        "stage": "journal_entry_creation",
        "document": journal_entry.name,
        "status": "completed"
    })
    
    return payroll_test
```

### 8. CRM Module Testing
```python
def test_crm_integration(site):
    """Test CRM module integration"""
    
    crm_test = {
        "test_name": "crm_integration",
        "lead_management": [],
        "opportunity_management": [],
        "customer_management": [],
        "campaign_management": []
    }
    
    # Test lead management
    lead_test = test_lead_management_flow(site)
    crm_test["lead_management"] = lead_test
    
    # Test opportunity pipeline
    opportunity_test = test_opportunity_pipeline(site)
    crm_test["opportunity_management"] = opportunity_test
    
    # Test customer communication
    communication_test = test_customer_communication(site)
    crm_test["customer_management"] = communication_test
    
    # Test campaign effectiveness
    campaign_test = test_campaign_management(site)
    crm_test["campaign_management"] = campaign_test
    
    return crm_test

def test_lead_management_flow(site):
    """Test lead management workflow"""
    
    lead_flow = {
        "test_name": "lead_management",
        "stages": []
    }
    
    # Create lead from web form
    lead = create_lead_from_web_form()
    lead_flow["stages"].append({
        "stage": "lead_creation",
        "document": lead.name,
        "source": "Web Form"
    })
    
    # Assign to sales person
    assignment = assign_lead_to_sales_person(lead)
    lead_flow["stages"].append({
        "stage": "lead_assignment",
        "assigned_to": assignment["sales_person"]
    })
    
    # Track communications
    communication = track_lead_communications(lead)
    lead_flow["stages"].append({
        "stage": "communication_tracking",
        "communications": len(communication)
    })
    
    # Convert to customer
    customer = convert_lead_to_customer(lead)
    lead_flow["stages"].append({
        "stage": "conversion",
        "customer": customer.name
    })
    
    return lead_flow
```

### 9. Project Management Testing
```python
def test_project_integration(site):
    """Test project management integration"""
    
    project_test = {
        "test_name": "project_integration",
        "project_creation": [],
        "task_management": [],
        "timesheet_integration": [],
        "billing_integration": []
    }
    
    # Create project from sales order
    project = create_project_from_sales_order()
    project_test["project_creation"].append({
        "project": project.name,
        "source": "Sales Order"
    })
    
    # Create and assign tasks
    tasks = create_project_tasks(project)
    project_test["task_management"] = tasks
    
    # Test timesheet integration
    timesheet = create_timesheet_for_project(project)
    project_test["timesheet_integration"].append({
        "timesheet": timesheet.name,
        "hours": timesheet.total_hours
    })
    
    # Test project billing
    billing = test_project_billing(project, timesheet)
    project_test["billing_integration"] = billing
    
    return project_test
```

### 10. Report Generation Testing
```python
def test_report_generation(site):
    """Test various ERPNext reports"""
    
    report_tests = {
        "financial_reports": [],
        "inventory_reports": [],
        "sales_reports": [],
        "purchase_reports": [],
        "hr_reports": []
    }
    
    # Financial Reports
    financial_reports = [
        "General Ledger",
        "Trial Balance",
        "Balance Sheet",
        "Profit and Loss Statement",
        "Cash Flow Statement",
        "Accounts Receivable",
        "Accounts Payable"
    ]
    
    for report_name in financial_reports:
        report_result = test_single_report(report_name, site)
        report_tests["financial_reports"].append(report_result)
    
    # Inventory Reports
    inventory_reports = [
        "Stock Balance",
        "Stock Ledger",
        "Stock Ageing",
        "Item-wise Sales Register",
        "Stock Projected Qty"
    ]
    
    for report_name in inventory_reports:
        report_result = test_single_report(report_name, site)
        report_tests["inventory_reports"].append(report_result)
    
    return report_tests

def test_single_report(report_name, site):
    """Test individual report generation"""
    
    report_test = {
        "report_name": report_name,
        "execution_time": 0,
        "record_count": 0,
        "status": "pending"
    }
    
    try:
        start_time = time.time()
        
        # Execute report
        result = frappe.get_doc("Report", report_name).execute(
            filters={},
            as_dict=True
        )
        
        execution_time = time.time() - start_time
        
        report_test["execution_time"] = execution_time
        report_test["record_count"] = len(result[1]) if result and len(result) > 1 else 0
        report_test["status"] = "passed"
        
        # Check execution time threshold
        if execution_time > 10:  # 10 seconds threshold
            report_test["performance_warning"] = "Report execution exceeded 10 seconds"
        
    except Exception as e:
        report_test["status"] = "failed"
        report_test["error"] = str(e)
    
    return report_test
```

### 11. Data Integrity Testing
```python
def test_data_integrity(site):
    """Test data integrity across ERPNext modules"""
    
    integrity_tests = {
        "referential_integrity": [],
        "data_consistency": [],
        "validation_rules": [],
        "constraints": []
    }
    
    # Test referential integrity
    ref_integrity = check_referential_integrity_all_modules(site)
    integrity_tests["referential_integrity"] = ref_integrity
    
    # Test data consistency
    consistency_checks = [
        check_account_balance_consistency(site),
        check_stock_balance_consistency(site),
        check_outstanding_amount_consistency(site),
        check_linked_document_consistency(site)
    ]
    integrity_tests["data_consistency"] = consistency_checks
    
    # Test validation rules
    validation_checks = test_all_validation_rules(site)
    integrity_tests["validation_rules"] = validation_checks
    
    # Test constraints
    constraint_checks = test_database_constraints(site)
    integrity_tests["constraints"] = constraint_checks
    
    return integrity_tests

def check_account_balance_consistency(site):
    """Check if account balances are consistent"""
    
    consistency_check = {
        "check_name": "account_balance_consistency",
        "discrepancies": []
    }
    
    # Get all GL entries grouped by account
    gl_balances = frappe.db.sql("""
        SELECT account, SUM(debit - credit) as balance
        FROM `tabGL Entry`
        WHERE is_cancelled = 0
        GROUP BY account
    """, as_dict=True)
    
    for entry in gl_balances:
        # Compare with account closing balance
        account_balance = get_account_balance(entry.account)
        
        if abs(entry.balance - account_balance) > 0.01:
            consistency_check["discrepancies"].append({
                "account": entry.account,
                "gl_balance": entry.balance,
                "account_balance": account_balance,
                "difference": entry.balance - account_balance
            })
    
    consistency_check["status"] = "failed" if consistency_check["discrepancies"] else "passed"
    
    return consistency_check
```

### 12. Test Result Analysis
```python
def analyze_integration_test_results(test_suite):
    """Analyze and generate comprehensive test report"""
    
    analysis = {
        "test_id": test_suite["test_id"],
        "summary": {},
        "module_analysis": {},
        "integration_analysis": {},
        "performance_metrics": {},
        "recommendations": []
    }
    
    # Generate summary
    total_tests = count_total_tests(test_suite)
    passed_tests = count_passed_tests(test_suite)
    failed_tests = count_failed_tests(test_suite)
    
    analysis["summary"] = {
        "total_tests": total_tests,
        "passed": passed_tests,
        "failed": failed_tests,
        "pass_rate": (passed_tests / total_tests * 100) if total_tests > 0 else 0,
        "execution_time": calculate_total_execution_time(test_suite)
    }
    
    # Analyze each module
    for module, results in test_suite["results"].items():
        analysis["module_analysis"][module] = analyze_module_results(results)
    
    # Analyze integration points
    analysis["integration_analysis"] = analyze_integration_points(test_suite["integration_tests"])
    
    # Performance metrics
    analysis["performance_metrics"] = extract_performance_metrics(test_suite)
    
    # Generate recommendations
    analysis["recommendations"] = generate_test_recommendations(analysis)
    
    return analysis

def generate_test_recommendations(analysis):
    """Generate recommendations based on test results"""
    
    recommendations = []
    
    # Check pass rate
    if analysis["summary"]["pass_rate"] < 80:
        recommendations.append({
            "priority": "high",
            "area": "overall",
            "recommendation": "Pass rate below 80%. Review failed tests and fix critical issues."
        })
    
    # Check module-specific issues
    for module, module_analysis in analysis["module_analysis"].items():
        if module_analysis.get("failed_tests", 0) > 0:
            recommendations.append({
                "priority": "medium",
                "area": module,
                "recommendation": f"Module {module} has failing tests. Review and fix."
            })
    
    # Check performance issues
    if analysis["performance_metrics"].get("slow_operations"):
        recommendations.append({
            "priority": "medium",
            "area": "performance",
            "recommendation": "Some operations are running slowly. Consider optimization."
        })
    
    # Check integration issues
    if analysis["integration_analysis"].get("failed_integrations"):
        recommendations.append({
            "priority": "high",
            "area": "integration",
            "recommendation": "Critical integration points are failing. Immediate attention required."
        })
    
    return recommendations
```

## Best Practices
1. **Test in isolated environment**
2. **Use realistic test data**
3. **Test all integration points**
4. **Verify data flow across modules**
5. **Check accounting entries**
6. **Validate business rules**
7. **Test error scenarios**
8. **Monitor performance during tests**
9. **Document test results**
10. **Regular regression testing**

## Integration Points
- **Testing Specialist**: Primary executor
- **ERPNext Architect**: Test design and analysis
- **Business Analyst**: Business scenario validation
- **QA Lead**: Test planning and reporting
- **Developer**: Bug fixing and optimization