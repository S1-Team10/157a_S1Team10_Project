package com.threadlink.auth;

import com.threadlink.db.Role;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        String path = req.getServletPath();

        if (isPublic(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        Role role = SessionUtil.getRole(session);

        if (role == null) {
            String loginPage = path.startsWith("/employee/") || path.startsWith("/manager/")
                ? req.getContextPath() + "/employee/login"
                : req.getContextPath() + "/login";
            res.sendRedirect(loginPage);
            return;
        }

        // /manager/* — managers only
        if (path.startsWith("/manager/") && role != Role.MANAGER) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Manager access required.");
            return;
        }

        // /employee/* — sales associates and managers only
        if (path.startsWith("/employee/") && role == Role.CUSTOMER) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Employee access required.");
            return;
        }

        // /customer/* — customers only
        if (path.startsWith("/customer/") && role != Role.CUSTOMER) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Customer access required.");
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean isPublic(String path) {
        return path.equals("/")
            || path.equals("/login")
            || path.equals("/employee/login")
            || path.equals("/logout")
            || path.startsWith("/css/")
            || path.startsWith("/js/")
            || path.startsWith("/img/");
    }

}
