package com.total.pearson.service;

import com.total.pearson.entity.Person;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import java.util.List;

@Stateless
public class PersonService {

    @PersistenceContext(unitName = "expensePU")
    private EntityManager em;

    public void createPerson(Person person) {
        em.persist(person);
    }

    public Person findPersonById(Long id) {
        return em.find(Person.class, id);
    }

    public List<Person> findAllPersons() {
        return em.createQuery("SELECT p FROM Person p ORDER BY p.name", Person.class).getResultList();
    }

    public List<Person> findPersonsWithFilters(String name, String email) {
        String jpql = "SELECT p FROM Person p WHERE 1=1";
        if (name != null && !name.trim().isEmpty())
            jpql += " AND LOWER(p.name) LIKE LOWER(:name)";
        
        if (email != null && !email.trim().isEmpty())
            jpql += " AND LOWER(p.email) LIKE LOWER(:email)";
        
        jpql += " ORDER BY p.name";
        
        TypedQuery<Person> query = em.createQuery(jpql, Person.class);
        
        if (name != null && !name.trim().isEmpty())
            query.setParameter("name", "%" + name + "%");
        
        if (email != null && !email.trim().isEmpty())
            query.setParameter("email", "%" + email + "%");
        return query.getResultList();
    }

    public void updatePerson(Person person) {
        em.merge(person);
    }

    public void deletePerson(Long id) {
        Person person = findPersonById(id);
        if (person != null) {
            em.remove(person);
        }
    }
}