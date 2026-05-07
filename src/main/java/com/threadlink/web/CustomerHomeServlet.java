package com.threadlink.web;

import com.threadlink.auth.SessionUtil;
import com.threadlink.db.DB;
import com.threadlink.db.Role;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

public class CustomerHomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String email = SessionUtil.getUserEmail(session);

        // loading the customer's profile from the database
        try (Connection conn = DB.get(Role.CUSTOMER, getServletContext());
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT firstName, lastName, phoneNumber, birthdate, isSubscribed " +
                             "FROM Customers WHERE email = ?")) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    req.setAttribute("firstName", rs.getString("firstName"));
                    req.setAttribute("lastName", rs.getString("lastName"));
                    req.setAttribute("phoneNumber", rs.getString("phoneNumber"));
                    req.setAttribute("birthdate", rs.getString("birthdate"));
                    req.setAttribute("isSubscribed", rs.getBoolean("isSubscribed"));
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Database error loading profile.", e);
        }

        // loading the orders that the customer have on the database
        try (Connection conn = DB.get(Role.CUSTOMER, getServletContext());
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT customerOrderID, totalAmount, orderDate " +
                             "FROM CustomerPlaces WHERE customerEmail = ? ORDER BY orderDate DESC")) {

            ps.setString(1, email);
            List<Map<String, Object>> orders = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> order = new HashMap<>();
                    order.put("orderId", rs.getInt("customerOrderID"));
                    order.put("totalAmount", rs.getBigDecimal("totalAmount"));
                    order.put("orderDate", rs.getString("orderDate"));
                    orders.add(order);
                }
            }
            req.setAttribute("orders", orders);
            req.setAttribute("email", email);

        } catch (SQLException e) {
            throw new ServletException("Database error loading orders.", e);
        }

        req.getRequestDispatcher("/customer/home.jsp").forward(req, res);
    }
}

