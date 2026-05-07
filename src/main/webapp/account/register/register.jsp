<%@ page import="java.sql.*" %>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>

<html>
<head>
    <meta charset="UTF-8">
    <title>ThreadLink - Create Account</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/home.css">
</head>
<body>
<div class="page-shell">
    <h2>Create Account</h2>
    <%
        request.setAttribute("navActive", "featured");
        request.setAttribute("navShowSearch", Boolean.TRUE);
    %>

    <section class="login-panel">
        <div class="section-heading">
            <div>
                <span class="eyebrow">New Customer</span>
                <h2>Create your account</h2>
            </div>
        </div>

        <div class="login-layout">
            <div class="login-copy">
                <p>Join ThreadLink to access your orders, earn rewards, and shop faster.</p>
                <p>Already have an account? <a href="../login/login.jsp">Log in here.</a></p>
            </div>

            <form class="login-form" method="post" action="registerAction.jsp">

                <% if (errorMessage != null) { %>
                <p class="message error"><%= errorMessage %>
                </p>
                <% } %>

                <% if (successMessage != null) { %>
                <p class="message" style="color: #2d6a2d; font-weight: 700;"><%= successMessage %>
                </p>
                <% } %>

                <input class="login-input" type="text" name="firstName" placeholder="First name" required>
                <input class="login-input" type="text" name="lastName" placeholder="Last name">
                <input class="login-input" type="email" name="email" placeholder="Email address" required>

                <div>
                    <input class="login-input" type="password" name="password" placeholder="Password" required>
                    <ul class="password-requirements">
                        <li>At least 8 characters</li>
                        <li>One uppercase letter (A–Z)</li>
                        <li>One lowercase letter (a–z)</li>
                        <li>One number (0–9)</li>
                    </ul>
                </div>

                <input class="login-input" type="tel" name="phoneNumber" placeholder="Phone number (e.g. 4081234567)">
                <input class="login-input" type="date" name="birthdate">

                <label class="rewards-checkbox">
                    <input type="checkbox" name="isSubscribed" value="1">
                    Sign me up for the ThreadLink Rewards Program
                </label>

                <button class="button button-primary" type="submit">Create Account</button>
            </form>
        </div>
    </section>
</div>
</body>
</html>