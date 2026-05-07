<%@ page import="com.threadlink.auth.SessionUtil" %>
<%
    if (SessionUtil.isLoggedIn(request.getSession(false))) {
        response.sendRedirect(request.getContextPath() + "/employee/home");
        return;
    }
    String error = (String) request.getAttribute("error");
%>

<html>
<head>
    <title>ThreadLink | Employee Login</title>
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
        </div>
    </nav>

    <section class="login-panel">
        <div class="section-heading">
            <div>
                <span class="eyebrow">Staff Portal</span>
                <h2>Employee Sign In</h2>
            </div>
        </div>

        <div class="login-layout">
            <div class="login-copy">
                <p>This portal is for sales associates and managers only.</p>
                <p>Enter your Employee ID to continue.</p>
            </div>

            <form class="login-form" method="post" action="<%= request.getContextPath() %>/employee/login">

                <% if (error != null) { %>
                <p class="message error"><%= error %>
                </p>
                <% } %>

                <!-- Must match: req.getParameter("employeeID") in EmployeeLoginServlet -->
                <input class="login-input" type="text" name="employeeID" placeholder="Employee ID" required>
                <button class="button button-primary" type="submit">Sign In</button>
            </form>
        </div>
    </section>

</div>
</body>
</html>
