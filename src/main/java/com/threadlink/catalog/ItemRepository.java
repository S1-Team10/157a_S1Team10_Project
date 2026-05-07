package com.threadlink.catalog;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ItemRepository {
  private static final String SEARCH_SQL =
    "SELECT itemID, itemName, description, price, minStock, maxStock " +
    "FROM Items " +
    "WHERE itemName LIKE ? OR description LIKE ? " +
    "ORDER BY itemName";

  public List<Item> searchItems(Connection conn, String query) throws SQLException {
    String searchTerm = "%" + normalizeQuery(query) + "%";
    List<Item> items = new ArrayList<>();

    try (PreparedStatement ps = conn.prepareStatement(SEARCH_SQL)) {
      ps.setString(1, searchTerm);
      ps.setString(2, searchTerm);

      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          items.add(new Item(
            rs.getInt("itemID"),
            rs.getString("itemName"),
            rs.getString("description"),
            rs.getBigDecimal("price"),
            rs.getInt("minStock"),
            rs.getInt("maxStock")
          ));
        }
      }
    }

    return items;
  }

  private String normalizeQuery(String query) {
    return query == null ? "" : query.trim();
  }
}
