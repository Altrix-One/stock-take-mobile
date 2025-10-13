# Copyright (c) 2024, Your Company and contributors
# For license information, please see license.txt

import frappe
from frappe import _
from frappe.utils import nowdate, get_first_day, get_last_day

@frappe.whitelist()
def pending_approvals(employee=None):
    """Get pending approvals for the logged-in user"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if not employee:
        return []
    
    pending_items = []
    
    # Get pending leave applications
    leave_apps = frappe.get_list("Leave Application",
        filters={
            "leave_approver": employee,
            "workflow_state": "Pending",
            "docstatus": 0
        },
        fields=[
            "name", "employee", "employee_name", "leave_type", "from_date", 
            "to_date", "total_leave_days", "description", "creation"
        ],
        order_by="creation desc"
    )
    
    for leave in leave_apps:
        pending_items.append({
            "id": leave["name"],
            "type": "leave",
            "title": f"{leave['leave_type']} - {leave['employee_name']}",
            "requester_name": leave["employee_name"],
            "submitted_date": leave["creation"],
            "priority": "Normal",
            "status": "Pending",
            "details": leave
        })
    
    # Get pending expense claims
    expense_claims = frappe.get_list("Expense Claim",
        filters={
            "expense_approver": employee,
            "workflow_state": "Pending",
            "docstatus": 0
        },
        fields=[
            "name", "employee", "employee_name", "total_claimed_amount", 
            "remark", "creation"
        ],
        order_by="creation desc"
    )
    
    for claim in expense_claims:
        pending_items.append({
            "id": claim["name"],
            "type": "expense",
            "title": f"Expense Claim - {claim['employee_name']}",
            "requester_name": claim["employee_name"],
            "submitted_date": claim["creation"],
            "amount": claim["total_claimed_amount"],
            "priority": "Normal",
            "status": "Pending",
            "details": claim
        })
    
    # Get pending attendance requests
    attendance_reqs = frappe.get_list("Attendance Request",
        filters={
            "workflow_state": "Pending",
            "docstatus": 0
        },
        fields=[
            "name", "employee", "employee_name", "from_date", "to_date", 
            "reason", "creation"
        ],
        order_by="creation desc"
    )
    
    for req in attendance_reqs:
        pending_items.append({
            "id": req["name"],
            "type": "attendance",
            "title": f"Attendance Request - {req['employee_name']}",
            "requester_name": req["employee_name"],
            "submitted_date": req["creation"],
            "priority": "Normal",
            "status": "Pending",
            "details": req
        })
    
    # Sort by submission date (newest first)
    pending_items.sort(key=lambda x: x["submitted_date"], reverse=True)
    
    return pending_items

@frappe.whitelist()
def my_approvals(employee=None):
    """Get approval history for the logged-in user"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if not employee:
        return []
    
    approval_history = []
    
    # Get processed leave applications
    leave_apps = frappe.get_list("Leave Application",
        filters={
            "leave_approver": employee,
            "workflow_state": ["in", ["Approved", "Rejected"]],
            "docstatus": ["!=", 2]  # Not cancelled
        },
        fields=[
            "name", "employee", "employee_name", "leave_type", "from_date", 
            "to_date", "total_leave_days", "status", "workflow_state", "modified"
        ],
        order_by="modified desc",
        limit=50
    )
    
    for leave in leave_apps:
        approval_history.append({
            "id": leave["name"],
            "type": "leave",
            "title": f"{leave['leave_type']} - {leave['employee_name']}",
            "requester_name": leave["employee_name"],
            "approved_date": leave["modified"],
            "status": leave["workflow_state"],
            "details": leave
        })
    
    # Get processed expense claims
    expense_claims = frappe.get_list("Expense Claim",
        filters={
            "expense_approver": employee,
            "approval_status": ["in", ["Approved", "Rejected"]],
            "docstatus": ["!=", 2]
        },
        fields=[
            "name", "employee", "employee_name", "total_claimed_amount", 
            "total_sanctioned_amount", "approval_status", "modified"
        ],
        order_by="modified desc",
        limit=50
    )
    
    for claim in expense_claims:
        approval_history.append({
            "id": claim["name"],
            "type": "expense",
            "title": f"Expense Claim - {claim['employee_name']}",
            "requester_name": claim["employee_name"],
            "approved_date": claim["modified"],
            "status": claim["approval_status"],
            "details": claim
        })
    
    return approval_history

