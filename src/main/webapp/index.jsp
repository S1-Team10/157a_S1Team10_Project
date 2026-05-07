<%@ page import="com.threadlink.web.HtmlUtils" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ThreadLink | Shop the Collection</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/home.css">
  </head>
  <body>
    <%
      String q = request.getParameter("q");
      if (q == null) q = "";
    %>

    <div class="page-shell">
      <%
        request.setAttribute("navActive", "featured");
        request.setAttribute("navShowSearch", Boolean.TRUE);
      %>
      <jsp:include page="/WEB-INF/jsp/includes/site-nav.jsp" />

      <section class="hero" id="featured">
        <div class="hero-panel">
          <span class="eyebrow">Seasonal Drop</span>
          <h1>Shop standout pieces with a boutique storefront feel.</h1>
          <p class="hero-copy">
            Explore curated apparel, search the catalog directly from the navigation bar, and give returning shoppers a clear path to sign in from the top navigation.
          </p>
          <div class="hero-actions">
            <a class="button button-primary" href="search/index.jsp">Browse Products</a>
          </div>
        </div>

        <aside class="feature-panel">
          <div class="feature-card">
            <h3>New Arrivals</h3>
            <p>Highlight the latest styles with a cleaner storefront presentation that feels more like a shopping homepage than a utility page.</p>
          </div>
          <div class="feature-card">
            <h3>Fast Product Search</h3>
            <p>The navbar now takes shoppers to a dedicated results page, while the existing server-side search continues to power matching items behind the scenes.</p>
          </div>
          <div class="feature-card">
            <h3>Customer Access</h3>
            <p>A dedicated navigation link points users to the account login page when they need account access.</p>
          </div>
        </aside>
      </section>
    </div>
  </body>
</html>
