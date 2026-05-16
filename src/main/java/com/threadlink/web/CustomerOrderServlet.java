package com.threadlink.web;

import com.threadlink.auth.SessionUtil;
import com.threadlink.db.DB;
import com.threadlink.db.Role;
import com.threadlink.orders.OrderLine;
import com.threadlink.orders.OrderReceipt;
import com.threadlink.orders.OrderRepository;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class CustomerOrderServlet extends HttpServlet {
  private final OrderRepository orderRepository = new OrderRepository();

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    HttpSession session = request.getSession(false);
    Role role = SessionUtil.getRole(session);
    if (role == null) {
      response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
      response.getWriter().write("{\"error\":\"Please log in before placing an order.\"}");
      return;
    }

    List<OrderLine> orderLines;
    String discountCode = trim(request.getParameter("discountCode"));
    try {
      orderLines = parseOrderLines(
          request.getParameterValues("itemId"),
          request.getParameterValues("quantity"),
          request.getParameterValues("selectedSize"),
          request.getParameterValues("selectedColor"));
    } catch (IllegalArgumentException e) {
      response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
      response.getWriter().write("{\"error\":\"" + JsonUtils.escape(e.getMessage()) + "\"}");
      return;
    }

    if (orderLines.isEmpty()) {
      response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
      response.getWriter().write("{\"error\":\"Add at least one item before placing an order.\"}");
      return;
    }

    try (Connection conn = DB.get(role, getServletContext())) {
      OrderReceipt receipt;
      if (role == Role.CUSTOMER) {
        String customerEmail = SessionUtil.getUserEmail(session);
        receipt = orderRepository.placeCustomerOrder(conn, customerEmail, orderLines, discountCode);
      } else {
        String employeeId = SessionUtil.getEmployeeID(session);
        receipt = orderRepository.placeEmployeeOrder(conn, employeeId, orderLines, discountCode);
      }

      response.getWriter().write(
          "{\"orderId\":" + receipt.getOrderId()
              + ",\"totalAmount\":\"" + receipt.getTotalAmount() + "\"}");
    } catch (SQLException e) {
      response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
      response.getWriter().write(
          "{\"error\":\"" + JsonUtils.escape("Database error: " + e.getMessage()) + "\"}");
    }
  }

  private List<OrderLine> parseOrderLines(
      String[] itemValues,
      String[] quantityValues,
      String[] sizeValues,
      String[] colorValues) {
    List<OrderLine> orderLines = new ArrayList<>();

    if (itemValues == null) {
      return orderLines;
    }

    for (int i = 0; i < itemValues.length; i++) {
      int itemId = parseItemId(itemValues[i]);
      int quantity = parseQuantity(quantityValues, i);
      String selectedSize = requiredChoice(sizeValues, i, "size");
      String selectedColor = requiredChoice(colorValues, i, "color");
      orderLines.add(new OrderLine(itemId, quantity, selectedSize, selectedColor));
    }

    return orderLines;
  }

  private int parseItemId(String value) {
    try {
      int itemId = Integer.parseInt(trim(value));
      if (itemId <= 0) {
        throw new NumberFormatException("Item IDs must be positive.");
      }
      return itemId;
    } catch (NumberFormatException e) {
      throw new IllegalArgumentException("Invalid item selected.");
    }
  }

  private int parseQuantity(String[] quantityValues, int index) {
    if (quantityValues == null || index >= quantityValues.length || trim(quantityValues[index]).isEmpty()) {
      return 1;
    }

    try {
      int quantity = Integer.parseInt(trim(quantityValues[index]));
      if (quantity <= 0) {
        throw new NumberFormatException("Quantity must be positive.");
      }
      return quantity;
    } catch (NumberFormatException e) {
      throw new IllegalArgumentException("Invalid quantity selected.");
    }
  }

  private String requiredChoice(String[] values, int index, String label) {
    String value = values == null || index >= values.length ? "" : trim(values[index]);
    if (value.isEmpty()) {
      throw new IllegalArgumentException("Choose a " + label + " for every item.");
    }
    return value;
  }

  private String trim(String value) {
    return value == null ? "" : value.trim();
  }
}
