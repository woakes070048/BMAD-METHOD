# BMAD Business Consultant Deployment Guide

## Overview

This guide provides comprehensive instructions for deploying and configuring the BMAD Business Consultant expansion pack within your BMAD-METHOD environment.

## Prerequisites

### System Requirements
- BMAD-METHOD Core v4.0+
- ERPNext v15+ (for integration features)
- Python 3.8+
- Node.js 16+
- Redis 6.0+
- PostgreSQL 12+ or MySQL 8.0+
- Minimum 8GB RAM
- 20GB available storage

### Required Permissions
- Admin access to BMAD-METHOD
- ERPNext API access (if using integration)
- Network access for webhook endpoints
- File system write permissions

## Installation Steps

### 1. Download and Extract Package

```bash
# Navigate to expansion packs directory
cd /path/to/bmad-method/expansion-packs

# Clone or download the business consultant package
git clone https://github.com/bmad-method/bmad-business-consultant.git

# Or extract from archive
tar -xzf bmad-business-consultant-v1.0.0.tar.gz
```

### 2. Install Dependencies

```bash
# Navigate to package directory
cd bmad-business-consultant

# Install Python dependencies
pip install -r requirements.txt

# Install Node.js dependencies (if applicable)
npm install

# Install system dependencies
sudo apt-get install -y redis-server postgresql-client
```

### 3. Configure Environment Variables

Create a `.env` file in the package root:

```env
# Core Configuration
BMAD_ENV=production
BMAD_LOG_LEVEL=INFO
BMAD_API_PORT=8080

# ERPNext Integration
ERPNEXT_URL=https://your-erpnext-instance.com
ERPNEXT_API_KEY=your-api-key-here
ERPNEXT_API_SECRET=your-api-secret-here

# Database Configuration
DB_TYPE=postgresql
DB_HOST=localhost
DB_PORT=5432
DB_NAME=bmad_consultant
DB_USER=bmad_user
DB_PASSWORD=secure_password

# Redis Configuration
REDIS_URL=redis://localhost:6379/0
REDIS_PASSWORD=redis_password

# Security
JWT_SECRET=your-jwt-secret-key
ENCRYPTION_KEY=your-encryption-key
WEBHOOK_SECRET=your-webhook-secret

# Feature Flags
ENABLE_ERPNEXT_INTEGRATION=true
ENABLE_ANALYTICS=true
ENABLE_WEBHOOKS=true
ENABLE_CACHING=true
```

### 4. Database Setup

```sql
-- Create database
CREATE DATABASE bmad_consultant;

-- Create user
CREATE USER bmad_user WITH PASSWORD 'secure_password';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE bmad_consultant TO bmad_user;

-- Run migrations
python manage.py migrate
```

### 5. Initialize Agents

```bash
# Load agent configurations
python scripts/load_agents.py

# Verify agent loading
python scripts/verify_agents.py

# Expected output:
# ✓ Strategic Growth Advisor - Loaded
# ✓ Financial Performance Analyst - Loaded
# ✓ Operations Excellence Expert - Loaded
# ... (all agents listed)
```

### 6. Configure ERPNext Integration (Optional)

```bash
# Test ERPNext connection
python scripts/test_erpnext_connection.py

# Setup custom fields in ERPNext
python scripts/setup_erpnext_fields.py

# Configure webhooks
python scripts/configure_webhooks.py
```

## Configuration

### Agent Configuration

Each agent can be customized via YAML configuration files:

```yaml
# agents/custom-config.yaml
agent_overrides:
  strategic-growth-advisor:
    max_context_length: 8000
    response_timeout: 60
    custom_prompts:
      analysis: "Focus on digital transformation opportunities"
    
  financial-performance-analyst:
    data_refresh_interval: 3600
    calculation_precision: 4
    currency: USD
```

### Workflow Configuration

Customize workflows for your organization:

```yaml
# workflows/custom-workflow.yaml
workflow_name: Custom Assessment Process
activation: manual
agents:
  - strategic-growth-advisor
  - financial-performance-analyst
phases:
  - name: Initial Assessment
    duration: 2 weeks
    deliverables:
      - Current state analysis
      - Opportunity identification
```

### Team Configuration

Configure agent teams for specific use cases:

```yaml
# teams/custom-team.yaml
team_name: Rapid Assessment Team
agents:
  - strategic-growth-advisor
  - operations-excellence-expert
coordination:
  meeting_frequency: daily
  decision_model: consensus
```

## Deployment Options

### Option 1: Standalone Deployment

```bash
# Start the service
python app.py --port 8080 --workers 4

# Or use the startup script
./scripts/start_consultant.sh

# Verify deployment
curl http://localhost:8080/health
```

### Option 2: Docker Deployment

```bash
# Build the Docker image
docker build -t bmad-business-consultant:latest .

# Run the container
docker run -d \
  --name bmad-consultant \
  -p 8080:8080 \
  -v $(pwd)/config:/app/config \
  -v $(pwd)/logs:/app/logs \
  --env-file .env \
  bmad-business-consultant:latest

# Check container status
docker ps | grep bmad-consultant
```

### Option 3: Kubernetes Deployment

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bmad-consultant
spec:
  replicas: 3
  selector:
    matchLabels:
      app: bmad-consultant
  template:
    metadata:
      labels:
        app: bmad-consultant
    spec:
      containers:
      - name: consultant
        image: bmad-business-consultant:latest
        ports:
        - containerPort: 8080
        env:
        - name: BMAD_ENV
          value: "production"
