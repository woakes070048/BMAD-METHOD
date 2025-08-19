# STAGE 3: Scrum Master Guide - Pete Lattimer

## Overview

This guide covers Stage 3 of the BMAD ERPNext v16 development process, led by **Pete Lattimer (erpnext-scrum-master)**. This stage focuses on agile planning, user story creation, and sprint management for ERPNext development.

## Agent Activation

```bash
/bmadErpNext:agent:erpnext-scrum-master
"Create ERPNext user stories and manage agile development"
```

## Stage Objectives

### Primary Goals
1. **Agile Planning**: Break down requirements into manageable user stories
2. **Sprint Planning**: Organize development work into iterative sprints
3. **Story Management**: Create well-defined, testable user stories
4. **Team Coordination**: Facilitate agile ceremonies and team collaboration

### Deliverables
- User Story Backlog
- Sprint Plans
- Acceptance Criteria
- Definition of Done
- Velocity Metrics
- Release Planning

## Key Activities

### 1. User Story Creation

**Commands:**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Create user stories for [ERPNext feature] based on these requirements: [requirements]"
```

**Story Creation Process:**
```bash
*task create-erpnext-story*
"Create user story for [specific functionality]"
```

**Story Templates:**
- `erpnext-story-template.yaml`
- `erpnext-epic-template.yaml`
- Epic breakdown templates

### 2. Backlog Management

**Commands:**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Prioritize and manage the ERPNext development backlog for [project name]"
```

**Backlog Activities:**
- Story prioritization
- Dependency identification
- Effort estimation
- Acceptance criteria definition

### 3. Sprint Planning

**Commands:**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Plan Sprint [number] for ERPNext development with team capacity of [hours]"
```

**Sprint Planning Elements:**
- Capacity planning
- Story selection
- Task breakdown
- Definition of done

### 4. Agile Ceremonies

**Daily Standups:**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Facilitate daily standup for ERPNext development team"
```

**Sprint Reviews:**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Conduct sprint review for completed ERPNext features"
```

**Retrospectives:**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Facilitate sprint retrospective focusing on ERPNext development process improvements"
```

## ERPNext-Specific Agile Practices

### Epic Structure for ERPNext

**Module-Based Epics:**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Create epic for ERPNext [module] implementation with these features: [list]"
```

**Integration Epics:**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Create epic for integrating ERPNext with [external system]"
```

**Migration Epics:**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Create epic for migrating data from [source system] to ERPNext"
```

### ERPNext User Story Patterns

**DocType Stories:**
```
As a [user role]
I want to [manage/create/view] [DocType]
So that I can [business benefit]
```

**Workflow Stories:**
```
As a [approver role]
I want to [approve/reject] [document type]
So that I can [maintain control/compliance]
```

**Report Stories:**
```
As a [manager role]
I want to view [report name]
So that I can [make decisions/track performance]
```

**Integration Stories:**
```
As a [system user]
I want ERPNext to sync with [external system]
So that I can [avoid double entry/maintain accuracy]
```

## Story Creation Framework

### User Story Template
```bash
*task create-erpnext-story*
```

**Required Elements:**
- User role (ERPNext user type)
- Functional requirement
- Business value
- Acceptance criteria
- ERPNext module context
- Dependencies

### Acceptance Criteria Framework

**Given-When-Then Format:**
```
Given [initial context/precondition]
When [action/event]
Then [expected outcome]
```

**ERPNext-Specific Criteria:**
- DocType field validation
- Workflow state changes
- Permission checks
- Integration points
- Performance requirements

### Definition of Done for ERPNext

**Development Complete:**
- [ ] DocType created/modified
- [ ] Server-side logic implemented
- [ ] Client-side functionality working
- [ ] Permissions configured
- [ ] Workflow states defined (if applicable)

**Testing Complete:**
- [ ] Unit tests written and passing
- [ ] Integration tests successful
- [ ] User acceptance testing completed
- [ ] Performance requirements met
- [ ] Security validation passed

**Documentation Complete:**
- [ ] User documentation updated
- [ ] Technical documentation complete
- [ ] Code comments added
- [ ] Change log updated

## Sprint Planning Process

### Sprint Planning Steps

1. **Capacity Calculation**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Calculate team capacity for Sprint [number] considering [team members] and [availability]"
```

