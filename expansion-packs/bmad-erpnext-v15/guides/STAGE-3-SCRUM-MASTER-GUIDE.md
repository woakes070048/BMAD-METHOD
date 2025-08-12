# Stage 3: Scrum Master Guide
## Creating Stories and Managing Tasks

### Role Overview

As a Scrum Master, you facilitate the transformation of epics into actionable user stories and ensure smooth sprint execution. You coordinate between the Business Analyst's epic definitions and the Development Team's implementation, managing the backlog, sprint planning, and daily execution.

### Key Responsibilities

1. **Story Creation**: Transform epics into detailed user stories
2. **Task Breakdown**: Decompose stories into development tasks
3. **Sprint Planning**: Organize and prioritize work for sprints
4. **Team Facilitation**: Remove blockers and enable productivity
5. **Progress Tracking**: Monitor and report on development progress

## 🚀 BMAD Commands for Scrum Masters

### Quick Start Commands

```bash
# 1. Activate the Scrum Master Agent
npx bmad-method activate:agent bmad-erpnext-v15 erpnext-scrum-master

# 2. Create stories from epics
npx bmad-method activate:agent bmad-erpnext-v15 erpnext-product-owner
*create-story    # Create individual stories from epic
*validate-story-draft story.md    # Validate story format

# 3. Review and validate stories
npx bmad-method run:task bmad-erpnext-v15 review-erpnext-story
npx bmad-method run:task bmad-erpnext-v15 validate-erpnext-story
```

### Command Reference for Each Step

#### Step 1: Epic Analysis & Story Creation
```bash
# Analyze epics from Business Analyst
npx bmad-method activate:agent bmad-erpnext-v15 erpnext-scrum-master
*analyze-epic epic-document.md
*identify-stories          # Extract story opportunities
*estimate-complexity      # Add story point estimates

# Create detailed stories
npx bmad-method activate:agent bmad-erpnext-v15 erpnext-product-owner
*create-story            # Create story using template
*validate-story-draft    # Validate story completeness
```

#### Step 2: Sprint Planning
```bash
# In Scrum Master agent mode:
*plan-sprint            # Organize stories into sprints
*assign-tasks           # Distribute work to team members
*track-dependencies     # Map story dependencies
*estimate-velocity      # Calculate team velocity
```

#### Step 3: Progress Tracking
```bash
# In Scrum Master agent mode:
*track-progress         # Monitor sprint progress
*identify-blockers      # Find and resolve impediments
*update-burndown       # Update sprint metrics
*facilitate-standup    # Daily standup facilitation
```

## Story Creation Process

### Step 1: Epic to Story Decomposition

#### 1.1 Story Identification Workshop

**Participants:**
- Business Analyst (Epic context)
- Development Team (Technical input)
- Product Owner (Priority guidance)
- QA Lead (Testing perspective)

**Workshop Agenda:**
```
1. Epic Review (30 min)
   - Business value recap
   - Technical architecture overview
   - Dependencies and risks

2. Story Brainstorming (60 min)
   - Identify user interactions
   - Map technical components
   - Define integration points

3. Story Refinement (45 min)
   - Write story statements
   - Define acceptance criteria
   - Estimate complexity

4. Sequencing (30 min)
   - Identify dependencies
   - Create story order
   - Define sprint allocation
```

#### 1.2 Story Writing Format

**Standard User Story Template:**
```
Title: [Verb] [Object] [Qualifier]

As a [persona/role]
I want [feature/capability]
So that [benefit/value]

Acceptance Criteria:
✓ Given [precondition]
  When [action]
  Then [expected result]

✓ Given [precondition]
  When [action]
  Then [expected result]
```

