<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Expenses for ${person.name}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="container mt-4">
    <h1>Expenses for ${person.name}</h1>
    <p><strong>Email:</strong> ${person.email}</p>
    <a href="${pageContext.request.contextPath}/persons" class="btn btn-secondary mb-3">← Back to Persons</a>

    <!-- Button to open add-expense modal -->
    <button type="button" class="btn btn-primary mb-3 ms-2" data-bs-toggle="modal" data-bs-target="#addExpenseModal">
        + Add Transaction
    </button>

    <!-- Filter Form -->
    <form method="get" action="${pageContext.request.contextPath}/expenses" class="row g-3 mb-4">
        <input type="hidden" name="personId" value="${param.personId}">
        <div class="col-md-2">
            <label class="form-label">Min Amount</label>
            <input type="number" step="0.01" class="form-control" name="minAmount" value="${param.minAmount}">
        </div>
        <div class="col-md-2">
            <label class="form-label">Max Amount</label>
            <input type="number" step="0.01" class="form-control" name="maxAmount" value="${param.maxAmount}">
        </div>
        <div class="col-md-2">
            <label class="form-label">From Date</label>
            <input type="date" class="form-control" name="fromDate" value="${param.fromDate}">
        </div>
        <div class="col-md-2">
            <label class="form-label">To Date</label>
            <input type="date" class="form-control" name="toDate" value="${param.toDate}">
        </div>
        <div class="col-md-2">
            <label class="form-label">Type</label>
            <select class="form-select" name="type">
                <option value="">All</option>
                <option value="INCOME" ${param.type == 'INCOME' ? 'selected' : ''}>Income</option>
                <option value="EXPENSE" ${param.type == 'EXPENSE' ? 'selected' : ''}>Expense</option>
            </select>
        </div>
        <div class="col-md-2 d-flex align-items-end">
            <button type="submit" class="btn btn-secondary me-2">Filter</button>
            <a href="${pageContext.request.contextPath}/expenses?personId=${param.personId}" class="btn btn-outline-secondary">Reset</a>
        </div>
    </form>

    <!-- Summary -->
    <div class="alert alert-info">
        <strong>Total Income:</strong> ${totalIncome} &nbsp;|&nbsp;
        <strong>Total Expense:</strong> ${totalExpense} &nbsp;|&nbsp;
        <strong>Balance:</strong> ${balance}
    </div>

    <!-- Expenses Table -->
    <table class="table table-bordered">
        <thead class="table-dark">
        <tr>
            <th>Date</th>
            <th>Amount</th>
            <th>Type</th>
            <th>Description</th>
            <th style="width: 100px;">Actions</th>
        </tr>
        </thead>
        <tbody>
        <c:choose>
            <c:when test="${empty expenses}">
                <tr><td colspan="5" class="text-center">No expenses found.</td></tr>
            </c:when>
            <c:otherwise>
                <c:forEach items="${expenses}" var="expense">
                    <tr>
                        <td>${expense.transactionDateFormatted}</td>
                        <td class="${expense.type == 'INCOME' ? 'text-success fw-bold' : 'text-danger fw-bold'}">
                            ${expense.signedAmount}
                        </td>
                        <td>${expense.type == 'INCOME' ? 'Income' : 'Expense'}</td>
                        <td>${fn:escapeXml(expense.description)}</td>
                        <td class="d-flex gap-2">
                            <button
                                    type="button"
                                    class="btn btn-sm btn-warning"
                                    data-bs-toggle="modal"
                                    data-bs-target="#editExpenseModal"
                                    data-expense-id="${expense.id}"
                                    data-expense-type="${expense.type}"
                                    data-expense-amount="${expense.amount}"
                                    data-expense-description="${fn:escapeXml(expense.description)}">
                                Edit
                            </button>

                            <form action="${pageContext.request.contextPath}/expenses" method="post" class="m-0" onsubmit="return confirm('Delete this transaction?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="personId" value="${person.id}">
                                <input type="hidden" name="id" value="${expense.id}">
                                <button type="submit" class="btn btn-sm btn-danger">Delete</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>

