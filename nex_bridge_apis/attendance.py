# Copyright (c) 2024, Your Company and contributors
# For license information, please see license.txt

import frappe
from frappe import _
from frappe.utils import now, getdate, nowdate

@frappe.whitelist()
def checkin(employee=None):
    """Create Employee Checkin record for check-in"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if not employee:
        frappe.throw(_("Employee not found for user"))
    
    # Create Employee Checkin
    checkin_doc = frappe.get_doc({
        "doctype": "Employee Checkin",
        "employee": employee,
        "time": now(),
        "log_type": "IN"
    })
    checkin_doc.insert()
    frappe.db.commit()
    
    return {
        "success": True,
        "name": checkin_doc.name,
        "time": checkin_doc.time,
        "message": "Checked in successfully"
    }

@frappe.whitelist()
def checkout(employee=None):
    """Create Employee Checkin record for check-out"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if not employee:
        frappe.throw(_("Employee not found for user"))
    
    # Create Employee Checkin
    checkout_doc = frappe.get_doc({
        "doctype": "Employee Checkin",
        "employee": employee,
        "time": now(),
        "log_type": "OUT"
    })
    checkout_doc.insert()
    frappe.db.commit()
    
    return {
        "success": True,
        "name": checkout_doc.name,
        "time": checkout_doc.time,
        "message": "Checked out successfully"
    }

@frappe.whitelist()
def get_attendance_history(employee=None, limit=50):
    """Get attendance history for employee"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if not employee:
        return []
    
    # Get attendance records from last 30 days
    from_date = frappe.utils.add_days(nowdate(), -30)
    
    attendance_list = frappe.get_list("Attendance",
        filters={
            "employee": employee,
            "attendance_date": [">=", from_date]
        },
        fields=[
            "name", "employee", "attendance_date", "status", 
            "in_time", "out_time", "working_hours", "late_entry", "early_exit"
        ],
        order_by="attendance_date desc",
        limit=limit
    )
    
    return attendance_list

@frappe.whitelist()
def get_attendance_requests(employee=None, for_approval=0):
    """Get attendance requests"""
    if not employee and not for_approval:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    filters = {}
    if employee and not for_approval:
        filters["employee"] = employee
    
    # If for_approval, get requests that need approval
    if for_approval:
        filters["workflow_state"] = "Pending"
    
    requests = frappe.get_list("Attendance Request",
        filters=filters,
        fields=[
            "name", "employee", "employee_name", "from_date", "to_date", 
            "half_day", "half_day_date", "reason", "status", "workflow_state"
        ],
        order_by="creation desc",
        limit=50
    )
    
    return requests

@frappe.whitelist()
def submit_attendance_request(employee=None, from_date=None, to_date=None, reason=None, half_day=0, half_day_date=None):
    """Submit attendance request"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if not employee:
        frappe.throw(_("Employee not found"))
    
    # Create Attendance Request
    doc = frappe.get_doc({
        "doctype": "Attendance Request",
        "employee": employee,
        "from_date": from_date,
        "to_date": to_date,
        "reason": reason,
        "half_day": half_day,
        "half_day_date": half_day_date if half_day else None
    })
    doc.insert()
    doc.submit()
    frappe.db.commit()
    
    return {
        "success": True,
        "name": doc.name,
        "message": "Attendance request submitted successfully"
    }

@frappe.whitelist()
def get_shift_types():
    """Get available shift types"""
    shift_types = frappe.get_list("Shift Type",
        filters={"disabled": 0},
        fields=["name", "start_time", "end_time"],
        order_by="name asc"
    )
    
    return [shift["name"] for shift in shift_types]

@frappe.whitelist()
def get_shifts(employee=None):
    """Get shift assignments for employee"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if not employee:
        return []
    
    shifts = frappe.get_list("Shift Assignment",
        filters={
            "employee": employee,
            "status": "Active"
        },
        fields=[
            "name", "employee", "shift_type", "start_date", "end_date", "status"
        ],
        order_by="start_date desc",
        limit=20
    )
    
    return shifts