```

Apply the deployment:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

## Integration Setup

### ERPNext Integration

1. **API Configuration**
```python
# config/erpnext_config.py
ERPNEXT_CONFIG = {
    'base_url': os.environ['ERPNEXT_URL'],
    'api_key': os.environ['ERPNEXT_API_KEY'],
    'api_secret': os.environ['ERPNEXT_API_SECRET'],
    'timeout': 30,
    'retry_attempts': 3
}
```

2. **Webhook Setup**
```bash
# Register webhooks with ERPNext
python scripts/register_webhooks.py

# Webhook endpoints will be created for:
# - Customer events
# - Employee events
# - Work Order events
# - Project events
```

3. **Data Synchronization**
```bash
# Initial data sync
python scripts/initial_sync.py --modules all

# Schedule periodic sync
crontab -e
# Add: */15 * * * * /usr/bin/python /path/to/sync_data.py
```

### Analytics Integration

1. **Configure Analytics Database**
```sql
-- Create analytics schema
CREATE SCHEMA analytics;

-- Create aggregation tables
CREATE TABLE analytics.daily_metrics (
    date DATE,
    metric_name VARCHAR(100),
    metric_value DECIMAL(10,2)
);
```

2. **Setup Reporting**
```bash
# Initialize reporting tables
python scripts/init_analytics.py

# Schedule report generation
python scripts/schedule_reports.py
```

## Testing

### Unit Tests
```bash
# Run all unit tests
pytest tests/unit/

# Run specific test suite
pytest tests/unit/test_agents.py

# Run with coverage
pytest --cov=bmad_consultant tests/unit/
```

### Integration Tests
```bash
# Test ERPNext integration
pytest tests/integration/test_erpnext.py

# Test agent workflows
pytest tests/integration/test_workflows.py

# Test team coordination
pytest tests/integration/test_teams.py
```

### Performance Tests
```bash
# Run load tests
locust -f tests/performance/locustfile.py --host=http://localhost:8080

# Run stress tests
python tests/performance/stress_test.py --users 100 --duration 600
```

## Monitoring and Maintenance

### Health Checks

```bash
# Check system health
curl http://localhost:8080/health

# Check agent status
curl http://localhost:8080/api/agents/status

# Check integration status
curl http://localhost:8080/api/integrations/status
```

### Log Management

```bash
# View application logs
tail -f logs/application.log

# View error logs
tail -f logs/error.log

# View agent activity logs
tail -f logs/agents/agent_activity.log

# Log rotation configuration
cat > /etc/logrotate.d/bmad-consultant << EOF
/path/to/logs/*.log {
    daily
    rotate 30
    compress
    delaycompress
    notifempty
    create 0640 bmad bmad
}
EOF
```

### Performance Monitoring

```bash
# Monitor resource usage
htop -p $(pgrep -f bmad-consultant)

# Monitor database connections
psql -c "SELECT count(*) FROM pg_stat_activity WHERE datname='bmad_consultant';"

# Monitor Redis
redis-cli INFO stats
```

### Backup and Recovery

```bash
# Backup database
pg_dump bmad_consultant > backup_$(date +%Y%m%d).sql

# Backup configuration
tar -czf config_backup_$(date +%Y%m%d).tar.gz config/

# Restore database
psql bmad_consultant < backup_20240101.sql

# Restore configuration
tar -xzf config_backup_20240101.tar.gz
```

## Troubleshooting

### Common Issues

#### Agent Not Loading
```bash
# Check agent configuration
python scripts/validate_agent.py agent-name

# Reload agent
python scripts/reload_agent.py agent-name

# Check logs
grep "agent-name" logs/error.log
```

#### ERPNext Connection Failed
```bash
# Test connection
curl -H "Authorization: Token your-api-key" https://your-erpnext.com/api/resource/Customer

# Check network connectivity
ping your-erpnext.com

# Verify API credentials
python scripts/test_erpnext_auth.py
```

#### Performance Issues
```bash
# Check database performance
psql -c "SELECT * FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"

# Check Redis performance
redis-cli --latency

# Profile application
python -m cProfile -o profile.stats app.py
python -m pstats profile.stats
```

### Debug Mode

Enable debug mode for detailed logging:

```bash
# Set debug environment
export BMAD_DEBUG=true
export BMAD_LOG_LEVEL=DEBUG

# Run with debug output
python app.py --debug

# Enable SQL query logging
export BMAD_LOG_SQL=true
```

## Security Considerations

### API Security
- Always use HTTPS in production
- Rotate API keys regularly
- Implement rate limiting
- Use IP whitelisting where possible

### Data Security
- Encrypt sensitive data at rest
- Use TLS for data in transit
- Implement role-based access control
- Regular security audits

### Compliance
- GDPR compliance for EU data
- SOC2 compliance for enterprise
- Regular compliance audits
- Data retention policies

## Support and Resources

### Documentation
- User Guide: `/docs/user-guide.md`
- API Reference: `/docs/api-reference.md`
- Agent Documentation: `/docs/agents/`
- Workflow Documentation: `/docs/workflows/`

### Community Support
- GitHub Issues: https://github.com/bmad-method/bmad-business-consultant/issues
- Discord Server: https://discord.gg/bmad-method
- Forum: https://forum.bmad-method.com

### Professional Support
- Email: support@bmad-method.com
- Phone: +1-800-BMAD-PRO
- Enterprise Support Portal: https://support.bmad-method.com

## Version History

### v1.0.0 (Current)
- Initial release
- 6 core agents
- 12 specialized tasks
- 8 compliance checklists
- 6 workflows
- 6 knowledge bases
- 4 team configurations
- ERPNext integration

### Planned Features (v1.1.0)
- AI-powered insights
- Advanced analytics dashboard
- Mobile application support
- Multi-language support
- Enhanced security features

## License

This software is licensed under the BMAD-METHOD Enterprise License. See LICENSE file for details.

---

**Last Updated**: January 2024
**Version**: 1.0.0
**Status**: Production Ready