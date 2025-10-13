# Nex Bridge HRMS API Installation Guide

This document explains how to install and configure the Nex Bridge HRMS API functions on your Frappe/ERPNext server to support the stock-take mobile app's HR functionalities.

## Overview

The Nex Bridge HRMS APIs provide the following functionality:
- **Attendance Management**: Check-in/check-out, attendance history, attendance requests
- **Leave Management**: Leave applications, leave balance, leave types, approvals
- **Expense Claims**: Claim submission, approval workflow, expense categories
- **Approvals**: Unified approval interface for managers

## Installation Steps

### 1. Create the Nex Bridge App (if not already exists)

If you don't have a Nex Bridge app, create one:

```bash
cd /path/to/your/frappe-bench
bench new-app nex_bridge
```

### 2. Add API Files

Copy the API files to your Nex Bridge app:

```
nex_bridge/
  nex_bridge/
    api/
      __init__.py
      hrms/
        __init__.py
        attendance.py
        leaves.py
        claims.py
        approvals.py
```

Create the directory structure:

```bash
mkdir -p /path/to/frappe-bench/apps/nex_bridge/nex_bridge/api/hrms
```

### 3. Create __init__.py Files

Create `/path/to/frappe-bench/apps/nex_bridge/nex_bridge/api/__init__.py`:
```python
# API module for Nex Bridge
```

Create `/path/to/frappe-bench/apps/nex_bridge/nex_bridge/api/hrms/__init__.py`:
```python
# HRMS API module for Nex Bridge
```

### 4. Add the API Files

Copy each of the provided Python files to the corresponding location:

- `attendance.py` → `/path/to/frappe-bench/apps/nex_bridge/nex_bridge/api/hrms/attendance.py`
- `leaves.py` → `/path/to/frappe-bench/apps/nex_bridge/nex_bridge/api/hrms/leaves.py`
- `claims.py` → `/path/to/frappe-bench/apps/nex_bridge/nex_bridge/api/hrms/claims.py`
- `approvals.py` → `/path/to/frappe-bench/apps/nex_bridge/nex_bridge/api/hrms/approvals.py`

### 5. Install the App

If this is a new app, install it on your site:

```bash
bench --site your-site.local install-app nex_bridge
```

If the app already exists, migrate to add the new changes:

```bash
bench --site your-site.local migrate
```

### 6. Update Mobile App Service Configuration

Update your Flutter app services to use the proper Nex Bridge endpoints:

#### In `attendance_service.dart`, update the method calls:

```dart
// Check in
final res = await HrmsApiClient.postMethod('nex_bridge.api.hrms.attendance.checkin', params: {
  if (emp != null) 'employee': emp,
});

// Check out  
final res = await HrmsApiClient.postMethod('nex_bridge.api.hrms.attendance.checkout', params: {
  if (emp != null) 'employee': emp,
});

// Get attendance history
final res = await HrmsApiClient.postMethod('nex_bridge.api.hrms.attendance.get_attendance_history', params: {
  if (emp != null) 'employee': emp,
});
```

#### In `leaves_service.dart`, update the method calls:

```dart
// Get leave applications
final res = await HrmsApiClient.postMethod('nex_bridge.api.hrms.leaves.get_leave_applications', params: {
  if (emp != null) 'employee': emp,
});

// Submit leave application
final res = await HrmsApiClient.postMethod('nex_bridge.api.hrms.leaves.submit_leave_application', params: payload);

// Get leave balance
final res = await HrmsApiClient.postMethod('nex_bridge.api.hrms.leaves.get_leave_balance_map', params: {
  if (emp != null) 'employee': emp,
});
```

#### In `claims_service.dart`, update the method calls:

```dart
// Get expense claims
final res = await HrmsApiClient.postMethod('nex_bridge.api.hrms.claims.get_expense_claims', params: {
  if (emp != null) 'employee': emp,
});

// Submit expense claim
final res = await HrmsApiClient.postMethod('nex_bridge.api.hrms.claims.submit_expense_claim', params: payload);

// Get expense claim types
final res = await HrmsApiClient.postMethod('nex_bridge.api.hrms.claims.get_expense_claim_types');
```

#### In `approvals_service.dart`, update the method calls:

```dart
// Get pending approvals
final res = await HrmsApiClient.postMethod('nex_bridge.api.hrms.approvals.pending_approvals', params: {
  if (emp != null) 'employee': emp,
});

// Approve request
final res = await HrmsApiClient.postMethod('nex_bridge.api.hrms.approvals.approve_request', params: {
  'doctype': doctype,
  'name': name,
  if (comments != null) 'comments': comments,
});
```

