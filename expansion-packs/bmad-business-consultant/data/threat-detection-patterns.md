# Threat Detection Patterns Knowledge Base

## Overview
Comprehensive patterns and indicators for identifying business threats across operational, financial, strategic, and cyber domains.

## 1. Financial Threat Patterns

### Revenue Decline Patterns
```
PATTERN: Accelerating Revenue Decline
Indicators:
- Month-over-month decline > 5% for 3+ months
- Increasing rate of decline each period
- Customer acquisition cost rising while conversions fall
- Sales pipeline shrinking > 20% quarter-over-quarter

Early Warning Signs:
- Lead quality scores dropping
- Sales cycle lengthening by > 15%
- Win rate declining > 10%
- Average deal size shrinking
```

### Cash Flow Crisis Patterns
```
PATTERN: Impending Cash Crunch
Indicators:
- Days Sales Outstanding (DSO) increasing > 10 days
- Accounts payable aging > 60 days
- Operating cash flow negative for 2+ months
- Quick ratio falling below 1.0

Early Warning (3-6 months ahead):
- Collections slowing by > 20%
- Customer payment delays increasing
- Inventory turnover declining
- Working capital ratio deteriorating
```

### Fraud Patterns
```
PATTERN: Internal Fraud Risk
Indicators:
- Unusual journal entries near period-end
- Override of controls increasing
- Missing documentation patterns
- Vendor/customer master data changes spike

Red Flags:
- Lifestyle changes in key personnel
- Resistance to job rotation
- Unusual working hours patterns
- Defensive behavior during audits
```

## 2. Operational Threat Patterns

### Supply Chain Disruption
```
PATTERN: Supply Chain Vulnerability
Indicators:
- Single source dependencies > 40%
- Supplier financial health declining
- Geopolitical risk in supplier regions
- Lead time variability increasing > 25%

Early Warnings:
- Supplier quality issues increasing
- Communication delays from suppliers
- Price increase requests accelerating
- Alternative supplier inquiries rising
```

### Quality Degradation
```
PATTERN: Systemic Quality Issues
Indicators:
- Defect rate trending up > 2% monthly
- Customer complaints increasing > 15%
- Rework costs rising > 10% quarterly
- First-pass yield declining

Precursors:
- Training hours per employee declining
- Preventive maintenance delays
- Process variation increasing
- Employee turnover in quality roles
```

### Capacity Constraints
```
PATTERN: Approaching Capacity Limits
Indicators:
- Utilization consistently > 85%
- Overtime hours increasing > 20%
- Delivery delays becoming frequent
- Maintenance deferrals increasing

Warning Signs (2-3 months ahead):
- Bottleneck resources at > 90% utilization
- Rush orders increasing
- Equipment downtime rising
- Employee fatigue indicators
```

## 3. Customer Threat Patterns

### Customer Churn Risk
```
PATTERN: Increasing Churn Probability
Indicators:
- Support ticket volume increasing > 30%
- Feature usage declining > 20%
- Login frequency dropping
- NPS scores falling below 7

Behavioral Precursors:
- Decreased engagement with communications
- Payment method failures
- Competitor research signals
- Contract renewal inquiries absent
```

### Market Share Erosion
```
PATTERN: Competitive Threat Materialization
Indicators:
- Win rate against competitor X falling > 15%
- Price pressure increasing in deals
- Customer acquisition cost rising > 25%
- Sales cycle lengthening against competitor

Market Signals:
- Competitor hiring in key roles
- Competitive product launches
- Industry analyst sentiment shifting
- Partner defections to competitors
```

## 4. Strategic Threat Patterns

### Disruption Vulnerability
```
PATTERN: Industry Disruption Risk
Indicators:
- New entrants with different business models
- Technology substitution accelerating
- Customer expectations shifting rapidly
- Traditional revenue streams declining

Early Indicators (12-18 months):
- VC investment in alternative solutions
- Patent filings in adjacent technologies
- Regulatory changes enabling new models
- Customer behavior shifts in adjacent markets
```

### Strategic Drift
```
PATTERN: Loss of Strategic Focus
Indicators:
- Initiative proliferation without closure
- Resource allocation fragmentation
- Conflicting priorities increasing
- Strategic metrics stagnating

Warning Signs:
- Executive turnover increasing
- Board meeting focus shifting
- Investment in core declining
- Innovation pipeline shrinking
```

## 5. Cybersecurity Threat Patterns

### Attack Precursors
```
PATTERN: Targeted Attack Preparation
Indicators:
- Reconnaissance activity on public sites
- Phishing attempts increasing
- Unusual network scanning
- Social engineering attempts

Technical Indicators:
- DNS queries to suspicious domains
- Unusual outbound traffic patterns
- Failed authentication attempts spike
- Privilege escalation attempts
```

### Data Breach Patterns
```
PATTERN: Ongoing Data Exfiltration
Indicators:
- Large data transfers at unusual times
- Access to sensitive data from new locations
- Database queries returning maximum rows
- Compression/encryption of large files

Behavioral Indicators:
- Access outside normal patterns
- Multiple system access by single user
- Dormant account reactivation
- VPN usage from unusual locations
```

## 6. Regulatory & Compliance Threats

