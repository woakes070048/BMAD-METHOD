# Troubleshooting Guide - BMAD Business Consultant

This guide addresses common issues, challenges, and questions that arise when using the BMAD Business Consultant expansion pack. Find solutions to typical problems and guidance for difficult situations.

## Common Template Usage Issues

### Assessment Phase Problems

#### Problem: Client Resistant to Providing Information
**Symptoms:**
- Client unwilling to share financial data
- Limited access to employees for interviews
- Vague or incomplete responses to assessment questions

**Solutions:**
1. **Build trust first**: Start with less sensitive questions, explain confidentiality
2. **Show value early**: Share initial insights to demonstrate expertise
3. **Use alternative data sources**: Industry reports, public information, observations
4. **Gradual approach**: Start with Quick Diagnostic, build up to full assessment

**Template Adaptations:**
- Use external benchmarks when internal data isn't available
- Focus on observational assessments over data-dependent analysis
- Employ ratio analysis with limited financial data
- Use qualitative assessments where quantitative data is missing

#### Problem: Overwhelming Amount of Information
**Symptoms:**
- Templates generating too much data to analyze effectively
- Analysis paralysis from too many findings
- Client overwhelmed by comprehensive assessment results

**Solutions:**
1. **Prioritize ruthlessly**: Focus on top 3-5 highest impact issues
2. **Use the 80/20 rule**: Identify the 20% of changes that will drive 80% of improvement
3. **Simplify presentation**: Create executive summary with key findings only
4. **Phase the analysis**: Complete assessment in phases, not all at once

**Template Adaptations:**
- Start with business-health-assessment-tmpl.yaml overview only
- Use quick-diagnostic-tools-tmpl.yaml for rapid triage
- Create simplified versions of complex templates
- Focus on financial impact and urgency for prioritization

#### Problem: Industry Templates Don't Fit
**Symptoms:**
- Client's business model doesn't match standard industry categories
- Hybrid business models (e.g., retail + service + e-commerce)
- Unique or niche industry characteristics

**Solutions:**
1. **Combine templates**: Use relevant sections from multiple industry templates
2. **Adapt existing templates**: Modify terminology and metrics for specific context
3. **Focus on functional areas**: Use process-specific templates regardless of industry
4. **Create custom variations**: Build hybrid templates for recurring business models

**Template Adaptations:**
- Use retail-business-toolkit-tmpl.yaml for physical operations
- Apply ecommerce-optimization-tmpl.yaml for online components
- Combine service-business-framework-tmpl.yaml for service elements
- Focus on process-mapping-tmpl.yaml for universal operational analysis

### Analysis Phase Problems

#### Problem: Benchmarking Data Not Available
**Symptoms:**
- Industry benchmarks are outdated or not applicable
- Business too small or unique for standard benchmarks
- Geographic market differences affect comparability

**Solutions:**
1. **Use proxy industries**: Find similar industries with available benchmarks
2. **Create local benchmarks**: Research local competitors and market conditions
3. **Use historical performance**: Compare against client's own historical data
4. **Focus on trends**: Analyze direction and rate of change rather than absolute values

**Template Adaptations:**
- Document benchmark limitations and assumptions
- Use ranges rather than specific benchmark targets
- Emphasize trend analysis over point-in-time comparisons
- Focus on internal efficiency metrics when external benchmarks aren't available

#### Problem: Financial Data Quality Issues
**Symptoms:**
- Incomplete or inconsistent financial statements
- Cash vs. accrual accounting inconsistencies
- Personal and business expenses mixed
- Seasonal businesses with irregular reporting

**Solutions:**
1. **Data normalization**: Adjust for accounting method differences
2. **Focus on cash flow**: Use cash-flow-analysis-tmpl.yaml when P&L is unreliable
3. **Ratio analysis**: Use ratios that are less sensitive to data quality issues
4. **Trend analysis**: Look at patterns over time rather than absolute numbers

**Template Adaptations:**
- Emphasize cash flow analysis over profit analysis
- Use operational metrics when financial metrics are unreliable
- Focus on customer and operational data for insights
- Document data quality limitations in analysis

#### Problem: Root Cause Analysis Stuck at Surface Level
**Symptoms:**
- Identifying symptoms but not underlying causes
- Multiple "root causes" that seem unrelated
- Client pushes back on deeper analysis

