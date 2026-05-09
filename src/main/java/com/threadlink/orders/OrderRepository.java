package com.threadlink.orders;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.List;

public class OrderRepository {

  public OrderReceipt placeCustomerOrder(Connection conn, String customerEmail, List<Integer> itemIds)
      throws SQLException {
    BigDecimal totalAmount = calculateTotal(conn, itemIds);

    boolean oldAutoCommit = conn.getAutoCommit();
    conn.setAutoCommit(false);

    try {
      int orderId = createOrder(conn);
      createCustomerPlace(conn, customerEmail, orderId, totalAmount);
      createOrderItems(conn, orderId, itemIds);
      conn.commit();
      return new OrderReceipt(orderId, totalAmount);
    } catch (SQLException e) {
      conn.rollback();
      throw e;
    } finally {
      conn.setAutoCommit(oldAutoCommit);
    }
  }

  private BigDecimal calculateTotal(Connection conn, List<Integer> itemIds) throws SQLException {
    StringBuilder sql = new StringBuilder("SELECT COALESCE(SUM(price), 0) AS total, COUNT(*) AS itemCount FROM Items WHERE itemID IN (");
    appendPlaceholders(sql, itemIds.size());
    sql.append(")");

    try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
      setItemIdParameters(ps, itemIds);

      try (ResultSet rs = ps.executeQuery()) {
        if (!rs.next()) {
          throw new SQLException("Could not calculate order total.");
        }

        if (rs.getInt("itemCount") != itemIds.size()) {
          throw new SQLException("One or more items are no longer available.");
        }

        return rs.getBigDecimal("total");
      }
    }
  }

  private int createOrder(Connection conn) throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(
        "INSERT INTO Orders () VALUES ()",
        Statement.RETURN_GENERATED_KEYS)) {
      ps.executeUpdate();

      try (ResultSet keys = ps.getGeneratedKeys()) {
        if (keys.next()) {
          return keys.getInt(1);
        }
      }
    }

    throw new SQLException("Could not create order.");
  }

  private void createCustomerPlace(Connection conn, String customerEmail, int orderId, BigDecimal totalAmount)
      throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(
        "INSERT INTO CustomerPlaces (customerEmail, customerOrderID, totalAmount, orderDate) VALUES (?, ?, ?, ?)")) {
      ps.setString(1, customerEmail);
      ps.setInt(2, orderId);
      ps.setBigDecimal(3, totalAmount);
      ps.setDate(4, Date.valueOf(LocalDate.now()));
      ps.executeUpdate();
    }
  }

  private void createOrderItems(Connection conn, int orderId, List<Integer> itemIds) throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(
        "INSERT INTO OrderItems (orderID, itemID) VALUES (?, ?)")) {
      for (Integer itemId : itemIds) {
        ps.setInt(1, orderId);
        ps.setInt(2, itemId);
        ps.addBatch();
      }

      ps.executeBatch();
    }
  }

  private void appendPlaceholders(StringBuilder sql, int count) {
    for (int i = 0; i < count; i++) {
      if (i > 0) {
        sql.append(", ");
      }
      sql.append("?");
    }
  }

  private void setItemIdParameters(PreparedStatement ps, List<Integer> itemIds) throws SQLException {
    for (int i = 0; i < itemIds.size(); i++) {
      ps.setInt(i + 1, itemIds.get(i));
    }
  }
}
