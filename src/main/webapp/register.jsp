<%@ page import="java.sql.*"%>
<%
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>

<html>
<head>
    <title>ThreadLink - Create Account</title>
</head>
<body>
<div class="register-box">
    <h2>Create Account</h2>

    <% if (errorMessage != null){ %>
    <p class="error"><%=errorMessage%></p>
<%}%>
    <% if (successMessage != null){ %>
        <p class="success"><%= successMessage%></p>
<%}%>
    <form method="post" action="registerAction.jsp">
        <label>First name</label>
        <input type="text" name="firstName" required/>

        <label>Last name</label>
        <input type="text" name="lastName">

        <label>Email</label>
        <input type="email" name="email" required/>

        <label>Password</label>
        <input type="password" name="password" required/>

        <label>Phone Number</label>
        <input type="tel" name="phoneNumber" placeholder="e.g. 4081234567"/>

        <label>Birthdate</label>
        <input type="date" name="birthdate"/>

        <div class="checkbox-row">
            <input type="checkbox" name="isSubscribed" value="1"/>
            <label>Subscribe to newsletter</label>
        </div>

        <input type="submit" value="Create Account"/>
    </form>

    <div class="login-link">
        Already have an account? <a href="login.jsp">Login</a>
    </div>
</div>
</body>
</html>
