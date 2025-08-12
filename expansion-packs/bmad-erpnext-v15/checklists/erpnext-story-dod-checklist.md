# ERPNext Story Definition of Done (DoD) Checklist

## Instructions for ERPNext Developer Agents

Before marking an ERPNext story as 'Review', please go through each item in this checklist. Report the status of each item (e.g., [x] Done, [ ] Not Done, [N/A] Not Applicable) and provide brief comments if necessary.

[[LLM: INITIALIZATION INSTRUCTIONS - ERPNEXT STORY DOD VALIDATION

This checklist is for ERPNext DEVELOPER AGENTS to self-validate their work before marking a story complete.

IMPORTANT: This is a self-assessment. Be honest about what's actually done vs what should be done. It's better to identify issues now than have them found in review.

ERPNEXT-SPECIFIC EXECUTION APPROACH:

1. Go through each section systematically with ERPNext context
2. Mark items as [x] Done, [ ] Not Done, or [N/A] Not Applicable
3. Add brief comments explaining any [ ] or [N/A] items
4. Be specific about ERPNext implementations (DocTypes, Controllers, etc.)
5. Flag any Frappe Framework compliance concerns or technical debt
6. Validate multi-app integration points

The goal is quality ERPNext delivery that follows Frappe Framework best practices.]]

## ERPNext Checklist Items

