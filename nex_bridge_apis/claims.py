# Copyright (c) 2024, Your Company and contributors
# For license information, please see license.txt

import frappe
from frappe import _
from frappe.utils import nowdate, flt

@frappe.whitelist()
def get_expense_claims(employee=None, for_approval=0):
    """Get expense claims for employee or for approval"""
    if not employee and not for_approval:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    filters = {}
    if employee and not for_approval:
        filters["employee"] = employee
    
    # If for_approval, get claims that need approval
    if for_approval:
        filters["workflow_state"] = "Pending"
    
    claims = frappe.get_list("Expense Claim",
        filters=filters,
        fields=[
            "name", "employee", "employee_name", "total_claimed_amount", 
            "total_sanctioned_amount", "status", "workflow_state", 
            "posting_date", "approval_status", "remark"
        ],
        order_by="creation desc",
        limit=100
    )
    
    return claims

@frappe.whitelist()
def get_expense_claim_types():
    """Get available expense claim types"""
    claim_types = frappe.get_list("Expense Claim Type",
        fields=["name", "description"],
        order_by="name asc"
    )
    
    return [ct["name"] for ct in claim_types]

@frappe.whitelist()
def get_expense_claim_summary(employee=None):
    """Get expense claim summary for employee"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if not employee:
        return {}
    
    # Get current month's statistics
    from frappe.utils import get_first_day, get_last_day
    first_day = get_first_day(nowdate())
    last_day = get_last_day(nowdate())
    
    # Total claimed this month
    total_claimed = frappe.db.get_value("Expense Claim",
        filters={
            "employee": employee,
            "posting_date": ["between", [first_day, last_day]],
            "docstatus": ["!=", 2]  # Not cancelled
        },
        fieldname="sum(total_claimed_amount)"
    ) or 0
    
    # Total approved this month
    total_approved = frappe.db.get_value("Expense Claim",
        filters={
            "employee": employee,
            "posting_date": ["between", [first_day, last_day]],
            "status": "Approved"
        },
        fieldname="sum(total_sanctioned_amount)"
    ) or 0
    
    # Pending claims count
    pending_count = frappe.db.count("Expense Claim",
        filters={
            "employee": employee,
            "status": ["in", ["Draft", "Submitted"]],
            "docstatus": ["!=", 2]
        }
    )
    
    return {
        "total_claimed_this_month": total_claimed,
        "total_approved_this_month": total_approved,
        "pending_claims_count": pending_count,
        "employee": employee
    }

@frappe.whitelist()
def submit_expense_claim(employee=None, total_claimed_amount=0, expenses=None, remark=None, expense_approver=None):
    """Submit expense claim"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if not employee:
        frappe.throw(_("Employee not found"))
    
    # Get company from employee
    company = frappe.db.get_value("Employee", employee, "company")
    
    # Create Expense Claim
    doc = frappe.get_doc({
        "doctype": "Expense Claim",
        "employee": employee,
        "company": company,
        "total_claimed_amount": flt(total_claimed_amount),
        "remark": remark,
        "expense_approver": expense_approver
    })
    
    # Add expense details if provided
    if expenses and isinstance(expenses, list):
        for expense in expenses:
            doc.append("expenses", {
                "expense_type": expense.get("expense_type"),
                "expense_date": expense.get("expense_date", nowdate()),
                "description": expense.get("description"),
                "amount": flt(expense.get("amount", 0)),
                "sanctioned_amount": flt(expense.get("sanctioned_amount", expense.get("amount", 0)))
            })
    
    doc.insert()
    
    # Try to submit automatically
    try:
        doc.submit()
        frappe.db.commit()
        
        return {
            "success": True,
            "name": doc.name,
            "status": doc.status,
            "message": "Expense claim submitted successfully"
        }
    except Exception as e:
        # If submission fails, leave as draft
        frappe.db.commit()
        
        return {
            "success": True,
            "name": doc.name,
            "status": "Draft",
            "message": "Expense claim created (pending approval)"
        }

