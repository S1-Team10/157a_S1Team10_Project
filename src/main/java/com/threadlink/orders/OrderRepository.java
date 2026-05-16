package com.threadlink.orders;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.List;

public class OrderRepository {

  public OrderReceipt placeCustomerOrder(
      Connection conn, String customerEmail, List<OrderLine> orderLines, String discountCode)
      throws SQLException {
    return placeOrder(conn, customerEmail, null, orderLines, discountCode);
  }

  public OrderReceipt placeEmployeeOrder(
      Connection conn, String employeeId, List<OrderLine> orderLines, String discountCode)
      throws SQLException {
    return placeOrder(conn, null, employeeId, orderLines, discountCode);
  }

  private OrderReceipt placeOrder(
      Connection conn,
      String customerEmail,
      String employeeId,
      List<OrderLine> orderLines,
      String discountCode)
      throws SQLException {
    boolean oldAutoCommit = conn.getAutoCommit();
    conn.setAutoCommit(false);

    try {
      BigDecimal subtotal = calculateSubtotal(conn, orderLines);
      BigDecimal totalAmount = applyDiscount(conn, subtotal, discountCode);
      int orderId = createOrder(conn);

      if (customerEmail != null) {
        createCustomerPlace(conn, customerEmail, orderId, totalAmount);
      } else {
        createEmployeePlace(conn, employeeId, orderId, totalAmount);
      }

      createOrderItems(conn, orderId, orderLines);
      adjustCurrentStock(conn, orderLines, employeeId != null);
      conn.commit();
      return new OrderReceipt(orderId, totalAmount);
    } catch (SQLException e) {
      conn.rollback();
      throw e;
    } finally {
      conn.setAutoCommit(oldAutoCommit);
    }
  }

  private BigDecimal calculateSubtotal(Connection conn, List<OrderLine> orderLines) throws SQLException {
    BigDecimal total = BigDecimal.ZERO;

    try (PreparedStatement ps = conn.prepareStatement("SELECT price FROM Items WHERE itemID = ?")) {
      for (OrderLine line : orderLines) {
        ps.setInt(1, line.getItemId());

        try (ResultSet rs = ps.executeQuery()) {
          if (!rs.next()) {
            throw new SQLException("One or more items are no longer available.");
          }

          total = total.add(rs.getBigDecimal("price").multiply(BigDecimal.valueOf(line.getQuantity())));
        }
      }
    }

    return total;
  }

  private BigDecimal applyDiscount(Connection conn, BigDecimal subtotal, String discountCode) throws SQLException {
    if (discountCode == null || discountCode.trim().isEmpty()) {
      return subtotal;
    }

    try (PreparedStatement ps = conn.prepareStatement(
        "SELECT percentOff FROM Discounts WHERE discountCode = ? AND startDate <= ? AND endDate >= ?")) {
      Date today = Date.valueOf(LocalDate.now());
      ps.setString(1, discountCode.trim());
      ps.setDate(2, today);
      ps.setDate(3, today);

      try (ResultSet rs = ps.executeQuery()) {
        if (!rs.next()) {
          throw new SQLException("Discount code is invalid or expired.");
        }

        BigDecimal percentOff = rs.getBigDecimal("percentOff");
        BigDecimal multiplier = BigDecimal.valueOf(100).subtract(percentOff)
            .divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
        return subtotal.multiply(multiplier).setScale(2, RoundingMode.HALF_UP);
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

  private void createEmployeePlace(Connection conn, String employeeId, int orderId, BigDecimal totalAmount)
      throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(
        "INSERT INTO EmployeePlaces (employeeID, employeeOrderID, totalAmount, orderDate) VALUES (?, ?, ?, ?)")) {
      ps.setString(1, employeeId);
      ps.setInt(2, orderId);
      ps.setBigDecimal(3, totalAmount);
      ps.setDate(4, Date.valueOf(LocalDate.now()));
      ps.executeUpdate();
    }
  }

  private void createOrderItems(Connection conn, int orderId, List<OrderLine> orderLines)
      throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(
        "INSERT INTO OrderItems (orderID, itemID, quantity, selectedSize, selectedColor) VALUES (?, ?, ?, ?, ?)")) {
      for (OrderLine line : orderLines) {
        ps.setInt(1, orderId);
        ps.setInt(2, line.getItemId());
        ps.setInt(3, line.getQuantity());
        ps.setString(4, line.getSelectedSize());
        ps.setString(5, line.getSelectedColor());
        ps.addBatch();
      }

      ps.executeBatch();
    }
  }

  private void adjustCurrentStock(Connection conn, List<OrderLine> orderLines, boolean addToStock)
      throws SQLException {
    if (addToStock) {
      incrementCurrentStock(conn, orderLines);
    } else {
      decrementCurrentStock(conn, orderLines);
    }
  }

  private void decrementCurrentStock(Connection conn, List<OrderLine> orderLines) throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(
        "UPDATE Items SET currentStock = currentStock - ? WHERE itemID = ? AND currentStock >= ?")) {
      for (OrderLine line : orderLines) {
        ps.setInt(1, line.getQuantity());
        ps.setInt(2, line.getItemId());
        ps.setInt(3, line.getQuantity());
        if (ps.executeUpdate() == 0) {
          throw new SQLException("Item " + line.getItemId() + " does not have enough stock.");
        }
      }
    }
  }

  private void incrementCurrentStock(Connection conn, List<OrderLine> orderLines) throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(
        "UPDATE Items SET currentStock = currentStock + ? WHERE itemID = ?")) {
      for (OrderLine line : orderLines) {
        ps.setInt(1, line.getQuantity());
        ps.setInt(2, line.getItemId());
        if (ps.executeUpdate() == 0) {
          throw new SQLException("Item " + line.getItemId() + " is no longer available.");
        }
      }
    }
  }
}
