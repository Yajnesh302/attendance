using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using AttendanceApp.Utils;
using MySqlConnector;

namespace AttendanceApp
{
    public partial class Attendance : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("Login.aspx");
            }
        }

        [WebMethod]
        public static string GetData(int year, int month, string category, string search)
        {
            // Note: Use session to filter by division if user is not admin
            int role = Convert.ToInt32(HttpContext.Current.Session["Role"] ?? 0);
            string division = HttpContext.Current.Session["Division"]?.ToString() ?? "";

            string empQuery = @"SELECT ID, Name, Department, Category, JoinDate, ResignDate 
                                FROM Employees 
                                WHERE Category = @Cat 
                                AND (Status = 'Active' OR (Status = 'Resigned' AND (YEAR(ResignDate) > @Year OR (YEAR(ResignDate) = @Year AND MONTH(ResignDate) >= @Month))))";
            
            if (role != 1)
            {
                // Simple starts-with filter for division based on requirements
                empQuery += " AND Department LIKE @Div";
            }
            if (!string.IsNullOrEmpty(search))
            {
                empQuery += " AND (ID LIKE @Search OR Name LIKE @Search)";
            }

            DataTable dtEmp = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), empQuery, 
                new MySqlParameter("@Cat", category),
                new MySqlParameter("@Div", division + "%"),
                new MySqlParameter("@Search", "%" + search + "%"),
                new MySqlParameter("@Year", year),
                new MySqlParameter("@Month", month + 1)); // JS month is 0-indexed, so month + 1

            List<object> emps = new List<object>();
            foreach(DataRow dr in dtEmp.Rows)
            {
                emps.Add(new { 
                    ID = dr["ID"].ToString(), 
                    Name = dr["Name"].ToString(), 
                    Dept = dr["Department"].ToString(),
                    JoinDate = dr["JoinDate"] != DBNull.Value ? Convert.ToDateTime(dr["JoinDate"]).ToString("yyyy-MM-dd") : null,
                    ResignDate = dr["ResignDate"] != DBNull.Value ? Convert.ToDateTime(dr["ResignDate"]).ToString("yyyy-MM-dd") : null
                });
            }

            string attQuery = "SELECT EmpID, Day, StatusValue, IsHoliday, LeaveType, AutoSat FROM Attendance WHERE Year = @Year AND Month = @Month";
            DataTable dtAtt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), attQuery,
                new MySqlParameter("@Year", year),
                new MySqlParameter("@Month", month));

            // Structure: { EmpID: { Day: { Val, Holiday, Leave } } }
            Dictionary<string, Dictionary<string, object>> attDict = new Dictionary<string, Dictionary<string, object>>();
            foreach(DataRow dr in dtAtt.Rows)
            {
                string empId = dr["EmpID"].ToString();
                int day = Convert.ToInt32(dr["Day"]);
                float? val = dr["StatusValue"] == DBNull.Value ? (float?)null : Convert.ToSingle(dr["StatusValue"]);
                bool isHoliday = Convert.ToBoolean(dr["IsHoliday"]);
                bool autoSat = dr.Table.Columns.Contains("AutoSat") && dr["AutoSat"] != DBNull.Value ? Convert.ToBoolean(dr["AutoSat"]) : false;
                string leave = dr["LeaveType"].ToString();

                if (!attDict.ContainsKey(empId))
                    attDict[empId] = new Dictionary<string, object>();

                attDict[empId][day.ToString()] = new { Val = val, Holiday = isHoliday, Leave = leave, AutoSat = autoSat };
            }

            // Fetch previous month trailing data for calcSat
            int prevMonth = month == 0 ? 11 : month - 1;
            int prevYear = month == 0 ? year - 1 : year;
            
            string prevAttQuery = "SELECT EmpID, Day, StatusValue, IsHoliday, LeaveType, AutoSat FROM Attendance WHERE Year = @PYear AND Month = @PMonth AND Day >= 24";
            DataTable dtPrevAtt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), prevAttQuery,
                new MySqlParameter("@PYear", prevYear),
                new MySqlParameter("@PMonth", prevMonth));

            Dictionary<string, Dictionary<string, object>> prevAttDict = new Dictionary<string, Dictionary<string, object>>();
            foreach(DataRow dr in dtPrevAtt.Rows)
            {
                string empId = dr["EmpID"].ToString();
                int day = Convert.ToInt32(dr["Day"]);
                float? val = dr["StatusValue"] == DBNull.Value ? (float?)null : Convert.ToSingle(dr["StatusValue"]);
                bool isHoliday = Convert.ToBoolean(dr["IsHoliday"]);
                bool autoSat = dr.Table.Columns.Contains("AutoSat") && dr["AutoSat"] != DBNull.Value ? Convert.ToBoolean(dr["AutoSat"]) : false;
                string leave = dr["LeaveType"].ToString();

                if (!prevAttDict.ContainsKey(empId))
                    prevAttDict[empId] = new Dictionary<string, object>();

                prevAttDict[empId][day.ToString()] = new { Val = val, Holiday = isHoliday, Leave = leave, AutoSat = autoSat };
            }

            var result = new { Employees = emps, Attendance = attDict, PrevAttendance = prevAttDict };
            return new JavaScriptSerializer().Serialize(result);
        }

        [WebMethod]
        public static string SaveData(int year, int month, string category, string data)
        {
            var dict = new JavaScriptSerializer().Deserialize<Dictionary<string, Dictionary<string, Dictionary<string, object>>>>(data);

            foreach (var empKvp in dict)
            {
                string empId = empKvp.Key;
                foreach (var dayKvp in empKvp.Value)
                {
                    int day = Convert.ToInt32(dayKvp.Key);
                    var cell = dayKvp.Value;
                    
                    object val = cell.ContainsKey("Val") && cell["Val"] != null ? cell["Val"] : DBNull.Value;
                    bool isHoliday = cell.ContainsKey("Holiday") && cell["Holiday"] != null ? Convert.ToBoolean(cell["Holiday"]) : false;
                    string leave = cell.ContainsKey("Leave") && cell["Leave"] != null ? cell["Leave"].ToString() : "";
                    bool autoSat = cell.ContainsKey("AutoSat") && cell["AutoSat"] != null ? Convert.ToBoolean(cell["AutoSat"]) : false;

                    string query = @"INSERT INTO Attendance (EmpID, Year, Month, Day, StatusValue, IsHoliday, LeaveType, AutoSat) 
                                     VALUES (@EmpID, @Year, @Month, @Day, @Val, @Holiday, @Leave, @AutoSat)
                                     ON DUPLICATE KEY UPDATE StatusValue=@Val, IsHoliday=@Holiday, LeaveType=@Leave, AutoSat=@AutoSat";
                                     
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), query,
                        new MySqlParameter("@EmpID", empId),
                        new MySqlParameter("@Year", year),
                        new MySqlParameter("@Month", month),
                        new MySqlParameter("@Day", day),
                        new MySqlParameter("@Val", val),
                        new MySqlParameter("@Holiday", isHoliday),
                        new MySqlParameter("@Leave", leave),
                        new MySqlParameter("@AutoSat", autoSat));
                }
            }

            return "{\"status\":\"success\"}";
        }
    }
}
