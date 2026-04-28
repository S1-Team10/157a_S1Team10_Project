<%@ page import="java.sql.*"%>
<%
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>

<html>
<head>
    <title>ThreadLink - Create Account</title>
    <style>
        :root {
            --bg: #f6f1e8;
            --surface: rgba(255, 251, 245, 0.94);
            --surface-strong: #fffdf8;
            --ink: #1f1a17;
            --muted: #6a5e57;
            --accent: #b85c38;
            --accent-dark: #8d4123;
            --border: rgba(31, 26, 23, 0.12);
            --shadow: 0 18px 45px rgba(52, 32, 20, 0.12);
            --radius-lg: 28px;
            --radius-md: 18px;
            --radius-sm: 12px;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: "Trebuchet MS", "Segoe UI", sans-serif;
            color: var(--ink);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 24px;
            background:
                    radial-gradient(circle at top left, rgba(184, 92, 56, 0.18), transparent 32%),
                    radial-gradient(circle at right, rgba(84, 111, 82, 0.12), transparent 28%),
                    linear-gradient(180deg, #f8f3eb 0%, #f0e6d8 100%);
        }

        .container {
            width: 100%;
            max-width: 500px;
            animation: fadeUp 0.45s ease forwards;
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .brand-mark {
            font-size: 0.8rem;
            font-weight: 700;
            letter-spacing: 0.28rem;
            text-transform: uppercase;
            color: var(--accent);
            margin-bottom: 4px;
        }

        .brand-name {
            font-size: 1.3rem;
            font-weight: 700;
            margin-bottom: 32px;
        }

        .card {
            background: var(--surface);
            border: 1px solid rgba(255, 255, 255, 0.6);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow);
            padding: 2.5rem;
        }

        h2 { font-size: 1.6rem; font-weight: 700; margin-bottom: 6px; }

        .subtitle {
            color: var(--muted);
            font-size: 0.95rem;
            line-height: 1.6;
            margin-bottom: 28px;
        }

        .row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .field { margin-bottom: 20px; }

        label {
            display: block;
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 0.08rem;
            text-transform: uppercase;
            color: var(--muted);
            margin-bottom: 8px;
        }

        input[type="text"],
        input[type="email"],
        input[type="password"],
        input[type="tel"],
        input[type="date"] {
            width: 100%;
            padding: 1rem 1.1rem;
            border-radius: var(--radius-sm);
            border: 1px solid var(--border);
            background: var(--surface-strong);
            font-size: 1rem;
            font-family: inherit;
            color: var(--ink);
            outline: none;
            transition: border-color 0.2s;
        }

        input[type="text"]:focus,
        input[type="email"]:focus,
        input[type="password"]:focus,
        input[type="tel"]:focus,
        input[type="date"]:focus {
            outline: 2px solid rgba(184, 92, 56, 0.2);
            border-color: rgba(184, 92, 56, 0.45);
        }

        .divider { border: none; border-top: 1px solid var(--border); margin: 8px 0 24px; }

        .checkbox-row {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 24px;
        }

        .checkbox-row input[type="checkbox"] {
            width: 18px;
            height: 18px;
            accent-color: var(--accent);
            cursor: pointer;
        }

        .checkbox-row label {
            text-transform: none;
            letter-spacing: 0;
            font-size: 0.95rem;
            color: var(--ink);
            margin: 0;
            cursor: pointer;
        }

        input[type="submit"] {
            width: 100%;
            padding: 0.95rem 1.3rem;
            border-radius: 999px;
            border: none;
            background: var(--accent);
            color: #fff7f1;
            font-size: 0.95rem;
            font-weight: 700;
            font-family: inherit;
            cursor: pointer;
            transition: background 0.2s, transform 0.1s;
        }

        input[type="submit"]:hover { background: var(--accent-dark); }
        input[type="submit"]:active { transform: scale(0.98); }

        .message {
            padding: 0.85rem 1rem;
            border-radius: var(--radius-sm);
            font-size: 0.9rem;
            margin-bottom: 20px;
        }

        .error   { color: #9c2f21; font-weight: 700; background: rgba(156,47,33,0.08); border: 1px solid rgba(156,47,33,0.2); }
        .success { color: #2f6b3a; font-weight: 700; background: rgba(47,107,58,0.08); border: 1px solid rgba(47,107,58,0.2); }

        .footer-link {
            text-align: center;
            margin-top: 20px;
            font-size: 0.9rem;
            color: var(--muted);
        }

        .footer-link a { color: var(--accent-dark); text-decoration: none; font-weight: 700; }
        .footer-link a:hover { text-decoration: underline; }

        @media (max-width: 480px) {
            .row { grid-template-columns: 1fr; }
        }
    </style>
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
