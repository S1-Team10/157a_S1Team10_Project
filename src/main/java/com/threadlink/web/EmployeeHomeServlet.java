package com.threadlink.web;

import com.threadlink.auth.SessionUtil;
import com.threadlink.db.DB;
import com.threadlink.db.Role;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

public class EmployeeHomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String employeeID = SessionUtil.getEmployeeID(session);
        Role role = SessionUtil.getRole(session);

        try (Connection conn = DB.get(role, getServletContext())) {
            Map<String, Object> employee = getEmployee(conn, employeeID);
            req.setAttribute("employee", employee);
            req.setAttribute("name", employee.get("name"));
            req.setAttribute("email", employee.get("email"));
            req.setAttribute("phoneNumber", employee.get("phoneNumber"));

            // load all items so sales associate can view stock levels
            req.setAttribute("items", queryRows(conn,
                    "SELECT * FROM Items ORDER BY itemID"));

            // load all employees so sales associate can view staff list
            req.setAttribute("employees", queryRows(conn,
                    "SELECT employeeID, name, email, phoneNumber FROM Employees ORDER BY employeeID"));

            // load customers
            req.setAttribute("customers", queryRows(conn,
                    "SELECT firstName, lastName, email, phoneNumber, isSubscribed FROM Customers ORDER BY firstName, lastName"));

        } catch (SQLException e) {
            throw new ServletException("Database error loading employee profile.", e);
        }

        req.setAttribute("employeeID", employeeID);
        req.setAttribute("role", role == Role.MANAGER ? "Manager" : "Sales Associate");
        req.getRequestDispatcher("/employee/home.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String action = trim(req.getParameter("action"));

        try (Connection conn = DB.get(Role.SALES_ASSOCIATE, getServletContext())) {
            if ("updateStock".equals(action)) {
                // sales associate can update stock levels only
                updateStock(conn, req);
                flash(req, "employeeSuccess", "Stock updated.");
            } else {
                throw new IllegalArgumentException("Invalid action.");
            }
        } catch (IllegalArgumentException e) {
            flash(req, "employeeError", e.getMessage());
        } catch (SQLException e) {
            flash(req, "employeeError", "Database error: " + e.getMessage());
        }

        res.sendRedirect(req.getContextPath() + "/employee/home");
    }

    // updates currentStock, minStock, and maxStock only
    private void updateStock(Connection conn, HttpServletRequest req) throws SQLException {
        int itemID = positiveInt(req, "itemID");
        int currentStock = nonNegativeInt(req, "currentStock");
        int minStock = nonNegativeInt(req, "minStock");
        int maxStock = nonNegativeInt(req, "maxStock");

        if (minStock > maxStock) {
            throw new IllegalArgumentException("Minimum stock cannot exceed maximum stock.");
        }

        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE Items SET currentStock = ?, minStock = ?, maxStock = ? WHERE itemID = ?")) {
            ps.setInt(1, currentStock);
            ps.setInt(2, minStock);
            ps.setInt(3, maxStock);
            ps.setInt(4, itemID);
            if (ps.executeUpdate() == 0) {
                throw new IllegalArgumentException("Item not found.");
            }
        }
    }

    private Map<String, Object> getEmployee(Connection conn, String employeeID) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT employeeID, name, email, phoneNumber FROM Employees WHERE employeeID = ?")) {
            ps.setString(1, employeeID);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rowToMap(rs) : new HashMap<>();
            }
        }
    }

    private List<Map<String, Object>> queryRows(Connection conn, String sql) throws SQLException {
        List<Map<String, Object>> rows = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                rows.add(rowToMap(rs));
            }
        }
        return rows;
    }

    private Map<String, Object> rowToMap(ResultSet rs) throws SQLException {
        Map<String, Object> row = new HashMap<>();
        for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) {
            row.put(rs.getMetaData().getColumnLabel(i), rs.getObject(i));
        }
        return row;
    }

    private int positiveInt(HttpServletRequest req, String name) {
        int value = parseInt(req, name);
        if (value <= 0) throw new IllegalArgumentException(name + " must be greater than 0.");
        return value;
    }

    private int nonNegativeInt(HttpServletRequest req, String name) {
        int value = parseInt(req, name);
        if (value < 0) throw new IllegalArgumentException(name + " cannot be negative.");
        return value;
    }

    private int parseInt(HttpServletRequest req, String name) {
        try {
            return Integer.parseInt(trim(req.getParameter(name)));
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(name + " must be a whole number.");
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private void flash(HttpServletRequest req, String key, String message) {
        req.getSession().setAttribute(key, message);
    }

    private String popFlash(HttpServletRequest req, String key) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        String value = (String) session.getAttribute(key);
        session.removeAttribute(key);
        return value;
    }
}
