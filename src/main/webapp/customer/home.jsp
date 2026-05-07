<%@ page import="java.util.*, com.threadlink.web.HtmlUtils" %>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%
    String firstName = (String) request.getAttribute("firstName");
    String email = (String) request.getAttribute("email");
    String phoneNumber = (String) request.getAttribute("phoneNumber");
    String birthdate = (String) request.getAttribute("birthdate");
    Boolean isSubscribed = (Boolean) request.getAttribute("isSubscribed");
    List<Map<String, Object>> orders =
            (List<Map<String, Object>>) request.getAttribute("orders");

    String displayName = (firstName != null && !firstName.isEmpty())
            ? firstName : email;
%>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ThreadLink | Home</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/home.css">
</head>
<body>
<div class="page-shell">

    <nav class="site-nav">
        <div class="brand">
            <span class="brand-mark">ThreadLink</span>
            <a class="brand-name" href="<%= request.getContextPath() %>/">Modern Storefront</a>
        </div>
        <div class="nav-links">
            <a class="nav-link" href="<%= request.getContextPath() %>/search/index.jsp">Browse</a>
            <a class="nav-link" href="<%= request.getContextPath() %>/rewards">Rewards</a>
            <a class="nav-link login-link" href="<%= request.getContextPath() %>/logout">Log Out</a>
        </div>
    </nav>

    <!--welcome banner-->
    <section class="hero">
        <div class="hero-panel">
            <span class="eyebrow">Welcome back</span>
            <h1><%= HtmlUtils.escape(displayName) %>
            </h1>
            <p class="hero-copy">Manage your account, rewards, and order history below.</p>
            <div class="hero-actions">
                <a class="button button-primary" href="<%= request.getContextPath() %>/search/index.jsp">Browse
                    Catalog</a>
                <a class="button button-secondary" href="<%= request.getContextPath() %>/rewards">
                    <%= isSubscribed ? "Manage Rewards" : "Join Rewards" %>
                </a>
            </div>
        </div>
        <aside class="feature-panel">
            <div class="feature-card">
                <h3>Email</h3>
                <p><%= HtmlUtils.escape(email) %>
                </p>
            </div>
            <div class="feature-card">
                <h3>Phone</h3>
                <p><%= phoneNumber != null && !phoneNumber.isEmpty()
                        ? HtmlUtils.escape(phoneNumber) : "Not provided" %>
                </p>
            </div>
            <div class="feature-card">
                <h3>Birthdate</h3>
                <p><%= birthdate != null && !birthdate.isEmpty()
                        ? HtmlUtils.escape(birthdate) : "Not provided" %>
                </p>
            </div>
        </aside>
    </section>

    <!-- Order history -->
    <section class="catalog-page">
        <div class="catalog-page-header">
            <div>
                <span class="eyebrow">Order History</span>
                <h2 class="catalog-title">Your Orders</h2>
            </div>
        </div>

        <% if (orders == null || orders.isEmpty()) { %>
        <p class="message">You have not placed any orders yet.</p>
        <% } else { %>
        <table class="results-table">
            <thead>
            <tr>
                <th scope="col">Order ID</th>
                <th scope="col">Total</th>
                <th scope="col">Date</th>
            </tr>
            </thead>
            <tbody>
            <% for (Map<String, Object> order : orders) { %>
            <tr>
                <td>#<%= order.get("orderId") %>
                </td>
                <td class="price">$<%= order.get("totalAmount") %>
                </td>
                <td><%= order.get("orderDate") %>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
    </section>

</div>
</body>
</html>
