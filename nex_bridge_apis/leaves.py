# Copyright (c) 2024, Your Company and contributors
# For license information, please see license.txt

import frappe
from frappe import _
from frappe.utils import nowdate, getdate

@frappe.whitelist()
def get_leave_applications(employee=None, for_approval=0):
    """Get leave applications for employee or for approval"""
    if not employee and not for_approval:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    filters = {}
    if employee and not for_approval:
        filters["employee"] = employee
    
    # If for_approval, get applications that need approval
    if for_approval:
        filters["workflow_state"] = "Pending"
    
    applications = frappe.get_list("Leave Application",
        filters=filters,
        fields=[
            "name", "employee", "employee_name", "leave_type", "from_date", "to_date", 
            "total_leave_days", "status", "workflow_state", "description", 
            "half_day", "half_day_date", "leave_approver"
        ],
        order_by="creation desc",
        limit=100
    )
    
    return applications

@frappe.whitelist()
def get_leave_balance_map(employee=None):
    """Get leave balance for employee"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if not employee:
        return {}
    
    # Get leave allocations for current leave period
    from hrms.hr.utils import get_leave_period
    leave_period = get_leave_period(nowdate(), employee)
    
    if not leave_period:
        return {}
    
    # Get leave balance using HRMS utility
    try:
        from hrms.hr.doctype.leave_application.leave_application import get_leave_balance_on
        
        leave_types = frappe.get_list("Leave Type", 
            filters={"is_active": 1}, 
            fields=["name"]
        )
        
        balance_map = {}
        for leave_type in leave_types:
            lt = leave_type["name"]
            balance = get_leave_balance_on(employee, lt, nowdate())
            
            # Get total allocated
            allocated = frappe.db.get_value("Leave Allocation",
                filters={
                    "employee": employee,
                    "leave_type": lt,
                    "from_date": ["<=", nowdate()],
                    "to_date": [">=", nowdate()],
                    "docstatus": 1
                },
                fieldname="total_leaves_allocated"
            ) or 0
            
            # Get total taken
            taken = allocated - balance if balance >= 0 else allocated
            
            balance_map[lt] = {
                "leaves_allocated": allocated,
                "leaves_taken": taken,
                "balance_leaves": balance
            }
        
        return balance_map
        
    except ImportError:
        # Fallback if HRMS methods not available
        return {}

@frappe.whitelist()
def get_leave_types(employee=None):
    """Get available leave types for employee"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    leave_types = frappe.get_list("Leave Type",
        filters={"is_active": 1},
        fields=["name", "max_leaves_allowed", "is_carry_forward", "is_optional_leave"],
        order_by="name asc"
    )
    
    return [lt["name"] for lt in leave_types]

@frappe.whitelist()
def submit_leave_application(employee=None, leave_type=None, from_date=None, to_date=None, 
                           reason=None, half_day=0, half_day_date=None, leave_approver=None):
    """Submit leave application"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if not employee:
        frappe.throw(_("Employee not found"))
    
    # Create Leave Application
    doc = frappe.get_doc({
        "doctype": "Leave Application",
        "employee": employee,
        "leave_type": leave_type,
        "from_date": from_date,
        "to_date": to_date,
        "description": reason,
        "half_day": half_day,
        "half_day_date": half_day_date if half_day else None,
        "leave_approver": leave_approver
    })
    
    doc.insert()
    
    # Try to submit automatically if no workflow
    try:
        doc.submit()
        frappe.db.commit()
        
        return {
            "success": True,
            "name": doc.name,
            "status": doc.status,
            "message": "Leave application submitted successfully"
        }
    except Exception as e:
        # If submission fails, leave as draft
        frappe.db.commit()
        
        return {
            "success": True,
            "name": doc.name,
            "status": "Draft",
            "message": "Leave application created (pending approval)"
        }

@frappe.whitelist()
def cancel_leave_application(name, reason=None):
    """Cancel leave application"""
    doc = frappe.get_doc("Leave Application", name)
    
    # Check if user can cancel
    if doc.employee != frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name"):
        frappe.throw(_("You can only cancel your own leave applications"))
    
    if reason:
        doc.add_comment("Comment", f"Cancellation reason: {reason}")
    
    doc.cancel()
    frappe.db.commit()
    
    return {
        "success": True,
        "message": "Leave application cancelled successfully"
    }

@frappe.whitelist()
def get_leave_approval_details(employee):
    """Get leave approval details for employee"""
    # Get employee's leave approver
    leave_approver = frappe.db.get_value("Employee", employee, "leave_approver")
    
    # Get department approver if no direct leave approver
    if not leave_approver:
        department = frappe.db.get_value("Employee", employee, "department")
        if department:
            leave_approver = frappe.db.get_value("Department Approver", 
                {"parent": department, "approver_type": "Leave Approver"}, 
                "approver"
            )
    
    return {
        "leave_approver": leave_approver,
        "employee": employee
    }

@frappe.whitelist()
def approve_leave_application(name, approve=1, comments=None):
    """Approve or reject leave application"""
    doc = frappe.get_doc("Leave Application", name)
    
    # Check if user can approve
    employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    if doc.leave_approver != employee:
        frappe.throw(_("You are not authorized to approve this leave application"))
    
    if approve:
        doc.status = "Approved"
        if comments:
            doc.add_comment("Comment", f"Approved: {comments}")
        
        # Submit the document
        doc.submit()
        message = "Leave application approved successfully"
    else:
        doc.status = "Rejected" 
        if comments:
            doc.add_comment("Comment", f"Rejected: {comments}")
        message = "Leave application rejected"
    
    doc.save()
    frappe.db.commit()
    
    return {
        "success": True,
        "status": doc.status,
        "message": message
    }