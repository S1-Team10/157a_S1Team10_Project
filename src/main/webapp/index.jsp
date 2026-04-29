<%@ page import="com.threadlink.web.HtmlUtils" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ThreadLink | Shop the Collection</title>
    <link rel="stylesheet" href="assets/css/home.css">
  </head>
  <body>
    <%
      String q = request.getParameter("q");
      if (q == null) q = "";
    %>

    <div class="page-shell">
      <nav class="site-nav">
        <div class="brand">
          <span class="brand-mark">ThreadLink</span>
          <a class="brand-name" href="index.jsp">Modern Storefront</a>
        </div>
        <form class="nav-search" method="get" action="search/index.jsp">
          <input
            class="nav-search-input"
            name="q"
            type="text"
            value="<%= HtmlUtils.escape(q) %>"
            placeholder="Search the catalog"
          >
          <button class="button button-primary nav-search-button" type="submit">Search</button>
        </form>
        <div class="nav-links">
          <a class="nav-link" href="#featured">Featured</a>
          <a class="nav-link" href="search/index.jsp">Search</a>
          <a class="nav-link login-link" href="#login">Log In</a>
        </div>
      </nav>

      <section class="hero" id="featured">
        <div class="hero-panel">
          <span class="eyebrow">Seasonal Drop</span>
          <h1>Shop standout pieces with a boutique storefront feel.</h1>
          <p class="hero-copy">
            Explore curated apparel, search the catalog directly from the navigation bar, and give returning shoppers a clear path to sign in from the top navigation.
          </p>
          <div class="hero-actions">
            <a class="button button-primary" href="search/index.jsp">Browse Products</a>
            <a class="button button-secondary" href="#login">Account Access</a>
          </div>
          <div class="pill-row">
            <span class="pill">Fresh arrivals</span>
            <span class="pill">Everyday staples</span>
            <span class="pill">Easy search</span>
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
            <p>A dedicated navigation link points users to a login section for account access, without adding account-creation functionality.</p>
          </div>
        </aside>
      </section>

      <section class="login-panel" id="login">
        <div class="section-heading">
          <div>
            <span class="eyebrow">Account Access</span>
            <h2>Log in to your account</h2>
          </div>
          <p>Navigation now includes a dedicated login link for returning shoppers.</p>
        </div>

        <div class="login-layout">
          <div class="login-copy">
            <p>
              This landing page now behaves more like a store homepage, with product discovery up front and a clear account-access entry point in the navigation bar.
            </p>
            <p>
              The section below is presentation-only and does not create new accounts. It gives users a familiar place to sign in once login functionality is wired up later.
            </p>
            <div class="pill-row">
              <span class="pill">Returning customers</span>
              <span class="pill">No account creation added</span>
              <span class="pill">Ready for future backend hookup</span>
            </div>
          </div>

          <form class="login-form" method="post" action="#">
            <input class="login-input" type="email" name="email" placeholder="Email address">
            <input class="login-input" type="password" name="password" placeholder="Password">
            <button class="button button-primary" type="submit">Log In</button>
            <p class="login-note">This form is a visual placeholder only. No login processing was added.</p>
          </form>
        </div>
      </section>
    </div>
  </body>
</html>
