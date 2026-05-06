package com.threadlink.auth;

import com.threadlink.db.Role;
import javax.servlet.http.HttpSession;

public class SessionUtil {

    private static final String ROLE_KEY = "role";
    private static final String USER_EMAIL_KEY = "userEmail";
    private static final String EMPLOYEE_ID_KEY = "employeeID";

    public static void loginCustomer(HttpSession session, String email) {
        session.setAttribute(ROLE_KEY, Role.CUSTOMER);
        session.setAttribute(USER_EMAIL_KEY, email);
    }

    public static void loginEmployee(HttpSession session, String employeeID, Role role) {
        session.setAttribute(ROLE_KEY, role);
        session.setAttribute(EMPLOYEE_ID_KEY, employeeID);
    }

    public static void logout(HttpSession session) {
        session.invalidate();
    }

    public static Role getRole(HttpSession session) {
        if (session == null) return null;
        return (Role) session.getAttribute(ROLE_KEY);
    }

    public static String getUserEmail(HttpSession session) {
        if (session == null) return null;
        return (String) session.getAttribute(USER_EMAIL_KEY);
    }

    public static String getEmployeeID(HttpSession session) {
        if (session == null) return null;
        return (String) session.getAttribute(EMPLOYEE_ID_KEY);
    }

    public static boolean isLoggedIn(HttpSession session) {
        return session != null && session.getAttribute(ROLE_KEY) != null;
    }

    public static boolean hasRole(HttpSession session, Role role) {
        return isLoggedIn(session) && role == getRole(session);
    }
}
