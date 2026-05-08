<%@ page import="com.threadlink.web.HtmlUtils" %>
<%
  String navActive = (String) request.getAttribute("navActive");
  if (navActive == null) navActive = "";

  boolean navShowSearch = Boolean.TRUE.equals(request.getAttribute("navShowSearch"));
  boolean navCatalogForm = Boolean.TRUE.equals(request.getAttribute("navCatalogForm"));

  String q = request.getParameter("q");
  if (q == null) q = "";

  String contextPath = request.getContextPath();
  String catalogFormAttrs = navCatalogForm
      ? " data-catalog-form data-api-url=\"" + contextPath + "/api/items\""
      : "";
  String searchInputAttrs = navCatalogForm ? " data-search-input" : "";
  String searchPlaceholder = navCatalogForm ? "Search by name or description" : "Search the catalog";
%>

<nav class="site-nav">
  <div class="brand">
    <span class="brand-mark">ThreadLink</span>
    <a class="brand-name" href="<%= contextPath %>/">Modern Storefront</a>
  </div>

  <% if (navShowSearch) { %>
    <form
      class="nav-search"
      method="get"
      action="<%= contextPath %>/search/index.jsp"
      <%= catalogFormAttrs %>
    >
      <input
        class="nav-search-input"
        id="q"
        name="q"
        type="text"
        <%= searchInputAttrs %>
        value="<%= HtmlUtils.escape(q) %>"
        placeholder="<%= searchPlaceholder %>"
      >
      <button class="button button-primary nav-search-button" type="submit">Search</button>
    </form>
  <% } %>

  <div class="nav-links">
    <a class="nav-link<%= "rewards".equals(navActive) ? " is-active" : "" %>" href="<%= contextPath %>/rewards">Rewards</a>
    <a class="nav-link login-link<%= "login".equals(navActive) ? " is-active" : "" %>" href="<%= contextPath %>/account/login">Log In</a>
  </div>
</nav>
