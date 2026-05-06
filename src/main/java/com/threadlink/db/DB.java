package com.threadlink.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import javax.servlet.ServletContext;

public class DB {

    public static Connection get(Role role, ServletContext ctx) throws SQLException {
        String prefix;
        if (role == Role.CUSTOMER) {
            prefix = "CUSTOMER";
        }
        else if (role == Role.SALES_ASSOCIATE) {
            prefix = "SALES";
        }
        else if (role == Role.MANAGER) {
            prefix = "MANAGER";
        }
        else {
            throw new IllegalArgumentException("Unknown Role: " + role);
        }

        String db = ctx.getInitParameter("DB_NAME");
        String user = ctx.getInitParameter("DB_" + prefix + "_USER");
        String pwd = ctx.getInitParameter("DB_" + prefix + "_PASSWORD");

        String url = "jdbc:mysql://localhost:3306/" + db + "?useSSL=false";
        return DriverManager.getConnection(url, user, pwd);
    }
}
