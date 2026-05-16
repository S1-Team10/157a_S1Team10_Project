package com.threadlink.web;

import com.threadlink.auth.SessionUtil;
import com.threadlink.db.DB;
import com.threadlink.db.Role;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class ManagerHomeServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
    HttpSession session = req.getSession(false);
    String managerID = SessionUtil.getEmployeeID(session);

    try (Connection conn = DB.get(Role.MANAGER, getServletContext())) {
      req.setAttribute("manager", getEmployee(conn, managerID));
      req.setAttribute("items", queryRows(conn,
          "SELECT * FROM Items ORDER BY itemID"));
      req.setAttribute("salesAssociates", queryRows(conn,
          "SELECT e.employeeID, e.name, e.email, e.phoneNumber FROM Employees e "
              + "JOIN SalesAssociates sa ON sa.salesAssociateID = e.employeeID ORDER BY e.employeeID"));
      req.setAttribute("discounts", queryRows(conn,
          "SELECT discountCode, discountName, percentOff, startDate, endDate FROM Discounts ORDER BY discountCode"));
      req.setAttribute("customers", queryRows(conn,
          "SELECT email, firstName, lastName FROM Customers ORDER BY email"));
      req.setAttribute("employees", queryRows(conn,
          "SELECT employeeID, name, email FROM Employees ORDER BY employeeID"));
    } catch (SQLException e) {
      throw new ServletException("Database error loading manager dashboard.", e);
    }

    req.setAttribute("managerID", managerID);
    req.setAttribute("success", popFlash(req, "managerSuccess"));
    req.setAttribute("error", popFlash(req, "managerError"));
    req.getRequestDispatcher("/manager/home.jsp").forward(req, res);
  }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
    HttpSession session = req.getSession(false);
    String managerID = SessionUtil.getEmployeeID(session);
    String action = trim(req.getParameter("action"));

    try (Connection conn = DB.get(Role.MANAGER, getServletContext())) {
      if ("addItem".equals(action)) {
        addItem(conn, req, managerID);
        flash(req, "managerSuccess", "Item added to inventory.");
      } else if ("deleteItem".equals(action)) {
        deleteItem(conn, req);
        flash(req, "managerSuccess", "Item deleted from inventory.");
      } else if ("updateItem".equals(action)) {
        updateItem(conn, req, managerID);
        flash(req, "managerSuccess", "Item updated.");
      } else if ("hireSalesAssociate".equals(action)) {
        hireSalesAssociate(conn, req, managerID);
        flash(req, "managerSuccess", "Sales associate hired.");
      } else if ("fireSalesAssociate".equals(action)) {
        fireSalesAssociate(conn, req);
        flash(req, "managerSuccess", "Sales associate removed.");
      } else if ("updateSalesAssociateId".equals(action)) {
        updateSalesAssociateId(conn, req);
        flash(req, "managerSuccess", "Sales associate ID updated.");
      } else if ("assignDiscount".equals(action)) {
        assignDiscount(conn, req, managerID);
        flash(req, "managerSuccess", "Discount assigned.");
      } else if ("assignBulkDiscount".equals(action)) {
        assignBulkDiscount(conn, req, managerID);
        flash(req, "managerSuccess", "Discount applied to the selected group.");
      } else if ("revokeDiscount".equals(action)) {
        revokeDiscount(conn, req, managerID);
        flash(req, "managerSuccess", "Discount removed.");
      } else {
        throw new IllegalArgumentException("Choose a valid manager action.");
      }
    } catch (IllegalArgumentException e) {
      flash(req, "managerError", e.getMessage());
    } catch (SQLException e) {
      flash(req, "managerError", "Database error: " + e.getMessage());
    }

    res.sendRedirect(req.getContextPath() + "/manager/home");
  }

  private Map<String, Object> getEmployee(Connection conn, String employeeID) throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(
        "SELECT employeeID, name, email, phoneNumber FROM Employees WHERE employeeID = ?")) {
      ps.setString(1, employeeID);
      try (ResultSet rs = ps.executeQuery()) {
        return rs.next() ? rowToMap(rs) : new HashMap<String, Object>();
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

  private void addItem(Connection conn, HttpServletRequest req, String managerID) throws SQLException {
    String itemName = required(req, "itemName");
    String description = trim(req.getParameter("description"));
    BigDecimal price = positiveMoney(req, "price");
    String colors = trim(req.getParameter("colors"));
    String sizes = trim(req.getParameter("sizes"));
    int currentStock = nonNegativeInt(req, "currentStock");
    int minStock = nonNegativeInt(req, "minStock");
    int maxStock = nonNegativeInt(req, "maxStock");
    validateStockLimits(minStock, maxStock);

    boolean oldAutoCommit = conn.getAutoCommit();
    conn.setAutoCommit(false);
    try {
      int itemID;
      try (PreparedStatement ps = conn.prepareStatement(
          "INSERT INTO Items (itemName, description, price, colors, sizes, currentStock, minStock, maxStock) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
          Statement.RETURN_GENERATED_KEYS)) {
        ps.setString(1, itemName);
        ps.setString(2, description);
        ps.setBigDecimal(3, price);
        ps.setString(4, colors);
        ps.setString(5, sizes);
        ps.setInt(6, currentStock);
        ps.setInt(7, minStock);
        ps.setInt(8, maxStock);
        ps.executeUpdate();
        try (ResultSet keys = ps.getGeneratedKeys()) {
          if (!keys.next()) throw new SQLException("Could not get new item ID.");
          itemID = keys.getInt(1);
        }
      }
      recordItemUpdate(conn, managerID, itemID);
      conn.commit();
    } catch (SQLException e) {
      conn.rollback();
      throw e;
    } finally {
      conn.setAutoCommit(oldAutoCommit);
    }
  }

  private void deleteItem(Connection conn, HttpServletRequest req) throws SQLException {
    int itemID = positiveInt(req, "itemID");

    boolean oldAutoCommit = conn.getAutoCommit();
    conn.setAutoCommit(false);
    try (PreparedStatement orderItems = conn.prepareStatement("DELETE FROM OrderItems WHERE itemID = ?");
         PreparedStatement audit = conn.prepareStatement("DELETE FROM UpdatesItem WHERE itemID = ?");
         PreparedStatement item = conn.prepareStatement("DELETE FROM Items WHERE itemID = ?")) {
      orderItems.setInt(1, itemID);
      orderItems.executeUpdate();
      audit.setInt(1, itemID);
      audit.executeUpdate();
      item.setInt(1, itemID);
      if (item.executeUpdate() == 0) {
        throw new IllegalArgumentException("Item not found.");
      }
      conn.commit();
    } catch (SQLException e) {
      conn.rollback();
      throw e;
    } catch (IllegalArgumentException e) {
      conn.rollback();
      throw e;
    } finally {
      conn.setAutoCommit(oldAutoCommit);
    }
  }

  private void updateItem(Connection conn, HttpServletRequest req, String managerID) throws SQLException {
    int itemID = positiveInt(req, "itemID");
    BigDecimal price = positiveMoney(req, "price");
    int currentStock = nonNegativeInt(req, "currentStock");
    int minStock = nonNegativeInt(req, "minStock");
    int maxStock = nonNegativeInt(req, "maxStock");
    validateStockLimits(minStock, maxStock);

    boolean oldAutoCommit = conn.getAutoCommit();
    conn.setAutoCommit(false);
    try (PreparedStatement ps = conn.prepareStatement(
        "UPDATE Items SET price = ?, currentStock = ?, minStock = ?, maxStock = ? WHERE itemID = ?")) {
      ps.setBigDecimal(1, price);
      ps.setInt(2, currentStock);
      ps.setInt(3, minStock);
      ps.setInt(4, maxStock);
      ps.setInt(5, itemID);
      if (ps.executeUpdate() == 0) {
        throw new IllegalArgumentException("Item not found.");
      }
      recordItemUpdate(conn, managerID, itemID);
      conn.commit();
    } catch (SQLException e) {
      conn.rollback();
      throw e;
    } finally {
      conn.setAutoCommit(oldAutoCommit);
    }
  }

  private void hireSalesAssociate(Connection conn, HttpServletRequest req, String managerID) throws SQLException {
    String employeeID = required(req, "employeeID");
    String name = required(req, "name");
    String email = required(req, "email");
    String phoneNumber = required(req, "phoneNumber");

    boolean oldAutoCommit = conn.getAutoCommit();
    conn.setAutoCommit(false);
    try {
      if (!employeeExists(conn, employeeID)) {
        try (PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO Employees (employeeID, name, email, phoneNumber) VALUES (?, ?, ?, ?)")) {
          ps.setString(1, employeeID);
          ps.setString(2, name);
          ps.setString(3, email);
          ps.setString(4, phoneNumber);
          ps.executeUpdate();
        }
      }

      if (managerExists(conn, employeeID)) {
        throw new IllegalArgumentException("Managers cannot also be hired as sales associates.");
      }

      insertIgnore(conn, "INSERT IGNORE INTO SalesAssociates (salesAssociateID) VALUES (?)", employeeID);
      insertHire(conn, employeeID, managerID);
      conn.commit();
    } catch (SQLException e) {
      conn.rollback();
      throw e;
    } catch (IllegalArgumentException e) {
      conn.rollback();
      throw e;
    } finally {
      conn.setAutoCommit(oldAutoCommit);
    }
  }

  private void fireSalesAssociate(Connection conn, HttpServletRequest req) throws SQLException {
    String employeeID = required(req, "employeeID");
    if (!salesAssociateExists(conn, employeeID)) {
      throw new IllegalArgumentException("Sales associate not found.");
    }

    boolean oldAutoCommit = conn.getAutoCommit();
    conn.setAutoCommit(false);
    try {
      deleteWhere(conn, "DELETE FROM EmployeeDiscounts WHERE employeeID = ?", employeeID);
      deleteWhere(conn, "DELETE FROM EmployeePlaces WHERE employeeID = ?", employeeID);
      deleteWhere(conn, "DELETE FROM Hires WHERE salesAssociateID = ?", employeeID);
      deleteWhere(conn, "DELETE FROM SalesAssociates WHERE salesAssociateID = ?", employeeID);
      deleteWhere(conn, "DELETE FROM Employees WHERE employeeID = ?", employeeID);
      conn.commit();
    } catch (SQLException e) {
      conn.rollback();
      throw e;
    } finally {
      conn.setAutoCommit(oldAutoCommit);
    }
  }

  private void updateSalesAssociateId(Connection conn, HttpServletRequest req) throws SQLException {
    String oldID = required(req, "oldEmployeeID");
    String newID = required(req, "newEmployeeID");

    if (oldID.equals(newID)) {
      throw new IllegalArgumentException("New employee ID must be different.");
    }
    if (!salesAssociateExists(conn, oldID)) {
      throw new IllegalArgumentException("Sales associate not found.");
    }
    if (employeeExists(conn, newID)) {
      throw new IllegalArgumentException("That employee ID is already in use.");
    }

    boolean oldAutoCommit = conn.getAutoCommit();
    conn.setAutoCommit(false);
    try {
      Map<String, Object> employee = getEmployee(conn, oldID);
      try (PreparedStatement ps = conn.prepareStatement(
          "INSERT INTO Employees (employeeID, name, email, phoneNumber) VALUES (?, ?, ?, ?)")) {
        ps.setString(1, newID);
        ps.setString(2, String.valueOf(employee.get("name")));
        ps.setString(3, String.valueOf(employee.get("email")));
        ps.setString(4, String.valueOf(employee.get("phoneNumber")));
        ps.executeUpdate();
      }
      insertIgnore(conn, "INSERT IGNORE INTO SalesAssociates (salesAssociateID) VALUES (?)", newID);

      copyRows(conn, "SELECT employeeDiscountCode FROM EmployeeDiscounts WHERE employeeID = ?",
          "INSERT INTO EmployeeDiscounts (employeeID, employeeDiscountCode) VALUES (?, ?)", oldID, newID);
      copyRows(conn, "SELECT employeeOrderID, totalAmount, orderDate FROM EmployeePlaces WHERE employeeID = ?",
          "INSERT INTO EmployeePlaces (employeeID, employeeOrderID, totalAmount, orderDate) VALUES (?, ?, ?, ?)",
          oldID, newID);
      copyRows(conn, "SELECT managerID FROM Hires WHERE salesAssociateID = ?",
          "INSERT INTO Hires (salesAssociateID, managerID) VALUES (?, ?)", oldID, newID);

      deleteWhere(conn, "DELETE FROM EmployeeDiscounts WHERE employeeID = ?", oldID);
      deleteWhere(conn, "DELETE FROM EmployeePlaces WHERE employeeID = ?", oldID);
      deleteWhere(conn, "DELETE FROM Hires WHERE salesAssociateID = ?", oldID);
      deleteWhere(conn, "DELETE FROM SalesAssociates WHERE salesAssociateID = ?", oldID);
      deleteWhere(conn, "DELETE FROM Employees WHERE employeeID = ?", oldID);
      conn.commit();
    } catch (SQLException e) {
      conn.rollback();
      throw e;
    } finally {
      conn.setAutoCommit(oldAutoCommit);
    }
  }

  private void assignDiscount(Connection conn, HttpServletRequest req, String managerID) throws SQLException {
    changeDiscount(conn, req, managerID, true);
  }

  private void revokeDiscount(Connection conn, HttpServletRequest req, String managerID) throws SQLException {
    changeDiscount(conn, req, managerID, false);
  }

  private void assignBulkDiscount(Connection conn, HttpServletRequest req, String managerID) throws SQLException {
    String targetGroup = required(req, "targetGroup");
    String discountCode = required(req, "discountCode");

    boolean customers = "customers".equals(targetGroup);
    boolean employees = "employees".equals(targetGroup);
    boolean subscribers = "subscribers".equals(targetGroup);
    if (!customers && !employees) {
      throw new IllegalArgumentException("Choose Customers, Employees, or Everyone.");
    }

    boolean oldAutoCommit = conn.getAutoCommit();
    conn.setAutoCommit(false);
    try {
      if (customers) {
        insertBulkDiscount(conn,
            "INSERT IGNORE INTO CustomerDiscounts (customerEmail, customerDiscountCode) "
                + "SELECT email, ? FROM Customers",
            discountCode);
      }
      if (subscribers) {
        insertBulkDiscount(conn,
            "INSERT IGNORE INTO CustomerDiscounts (customerEmail, customerDiscountCode) "
                + "SELECT email, ? FROM Customers "
                + "WHERE isSubscribed = 1",
            discountCode);
      }
      if (employees) {
        insertBulkDiscount(conn,
            "INSERT IGNORE INTO EmployeeDiscounts (employeeID, employeeDiscountCode) "
                + "SELECT employeeID, ? FROM Employees",
            discountCode);
      }
      recordDiscountUpdate(conn, managerID, discountCode);
      conn.commit();
    } catch (SQLException e) {
      conn.rollback();
      throw e;
    } finally {
      conn.setAutoCommit(oldAutoCommit);
    }
  }

  private void changeDiscount(Connection conn, HttpServletRequest req, String managerID, boolean assign)
      throws SQLException {
    String targetType = required(req, "targetType");
    String targetID = required(req, "targetID");
    String discountCode = required(req, "discountCode");

    boolean customer = "customer".equals(targetType);
    boolean employee = "employee".equals(targetType);
    if (!customer && !employee) {
      throw new IllegalArgumentException("Choose Customer or Employee.");
    }

    String sql;
    if (assign && customer) {
      sql = "INSERT IGNORE INTO CustomerDiscounts (customerEmail, customerDiscountCode) VALUES (?, ?)";
    } else if (assign) {
      sql = "INSERT IGNORE INTO EmployeeDiscounts (employeeID, employeeDiscountCode) VALUES (?, ?)";
    } else if (customer) {
      sql = "DELETE FROM CustomerDiscounts WHERE customerEmail = ? AND customerDiscountCode = ?";
    } else {
      sql = "DELETE FROM EmployeeDiscounts WHERE employeeID = ? AND employeeDiscountCode = ?";
    }

    boolean oldAutoCommit = conn.getAutoCommit();
    conn.setAutoCommit(false);
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
      ps.setString(1, targetID);
      ps.setString(2, discountCode);
      ps.executeUpdate();
      recordDiscountUpdate(conn, managerID, discountCode);
      conn.commit();
    } catch (SQLException e) {
      conn.rollback();
      throw e;
    } finally {
      conn.setAutoCommit(oldAutoCommit);
    }
  }

  private void recordItemUpdate(Connection conn, String managerID, int itemID) throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(
        "INSERT IGNORE INTO UpdatesItem (managerID, itemID) VALUES (?, ?)")) {
      ps.setString(1, managerID);
      ps.setInt(2, itemID);
      ps.executeUpdate();
    }
  }

  private void recordDiscountUpdate(Connection conn, String managerID, String discountCode) throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(
        "INSERT IGNORE INTO UpdatesDiscount (managerID, discountCode) VALUES (?, ?)")) {
      ps.setString(1, managerID);
      ps.setString(2, discountCode);
      ps.executeUpdate();
    }
  }

  private void insertHire(Connection conn, String salesAssociateID, String managerID) throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(
        "INSERT IGNORE INTO Hires (salesAssociateID, managerID) VALUES (?, ?)")) {
      ps.setString(1, salesAssociateID);
      ps.setString(2, managerID);
      ps.executeUpdate();
    }
  }

  private void insertIgnore(Connection conn, String sql, String value) throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
      ps.setString(1, value);
      ps.executeUpdate();
    }
  }

  private void insertBulkDiscount(Connection conn, String sql, String discountCode) throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
      ps.setString(1, discountCode);
      ps.executeUpdate();
    }
  }

  private void deleteWhere(Connection conn, String sql, String value) throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
      ps.setString(1, value);
      ps.executeUpdate();
    }
  }

  private void copyRows(Connection conn, String selectSql, String insertSql, String oldID, String newID)
      throws SQLException {
    try (PreparedStatement select = conn.prepareStatement(selectSql)) {
      select.setString(1, oldID);
      try (ResultSet rs = select.executeQuery();
           PreparedStatement insert = conn.prepareStatement(insertSql)) {
        while (rs.next()) {
          insert.setString(1, newID);
          for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) {
            Object value = rs.getObject(i);
            if (value instanceof Date) {
              insert.setDate(i + 1, (Date) value);
            } else {
              insert.setObject(i + 1, value);
            }
          }
          insert.addBatch();
        }
        insert.executeBatch();
      }
    }
  }

  private boolean employeeExists(Connection conn, String employeeID) throws SQLException {
    return exists(conn, "SELECT 1 FROM Employees WHERE employeeID = ?", employeeID);
  }

  private boolean managerExists(Connection conn, String employeeID) throws SQLException {
    return exists(conn, "SELECT 1 FROM Managers WHERE managerID = ?", employeeID);
  }

  private boolean salesAssociateExists(Connection conn, String employeeID) throws SQLException {
    return exists(conn, "SELECT 1 FROM SalesAssociates WHERE salesAssociateID = ?", employeeID);
  }

  private boolean exists(Connection conn, String sql, String value) throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
      ps.setString(1, value);
      try (ResultSet rs = ps.executeQuery()) {
        return rs.next();
      }
    }
  }

  private String required(HttpServletRequest req, String name) {
    String value = trim(req.getParameter(name));
    if (value.isEmpty()) {
      throw new IllegalArgumentException("Required field missing: " + name);
    }
    return value;
  }

  private String trim(String value) {
    return value == null ? "" : value.trim();
  }

  private int positiveInt(HttpServletRequest req, String name) {
    int value = parseInt(req, name);
    if (value <= 0) {
      throw new IllegalArgumentException(name + " must be greater than 0.");
    }
    return value;
  }

  private int nonNegativeInt(HttpServletRequest req, String name) {
    int value = parseInt(req, name);
    if (value < 0) {
      throw new IllegalArgumentException(name + " cannot be negative.");
    }
    return value;
  }

  private int parseInt(HttpServletRequest req, String name) {
    try {
      return Integer.parseInt(required(req, name));
    } catch (NumberFormatException e) {
      throw new IllegalArgumentException(name + " must be a whole number.");
    }
  }

  private BigDecimal positiveMoney(HttpServletRequest req, String name) {
    try {
      BigDecimal value = new BigDecimal(required(req, name));
      if (value.compareTo(BigDecimal.ZERO) <= 0) {
        throw new IllegalArgumentException(name + " must be greater than 0.");
      }
      return value;
    } catch (NumberFormatException e) {
      throw new IllegalArgumentException(name + " must be a valid price.");
    }
  }

  private void validateStockLimits(int minStock, int maxStock) {
    if (minStock > maxStock) {
      throw new IllegalArgumentException("Minimum stock cannot be greater than maximum stock.");
    }
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
