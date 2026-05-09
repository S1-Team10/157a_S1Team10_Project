package com.threadlink.web;

import com.threadlink.auth.SessionUtil;
import com.threadlink.db.DB;
import com.threadlink.db.Role;
import com.threadlink.orders.OrderReceipt;
import com.threadlink.orders.OrderRepository;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
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
    String customerEmail = SessionUtil.getUserEmail(session);
    if (customerEmail == null || !SessionUtil.hasRole(session, Role.CUSTOMER)) {
      response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
      response.getWriter().write("{\"error\":\"Please log in as a customer to place an order.\"}");
      return;
    }

    List<Integer> itemIds;
    try {
      itemIds = parseItemIds(request.getParameterValues("itemId"));
    } catch (IllegalArgumentException e) {
      response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
      response.getWriter().write("{\"error\":\"" + JsonUtils.escape(e.getMessage()) + "\"}");
      return;
    }

    if (itemIds.isEmpty()) {
      response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
      response.getWriter().write("{\"error\":\"Add at least one item before placing an order.\"}");
      return;
    }

    try (Connection conn = DB.get(Role.CUSTOMER, getServletContext())) {
      OrderReceipt receipt = orderRepository.placeCustomerOrder(conn, customerEmail, itemIds);
      response.getWriter().write(
          "{\"orderId\":" + receipt.getOrderId()
              + ",\"totalAmount\":\"" + receipt.getTotalAmount() + "\"}");
    } catch (SQLException e) {
      response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
      response.getWriter().write(
          "{\"error\":\"" + JsonUtils.escape("Database error: " + e.getMessage()) + "\"}");
    }
  }

  private List<Integer> parseItemIds(String[] values) {
    Set<Integer> itemIds = new LinkedHashSet<>();

    if (values == null) {
      return new ArrayList<>(itemIds);
    }

    for (String value : values) {
      if (value == null) {
        continue;
      }

      String[] parts = value.split(",");
      for (String part : parts) {
        String trimmed = part.trim();
        if (trimmed.isEmpty()) {
          continue;
        }

        try {
          int itemId = Integer.parseInt(trimmed);
          if (itemId <= 0) {
            throw new NumberFormatException("Item IDs must be positive.");
          }
          itemIds.add(itemId);
        } catch (NumberFormatException e) {
          throw new IllegalArgumentException("Invalid item selected.");
        }
      }
    }

    return new ArrayList<>(itemIds);
  }
}
