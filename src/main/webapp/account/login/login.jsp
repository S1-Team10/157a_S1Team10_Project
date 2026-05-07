<%@ page import="com.threadlink.auth.SessionUtil" %>
<%
    // If already logged in, skip the login page entirely
    if (SessionUtil.isLoggedIn(request.getSession(false))) {
        response.sendRedirect(request.getContextPath() + "/customer/home");
        return;
    }

    // The servlet sets this attribute on failed login
    String error = (String) request.getAttribute("error");
%>

<html>
<head>
    <title>ThreadLink | Log In</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/home.css">
</head>
<body>
<div class="page-shell">

    <%
        request.setAttribute("navActive", "login");
    %>
    <jsp:include page="/WEB-INF/jsp/includes/site-nav.jsp" />

    <section class="login-panel">
        <div class="section-heading">
            <div>
                <span class="eyebrow">Account Access</span>
                <h2>Log in to your account</h2>
            </div>
        </div>

        <div class="login-layout">
            <div class="login-copy">
                <p>Welcome back. Enter your email and password to access your
                    account.</p>
                <p>Don't have an account? <a href="<%= request.getContextPath() %>/account/register/register.jsp">Create
                    one here.</a></p>
            </div>


            <form class="login-form" method="post" action="<%= request.getContextPath() %>/account/login">


                <% if (error != null) { %>
                <p class="message error"><%= error %>
                </p>
                <% } %>

                <input class="login-input" type="email" name="email"
                       placeholder="Email address" required>
                <input class="login-input" type="password" name="password"
                       placeholder="Password" required>
                <button class="button button-primary" type="submit">Log
                    In
                </button>
            </form>
        </div>
    </section>

</div>

</body>
</html>