**ERPNext Story Example:**
```
Title: View Customer Order History

As a Customer Portal User
I want to view my past orders
So that I can track my purchase history and reorder items

Acceptance Criteria:
✓ Given I am logged into the portal
  When I navigate to "My Orders"
  Then I see a list of all my past orders

✓ Given I have orders in the system
  When I view the order list
  Then I see order date, total, status, and items

✓ Given I have more than 20 orders
  When I scroll to the bottom
  Then the next page loads automatically

✓ Given I click on an order
  When the detail view opens
  Then I can see all order line items and shipping details
```

### Step 2: Task Breakdown

#### 2.1 Task Categories for ERPNext Development

**Backend Tasks:**
```yaml
DocType Tasks:
  - Create DocType schema
  - Define field types and validations
  - Set up naming series
  - Configure permissions
  - Create list/form views

Controller Tasks:
  - Implement validate() method
  - Add before_save() hooks
  - Create after_insert() logic
  - Add custom methods
  - Implement workflow actions

API Tasks:
  - Create whitelisted methods
  - Implement REST endpoints
  - Add authentication checks
  - Include rate limiting
  - Handle error responses
```

**Frontend Tasks:**
```yaml
Vue.js Tasks:
  - Create component structure
  - Implement data binding
  - Add event handlers
  - Create computed properties
  - Implement watchers

Frappe UI Tasks:
  - Use Frappe controls
  - Implement form layouts
  - Add client scripts
  - Create print formats
  - Configure list views

Mobile Tasks:
  - Responsive design implementation
  - Touch interaction handlers
  - Offline capability
  - PWA manifest creation
  - Service worker setup
```

**Integration Tasks:**
```yaml
Workflow Tasks:
  - Define workflow states
  - Create transitions
  - Set up approvals
  - Configure notifications
  - Add validation rules

Automation Tasks:
  - Create webhook endpoints
  - Set up event triggers
  - Configure n8n workflows
  - Implement schedulers
  - Add background jobs
```

**Testing Tasks:**
```yaml
Unit Tests:
  - Test business logic
  - Validate calculations
  - Check permissions
  - Test API endpoints
  - Verify data integrity

Integration Tests:
  - Test workflow execution
  - Validate multi-DocType operations
  - Check third-party integrations
  - Test data synchronization
  - Verify email notifications

UI Tests:
  - Test form submissions
  - Validate field interactions
  - Check responsive behavior
  - Test error handling
  - Verify accessibility
```

#### 2.2 Task Definition Template

```markdown
## Task: [Task Title]

### Story Reference
Story: [Story Number and Title]
Acceptance Criteria: [Related AC numbers]

### Description
[Clear description of what needs to be done]

### Technical Specifications
- Component: [DocType/API/Frontend/etc.]
- Module: [ERPNext module]
- Dependencies: [Other tasks that must complete first]

### Implementation Details
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Definition of Done
- [ ] Code implemented and reviewed
- [ ] Unit tests written and passing
- [ ] Documentation updated
- [ ] Integration tested
- [ ] Code merged to develop branch

### Estimated Effort
- Development: [X hours]
- Testing: [Y hours]
- Total: [Z hours]

### Assigned To
Developer: [Name]
Reviewer: [Name]
```

### Step 3: Sprint Planning

#### 3.1 Sprint Planning Meeting

**Pre-Planning Preparation:**
```
1. Backlog Grooming
   - Review story readiness
   - Confirm acceptance criteria
   - Validate estimates
   - Check dependencies

2. Capacity Planning
   - Calculate team availability
   - Account for holidays/leave
   - Consider meetings/ceremonies
   - Factor in support work

3. Velocity Analysis
   - Review past 3 sprints
   - Calculate average velocity
   - Identify trends
   - Adjust for team changes
```

**Sprint Planning Agenda:**
```
Part 1: What (60 minutes)
- Sprint goal definition
- Story selection
- Dependency review
- Risk assessment

Part 2: How (90 minutes)
- Story breakdown into tasks
- Task estimation
- Task assignment
- Capacity validation
```

#### 3.2 Sprint Backlog Creation

