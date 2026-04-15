package com.threadlink.web;

import com.threadlink.catalog.Item;
import com.threadlink.catalog.ItemRepository;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class CatalogApiServlet extends HttpServlet {
  private final ItemRepository itemRepository = new ItemRepository();

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    String query = request.getParameter("q");
    if (query == null) {
      query = "";
    }

    String db = getServletContext().getInitParameter("DB_NAME");
    String user = getServletContext().getInitParameter("DB_USER");
    String password = getServletContext().getInitParameter("DB_PASSWORD");

    try (PrintWriter out = response.getWriter()) {
      if (db == null || user == null || password == null) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.write("{\"error\":\"Database config is missing. Set `DB_NAME`, `DB_USER`, and `DB_PASSWORD` as app init params.\"}");
        return;
      }

      try {
        List<Item> items = itemRepository.searchItems(db, user, password, query);
        out.write(toJson(items));
      } catch (Exception e) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.write("{\"error\":\"" + JsonUtils.escape(e instanceof ClassNotFoundException
          ? "MySQL JDBC driver not found."
          : "Database error: " + e.getMessage()) + "\"}");
      }
    }
  }

  private String toJson(List<Item> items) {
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
        .append("\"minStock\":").append(item.getMinStock()).append(",")
        .append("\"maxStock\":").append(item.getMaxStock())
        .append("}");
    }

    json.append("]}");
    return json.toString();
  }
}
