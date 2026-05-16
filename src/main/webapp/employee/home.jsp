<%@ page import="com.threadlink.auth.SessionUtil" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="com.threadlink.web.HtmlUtils" %>
<%
    if (!SessionUtil.isLoggedIn(request.getSession(false))) {
        response.sendRedirect(request.getContextPath() + "/employee/login");
        return;
    }
    Map<String, Object> employee = (Map<String, Object>) request.getAttribute("employee");
    List<Map<String, Object>> items     = (List<Map<String, Object>>) request.getAttribute("items");
    List<Map<String, Object>> employees = (List<Map<String, Object>>) request.getAttribute("employees");
    List<Map<String, Object>> customers = (List<Map<String, Object>>) request.getAttribute("customers");
    String contextPath = request.getContextPath();
%>

<html>
<head>
    <title>ThreadLink | Employee Home</title>
    <link rel="stylesheet" href="../assets/css/home.css">
</head>
<body>
<div class="page-shell">

    <nav class="site-nav">
        <div class="brand">
            <span class="brand-mark">ThreadLink</span>
            <a class="brand-name" href="../index.jsp">Modern Storefront</a>
        </div>
        <div class="nav-links">
            <a class="nav-link" href="../index.jsp">Home</a>
            <% if ("Manager".equals(request.getAttribute("role"))) { %>
                <a class="nav-link" href="<%= request.getContextPath() %>/manager/home">Manager Dashboard</a>
            <% } %>
            <a class="nav-link" href="<%= request.getContextPath() %>/logout">Log Out</a>
        </div>
    </nav>

    <section class="login-panel">
        <div class="section-heading">
            <div>
                <span class="eyebrow"><%= request.getAttribute("role") %></span>
                <h2>Welcome, <%= request.getAttribute("name") %></h2>
            </div>
        </div>

        <div class="login-layout">
            <div class="login-copy">
                <p>Employee ID: <%= request.getAttribute("employeeID") %></p>
                <p>Email: <%= request.getAttribute("email") %></p>
                <p>Phone: <%= request.getAttribute("phoneNumber") %></p>
            </div>
        </div>
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
    
    <section class="manager-section">
        <div class="catalog-page-header">
            <span class="eyebrow">Inventory</span>
            <h2 class="catalog-title">View / Update Stock</h2>
        </div>

        <div class="manager-grid">
            <!-- sales associate can update stock, but not price or item details -->
            <form class="login-form" method="post" action="<%= contextPath %>/employee/home">
                <input type="hidden" name="action" value="updateStock">
                <h3>Update Stock</h3>
                <input class="login-input" list="itemIds" name="itemID" placeholder="Item ID" required>
                <input class="login-input" type="number" name="currentStock" min="0" placeholder="Current stock">
                <input class="login-input" type="number" name="minStock" min="0" placeholder="Min stock">
                <input class="login-input" type="number" name="maxStock" min="0" placeholder="Max stock">
                <button class="button button-primary" type="submit">Update</button>
            </form>
        </div>

        <datalist id="itemIds">
            <% for (Map<String, Object> item : items) { %>
            <option value="<%= item.get("itemID") %>">
                <%= HtmlUtils.escape(String.valueOf(item.get("itemName"))) %>
            </option>
            <% } %>
        </datalist>

        <!-- Search bar filters the table client-side via JS below -->
        <input class="login-input" type="text" id="itemSearch" placeholder="Search items..."
               oninput="filterTable('itemSearch', 'itemTable')" style="margin: 1rem 0;">

        <div class="manager-table-wrap">
            <table class="results-table" id="itemTable">
                <thead>
                <tr>
                    <th>ID</th><th>Name</th><th>Description</th><th>Price</th><th>Colors</th><th>Sizes</th><th>Current Stock</th><th>Min Stock</th><th>Max Stock</th>
                </tr>
                </thead>
                <tbody>
                <% for (Map<String, Object> item : items) { %>
                <tr>
                    <td><%= item.get("itemID") %></td>
                    <td><%= HtmlUtils.escape(String.valueOf(item.get("itemName"))) %></td>
                    <td><%= HtmlUtils.escape(String.valueOf(item.get("description"))) %></td>
                    <td>$<%= item.get("price") %></td>
                    <td><%= HtmlUtils.escape(String.valueOf(item.get("colors") != null ? item.get("colors") : item.get("color") != null ? item.get("color") : "")) %></td>
                    <td><%= HtmlUtils.escape(String.valueOf(item.get("sizes") != null ? item.get("sizes") : item.get("size") != null ? item.get("size") : "")) %></td>
                    <td><%= item.get("currentStock") != null ? item.get("currentStock") : "" %></td>
                    <td><%= item.get("minStock") %></td>
                    <td><%= item.get("maxStock") %></td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>

    <!-- Employees section — read-only, no management actions -->
    <section class="manager-section">
        <div class="catalog-page-header">
            <span class="eyebrow">Staff</span>
            <h2 class="catalog-title">All Employees</h2>
        </div>

        <input class="login-input" type="text" id="employeeSearch" placeholder="Search employees..."
               oninput="filterTable('employeeSearch', 'employeeTable')" style="margin: 1rem 0;">

        <div class="manager-table-wrap">
            <table class="results-table" id="employeeTable">
                <thead>
                <tr>
                    <th>Employee ID</th><th>Name</th><th>Email</th><th>Phone</th>
                </tr>
                </thead>
                <tbody>
                <% for (Map<String, Object> emp : employees) { %>
                <tr>
                    <td><%= HtmlUtils.escape(String.valueOf(emp.get("employeeID"))) %></td>
                    <td><%= HtmlUtils.escape(String.valueOf(emp.get("name"))) %></td>
                    <td><%= HtmlUtils.escape(String.valueOf(emp.get("email"))) %></td>
                    <td><%= HtmlUtils.escape(String.valueOf(emp.get("phoneNumber"))) %></td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>

    <!-- Customers section — limited fields only -->
    <section class="manager-section">
        <div class="catalog-page-header">
            <span class="eyebrow">Customers</span>
            <h2 class="catalog-title">All Customers</h2>
        </div>

        <input class="login-input" type="text" id="customerSearch" placeholder="Search customers..."
               oninput="filterTable('customerSearch', 'customerTable')" style="margin: 1rem 0;">

        <div class="manager-table-wrap">
            <table class="results-table" id="customerTable">
                <thead>
                <tr>
                    <th>First Name</th><th>Last Name</th><th>Email</th><th>Phone</th><th>Subscribed</th>
                </tr>
                </thead>
                <tbody>
                <% for (Map<String, Object> customer : customers) { %>
                <tr>
                    <td><%= HtmlUtils.escape(String.valueOf(customer.get("firstName"))) %></td>
                    <td><%= HtmlUtils.escape(String.valueOf(customer.get("lastName"))) %></td>
                    <td><%= HtmlUtils.escape(String.valueOf(customer.get("email"))) %></td>
                    <td><%= HtmlUtils.escape(String.valueOf(customer.get("phoneNumber"))) %></td>
                    <td><%= Boolean.TRUE.equals(customer.get("isSubscribed")) ? "Yes" : "No" %></td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>

</div>

<!-- Client-side search: hides rows that don't match the search input -->
<script>
    function filterTable(inputId, tableId) {
        var filter = document.getElementById(inputId).value.toLowerCase();
        var rows = document.getElementById(tableId).getElementsByTagName("tr");
        for (var i = 1; i < rows.length; i++) {
            rows[i].style.display = rows[i].textContent.toLowerCase().includes(filter) ? "" : "none";
        }
    }
</script>

</div>
</body>
</html>
