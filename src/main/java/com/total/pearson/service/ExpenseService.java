package com.total.pearson.service;

import com.total.pearson.entity.Expense;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Stateless
public class ExpenseService {

    @PersistenceContext(unitName = "expensePU")
    private EntityManager em;

    public void createExpense(Expense expense) {
        em.persist(expense);
    }

    public Expense findExpenseById(Long id) {
        return em.find(Expense.class, id);
    }

    public List<Expense> findExpensesByPersonId(Long personId) {
        return em.createQuery(
                        "SELECT e FROM Expense e WHERE e.person.id = :personId ORDER BY e.id DESC",
                        Expense.class)
                .setParameter("personId", personId)
                .getResultList();
    }

    public List<Expense> findExpensesByPersonIdWithFilters(Long personId, BigDecimal minAmount, BigDecimal maxAmount,
                                                           LocalDateTime fromDate, LocalDateTime toDate, Expense.TransactionType type) {
        StringBuilder jpql = new StringBuilder("SELECT e FROM Expense e WHERE e.person.id = :personId");
        if (minAmount != null) jpql.append(" AND e.amount >= :minAmount");
        if (maxAmount != null) jpql.append(" AND e.amount <= :maxAmount");
        if (fromDate != null) jpql.append(" AND e.transactionDate >= :fromDate");
        if (toDate != null) jpql.append(" AND e.transactionDate <= :toDate");
        if (type != null) jpql.append(" AND e.type = :type");
        
        jpql.append(" ORDER BY e.id DESC");
        TypedQuery<Expense> query = em.createQuery(jpql.toString(), Expense.class);
        query.setParameter("personId", personId);
        
        if (minAmount != null) query.setParameter("minAmount", minAmount);
        if (maxAmount != null) query.setParameter("maxAmount", maxAmount);
        if (fromDate != null) query.setParameter("fromDate", fromDate);
        if (toDate != null) query.setParameter("toDate", toDate);
        if (type != null) query.setParameter("type", type);
        return query.getResultList();
    }

    public void updateExpense(Expense expense) {
        em.merge(expense);
    }

    public void deleteExpense(Long id) {
        Expense expense = findExpenseById(id);
        if (expense != null) {
            em.remove(expense);
        }
    }
}