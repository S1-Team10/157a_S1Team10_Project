package com.threadlink.web;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class RewardsServlet extends HttpServlet {

  private static final String UPDATE_SQL =
    "UPDATE Customers SET isSubscribed = ? WHERE customerID = ?";

  private static final String SELECT_SQL =
    "SELECT isSubscribed FROM Customers WHERE customerID = ?";

  // ── GET: render the rewards page ─────────────────────────────────────────
  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    response.setContentType("text/html; charset=UTF-8");
    response.setCharacterEncoding("UTF-8");

    HttpSession session = request.getSession(false);
    Integer customerId  = (session != null) ? (Integer) session.getAttribute("customerId") : null;

    if (customerId == null) {
      // Not logged in — forward to JSP which will show the login prompt
      request.setAttribute("loggedIn", false);
      request.getRequestDispatcher("/rewards/index.jsp").forward(request, response);
      return;
    }

    // Logged in — look up current subscription status
    String db       = getServletContext().getInitParameter("DB_NAME");
    String user     = getServletContext().getInitParameter("DB_USER");
    String password = getServletContext().getInitParameter("DB_PASSWORD");

    if (db == null || user == null || password == null) {
      response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
        "Database config is missing. Set DB_NAME, DB_USER, and DB_PASSWORD as app init params.");
      return;
    }

    try {
      boolean isSubscribed = fetchSubscriptionStatus(db, user, password, customerId);
      request.setAttribute("loggedIn",      true);
      request.setAttribute("customerId",    customerId);
      request.setAttribute("isSubscribed",  isSubscribed);
    } catch (Exception e) {
      request.setAttribute("loggedIn",   true);
      request.setAttribute("customerId", customerId);
      request.setAttribute("dbError",    sanitizeMessage(e));
    }

    request.getRequestDispatcher("/rewards/index.jsp").forward(request, response);
  }

  // ── POST: toggle subscription ─────────────────────────────────────────────
  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    HttpSession session = request.getSession(false);
    Integer customerId  = (session != null) ? (Integer) session.getAttribute("customerId") : null;

    if (customerId == null) {
      response.sendRedirect(request.getContextPath() + "/rewards");
      return;
    }

    String action = request.getParameter("action"); // "subscribe" or "cancel"
    boolean subscribe = "subscribe".equals(action);

    String db       = getServletContext().getInitParameter("DB_NAME");
    String user     = getServletContext().getInitParameter("DB_USER");
    String password = getServletContext().getInitParameter("DB_PASSWORD");

    if (db == null || user == null || password == null) {
      response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
        "Database config is missing.");
      return;
    }

    try {
      updateSubscription(db, user, password, customerId, subscribe);
      // PRG pattern — redirect to GET so refresh doesn't resubmit
      response.sendRedirect(
        request.getContextPath() + "/rewards?success=" + (subscribe ? "subscribed" : "cancelled")
      );
    } catch (Exception e) {
      request.setAttribute("loggedIn",      true);
      request.setAttribute("customerId",    customerId);
      request.setAttribute("isSubscribed",  subscribe); // optimistic fallback
      request.setAttribute("dbError",       sanitizeMessage(e));
      request.getRequestDispatcher("/rewards/index.jsp").forward(request, response);
    }
  }

  // ── DB helpers ─────────────────────────────────────────────────────────────
  private boolean fetchSubscriptionStatus(
      String db, String user, String password, int customerId)
      throws SQLException, ClassNotFoundException {

    Class.forName("com.mysql.cj.jdbc.Driver");
    String url = buildUrl(db);

    try (
      Connection con = DriverManager.getConnection(url, user, password);
      PreparedStatement ps = con.prepareStatement(SELECT_SQL)
    ) {
      ps.setInt(1, customerId);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          return rs.getBoolean("isSubscribed");
        }
      }
    }
    return false;
  }

  private void updateSubscription(
      String db, String user, String password, int customerId, boolean subscribe)
      throws SQLException, ClassNotFoundException {

    Class.forName("com.mysql.cj.jdbc.Driver");
    String url = buildUrl(db);

    try (
      Connection con = DriverManager.getConnection(url, user, password);
      PreparedStatement ps = con.prepareStatement(UPDATE_SQL)
    ) {
      ps.setBoolean(1, subscribe);
      ps.setInt(2, customerId);
      ps.executeUpdate();
    }
  }

  private String buildUrl(String db) {
    return "jdbc:mysql://localhost:3306/" + db + "?autoReconnect=true&useSSL=false";
  }

  private String sanitizeMessage(Exception e) {
    if (e instanceof ClassNotFoundException) {
      return "MySQL JDBC driver not found.";
    }
    // Don't expose raw SQL errors to the view
    return "A database error occurred. Please try again later.";
  }
}
