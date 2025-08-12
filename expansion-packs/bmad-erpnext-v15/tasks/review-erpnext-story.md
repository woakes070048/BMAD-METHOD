# review-erpnext-story

When an ERPNext developer agent marks a story as "Ready for Review", perform a comprehensive senior ERPNext developer code review with the ability to refactor and improve ERPNext code directly while ensuring Frappe Framework compliance.

## Prerequisites

- ERPNext story status must be "Review"
- Developer has completed all ERPNext tasks and updated the File List
- All automated tests are passing (bench run-tests)
- Frappe Framework compliance has been initially validated
- Multi-app integration has been tested

## ERPNext Review Process

1. **Read the Complete ERPNext Story**
   - Review all ERPNext-specific acceptance criteria
   - Understand the DocType requirements and business logic
   - Note any ERPNext completion notes from the developer
   - Verify Frappe Framework constraints were considered

2. **Verify ERPNext Implementation Against Dev Notes Guidance**
   - Review the "Dev Notes" section for ERPNext-specific technical guidance
   - Verify DocType implementation follows Frappe field type conventions
   - Check that controller logic follows ERPNext patterns
   - Confirm Vue.js frontend uses Frappe UI components correctly
   - Validate API endpoints are properly whitelisted
   - Ensure mobile-first design principles were implemented
   - Check PWA requirements were addressed if applicable

3. **Focus on the ERPNext File List**
   - Verify all ERPNext files listed were actually created/modified
   - Check for missing ERPNext files (JSON, JS, PY, HTML, CSS)
   - Ensure file locations align with Frappe app structure
   - Validate naming conventions follow Frappe standards

4. **Senior ERPNext Developer Code Review**
   - Review code with the eye of a senior ERPNext developer
   - If changes form an ERPNext module, review them together
   - If changes are independent ERPNext components, review incrementally
   - Focus on:
     - ERPNext DocType design and field relationships
     - Frappe Framework pattern adherence
     - Vue.js integration with Frappe UI
     - API security and whitelisting compliance
     - Mobile responsiveness and PWA features
     - Performance optimizations for ERPNext scale
     - Security concerns specific to ERPNext
     - Best practices for ERPNext development

5. **ERPNext-Specific Validation**

   **5.1 DocType Review:**
   - Field types are appropriate for data requirements
   - Relationships (Link, Table) are correctly implemented
   - Naming conventions follow Frappe standards
   - Permissions are properly configured
   - Validation rules are comprehensive

   **5.2 Controller Review:**
   - Business logic follows ERPNext patterns
   - Hooks are implemented correctly (before_save, validate, etc.)
   - Error handling follows Frappe conventions
   - Performance considerations for large datasets

   **5.3 Frontend Review:**
   - Vue.js components use Frappe UI patterns
   - Mobile-first design is implemented
   - PWA features work correctly if required
   - Accessibility standards are met
   - Loading states and error handling

   **5.4 API Review:**
   - All endpoints are properly whitelisted
   - Authentication and authorization are correct
   - Input validation and sanitization
   - Rate limiting considerations
   - Response format follows Frappe conventions

6. **Multi-App Integration Review**

   **6.1 docflow Integration:**
   - Workflow states are properly defined
   - Transitions follow business rules
   - Approval processes work correctly
   - Document lifecycle is managed properly

   **6.2 n8n_integration Review:**
   - Webhook endpoints are secure and functional
   - Event triggers are properly implemented
   - External system integration works correctly
   - Error handling for automation failures

7. **Frappe-First Compliance Review**
   - No external libraries when Frappe has built-in solutions
   - Proper use of Frappe utilities and helpers
   - Correct implementation of Frappe design patterns
   - Adherence to Frappe security best practices

8. **Performance and Scalability Review**
   - Database queries are optimized
   - Proper indexing for performance
   - Bulk operations handle large datasets
   - Caching strategies are implemented where appropriate
   - Memory usage is reasonable

9. **Security Review**
   - SQL injection prevention
   - XSS protection
   - CSRF token validation
   - Permission checks at all levels
   - Input validation and sanitization
   - Sensitive data handling

10. **Testing Review**
    - Unit tests cover business logic
    - Integration tests validate DocType relationships
    - API tests verify endpoint functionality
    - Frontend tests validate user interactions
    - Performance tests for critical paths

## Active Code Improvement

As a senior ERPNext developer, you should:

1. **Refactor Code Directly:**
   - Improve code structure and readability
   - Optimize database queries
   - Enhance error handling
   - Implement better design patterns

2. **Add Missing Components:**
   - Add missing validations or hooks
   - Implement missing error handling
   - Add performance optimizations
   - Enhance security measures

3. **Document Changes:**
   - Explain why refactoring was needed
   - Document new patterns or approaches
   - Provide learning guidance for the developer
   - Update code comments for clarity

4. **Validate Improvements:**
   - Run tests to ensure changes work
   - Verify no regressions were introduced
   - Test integration points still function
   - Validate performance improvements

## Quality Standards

The code must meet these ERPNext quality standards:

- **Functionality:** All acceptance criteria are met
- **Frappe Compliance:** Follows all Frappe Framework patterns
- **Performance:** Performs well under expected load
- **Security:** Meets ERPNext security standards
- **Maintainability:** Code is clean, documented, and testable
- **Integration:** Works seamlessly with existing apps
- **Mobile-First:** Responsive design works on all devices
- **Accessibility:** Meets accessibility standards

## Review Completion

1. **Update QA Results Section:**
   - Document all findings and improvements made
   - Explain refactoring decisions and learning points
   - Note any remaining technical debt or future considerations
   - Provide specific feedback for developer growth

2. **Set Final Status:**
   - If code meets all standards: Status = "Done"
   - If major issues remain: Status = "In Development" with specific requirements
   - If architectural changes needed: Status = "Needs Architecture Review"

3. **Mentorship Component:**
   - Explain WHY changes were made
   - Share ERPNext best practices and patterns
   - Provide guidance for future similar implementations
   - Encourage good practices that were demonstrated

## Integration Points

- Reports findings to erpnext-product-owner for business validation
- Coordinates with main-dev-coordinator for process improvement
- Provides feedback to erpnext-scrum-master for future story planning
- Mentors ERPNext development team on best practices