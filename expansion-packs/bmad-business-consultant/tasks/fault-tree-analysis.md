# Fault Tree Analysis (FTA) Task

## Task Description
Conduct a systematic Fault Tree Analysis to identify all possible failure paths leading to an undesired event using Boolean logic and probability calculations.

## Input Parameters
- **top_event**: The undesired event or failure to analyze (required)
- **context**: System or process context (required)
- **historical_data**: Historical failure data and probabilities (required)
- **analysis_depth**: How many levels deep to analyze (default: 5)

## Execution Instructions

### Step 1: Define Top Event
```
TOP EVENT DEFINITION
====================
Event: [Clear description of the undesired event]
System/Process: [Where this occurs]
Frequency: [Historical occurrence rate]
Impact: [Business impact when it occurs]
Current Probability: [Estimated probability]
Target Probability: [Desired reduction goal]
```

### Step 2: Build Fault Tree Structure

#### Level 1: Immediate Causes
```
TOP EVENT: [Undesired Event]
    |
    ├─[OR/AND Gate]
    |
    ├── CAUSE 1A: [Description]
    │   Type: [Basic Event/Intermediate Event]
    │   Probability: [X%]
    │   Evidence: [Historical data]
    │
    ├── CAUSE 1B: [Description]
    │   Type: [Basic Event/Intermediate Event]
    │   Probability: [Y%]
    │   Evidence: [Historical data]
    │
    └── CAUSE 1C: [Description]
        Type: [Basic Event/Intermediate Event]
        Probability: [Z%]
        Evidence: [Historical data]
```

#### Level 2: Secondary Causes
```
CAUSE 1A: [Intermediate Event]
    |
    ├─[AND Gate] (All must occur)
    |
    ├── CAUSE 2A1: [Description]
    │   Type: Basic Event
    │   Probability: [X%]
    │   Failure Rate: [λ = X failures/time]
    │
    └── CAUSE 2A2: [Description]
        Type: Basic Event
        Probability: [Y%]
        Failure Rate: [λ = Y failures/time]

CAUSE 1B: [Intermediate Event]
    |
    ├─[OR Gate] (Any can occur)
    |
    ├── CAUSE 2B1: [Description]
    │   Type: Basic Event
    │   Probability: [X%]
    │
    ├── CAUSE 2B2: [Description]
    │   Type: Basic Event
    │   Probability: [Y%]
    │
    └── CAUSE 2B3: [Description]
        Type: Undeveloped Event
        Probability: [Estimated]
```

#### Level 3: Tertiary Causes
```
Continue decomposition until reaching:
- Basic Events (root causes that need no further development)
- Undeveloped Events (insufficient data to develop further)
- External Events (outside system boundaries)
```

### Step 3: Gate Logic Definition

#### AND Gates (All inputs must occur)
```
AND GATE: [Gate Name]
Inputs: [List of input events]
Logic: Output occurs IF Input1 AND Input2 AND ... InputN
Probability: P(output) = P(input1) × P(input2) × ... × P(inputN)

Example:
System Failure (AND)
├── Power Loss (P=0.01)
├── Backup Generator Fails (P=0.05)
└── UPS Depleted (P=0.10)
P(System Failure) = 0.01 × 0.05 × 0.10 = 0.00005 (0.005%)
```

#### OR Gates (Any input can occur)
```
OR GATE: [Gate Name]
Inputs: [List of input events]
Logic: Output occurs IF Input1 OR Input2 OR ... InputN
Probability: P(output) = 1 - [(1-P(input1)) × (1-P(input2)) × ... × (1-P(inputN))]

Example:
Data Loss (OR)
├── Hardware Failure (P=0.02)
├── Software Corruption (P=0.03)
└── Human Error (P=0.05)
P(Data Loss) = 1 - [(1-0.02) × (1-0.03) × (1-0.05)]
P(Data Loss) = 1 - [0.98 × 0.97 × 0.95] = 0.0969 (9.69%)
```

### Step 4: Probability Calculations

#### Minimal Cut Sets (MCS)
Identify all minimal combinations that cause top event:
```
MINIMAL CUT SET 1: {Event A, Event B}
Probability: P(A) × P(B) = [Calculate]
Criticality: [High/Medium/Low]

MINIMAL CUT SET 2: {Event C}
Probability: P(C) = [Value]
Criticality: [High/Medium/Low]

MINIMAL CUT SET 3: {Event D, Event E, Event F}
Probability: P(D) × P(E) × P(F) = [Calculate]
Criticality: [High/Medium/Low]
```

#### Path Probability Ranking
```
CRITICAL PATHS (Ranked by Probability)
1. Path: A → B → Top Event
   Probability: [X%]
   Components: [List]
   
2. Path: C → D → E → Top Event
   Probability: [Y%]
   Components: [List]
   
3. Path: F → Top Event
   Probability: [Z%]
   Components: [List]
```

