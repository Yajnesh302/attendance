using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI.WebControls;
using AttendanceApp.Utils;
using MySqlConnector;

namespace AttendanceApp
{
    public partial class Ledger : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                int currentYear = DateTime.Now.Year;
                for (int i = currentYear - 2; i <= currentYear + 2; i++)
                {
                    ddlYear.Items.Add(new ListItem(i.ToString(), i.ToString()));
                }
                ddlYear.SelectedValue = currentYear.ToString();
                ddlMonth.SelectedValue = DateTime.Now.Month.ToString();
                
                BindGrid();
            }
        }

        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            BindGrid();
        }

        private void BindGrid()
        {
            int tY = int.Parse(ddlYear.SelectedValue);
            int tM = int.Parse(ddlMonth.SelectedValue) - 1; // Convert 1-12 to 0-11 to match 0-indexed database Month
            string cat = ddlCategory.SelectedValue;
            string search = txtSearch.Text.Trim();

            // 1. Fetch Employees
            string empQuery = "SELECT ID, Name, Department, Category, JoinDate, ResignDate, LeaveBalance FROM Employees WHERE 1=1";
            List<MySqlParameter> empParams = new List<MySqlParameter>();
            
            if (cat != "All")
            {
                empQuery += " AND Category = @Cat";
                empParams.Add(new MySqlParameter("@Cat", cat));
            }
            if (!string.IsNullOrEmpty(search))
            {
                empQuery += " AND (ID LIKE @Search OR Name LIKE @Search)";
                empParams.Add(new MySqlParameter("@Search", "%" + search + "%"));
            }
            empQuery += " ORDER BY Department ASC, Name ASC";

            DataTable dtEmp = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), empQuery, empParams.ToArray());

            // 2. Output Table
            DataTable resultDt = new DataTable();
            resultDt.Columns.Add("ID", typeof(string));
            resultDt.Columns.Add("Name", typeof(string));
            resultDt.Columns.Add("Department", typeof(string));
            resultDt.Columns.Add("Category", typeof(string));
            resultDt.Columns.Add("Opening", typeof(double));
            resultDt.Columns.Add("Paid", typeof(int));
            resultDt.Columns.Add("Half", typeof(double));
            resultDt.Columns.Add("Unpaid", typeof(int));
            resultDt.Columns.Add("SatCut", typeof(int));
            resultDt.Columns.Add("Closing", typeof(double));

            foreach (DataRow row in dtEmp.Rows)
            {
                string empId = row["ID"].ToString();
                DateTime? joinDate = row["JoinDate"] != DBNull.Value ? Convert.ToDateTime(row["JoinDate"]) : (DateTime?)null;
                DateTime? resignDate = row["ResignDate"] != DBNull.Value ? Convert.ToDateTime(row["ResignDate"]) : (DateTime?)null;
                double initialBalance = row["LeaveBalance"] != DBNull.Value ? Convert.ToDouble(row["LeaveBalance"]) : 0;

                // Check Bounds
                if (joinDate.HasValue)
                {
                    if (tY < joinDate.Value.Year || (tY == joinDate.Value.Year && tM < (joinDate.Value.Month - 1)))
                    {
                        continue; // Skip, they haven't joined yet
                    }
                }
                
                if (resignDate.HasValue)
                {
                    if (tY > resignDate.Value.Year || (tY == resignDate.Value.Year && tM > (resignDate.Value.Month - 1)))
                    {
                        continue; // Skip, they have already left before this month
                    }
                }

                // Get Historical Totals (Prior to Target Month)
                string histQuery = @"
                    SELECT 
                        SUM(CASE WHEN StatusValue = 0 AND LeaveType = 'Paid' THEN 1 ELSE 0 END) as PrevFull,
                        SUM(CASE WHEN StatusValue = 0.5 THEN 1 ELSE 0 END) as PrevHalf
                    FROM Attendance 
                    WHERE EmpID = @EmpID AND ((Year < @TY) OR (Year = @TY AND Month < @TM)) AND EmpID != 'GLOBAL'";
                
                DataTable dtHist = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), histQuery, 
                    new MySqlParameter("@EmpID", empId), 
                    new MySqlParameter("@TY", tY), 
                    new MySqlParameter("@TM", tM));

                int prevFull = 0;
                int prevHalf = 0;
                if (dtHist.Rows.Count > 0)
                {
                    prevFull = dtHist.Rows[0]["PrevFull"] != DBNull.Value ? Convert.ToInt32(dtHist.Rows[0]["PrevFull"]) : 0;
                    prevHalf = dtHist.Rows[0]["PrevHalf"] != DBNull.Value ? Convert.ToInt32(dtHist.Rows[0]["PrevHalf"]) : 0;
                }

                double openingBalance = initialBalance - prevFull - (prevHalf * 0.5);

                // Get Current Month Totals
                string currQuery = @"
                    SELECT 
                        SUM(CASE WHEN StatusValue = 0 AND LeaveType = 'Paid' THEN 1 ELSE 0 END) as CurrFull,
                        SUM(CASE WHEN StatusValue = 0.5 THEN 1 ELSE 0 END) as CurrHalf,
                        SUM(CASE WHEN StatusValue = 0 AND (LeaveType = 'Unpaid' OR LeaveType = '' OR LeaveType IS NULL) AND DAYOFWEEK(STR_TO_DATE(CONCAT(Year, '-', Month + 1, '-', Day), '%Y-%c-%e')) != 7 THEN 1 ELSE 0 END) as CurrUnpaid,
                        SUM(CASE WHEN StatusValue = 0 AND DAYOFWEEK(STR_TO_DATE(CONCAT(Year, '-', Month + 1, '-', Day), '%Y-%c-%e')) = 7 THEN 1 ELSE 0 END) as CurrSat
                    FROM Attendance 
                    WHERE EmpID = @EmpID AND Year = @TY AND Month = @TM AND EmpID != 'GLOBAL'";

                DataTable dtCurr = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), currQuery,
                    new MySqlParameter("@EmpID", empId),
                    new MySqlParameter("@TY", tY),
                    new MySqlParameter("@TM", tM));

                int currFull = 0;
                int currHalf = 0;
                int currUnpaid = 0;
                int currSat = 0;

                if (dtCurr.Rows.Count > 0)
                {
                    currFull = dtCurr.Rows[0]["CurrFull"] != DBNull.Value ? Convert.ToInt32(dtCurr.Rows[0]["CurrFull"]) : 0;
                    currHalf = dtCurr.Rows[0]["CurrHalf"] != DBNull.Value ? Convert.ToInt32(dtCurr.Rows[0]["CurrHalf"]) : 0;
                    currUnpaid = dtCurr.Rows[0]["CurrUnpaid"] != DBNull.Value ? Convert.ToInt32(dtCurr.Rows[0]["CurrUnpaid"]) : 0;
                    currSat = dtCurr.Rows[0]["CurrSat"] != DBNull.Value ? Convert.ToInt32(dtCurr.Rows[0]["CurrSat"]) : 0;
                }

                double totalDeductionThisMonth = currFull + (currHalf * 0.5);
                double closingBalance = openingBalance - totalDeductionThisMonth;

                // Populate Row
                DataRow dr = resultDt.NewRow();
                dr["ID"] = empId;
                dr["Name"] = row["Name"];
                dr["Department"] = row["Department"];
                dr["Category"] = row["Category"];
                dr["Opening"] = openingBalance;
                dr["Paid"] = currFull > 0 ? "-" + currFull : "0";
                dr["Half"] = currHalf * 0.5;
                dr["Unpaid"] = currUnpaid;
                dr["SatCut"] = currSat;
                dr["Closing"] = closingBalance;
                resultDt.Rows.Add(dr);
            }

            gvLedger.DataSource = resultDt;
            gvLedger.DataBind();
        }
    }
}