**Sprint Backlog Structure:**
```
Sprint [Number]: [Sprint Goal]
Duration: [Start Date] - [End Date]
Capacity: [Total Hours Available]

Stories Committed:
├── Story 1.1: User Authentication
│   ├── Task: Create User DocType extension
│   ├── Task: Implement login controller
│   ├── Task: Build login Vue component
│   └── Task: Write authentication tests
│
├── Story 1.2: Dashboard View
│   ├── Task: Create dashboard layout
│   ├── Task: Implement data aggregation
│   ├── Task: Add chart components
│   └── Task: Optimize performance
│
└── Story 1.3: Profile Management
    ├── Task: Create profile form
    ├── Task: Add validation logic
    ├── Task: Implement save functionality
    └── Task: Test profile updates
```

### Step 4: Daily Scrum Management

#### 4.1 Daily Standup Format

**Standard Questions:**
1. What did you complete yesterday?
2. What will you work on today?
3. Are there any blockers?

**ERPNext-Specific Additions:**
4. Any framework limitations discovered?
5. Integration issues with other apps?
6. Performance concerns identified?

**Standup Board Updates:**
```
| To Do | In Progress | Review | Testing | Done |
|-------|-------------|--------|---------|------|
| Task  | Task →      |        |         |      |
| Task  |      Task → |        |         |      |
| Task  |             | Task → |         |      |
| Task  |             |        | Task →  |      |
|       |             |        |         | Task |
```

#### 4.2 Blocker Resolution

**Common ERPNext Blockers and Solutions:**

| Blocker Type | Example | Resolution Approach |
|--------------|---------|-------------------|
| Technical | Frappe version incompatibility | Coordinate with DevOps for upgrade |
| Dependency | Waiting for DocType from another team | Reprioritize or create mock |
| Knowledge | Unclear about framework pattern | Schedule knowledge transfer session |
| Integration | Third-party API unavailable | Implement fallback or mock service |
| Performance | Query taking too long | Engage DBA for optimization |
| Access | No permissions to production data | Request access through proper channels |

### Step 5: Progress Tracking and Reporting

#### 5.1 Sprint Metrics

**Key Metrics to Track:**
```yaml
Velocity Metrics:
  - Planned story points: 40
  - Completed story points: 35
  - Velocity trend: ↑ Improving

Quality Metrics:
  - Bugs found in sprint: 5
  - Bugs resolved: 7
  - Technical debt addressed: 2 items

Efficiency Metrics:
  - Planned vs actual hours: 85%
  - Rework percentage: 10%
  - Automation coverage: 75%

Team Health:
  - Attendance: 95%
  - Engagement score: 8/10
  - Knowledge sharing sessions: 2
```

#### 5.2 Burndown Chart Management

**Ideal vs Actual Burndown:**
```
Story Points
40 |*
35 |  *
30 |    *
25 |      *      (Ideal)
20 |        .*
15 |       .   *
10 |     .       *
5  |   .           *
0  |_________________*
   Day 1  3  5  7  9  10

* = Ideal Burndown
. = Actual Progress
```

**Burndown Analysis:**
- Ahead of schedule: Capacity for additional work
- On track: Continue current pace
- Behind schedule: Identify blockers, adjust scope

### Step 6: Sprint Review and Retrospective

#### 6.1 Sprint Review

**Demo Preparation Checklist:**
- [ ] Test all features in demo environment
- [ ] Prepare demo script
- [ ] Load sample data
- [ ] Test integrations
- [ ] Prepare fallback plan

**Review Meeting Structure:**
```
1. Sprint Goal Recap (5 min)
2. Completed Stories Demo (30 min)
3. Incomplete Items Review (10 min)
4. Stakeholder Feedback (15 min)
5. Next Sprint Preview (10 min)
```

#### 6.2 Sprint Retrospective

**Retrospective Techniques:**

**Start-Stop-Continue:**
- Start: What should we start doing?
- Stop: What should we stop doing?
- Continue: What's working well?

