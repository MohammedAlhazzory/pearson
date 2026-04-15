package com.total.pearson.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Objects;
import com.total.pearson.validation.NotFuture;

@Entity
@Table(name = "expenses")
public class Expense implements Serializable {
    public enum TransactionType { INCOME, EXPENSE }
    
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "expenses_seq")
    @SequenceGenerator(name = "expenses_seq", sequenceName = "expenses_seq", allocationSize = 1)
    private Long id;

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.0", inclusive = false, message = "Amount must be positive")
    private BigDecimal amount;

    @NotNull(message = "Transaction date is required")
    @NotFuture(message = "Transaction date cannot be in the futre")
    @Column(name = "transaction_date", nullable = false)
    private LocalDateTime transactionDate;

    @NotNull(message = "Transaction type is required")
    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private TransactionType type;

    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "person_id", nullable = false)
    private Person person;

    private static DateTimeFormatter UI_DATE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");


    public Expense() {}

    public Expense(BigDecimal amount, LocalDateTime transactionDate, TransactionType type, Person person) {
        this.amount = amount;
        this.transactionDate = transactionDate;
        this.type = type;
        this.person = person;
    }


    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public LocalDateTime getTransactionDate() { return transactionDate; }
    public void setTransactionDate(LocalDateTime transactionDate) { this.transactionDate = transactionDate; }


    public String getTransactionDateFormatted() {
        return transactionDate == null ? "" : transactionDate.format(UI_DATE_TIME_FORMATTER);
    }

    public TransactionType getType() { return type; }
    public void setType(TransactionType type) { this.type = type; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Person getPerson() { return person; }
    public void setPerson(Person person) { this.person = person; }

    public BigDecimal getSignedAmount() {
        return type == TransactionType.INCOME ? amount : amount.negate();
    }


}