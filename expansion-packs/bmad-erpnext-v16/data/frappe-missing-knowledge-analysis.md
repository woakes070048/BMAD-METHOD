# Critical Frappe Knowledge Gaps for ALL Agents

## 🚨 What Each Agent is MISSING from Frappe Docs

### 1. **testing-specialist** - MAJOR GAPS
Missing from Frappe Testing Guides:
- ❌ **UI Integration Testing** (`/testing/ui-integration-testing`)
- ❌ **UI Testing with Frappe API** (`/testing/ui-testing`)
- ❌ **Automated Testing strategies** (`/testing/automated-testing`)
- ❌ How to write tests that actually test DocType workflows
- ❌ How to test background jobs
- ❌ How to test real-time features
- ❌ Test fixtures and data setup patterns

### 2. **api-developer & api-architect** - CRITICAL GAPS
Missing from Frappe API Guides:
- ❌ **Dialog API** (`/api/dialog`) - How to create dynamic dialogs
- ❌ **Full-Text Search API** (`/api/full-text-search`)
- ❌ **SQLite Search patterns** (`/api/sqlite-search`)
- ❌ **Query Builder patterns** (`/api/query-builder`)
- ❌ **How to handle file uploads** properly
- ❌ **How to implement rate limiting**
- ❌ **How to create custom REST endpoints**
- ❌ **Batch processing patterns**

### 3. **doctype-designer** - FUNDAMENTAL GAPS
Missing DocType Knowledge:
- ❌ **Virtual DocTypes** (`/basics/doctypes/virtual-doctype`)
- ❌ **Single DocTypes** (`/basics/doctypes/single-doctype`)
- ❌ **Naming patterns** (`/basics/doctypes/naming`)
- ❌ **Virtual DocField** (`/basics/virtual_docfield`)
- ❌ **How to create tree structures**
- ❌ **How to implement custom field types**
- ❌ **How to create computed fields**

### 4. **diagnostic-specialist** - DEBUGGING GAPS
Missing Debugging/Monitoring:
- ❌ **Debugging guide** (`/debugging`)
- ❌ **Profiling and Monitoring** (`/profiling-and-monitoring`)
- ❌ **Performance Optimization** (`/guides/performance-optimization`)
- ❌ **How to use System Console** (`/desk/scripting/system-console`)
- ❌ **How to analyze slow queries**
- ❌ **How to debug background jobs**
- ❌ **Memory leak detection**

### 5. **bench-operator** - OPERATIONAL GAPS
Missing Operational Guides:
- ❌ **Database Optimization** (`/guides/database/database-optimization`)
- ❌ **Read from Slave/Secondary** (`/guides/database/read-from-slave`)
- ❌ **Backup Encryption** (`/guides/basics/backup-encryption`)
- ❌ **How to setup multi-tenant**
- ❌ **How to configure Redis properly**
- ❌ **How to setup production deployment**
- ❌ **SSL certificate management**

### 6. **vue-spa-architect** - INTEGRATION GAPS
Missing Frontend Integration:
- ❌ **Form Tours** (`/api/form-tours`) - Interactive tutorials
- ❌ **Scanner API** (`/api/scanner`) - Barcode/QR scanning
- ❌ **Chart API** (`/api/chart`) - Data visualization
- ❌ **How to integrate with Desk features**
- ❌ **How to create custom controls**
- ❌ **How to use Frappe's grid system**

### 7. **business-analyst** - PROCESS GAPS
Missing Business Process Knowledge:
- ❌ **Assignments and Todos** (`/guides/basics/assignments-todos`)
- ❌ **Notifications setup** (`/guides/basics/notifications`)
- ❌ **Email Groups** (`/guides/basics/email-groups`)
- ❌ **How to map business processes to ERPNext**
- ❌ **How to design approval workflows**
- ❌ **How to setup role hierarchies**

### 8. **portal-specialist** (DOESN'T EXIST!)
We have NO agent for:
- ❌ **Web Forms** (`/portal/web-form/*`)
- ❌ **Portal Pages** (`/portal/portal-pages`)
- ❌ **Blog Posts** (`/portal/blog-post`)
- ❌ **Discussions** (`/portal/discussions`)
- ❌ **Apps Page** (`/portal/apps-page`)

### 9. **pwa-specialist** - SERVICE WORKER GAPS
Missing PWA Knowledge:
- ❌ **How to implement offline sync**
- ❌ **How to handle network failures**
- ❌ **How to cache strategies**
- ❌ **How to implement background sync**
- ❌ **Push notification patterns**

### 10. **workspace-architect** - DESK GAPS
Missing Desk Knowledge:
- ❌ **Workspace customization** (`/desk/workspace`)
- ❌ **How to create dashboard widgets**
- ❌ **How to implement shortcuts**
- ❌ **How to create number cards**
- ❌ **How to setup quick lists**

## 📚 Critical HOW-TO Guides We're Missing

### From Frappe "Guides" Section We Don't Cover:

#### App Development Guides:
1. **Custom Action in Link Field** - How to add buttons in link fields
2. **Executing Code On DocType Events** - Complete event lifecycle
3. **How To Improve A Standard Control** - Extending built-in controls
4. **Trigger Event On Deletion Of Grid Row** - Grid manipulation
5. **Dialog Types** - All dialog patterns (prompt, confirm, custom)
6. **Overriding Link Query By Custom Script** - Dynamic filtering
7. **Insert A Document Via API** - Proper document creation
8. **Custom Fields During App Installation** - Migration patterns
9. **HTML Templates In JavaScript** - Template rendering

#### Database Guides:
1. **Database Settings** - Connection pooling, optimization
2. **Setup Read Operations from Slave** - Read replicas
3. **Postgres Database Setup** - Alternative to MariaDB
4. **Database Optimization** - Indexing, query optimization

#### Desk Guides:
1. **Desk Customization** - Theming, layouts
2. **Formatter For Link Fields** - Custom display
3. **Making Charts** - Data visualization
4. **Using Vue in a Desk Page** - Integration patterns

## 🎯 What This Means for Our Agents

### IMMEDIATE NEEDS:

1. **ALL agents need**:
   - How to handle errors properly
   - How to log for debugging
   - How to write tests for their work
   - How to handle permissions

2. **Frontend agents need**:
   - Complete Form Scripts patterns
   - Dialog creation patterns
   - Chart/visualization patterns
   - Scanner integration

3. **Backend agents need**:
   - Background job patterns
   - Database optimization
   - Query builder usage
   - Full-text search

4. **Testing specialist needs**:
   - COMPLETE rewrite with UI testing
   - Integration test patterns
   - Performance testing
   - Security testing

5. **Diagnostic specialist needs**:
   - Profiling tools usage
   - System console usage
   - Performance analysis
   - Debug techniques

## 🔥 Priority Fixes

### HIGH PRIORITY (Affects ALL work):
1. Error handling patterns
2. Testing patterns  
3. Permission patterns
4. Logging/debugging

### MEDIUM PRIORITY (Common tasks):
1. Dialog creation
2. Background jobs
3. File uploads
4. Search patterns

### LOW PRIORITY (Specialized):
1. Postgres setup
2. Read replicas
3. Email groups
4. Blog posts

---

**CONCLUSION**: We're missing 60-70% of practical Frappe knowledge. Agents have reference knowledge but lack HOW-TO knowledge for actual implementation.