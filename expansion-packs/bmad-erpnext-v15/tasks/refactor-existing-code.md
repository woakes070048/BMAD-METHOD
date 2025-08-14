# refactor-existing-code

**Task:** Improve existing code quality, performance, and maintainability through systematic refactoring

**Agent:** refactoring-expert  
**Category:** Code Quality & Optimization  
**Elicit:** true  
**Prerequisites:** Existing code that needs improvement  

## Overview

This task guides systematic refactoring of existing code to improve quality, performance, and maintainability while preserving functionality.

## Input Requirements

**Required:**
- Code files or modules to refactor
- Description of current issues or pain points
- Quality goals for the refactoring effort

**Optional:**
- Performance benchmarks or requirements
- Existing tests to validate functionality
- Code review feedback or quality metrics
- Legacy system constraints

## Process Steps

### Step 1: Code Assessment
1. **Analyze current code:**
   ```python
   # Identify code smells:
   # - Long functions (>20 lines)
   # - Large classes (>200 lines)  
   # - Deep nesting (>3 levels)
   # - Duplicated code blocks
   # - Magic numbers/strings
   # - Complex conditionals
   ```

2. **Measure quality metrics:**
   - Cyclomatic complexity
   - Lines of code per function/class
   - Code duplication percentage
   - Test coverage levels
   - Performance benchmarks

3. **Identify improvement opportunities:**
   - Code smell elimination
   - Performance bottlenecks
   - Maintainability issues
   - Reusability opportunities

### Step 2: Create Refactoring Plan
1. **Prioritize improvements by impact:**
   - **High impact:** Performance bottlenecks, critical bugs
   - **Medium impact:** Maintainability improvements, code smells
   - **Low impact:** Style consistency, minor optimizations

2. **Define refactoring phases:**
   ```yaml
   phase_1:
     goal: "Fix critical performance issues"
     tasks: ["Optimize database queries", "Remove N+1 problems"]
     success_criteria: ["Query time < 100ms", "API response < 200ms"]
   
   phase_2:
     goal: "Eliminate code duplication"
     tasks: ["Extract common utilities", "Create reusable components"]
     success_criteria: ["Duplication < 5%", "Utility usage tracked"]
   ```

3. **Identify risks and mitigations:**
   - Breaking existing functionality
   - Integration issues with other components
   - Performance regressions
   - Test coverage gaps

### Step 3: Apply DRY Principles
1. **Extract duplicated code:**
   ```python
   # Before: Duplicated validation logic
   def create_customer(data):
       if not data.get('name'):
           frappe.throw('Name is required')
       if not data.get('email'):
           frappe.throw('Email is required')
       # ... rest of logic
   
   def update_customer(name, data):
       if not data.get('name'):
           frappe.throw('Name is required')
       if not data.get('email'):  
           frappe.throw('Email is required')
       # ... rest of logic
   
   # After: Extract validation utility
   def validate_customer_data(data):
       required_fields = ['name', 'email']
       for field in required_fields:
           if not data.get(field):
               frappe.throw(f'{field.title()} is required')
   
   def create_customer(data):
       validate_customer_data(data)
       # ... rest of logic
   
   def update_customer(name, data):
       validate_customer_data(data)
       # ... rest of logic
   ```

2. **Create reusable components:**
   - Extract common UI components
   - Create utility functions for shared logic
   - Build configuration-driven solutions

3. **Implement inheritance or composition:**
   - Use base classes for shared behavior
   - Apply composition over inheritance where appropriate
   - Create mixins for cross-cutting concerns

### Step 4: Improve Code Structure
1. **Break down large functions:**
   ```python
   # Before: Long function doing too much
   def process_order(order_data):
       # 50+ lines of mixed logic
       pass
   
   # After: Smaller, focused functions
   def process_order(order_data):
       validate_order(order_data)
       items = prepare_order_items(order_data['items'])
       pricing = calculate_pricing(items, order_data['customer'])
       order = create_order_document(order_data, items, pricing)
       send_order_confirmation(order)
       return order
   ```

2. **Improve separation of concerns:**
   - Separate business logic from presentation
   - Extract data access into repositories
   - Create service layers for complex operations

3. **Apply SOLID principles:**
   - Single Responsibility: Each class/function has one job
   - Open/Closed: Open for extension, closed for modification
   - Liskov Substitution: Subtypes should be substitutable
   - Interface Segregation: Small, focused interfaces
   - Dependency Inversion: Depend on abstractions

