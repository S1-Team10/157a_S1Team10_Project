<%@ page import="com.threadlink.auth.SessionUtil" %>
<%
    if (!SessionUtil.isLoggedIn(request.getSession(false))) {
        response.sendRedirect(request.getContextPath() + "/employee/login");
        return;
    }
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

</div>
</body>
</html>
