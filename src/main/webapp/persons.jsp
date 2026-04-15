<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Expense Manager - Persons</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container mt-4">
    <h1 class="mb-4">Persons List</h1>

    <!-- Button to open modal -->
    <button type="button" class="btn btn-primary mb-3" data-bs-toggle="modal" data-bs-target="#addPersonModal">
        + Add New Person
    </button>

    <!-- Search Form -->
    <form method="get" action="persons" class="row g-3 mb-4">
        <div class="col-md-5">
            <label for="name" class="form-label">Name</label>
            <input type="text" class="form-control" name="name" id="name" value="${param.name}" placeholder="Search by name...">
        </div>
        <div class="col-md-5">
            <label for="email" class="form-label">Email</label>
            <input type="text" class="form-control" name="email" id="email" value="${param.email}" placeholder="Search by email...">
        </div>
        <div class="col-md-2 d-flex align-items-end">
            <button type="submit" class="btn btn-secondary me-2">Search</button>
            <a href="persons" class="btn btn-outline-secondary">Reset</a>
        </div>
    </form>

    <!-- Persons Table -->
    <table class="table table-bordered table-striped">
        <thead class="table-dark">
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Email</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <c:choose>
            <c:when test="${empty persons}">
                <tr><td colspan="4" class="text-center">No persons found.</td></tr>
            </c:when>
            <c:otherwise>
                <c:forEach items="${persons}" var="person">
                    <tr>
                        <td>${person.id}</td>
                        <td>${fn:escapeXml(person.name)}</td>
                        <td>${fn:escapeXml(person.email)}</td>
                        <td class="d-flex gap-2">
                            <a href="expenses?personId=${person.id}" class="btn btn-sm btn-info">View Expenses</a>

                            <button
                                    type="button"
                                    class="btn btn-sm btn-warning"
                                    data-bs-toggle="modal"
                                    data-bs-target="#editPersonModal"
                                    data-person-id="${person.id}"
                                    data-person-name="${fn:escapeXml(person.name)}"
                                    data-person-email="${fn:escapeXml(person.email)}">
                                Edit
                            </button>

                            <form action="persons" method="post" class="m-0" onsubmit="return confirm('Delete this person?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="${person.id}">
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

<!-- Modal Dialog for Add Person -->
<div class="modal fade" id="addPersonModal" tabindex="-1" aria-labelledby="modalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalLabel">Add New Person</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="addPersonForm" action="persons" method="post">
                    <input type="hidden" name="action" value="add">
                    <div class="mb-3">
                        <label for="nameInput" class="form-label">Name</label>
                        <input type="text" class="form-control" name="name" id="nameInput" required>
                    </div>
                    <div class="mb-3">
                        <label for="emailInput" class="form-label">Email</label>
                        <input type="email" class="form-control" name="email" id="emailInput" required>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" form="addPersonForm" class="btn btn-primary">Save</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Dialog for Edit Person -->
<div class="modal fade" id="editPersonModal" tabindex="-1" aria-labelledby="editPersonModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="editPersonModalLabel">Edit Person</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="editPersonForm" action="persons" method="post">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" id="editPersonId">
                    <div class="mb-3">
                        <label class="form-label">Name</label>
                        <input type="text" class="form-control" name="name" id="editPersonName" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-control" name="email" id="editPersonEmail" required>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" form="editPersonForm" class="btn btn-primary">Save Changes</button>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS Bundle (includes Popper) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const editPersonModal = document.getElementById('editPersonModal');
    editPersonModal.addEventListener('show.bs.modal', event => {
        const button = event.relatedTarget;
        const id = button.getAttribute('data-person-id');
        const name = button.getAttribute('data-person-name');
        const email = button.getAttribute('data-person-email');

        document.getElementById('editPersonId').value = id;
        document.getElementById('editPersonName').value = name;
        document.getElementById('editPersonEmail').value = email;
    });
</script>
</body>
</html>