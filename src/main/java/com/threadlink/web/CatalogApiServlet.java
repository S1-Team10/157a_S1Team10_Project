package com.threadlink.web;

import com.threadlink.catalog.Item;
import com.threadlink.catalog.ItemRepository;
import com.threadlink.auth.SessionUtil;
import com.threadlink.db.DB;
import com.threadlink.db.Role;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class CatalogApiServlet extends HttpServlet {
  private final ItemRepository itemRepository = new ItemRepository();

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    String query = request.getParameter("q");
    if (query == null) query = "";

    HttpSession session = request.getSession(false);
    Role role = SessionUtil.getRole(session);
    Role dbRole = role == null ? Role.CUSTOMER : role;
    boolean canViewStockRange = role == Role.SALES_ASSOCIATE || role == Role.MANAGER;

    try (Connection conn = DB.get(dbRole, getServletContext())) {
      List<Item> items = itemRepository.searchItems(conn, query, canViewStockRange);
      response.getWriter().write(toJson(items, canViewStockRange));
    } catch (SQLException e) {
      response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
      response.getWriter().write(
        "{\"error\":\"" + JsonUtils.escape("Database error: " + e.getMessage()) + "\"}"
      );
    }
  }

  private String toJson(List<Item> items, boolean canViewStockRange) {
    StringBuilder json = new StringBuilder();
    json.append("{\"items\":[");

    for (int i = 0; i < items.size(); i++) {
      Item item = items.get(i);

      if (i > 0) {
        json.append(",");
      }

      json.append("{")
        .append("\"itemId\":").append(item.getItemId()).append(",")
        .append("\"itemName\":\"").append(JsonUtils.escape(item.getItemName())).append("\",")
        .append("\"description\":\"").append(JsonUtils.escape(item.getDescription())).append("\",")
        .append("\"price\":\"").append(item.getPrice()).append("\",")
        .append("\"colors\":\"").append(JsonUtils.escape(item.getColors())).append("\",")
        .append("\"sizes\":\"").append(JsonUtils.escape(item.getSizes())).append("\",")
        .append("\"currentStock\":").append(item.getCurrentStock());

      if (canViewStockRange) {
        json.append(",")
          .append("\"minStock\":").append(item.getMinStock()).append(",")
          .append("\"maxStock\":").append(item.getMaxStock());
      }

      json.append("}");
    }

    json.append("]}");
    return json.toString();
  }
}
