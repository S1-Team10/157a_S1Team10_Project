-- MySQL dump 10.13  Distrib 9.6.0, for macos15 (arm64)
--
-- Host: localhost    Database: ThreadLink
-- ------------------------------------------------------
-- Server version	9.6.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'b2f0de9a-038d-11f1-bb74-5702030b2dc3:1-41';

--
-- Table structure for table `CustomerDiscounts`
--

DROP TABLE IF EXISTS `CustomerDiscounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CustomerDiscounts` (
  `customerEmail` varchar(100) NOT NULL,
  `customerDiscountCode` varchar(20) NOT NULL,
  PRIMARY KEY (`customerEmail`,`customerDiscountCode`),
  KEY `customerDiscountCode` (`customerDiscountCode`),
  CONSTRAINT `customerdiscounts_ibfk_1` FOREIGN KEY (`customerEmail`) REFERENCES `Customers` (`email`),
  CONSTRAINT `customerdiscounts_ibfk_2` FOREIGN KEY (`customerDiscountCode`) REFERENCES `Discounts` (`discountCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CustomerDiscounts`
--

LOCK TABLES `CustomerDiscounts` WRITE;
/*!40000 ALTER TABLE `CustomerDiscounts` DISABLE KEYS */;
INSERT INTO `CustomerDiscounts` VALUES ('carol.white@hotmail.com','BDAY5'),('karen.thomas@hotmail.com','FLASH50'),('bob.smith@yahoo.com','NEWCUST15'),('david.lee@gmail.com','NEWCUST15'),('emma.davis@outlook.com','NEWCUST15'),('henry.moore@gmail.com','REFER10'),('alice.johnson@gmail.com','REWARDS10'),('carol.white@hotmail.com','REWARDS10'),('david.lee@gmail.com','REWARDS10'),('frank.miller@gmail.com','REWARDS10'),('henry.moore@gmail.com','REWARDS10'),('james.anderson@gmail.com','REWARDS10'),('karen.thomas@hotmail.com','REWARDS10'),('alice.johnson@gmail.com','SUMMER25'),('frank.miller@gmail.com','VIP40');
/*!40000 ALTER TABLE `CustomerDiscounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CustomerPlaces`
--

DROP TABLE IF EXISTS `CustomerPlaces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CustomerPlaces` (
  `customerEmail` varchar(100) NOT NULL,
  `customerOrderID` int NOT NULL,
  `totalAmount` decimal(10,2) NOT NULL,
  `orderDate` date NOT NULL,
  PRIMARY KEY (`customerEmail`,`customerOrderID`),
  KEY `customerOrderID` (`customerOrderID`),
  CONSTRAINT `customerplaces_ibfk_1` FOREIGN KEY (`customerEmail`) REFERENCES `Customers` (`email`),
  CONSTRAINT `customerplaces_ibfk_2` FOREIGN KEY (`customerOrderID`) REFERENCES `Orders` (`orderID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CustomerPlaces`
--

LOCK TABLES `CustomerPlaces` WRITE;
/*!40000 ALTER TABLE `CustomerPlaces` DISABLE KEYS */;
INSERT INTO `CustomerPlaces` VALUES ('alice.johnson@gmail.com',1,62.98,'2026-02-01'),('bob.smith@yahoo.com',2,49.99,'2026-02-03'),('carol.white@hotmail.com',3,39.99,'2026-02-05'),('david.lee@gmail.com',4,129.99,'2026-02-07'),('emma.davis@outlook.com',5,54.98,'2026-02-10'),('frank.miller@gmail.com',6,84.98,'2026-02-12'),('grace.wilson@icloud.com',7,18.99,'2026-02-15'),('henry.moore@gmail.com',8,94.97,'2026-02-18'),('isabella.taylor@yahoo.com',9,29.99,'2026-02-20'),('james.anderson@gmail.com',10,47.98,'2026-02-22'),('karen.thomas@hotmail.com',11,65.98,'2026-02-25'),('liam.jackson@outlook.com',12,36.99,'2026-02-27');
/*!40000 ALTER TABLE `CustomerPlaces` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Customers`
--

DROP TABLE IF EXISTS `Customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Customers` (
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phoneNumber` varchar(15) DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `isSubscribed` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Customers`
--

LOCK TABLES `Customers` WRITE;
/*!40000 ALTER TABLE `Customers` DISABLE KEYS */;
INSERT INTO `Customers` VALUES ('alice.johnson@gmail.com','hashed_pw_001','4081234567','1995-03-12',1),('bob.smith@yahoo.com','hashed_pw_002','4082345678','1990-07-24',0),('carol.white@hotmail.com','hashed_pw_003','4083456789','1988-11-05',1),('david.lee@gmail.com','hashed_pw_004','4084567890','2000-01-30',1),('emma.davis@outlook.com','hashed_pw_005',NULL,'1997-06-15',0),('frank.miller@gmail.com','hashed_pw_006','4086789012','1985-09-22',1),('grace.wilson@icloud.com','hashed_pw_007','4087890123',NULL,0),('henry.moore@gmail.com','hashed_pw_008','4088901234','1993-04-18',1),('isabella.taylor@yahoo.com','hashed_pw_009','4089012345','2001-12-03',0),('james.anderson@gmail.com','hashed_pw_010','4080123456','1996-08-27',1),('karen.thomas@hotmail.com','hashed_pw_011','4081357924','1989-02-14',1),('liam.jackson@outlook.com','hashed_pw_012',NULL,'1998-05-09',0);
/*!40000 ALTER TABLE `Customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Discounts`
--

DROP TABLE IF EXISTS `Discounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Discounts` (
  `discountCode` varchar(20) NOT NULL,
  `discountName` varchar(100) NOT NULL,
  `percentOff` decimal(5,2) NOT NULL,
  `startDate` date NOT NULL,
  `endDate` date NOT NULL,
  PRIMARY KEY (`discountCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Discounts`
--

LOCK TABLES `Discounts` WRITE;
/*!40000 ALTER TABLE `Discounts` DISABLE KEYS */;
INSERT INTO `Discounts` VALUES ('BACK2SCHOOL','Back to School 18% Off',18.00,'2026-08-01','2026-09-15'),('BDAY5','Birthday Month 5% Off',5.00,'2026-01-01','2026-12-31'),('CLEARANCE30','End of Season Clearance 30%',30.00,'2026-04-01','2026-04-30'),('FLASH50','Flash Sale 50% Off',50.00,'2026-03-15','2026-03-16'),('HOLIDAY20','Holiday Season 20% Off',20.00,'2025-12-01','2025-12-31'),('NEWCUST15','New Customer 15% Off',15.00,'2026-01-01','2026-06-30'),('REFER10','Referral Program 10% Off',10.00,'2026-01-01','2026-12-31'),('REWARDS10','Rewards Member 10% Off',10.00,'2026-01-01','2026-12-31'),('STAFF20','Employee Staff Discount 20%',20.00,'2026-01-01','2026-12-31'),('SUMMER25','Summer Sale 25% Off',25.00,'2026-06-01','2026-08-31'),('VIP40','VIP Member 40% Off',40.00,'2026-05-01','2026-05-31');
/*!40000 ALTER TABLE `Discounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `EmployeeDiscounts`
--

DROP TABLE IF EXISTS `EmployeeDiscounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `EmployeeDiscounts` (
  `employeeID` varchar(10) NOT NULL,
  `employeeDiscountCode` varchar(20) NOT NULL,
  PRIMARY KEY (`employeeID`,`employeeDiscountCode`),
  KEY `employeeDiscountCode` (`employeeDiscountCode`),
  CONSTRAINT `employeediscounts_ibfk_1` FOREIGN KEY (`employeeID`) REFERENCES `Employees` (`employeeID`),
  CONSTRAINT `employeediscounts_ibfk_2` FOREIGN KEY (`employeeDiscountCode`) REFERENCES `Discounts` (`discountCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `EmployeeDiscounts`
--

LOCK TABLES `EmployeeDiscounts` WRITE;
/*!40000 ALTER TABLE `EmployeeDiscounts` DISABLE KEYS */;
INSERT INTO `EmployeeDiscounts` VALUES ('E001','STAFF20'),('E002','STAFF20'),('E003','STAFF20'),('E004','STAFF20'),('E005','STAFF20'),('E006','STAFF20'),('E007','STAFF20'),('E008','STAFF20'),('E009','STAFF20'),('E010','STAFF20'),('E011','STAFF20'),('E012','STAFF20');
/*!40000 ALTER TABLE `EmployeeDiscounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `EmployeePlaces`
--

DROP TABLE IF EXISTS `EmployeePlaces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `EmployeePlaces` (
  `employeeID` varchar(10) NOT NULL,
  `employeeOrderID` int NOT NULL,
  `totalAmount` decimal(10,2) NOT NULL,
  `orderDate` date NOT NULL,
  PRIMARY KEY (`employeeID`,`employeeOrderID`),
  KEY `employeeOrderID` (`employeeOrderID`),
  CONSTRAINT `employeeplaces_ibfk_1` FOREIGN KEY (`employeeID`) REFERENCES `Employees` (`employeeID`),
  CONSTRAINT `employeeplaces_ibfk_2` FOREIGN KEY (`employeeOrderID`) REFERENCES `Orders` (`orderID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `EmployeePlaces`
--

LOCK TABLES `EmployeePlaces` WRITE;
/*!40000 ALTER TABLE `EmployeePlaces` DISABLE KEYS */;
INSERT INTO `EmployeePlaces` VALUES ('E001',13,259.98,'2026-01-05'),('E002',14,399.96,'2026-01-10'),('E003',15,519.95,'2026-01-15'),('E004',16,189.97,'2026-01-18'),('E005',17,312.95,'2026-01-20'),('E006',18,145.98,'2026-01-22'),('E007',19,224.97,'2026-01-25'),('E008',20,178.96,'2026-01-27'),('E009',21,299.95,'2026-01-29'),('E010',22,164.97,'2026-02-01');
/*!40000 ALTER TABLE `EmployeePlaces` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Employees`
--

DROP TABLE IF EXISTS `Employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Employees` (
  `employeeID` varchar(10) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phoneNumber` varchar(15) NOT NULL,
  PRIMARY KEY (`employeeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Employees`
--

LOCK TABLES `Employees` WRITE;
/*!40000 ALTER TABLE `Employees` DISABLE KEYS */;
INSERT INTO `Employees` VALUES ('E001','Sandra Cruz','sandra.cruz@threadlink.com','4081111001'),('E002','Michael Torres','michael.torres@threadlink.com','4081111002'),('E003','Rachel Green','rachel.green@threadlink.com','4081111003'),('E004','Omar Patel','omar.patel@threadlink.com','4081111004'),('E005','Nina Reyes','nina.reyes@threadlink.com','4081111005'),('E006','Kevin Park','kevin.park@threadlink.com','4081111006'),('E007','Laura Kim','laura.kim@threadlink.com','4081111007'),('E008','Derek Nguyen','derek.nguyen@threadlink.com','4081111008'),('E009','Tiffany Brown','tiffany.brown@threadlink.com','4081111009'),('E010','Carlos Mendoza','carlos.mendoza@threadlink.com','4081111010'),('E011','Priya Singh','priya.singh@threadlink.com','4081111011'),('E012','Jason Hall','jason.hall@threadlink.com','4081111012');
/*!40000 ALTER TABLE `Employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Hires`
--

DROP TABLE IF EXISTS `Hires`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Hires` (
  `salesAssociateID` varchar(10) NOT NULL,
  `managerID` varchar(10) NOT NULL,
  PRIMARY KEY (`salesAssociateID`,`managerID`),
  KEY `managerID` (`managerID`),
  CONSTRAINT `hires_ibfk_1` FOREIGN KEY (`salesAssociateID`) REFERENCES `SalesAssociates` (`salesAssociateID`),
  CONSTRAINT `hires_ibfk_2` FOREIGN KEY (`managerID`) REFERENCES `Managers` (`managerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Hires`
--

LOCK TABLES `Hires` WRITE;
/*!40000 ALTER TABLE `Hires` DISABLE KEYS */;
INSERT INTO `Hires` VALUES ('E005','E001'),('E006','E001'),('E007','E002'),('E008','E002'),('E009','E003'),('E010','E003'),('E011','E004'),('E012','E004');
/*!40000 ALTER TABLE `Hires` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Items`
--

DROP TABLE IF EXISTS `Items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Items` (
  `itemID` int NOT NULL AUTO_INCREMENT,
  `itemName` varchar(100) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `minStock` int NOT NULL,
  `maxStock` int NOT NULL,
  PRIMARY KEY (`itemID`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Items`
--

LOCK TABLES `Items` WRITE;
/*!40000 ALTER TABLE `Items` DISABLE KEYS */;
INSERT INTO `Items` VALUES (1,'Classic White Tee','Unisex 100% cotton short-sleeve t-shirt in white',12.99,20,200),(2,'Slim Fit Jeans','Dark-wash slim-fit denim jeans, sizes 28-40',49.99,15,150),(3,'Floral Summer Dress','Light chiffon floral print midi dress',39.99,10,100),(4,'Hooded Zip-Up Sweatshirt','Soft fleece zip-up hoodie with front pocket',34.99,20,180),(5,'Cargo Shorts','6-pocket cargo shorts in khaki and olive',27.99,15,120),(6,'Wool Blend Coat','Tailored wool-blend overcoat, available in black and gray',129.99,5,60),(7,'Striped Polo Shirt','Classic fit polo shirt with two-button placket',24.99,20,160),(8,'Yoga Leggings','High-waist 4-way stretch leggings for workouts',29.99,25,200),(9,'Denim Jacket','Classic denim trucker jacket with button closure',59.99,10,100),(10,'Graphic Print Tee','Unisex oversized tee with seasonal graphic print',18.99,20,180),(11,'Linen Button-Down Shirt','Breathable linen shirt, relaxed fit',36.99,10,120),(12,'Athletic Track Pants','Tapered jogger pants with side stripe',32.99,15,140);
/*!40000 ALTER TABLE `Items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Managers`
--

DROP TABLE IF EXISTS `Managers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Managers` (
  `managerID` varchar(10) NOT NULL,
  PRIMARY KEY (`managerID`),
  CONSTRAINT `managers_ibfk_1` FOREIGN KEY (`managerID`) REFERENCES `Employees` (`employeeID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Managers`
--

LOCK TABLES `Managers` WRITE;
/*!40000 ALTER TABLE `Managers` DISABLE KEYS */;
INSERT INTO `Managers` VALUES ('E001'),('E002'),('E003'),('E004');
/*!40000 ALTER TABLE `Managers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `OrderItems`
--

DROP TABLE IF EXISTS `OrderItems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `OrderItems` (
  `orderID` int NOT NULL,
  `itemID` int NOT NULL,
  PRIMARY KEY (`orderID`,`itemID`),
  KEY `itemID` (`itemID`),
  CONSTRAINT `orderitems_ibfk_1` FOREIGN KEY (`orderID`) REFERENCES `Orders` (`orderID`),
  CONSTRAINT `orderitems_ibfk_2` FOREIGN KEY (`itemID`) REFERENCES `Items` (`itemID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `OrderItems`
--

LOCK TABLES `OrderItems` WRITE;
/*!40000 ALTER TABLE `OrderItems` DISABLE KEYS */;
INSERT INTO `OrderItems` VALUES (1,1),(8,1),(10,1),(15,1),(2,2),(13,2),(15,2),(3,3),(1,4),(11,4),(15,4),(8,5),(10,5),(4,6),(13,6),(14,6),(5,7),(5,8),(8,8),(9,8),(15,8),(6,9),(11,9),(14,9),(6,10),(7,10),(12,11),(14,12);
/*!40000 ALTER TABLE `OrderItems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Orders`
--

DROP TABLE IF EXISTS `Orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Orders` (
  `orderID` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`orderID`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Orders`
--

LOCK TABLES `Orders` WRITE;
/*!40000 ALTER TABLE `Orders` DISABLE KEYS */;
INSERT INTO `Orders` VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),(21),(22);
/*!40000 ALTER TABLE `Orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SalesAssociates`
--

DROP TABLE IF EXISTS `SalesAssociates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `SalesAssociates` (
  `salesAssociateID` varchar(10) NOT NULL,
  PRIMARY KEY (`salesAssociateID`),
  CONSTRAINT `salesassociates_ibfk_1` FOREIGN KEY (`salesAssociateID`) REFERENCES `Employees` (`employeeID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SalesAssociates`
--

LOCK TABLES `SalesAssociates` WRITE;
/*!40000 ALTER TABLE `SalesAssociates` DISABLE KEYS */;
INSERT INTO `SalesAssociates` VALUES ('E005'),('E006'),('E007'),('E008'),('E009'),('E010'),('E011'),('E012');
/*!40000 ALTER TABLE `SalesAssociates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `UpdatesDiscount`
--

DROP TABLE IF EXISTS `UpdatesDiscount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `UpdatesDiscount` (
  `managerID` varchar(10) NOT NULL,
  `discountCode` varchar(20) NOT NULL,
  PRIMARY KEY (`managerID`,`discountCode`),
  KEY `discountCode` (`discountCode`),
  CONSTRAINT `updatesdiscount_ibfk_1` FOREIGN KEY (`managerID`) REFERENCES `Managers` (`managerID`),
  CONSTRAINT `updatesdiscount_ibfk_2` FOREIGN KEY (`discountCode`) REFERENCES `Discounts` (`discountCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UpdatesDiscount`
--

LOCK TABLES `UpdatesDiscount` WRITE;
/*!40000 ALTER TABLE `UpdatesDiscount` DISABLE KEYS */;
INSERT INTO `UpdatesDiscount` VALUES ('E004','BACK2SCHOOL'),('E002','BDAY5'),('E003','CLEARANCE30'),('E002','FLASH50'),('E002','HOLIDAY20'),('E001','NEWCUST15'),('E004','REFER10'),('E001','REWARDS10'),('E003','STAFF20'),('E001','SUMMER25'),('E003','VIP40');
/*!40000 ALTER TABLE `UpdatesDiscount` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `UpdatesItem`
--

DROP TABLE IF EXISTS `UpdatesItem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `UpdatesItem` (
  `managerID` varchar(10) NOT NULL,
  `itemID` int NOT NULL,
  PRIMARY KEY (`managerID`,`itemID`),
  KEY `itemID` (`itemID`),
  CONSTRAINT `updatesitem_ibfk_1` FOREIGN KEY (`managerID`) REFERENCES `Managers` (`managerID`),
  CONSTRAINT `updatesitem_ibfk_2` FOREIGN KEY (`itemID`) REFERENCES `Items` (`itemID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UpdatesItem`
--

LOCK TABLES `UpdatesItem` WRITE;
/*!40000 ALTER TABLE `UpdatesItem` DISABLE KEYS */;
INSERT INTO `UpdatesItem` VALUES ('E001',1),('E001',2),('E001',3),('E002',4),('E002',5),('E002',6),('E003',7),('E003',8),('E003',9),('E004',10),('E004',11),('E004',12);
/*!40000 ALTER TABLE `UpdatesItem` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-25 18:40:20
