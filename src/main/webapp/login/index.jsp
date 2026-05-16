<%@ page import="com.threadlink.auth.SessionUtil, com.threadlink.db.Role" %>
<%
    Role currentRole = SessionUtil.getRole(request.getSession(false));
    if (currentRole == Role.CUSTOMER) {
        response.sendRedirect(request.getContextPath() + "/customer/home");
        return;
    }
    if (currentRole == Role.MANAGER) {
        response.sendRedirect(request.getContextPath() + "/manager/home");
        return;
    }
    if (currentRole == Role.SALES_ASSOCIATE) {
        response.sendRedirect(request.getContextPath() + "/employee/home");
        return;
    }
%>

<html>
<head>
    <title>ThreadLink | Log In Gateway</title>
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
                <span class="eyebrow">Who are you?</span>
                <h2>I am a:</h2>
            </div>
        </div>

        <div style="display:flex; gap:1.5rem; justify-content:center; flex-wrap:wrap; margin-top:2rem;">
            <a class="button button-login" href="<%= request.getContextPath() %>/login/customer_login.jsp"
               style="font-size:1.1rem; padding:1rem 2.5rem; text-decoration:none;">
                Customer
            </a>
            <a class="button button-login" href="<%= request.getContextPath() %>/login/employee_login.jsp"
               style="font-size:1.1rem; padding:1rem 2.5rem; text-decoration:none;">
                Employee
            </a>
        </div>
    </section>

</div>
</body>
</html>