**Solutions:**
1. **Use structured techniques**: Apply 5 Whys consistently and systematically
2. **Multiple perspectives**: Interview different stakeholders for varying viewpoints
3. **Data triangulation**: Use multiple data sources to validate findings
4. **Fishbone diagrams**: Use cause-and-effect analysis for complex issues

**Template Techniques:**
- Apply root cause analysis section from comprehensive-rca.md task
- Use stakeholder-analysis.md to understand different perspectives
- Employ pattern-detection.md for identifying systemic issues
- Reference rca-methodologies.md for different analytical approaches

### Implementation Phase Problems

#### Problem: Client Lacks Resources for Implementation
**Symptoms:**
- Insufficient budget for recommended changes
- Limited staff time for implementation activities
- Lack of technical capabilities for system changes

**Solutions:**
1. **Phase implementation**: Break into smaller, affordable phases
2. **Identify quick wins**: Focus on low-cost, high-impact improvements first
3. **Build business case**: Use roi-calculator-tmpl.yaml to justify investment
4. **Alternative approaches**: Find lower-cost ways to achieve similar outcomes

**Template Adaptations:**
- Create "resource-constrained" versions of implementation plans
- Focus on process improvements over technology solutions
- Emphasize training and development over external resources
- Use implementation-roadmap-tmpl.yaml to create affordable phases

#### Problem: Organizational Resistance to Change
**Symptoms:**
- Employees resistant to new processes
- Management not fully committed to changes
- Stakeholders undermining implementation efforts

**Solutions:**
1. **Change management focus**: Use change-management-checklist.md extensively
2. **Stakeholder engagement**: Apply stakeholder-analysis.md for engagement planning
3. **Communication strategy**: Develop comprehensive communication plan
4. **Quick wins**: Demonstrate early value to build momentum

**Template Support:**
- Use change-management-checklist.md for systematic approach
- Apply stakeholder-analysis.md for resistance management
- Reference crisis-response-checklist.md if resistance is severe
- Use implementation-roadmap-tmpl.yaml change management sections

## Specific Template Issues

### Business Health Assessment Issues

#### Problem: Scoring Seems Inconsistent
**Symptoms:**
- Different team members score same factors differently
- Scores don't match overall business performance
- Client questions scoring methodology

**Solutions:**
1. **Calibration discussions**: Have team discuss scoring rationale
2. **Evidence-based scoring**: Require data support for scores
3. **Multiple raters**: Use average of multiple assessments
4. **Benchmark comparison**: Compare scores to similar businesses

#### Problem: Too Many Priority Areas Identified  
**Symptoms:**
- Assessment identifies 10+ priority areas
- Client overwhelmed by scope of issues
- Unclear where to start improvement efforts

**Solutions:**
1. **Impact vs. effort matrix**: Plot initiatives on 2x2 matrix
2. **Financial impact ranking**: Prioritize by revenue/profit impact
3. **Quick win identification**: Start with easy, visible improvements
4. **Client capacity assessment**: Match priorities to available resources

### Financial Analysis Issues

#### Problem: Cash Flow Analysis Shows Conflicting Results
**Symptoms:**
- Positive P&L but negative cash flow
- Seasonal patterns don't match business description
- Working capital changes seem unrealistic

**Solutions:**
1. **Reconciliation analysis**: Trace differences between P&L and cash flow
2. **Working capital deep dive**: Analyze receivables, payables, inventory changes
3. **Timing differences**: Account for accrual vs. cash basis differences
4. **Seasonal adjustment**: Normalize for seasonal working capital requirements

#### Problem: Break-Even Analysis Doesn't Match Reality
**Symptoms:**
- Calculated break-even point differs from actual experience
- Fixed vs. variable cost classification unclear
- Multiple products/services complicate analysis

**Solutions:**
1. **Cost behavior analysis**: Study actual cost patterns over time
2. **Activity-based classification**: Classify costs by activity drivers
3. **Segmented analysis**: Perform break-even analysis by product/service line
4. **Contribution margin focus**: Emphasize contribution analysis over simple break-even

### Industry Template Issues

#### Problem: Retail Metrics Don't Apply
**Symptoms:**
- Service-oriented retail doesn't fit traditional retail metrics
- B2B retail has different patterns than B2C
- Online/offline hybrid models create confusion

**Solutions:**
1. **Hybrid approach**: Combine retail and service templates
2. **Metric adaptation**: Modify metrics for specific retail model
3. **Custom calculations**: Create business-specific performance measures
4. **Focus on customer experience**: Emphasize universal customer metrics

