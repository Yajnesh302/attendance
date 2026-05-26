-- Database 1: hrdata (Simulates Company DB)
CREATE DATABASE IF NOT EXISTS hrdata;
USE hrdata;

CREATE TABLE IF NOT EXISTS empdetails (
    PCNO VARCHAR(50) PRIMARY KEY,
    NAME VARCHAR(100),
    DESIGNATION VARCHAR(100),
    DIVNAME VARCHAR(100)
);

-- Insert dummy data for testing (user can modify this later)
INSERT IGNORE INTO empdetails (PCNO, NAME, DESIGNATION, DIVNAME) VALUES 
('1001', 'Admin User', 'Manager', 'DKRM/ITISG'),
('1002', 'Test User', 'Engineer', 'D-ADMIN/STORE'),
('1003', 'John Doe', 'Technician', 'DKRM/MAINT');

-- Database 2: AttendanceDB
CREATE DATABASE IF NOT EXISTS AttendanceDB;
USE AttendanceDB;

CREATE TABLE IF NOT EXISTS AppUsers (
    PCNO VARCHAR(50) PRIMARY KEY,
    Name VARCHAR(100),
    Role INT DEFAULT 0
);

INSERT IGNORE INTO AppUsers (PCNO, Name, Role) VALUES 
('1001', 'Admin User', 1), -- Admin
('1002', 'Test User', 0), -- User
('1003', 'John Doe', 0);

CREATE TABLE IF NOT EXISTS Employees (
    ID VARCHAR(50) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Department VARCHAR(100),
    Category VARCHAR(50),
    JoinDate DATE,
    LeaveBalance FLOAT DEFAULT 0,
    Status VARCHAR(20) DEFAULT 'Active',
    ResignDate DATE
);

CREATE TABLE IF NOT EXISTS Attendance (
    EmpID VARCHAR(50),
    Year INT,
    Month INT,
    Day INT,
    StatusValue FLOAT,
    LeaveType VARCHAR(50),
    IsHoliday BOOLEAN DEFAULT FALSE,
    AutoSat BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (EmpID, Year, Month, Day)
);

CREATE TABLE IF NOT EXISTS CalculationWages (
    Year INT,
    Month INT,
    Category VARCHAR(50),
    WageRate FLOAT,
    PRIMARY KEY (Year, Month, Category)
);

CREATE TABLE IF NOT EXISTS CalculationOverrides (
    Year INT,
    Month INT,
    Category VARCHAR(50),
    EmpID VARCHAR(50),
    FinalDays FLOAT,
    PRIMARY KEY (Year, Month, Category, EmpID)
);
