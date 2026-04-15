<%@ page import="com.threadlink.web.HtmlUtils" %>
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
      <nav class="site-nav">
        <div class="brand">
          <span class="brand-mark">ThreadLink</span>
          <a class="brand-name" href="../index.jsp">Modern Storefront</a>
        </div>
        <form
          class="nav-search"
          method="get"
          action="."
          data-catalog-form
          data-api-url="<%= request.getContextPath() %>/api/items"
        >
          <input
            class="nav-search-input"
            id="q"
            name="q"
            type="text"
            data-search-input
            value="<%= HtmlUtils.escape(q) %>"
            placeholder="Search by name or description"
          >
          <button class="button button-primary nav-search-button" type="submit">Search</button>
        </form>
        <div class="nav-links">
          <a class="nav-link" href="../index.jsp#featured">Featured</a>
          <a class="nav-link is-active" href=".">Search</a>
          <a class="nav-link login-link" href="../index.jsp#login">Log In</a>
        </div>
      </nav>

      <section
        class="catalog-page"
        data-catalog-page
        data-selected-item-id="<%= HtmlUtils.escape(itemId) %>"
      >
        <div class="catalog-page-header">
          <div>
            <span class="eyebrow">Search Results</span>
            <h1 class="catalog-title">Browse matching items</h1>
            <p class="catalog-copy">
              Every search stays anchored in the navbar. Select a product in the table to review its details before future cart integration is added.
            </p>
          </div>
        </div>

        <p class="message error" data-results-error></p>
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

              <button class="button button-primary detail-cart-button" type="button">
                Add to Cart
              </button>
            </div>
          </aside>
        </div>
      </section>
    </div>

    <script src="../assets/js/catalog.js"></script>
  </body>
</html>