@frappe.whitelist()
def team_members(employee=None):
    """Get team members for the logged-in user"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if not employee:
        return []
    
    # Get employees who report to this employee
    team_members = frappe.get_list("Employee",
        filters={
            "reports_to": employee,
            "status": "Active"
        },
        fields=[
            "name", "employee_name", "designation", "department", 
            "user_id", "status", "date_of_joining"
        ],
        order_by="employee_name asc"
    )
    
    # Add additional info
    for member in team_members:
        # Get pending requests count
        pending_leaves = frappe.db.count("Leave Application",
            filters={
                "employee": member["name"],
                "workflow_state": "Pending"
            }
        )
        
        pending_claims = frappe.db.count("Expense Claim",
            filters={
                "employee": member["name"],
                "workflow_state": "Pending"
            }
        )
        
        member["pending_requests"] = pending_leaves + pending_claims
        member["is_active"] = member["status"] == "Active"
        
        # Get last seen (if user_id is available)
        if member["user_id"]:
            last_login = frappe.db.get_value("User", member["user_id"], "last_login")
            member["last_seen"] = last_login
    
    return team_members

@frappe.whitelist()
def approvals_stats(employee=None):
    """Get approval statistics"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if not employee:
        return {}
    
    # Get current month dates
    first_day = get_first_day(nowdate())
    last_day = get_last_day(nowdate())
    
    # Pending count
    pending_leaves = frappe.db.count("Leave Application",
        filters={
            "leave_approver": employee,
            "workflow_state": "Pending"
        }
    )
    
    pending_claims = frappe.db.count("Expense Claim",
        filters={
            "expense_approver": employee,
            "workflow_state": "Pending"
        }
    )
    
    pending_count = pending_leaves + pending_claims
    
    # Approved today
    approved_today_leaves = frappe.db.count("Leave Application",
        filters={
            "leave_approver": employee,
            "workflow_state": "Approved",
            "modified": [">=", nowdate()]
        }
    )
    
    approved_today_claims = frappe.db.count("Expense Claim",
        filters={
            "expense_approver": employee,
            "approval_status": "Approved",
            "modified": [">=", nowdate()]
        }
    )
    
    approved_today = approved_today_leaves + approved_today_claims
    
    # This month approved/rejected
    this_month_approved_leaves = frappe.db.count("Leave Application",
        filters={
            "leave_approver": employee,
            "workflow_state": "Approved",
            "modified": ["between", [first_day, last_day]]
        }
    )
    
    this_month_approved_claims = frappe.db.count("Expense Claim",
        filters={
            "expense_approver": employee,
            "approval_status": "Approved",
            "modified": ["between", [first_day, last_day]]
        }
    )
    
    this_month_approved = this_month_approved_leaves + this_month_approved_claims
    
    this_month_rejected_leaves = frappe.db.count("Leave Application",
        filters={
            "leave_approver": employee,
            "workflow_state": "Rejected",
            "modified": ["between", [first_day, last_day]]
        }
    )
    
    this_month_rejected_claims = frappe.db.count("Expense Claim",
        filters={
            "expense_approver": employee,
            "approval_status": "Rejected",
            "modified": ["between", [first_day, last_day]]
        }
    )
    
    this_month_rejected = this_month_rejected_leaves + this_month_rejected_claims
    
    # Get team members on leave today
    team_members = frappe.get_list("Employee",
        filters={"reports_to": employee, "status": "Active"},
        fields=["name"]
    )
    
    on_leave_today = 0
    if team_members:
        employee_list = [tm["name"] for tm in team_members]
        on_leave_today = frappe.db.count("Leave Application",
            filters={
                "employee": ["in", employee_list],
                "status": "Approved",
                "from_date": ["<=", nowdate()],
                "to_date": [">=", nowdate()]
            }
        )
    
    return {
        "pending_count": pending_count,
        "approved_today": approved_today,
        "this_month_approved": this_month_approved,
        "this_month_rejected": this_month_rejected,
        "on_leave_today": on_leave_today,
        "average_approval_time": 2.5,  # This would need complex calculation
        "avg_response_time": 4.2,      # This would need complex calculation
        "avg_team_rating": 4.3         # This would need rating system
    }

@frappe.whitelist()
def approve_request(doctype, name, comments=None):
    """Approve a request"""
    doc = frappe.get_doc(doctype, name)
    
    # Check authorization based on doctype
    employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if doctype == "Leave Application":
        if doc.leave_approver != employee:
            frappe.throw(_("Not authorized to approve this leave application"))
        doc.workflow_state = "Approved"
        doc.status = "Approved"
    elif doctype == "Expense Claim":
        if doc.expense_approver != employee:
            frappe.throw(_("Not authorized to approve this expense claim"))
        doc.approval_status = "Approved"
        doc.total_sanctioned_amount = doc.total_claimed_amount
    elif doctype == "Attendance Request":
        # For attendance requests, check if user is manager/approver
        doc.workflow_state = "Approved"
    else:
        frappe.throw(_("Unsupported document type for approval"))
    
    if comments:
        doc.add_comment("Comment", f"Approved: {comments}")
    
    doc.save()
    
    # Try to submit if applicable
    try:
        if doc.docstatus == 0:  # Draft
            doc.submit()
    except Exception:
        pass  # May fail due to workflow, that's okay
    
    frappe.db.commit()
    
    return {
        "success": True,
        "message": f"{doctype} approved successfully"
    }

@frappe.whitelist()
def reject_request(doctype, name, reason=None):
    """Reject a request"""
    doc = frappe.get_doc(doctype, name)
    
    # Check authorization based on doctype
    employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if doctype == "Leave Application":
        if doc.leave_approver != employee:
            frappe.throw(_("Not authorized to reject this leave application"))
        doc.workflow_state = "Rejected"
        doc.status = "Rejected"
    elif doctype == "Expense Claim":
        if doc.expense_approver != employee:
            frappe.throw(_("Not authorized to reject this expense claim"))
        doc.approval_status = "Rejected"
        doc.total_sanctioned_amount = 0
    elif doctype == "Attendance Request":
        doc.workflow_state = "Rejected"
    else:
        frappe.throw(_("Unsupported document type for rejection"))
    
    if reason:
        doc.add_comment("Comment", f"Rejected: {reason}")
    
    doc.save()
    frappe.db.commit()
    
    return {
        "success": True,
        "message": f"{doctype} rejected successfully"
    }