#### Problem: Service Business Utilization Unclear
**Symptoms:**
- Difficulty defining "billable" vs. "non-billable" time
- Multiple service types with different characteristics
- Project-based vs. ongoing service confusion

**Solutions:**
1. **Time categorization**: Create clear definitions for time categories
2. **Service segmentation**: Analyze different service types separately
3. **Value-based metrics**: Focus on value delivery rather than just time
4. **Client outcome focus**: Measure client satisfaction and results

## Emergency Situations

### Crisis Response During Engagement

#### Problem: Client Business Faces Immediate Crisis
**Symptoms:**
- Cash flow crisis requiring immediate attention
- Major customer loss or competitive threat
- Operational crisis affecting business continuity

**Response Protocol:**
1. **Activate crisis-response-checklist.md**: Follow immediate response procedures
2. **Assess urgency**: Determine if consulting work should pause
3. **Redirect efforts**: Focus on crisis management and stabilization
4. **Document lessons**: Capture insights for future crisis prevention

#### Problem: Consulting Engagement Relationship Crisis
**Symptoms:**
- Client loses confidence in consultant
- Major disagreement about findings or recommendations
- Scope creep or payment issues

**Response Protocol:**
1. **Stop and assess**: Pause work to understand root cause
2. **Stakeholder meeting**: Bring all parties together for open discussion
3. **Reset expectations**: Clarify scope, timeline, and deliverables
4. **Recovery plan**: Develop specific steps to rebuild relationship

### Data and Analysis Emergencies

#### Problem: Discovered Major Error in Analysis
**Symptoms:**
- Calculation errors found after presentation
- Wrong benchmarks or data used
- Significant omissions discovered

**Response Protocol:**
1. **Immediate notification**: Contact client immediately about error
2. **Impact assessment**: Determine how error affects recommendations
3. **Corrected analysis**: Provide corrected version with explanation
4. **Process improvement**: Revise quality assurance procedures

#### Problem: Client Data Security Breach
**Symptoms:**
- Consultant system compromised with client data
- Accidental data sharing with wrong parties
- Loss of confidential client information

**Response Protocol:**
1. **Immediate containment**: Stop further data exposure
2. **Client notification**: Inform client within 24 hours
3. **Legal consultation**: Contact legal counsel for guidance
4. **Remediation plan**: Develop steps to prevent recurrence

## Quality Assurance Checklist

### Before Starting Any Template
- [ ] **Template relevance confirmed**: Matches client's business model and challenges
- [ ] **Data requirements understood**: Know what information will be needed
- [ ] **Timeline realistic**: Sufficient time allocated for thorough analysis
- [ ] **Client expectations set**: Clear understanding of process and outcomes

### During Template Usage
- [ ] **Data quality verified**: Information is accurate and current
- [ ] **Multiple sources used**: Triangulated information from various sources
- [ ] **Assumptions documented**: All assumptions clearly stated and justified
- [ ] **Stakeholder input gathered**: Multiple perspectives included in analysis

### After Completing Analysis
- [ ] **Findings validated**: Results make sense and pass sanity check
- [ ] **Benchmarks appropriate**: Comparisons are relevant and current
- [ ] **Recommendations feasible**: Solutions match client capabilities and resources
- [ ] **Success metrics defined**: Clear measures for tracking improvement

## Getting Additional Help

### When to Seek External Support
- **Complex industry regulations**: Specialized compliance requirements
- **Technical expertise gaps**: Areas outside your core competency
- **Large-scale implementations**: Projects requiring additional resources
- **Crisis situations**: Emergency situations requiring immediate expert help

### Resources for Continued Learning
- **Industry associations**: Sector-specific consulting groups
- **Professional development**: Advanced training in specialized areas
- **Peer networks**: Other consultants for advice and collaboration
- **Technology vendors**: Product training and implementation support

### Template Improvement and Feedback
- **Document modifications**: Keep track of template customizations that work
- **Share learnings**: Contribute improvements back to the BMAD community
- **Request enhancements**: Suggest new templates or features
- **Participate in updates**: Stay current with template improvements and additions

---

**Remember: When in doubt, return to first principles. Focus on understanding the client's business, identifying real problems, and developing practical solutions. The templates are tools to support your judgment, not replace it.**