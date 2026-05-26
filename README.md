# Attendance & Payroll System Documentation

This document serves as the comprehensive source of truth for the business logic, UI rules, and database calculation structures for the Attendance & Payroll system. It is designed to get any new developer (or AI assistant) immediately up to speed on the project's exact requirements without needing past chat history.

## 1. Core Architecture
- **Frontend/Backend**: ASP.NET WebForms (`.aspx`, `.aspx.cs`) using standard HTML/CSS/JS on the frontend.
- **Database**: MySQL. Interactions happen via `DBHelper.cs` and `MySqlConnector`.
- **Key Files**:
  - `Attendance.aspx` / `Attendance.aspx.cs`: Core UI for marking attendance.
  - `Ledger.aspx` / `Ledger.aspx.cs`: Tracks leave balances (Opening/Closing).
  - `Calculation.aspx` / `Calculation.aspx.cs`: Calculates final present days and wages.

## 2. Core Attendance Logic (Exception-Based)
The system is **exception-based**. This means if a cell is empty (no data entered), the employee is implicitly considered **Present (1)** for that day. 

### Grid Cell Entries:
- **`Empty`**: Assumed `1` (Present).
- **`1`**: Explicitly marked Present.
- **`0`**: Absent. Triggers a dropdown to specify if it is a **Paid** or **Unpaid** leave.
- **`0.5`**: Half-day. They were present for half the day.
- **`H`**: Holiday.

### Leave Types for `0` (Absences):
- **Unpaid Leave**: 
  - Reduces the employee's `Present` count by 1.
  - Does NOT deduct from the Paid Leave Balance in the Ledger.
  - **Can trigger a Saturday Cut** (see below).
- **Paid Leave**:
  - The cell visually turns **green** and displays **`1`** in the UI to indicate they are getting paid for it.
  - It does **not** reduce the `Present` count (since they get paid).
  - It **immediately deducts 1 full day** from their Paid Leave Balance in the Ledger.
  - Does NOT trigger a Saturday Cut.

### Half Days (`0.5`):
- Reduces the employee's `Present` count by `0.5`.
- **Automatically deducts `0.5`** from their Paid Leave Balance in the Ledger (closing row).

## 3. Saturday Cut Logic
If an employee takes an Unpaid leave (or has an invalid absence) during the weekdays (Monday - Friday), they are penalized with a **Saturday Cut**.
- The system automatically forces their Saturday attendance to `0`.
- This means taking an Unpaid leave on Friday effectively costs them 2 days of pay (Friday + Saturday penalty).

## 4. UI Columns (`Attendance.aspx`)
- **Total**: This is a strictly static number representing the **Maximum Working Days** in the month for that specific employee. 
  - It excludes normal Sundays.
  - It includes any Holidays (even if a Holiday is marked on a Sunday, it increases the Total by 1).
  - It respects the employee's `JoinDate` and `ResignDate` (days outside these bounds are excluded).
- **Present**: The actual number of days the employee is getting paid for.
  - Formula visually: Starts at `Total`. Drops by `1` for Unpaid. Drops by `1` for Saturday Cut. Drops by `0.5` for Half Days. Stays the same for Paid leaves.
- **Adj**: Global adjustments added to the final present count.

## 5. Ledger Logic (`Ledger.aspx`)
The Ledger tracks the employee's Leave Balance over time.
- **Opening Balance**: The previous month's closing balance. Calculated dynamically by taking the employee's `OpeningLeaveBalance` (from the `Employees` table) and subtracting **ALL** past `Paid` leaves (1.0) and past `Half` days (0.5) taken in any month prior to the currently viewed month.
- **Current Deductions**: 
  - Paid leaves show up as `-1`, `-2`, etc.
  - Half days show up as `0.5`, `1.0`, etc.
- **Closing Balance**: `Opening Balance` - (Current Paid Leaves + Current Half Days).
- **Unpaid & SatCut Columns**: Tracked for visibility, but do **not** reduce the Closing Balance.

## 6. Wage Calculation (`Calculation.aspx`)
To ensure total accuracy regardless of missing database rows, the backend calculates wages by finding the Total Working Days and subtracting explicit Absences.
1. **Total Working Days**: Calculates all valid Mon-Sat days in the month between the employee's `JoinDate` and `ResignDate`. Adds any Sunday Holidays explicitly marked in the database (`IsHoliday = 1` on `DayOfWeek = 1`).
2. **Absences**: Sums all Unpaid leaves, Saturday Cuts, and Half Days (`* 0.5`).
3. **Present Days**: `Total Working Days` - `Absences`. *(Note: Paid leaves are not subtracted here, ensuring the employee gets paid for them).*
4. **Final Salary**: `Present Days` * `WageRate`.

## 7. Development Guidelines
- Always use standard JavaScript and CSS; avoid unnecessary frameworks.
- Do not assume `0.5` requires two occurrences to trigger a deduction—it must deduct immediately in the Ledger.
- Always handle bounds correctly: Employees should never accrue attendance or be penalized for days before their `JoinDate` or after their `ResignDate`.
