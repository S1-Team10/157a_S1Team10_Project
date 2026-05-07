package com.threadlink.web;

import com.threadlink.auth.SessionUtil;
import com.threadlink.db.DB;
import com.threadlink.db.Role;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class RewardsServlet extends HttpServlet {

  private static final String SELECT_SQL =
    "SELECT isSubscribed FROM Customers WHERE email = ?";

  private static final String UPDATE_SQL =
    "UPDATE Customers SET isSubscribed = ? WHERE email = ?";

  // ── GET: render the rewards page ─────────────────────────────────────────
  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

    response.setContentType("text/html; charset=UTF-8");
    response.setCharacterEncoding("UTF-8");

    HttpSession session = request.getSession(false);
    String userEmail = SessionUtil.getUserEmail(session);

    if (userEmail == null) {
      request.setAttribute("loggedIn", false);
      request.getRequestDispatcher("/rewards/index.jsp").forward(request, response);
      return;
    }

    try (Connection conn = DB.get(Role.CUSTOMER, getServletContext())) {
      boolean isSubscribed = fetchSubscriptionStatus(conn, userEmail);
      request.setAttribute("loggedIn",     true);
      request.setAttribute("isSubscribed", isSubscribed);
    } catch (SQLException e) {
      request.setAttribute("loggedIn", true);
      request.setAttribute("dbError",  sanitizeMessage(e));
    }

    request.getRequestDispatcher("/rewards/index.jsp").forward(request, response);
  }

  // ── POST: toggle subscription ─────────────────────────────────────────────
  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    HttpSession session = request.getSession(false);
    String userEmail = SessionUtil.getUserEmail(session);

    if (userEmail == null) {
      response.sendRedirect(request.getContextPath() + "/rewards");
      return;
    }

    String action = request.getParameter("action");
    boolean subscribe = "subscribe".equals(action);

    try (Connection conn = DB.get(Role.CUSTOMER, getServletContext())) {
      updateSubscription(conn, userEmail, subscribe);
      // PRG pattern — redirect to GET so refresh doesn't resubmit
      response.sendRedirect(
        request.getContextPath() + "/rewards?success=" + (subscribe ? "subscribed" : "cancelled")
      );
    } catch (SQLException e) {
      request.setAttribute("loggedIn",     true);
      request.setAttribute("isSubscribed", subscribe);
      request.setAttribute("dbError",      sanitizeMessage(e));
      request.getRequestDispatcher("/rewards/index.jsp").forward(request, response);
    }
  }

  // ── DB helpers ─────────────────────────────────────────────────────────────
  private boolean fetchSubscriptionStatus(Connection conn, String email) throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(SELECT_SQL)) {
      ps.setString(1, email);
      try (ResultSet rs = ps.executeQuery()) {
        return rs.next() && rs.getBoolean("isSubscribed");
      }
    }
  }

  private void updateSubscription(Connection conn, String email, boolean subscribe)
      throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement(UPDATE_SQL)) {
      ps.setBoolean(1, subscribe);
      ps.setString(2, email);
      ps.executeUpdate();
    }
  }

  private String sanitizeMessage(Exception e) {
    return "A database error occurred. Please try again later.";
  }
}
