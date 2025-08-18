# create-user-guide

**Task:** Create comprehensive user guides and documentation for ERPNext applications

**Agent:** documentation-specialist  
**Category:** Documentation  
**Elicit:** true  
**Prerequisites:** Working application, understanding of user workflows  

## Overview

This task creates user-friendly documentation including getting started guides, feature tutorials, workflow documentation, and troubleshooting guides for end users.

## Input Requirements

**Required:**
- Application name and purpose
- Target user personas (roles, skill levels)
- Key features and workflows
- Common use cases

**Optional:**
- Screenshots or screen recordings
- Existing documentation to update
- Branding guidelines
- Training materials
- Support ticket patterns

## Process Steps

### Step 1: User Analysis and Planning
1. **Identify user personas:**
   ```yaml
   user_personas:
     administrator:
       role: "System Administrator"
       technical_level: "Advanced"
       responsibilities:
         - "System configuration"
         - "User management"
         - "Data imports/exports"
       documentation_needs:
         - "Technical setup guides"
         - "Configuration reference"
         - "Troubleshooting guides"
     
     end_user:
       role: "Sales Representative"
       technical_level: "Basic"
       responsibilities:
         - "Create quotations"
         - "Manage customers"
         - "Process orders"
       documentation_needs:
         - "Step-by-step tutorials"
         - "Visual guides"
         - "Quick reference cards"
     
     manager:
       role: "Sales Manager"
       technical_level: "Intermediate"
       responsibilities:
         - "Review reports"
         - "Approve transactions"
         - "Monitor team performance"
       documentation_needs:
         - "Dashboard guides"
         - "Report explanations"
         - "Workflow documentation"
   ```

2. **Map user journeys:**
   - Onboarding flow
   - Daily tasks
   - Periodic activities
   - Advanced features
   - Troubleshooting paths

3. **Create documentation outline:**
   ```markdown
   # User Guide Outline
   
   1. Getting Started
      - First login
      - Dashboard overview
      - Navigation basics
      - User preferences
   
   2. Core Features
      - Customer management
      - Order processing
      - Inventory tracking
      - Report generation
   
   3. Workflows
      - Quote to cash
      - Purchase to pay
      - Inventory management
   
   4. Advanced Features
      - Customization
      - Automation
      - Integrations
   
   5. Troubleshooting
      - Common issues
      - Error messages
      - Support resources
   ```