**4 L's:**
- Liked: What did you like?
- Learned: What did you learn?
- Lacked: What was missing?
- Longed for: What did you wish for?

**Action Items Template:**
```
Action: [Specific improvement action]
Owner: [Person responsible]
Due Date: [When to complete]
Success Metric: [How to measure]
```

## Best Practices

### DO's:
- ✅ Keep stories small and deliverable in one sprint
- ✅ Ensure clear acceptance criteria
- ✅ Include testing in task estimates
- ✅ Update board daily
- ✅ Celebrate achievements
- ✅ Address blockers immediately
- ✅ Maintain sustainable pace

### DON'Ts:
- ❌ Overcommit in sprint planning
- ❌ Skip daily standups
- ❌ Ignore technical debt
- ❌ Change sprint scope without discussion
- ❌ Blame individuals for issues
- ❌ Forget documentation tasks
- ❌ Neglect retrospective actions

## Story and Task Templates

### Story Template File
```yaml
story:
  number: "1.1"
  title: "User Login Implementation"
  epic: "1 - User Management"
  points: 8
  priority: "High"
  sprint: 3
  
  statement:
    as_a: "Portal User"
    i_want: "to securely log into the system"
    so_that: "I can access my personalized content"
  
  acceptance_criteria:
    - "User can enter email and password"
    - "System validates credentials"
    - "Successful login redirects to dashboard"
    - "Failed login shows error message"
    - "Session timeout after 30 minutes"
  
  tasks:
    - title: "Create login form"
      type: "Frontend"
      estimate: 4
      assigned: "Developer A"
    
    - title: "Implement authentication"
      type: "Backend"
      estimate: 6
      assigned: "Developer B"
    
    - title: "Add session management"
      type: "Backend"
      estimate: 3
      assigned: "Developer B"
    
    - title: "Write tests"
      type: "Testing"
      estimate: 3
      assigned: "QA Engineer"
```

### Task Board Configuration

**Jira/Azure DevOps Board Setup:**
```
Columns:
1. Backlog (All future work)
2. Sprint Backlog (Current sprint)
3. In Progress (Active development)
4. Code Review (Pending review)
5. Testing (QA validation)
6. Done (Completed in sprint)

Swimlanes:
- Urgent (Production issues)
- Stories (Feature work)
- Bugs (Defect fixes)
- Technical Debt (Improvements)
```

## Agile Ceremonies Schedule

### Two-Week Sprint Schedule

| Day | Time | Ceremony | Duration | Participants |
|-----|------|----------|----------|--------------|
| Mon Week 1 | 9:00 AM | Sprint Planning | 2 hours | Entire Team |
| Daily | 9:00 AM | Daily Standup | 15 min | Entire Team |
| Fri Week 1 | 3:00 PM | Backlog Grooming | 1 hour | SM, PO, Tech Lead |
| Thu Week 2 | 3:00 PM | Sprint Review | 1 hour | Team + Stakeholders |
| Fri Week 2 | 10:00 AM | Retrospective | 1.5 hours | Entire Team |

## Common Challenges and Solutions

### Challenge 1: Incomplete Stories
**Problem**: Stories regularly spill over to next sprint
**Solution**: Break stories smaller, improve estimation

### Challenge 2: Changing Requirements
**Problem**: Requirements change mid-sprint
**Solution**: Lock sprint scope, queue changes for next sprint

### Challenge 3: Technical Debt
**Problem**: Accumulating technical debt slows progress
**Solution**: Allocate 20% of sprint capacity to debt

### Challenge 4: Unclear Acceptance Criteria
**Problem**: Developers unsure when story is done
**Solution**: Review and clarify AC before sprint start

### Challenge 5: Dependencies
**Problem**: Blocked by external teams
**Solution**: Identify dependencies in planning, coordinate early

## Quality Checklist

