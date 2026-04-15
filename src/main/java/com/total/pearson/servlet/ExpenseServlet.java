package com.total.pearson.servlet;

import com.total.pearson.entity.Expense;
import com.total.pearson.entity.Person;
import com.total.pearson.service.ExpenseService;
import com.total.pearson.service.PersonService;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import java.util.Set;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/expenses")
public class ExpenseServlet extends HttpServlet {
    @EJB
    private ExpenseService expenseService;

    @EJB
    private PersonService personService;

    private static final DateTimeFormatter INPUT_DATE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    private static final ValidatorFactory VALIDATOR_FACTORY = Validation.buildDefaultValidatorFactory();
    private static final Validator VALIDATOR = VALIDATOR_FACTORY.getValidator();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String personIdParam = request.getParameter("personId");
        if (personIdParam == null || personIdParam.trim().isEmpty()) {
            response.sendRedirect("persons");
            return;
        }

        Long personId = Long.parseLong(personIdParam);
        Person person = personService.findPersonById(personId);
        if (person == null) {
            response.sendRedirect("persons");
            return;
        }

        
        String minAmountParam = request.getParameter("minAmount");
        String maxAmountParam = request.getParameter("maxAmount");
        String fromDateParam = request.getParameter("fromDate");
        String toDateParam = request.getParameter("toDate");
        String typeParam = request.getParameter("type");

        BigDecimal minAmount = null;
        BigDecimal maxAmount = null;
        LocalDateTime fromDate = null;
        LocalDateTime toDate = null;
        Expense.TransactionType type = null;

        if (minAmountParam != null && !minAmountParam.trim().isEmpty())
            minAmount = new BigDecimal(minAmountParam);
        if (maxAmountParam != null && !maxAmountParam.trim().isEmpty())
            maxAmount = new BigDecimal(maxAmountParam);
        if (fromDateParam != null && !fromDateParam.trim().isEmpty())
            fromDate = LocalDate.parse(fromDateParam).atStartOfDay();
        if (toDateParam != null && !toDateParam.trim().isEmpty())
            toDate = LocalDate.parse(toDateParam).atTime(23, 59, 59);
        if (typeParam != null && !typeParam.trim().isEmpty())
            type = Expense.TransactionType.valueOf(typeParam);

        List<Expense> expenses = expenseService.findExpensesByPersonIdWithFilters(
                personId, minAmount, maxAmount, fromDate, toDate, type);


        BigDecimal totalIncome = BigDecimal.ZERO;
        BigDecimal totalExpense = BigDecimal.ZERO;
        for (Expense e : expenses) {
            if (e.getType() == Expense.TransactionType.INCOME)
                totalIncome = totalIncome.add(e.getAmount());
            else
                totalExpense = totalExpense.add(e.getAmount());
        }
        BigDecimal balance = totalIncome.subtract(totalExpense);

        request.setAttribute("person", person);
        request.setAttribute("expenses", expenses);
        request.setAttribute("totalIncome", totalIncome);
        request.setAttribute("totalExpense", totalExpense);
        request.setAttribute("balance", balance);

        request.getRequestDispatcher("/expenses.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");


        
        
        
        
        
        request.setAttribute("__current_response", response);

        String action = request.getParameter("action");
        if (action == null) action = "";

        String personIdParam = request.getParameter("personId");
        if (personIdParam == null || personIdParam.trim().isEmpty()) {
            response.sendRedirect("persons");
            return;
        }

        Long personId;
        try {
            personId = Long.parseLong(personIdParam);
        } catch (NumberFormatException ex) {
            response.sendRedirect("persons");
            return;
        }