### Step 2: Create Getting Started Guide
1. **Write welcome section:**
   ```markdown
   # Getting Started with [App Name]
   
   Welcome to [App Name]! This guide will help you get up and running quickly.
   
   ## What is [App Name]?
   
   [App Name] is a comprehensive business management solution that helps you:
   - ✅ Manage customers and leads
   - ✅ Process orders efficiently
   - ✅ Track inventory in real-time
   - ✅ Generate insightful reports
   
   ## Your First Login
   
   ### Step 1: Access the System
   1. Open your web browser
   2. Navigate to `https://your-company.erpnext.com`
   3. You'll see the login screen
   
   ![Login Screen](images/login-screen.png)
   
   ### Step 2: Enter Your Credentials
   1. Enter your **email address**
   2. Enter your **password**
   3. Click **Login**
   
   > 💡 **Tip:** Check "Remember Me" to stay logged in on this device
   
   ### Step 3: Complete Your Profile
   On first login, you'll be prompted to:
   1. Upload a profile picture (optional)
   2. Set your timezone
   3. Choose your language preference
   4. Configure notification settings
   
   ## Understanding the Dashboard
   
   After login, you'll see your personalized dashboard:
   
   ![Dashboard Overview](images/dashboard-overview.png)
   
   ### Key Areas:
   
   #### 1. Navigation Menu (Left Sidebar)
   - **Home**: Return to dashboard
   - **Modules**: Access different areas (Sales, Purchase, Stock, etc.)
   - **Reports**: View analytical reports
   - **Settings**: Configure preferences
   
   #### 2. Quick Access Shortcuts
   Frequently used features for quick access:
   - New Customer
   - New Sales Order
   - Today's Tasks
   - Pending Approvals
   
   #### 3. Dashboard Cards
   Real-time metrics and KPIs:
   - Sales this month
   - Pending orders
   - Inventory alerts
   - Team activity
   ```

### Step 3: Document Core Features
1. **Create feature documentation:**
   ```markdown
   # Customer Management
   
   ## Overview
   The Customer module helps you maintain comprehensive records of your clients, track interactions, and manage relationships effectively.
   
   ## Creating a New Customer
   
   ### Method 1: Quick Create
   1. Click **+ New** button in the top bar
   2. Select **Customer**
   3. Fill in essential details:
      - Customer Name (required)
      - Customer Type: Company or Individual
      - Customer Group: Select from dropdown
   4. Click **Save**
   
   ### Method 2: Detailed Creation
   1. Navigate to **CRM > Customer**
   2. Click **New Customer** button
   3. Complete all sections:
   
   #### Basic Information
   ![Customer Basic Info](images/customer-basic.png)
   
   - **Customer Name**: Official business name
   - **Customer Type**: 
     - *Company*: For businesses
     - *Individual*: For personal customers
   - **Customer Group**: Categorize for reporting
   - **Territory**: Geographic classification
   
   #### Contact & Address
   ![Contact Section](images/customer-contact.png)
   
   - Click **Add Row** to add contacts
   - Enter primary contact details
   - Mark primary contact with checkbox
   
   #### Accounting
   - **Default Currency**: For transactions
   - **Default Price List**: Automatic pricing
   - **Credit Limit**: Set if applicable
   
   ### Best Practices
   
   ✅ **DO:**
   - Use consistent naming conventions
   - Complete all available fields
   - Link related contacts and addresses
   - Set appropriate credit limits
   - Add notes for special requirements
   
   ❌ **DON'T:**
   - Create duplicate customers
   - Use abbreviations in official names
   - Skip contact information
   - Forget to set customer group
   
   ## Searching and Filtering
   
   ### Quick Search
   1. Use the search bar at the top
   2. Type customer name or ID
   3. Press Enter or click result
   
   ### Advanced Filters
   1. Go to **Customer List**
   2. Click **Filter** button
   3. Set filter criteria:
      - Customer Group
      - Territory  
      - Creation date range
      - Status
   4. Click **Apply Filters**
   
   ## Common Tasks
   
   ### View Customer History
   1. Open customer record
   2. Click **View > Connections**
   3. See related:
      - Quotations
      - Sales Orders
      - Invoices
      - Payments
   
   ### Update Customer Information
   1. Open customer record
   2. Click **Edit** button
   3. Make changes
   4. Click **Save**
   
   > ⚠️ **Note:** Some fields may be locked after transactions are created
   ```

### Step 4: Create Workflow Documentation
1. **Document business processes:**
   ```markdown
   # Quote to Cash Workflow
   
   ## Overview
   This workflow covers the complete sales cycle from initial quotation to payment collection.
   
   ```mermaid
   graph LR
     A[Lead] --> B[Quotation]
     B --> C[Sales Order]
     C --> D[Delivery Note]
     D --> E[Sales Invoice]
     E --> F[Payment Entry]
   ```
   
   ## Step 1: Create Quotation
   
   ### When to Use
   When a potential customer requests pricing for products/services.
   
   ### Process
   1. Navigate to **Selling > Quotation**
   2. Click **New**
   3. Select or create **Customer/Lead**
   4. Add items:
      - Search and select products
      - Enter quantities
      - Apply discounts if authorized
   5. Review totals and taxes
   6. Click **Save** then **Submit**
   
   ![Quotation Form](images/quotation-form.png)
   
   ### What Happens Next
   - Customer receives quotation via email
   - Quotation remains valid for specified period
   - Follow up tasks created automatically
   
   ## Step 2: Convert to Sales Order
   
   ### When Customer Accepts
   1. Open the submitted Quotation
   2. Click **Create > Sales Order**
   3. Review and adjust:
      - Delivery dates
      - Payment terms
      - Special instructions
   4. Click **Save** then **Submit**
   
   ### Automatic Actions
   - Inventory reserved (if configured)
   - Production orders created (if manufacturing)
   - Customer notified of order confirmation
   
   ## Step 3: Process Delivery
   
   ### Create Delivery Note
   1. From Sales Order, click **Create > Delivery Note**
   2. Verify items and quantities
   3. Add shipping details:
      - Transporter name
      - Vehicle number
      - Tracking information
   4. Click **Save** then **Submit**
   
   ### What This Triggers
   - Stock reduced from warehouse
   - Shipping notification sent
   - Available for invoicing
   
   ## Step 4: Generate Invoice
   
   ### Creating Sales Invoice
   1. From Delivery Note, click **Create > Sales Invoice**
   2. Or from Sales Order if shipping not required
   3. Review:
      - Items and amounts
      - Taxes and charges
      - Payment terms
   4. Click **Save** then **Submit**
   
   ### Invoice Actions
   - PDF generated automatically
   - Email sent to customer
   - Accounting entries created
   - Receivable recorded
   
   ## Step 5: Record Payment
   
   ### Payment Entry
   1. From Sales Invoice, click **Create > Payment**
   2. Enter payment details:
      - Payment date
      - Amount received
      - Payment method
      - Reference number
   3. Click **Save** then **Submit**
   
   ### Completion
   - Invoice marked as paid
   - Customer statement updated
   - Commission calculations triggered
   - Reports updated real-time
   ```

### Step 5: Create Troubleshooting Guide
1. **Document common issues:**
   ```markdown
   # Troubleshooting Guide
   
   ## Common Issues and Solutions
   
   ### Cannot Login
   
   #### Symptom
   Error message: "Invalid login credentials"
   
   #### Possible Causes & Solutions
   
   **1. Incorrect Password**
   - Click "Forgot Password?" link
   - Enter your email address
   - Check email for reset link
   - Create new password
   
   **2. Account Locked**
   - Too many failed attempts
   - Wait 30 minutes and try again
   - Or contact administrator
   
   **3. Account Deactivated**
   - Contact your administrator
   - Verify employment status
   
   ### Cannot Create Documents
   
   #### Symptom
   "Permission Denied" error when creating records
   
   #### Solutions
   
   **Check Your Role:**
   1. Go to **My Settings**
   2. Check assigned roles
   3. Verify role permissions with admin
   
   **Document-Specific Issues:**
   - Some documents require approval
   - Check if in correct company
   - Verify workflow state
   
   ### Reports Show No Data
   
   #### Symptom
   Reports appear empty or show zero values
   
   #### Troubleshooting Steps
   
   1. **Check Filters:**
      - Date range includes data
      - Company filter correct
      - Status filters appropriate
   
   2. **Verify Permissions:**
      - You have access to the data
      - Role includes report permission
   
   3. **Data Existence:**
      - Confirm data exists in period
      - Check if documents are submitted
   
   ### Slow Performance
   
   #### Symptom
   System responds slowly or times out
   
   #### Quick Fixes
   
   1. **Clear Browser Cache:**
      - Press Ctrl+Shift+Delete
      - Select "Cached images and files"
      - Clear data
   
   2. **Check Internet Connection:**
      - Run speed test
      - Try different network
   
   3. **Reduce Data Load:**
      - Limit list view items
      - Use specific filters
      - Close unused tabs
   
   ## Error Messages Explained
   
   | Error Message | Meaning | Solution |
   |--------------|---------|----------|
   | "Insufficient Permission" | You don't have access rights | Contact administrator for permission |
   | "Mandatory field missing" | Required field is empty | Fill in all fields marked with red asterisk |
   | "Value already exists" | Duplicate entry attempted | Check if record already exists |
   | "Cannot cancel submitted document" | Document is locked | Create amendment or contact admin |
   | "Link field validation failed" | Invalid reference | Select value from dropdown only |
   
   ## Getting Help
   
   ### Self-Service Resources
   - 📚 This user guide
   - 🎥 Video tutorials: [link]
   - 💬 Community forum: [link]
   - 📖 Knowledge base: [link]
   
   ### Contact Support
   
   **Before Contacting Support:**
   1. Note the exact error message
   2. Document steps to reproduce
   3. Take screenshots if helpful
   4. Check if others have same issue
   
   **Support Channels:**
   - 📧 Email: support@company.com
   - 💬 Chat: Available 9 AM - 5 PM
   - 📞 Phone: 1-800-XXX-XXXX
   - 🎫 Ticket System: support.company.com
   ```

### Step 6: Generate Quick Reference Materials
1. **Create cheat sheets:**
   ```markdown
   # Quick Reference Card
   
   ## Keyboard Shortcuts
   
   | Action | Shortcut |
   |--------|----------|
   | Search | Ctrl + K |
   | New Document | Ctrl + N |
   | Save | Ctrl + S |
   | Submit | Ctrl + B |
   | Print | Ctrl + P |
   | Help | F1 |
   
   ## Common Operations
   
   ### Create Customer
   `CRM > Customer > New`
   
   ### Create Quotation  
   `Selling > Quotation > New`
   
   ### View Reports
   `Reports > [Report Name]`
   
   ### Check Notifications
   Click bell icon in top bar
   
   ## Status Indicators
   
   🟦 **Draft**: Document not finalized
   🟩 **Submitted**: Document confirmed
   🟥 **Cancelled**: Document void
   🟨 **Pending**: Awaiting action
   
   ## Quick Tips
   
   💡 Use `@` to mention users in comments
   💡 Press `/` to see available slash commands
   💡 Drag and drop files to attach
   💡 Right-click for context menu options
   ```

## Deliverables

### 1. Complete User Guide
- Getting started section
- Feature documentation
- Workflow guides
- Troubleshooting section
- FAQ
- Glossary of terms

### 2. Quick Reference Materials
- Keyboard shortcuts card
- Common operations guide
- Status reference
- Error message dictionary

### 3. Visual Assets
- Screenshots with annotations
- Process flow diagrams
- Video tutorials (scripts)
- Infographics

### 4. Training Materials
- New user onboarding guide
- Role-specific guides
- Best practices document
- Do's and don'ts list

## Quality Checks

- [ ] Language is appropriate for audience
- [ ] All features documented
- [ ] Screenshots are current
- [ ] Steps are accurate and complete
- [ ] Navigation paths verified
- [ ] Error solutions tested
- [ ] Links work correctly
- [ ] Formatting is consistent
- [ ] Accessible language used
- [ ] Visual aids included

## Success Criteria

1. **Usability**
   - Users can complete tasks independently
   - Reduced support tickets
   - Positive user feedback
   - Quick task completion

2. **Completeness**
   - All features covered
   - All user roles addressed
   - Common issues documented
   - Edge cases mentioned

3. **Clarity**
   - Plain language used
   - Technical terms explained
   - Visual aids support text
   - Logical organization

4. **Maintenance**
   - Easy to update
   - Version controlled
   - Change tracking enabled
   - Review schedule defined

## Next Steps

After creating user guide:
1. Conduct user testing for feedback
2. Create video tutorials based on guide
3. Set up help system integration
4. Translate for multiple languages
5. Create mobile-friendly version
6. Establish update process for new features