### Story Ready Checklist
- [ ] User story statement complete
- [ ] Acceptance criteria defined
- [ ] Technical approach discussed
- [ ] Dependencies identified
- [ ] Estimate agreed
- [ ] Test approach defined

### Sprint Ready Checklist
- [ ] Sprint goal defined
- [ ] Stories prioritized
- [ ] Capacity calculated
- [ ] Tasks created
- [ ] Assignments made
- [ ] Board updated

### Story Done Checklist
- [ ] All AC met
- [ ] Code reviewed
- [ ] Tests passing
- [ ] Documentation updated
- [ ] Demo ready
- [ ] Deployed to staging

## Handoff to Developers

### Development Kickoff Package
1. **Story Documentation**
   - Complete story with AC
   - Technical specifications
   - Design mockups/wireframes
   - API contracts

2. **Task Assignments**
   - Clear task descriptions
   - Effort estimates
   - Dependencies marked
   - Due dates set

3. **Environment Setup**
   - Development environment ready
   - Test data available
   - Access permissions granted
   - Integration endpoints configured

4. **Support Structure**
   - Technical contact points
   - Business clarification process
   - Escalation path
   - Code review assignments

## 🎯 Complete Workflow Example

### Example: Sprint Planning for Customer Portal Epics

```bash
# Step 1: Receive epics from Business Analyst
# Review epic documents: user-account-management.md, order-self-service.md

# Step 2: Break epics into stories
npx bmad-method activate:agent bmad-erpnext-v15 erpnext-scrum-master
*analyze-epic user-account-management.md
*identify-stories
# Identifies: User Registration, Profile Management, Password Reset

# Create detailed stories
npx bmad-method activate:agent bmad-erpnext-v15 erpnext-product-owner
*create-story
# Story 1.1: User Registration
# Story 1.2: Profile Management
# Story 1.3: Password Reset

*create-story
# Story 2.1: View Order History
# Story 2.2: Track Shipments
# Story 2.3: Download Invoices

# Step 3: Validate stories
npx bmad-method run:task bmad-erpnext-v15 review-erpnext-story
npx bmad-method run:task bmad-erpnext-v15 validate-erpnext-story

# Step 4: Sprint planning
npx bmad-method activate:agent bmad-erpnext-v15 erpnext-scrum-master
*plan-sprint
# Sprint 1: Stories 1.1, 1.2 (User Account Foundation)
# Sprint 2: Stories 1.3, 2.1 (Extended Features)
# Sprint 3: Stories 2.2, 2.3 (Order Management)

*assign-tasks
# Assign specific developers to stories
# Map dependencies between tasks

*estimate-velocity
# Calculate team capacity and timeline

# Step 5: Hand off to development team
*track-progress    # Set up progress tracking
*exit
```

### Ready for Development ✅

Your stories are now ready for the development team with clear tasks, assignments, and sprint plans.

## Next Steps

After sprint planning:
1. **Conduct Development Kickoff**
2. **Set up Daily Standups**
3. **Monitor Progress Daily**
4. **Address Blockers Immediately**
5. **Prepare for Sprint Review**

### 💻 Next Stage Command
```bash
# Move to Stage 4 - Development
# Hand off your sprint plan to the Development Team
# They will use various agents like:
# npx bmad-method activate:agent bmad-erpnext-v15 doctype-designer
# npx bmad-method activate:agent bmad-erpnext-v15 api-developer
# npx bmad-method activate:agent bmad-erpnext-v15 vue-frontend-architect
```

## Resources

- [Agile Manifesto](https://agilemanifesto.org)
- [Scrum Guide](https://scrumguides.org)
- [Story Writing Workshop](./workshops/story-writing.md)
- [Estimation Techniques](./references/estimation.md)
- [ERPNext Sprint Templates](./templates/sprint-templates.md)

---

*Remember: The Scrum Master is a servant leader. Your role is to enable the team's success, not to manage them. Focus on removing obstacles and facilitating communication.*