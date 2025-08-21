# ERPNext Practical Development Guide

This guide provides hands-on examples for three common scenarios: building a new app from scratch, working in an existing app, and adding new features. Each example follows the BMAD Method for ERPNext.

## Table of Contents
1. [Building a New ERPNext App](#scenario-1-building-a-new-erpnext-app)
2. [Working in an Existing App](#scenario-2-working-in-an-existing-app)
3. [Adding a New Feature](#scenario-3-adding-a-new-feature)

---

## Scenario 1: Building a New ERPNext App

### Example: Building an Equipment Rental Management App

Let's build a complete equipment rental app for a construction company that needs to track equipment, rentals, maintenance, and customer contracts.

#### Phase 1: Planning (Web UI or Powerful IDE)

##### Step 1: Business Analysis (Optional but Recommended)

```bash
# Activate Business Analyst
@business-analyst

# Commands to run:
*analyze-business "Equipment rental company needs to track inventory, rentals, maintenance schedules, and customer contracts"
*identify-modules "Equipment management, rental contracts, maintenance tracking, customer portal"
*map-to-erpnext "Identify which ERPNext modules to extend or integrate"
```

**Output**: Business brief documenting:
- Equipment lifecycle management needs
- Rental contract workflows
- Maintenance scheduling requirements
- Integration with ERPNext Sales and Stock modules

##### Step 2: Create PRD with Architect

```bash
# Activate ERPNext Architect
@erpnext-architect

# If you have a brief:
*generate-prd --input "business-brief.md"

# If starting fresh (interactive):
*generate-prd

# The architect will ask:
# 1. What is the main purpose? "Equipment rental management"
# 2. Key features? "Equipment tracking, rental contracts, maintenance, billing"
# 3. User roles? "Rental Manager, Technician, Customer"
# 4. Integrations? "ERPNext Sales, Stock, Accounting"
```

**PRD Output Structure**:
```markdown
# Equipment Rental Management PRD

## Functional Requirements
- FR1: Equipment catalog with availability tracking
- FR2: Rental contract creation and management
- FR3: Automated maintenance scheduling
- FR4: Customer self-service portal

## Non-Functional Requirements
- NFR1: Handle 10,000+ equipment items
- NFR2: Real-time availability updates
- NFR3: Mobile-responsive interface

## DocTypes Required
1. Equipment Item (extends Item)
2. Rental Contract
3. Maintenance Schedule
4. Equipment Assignment

## APIs Required
- GET /api/equipment/availability
- POST /api/rental/create
- GET /api/maintenance/schedule
```

##### Step 3: Technical Architecture

```bash
# Continue with architect
*design-architecture --prd "docs/prd.md"

# Architecture will include:
# - DocType relationships diagram
# - API endpoint specifications
# - Workflow definitions
# - Integration points with ERPNext
```

**Architecture Output**:
```yaml
doctypes:
  equipment_item:
    extends: Item
    fields:
      - serial_no (Data, unique)
      - equipment_type (Link to Equipment Type)
      - current_status (Select: Available|Rented|Maintenance)
      - hourly_rate (Currency)
    
  rental_contract:
    fields:
      - customer (Link to Customer)
      - equipment_items (Table of Equipment Item)
      - start_date (Date)
      - end_date (Date)
      - total_amount (Currency, calculated)
    workflow: rental_approval_workflow

apis:
  equipment_availability:
    endpoint: /api/method/rental_management.api.get_availability
    method: GET
    params: [equipment_type, date_from, date_to]
    
integrations:
  erpnext_sales:
    - Create Sales Invoice from Rental Contract
  erpnext_stock:
    - Track equipment as stock items
```

##### Step 4: Early Test Strategy (Recommended)

```bash
# Activate Test Architect
@qa *risk --story "Equipment rental core functionality"
@qa *design --story "Equipment rental core functionality"

# Identifies risks:
# - Concurrent booking conflicts (Risk Score: 9)
# - Data integrity for equipment status (Risk Score: 6)
# - Performance with large equipment catalog (Risk Score: 6)
```

##### Step 5: Validate and Shard

```bash
# Activate Product Owner
@erpnext-product-owner

# Run validation
*execute-checklist-po

# Shard documents
*shard-doc "docs/prd.md" "docs/epics/"
*shard-doc "docs/architecture.md" "docs/stories/"
```

**Sharded Epics**:
- `epic-001-equipment-management.md`
- `epic-002-rental-contracts.md`
- `epic-003-maintenance-tracking.md`
- `epic-004-customer-portal.md`

#### Phase 2: Development (IDE)

##### Step 6: Create the App Structure

```bash
# In your frappe-bench directory
cd ~/frappe-bench

# Create new app
bench new-app rental_management

# Get app (if from repo)
# bench get-app https://github.com/yourcompany/rental_management

# Install on site
bench --site prima-erpnext.local install-app rental_management
```

##### Step 7: Implement First Story

```bash
# Activate Scrum Master
@erpnext-scrum-master

# Draft first story
*draft --epic "epic-001-equipment-management"

# Story Output: Create Equipment Item DocType
```

**Story: Create Equipment Item DocType**
```markdown
## Story: Equipment Item DocType Creation

### Acceptance Criteria
1. DocType extends Item with rental-specific fields
2. Tracks availability status in real-time
3. Calculates rental rates based on duration
4. Integrates with Stock module

### Tasks
1. Create DocType schema
2. Implement controller methods
3. Add permission rules
4. Create list and form views
5. Write tests
```

##### Step 8: Development Implementation

```bash
# Activate Development Coordinator
@development-coordinator

# Route the task
*route-task "Create Equipment Item DocType with rental fields"
# Output: "Routing to doctype-designer"

# Activate DocType Designer
@doctype-designer

# Create the DocType
*create-doctype "Equipment Item"
```

**Generated DocType Python Controller**:
```python
# rental_management/rental_management/doctype/equipment_item/equipment_item.py

import frappe
from frappe.model.document import Document

class EquipmentItem(Document):
    def validate(self):
        """Validate equipment item data"""
        self.validate_rental_rates()
        self.check_availability()
        
    def validate_rental_rates(self):
        """Ensure rental rates are properly set"""
        if self.hourly_rate <= 0:
            frappe.throw("Hourly rate must be greater than 0")
        
        if self.daily_rate < self.hourly_rate * 8:
            self.daily_rate = self.hourly_rate * 10  # Daily discount
            
    def check_availability(self):
        """Check if equipment is available for rental"""
        if self.current_status == "Rented":
            # Check active contracts
            contracts = frappe.get_all("Rental Contract",
                filters={
                    "equipment": self.name,
                    "status": "Active",
                    "end_date": [">=", frappe.utils.today()]
                })
            
            if not contracts and self.current_status == "Rented":
                self.current_status = "Available"
                
    @frappe.whitelist()
    def get_availability(self, from_date, to_date):
        """Check availability for date range"""
        # NEVER use raw SQL
        conflicts = frappe.get_all("Rental Contract",
            filters={
                "equipment": self.name,
                "start_date": ["<=", to_date],
                "end_date": [">=", from_date],
                "status": ["!=", "Cancelled"]
            })
        
        return len(conflicts) == 0
```

##### Step 9: Create API Endpoints

```bash
# Activate API Developer
@api-developer

# Create rental API
*create-api "Equipment availability checking and rental creation"
```

**Generated API**:
```python
# rental_management/api/rental.py

import frappe
from frappe import _

@frappe.whitelist()
def get_available_equipment(equipment_type=None, from_date=None, to_date=None):
    """Get available equipment for date range"""
    # ALWAYS check permissions
    if not frappe.has_permission("Equipment Item", "read"):
        frappe.throw(_("Insufficient permissions"), frappe.PermissionError)
    
    try:
        # Build filters
        filters = {"current_status": "Available"}
        if equipment_type:
            filters["equipment_type"] = equipment_type
        
        # Get all equipment
        equipment_list = frappe.get_all("Equipment Item",
            filters=filters,
            fields=["name", "equipment_name", "hourly_rate", "daily_rate"])
        
        # Check availability for date range
        available = []
        for item in equipment_list:
            doc = frappe.get_doc("Equipment Item", item.name)
            if doc.get_availability(from_date, to_date):
                available.append(item)
        
        return {
            "success": True,
            "data": available,
            "message": _("{0} items available").format(len(available))
        }
        
    except Exception as e:
        frappe.log_error(message=str(e), title="Equipment API Error")
        frappe.throw(_("Error fetching equipment: {0}").format(str(e)))

@frappe.whitelist()
def create_rental_contract(customer, equipment_items, start_date, end_date):
    """Create a new rental contract"""
    # Permission check
    if not frappe.has_permission("Rental Contract", "create"):
        frappe.throw(_("Cannot create rental contracts"), frappe.PermissionError)
    
    # Validate inputs
    if not customer or not equipment_items:
        frappe.throw(_("Customer and equipment items are required"))
    
    # Create contract using Frappe ORM
    contract = frappe.get_doc({
        "doctype": "Rental Contract",
        "customer": customer,
        "start_date": start_date,
        "end_date": end_date,
        "equipment_items": equipment_items,
        "status": "Draft"
    })
    
    contract.insert()
    
    # Use Frappe's background jobs for notifications
    frappe.enqueue(
        send_rental_confirmation,
        contract=contract.name,
        queue="short"
    )
    
    return {
        "success": True,
        "contract": contract.name,
        "message": _("Rental contract created successfully")
    }
```

##### Step 10: Add Vue Frontend (if needed)

```bash
# Activate Vue SPA Architect
@vue-spa-architect

# Create equipment dashboard
*create-spa "Equipment rental dashboard with availability calendar"
```

**Generated Vue Component** (`public/js/equipment_dashboard/EquipmentDashboard.vue`):
```vue
<template>
  <div class="equipment-dashboard">
    <div class="page-header">
      <h2>{{ __('Equipment Availability') }}</h2>
      <button 
        class="btn btn-primary"
        @click="showRentalDialog"
      >
        {{ __('New Rental') }}
      </button>
    </div>
    
    <div class="filters-section">
      <input 
        v-model="filters.search"
        type="text"
        class="form-control"
        :placeholder="__('Search equipment...')"
      />
      
      <select 
        v-model="filters.type"
        class="form-control"
      >
        <option value="">{{ __('All Types') }}</option>
        <option 
          v-for="type in equipmentTypes" 
          :key="type"
          :value="type"
        >
          {{ type }}
        </option>
      </select>
    </div>
    
    <div class="equipment-grid">
      <div 
        v-for="item in filteredEquipment"
        :key="item.name"
        class="equipment-card"
        :class="{ 'available': item.status === 'Available' }"
      >
        <h4>{{ item.equipment_name }}</h4>
        <p>{{ __('Status') }}: {{ __(item.status) }}</p>
        <p>{{ __('Daily Rate') }}: {{ format_currency(item.daily_rate) }}</p>
        <button 
          v-if="item.status === 'Available'"
          class="btn btn-sm btn-success"
          @click="rentEquipment(item)"
        >
          {{ __('Rent Now') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useStore } from './store'

// Access Frappe globals
const { __, format_currency } = window.frappe;

const store = useStore();
const equipment = ref([]);
const filters = ref({
  search: '',
  type: '',
  dateFrom: '',
  dateTo: ''
});

const filteredEquipment = computed(() => {
  return equipment.value.filter(item => {
    if (filters.value.search && 
        !item.equipment_name.toLowerCase().includes(filters.value.search.toLowerCase())) {
      return false;
    }
    if (filters.value.type && item.equipment_type !== filters.value.type) {
      return false;
    }
    return true;
  });
});

async function loadEquipment() {
  const response = await frappe.call({
    method: 'rental_management.api.rental.get_available_equipment',
    args: {
      from_date: filters.value.dateFrom,
      to_date: filters.value.dateTo
    }
  });
  
  if (response.message.success) {
    equipment.value = response.message.data;
  }
}

function rentEquipment(item) {
  const d = new frappe.ui.Dialog({
    title: __('Create Rental Contract'),
    fields: [
      {
        label: __('Customer'),
        fieldname: 'customer',
        fieldtype: 'Link',
        options: 'Customer',
        reqd: 1
      },
      {
        label: __('Start Date'),
        fieldname: 'start_date',
        fieldtype: 'Date',
        reqd: 1,
        default: frappe.datetime.get_today()
      },
      {
        label: __('End Date'),
        fieldname: 'end_date',
        fieldtype: 'Date',
        reqd: 1
      }
    ],
    primary_action_label: __('Create Contract'),
    primary_action(values) {
      createRentalContract(item, values);
      d.hide();
    }
  });
  
  d.show();
}

async function createRentalContract(equipment, details) {
  try {
    const response = await frappe.call({
      method: 'rental_management.api.rental.create_rental_contract',
      args: {
        customer: details.customer,
        equipment_items: [{
          equipment: equipment.name,
          rate: equipment.daily_rate
        }],
        start_date: details.start_date,
        end_date: details.end_date
      }
    });
    
    if (response.message.success) {
      frappe.show_alert({
        message: __('Rental contract created'),
        indicator: 'green'
      });
      
      // Refresh equipment list
      await loadEquipment();
    }
  } catch (error) {
    frappe.show_alert({
      message: __('Error creating contract'),
      indicator: 'red'
    });
  }
}

onMounted(() => {
  loadEquipment();
});
</script>

<style scoped>
.equipment-dashboard {
  padding: 20px;
}

.equipment-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.equipment-card {
  border: 1px solid #ddd;
  padding: 15px;
  border-radius: 8px;
  background: white;
}

.equipment-card.available {
  border-color: #28a745;
}

.filters-section {
  display: flex;
  gap: 10px;
  margin: 20px 0;
}
</style>
```

**Bundle Entry Point** (`public/js/equipment_dashboard.bundle.js`):
```javascript
import { createApp } from "vue";
import EquipmentDashboard from "./equipment_dashboard/EquipmentDashboard.vue";
import { createPinia } from "pinia";

class EquipmentDashboardPage {
  constructor(wrapper) {
    this.$wrapper = $(wrapper);
    this.page = wrapper.page;
    
    // Set page title
    this.page.set_title(__("Equipment Dashboard"));
    
    // Add page actions
    this.page.set_primary_action(__("Refresh"), () => {
      this.$component.loadEquipment();
    });
    
    // Create Vue app
    const app = createApp(EquipmentDashboard);
    
    // CRITICAL: Set Frappe globals
    SetVueGlobals(app);
    
    // Add Pinia store
    const pinia = createPinia();
    app.use(pinia);
    
    // Mount the app
    this.$component = app.mount(this.$wrapper.get(0));
  }
}

// Register with Frappe pages
frappe.pages["equipment-dashboard"] = EquipmentDashboardPage;
```

##### Step 11: Testing

```bash
# Activate Testing Specialist
@testing-specialist

# Create tests
*create-tests "Equipment Item DocType and rental APIs"
```

**Generated Test** (`rental_management/tests/test_equipment.py`):
```python
import frappe
from frappe.tests.utils import FrappeTestCase
from frappe.utils import today, add_days

class TestEquipmentItem(FrappeTestCase):
    def setUp(self):
        """Create test data"""
        # Create test equipment
        self.equipment = frappe.get_doc({
            "doctype": "Equipment Item",
            "equipment_name": "Test Excavator",
            "equipment_type": "Heavy Machinery",
            "hourly_rate": 100,
            "daily_rate": 800,
            "current_status": "Available"
        }).insert()
        
        # Create test customer
        self.customer = frappe.get_doc({
            "doctype": "Customer",
            "customer_name": "Test Customer",
            "customer_group": "Commercial"
        }).insert()
    
    def tearDown(self):
        """Clean up test data"""
        frappe.db.rollback()
    
    def test_equipment_creation(self):
        """Test equipment item creation"""
        self.assertTrue(self.equipment.name)
        self.assertEqual(self.equipment.current_status, "Available")
    
    def test_availability_check(self):
        """Test availability checking"""
        # Check availability for future dates
        is_available = self.equipment.get_availability(
            today(),
            add_days(today(), 7)
        )
        self.assertTrue(is_available)
        
        # Create a rental contract
        contract = frappe.get_doc({
            "doctype": "Rental Contract",
            "customer": self.customer.name,
            "equipment": self.equipment.name,
            "start_date": today(),
            "end_date": add_days(today(), 7),
            "status": "Active"
        }).insert()
        
        # Check availability again (should be false)
        is_available = self.equipment.get_availability(
            add_days(today(), 2),
            add_days(today(), 5)
        )
        self.assertFalse(is_available)
    
    def test_rental_rate_validation(self):
        """Test rental rate validations"""
        equipment = frappe.get_doc({
            "doctype": "Equipment Item",
            "equipment_name": "Test Item",
            "hourly_rate": -10  # Invalid rate
        })
        
        # Should throw error
        self.assertRaises(frappe.ValidationError, equipment.insert)
    
    def test_api_permissions(self):
        """Test API permission checks"""
        # Test as guest user (should fail)
        frappe.set_user("Guest")
        
        from rental_management.api.rental import get_available_equipment
        self.assertRaises(
            frappe.PermissionError,
            get_available_equipment
        )
        
        # Test as valid user
        frappe.set_user("Administrator")
        result = get_available_equipment()
        self.assertTrue(result["success"])
```

##### Step 12: Quality Review

```bash
# Activate Test Architect for review
@qa *review "Equipment rental core functionality"

# QA performs:
# - Requirements traceability check
# - Test coverage analysis
# - Code quality review
# - Security validation
# - Performance assessment

# Output: Quality gate decision (PASS/CONCERNS/FAIL)
```

##### Step 13: Deployment

```bash
# Build and deploy
bench build --app rental_management
bench --site prima-erpnext.local migrate
bench restart

# Run tests
bench --site prima-erpnext.local run-tests --app rental_management
```

---

## Scenario 2: Working in an Existing App

### Example: Adding Features to an Existing HR Customization App

You have an existing `hr_customizations` app and need to add employee skill tracking functionality.

#### Phase 1: Understanding Existing Code

```bash
# Activate Diagnostic Specialist
@diagnostic-specialist

# Analyze existing app structure
*analyze-app "hr_customizations"

# Output shows:
# - 5 existing DocTypes
# - 12 API endpoints
# - Custom fields on Employee
# - 2 workflows
```

#### Phase 2: Planning the Enhancement

```bash
# Activate Business Analyst
@business-analyst

# Analyze requirements within existing context
*analyze-enhancement "Add skill tracking to existing HR customizations app"

# Generates mini-PRD for the feature
```

**Mini-PRD for Skill Tracking**:
```markdown
## Feature: Employee Skill Tracking

### Requirements
- Track employee skills and proficiency levels
- Skill gap analysis
- Training recommendations
- Integration with existing Employee DocType

### DocTypes Needed
1. Skill Master (new)
2. Employee Skill (new child table)
3. Skill Assessment (new)

### Modifications to Existing
- Add skill_profile field to Employee
- Extend employee dashboard
```

#### Phase 3: Implementation in Existing App

##### Step 1: Add to Existing Employee DocType

```bash
# Activate DocType Designer
@doctype-designer

# Extend existing DocType
*extend-doctype "Employee" --app "hr_customizations"
```

**Custom Field Addition** (`hr_customizations/fixtures/custom_field.json`):
```json
[
  {
    "doctype": "Custom Field",
    "dt": "Employee",
    "fieldname": "skills_section",
    "fieldtype": "Section Break",
    "label": "Skills and Competencies",
    "insert_after": "personal_details"
  },
  {
    "doctype": "Custom Field",
    "dt": "Employee",
    "fieldname": "employee_skills",
    "fieldtype": "Table",
    "label": "Skills",
    "options": "Employee Skill",
    "insert_after": "skills_section"
  },
  {
    "doctype": "Custom Field",
    "dt": "Employee",
    "fieldname": "overall_skill_score",
    "fieldtype": "Float",
    "label": "Overall Skill Score",
    "read_only": 1,
    "insert_after": "employee_skills"
  }
]
```

##### Step 2: Create New DocTypes in Existing App

```python
# hr_customizations/hr_customizations/doctype/skill_master/skill_master.py

import frappe
from frappe.model.document import Document

class SkillMaster(Document):
    def validate(self):
        """Validate skill master"""
        self.validate_skill_category()
        self.check_duplicate_skill()
    
    def validate_skill_category(self):
        """Ensure valid category"""
        valid_categories = ["Technical", "Soft Skills", "Domain", "Tools"]
        if self.category not in valid_categories:
            frappe.throw(f"Category must be one of {valid_categories}")
    
    def check_duplicate_skill(self):
        """Check for duplicate skills"""
        exists = frappe.db.exists("Skill Master", {
            "skill_name": self.skill_name,
            "category": self.category,
            "name": ["!=", self.name]
        })
        
        if exists:
            frappe.throw(f"Skill {self.skill_name} already exists in {self.category}")
```

##### Step 3: Integrate with Existing APIs

```python
# hr_customizations/hr_customizations/api/employee_extensions.py
# ADD to existing API file

@frappe.whitelist()
def get_employee_skills(employee):
    """Get skills for an employee"""
    if not frappe.has_permission("Employee", "read", employee):
        frappe.throw("Insufficient permissions")
    
    # Get employee with skills
    doc = frappe.get_doc("Employee", employee)
    
    skills = []
    for skill in doc.employee_skills:
        skills.append({
            "skill": skill.skill,
            "proficiency": skill.proficiency_level,
            "years": skill.years_of_experience,
            "certified": skill.is_certified
        })
    
    return {
        "employee": doc.employee_name,
        "skills": skills,
        "overall_score": doc.overall_skill_score
    }

@frappe.whitelist()
def suggest_training(employee):
    """Suggest training based on skill gaps"""
    if not frappe.has_permission("Employee", "read"):
        frappe.throw("Insufficient permissions")
    
    # Get employee's current skills
    emp_skills = frappe.get_all("Employee Skill",
        filters={"parent": employee},
        fields=["skill", "proficiency_level"])
    
    # Get required skills for employee's designation
    designation = frappe.db.get_value("Employee", employee, "designation")
    required_skills = frappe.get_all("Designation Skill Requirement",
        filters={"designation": designation},
        fields=["skill", "required_level"])
    
    # Find gaps
    training_needed = []
    for req in required_skills:
        emp_skill = next((s for s in emp_skills if s.skill == req.skill), None)
        
        if not emp_skill or emp_skill.proficiency_level < req.required_level:
            training_needed.append({
                "skill": req.skill,
                "current_level": emp_skill.proficiency_level if emp_skill else 0,
                "required_level": req.required_level,
                "priority": "High" if not emp_skill else "Medium"
            })
    
    return {
        "employee": employee,
        "training_recommendations": training_needed
    }
```

##### Step 4: Extend Existing Frontend

```vue
<!-- Add to existing Employee Dashboard component -->
<!-- hr_customizations/public/js/employee_dashboard/SkillsTab.vue -->

<template>
  <div class="skills-tab">
    <div class="skills-header">
      <h3>{{ __('Employee Skills') }}</h3>
      <button 
        class="btn btn-primary btn-sm"
        @click="addSkill"
      >
        {{ __('Add Skill') }}
      </button>
    </div>
    
    <div class="skills-grid">
      <div 
        v-for="skill in employeeSkills"
        :key="skill.name"
        class="skill-card"
      >
        <div class="skill-name">{{ skill.skill }}</div>
        <div class="skill-level">
          <div class="progress">
            <div 
              class="progress-bar"
              :style="{width: skill.proficiency_level * 20 + '%'}"
            >
              {{ skill.proficiency_level }}/5
            </div>
          </div>
        </div>
        <div class="skill-meta">
          <span>{{ skill.years_of_experience }} {{ __('years') }}</span>
          <span v-if="skill.is_certified" class="badge badge-success">
            {{ __('Certified') }}
          </span>
        </div>
      </div>
    </div>
    
    <div v-if="trainingRecommendations.length" class="training-section">
      <h4>{{ __('Recommended Training') }}</h4>
      <ul>
        <li 
          v-for="training in trainingRecommendations"
          :key="training.skill"
        >
          <strong>{{ training.skill }}</strong> - 
          {{ __('Current') }}: {{ training.current_level }}/5,
          {{ __('Required') }}: {{ training.required_level }}/5
          <span :class="'badge badge-' + (training.priority === 'High' ? 'danger' : 'warning')">
            {{ training.priority }}
          </span>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const props = defineProps({
  employee: String
});

const employeeSkills = ref([]);
const trainingRecommendations = ref([]);

async function loadSkills() {
  const response = await frappe.call({
    method: 'hr_customizations.api.employee_extensions.get_employee_skills',
    args: { employee: props.employee }
  });
  
  if (response.message) {
    employeeSkills.value = response.message.skills;
  }
  
  // Load training recommendations
  const training = await frappe.call({
    method: 'hr_customizations.api.employee_extensions.suggest_training',
    args: { employee: props.employee }
  });
  
  if (training.message) {
    trainingRecommendations.value = training.message.training_recommendations;
  }
}

function addSkill() {
  // Open dialog to add new skill
  const d = new frappe.ui.Dialog({
    title: __('Add Skill'),
    fields: [
      {
        label: __('Skill'),
        fieldname: 'skill',
        fieldtype: 'Link',
        options: 'Skill Master',
        reqd: 1
      },
      {
        label: __('Proficiency Level'),
        fieldname: 'proficiency_level',
        fieldtype: 'Rating',
        reqd: 1
      },
      {
        label: __('Years of Experience'),
        fieldname: 'years_of_experience',
        fieldtype: 'Float',
        reqd: 1
      },
      {
        label: __('Certified'),
        fieldname: 'is_certified',
        fieldtype: 'Check'
      }
    ],
    primary_action_label: __('Add'),
    primary_action(values) {
      saveSkill(values);
      d.hide();
    }
  });
  
  d.show();
}

async function saveSkill(skillData) {
  // Get current employee doc
  const employee = await frappe.db.get_doc('Employee', props.employee);
  
  // Add new skill to the table
  if (!employee.employee_skills) {
    employee.employee_skills = [];
  }
  
  employee.employee_skills.push(skillData);
  
  // Save the employee doc
  await frappe.db.save_doc(employee);
  
  frappe.show_alert({
    message: __('Skill added successfully'),
    indicator: 'green'
  });
  
  // Reload skills
  await loadSkills();
}

onMounted(() => {
  loadSkills();
});
</script>
```

##### Step 5: Testing the Enhancement

```python
# hr_customizations/hr_customizations/tests/test_skills.py

import frappe
from frappe.tests.utils import FrappeTestCase

class TestEmployeeSkills(FrappeTestCase):
    def setUp(self):
        """Set up test data"""
        # Create skill master
        self.skill = frappe.get_doc({
            "doctype": "Skill Master",
            "skill_name": "Python Programming",
            "category": "Technical",
            "description": "Python development skills"
        }).insert()
        
        # Create employee with skills
        self.employee = frappe.get_doc({
            "doctype": "Employee",
            "first_name": "Test",
            "last_name": "Employee",
            "employee_skills": [{
                "skill": self.skill.name,
                "proficiency_level": 4,
                "years_of_experience": 3,
                "is_certified": 1
            }]
        }).insert()
    
    def test_skill_tracking(self):
        """Test skill tracking functionality"""
        # Test skill creation
        self.assertTrue(self.skill.name)
        
        # Test employee skills
        self.assertEqual(len(self.employee.employee_skills), 1)
        self.assertEqual(
            self.employee.employee_skills[0].proficiency_level, 
            4
        )
    
    def test_skill_gap_analysis(self):
        """Test training recommendations"""
        from hr_customizations.api.employee_extensions import suggest_training
        
        # Create designation requirement
        frappe.get_doc({
            "doctype": "Designation Skill Requirement",
            "designation": self.employee.designation,
            "skill": "JavaScript",
            "required_level": 3
        }).insert()
        
        # Get recommendations
        result = suggest_training(self.employee.name)
        
        self.assertTrue(result["training_recommendations"])
        self.assertEqual(
            result["training_recommendations"][0]["skill"],
            "JavaScript"
        )
```

---

## Scenario 3: Adding a New Feature

### Example: Adding Email Notification System to Rental App

Let's add automated email notifications to our equipment rental app when contracts are created, due, or expired.

#### Phase 1: Feature Planning

```bash
# Quick feature planning with Architect
@erpnext-architect

*design-feature "Add email notifications for rental contracts: creation, due reminders, expiration alerts"
```

**Feature Design Output**:
```markdown
## Email Notification Feature

### Components Needed
1. Email Template DocTypes
2. Notification Rules
3. Background Jobs for scheduling
4. Notification preferences per customer

### Implementation Plan
1. Create email templates
2. Add notification settings to Rental Contract
3. Implement notification sender
4. Schedule reminder jobs
5. Add customer preferences
```

#### Phase 2: Implementation

##### Step 1: Create Email Templates

```python
# rental_management/fixtures/email_template.json
[
  {
    "doctype": "Email Template",
    "name": "Rental Contract Created",
    "subject": "Rental Contract {{ doc.name }} Confirmed",
    "response": """
    <h3>Dear {{ doc.customer_name }},</h3>
    
    <p>Your equipment rental contract has been confirmed.</p>
    
    <table>
      <tr><td>Contract Number:</td><td>{{ doc.name }}</td></tr>
      <tr><td>Start Date:</td><td>{{ doc.start_date }}</td></tr>
      <tr><td>End Date:</td><td>{{ doc.end_date }}</td></tr>
      <tr><td>Total Amount:</td><td>{{ doc.total_amount }}</td></tr>
    </table>
    
    <h4>Equipment Details:</h4>
    <ul>
    {% for item in doc.equipment_items %}
      <li>{{ item.equipment_name }} - {{ item.daily_rate }}/day</li>
    {% endfor %}
    </ul>
    
    <p>Thank you for your business!</p>
    """
  },
  {
    "doctype": "Email Template",
    "name": "Rental Contract Due Reminder",
    "subject": "Reminder: Rental Contract {{ doc.name }} Due Soon",
    "response": """
    <h3>Dear {{ doc.customer_name }},</h3>
    
    <p>This is a reminder that your rental contract is due for return in {{ days_remaining }} days.</p>
    
    <p>Contract End Date: {{ doc.end_date }}</p>
    
    <p>Please ensure all equipment is returned by the due date to avoid additional charges.</p>
    """
  }
]
```

##### Step 2: Add Notification Module

```python
# rental_management/rental_management/notifications.py

import frappe
from frappe import _
from frappe.utils import add_days, date_diff, today, get_datetime

class RentalNotificationManager:
    """Handles all rental-related notifications"""
    
    @staticmethod
    def send_contract_created(contract_name):
        """Send email when contract is created"""
        contract = frappe.get_doc("Rental Contract", contract_name)
        
        # Use Frappe's email template system
        frappe.sendmail(
            recipients=[contract.customer_email],
            subject=_("Rental Contract {0} Confirmed").format(contract.name),
            template="Rental Contract Created",
            args={
                "doc": contract,
                "customer_name": contract.customer_name
            },
            delayed=False  # Send immediately
        )
        
        # Log the notification
        frappe.get_doc({
            "doctype": "Communication",
            "subject": f"Contract {contract.name} Created",
            "communication_type": "Communication",
            "sent_or_received": "Sent",
            "reference_doctype": "Rental Contract",
            "reference_name": contract.name
        }).insert(ignore_permissions=True)
        
        return True
    
    @staticmethod
    def send_due_reminders():
        """Send reminders for contracts due soon"""
        # Get contracts due in 3 days
        due_date = add_days(today(), 3)
        
        contracts = frappe.get_all("Rental Contract",
            filters={
                "end_date": due_date,
                "status": "Active",
                "reminder_sent": 0
            },
            fields=["name", "customer", "customer_email", "end_date"]
        )
        
        for contract in contracts:
            days_remaining = date_diff(contract.end_date, today())
            
            # Send reminder using Frappe's email system
            frappe.sendmail(
                recipients=[contract.customer_email],
                subject=_("Rental Due in {0} Days").format(days_remaining),
                template="Rental Contract Due Reminder",
                args={
                    "doc": contract,
                    "days_remaining": days_remaining
                }
            )
            
            # Mark reminder as sent
            frappe.db.set_value("Rental Contract", contract.name, 
                              "reminder_sent", 1)
        
        return f"Sent {len(contracts)} reminders"
    
    @staticmethod
    def check_expired_contracts():
        """Check and update expired contracts"""
        expired = frappe.get_all("Rental Contract",
            filters={
                "end_date": ["<", today()],
                "status": "Active"
            }
        )
        
        for contract in expired:
            doc = frappe.get_doc("Rental Contract", contract.name)
            doc.status = "Expired"
            doc.save()
            
            # Send expiration notice
            frappe.sendmail(
                recipients=[doc.customer_email],
                subject=_("Rental Contract {0} Expired").format(doc.name),
                message=_("Your rental contract has expired. Please return equipment immediately.")
            )
        
        return f"Processed {len(expired)} expired contracts"

@frappe.whitelist()
def send_test_notification(contract):
    """Test notification sending"""
    if not frappe.has_permission("Rental Contract", "write"):
        frappe.throw(_("Insufficient permissions"))
    
    manager = RentalNotificationManager()
    result = manager.send_contract_created(contract)
    
    return {
        "success": result,
        "message": _("Test notification sent")
    }
```

##### Step 3: Add Scheduled Jobs

```python
# rental_management/hooks.py
# ADD to scheduler_events

scheduler_events = {
    "daily": [
        "rental_management.rental_management.notifications.RentalNotificationManager.send_due_reminders",
        "rental_management.rental_management.notifications.RentalNotificationManager.check_expired_contracts"
    ],
    "all": [
        # Runs every 30 minutes
        "rental_management.tasks.check_contract_status"
    ]
}

# Document Events for automatic notifications
doc_events = {
    "Rental Contract": {
        "on_submit": "rental_management.rental_management.notifications.on_contract_submit",
        "on_update_after_submit": "rental_management.rental_management.notifications.on_contract_update"
    }
}
```

##### Step 4: Add Customer Preferences

```python
# Add to Customer DocType via custom fields
custom_fields = {
    "Customer": [
        {
            "fieldname": "notification_preferences",
            "label": "Notification Preferences",
            "fieldtype": "Section Break"
        },
        {
            "fieldname": "send_rental_notifications",
            "label": "Send Rental Notifications",
            "fieldtype": "Check",
            "default": 1
        },
        {
            "fieldname": "reminder_days",
            "label": "Send Reminder Days Before",
            "fieldtype": "Int",
            "default": 3
        },
        {
            "fieldname": "notification_email",
            "label": "Notification Email",
            "fieldtype": "Data",
            "options": "Email"
        }
    ]
}
```

##### Step 5: Update Contract DocType

```python
# rental_management/rental_management/doctype/rental_contract/rental_contract.py
# ADD notification handling

class RentalContract(Document):
    def on_submit(self):
        """Send notification on contract creation"""
        # Check customer preferences
        customer = frappe.get_doc("Customer", self.customer)
        
        if customer.send_rental_notifications:
            # Use Frappe's background job queue
            frappe.enqueue(
                "rental_management.notifications.RentalNotificationManager.send_contract_created",
                contract_name=self.name,
                queue="short",
                timeout=300
            )
            
            frappe.msgprint(_("Notification queued for sending"))
    
    def validate(self):
        """Validate contract data"""
        super().validate()
        self.calculate_total_amount()
        self.check_equipment_availability()
        
    def calculate_total_amount(self):
        """Calculate total rental amount"""
        from frappe.utils import date_diff
        
        days = date_diff(self.end_date, self.start_date) + 1
        total = 0
        
        for item in self.equipment_items:
            total += item.daily_rate * days
        
        self.total_amount = total
    
    @frappe.whitelist()
    def extend_contract(self, new_end_date):
        """Extend contract end date"""
        if not frappe.has_permission(self.doctype, "write", self.name):
            frappe.throw(_("Insufficient permissions"))
        
        old_end_date = self.end_date
        self.end_date = new_end_date
        self.calculate_total_amount()
        self.save()
        
        # Send notification about extension
        frappe.sendmail(
            recipients=[self.customer_email],
            subject=_("Contract Extended"),
            message=_("Your rental contract has been extended from {0} to {1}").format(
                old_end_date, new_end_date
            )
        )
        
        return {
            "success": True,
            "message": _("Contract extended successfully")
        }
```

##### Step 6: Add UI for Notification Management

```vue
<!-- rental_management/public/js/notification_settings/NotificationSettings.vue -->

<template>
  <div class="notification-settings">
    <h3>{{ __('Notification Settings') }}</h3>
    
    <div class="form-group">
      <label>
        <input 
          type="checkbox"
          v-model="settings.send_notifications"
          @change="saveSettings"
        />
        {{ __('Enable Email Notifications') }}
      </label>
    </div>
    
    <div v-if="settings.send_notifications" class="notification-options">
      <div class="form-group">
        <label>{{ __('Send Reminders') }}</label>
        <select 
          v-model="settings.reminder_days"
          class="form-control"
          @change="saveSettings"
        >
          <option value="1">1 day before</option>
          <option value="3">3 days before</option>
          <option value="7">1 week before</option>
        </select>
      </div>
      
      <div class="form-group">
        <label>{{ __('Notification Email') }}</label>
        <input 
          type="email"
          v-model="settings.notification_email"
          class="form-control"
          @blur="saveSettings"
        />
      </div>
      
      <div class="form-group">
        <h4>{{ __('Notification Types') }}</h4>
        <label v-for="type in notificationTypes" :key="type.name">
          <input 
            type="checkbox"
            v-model="settings[type.field]"
            @change="saveSettings"
          />
          {{ __(type.label) }}
        </label>
      </div>
    </div>
    
    <button 
      class="btn btn-primary"
      @click="sendTestNotification"
    >
      {{ __('Send Test Notification') }}
    </button>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const props = defineProps({
  customer: String
});

const settings = ref({
  send_notifications: true,
  reminder_days: 3,
  notification_email: '',
  notify_on_create: true,
  notify_on_due: true,
  notify_on_expire: true
});

const notificationTypes = [
  { name: 'create', field: 'notify_on_create', label: 'Contract Creation' },
  { name: 'due', field: 'notify_on_due', label: 'Due Reminders' },
  { name: 'expire', field: 'notify_on_expire', label: 'Expiration Alerts' }
];

async function loadSettings() {
  const customer = await frappe.db.get_doc('Customer', props.customer);
  
  settings.value = {
    send_notifications: customer.send_rental_notifications || false,
    reminder_days: customer.reminder_days || 3,
    notification_email: customer.notification_email || customer.email_id,
    notify_on_create: customer.notify_on_create !== 0,
    notify_on_due: customer.notify_on_due !== 0,
    notify_on_expire: customer.notify_on_expire !== 0
  };
}

async function saveSettings() {
  try {
    await frappe.db.set_value('Customer', props.customer, {
      send_rental_notifications: settings.value.send_notifications ? 1 : 0,
      reminder_days: settings.value.reminder_days,
      notification_email: settings.value.notification_email,
      notify_on_create: settings.value.notify_on_create ? 1 : 0,
      notify_on_due: settings.value.notify_on_due ? 1 : 0,
      notify_on_expire: settings.value.notify_on_expire ? 1 : 0
    });
    
    frappe.show_alert({
      message: __('Settings saved'),
      indicator: 'green'
    });
  } catch (error) {
    frappe.show_alert({
      message: __('Error saving settings'),
      indicator: 'red'
    });
  }
}

async function sendTestNotification() {
  // Get any active contract for this customer
  const contracts = await frappe.db.get_list('Rental Contract', {
    filters: {
      customer: props.customer,
      status: 'Active'
    },
    limit: 1
  });
  
  if (contracts.length === 0) {
    frappe.show_alert({
      message: __('No active contracts found'),
      indicator: 'orange'
    });
    return;
  }
  
  // Send test notification
  const response = await frappe.call({
    method: 'rental_management.notifications.send_test_notification',
    args: {
      contract: contracts[0].name
    }
  });
  
  if (response.message.success) {
    frappe.show_alert({
      message: __('Test notification sent'),
      indicator: 'green'
    });
  }
}

onMounted(() => {
  loadSettings();
});
</script>
```

##### Step 7: Testing the Feature

```python
# rental_management/tests/test_notifications.py

import frappe
from frappe.tests.utils import FrappeTestCase
from frappe.utils import today, add_days
from rental_management.rental_management.notifications import RentalNotificationManager

class TestNotifications(FrappeTestCase):
    def setUp(self):
        """Set up test data"""
        # Create customer with email
        self.customer = frappe.get_doc({
            "doctype": "Customer",
            "customer_name": "Test Customer",
            "email_id": "test@example.com",
            "send_rental_notifications": 1,
            "reminder_days": 3
        }).insert()
        
        # Create rental contract
        self.contract = frappe.get_doc({
            "doctype": "Rental Contract",
            "customer": self.customer.name,
            "customer_email": self.customer.email_id,
            "start_date": today(),
            "end_date": add_days(today(), 7),
            "status": "Active"
        }).insert()
    
    def test_notification_on_create(self):
        """Test notification sent on contract creation"""
        # Submit contract (triggers notification)
        self.contract.submit()
        
        # Check if communication was logged
        comm = frappe.get_all("Communication",
            filters={
                "reference_doctype": "Rental Contract",
                "reference_name": self.contract.name
            }
        )
        
        self.assertTrue(len(comm) > 0)
    
    def test_due_reminders(self):
        """Test due reminder functionality"""
        # Set contract to be due in 3 days
        self.contract.end_date = add_days(today(), 3)
        self.contract.save()
        
        # Run reminder function
        manager = RentalNotificationManager()
        result = manager.send_due_reminders()
        
        # Check if reminder was marked as sent
        self.contract.reload()
        self.assertEqual(self.contract.reminder_sent, 1)
    
    def test_expiration_check(self):
        """Test contract expiration handling"""
        # Set contract as expired
        self.contract.end_date = add_days(today(), -1)
        self.contract.save()
        
        # Run expiration check
        manager = RentalNotificationManager()
        result = manager.check_expired_contracts()
        
        # Check if status was updated
        self.contract.reload()
        self.assertEqual(self.contract.status, "Expired")
    
    def test_customer_preferences(self):
        """Test notification preferences"""
        # Disable notifications for customer
        self.customer.send_rental_notifications = 0
        self.customer.save()
        
        # Create new contract
        contract = frappe.get_doc({
            "doctype": "Rental Contract",
            "customer": self.customer.name,
            "start_date": today(),
            "end_date": add_days(today(), 5)
        }).insert()
        
        # Submit (should not send notification)
        contract.submit()
        
        # Check no communication was created
        comm = frappe.get_all("Communication",
            filters={
                "reference_doctype": "Rental Contract",
                "reference_name": contract.name
            }
        )
        
        self.assertEqual(len(comm), 0)
```

---

## Best Practices Summary

### For New Apps
1. **Start with Business Analysis** - Understand requirements thoroughly
2. **Create Comprehensive PRD** - Document all functional/non-functional requirements
3. **Design First, Code Second** - Architecture before implementation
4. **Use Test Architect Early** - Identify risks before coding
5. **Follow Frappe-First** - Never use external libraries when Frappe provides

### For Existing Apps
1. **Analyze First** - Understand existing code structure
2. **Extend, Don't Replace** - Build on existing functionality
3. **Maintain Compatibility** - Don't break existing features
4. **Test Thoroughly** - Include regression tests
5. **Document Changes** - Update existing documentation

### For New Features
1. **Mini-PRD for Features** - Even small features need planning
2. **Consider Integration Points** - How it fits with existing code
3. **Progressive Enhancement** - Add features incrementally
4. **Backwards Compatible** - Don't break existing workflows
5. **Test Edge Cases** - Features often break at boundaries

### Common Commands Reference

```bash
# Planning Phase
@business-analyst *analyze-business {description}
@erpnext-architect *generate-prd
@erpnext-architect *design-architecture
@qa *risk {story}
@qa *design {story}

# Development Phase
@erpnext-scrum-master *draft
@development-coordinator *route-task {task}
@doctype-designer *create-doctype {name}
@api-developer *create-api {description}
@vue-spa-architect *create-spa {description}

# Testing Phase
@testing-specialist *create-tests {description}
@qa *trace {story}
@qa *nfr {story}
@qa *review {story}

# Quality Gates
@qa *gate {story}

# Deployment
@bench-operator *deploy {app}
```

### Frappe-First Checklist

✅ **Always Use**:
- `frappe.get_doc()` instead of raw SQL
- `frappe.make_get_request()` instead of requests
- `frappe.enqueue()` instead of Celery
- `frappe.cache()` instead of Redis direct
- `@frappe.whitelist()` for all APIs
- `FrappeTestCase` for tests
- `frappe.throw()` for errors

❌ **Never Use**:
- `import requests`
- `import unittest`
- Raw SQL queries
- Direct Redis access
- Custom auth systems
- External PDF libraries
- Direct file operations

This practical guide provides concrete examples you can adapt for your specific ERPNext development needs. Remember to always follow the BMAD Method workflow and Frappe-first principles for maintainable, scalable applications.