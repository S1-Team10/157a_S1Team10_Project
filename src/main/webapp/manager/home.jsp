<%@ page import="java.util.*, com.threadlink.web.HtmlUtils" %>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%
  Map<String, Object> manager = (Map<String, Object>) request.getAttribute("manager");
  List<Map<String, Object>> items = (List<Map<String, Object>>) request.getAttribute("items");
  List<Map<String, Object>> salesAssociates = (List<Map<String, Object>>) request.getAttribute("salesAssociates");
  List<Map<String, Object>> discounts = (List<Map<String, Object>>) request.getAttribute("discounts");
  List<Map<String, Object>> customers = (List<Map<String, Object>>) request.getAttribute("customers");
  List<Map<String, Object>> employees = (List<Map<String, Object>>) request.getAttribute("employees");
  String success = (String) request.getAttribute("success");
  String error = (String) request.getAttribute("error");
  String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ThreadLink | Manager Dashboard</title>
  <link rel="stylesheet" href="<%= contextPath %>/assets/css/home.css">
</head>
<body>
<div class="page-shell">
  <nav class="site-nav">
    <div class="brand">
      <span class="brand-mark">ThreadLink</span>
      <a class="brand-name" href="<%= contextPath %>/">Modern Storefront</a>
    </div>
    <div class="nav-links">
      <a class="nav-link" href="<%= contextPath %>/search/index.jsp">Browse</a>
      <a class="nav-link login-link" href="<%= contextPath %>/logout">Log Out</a>
    </div>
  </nav>

  <section class="login-panel">
    <div class="section-heading">
      <div>
        <span class="eyebrow">Manager</span>
        <h2>Welcome, <%= HtmlUtils.escape(String.valueOf(manager.get("name"))) %></h2>
      </div>
    </div>
    <div class="login-copy">
      <p>Employee ID: <%= HtmlUtils.escape(String.valueOf(manager.get("employeeID"))) %></p>
      <p>Email: <%= HtmlUtils.escape(String.valueOf(manager.get("email"))) %></p>
      <p>Phone: <%= HtmlUtils.escape(String.valueOf(manager.get("phoneNumber"))) %></p>
    </div>
    <% if (success != null) { %>
      <p class="message success"><%= HtmlUtils.escape(success) %></p>
    <% } %>
    <% if (error != null) { %>
      <p class="message error"><%= HtmlUtils.escape(error) %></p>
    <% } %>
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
      <h2 class="catalog-title">Manage Items</h2>
    </div>

    <div class="manager-grid">
      <form class="login-form" method="post" action="<%= contextPath %>/manager/home">
        <input type="hidden" name="action" value="addItem">
        <h3>Add Item</h3>
        <input class="login-input" type="text" name="itemName" placeholder="Item name" required>
        <input class="login-input" type="text" name="description" placeholder="Description">
        <input class="login-input" type="number" name="price" min="0.01" step="0.01" placeholder="Price" required>
        <input class="login-input" type="text" name="colors" placeholder="Colors">
        <input class="login-input" type="text" name="sizes" placeholder="Sizes">
        <input class="login-input" type="number" name="currentStock" min="0" step="1" placeholder="Current stock" required>
        <input class="login-input" type="number" name="minStock" min="0" step="1" placeholder="Minimum stock" required>
        <input class="login-input" type="number" name="maxStock" min="0" step="1" placeholder="Maximum stock" required>
        <button class="button button-primary" type="submit">Add Item</button>
      </form>

      <form class="login-form" method="post" action="<%= contextPath %>/manager/home">
        <input type="hidden" name="action" value="updateItem">
        <h3>Set Price and Stock Limits</h3>
        <input class="login-input" list="itemIds" name="itemID" placeholder="Item ID" required>
        <input class="login-input" type="number" name="price" min="0.01" step="0.01" placeholder="New price" required>
        <input class="login-input" type="number" name="currentStock" min="0" step="1" placeholder="Current stock" required>
        <input class="login-input" type="number" name="minStock" min="0" step="1" placeholder="Minimum stock" required>
        <input class="login-input" type="number" name="maxStock" min="0" step="1" placeholder="Maximum stock" required>
        <button class="button button-primary" type="submit">Update Item</button>
      </form>

      <form class="login-form" method="post" action="<%= contextPath %>/manager/home">
        <input type="hidden" name="action" value="deleteItem">
        <h3>Delete Item</h3>
        <input class="login-input" list="itemIds" name="itemID" placeholder="Item ID" required>
        <button class="button button-secondary" type="submit">Delete Item</button>
      </form>
    </div>

    <datalist id="itemIds">
      <% for (Map<String, Object> item : items) { %>
        <option value="<%= item.get("itemID") %>"><%= HtmlUtils.escape(String.valueOf(item.get("itemName"))) %></option>
      <% } %>
    </datalist>

    <div class="manager-table-wrap">
      <table class="results-table">
        <thead>
        <tr>
          <th>Item ID</th>
          <th>Name</th>
          <th>Description</th>
          <th>Price</th>
          <th>Colors</th>
          <th>Sizes</th>
          <th>Current</th>
          <th>Min</th>
          <th>Max</th>
        </tr>
        </thead>
        <tbody>
        <% for (Map<String, Object> item : items) { %>
          <tr>
            <td><%= item.get("itemID") %></td>
            <td><%= HtmlUtils.escape(String.valueOf(item.get("itemName"))) %></td>
            <td><%= HtmlUtils.escape(String.valueOf(item.get("description"))) %></td>
            <td class="price">$<%= item.get("price") %></td>
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

  <section class="manager-section">
    <div class="catalog-page-header">
      <span class="eyebrow">Sales Associates</span>
      <h2 class="catalog-title">Manage Staff</h2>
    </div>

    <div class="manager-grid">
      <form class="login-form" method="post" action="<%= contextPath %>/manager/home">
        <input type="hidden" name="action" value="hireSalesAssociate">
        <h3>Hire Sales Associate</h3>
        <input class="login-input" type="text" name="employeeID" placeholder="Employee ID" maxlength="10" required>
        <input class="login-input" type="text" name="name" placeholder="Name" required>
        <input class="login-input" type="email" name="email" placeholder="Email" required>
        <input class="login-input" type="tel" name="phoneNumber" placeholder="Phone number" required>
        <button class="button button-primary" type="submit">Hire</button>
      </form>

      <form class="login-form" method="post" action="<%= contextPath %>/manager/home">
        <input type="hidden" name="action" value="updateSalesAssociateId">
        <h3>Update Sales Associate ID</h3>
        <input class="login-input" list="salesAssociateIds" name="oldEmployeeID" placeholder="Current employee ID" required>
        <input class="login-input" type="text" name="newEmployeeID" placeholder="New employee ID" maxlength="10" required>
        <button class="button button-primary" type="submit">Update ID</button>
      </form>

      <form class="login-form" method="post" action="<%= contextPath %>/manager/home">
        <input type="hidden" name="action" value="fireSalesAssociate">
        <h3>Fire Sales Associate</h3>
        <input class="login-input" list="salesAssociateIds" name="employeeID" placeholder="Employee ID" required>
        <button class="button button-secondary" type="submit">Fire</button>
      </form>
    </div>

    <datalist id="salesAssociateIds">
      <% for (Map<String, Object> employee : salesAssociates) { %>
        <option value="<%= HtmlUtils.escape(String.valueOf(employee.get("employeeID"))) %>">
          <%= HtmlUtils.escape(String.valueOf(employee.get("name"))) %>
        </option>
      <% } %>
    </datalist>

    <div class="manager-table-wrap">
      <table class="results-table">
        <thead>
        <tr>
          <th>Employee ID</th>
          <th>Name</th>
          <th>Email</th>
          <th>Phone</th>
        </tr>
        </thead>
        <tbody>
        <% for (Map<String, Object> employee : salesAssociates) { %>
          <tr>
            <td><%= HtmlUtils.escape(String.valueOf(employee.get("employeeID"))) %></td>
            <td><%= HtmlUtils.escape(String.valueOf(employee.get("name"))) %></td>
            <td><%= HtmlUtils.escape(String.valueOf(employee.get("email"))) %></td>
            <td><%= HtmlUtils.escape(String.valueOf(employee.get("phoneNumber"))) %></td>
          </tr>
        <% } %>
        </tbody>
      </table>
    </div>
  </section>

  <section class="manager-section">
    <div class="catalog-page-header">
      <span class="eyebrow">Discounts</span>
      <h2 class="catalog-title">Assign Discounts</h2>
    </div>

    <div class="manager-grid manager-grid-compact">
      <form class="login-form" method="post" action="<%= contextPath %>/manager/home">
        <input type="hidden" name="action" value="assignDiscount">
        <h3>Give Discount</h3>
        <select class="login-input" name="targetType" required>
          <option value="customer">Customer</option>
          <option value="employee">Employee</option>
        </select>
        <input class="login-input" list="discountTargets" name="targetID" placeholder="Customer email or employee ID" required>
        <input class="login-input" list="discountCodes" name="discountCode" placeholder="Discount code" required>
        <button class="button button-primary" type="submit">Give Discount</button>
      </form>

      <form class="login-form" method="post" action="<%= contextPath %>/manager/home">
        <input type="hidden" name="action" value="revokeDiscount">
        <h3>Remove Discount</h3>
        <select class="login-input" name="targetType" required>
          <option value="customer">Customer</option>
          <option value="employee">Employee</option>
        </select>
        <input class="login-input" list="discountTargets" name="targetID" placeholder="Customer email or employee ID" required>
        <input class="login-input" list="discountCodes" name="discountCode" placeholder="Discount code" required>
        <button class="button button-secondary" type="submit">Remove Discount</button>
      </form>
    </div>

    <datalist id="discountTargets">
      <% for (Map<String, Object> customer : customers) { %>
        <option value="<%= HtmlUtils.escape(String.valueOf(customer.get("email"))) %>">
          <%= HtmlUtils.escape(String.valueOf(customer.get("firstName"))) %> <%= HtmlUtils.escape(String.valueOf(customer.get("lastName"))) %>
        </option>
      <% } %>
      <% for (Map<String, Object> employee : employees) { %>
        <option value="<%= HtmlUtils.escape(String.valueOf(employee.get("employeeID"))) %>">
          <%= HtmlUtils.escape(String.valueOf(employee.get("name"))) %>
        </option>
      <% } %>
    </datalist>

    <datalist id="discountCodes">
      <% for (Map<String, Object> discount : discounts) { %>
        <option value="<%= HtmlUtils.escape(String.valueOf(discount.get("discountCode"))) %>">
          <%= HtmlUtils.escape(String.valueOf(discount.get("discountName"))) %>
        </option>
      <% } %>
    </datalist>

    <div class="manager-table-wrap">
      <table class="results-table">
        <thead>
        <tr>
          <th>Code</th>
          <th>Name</th>
          <th>Percent</th>
          <th>Start</th>
          <th>End</th>
        </tr>
        </thead>
        <tbody>
        <% for (Map<String, Object> discount : discounts) { %>
          <tr>
            <td><%= HtmlUtils.escape(String.valueOf(discount.get("discountCode"))) %></td>
            <td><%= HtmlUtils.escape(String.valueOf(discount.get("discountName"))) %></td>
            <td><%= discount.get("percentOff") %>%</td>
            <td><%= discount.get("startDate") %></td>
            <td><%= discount.get("endDate") %></td>
          </tr>
        <% } %>
        </tbody>
      </table>
    </div>
  </section>
  <!-- Customers -->
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
