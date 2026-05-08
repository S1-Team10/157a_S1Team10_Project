package com.threadlink.web;

import com.threadlink.auth.SessionUtil;
import com.threadlink.db.DB;
import com.threadlink.db.Role;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class EmployeeHomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String employeeID = SessionUtil.getEmployeeID(session);
        Role role = SessionUtil.getRole(session);

        try (Connection conn = DB.get(role, getServletContext());
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT name, email, phoneNumber FROM Employees WHERE employeeID = ?")) {

            ps.setString(1, employeeID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    req.setAttribute("name", rs.getString("name"));
                    req.setAttribute("email", rs.getString("email"));
                    req.setAttribute("phoneNumber", rs.getString("phoneNumber"));
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Database error loading employee profile.", e);
        }

        req.setAttribute("employeeID", employeeID);
        req.setAttribute("role", role == Role.MANAGER ? "Manager" : "Sales Associate");
        req.getRequestDispatcher("/employee/home.jsp").forward(req, res);
    }
}
