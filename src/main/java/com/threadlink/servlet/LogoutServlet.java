package com.threadlink.servlet;

import com.threadlink.auth.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;

public class LogoutServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            SessionUtil.logout(session);
        }
        res.sendRedirect(req.getContextPath() + "/");
    }

    // Allow GET so a simple link like <a href="/logout"> also works.
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        doPost(req, res);
    }
}