### 1. **ERPNext Requirements Met:**

   [[LLM: Be specific about ERPNext requirements - list each DocType, API, frontend requirement and whether it's complete]]

   - [ ] All ERPNext functional requirements specified in the story are implemented.
   - [ ] All ERPNext acceptance criteria defined in the story are met.
   - [ ] DocType requirements are fully implemented with correct field types.
   - [ ] Business logic requirements are implemented in controllers.
   - [ ] API requirements are implemented with proper whitelisting.
   - [ ] Frontend requirements are implemented using Frappe UI patterns.
   - [ ] Mobile-first design requirements are met.
   - [ ] PWA requirements are implemented if specified.

   **Comments:** _Brief explanation of any incomplete requirements_

### 2. **Frappe Framework Compliance:**

   [[LLM: Validate adherence to Frappe Framework patterns and best practices]]

   - [ ] Code follows Frappe-first principles (no external libraries when Frappe has built-in solutions).
   - [ ] DocType design follows Frappe naming conventions and patterns.
   - [ ] Field types are appropriate and follow Frappe field type standards.
   - [ ] Controller code follows Frappe controller patterns and hooks.
   - [ ] API endpoints are properly whitelisted using @frappe.whitelist().
   - [ ] Client scripts follow Frappe JavaScript patterns.
   - [ ] No Frappe Framework anti-patterns are present in the code.
   - [ ] Code adheres to Frappe security best practices.

   **Comments:** _Note any framework compliance issues or exceptions_

### 3. **DocType Implementation Quality:**

   [[LLM: Validate DocType design and implementation quality]]

   - [ ] DocType JSON files are properly structured and valid.
   - [ ] Field relationships (Link, Table) are correctly implemented.
   - [ ] Field validations are appropriate and comprehensive.
   - [ ] Permission matrix is properly configured for required roles.
   - [ ] Naming conventions follow Frappe standards.
   - [ ] Auto-naming rules are implemented correctly if required.
   - [ ] Child table relationships are properly configured.
   - [ ] Database indexes are added where necessary for performance.

   **Comments:** _Note any DocType design concerns or optimization opportunities_

### 4. **Multi-App Integration:**

   [[LLM: Validate integration with existing ERPNext apps]]

   - [ ] Integration with docflow workflows is implemented correctly.
   - [ ] n8n_integration hooks are implemented where specified.
   - [ ] Existing app compatibility is maintained.
   - [ ] No conflicts with existing custom DocTypes or functionality.
   - [ ] Data synchronization with other apps works correctly.
   - [ ] Integration points are properly tested.

   **Comments:** _Note any integration issues or concerns_

### 5. **Frontend Implementation:**

   [[LLM: Validate Vue.js and Frappe UI implementation]]

   - [ ] Vue.js components use Frappe UI patterns correctly.
   - [ ] Frontend code follows Vue.js best practices.
   - [ ] Components are properly responsive for mobile devices.
   - [ ] Frappe UI components are used appropriately.
   - [ ] Custom CSS follows Frappe design system.
   - [ ] Frontend performance is acceptable.
   - [ ] Accessibility requirements are met.
   - [ ] PWA features work correctly if implemented.

   **Comments:** _Note any frontend implementation concerns_

### 6. **API Implementation:**

   [[LLM: Validate API endpoint implementation and security]]

   - [ ] All API endpoints are properly whitelisted.
   - [ ] Authentication and authorization are correctly implemented.
   - [ ] Input validation and sanitization are comprehensive.
   - [ ] API responses follow Frappe JSON format conventions.
   - [ ] Error handling is proper and follows Frappe patterns.
   - [ ] API documentation is adequate.
   - [ ] Rate limiting is considered where appropriate.

   **Comments:** _Note any API implementation concerns_

### 7. **Testing Implementation:**

   [[LLM: Validate testing coverage and quality]]

   - [ ] Unit tests are written for DocType controllers.
   - [ ] Unit tests are written for API endpoints.
   - [ ] Integration tests validate multi-DocType functionality.
   - [ ] Frontend tests validate Vue.js component behavior.
   - [ ] Manual testing has been performed for user workflows.
   - [ ] Mobile testing has been performed on actual devices.
   - [ ] Integration testing with existing apps has been performed.
   - [ ] All tests pass successfully.

   **Comments:** _Note any testing gaps or concerns_

### 8. **Performance and Security:**

   [[LLM: Validate performance and security implementation]]

   - [ ] Database queries are optimized for performance.
   - [ ] Page load times are acceptable for ERPNext scale.
   - [ ] API response times meet performance requirements.
   - [ ] Security measures prevent common vulnerabilities.
   - [ ] Input validation prevents injection attacks.
   - [ ] Proper permission checks are in place.
   - [ ] Sensitive data is properly protected.

   **Comments:** _Note any performance or security concerns_

### 9. **Code Quality:**

   [[LLM: Validate code quality and maintainability]]

   - [ ] Code is clean, readable, and well-structured.
   - [ ] Code follows ERPNext coding standards and conventions.
   - [ ] Adequate code comments are present where needed.
   - [ ] No code duplication or anti-patterns are present.
   - [ ] Error handling is comprehensive and appropriate.
   - [ ] Code is maintainable and extensible.
   - [ ] Technical debt is minimized or documented.

   **Comments:** _Note any code quality concerns_

### 10. **Documentation:**

   [[LLM: Validate documentation completeness]]

   - [ ] Technical documentation is complete and accurate.
   - [ ] User documentation is clear and helpful.
   - [ ] API documentation follows ERPNext standards.
   - [ ] Code comments explain complex business logic.
   - [ ] Migration scripts are documented if required.
   - [ ] Integration points are documented.

   **Comments:** _Note any documentation gaps_

### 11. **Deployment Readiness:**

   [[LLM: Validate deployment readiness and migration requirements]]

   - [ ] Migration scripts are created and tested if required.
   - [ ] Deployment instructions are clear and complete.
   - [ ] Backward compatibility is maintained where required.
   - [ ] Database changes are properly scripted.
   - [ ] App installation/upgrade procedures are documented.
   - [ ] Production environment considerations are addressed.

   **Comments:** _Note any deployment concerns_

### 12. **Environment Validation:**

   [[LLM: Validate ERPNext environment compatibility]]

   - [ ] Code works correctly in the specified ERPNext environment.
   - [ ] Bench commands execute successfully.
   - [ ] Site functionality is preserved and enhanced.
   - [ ] Multi-tenancy compatibility is maintained.
   - [ ] Development environment matches production requirements.

   **Comments:** _Note any environment compatibility issues_

## Final DoD Assessment

### Overall Story Completion Status:
- [ ] **READY FOR REVIEW** - All critical items are complete, story meets ERPNext quality standards
- [ ] **NEEDS WORK** - Some items need completion before review
- [ ] **BLOCKED** - Cannot complete due to external dependencies or issues

### Summary of Remaining Work:
_List any items that still need completion before story can be marked as ready for review_

### Technical Debt Created:
_Document any technical debt created during implementation that should be addressed in future stories_

### Recommendations for QA Review:
_Provide specific guidance for QA reviewer on areas that need special attention_

## ERPNext-Specific Validation Notes

**Frappe Framework Compliance Score:** ___/10 (rate adherence to Frappe patterns)

**Integration Quality Score:** ___/10 (rate multi-app integration quality)

**Mobile Responsiveness Score:** ___/10 (rate mobile user experience)

**Performance Score:** ___/10 (rate overall performance)

**Security Score:** ___/10 (rate security implementation)

### Final Developer Certification:
I certify that this ERPNext story implementation:
- [ ] Meets all specified requirements
- [ ] Follows Frappe Framework best practices
- [ ] Maintains compatibility with existing ERPNext apps
- [ ] Is ready for QA review and potential production deployment

**Developer Signature:** _______________  **Date:** _______________