### Compliance Violation Patterns
```
PATTERN: Systemic Compliance Failure
Indicators:
- Audit findings increasing
- Policy exceptions rising > 20%
- Training completion rates falling
- Documentation gaps widening

Risk Indicators:
- Regulatory changes not implemented
- Control testing failures
- Third-party compliance issues
- Whistleblower reports increasing
```

## 7. Human Capital Threats

### Talent Flight Risk
```
PATTERN: Mass Exodus Risk
Indicators:
- Turnover rate increasing > 2% quarterly
- Key talent departures accelerating
- Recruitment difficulty increasing
- Employee engagement scores falling

Early Warning Signs:
- LinkedIn profile updates surge
- Internal mobility requests increase
- Training investment requests decline
- Team morale indicators dropping
```

### Knowledge Loss Patterns
```
PATTERN: Critical Knowledge Drain
Indicators:
- Single points of expertise identified
- Documentation gaps in critical processes
- Retirement eligibility approaching
- Succession planning gaps

Risk Factors:
- Average tenure in critical roles < 2 years
- Knowledge transfer programs absent
- Cross-training metrics low
- Project handover issues recurring
```

## 8. Threat Correlation Matrix

### Multi-Domain Threat Indicators
```
COMPOUND THREAT: Financial + Operational
When Observed Together:
- Cash flow tightening + Capacity constraints
- Risk Level: CRITICAL
- Likely Outcome: Operational breakdown
- Response Time: 30 days

COMPOUND THREAT: Customer + Strategic
When Observed Together:
- Churn increasing + Strategic drift
- Risk Level: HIGH
- Likely Outcome: Market position loss
- Response Time: 90 days
```

## 9. Industry-Specific Threat Patterns

### Manufacturing
- Equipment failure patterns
- Supply chain bottlenecks
- Quality system breakdowns
- Safety incident precursors

### Retail
- Inventory shrinkage patterns
- Seasonal demand mismatches
- Store performance degradation
- E-commerce cannibalization

### Financial Services
- Credit risk concentration
- Liquidity stress patterns
- Regulatory breach indicators
- Cyber attack patterns

### Healthcare
- Patient safety indicators
- Regulatory compliance gaps
- Staffing crisis patterns
- Technology failure risks

### Technology
- Technical debt accumulation
- Platform stability degradation
- Security vulnerability patterns
- Innovation stagnation

## 10. Threat Detection Techniques

### Statistical Methods
1. **Control Charts**: Detect process variations
2. **Time Series Analysis**: Identify trends and seasonality
3. **Regression Analysis**: Find correlations
4. **Clustering**: Group similar threats
5. **Anomaly Detection**: Identify outliers

### Machine Learning Approaches
1. **Random Forests**: Multi-factor threat classification
2. **Neural Networks**: Complex pattern recognition
3. **SVM**: Binary threat classification
4. **LSTM**: Sequential pattern detection
5. **Autoencoders**: Anomaly detection

### Behavioral Analysis
1. **User Behavior Analytics**: Detect insider threats
2. **Entity Behavior Analytics**: System anomalies
3. **Network Traffic Analysis**: Communication patterns
4. **Transaction Monitoring**: Financial anomalies

## 11. Threat Velocity Classification

### Immediate Threats (0-7 days)
- System failures
- Cyber attacks
- Cash crises
- Regulatory deadlines

### Near-term Threats (1-4 weeks)
- Supply disruptions
- Quality issues
- Customer defections
- Competitive moves

### Medium-term Threats (1-3 months)
- Market shifts
- Talent exodus
- Technology obsolescence
- Partner failures

### Long-term Threats (3-12 months)
- Industry disruption
- Regulatory changes
- Economic cycles
- Climate impacts

## 12. Response Readiness Indicators

### High Readiness
- Response plans documented
- Teams trained and ready
- Resources allocated
- Communication plans clear
- Decision rights defined

### Low Readiness
- No documented procedures
- Unclear responsibilities
- Resource constraints
- Poor communication
- Slow decision-making

## 13. Threat Intelligence Sources

### Internal Sources
- ERP systems
- CRM databases
- Security logs
- Employee feedback
- Customer data
- Financial systems
- Operational metrics

### External Sources
- Industry reports
- Competitor intelligence
- Regulatory bulletins
- Economic indicators
- Social media
- News feeds
- Partner networks

## 14. Threat Scoring Framework

### Threat Score Calculation
```
Threat Score = (Probability × Impact × Velocity) / Preparedness

Where:
- Probability: 1-10 (likelihood)
- Impact: 1-10 (business impact)
- Velocity: 1-10 (speed of onset)
- Preparedness: 1-10 (readiness level)

Score Interpretation:
- > 50: Critical threat
- 25-50: High threat
- 10-25: Medium threat
- < 10: Low threat
```

## 15. Best Practices

### Detection Best Practices
1. Layer multiple detection methods
2. Maintain baseline metrics
3. Regular pattern updates
4. Cross-functional monitoring
5. Automated alerting
6. Regular threat hunting
7. Continuous improvement
8. Document patterns learned

### Common Mistakes
1. Single indicator reliance
2. Ignoring weak signals
3. Alert fatigue
4. Siloed monitoring
5. Reactive only approach
6. Poor documentation
7. No feedback loops
8. Technology-only focus