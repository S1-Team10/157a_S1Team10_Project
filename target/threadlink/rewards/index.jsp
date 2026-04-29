<%@ page import="com.threadlink.web.HtmlUtils" %>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ThreadLink | Rewards Program</title>
    <link rel="stylesheet" href="../assets/css/home.css">
    <link rel="stylesheet" href="../assets/css/rewards.css">
  </head>
  <body>
    <%
      boolean loggedIn     = Boolean.TRUE.equals(request.getAttribute("loggedIn"));
      boolean isSubscribed = Boolean.TRUE.equals(request.getAttribute("isSubscribed"));
      String  dbError      = (String) request.getAttribute("dbError");

      String successParam  = request.getParameter("success");
      boolean justSubbed   = "subscribed".equals(successParam);
      boolean justCancelled = "cancelled".equals(successParam);
    %>

    <div class="page-shell">
      <nav class="site-nav">
        <div class="brand">
          <span class="brand-mark">ThreadLink</span>
          <a class="brand-name" href="../index.jsp">Modern Storefront</a>
        </div>
        <div class="nav-links">
          <a class="nav-link" href="../index.jsp#featured">Featured</a>
          <a class="nav-link" href="../search/index.jsp">Search</a>
          <a class="nav-link is-active" href=".">Rewards</a>
          <a class="nav-link login-link" href="../index.jsp#login">Log In</a>
        </div>
      </nav>

      <main class="rewards-page">

        <div class="rewards-hero">
          <span class="eyebrow">Members Only</span>
          <h1 class="rewards-title">ThreadLink Rewards</h1>
          <p class="rewards-copy">
            Join our rewards program and unlock exclusive discounts, early access to new
            arrivals, and members-only promotions — all for free.
          </p>
        </div>

        <div class="rewards-layout">

          <!-- ── Perks column ── -->
          <section class="rewards-perks">
            <h2>What you get</h2>
            <ul class="perks-list">
              <li class="perk-item">
                <span class="perk-icon">🏷️</span>
                <div>
                  <strong>Member Discounts</strong>
                  <p>Save up to 20% on every order, automatically applied at checkout.</p>
                </div>
              </li>
              <li class="perk-item">
                <span class="perk-icon">🚀</span>
                <div>
                  <strong>Early Access</strong>
                  <p>Shop new arrivals 48 hours before they go public.</p>
                </div>
              </li>
              <li class="perk-item">
                <span class="perk-icon">🎁</span>
                <div>
                  <strong>Birthday Bonus</strong>
                  <p>A special gift added to your account every year on your birthday.</p>
                </div>
              </li>
              <li class="perk-item">
                <span class="perk-icon">📦</span>
                <div>
                  <strong>Free Shipping</strong>
                  <p>No minimums. Free standard shipping on every rewards order.</p>
                </div>
              </li>
            </ul>
          </section>

          <!-- ── Action card column ── -->
          <aside class="rewards-card">

            <% if (dbError != null) { %>
              <p class="message error rewards-notice">
                <%= HtmlUtils.escape(dbError) %>
              </p>
            <% } %>

            <% if (justSubbed) { %>
              <div class="rewards-notice rewards-notice--success">
                🎉 You're in! Welcome to ThreadLink Rewards.
              </div>
            <% } else if (justCancelled) { %>
              <div class="rewards-notice rewards-notice--info">
                Your rewards membership has been cancelled. You can re-join any time.
              </div>
            <% } %>

            <% if (!loggedIn) { %>
              <!-- ── Not logged in ── -->
              <div class="rewards-login-prompt">
                <h2>Sign up for Rewards</h2>
                <p>
                  You need to be logged in to join the rewards program.
                  Please log in or create an account to continue.
                </p>
                <div class="rewards-actions">
                  <a class="button button-primary" href="../index.jsp#login">Log In</a>
                  <a class="button button-secondary" href="../index.jsp#login">Create Account</a>
                </div>
                <p class="login-note">
                  Already a rewards member? Log in to manage your membership.
                </p>
              </div>

            <% } else if (!isSubscribed) { %>
              <!-- ── Logged in, not subscribed ── -->
              <h2>Join for free</h2>
              <p class="rewards-card-copy">
                Sign up in one click — no credit card required. Cancel any time.
              </p>
              <form method="post" action="<%= request.getContextPath() %>/rewards">
                <input type="hidden" name="action" value="subscribe">
                <button class="button button-primary rewards-submit" type="submit">
                  Sign Me Up
                </button>
              </form>

            <% } else { %>
              <!-- ── Logged in, subscribed ── -->
              <div class="rewards-active-badge">
                <span class="rewards-badge-icon">✓</span>
                <div>
                  <strong>You're a rewards member</strong>
                  <p>All perks are active on your account.</p>
                </div>
              </div>
              <form method="post" action="<%= request.getContextPath() %>/rewards">
                <input type="hidden" name="action" value="cancel">
                <button class="button button-secondary rewards-cancel" type="submit">
                  Cancel Membership
                </button>
              </form>
              <p class="login-note">
                Cancelling will immediately remove your member benefits.
              </p>
            <% } %>

          </aside>
        </div>
      </main>
    </div>
  </body>
</html>
