<%@ page import="com.threadlink.web.HtmlUtils" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ThreadLink | Search Results</title>
    <link rel="stylesheet" href="../assets/css/home.css">
  </head>
  <body>
    <%
      String q = request.getParameter("q");
      if (q == null) q = "";

      String itemId = request.getParameter("itemId");
      if (itemId == null) itemId = "";
    %>

    <div class="page-shell">
      <%
        request.setAttribute("navActive", "search");
        request.setAttribute("navShowSearch", Boolean.TRUE);
        request.setAttribute("navCatalogForm", Boolean.TRUE);
      %>
      <jsp:include page="/WEB-INF/jsp/includes/site-nav.jsp" />

      <section
        class="catalog-page"
        data-catalog-page
        data-selected-item-id="<%= HtmlUtils.escape(itemId) %>"
        data-order-url="<%= request.getContextPath() %>/customer/orders"
        data-login-url="<%= request.getContextPath() %>/account/login"
      >
        <div class="catalog-page-header">
          <div>
            <span class="eyebrow">Search Results</span>
            <h1 class="catalog-title">Browse matching items</h1>
          </div>
        </div>

        <p class="message error" data-results-error hidden></p>
        <p class="message" data-results-status>Loading products...</p>

        <div class="catalog-layout">
          <section class="catalog-results">
            <table class="results-table" data-results-table hidden>
              <thead>
                <tr>
                  <th scope="col">Item ID</th>
                  <th scope="col">Product</th>
                  <th scope="col">Description</th>
                  <th scope="col">Price</th>
                </tr>
              </thead>
              <tbody data-results-body></tbody>
            </table>
          </section>

          <aside class="item-detail" data-item-detail>
            <div class="item-detail-empty" data-item-detail-empty>
              Select a product in the table to see more details.
            </div>

            <div class="item-detail-card" data-item-detail-card hidden>
              <span class="detail-kicker" data-detail-id></span>
              <h2 data-detail-name></h2>
              <p class="detail-price" data-detail-price></p>
              <p class="detail-description" data-detail-description></p>

              <div class="detail-meta">
                <div class="detail-chip-group">
                  <span class="detail-label">Sizes</span>
                  <p data-detail-sizes></p>
                </div>
                <div class="detail-chip-group">
                  <span class="detail-label">Colors</span>
                  <p data-detail-colors></p>
                </div>
                <div class="detail-chip-group">
                  <span class="detail-label">Stock Range</span>
                  <p data-detail-stock></p>
                </div>
              </div>

              <button class="button button-primary detail-cart-button" type="button" data-add-to-cart>
                Add to Cart
              </button>
            </div>

            <div class="cart-panel" data-cart-panel>
              <div class="cart-panel-header">
                <div>
                  <span class="detail-kicker">Cart</span>
                  <h2>Your order</h2>
                </div>
                <button class="cart-clear-button" type="button" data-cart-clear>Clear</button>
              </div>

              <p class="item-detail-empty" data-cart-empty>Your cart is empty.</p>
              <ul class="cart-list" data-cart-list></ul>

              <div class="cart-total" data-cart-total-row hidden>
                <span>Total</span>
                <strong data-cart-total>$0.00</strong>
              </div>

              <p class="message" data-order-status hidden></p>
              <p class="message error" data-order-error hidden></p>

              <button class="button button-primary detail-cart-button" type="button" data-place-order disabled>
                Place Order
              </button>
            </div>
          </aside>
        </div>
      </section>
    </div>

    <script src="../assets/js/catalog.js"></script>
  </body>
</html>
