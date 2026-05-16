package com.threadlink.catalog;

import java.sql.DatabaseMetaData;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class ItemRepository {
  public List<Item> searchItems(Connection conn, String query, boolean includeStockRange) throws SQLException {
    String searchTerm = "%" + normalizeQuery(query) + "%";
    List<Item> items = new ArrayList<>();
    String sql = buildSearchSql(conn, includeStockRange);

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
      ps.setString(1, searchTerm);
      ps.setString(2, searchTerm);

      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          items.add(new Item(
            rs.getInt("itemID"),
            rs.getString("itemName"),
            rs.getString("description"),
            rs.getBigDecimal("price"),
            rs.getString("color"),
            rs.getString("size"),
            rs.getInt("currentStock"),
            includeStockRange ? rs.getInt("minStock") : 0,
            includeStockRange ? rs.getInt("maxStock") : 0
          ));
        }
      }
    }

    return items;
  }

  private String buildSearchSql(Connection conn, boolean includeStockRange) throws SQLException {
    Set<String> columns = itemColumns(conn);
    String colorExpr = publicColumnExpr(columns, "color", "colors");
    String sizeExpr = publicColumnExpr(columns, "size", "sizes");
    String currentStockExpr = columns.contains("currentstock") ? "currentStock" : "0";

    StringBuilder sql = new StringBuilder();
    sql.append("SELECT itemID, itemName, description, price, ")
      .append(colorExpr).append(" AS color, ")
      .append(sizeExpr).append(" AS size, ")
      .append(currentStockExpr).append(" AS currentStock");

    if (includeStockRange) {
      sql.append(", minStock, maxStock");
    }

    sql.append(" FROM Items WHERE itemName LIKE ? OR description LIKE ? ORDER BY itemName");
    return sql.toString();
  }

  private String publicColumnExpr(Set<String> columns, String singularName, String pluralName) {
    if (columns.contains(singularName.toLowerCase())) {
      return singularName;
    }
    if (columns.contains(pluralName.toLowerCase())) {
      return pluralName;
    }
    return "''";
  }

  private Set<String> itemColumns(Connection conn) throws SQLException {
    Set<String> columns = new HashSet<>();
    DatabaseMetaData metaData = conn.getMetaData();
    try (ResultSet rs = metaData.getColumns(conn.getCatalog(), null, "Items", null)) {
      while (rs.next()) {
        columns.add(rs.getString("COLUMN_NAME").toLowerCase());
      }
    }
    if (columns.isEmpty()) {
      try (ResultSet rs = metaData.getColumns(conn.getCatalog(), null, "items", null)) {
        while (rs.next()) {
          columns.add(rs.getString("COLUMN_NAME").toLowerCase());
        }
      }
    }
    return columns;
  }

  private String normalizeQuery(String query) {
    return query == null ? "" : query.trim();
  }
}