### 7. Set Up Employee User Linking

Ensure your employees are properly linked to users in the system:

1. Go to **HR > Employee** in your Frappe desk
2. For each employee that will use the mobile app:
   - Set the **User ID** field to their user account
   - Set appropriate **Leave Approver** and **Expense Approver** if needed
   - Ensure **Reports To** is set correctly for approval workflows

### 8. Configure Leave Types and Expense Claim Types

1. **Leave Types**: Go to **HR > Leave Type** and ensure you have the required leave types configured
2. **Expense Claim Types**: Go to **HR > Expense Claim Type** and create the required expense categories

### 9. Test the API Endpoints

You can test the endpoints using Frappe's built-in API testing or using tools like Postman:

#### Test Check-in
```
POST /api/method/nex_bridge.api.hrms.attendance.checkin
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: application/json

{}
```

#### Test Leave Application Submission
```
POST /api/method/nex_bridge.api.hrms.leaves.submit_leave_application
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: application/json

{
  "leave_type": "Annual Leave",
  "from_date": "2024-01-15",
  "to_date": "2024-01-16", 
  "reason": "Personal work"
}
```

## API Endpoint Reference

### Attendance APIs
- `nex_bridge.api.hrms.attendance.checkin` - Create check-in record
- `nex_bridge.api.hrms.attendance.checkout` - Create check-out record  
- `nex_bridge.api.hrms.attendance.get_attendance_history` - Get attendance history
- `nex_bridge.api.hrms.attendance.get_attendance_requests` - Get attendance requests
- `nex_bridge.api.hrms.attendance.submit_attendance_request` - Submit attendance request

### Leave APIs
- `nex_bridge.api.hrms.leaves.get_leave_applications` - Get leave applications
- `nex_bridge.api.hrms.leaves.submit_leave_application` - Submit leave application
- `nex_bridge.api.hrms.leaves.get_leave_balance_map` - Get leave balance
- `nex_bridge.api.hrms.leaves.get_leave_types` - Get available leave types
- `nex_bridge.api.hrms.leaves.approve_leave_application` - Approve/reject leave

### Claims APIs
- `nex_bridge.api.hrms.claims.get_expense_claims` - Get expense claims
- `nex_bridge.api.hrms.claims.submit_expense_claim` - Submit expense claim
- `nex_bridge.api.hrms.claims.get_expense_claim_types` - Get claim types
- `nex_bridge.api.hrms.claims.get_expense_claim_summary` - Get claims summary

### Approval APIs  
- `nex_bridge.api.hrms.approvals.pending_approvals` - Get pending approvals
- `nex_bridge.api.hrms.approvals.my_approvals` - Get approval history
- `nex_bridge.api.hrms.approvals.approve_request` - Approve request
- `nex_bridge.api.hrms.approvals.reject_request` - Reject request
- `nex_bridge.api.hrms.approvals.team_members` - Get team members
- `nex_bridge.api.hrms.approvals.approvals_stats` - Get approval statistics

## Security Notes

1. All API methods use `@frappe.whitelist()` which requires authentication
2. The APIs automatically detect the current user and link to their employee record
3. Authorization checks ensure users can only access their own data or data they're authorized to approve
4. All database operations are properly committed with `frappe.db.commit()`

## Troubleshooting

### Common Issues:

1. **"Employee not found" error**: Ensure the user is linked to an Employee record
2. **Permission errors**: Check that the user has the required roles (Employee, HR User, HR Manager)
3. **Workflow errors**: Ensure proper workflow states are set up for Leave Applications and Expense Claims
4. **Import errors**: Make sure HRMS app is installed and all imports are available

### Logs:
Check Frappe logs for detailed error messages:
```bash
tail -f /path/to/frappe-bench/logs/web.error.log
```

## Next Steps

After installation:

1. Test each API endpoint with your mobile app
2. Configure proper workflows for approvals if needed
3. Set up notifications for managers when approvals are pending
4. Customize the approval logic based on your company's requirements
5. Add any additional fields or validations as needed

## Support

For issues related to these APIs:
1. Check Frappe/ERPNext logs
2. Verify HRMS app installation and configuration
3. Test API endpoints individually using Postman or similar tools
4. Ensure proper user-employee linking and permissions