### Step 5: Importance Measures

#### Fussell-Vesely Importance
```
Component: [Name]
FV Importance = P(Top Event with component failed) / P(Top Event)
Value: [Calculate]
Interpretation: [Contribution to system unreliability]
```

#### Risk Achievement Worth
```
Component: [Name]
RAW = P(Top Event | Component Failed) / P(Top Event)
Value: [Calculate]
Interpretation: [Importance for preventing top event]
```

#### Risk Reduction Worth
```
Component: [Name]
RRW = P(Top Event) / P(Top Event | Component Perfect)
Value: [Calculate]
Interpretation: [Maximum improvement possible]
```

### Step 6: Common Cause Analysis

#### Common Cause Failures
```
COMMON CAUSE GROUP 1
Affected Components: [List]
Common Cause: [Description]
Beta Factor: [β value]
Combined Probability: [Calculate]

COMMON CAUSE GROUP 2
Affected Components: [List]
Common Cause: [Description]
Beta Factor: [β value]
Combined Probability: [Calculate]
```

### Step 7: Sensitivity Analysis

#### Parameter Sensitivity
```
PARAMETER: [Component failure rate]
Baseline Value: [X]
Range Tested: [Min - Max]
Impact on Top Event:
- At Min: P(Top) = [Y%]
- At Baseline: P(Top) = [Z%]
- At Max: P(Top) = [W%]
Sensitivity: [High/Medium/Low]
```

### Step 8: Risk Mitigation Strategies

#### Mitigation by Cut Set
```
CUT SET 1 MITIGATION
Current Probability: [X%]
Mitigation Options:
1. Reduce P(Event A) by [method]
   - New P(Event A): [Y%]
   - New Cut Set Probability: [Z%]
   - Cost: $[Amount]
   - ROI: [Calculate]

2. Add redundancy to prevent Event B
   - Implementation: [Description]
   - New Cut Set Probability: [W%]
   - Cost: $[Amount]
   - ROI: [Calculate]
```

## Output Format

### Fault Tree Analysis Report
```
FAULT TREE ANALYSIS REPORT
==========================

Top Event: [Description]
Analysis Date: [Date]
System/Process: [Name]

QUANTITATIVE RESULTS
-------------------
Top Event Probability: [X%]
Mean Time Between Failures: [MTBF]
Reliability at Time T: R(t) = [Calculate]

CRITICAL FAILURE PATHS
---------------------
1. [Path Description] - Probability: [X%]
2. [Path Description] - Probability: [Y%]
3. [Path Description] - Probability: [Z%]

MINIMAL CUT SETS
---------------
Order 1 (Single Points of Failure):
- [Component]: P = [X%]

Order 2 (Dual Failures):
- {[Component A], [Component B]}: P = [Y%]

Order 3+ (Multiple Failures):
- {[A], [B], [C]}: P = [Z%]

COMPONENT IMPORTANCE RANKING
---------------------------
1. [Component] - FV: [X], RAW: [Y], RRW: [Z]
2. [Component] - FV: [X], RAW: [Y], RRW: [Z]
3. [Component] - FV: [X], RAW: [Y], RRW: [Z]

COMMON CAUSE VULNERABILITIES
---------------------------
1. [Common Cause] affecting [Components]
2. [Common Cause] affecting [Components]

RECOMMENDATIONS
--------------
Priority 1 (Single Points of Failure):
- Add redundancy to [Component]
- Expected risk reduction: [X%]

Priority 2 (High Probability Paths):
- Improve reliability of [Component]
- Expected risk reduction: [Y%]

Priority 3 (Common Cause Mitigation):
- Implement [Strategy]
- Expected risk reduction: [Z%]

VISUAL FAULT TREE
----------------
[Include ASCII diagram or reference to visual]
```

## Calculations Reference

### Basic Probability Formulas
```
AND Gate: P = P₁ × P₂ × ... × Pₙ
OR Gate: P = 1 - ∏(1 - Pᵢ)
Reliability: R(t) = e^(-λt)
Availability: A = MTBF / (MTBF + MTTR)
```

### Quality Criteria
- Complete decomposition to basic events
- Accurate probability assignments
- Proper gate logic application
- All cut sets identified
- Importance measures calculated
- Common causes analyzed
- Mitigation strategies provided

## Common Symbols
- ⊓ : AND gate (all inputs required)
- ⊔ : OR gate (any input sufficient)
- ○ : Basic event (root cause)
- ◇ : Undeveloped event
- ⌂ : External event
- □ : Intermediate event

## Integration Points
- Complements: FMEA Analysis
- Feeds into: Risk Assessment
- Informs: Reliability Engineering
- Supports: Safety Analysis
- Validates: Design Decisions