2. **Story Selection**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Select stories for Sprint [number] based on priority and capacity"
```

3. **Task Breakdown**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Break down selected stories into development tasks for ERPNext implementation"
```

### ERPNext Development Tasks

**Common Task Types:**
- DocType creation/modification
- Server script development
- Client script implementation
- Workflow configuration
- Permission setup
- Report creation
- Integration development
- Testing and validation

## Estimation Techniques

### Story Point Estimation
- **1 Point**: Simple configuration change, minor DocType field addition
- **3 Points**: Standard DocType creation, basic workflow
- **5 Points**: Complex business logic, custom reports
- **8 Points**: Major integration, complex workflow
- **13 Points**: Large feature, multiple DocTypes, complex logic

### Planning Poker for ERPNext
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Facilitate planning poker session for ERPNext stories with development team"
```

## Release Planning

### Release Milestones

**MVP Release:**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Plan MVP release for ERPNext implementation including core functionality"
```

**Feature Releases:**
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Plan incremental feature releases for ERPNext enhancements"
```

### Release Dependencies
- ERPNext version compatibility
- Module dependencies
- Integration readiness
- Data migration completion
- User training requirements

## Risk Management

### Common ERPNext Risks
- Custom development complexity
- Integration challenges
- Data migration issues
- Performance concerns
- User adoption challenges

### Risk Mitigation Strategies
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Identify and create mitigation strategies for ERPNext development risks"
```

## Team Coordination

### Cross-Functional Team Management
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Coordinate ERPNext development team including developers, analysts, and testers"
```

### Stakeholder Communication
```bash
/bmadErpNext:agent:erpnext-scrum-master
"Facilitate communication between ERPNext development team and business stakeholders"
```

## Stage 3 Checklist

### Story Management
- [ ] All requirements converted to user stories
- [ ] Stories have clear acceptance criteria
- [ ] Story dependencies identified
- [ ] Effort estimation completed

### Sprint Planning
- [ ] Sprint goals defined
- [ ] Team capacity calculated
- [ ] Stories selected for sprints
- [ ] Task breakdown completed

### Process Setup
- [ ] Definition of done established
- [ ] Agile ceremonies scheduled
- [ ] Communication protocols defined
- [ ] Progress tracking mechanisms set up

### Documentation
- [ ] User story backlog documented
- [ ] Sprint plans created
- [ ] Acceptance criteria defined
- [ ] Release plan established

## Handoff to Stage 4

### Deliverables for Development Team
- Prioritized user story backlog
- Sprint plans with task breakdown
- Clear acceptance criteria
- Definition of done

### Handoff Command
```bash
/bmadErpNext:agent:main-dev-coordinator
"Ready to hand off Stage 3 Scrum Master deliverables to Development Team for Stage 4"
```

## Success Metrics

### Planning Quality
- Story completeness and clarity
- Accurate effort estimation
- Well-defined acceptance criteria
- Clear dependencies identified

### Team Performance
- Sprint velocity consistency
- Sprint goal achievement
- Team satisfaction scores
- Stakeholder satisfaction

## Tips for Success

1. **ERPNext Knowledge**: Understand ERPNext capabilities and limitations
2. **Incremental Delivery**: Plan for frequent, valuable releases
3. **Stakeholder Engagement**: Keep business users involved throughout
4. **Flexibility**: Adapt plans based on learning and feedback
5. **Quality Focus**: Never compromise on definition of done

## Tools and Templates

### Agile Tools
- User story tracking systems
- Sprint planning tools
- Burndown charts
- Velocity tracking

### ERPNext-Specific Templates
- `erpnext-story-template.yaml`
- `erpnext-epic-template.yaml`
- Sprint planning templates
- Acceptance criteria checklists

## Next Stage

Once Stage 3 is complete, proceed to [STAGE-4-DEVELOPER-GUIDE.md](STAGE-4-DEVELOPER-GUIDE.md) for technical implementation.

---

**Stage 3 Owner**: Pete Lattimer (erpnext-scrum-master)  
**Estimated Duration**: 1-2 weeks for initial setup, ongoing for sprint management  
**Key Focus**: Stories, Sprints, Agile Process