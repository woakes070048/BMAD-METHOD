# Root Cause Analysis Methodologies Knowledge Base

## Overview
This knowledge base contains comprehensive information about various RCA methodologies, their applications, strengths, and best practices.

## 1. Five Whys Methodology

### Description
Iterative questioning technique developed by Sakichi Toyoda for Toyota Production System.

### When to Use
- Simple to moderate problems
- Single root cause suspected
- Limited time available
- Clear cause-effect relationships

### Strengths
- Simple and quick
- No special tools required
- Encourages deep thinking
- Good for team discussions

### Limitations
- May oversimplify complex problems
- Can lead to single cause fixation
- Dependent on knowledge of participants
- May miss systemic issues

### Best Practices
1. Start with specific problem statement
2. Base answers on facts, not assumptions
3. Validate each answer with data
4. Consider multiple paths
5. Stop when actionable root cause found
6. Test reversibility of cause

## 2. Fishbone (Ishikawa) Diagram

### Description
Visual cause-and-effect diagram organizing potential causes into categories.

### Standard Categories (6Ms)
- **Man** (People): Skills, training, motivation
- **Machine** (Equipment): Tools, technology, systems
- **Method** (Process): Procedures, workflows, standards
- **Material** (Inputs): Raw materials, information, supplies
- **Measurement**: Metrics, monitoring, calibration
- **Mother Nature** (Environment): External factors, conditions

### Alternative Categories (5Ps)
- **People**: Human factors
- **Processes**: Workflows and procedures
- **Policies**: Rules and guidelines
- **Programs**: Software and systems
- **Physical Environment**: Workspace and conditions

### When to Use
- Complex problems with multiple causes
- Team brainstorming sessions
- Need visual representation
- Categorical analysis required

### Best Practices
1. Clearly define the problem (fish head)
2. Use appropriate categories for context
3. Brainstorm without filtering initially
4. Validate causes with data
5. Prioritize using Pareto principle
6. Create sub-bones for detailed analysis

## 3. Fault Tree Analysis (FTA)

### Description
Deductive, top-down approach using Boolean logic to analyze failure paths.

### Logic Gates
- **AND Gate**: All inputs must occur
- **OR Gate**: Any input can occur
- **NOT Gate**: Inverse of input
- **XOR Gate**: Exclusive OR
- **Priority AND**: Inputs must occur in sequence
- **Inhibit Gate**: Input with condition

### Event Types
- **Top Event**: Undesired outcome
- **Basic Event**: Root cause needing no development
- **Undeveloped Event**: Insufficient information
- **External Event**: Outside system boundary
- **Conditioning Event**: Modifies gate logic

### Calculations
```
AND Gate: P(output) = ∏ P(inputs)
OR Gate: P(output) = 1 - ∏(1 - P(inputs))
```

### When to Use
- Safety-critical systems
- Reliability analysis needed
- Probability calculations required
- Complex failure modes
- Regulatory compliance

## 4. Pareto Analysis (80/20 Rule)

### Description
Statistical technique identifying vital few causes creating majority of impact.

### Principle
80% of effects come from 20% of causes (approximate ratio).

### Applications
- Defect prioritization
- Cost driver analysis
- Customer complaint analysis
- Time allocation
- Resource optimization

### Steps
1. Identify and list problems
2. Score/measure each problem
3. Sort by impact (descending)
4. Calculate cumulative percentage
5. Identify 80% threshold
6. Focus on vital few

### Variations
- **ABC Analysis**: A=70%, B=20%, C=10%
- **XYZ Analysis**: Demand variability
- **Multi-criteria Pareto**: Multiple dimensions

## 5. Failure Mode and Effects Analysis (FMEA)

### Description
Systematic approach identifying potential failure modes and their effects.

### Types
- **Design FMEA (DFMEA)**: Product design phase
- **Process FMEA (PFMEA)**: Manufacturing/service process
- **System FMEA (SFMEA)**: System level analysis

### Risk Priority Number (RPN)
```
RPN = Severity × Occurrence × Detection
```
- Severity: 1-10 (impact if occurs)
- Occurrence: 1-10 (likelihood)
- Detection: 1-10 (ability to detect)

### Action Priority
- RPN > 100: High priority
- RPN 50-100: Medium priority
- RPN < 50: Low priority

## 6. 8D Problem Solving

### Description
Eight disciplines methodology for team-based problem solving.

### The 8 Disciplines
1. **D0**: Plan and prepare
2. **D1**: Form team
3. **D2**: Define problem
4. **D3**: Interim containment
5. **D4**: Root cause analysis
6. **D5**: Permanent corrective action
7. **D6**: Implement and validate
8. **D7**: Prevent recurrence
9. **D8**: Recognize team

### When to Use
- Customer complaints
- Warranty issues
- Systematic problems
- Cross-functional issues
- Supplier problems

## 7. DMAIC (Six Sigma)

### Description
Data-driven improvement cycle for existing processes.

