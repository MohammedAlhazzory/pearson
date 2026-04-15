<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Expenses for ${person.name}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container mt-4">
    <h1>Expenses for ${person.name}</h1>
    <p><strong>Email:</strong> ${person.email}</p>
    <a href="persons" class="btn btn-secondary mb-3">← Back to Persons</a>

    <!-- Filter Form -->
    <form method="get" action="expenses" class="row g-3 mb-4">
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
            <a href="expenses?personId=${param.personId}" class="btn btn-outline-secondary">Reset</a>
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
        </tr>
        </thead>
        <tbody>
        <c:choose>
            <c:when test="${empty expenses}">
                <tr><td colspan="4" class="text-center">No expenses found.</td></tr>
            </c:when>
            <c:otherwise>
                <c:forEach items="${expenses}" var="expense">
                    <tr>
                        <td>${expense.transactionDate}</td>
                        <td class="${expense.type == 'INCOME' ? 'text-success fw-bold' : 'text-danger fw-bold'}">
                            ${expense.signedAmount}
                        </td>
                        <td>${expense.type == 'INCOME' ? 'Income' : 'Expense'}</td>
                        <td>${fn:escapeXml(expense.description)}</td>
                    </tr>
                </c:forEach>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>