<!-- Modal Dialog for Add Expense -->
<div class="modal fade" id="addExpenseModal" tabindex="-1" aria-labelledby="addExpenseModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addExpenseModalLabel">Add Transaction</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="addExpenseForm" action="${pageContext.request.contextPath}/expenses" method="post">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="personId" value="${person.id}">

                    <div class="mb-3">
                        <label class="form-label">Type</label>
                        <select class="form-select" name="type" required>
                            <option value="INCOME">Income</option>
                            <option value="EXPENSE">Expense</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Amount</label>
                        <input type="number" step="0.01" min="0.01" class="form-control" name="amount" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Date & Time</label>
                        <input type="datetime-local" class="form-control" name="dateTime">
                        <div class="form-text">If empty, current date/time will be used.</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Description</label>
                        <textarea class="form-control" name="description" rows="2"></textarea>
                    </div>
                </form>

                <!-- Error container for AJAX responses -->
                <div id="add-errors" class="alert alert-danger d-none"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" form="addExpenseForm" class="btn btn-primary">Save</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Dialog for Edit Expense -->
<div class="modal fade" id="editExpenseModal" tabindex="-1" aria-labelledby="editExpenseModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="editExpenseModalLabel">Edit Transaction</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="editExpenseForm" action="${pageContext.request.contextPath}/expenses" method="post">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="personId" value="${person.id}">
                    <input type="hidden" name="id" id="editExpenseId">

                    <div class="mb-3">
                        <label class="form-label">Type</label>
                        <select class="form-select" name="type" id="editExpenseType" required>
                            <option value="INCOME">Income</option>
                            <option value="EXPENSE">Expense</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Amount</label>
                        <input type="number" step="0.01" min="0.01" class="form-control" name="amount" id="editExpenseAmount" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Date & Time</label>
                        <input type="datetime-local" class="form-control" name="dateTime" id="editExpenseDateTime">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Description</label>
                        <textarea class="form-control" name="description" rows="2" id="editExpenseDescription"></textarea>
                    </div>
                </form>

                <!-- Error container for AJAX responses -->
                <div id="edit-errors" class="alert alert-danger d-none"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" form="editExpenseForm" class="btn btn-primary">Save Changes</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function showFieldError(prefix, fieldName, message) {
        const el = document.getElementById(prefix + '-error-' + fieldName);
        if (el) {
            el.textContent = message || '';
            el.classList.remove('d-none');
        }
    }
    function clearFieldErrors(prefix, fields) {
        fields.forEach(f => {
            const el = document.getElementById(prefix + '-error-' + f);
            if (el) {
                el.textContent = '';
                el.classList.add('d-none');
            }
        });
        const container = document.getElementById(prefix + '-errors');
        if (container) { container.classList.add('d-none'); container.innerHTML = ''; }
    }

    async function submitFormAjax(form, prefix, modalId) {
        clearFieldErrors(prefix, ['amount','type','dateTime','description']);
        const data = new URLSearchParams(new FormData(form));

        // Important: use attribute value (string), not a DOM element
        const actionUrl = form.getAttribute('action') || (window.location.pathname.split('/').slice(0,2).join('/') + '/expenses');

        try {
            const resp = await fetch(actionUrl, {
                method: (form.getAttribute('method') || form.method || 'POST').toUpperCase(),
                headers: {
                    'X-Requested-With': 'XMLHttpRequest',
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                },
                body: data.toString()
            });

            if (resp.status === 200) {
                const json = await resp.json().catch(()=>({success:true}));
                if (json && json.success) {
                    // close modal and reload to show changes
                    const modalEl = document.getElementById(modalId);
                    const bsModal = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
                    bsModal.hide();
                    location.reload();
                    return;
                }
            }

            // handle validation errors (400) or other structured responses
            const json = await resp.json().catch(()=>null);
            if (json && json.errors) {
                const errs = json.errors;
                let any = false;
                for (const key in errs) {
                    any = true;
                    showFieldError(prefix, key, errs[key]);
                }
                if (any) {
                    const container = document.getElementById(prefix + '-errors');
                    if (container) {
                        container.classList.remove('d-none');
                        container.innerHTML = '<strong>Please fix the errors below.</strong>';
                    }
                    return; // keep modal open
                }
            }

            // If server returned a general message (eg 500) show it
            if (json && json.message) {
                const container = document.getElementById(prefix + '-errors');
                if (container) {
                    container.classList.remove('d-none');
                    container.innerHTML = json.message;
                }
                return;
            }

            // fallback: show generic error
            const container = document.getElementById(prefix + '-errors');
            if (container) {
                container.classList.remove('d-none');
                container.innerHTML = 'An error occurred. Please try again.';
            }
        } catch (e) {
            const container = document.getElementById(prefix + '-errors');
            if (container) {
                container.classList.remove('d-none');
                container.innerHTML = 'Network error. Please try again.';
            }
        }
    }

    // wire add form
    document.addEventListener('DOMContentLoaded', function() {
        const addForm = document.getElementById('addExpenseForm');
        if (addForm) {
            // add per-field error spans if not present
            const amount = addForm.querySelector('input[name="amount"]');
            if (amount && !document.getElementById('add-error-amount')) {
                amount.insertAdjacentHTML('afterend','<div id="add-error-amount" class="text-danger small d-none"></div>');
            }
            const type = addForm.querySelector('select[name="type"]');
            if (type && !document.getElementById('add-error-type')) {
                type.insertAdjacentHTML('afterend','<div id="add-error-type" class="text-danger small d-none"></div>');
            }
            const date = addForm.querySelector('input[name="dateTime"]');
            if (date && !document.getElementById('add-error-dateTime')) {
                date.insertAdjacentHTML('afterend','<div id="add-error-dateTime" class="text-danger small d-none"></div>');
            }
            const desc = addForm.querySelector('textarea[name="description"]');
            if (desc && !document.getElementById('add-error-description')) {
                desc.insertAdjacentHTML('afterend','<div id="add-error-description" class="text-danger small d-none"></div>');
            }

            // container for general errors
            if (!document.getElementById('add-errors')) {
                addForm.insertAdjacentHTML('afterbegin','<div id="add-errors" class="alert alert-danger d-none"></div>');
            }

            addForm.addEventListener('submit', function(e) {
                e.preventDefault();
                // ensure action=add present
                if (!addForm.querySelector('input[name="action"]')) {
                    addForm.insertAdjacentHTML('afterbegin','<input type="hidden" name="action" value="add">');
                } else {
                    addForm.querySelector('input[name="action"]').value = 'add';
                }
                submitFormAjax(addForm, 'add', 'addExpenseModal');
            });
        }

        const editForm = document.getElementById('editExpenseForm');
        if (editForm) {
            const amount = editForm.querySelector('input[name="amount"]');
            if (amount && !document.getElementById('edit-error-amount')) {
                amount.insertAdjacentHTML('afterend','<div id="edit-error-amount" class="text-danger small d-none"></div>');
            }
            const type = editForm.querySelector('select[name="type"]');
            if (type && !document.getElementById('edit-error-type')) {
                type.insertAdjacentHTML('afterend','<div id="edit-error-type" class="text-danger small d-none"></div>');
            }
            const date = editForm.querySelector('input[name="dateTime"]');
            if (date && !document.getElementById('edit-error-dateTime')) {
                date.insertAdjacentHTML('afterend','<div id="edit-error-dateTime" class="text-danger small d-none"></div>');
            }
            const desc = editForm.querySelector('textarea[name="description"]');
            if (desc && !document.getElementById('edit-error-description')) {
                desc.insertAdjacentHTML('afterend','<div id="edit-error-description" class="text-danger small d-none"></div>');
            }

            if (!document.getElementById('edit-errors')) {
                editForm.insertAdjacentHTML('afterbegin','<div id="edit-errors" class="alert alert-danger d-none"></div>');
            }

            editForm.addEventListener('submit', function(e) {
                e.preventDefault();
                if (!editForm.querySelector('input[name="action"]')) {
                    editForm.insertAdjacentHTML('afterbegin','<input type="hidden" name="action" value="update">');
                } else {
                    editForm.querySelector('input[name="action"]').value = 'update';
                }
                submitFormAjax(editForm, 'edit', 'editExpenseModal');
            });
        }

        // populate edit modal fields when opened
        const editExpenseModal = document.getElementById('editExpenseModal');
        if (editExpenseModal) {
            editExpenseModal.addEventListener('show.bs.modal', event => {
                const button = event.relatedTarget;
                const id = button.getAttribute('data-expense-id');
                const type = button.getAttribute('data-expense-type');
                const amount = button.getAttribute('data-expense-amount');
                const description = button.getAttribute('data-expense-description');

                document.getElementById('editExpenseId').value = id;
                document.getElementById('editExpenseType').value = type;
                document.getElementById('editExpenseAmount').value = amount;
                document.getElementById('editExpenseDescription').value = description || '';

                // clear previous errors
                clearFieldErrors('edit', ['amount','type','dateTime','description']);
            });
        }
    });
</script>
</body>
</html>