### Phases
1. **Define**: Problem, goals, customer requirements
2. **Measure**: Current performance, data collection
3. **Analyze**: Root causes, process analysis
4. **Improve**: Solutions, implementation
5. **Control**: Sustain improvements, monitoring

### Tools by Phase
- **Define**: Charter, SIPOC, VOC
- **Measure**: Data collection, MSA
- **Analyze**: Statistical analysis, hypothesis testing
- **Improve**: DOE, pilot testing
- **Control**: Control charts, SPC

## 8. A3 Problem Solving

### Description
Structured problem-solving approach on single A3-size paper.

### Sections
1. Background/Context
2. Current condition
3. Goal/Target condition
4. Root cause analysis
5. Countermeasures
6. Implementation plan
7. Follow-up actions

### Benefits
- Forces conciseness
- Visual communication
- Systematic thinking
- Documentation standard

## 9. Kepner-Tregoe (KT) Method

### Description
Systematic approach for problem solving and decision making.

### Four Processes
1. **Situation Appraisal**: Clarify situation
2. **Problem Analysis**: Find root cause
3. **Decision Analysis**: Make best choice
4. **Potential Problem Analysis**: Anticipate risks

### IS/IS NOT Analysis
| Aspect | IS | IS NOT | Distinction |
|--------|-----|---------|-------------|
| What | [Problem occurs] | [Doesn't occur] | [Difference] |
| Where | [Location] | [Other locations] | [Unique factor] |
| When | [Timing] | [Other times] | [Trigger] |
| Extent | [Magnitude] | [Other magnitudes] | [Threshold] |

## 10. Bow-Tie Analysis

### Description
Visual risk assessment combining fault tree (causes) and event tree (consequences).

### Structure
```
Threats → Barriers → TOP EVENT → Barriers → Consequences
(Preventive)                    (Mitigative)
```

### Components
- **Hazard**: Source of harm
- **Top Event**: Loss of control
- **Threats**: Causes of top event
- **Consequences**: Results of top event
- **Barriers**: Controls preventing/mitigating

## Selection Criteria Matrix

| Methodology | Complexity | Time | Team Size | Quantitative | Visual | Best For |
|------------|------------|------|-----------|--------------|--------|----------|
| 5 Whys | Low | Quick | 1-3 | No | No | Simple problems |
| Fishbone | Medium | Moderate | 3-8 | No | Yes | Brainstorming |
| FTA | High | Long | 2-5 | Yes | Yes | Safety analysis |
| Pareto | Low | Quick | 1-2 | Yes | Yes | Prioritization |
| FMEA | High | Long | 5-10 | Yes | No | Risk assessment |
| 8D | High | Long | 5-10 | Mixed | No | Customer issues |
| DMAIC | High | Very Long | 5-15 | Yes | Mixed | Process improvement |
| A3 | Medium | Moderate | 2-5 | Mixed | Yes | Communication |
| KT | Medium | Moderate | 3-6 | No | No | Complex problems |
| Bow-Tie | Medium | Moderate | 3-8 | No | Yes | Risk visualization |

## Combining Methodologies

### Complementary Pairs
1. **5 Whys + Fishbone**: Depth and breadth
2. **Pareto + FMEA**: Prioritize then analyze
3. **FTA + Bow-Tie**: Causes and consequences
4. **A3 + DMAIC**: Communication and rigor
5. **KT + 8D**: Analysis and implementation

### Sequential Application
1. Start with Pareto to prioritize
2. Use Fishbone for brainstorming
3. Apply 5 Whys for depth
4. Validate with data analysis
5. Document with A3
6. Implement with 8D

## Common Pitfalls

### General Pitfalls
1. Jumping to conclusions
2. Blaming individuals
3. Stopping at symptoms
4. Ignoring data
5. Single methodology fixation
6. Poor problem definition
7. Inadequate team composition
8. Lack of follow-through

### Mitigation Strategies
1. Use multiple methodologies
2. Validate with data
3. Include diverse perspectives
4. Document thoroughly
5. Test solutions before implementation
6. Monitor effectiveness
7. Create feedback loops
8. Institutionalize learning

## Industry-Specific Applications

### Manufacturing
- Primary: FMEA, 8D, DMAIC
- Secondary: 5 Whys, Fishbone

### Healthcare
- Primary: RCA2, Fishbone, FMEA
- Secondary: Bow-Tie, Swiss Cheese

### IT/Software
- Primary: 5 Whys, Fault Tree
- Secondary: Fishbone, KT

### Financial Services
- Primary: Bow-Tie, FMEA
- Secondary: Pareto, KT

### Aviation
- Primary: FTA, FMEA, Bow-Tie
- Secondary: 8D, Swiss Cheese

## Success Factors

### Critical Success Factors
1. Management support
2. Data availability
3. Team expertise
4. Time allocation
5. Clear problem definition
6. Systematic approach
7. Action implementation
8. Effectiveness monitoring

### Maturity Progression
1. **Level 1**: Reactive, ad-hoc
2. **Level 2**: Basic methodology use
3. **Level 3**: Systematic application
4. **Level 4**: Data-driven analysis
5. **Level 5**: Predictive prevention