package com.threadlink.web;

import com.threadlink.auth.SessionUtil;
import com.threadlink.db.DB;
import com.threadlink.db.Role;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;

public class CustomerLoginServlet extends HttpServlet {

    // Called when the customer login form is submitted.
    // Expects form fields: "email" and "password".
    // On success: creates a session and redirects to /customer/home.
    // On failure: forwards back to the account login JSP with an "error" attribute.
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/login/customer_login.jsp").forward(req, res);
            return;
        }

        String hashedPassword;
        
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) sb.append(String.format("%02x", b));
            hashedPassword = sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new ServletException("SHA-256 not available.", e);
        }

        try (Connection conn = DB.get(Role.CUSTOMER, getServletContext());
             PreparedStatement ps = conn.prepareStatement(
                "SELECT email FROM Customers WHERE email = ? AND password = ?")) {

            ps.setString(1, email.trim());
            ps.setString(2, hashedPassword);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    HttpSession session = req.getSession(true);
                    SessionUtil.loginCustomer(session, email.trim());
                    res.sendRedirect(req.getContextPath() + "/customer/home");
                } 
                else {
                    req.setAttribute("error", "Invalid email or password.");
                    req.getRequestDispatcher("/login/customer_login.jsp").forward(req, res);
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Database error during customer login.", e);
        }
    }

    // GET just shows the login page.
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.getRequestDispatcher("/login/customer_login.jsp").forward(req, res);
    }
}
