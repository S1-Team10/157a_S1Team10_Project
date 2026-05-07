<%@ page import="java.sql.*, java.security.MessageDigest" %>
<%@ page import="java.nio.charset.StandardCharsets" %>


<%
  String firstName = request.getParameter("firstName");
  String lastName = request.getParameter("lastName");
  String email = request.getParameter("email");
  String password = request.getParameter("password");
  String phoneNumber = request.getParameter("phoneNumber");
  String birthdate = request.getParameter("birthdate");
  String subscribe = request.getParameter("isSubscribed");
  int isSubscribed = (subscribe != null) ? 1 : 0;

// --- VALIDATE EMAIL FORMAT ---
  if (!email.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
    request.setAttribute("errorMessage", "Please enter a valid email address.");
    request.getRequestDispatcher("register.jsp").forward(request, response);
    return;
  }

// --- VALIDATE PASSWORD ---
  if (password.length() < 8) {
    request.setAttribute("errorMessage", "Password must be at least 8 characters.");
    request.getRequestDispatcher("register.jsp").forward(request, response);
    return;
  }
  if (!password.matches(".*[A-Z].*")) {
    request.setAttribute("errorMessage", "Password must contain at least one uppercase letter.");
    request.getRequestDispatcher("register.jsp").forward(request, response);
    return;
  }
  if (!password.matches(".*[a-z].*")) {
    request.setAttribute("errorMessage", "Password must contain at least one lowercase letter.");
    request.getRequestDispatcher("register.jsp").forward(request, response);
    return;
  }
  if (!password.matches(".*[0-9].*")) {
    request.setAttribute("errorMessage", "Password must contain at least one number.");
    request.getRequestDispatcher("register.jsp").forward(request, response);
    return;
  }

  // HASHING THE PASSWORD

  String hashedPassword ="";
  try{
    MessageDigest md = MessageDigest.getInstance("SHA-256");
    byte[] hash = md.digest(password.getBytes(StandardCharsets.UTF_8));
    StringBuilder sb = new StringBuilder();
    for (byte b : hash) {
      sb.append(String.format("%02x", b));
    }
    hashedPassword = sb.toString();
    } catch (Exception e){
      request.setAttribute("errorMessage", "Hashing error: " + e.getMessage());
      request.getRequestDispatcher("register.jsp").forward(request, response);
      return;
    }

  // CONNECTION TO THE DATABASE

  String db = application.getInitParameter("DB_NAME");
  String dbUser = application.getInitParameter("DB_USER");
  String dbPassword = application.getInitParameter("DB_PASSWORD");

  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/" + db + "?autoReconnect=true&useSSL=false",
    dbUser, dbPassword
    );

    // CHECK IF THE EMAIL EXISTS
    PreparedStatement check = connection.prepareStatement(
    "SELECT email FROM Customers WHERE email = ?"
    );
    check.setString(1, email);
    ResultSet rs = check.executeQuery();

    if (rs.next()) {
    request.setAttribute("errorMessage", "An account with that email already exists.");
    request.getRequestDispatcher("register.jsp").forward(request, response);
    return;
    }

    // NEW CUSTOMER

    PreparedStatement statement = connection.prepareStatement(
    "INSERT INTO Customers (firstName, lastName, email, password, phoneNumber, birthdate, isSubscribed) VALUES (?, ?, ?, ?, ?, ?, ?)"
    );
  statement.setString(1, firstName);
  statement.setString(2, (lastName == null    || lastName.isEmpty())    ? null : lastName);
  statement.setString(3, email);
  statement.setString(4, hashedPassword);
  statement.setString(5, (phoneNumber == null || phoneNumber.isEmpty()) ? null : phoneNumber);
  statement.setString(6, (birthdate == null   || birthdate.isEmpty())   ? null : birthdate);
  statement.setInt(7, isSubscribed);

  statement.executeUpdate();

  statement.close();
    check.close();
    connection.close();

    request.setAttribute("successMessage", "Account created! You can now log in.");
    request.getRequestDispatcher("register.jsp").forward(request, response);
    } catch (SQLException e) {
    request.setAttribute("errorMessage", "Database error: " + e.getMessage());
    request.getRequestDispatcher("register.jsp").forward(request, response);
    }
  %>