package com.total.pearson.servlet;

import com.total.pearson.entity.Person;
import com.total.pearson.service.PersonService;
import jakarta.ejb.EJB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/persons")
public class PersonServlet extends HttpServlet {
    @EJB
    private PersonService personService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String email = request.getParameter("email");

        List<Person> persons;
        if ((name == null || name.trim().isEmpty()) && (email == null || email.trim().isEmpty())) {
            persons = personService.findAllPersons();
        } else {
            persons = personService.findPersonsWithFilters(name, email);
        }

        request.setAttribute("persons", persons);
        request.getRequestDispatcher("/persons.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "add":
                handleAdd(request);
                break;
            case "update":
                handleUpdate(request);
                break;
            case "delete":
                handleDelete(request);
                break;
            default:
                break;
        }

        response.sendRedirect("persons");
    }

    private void handleAdd(HttpServletRequest request) {
        String name = request.getParameter("name");
        String email = request.getParameter("email");

        if (name != null && !name.trim().isEmpty() && email != null && !email.trim().isEmpty()) {
            Person person = new Person();
            person.setName(name);
            person.setEmail(email);
            personService.createPerson(person);
        }
    }

    private void handleUpdate(HttpServletRequest request) {
        String idParam = request.getParameter("id");
        String name = request.getParameter("name");
        String email = request.getParameter("email");

        if (idParam == null || idParam.trim().isEmpty()) return;

        try {
            Long id = Long.parseLong(idParam);
            Person person = personService.findPersonById(id);
            if (person == null) return;

            if (name != null && !name.trim().isEmpty()) person.setName(name);
            if (email != null && !email.trim().isEmpty()) person.setEmail(email);

            personService.updatePerson(person);
        } catch (NumberFormatException ignored) {
        }
    }

    private void handleDelete(HttpServletRequest request) {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) return;

        try {
            Long id = Long.parseLong(idParam);
            personService.deletePerson(id);
        } catch (NumberFormatException ignored) {
        }
    }
}