package com.threadlink.servlet;

import com.threadlink.auth.SessionUtil;
import com.threadlink.db.DB;
import com.threadlink.db.Role;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class EmployeeLoginServlet extends HttpServlet {

    // Called when the employee login form is submitted.
    // Expects form field: "employeeID".
    // Checks Employees table, then determines Manager vs SalesAssociate sub-role.
    // On success: creates a session and redirects to /employee/home.
    // On failure: forwards back to /employee/login.jsp with an "error" attribute.
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

        String employeeID = req.getParameter("employeeID");

        if (employeeID == null || employeeID.trim().isEmpty()) {
            req.setAttribute("error", "Employee ID is required.");
            req.getRequestDispatcher("/employee/login.jsp").forward(req, res);
            return;
        }

        employeeID = employeeID.trim();

        try (Connection conn = DB.get(Role.SALES_ASSOCIATE, getServletContext())) {

            // Verify the employee exists
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT employeeID FROM Employees WHERE employeeID = ?")) {

                ps.setString(1, employeeID);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        req.setAttribute("error", "Employee ID not found.");
                        req.getRequestDispatcher("/employee/login.jsp").forward(req, res);
                        return;
                    }
                }
            }

            // Determine sub-role: check if they appear in the Managers table
            Role role;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT managerID FROM Managers WHERE managerID = ?")) {

                ps.setString(1, employeeID);
                try (ResultSet rs = ps.executeQuery()) {
                    role = rs.next() ? Role.MANAGER : Role.SALES_ASSOCIATE;
                }
            }

            HttpSession session = req.getSession(true);
            SessionUtil.loginEmployee(session, employeeID, role);
            res.sendRedirect(req.getContextPath() + "/employee/home");

        } catch (SQLException e) {
            throw new ServletException("Database error during employee login.", e);
        }
    }

    // GET just shows the employee login page.
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.getRequestDispatcher("/employee/login.jsp").forward(req, res);
    }
}
