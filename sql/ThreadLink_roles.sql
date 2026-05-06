------ setup ------
CREATE ROLE 'customer', 'sales_associate', 'manager';

CREATE USER 'customer_app'@'localhost' IDENTIFIED BY 'customer_password';
CREATE USER 'sales_app'@'localhost' IDENTIFIED BY 'sales_password';
CREATE USER 'manager_app'@'localhost' IDENTIFIED BY 'manager_password';

GRANT 'customer' TO 'customer_app'@'localhost';
GRANT 'sales_associate' TO 'sales_app'@'localhost';
GRANT 'manager' TO 'manager_app'@'localhost';

SET DEFAULT ROLE ALL TO
'customer_app'@'localhost',
'sales_app'@'localhost',
'manager_app'@'localhost';

------ customer ------
-- account management --
GRANT SELECT, INSERT, UPDATE, DELETE ON ThreadLink.Customers TO 'customer';

-- browse the website --
GRANT SELECT ON ThreadLink.Items TO 'customer';
GRANT SELECT ON ThreadLink.Discounts TO 'customer';
GRANT SELECT ON ThreadLink.CustomerDiscounts TO 'customer';

-- place orders --
GRANT INSERT ON ThreadLink.Orders TO 'customer';
GRANT INSERT ON ThreadLink.OrderItems TO 'customer';
GRANT SELECT, INSERT ON ThreadLink.CustomerPlaces TO 'customer';



------ sales associate ------
-- browse website --
GRANT SELECT ON ThreadLink.Items TO 'sales_associate';

-- view other employees --
GRANT SELECT ON ThreadLink.Employees TO 'sales_associate';
GRANT SELECT ON ThreadLink.SalesAssociates TO 'sales_associate';
GRANT SELECT ON ThreadLink.Managers TO 'sales_associate';
GRANT SELECT ON ThreadLink.Hires TO 'sales_associate';

-- view customers --
GRANT SELECT (email, phoneNumber, isSubscribed) ON ThreadLink.Customers TO 'sales_associate';

-- update stock --
GRANT UPDATE (minStock, maxStock) ON ThreadLink.Items TO 'sales_associate';



------ manager ------
-- inherits from sales associates --
GRANT 'sales_associate' TO 'manager';

-- controls item inventory --
GRANT INSERT, UPDATE, DELETE ON ThreadLink.Items TO 'manager';
GRANT INSERT, DELETE ON ThreadLink.UpdatesItem TO 'manager';
GRANT INSERT ON ThreadLink.Orders TO 'manager';
GRANT INSERT ON ThreadLink.OrderItems TO 'manager';
GRANT INSERT ON ThreadLink.EmployeePlaces TO 'manager';

-- employee management --
GRANT INSERT, UPDATE, DELETE ON ThreadLink.Employees TO 'manager';
GRANT INSERT, UPDATE, DELETE ON ThreadLink.SalesAssociates TO 'manager';
GRANT INSERT, DELETE ON ThreadLink.Hires TO 'manager';

-- discount management --
GRANT INSERT, UPDATE, DELETE ON ThreadLink.Discounts TO 'manager';
GRANT INSERT, DELETE ON ThreadLink.UpdatesDiscount TO 'manager';
GRANT INSERT, DELETE ON ThreadLink.CustomerDiscounts TO 'manager';
GRANT INSERT, DELETE ON ThreadLink.EmployeeDiscounts TO 'manager';