### Step 5: Optimize Performance
1. **Database optimization:**
   ```python
   # Before: N+1 query problem
   orders = frappe.get_all("Sales Order")
   for order in orders:
       customer = frappe.get_doc("Customer", order.customer)
       # Process each customer...
   
   # After: Single query with joins
   orders = frappe.get_all("Sales Order", 
       fields=["name", "customer", "customer_name", "status"])
   # Or use batch loading if needed
   ```

2. **Caching strategies:**
   - Cache expensive calculations
   - Use Redis for session data
   - Implement query result caching

3. **Frontend optimization:**
   - Lazy loading of components
   - Bundle size reduction
   - API call optimization

### Step 6: Enhance Error Handling
1. **Implement consistent error patterns:**
   ```python
   # Before: Inconsistent error handling
   def get_customer_orders(customer):
       orders = frappe.db.get_all("Sales Order", {"customer": customer})
       if not orders:
           return []  # Silent failure
   
   # After: Explicit error handling
   def get_customer_orders(customer):
       if not customer:
           raise ValueError("Customer is required")
       
       try:
           orders = frappe.db.get_all("Sales Order", {"customer": customer})
           return orders or []
       except Exception as e:
           frappe.log_error(f"Failed to fetch orders for {customer}: {str(e)}")
           raise
   ```

2. **Add logging and monitoring:**
   - Log important operations
   - Add performance monitoring
   - Track error patterns

## Quality Checks During Refactoring

### Before Each Change:
- [ ] Create tests if they don't exist
- [ ] Document current behavior
- [ ] Benchmark performance if relevant

### After Each Change:
- [ ] Run existing tests
- [ ] Verify functionality unchanged
- [ ] Check performance impact
- [ ] Update documentation

### Code Quality Standards:
- [ ] Cyclomatic complexity < 10
- [ ] Function length < 20 lines
- [ ] No code duplication > 3 lines
- [ ] Consistent naming conventions
- [ ] Proper error handling

## Deliverables

### 1. Refactored Code
- Improved source code files
- New utility modules and components
- Updated configuration files
- Enhanced error handling

### 2. Quality Metrics Report
```yaml
refactoring_results:
  before:
    cyclomatic_complexity: 15
    code_duplication: "23%"
    average_function_length: 35
    test_coverage: "60%"
  
  after:
    cyclomatic_complexity: 8
    code_duplication: "4%"
    average_function_length: 18
    test_coverage: "85%"
  
  improvements:
    performance: "40% faster query execution"
    maintainability: "Reduced complexity by 47%"
    reusability: "Created 12 utility functions"
```

### 3. Documentation Updates
- Updated code comments
- Architecture documentation
- API documentation changes
- Developer guides

### 4. Testing Validation
- All existing tests pass
- New tests for refactored components
- Performance benchmarks
- Regression test results

## Success Criteria

1. **Functionality Preserved:** All existing features work as before
2. **Quality Improved:** Measurable improvements in code metrics
3. **Performance Enhanced:** Better response times where targeted
4. **Maintainability Increased:** Easier to understand and modify
5. **Test Coverage:** Adequate test coverage maintained or improved

## Common Refactoring Patterns

### Extract Method
```python
# Before
def calculate_total_with_tax(items):
    subtotal = 0
    for item in items:
        subtotal += item.quantity * item.rate
    tax = subtotal * 0.1
    return subtotal + tax

# After
def calculate_total_with_tax(items):
    subtotal = calculate_subtotal(items)
    tax = calculate_tax(subtotal)
    return subtotal + tax

def calculate_subtotal(items):
    return sum(item.quantity * item.rate for item in items)

def calculate_tax(subtotal, rate=0.1):
    return subtotal * rate
```

### Replace Magic Numbers
```python
# Before
if customer.credit_limit > 50000:
    apply_premium_discount()

# After
PREMIUM_CUSTOMER_THRESHOLD = 50000

if customer.credit_limit > PREMIUM_CUSTOMER_THRESHOLD:
    apply_premium_discount()
```

### Extract Configuration
```python
# Before
email_settings = {
    'smtp_host': 'smtp.gmail.com',
    'smtp_port': 587,
    'username': 'user@company.com'
}

# After
email_settings = frappe.get_single('Email Settings')
```

## Next Steps

After refactoring:
1. Deploy to staging environment
2. Run comprehensive testing
3. Monitor performance in production
4. Document lessons learned
5. Plan next refactoring iteration