        switch (action) {
            case "add":
                handleAdd(request, personId);
                break;
            case "update":
                handleUpdate(request, personId);
                break;
            case "delete":
                handleDelete(request, personId);
                break;
            default:
                break;
        }


        
        
        
        boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
        if (!isAjax) {
            response.sendRedirect("expenses?personId=" + personId);
        }
    }

    private void handleAdd(HttpServletRequest request, Long personId) throws IOException {
        Person person = personService.findPersonById(personId);
        if (person == null) return;

        String amountParam = request.getParameter("amount");
        String typeParam = request.getParameter("type");
        String dateTimeParam = request.getParameter("dateTime");
        String description = request.getParameter("description");

        if (amountParam == null || amountParam.trim().isEmpty()
                || typeParam == null || typeParam.trim().isEmpty()) {
            return;
        }

        boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
        try {
            BigDecimal amount = new BigDecimal(amountParam);
            Expense.TransactionType type = Expense.TransactionType.valueOf(typeParam);

            LocalDateTime transactionDate;
            if (dateTimeParam != null && !dateTimeParam.trim().isEmpty()) {
                try {
                    transactionDate = LocalDateTime.parse(dateTimeParam, INPUT_DATE_TIME_FORMATTER);
                } catch (Exception ex) {
                    if (isAjax) {
                        sendServerError(responseFor(request), "Invalid date/time format");
                        return;
                    } else {
                        return;
                    }
                }
            } else {
                transactionDate = LocalDateTime.now();
            }

            Expense expense = new Expense();
            expense.setPerson(person);
            expense.setAmount(amount);
            expense.setType(type);
            expense.setTransactionDate(transactionDate);
            expense.setDescription(description);


            
            
            Set<ConstraintViolation<Expense>> violations = VALIDATOR.validate(expense);
            if (!violations.isEmpty()) {
                if (isAjax) {
                    sendValidationErrors(responseFor(request), violations);
                }
                return;
            }

            expenseService.createExpense(expense);

            if (isAjax) {
                sendSuccess(responseFor(request));
            }
        } catch (Exception ex) {
            if (isAjax) {
                sendServerError(responseFor(request), "Server error: " + ex.getMessage());
            }
        }
    }

    private void handleUpdate(HttpServletRequest request, Long personId) throws IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) return;

        boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
        try {
            Long id = Long.parseLong(idParam);
            Expense expense = expenseService.findExpenseById(id);
            if (expense == null || expense.getPerson() == null || expense.getPerson().getId() == null) return;
            if (!expense.getPerson().getId().equals(personId)) return;

            String amountParam = request.getParameter("amount");
            String typeParam = request.getParameter("type");
            String dateTimeParam = request.getParameter("dateTime");
            String description = request.getParameter("description");

            if (amountParam != null && !amountParam.trim().isEmpty()) {
                expense.setAmount(new BigDecimal(amountParam));
            }
            if (typeParam != null && !typeParam.trim().isEmpty()) {
                expense.setType(Expense.TransactionType.valueOf(typeParam));
            }
            if (dateTimeParam != null && !dateTimeParam.trim().isEmpty()) {
                try {
                    expense.setTransactionDate(LocalDateTime.parse(dateTimeParam, INPUT_DATE_TIME_FORMATTER));
                } catch (Exception ex) {
                    if (isAjax) {
                        sendServerError(responseFor(request), "Invalid date/time format");
                        return;
                    } else {
                        return;
                    }
                }
            }
            expense.setDescription(description);


            
            
            Set<ConstraintViolation<Expense>> violations = VALIDATOR.validate(expense);
            if (!violations.isEmpty()) {
                if (isAjax) {
                    sendValidationErrors(responseFor(request), violations);
                }
                return;
            }

            expenseService.updateExpense(expense);

            if (isAjax) {
                sendSuccess(responseFor(request));
            }
        } catch (Exception ex) {
            if (isAjax) {
                sendServerError(responseFor(request), "Server error: " + ex.getMessage());
            }
        }
    }

    private void handleDelete(HttpServletRequest request, Long personId) {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) return;

        try {
            Long id = Long.parseLong(idParam);
            Expense expense = expenseService.findExpenseById(id);
            if (expense == null || expense.getPerson() == null || expense.getPerson().getId() == null) return;
            if (!expense.getPerson().getId().equals(personId)) return;

            expenseService.deleteExpense(id);
        } catch (Exception ignored) {
        }
    }


    
    
    private void sendValidationErrors(HttpServletResponse response, Set<ConstraintViolation<Expense>> violations) throws IOException {
        Map<String, String> errors = new HashMap<>();
        for (ConstraintViolation<Expense> v : violations) {
            String prop = v.getPropertyPath().toString();

            
            if ("transactionDate".equals(prop)) prop = "dateTime";
            errors.put(prop, v.getMessage());
        }
        response.setStatus(400);
        response.setContentType("application/json;charset=UTF-8");
        StringBuilder sb = new StringBuilder();
        sb.append('{');
        sb.append("\"success\":false,");
        sb.append("\"errors\":{");
        boolean first = true;
        for (Map.Entry<String, String> e : errors.entrySet()) {
            if (!first) sb.append(',');
            first = false;
            sb.append('"').append(escapeJson(e.getKey())).append('"').append(':');
            sb.append('"').append(escapeJson(e.getValue())).append('"');
        }
        sb.append('}');
        sb.append('}');
        response.getWriter().write(sb.toString());
    }

    private void sendSuccess(HttpServletResponse response) throws IOException {
        response.setStatus(200);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":true}");
    }

    private void sendServerError(HttpServletResponse response, String message) throws IOException {
        response.setStatus(500);
        response.setContentType("application/json;charset=UTF-8");
        String json = "{\"success\":false,\"message\":\"" + escapeJson(message) + "\"}";
        response.getWriter().write(json);
    }

    private String escapeJson(String s) {
        return s == null ? "" : s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }

    private HttpServletResponse responseFor(HttpServletRequest request) {
        return (HttpServletResponse) request.getAttribute("__current_response");
    }
}