@frappe.whitelist()
def update_expense_claim(name, **kwargs):
    """Update expense claim"""
    doc = frappe.get_doc("Expense Claim", name)
    
    # Check if user can update
    if doc.employee != frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name"):
        frappe.throw(_("You can only update your own expense claims"))
    
    # Update allowed fields
    allowed_fields = ["total_claimed_amount", "remark", "expense_approver"]
    for field in allowed_fields:
        if field in kwargs:
            setattr(doc, field, kwargs[field])
    
    doc.save()
    frappe.db.commit()
    
    return {
        "success": True,
        "name": doc.name,
        "message": "Expense claim updated successfully"
    }

@frappe.whitelist()
def save_expense_claim_draft(employee=None, total_claimed_amount=0, expenses=None, remark=None):
    """Save expense claim as draft"""
    if not employee:
        employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    
    if not employee:
        frappe.throw(_("Employee not found"))
    
    # Get company from employee
    company = frappe.db.get_value("Employee", employee, "company")
    
    # Create Expense Claim as draft
    doc = frappe.get_doc({
        "doctype": "Expense Claim",
        "employee": employee,
        "company": company,
        "total_claimed_amount": flt(total_claimed_amount),
        "remark": remark
    })
    
    # Add expense details if provided
    if expenses and isinstance(expenses, list):
        for expense in expenses:
            doc.append("expenses", {
                "expense_type": expense.get("expense_type"),
                "expense_date": expense.get("expense_date", nowdate()),
                "description": expense.get("description"),
                "amount": flt(expense.get("amount", 0)),
                "sanctioned_amount": flt(expense.get("sanctioned_amount", expense.get("amount", 0)))
            })
    
    doc.insert()
    frappe.db.commit()
    
    return {
        "success": True,
        "name": doc.name,
        "status": "Draft",
        "message": "Expense claim saved as draft"
    }

@frappe.whitelist()
def approve_expense_claim(name, approve=1, comments=None, sanctioned_amount=None):
    """Approve or reject expense claim"""
    doc = frappe.get_doc("Expense Claim", name)
    
    # Check if user can approve
    employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    if doc.expense_approver != employee:
        frappe.throw(_("You are not authorized to approve this expense claim"))
    
    if approve:
        doc.approval_status = "Approved"
        if sanctioned_amount is not None:
            doc.total_sanctioned_amount = flt(sanctioned_amount)
        else:
            doc.total_sanctioned_amount = doc.total_claimed_amount
            
        if comments:
            doc.add_comment("Comment", f"Approved: {comments}")
        
        # Submit the document
        doc.submit()
        message = "Expense claim approved successfully"
    else:
        doc.approval_status = "Rejected"
        doc.total_sanctioned_amount = 0
        if comments:
            doc.add_comment("Comment", f"Rejected: {comments}")
        message = "Expense claim rejected"
    
    doc.save()
    frappe.db.commit()
    
    return {
        "success": True,
        "status": doc.approval_status,
        "message": message
    }

@frappe.whitelist()
def get_expense_approval_details(employee):
    """Get expense approval details for employee"""
    # Get employee's expense approver
    expense_approver = frappe.db.get_value("Employee", employee, "expense_approver")
    
    # Get department approver if no direct expense approver
    if not expense_approver:
        department = frappe.db.get_value("Employee", employee, "department")
        if department:
            expense_approver = frappe.db.get_value("Department Approver", 
                {"parent": department, "approver_type": "Expense Approver"}, 
                "approver"
            )
    
    return {
        "expense_approver": expense_approver,
        "employee": employee
    }

@frappe.whitelist()
def get_company_cost_center_and_expense_account(company):
    """Get default cost center and expense account for company"""
    # Get default cost center
    cost_center = frappe.db.get_value("Company", company, "cost_center")
    
    # Get default expense account (simplified - you may need to customize this)
    expense_account = frappe.db.get_value("Account", 
        {"company": company, "account_type": "Expense", "is_group": 0}, 
        "name"
    )
    
    return {
        "cost_center": cost_center,
        "expense_account": expense_account,
        "company": company
    }