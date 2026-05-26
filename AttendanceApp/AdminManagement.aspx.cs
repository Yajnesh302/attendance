using System;
using System.Data;
using MySqlConnector;
using AttendanceApp.Utils;

namespace AttendanceApp
{
    public partial class AdminManagement : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            int role = Convert.ToInt32(Session["Role"] ?? 0);
            if (role != 1)
            {
                Response.Redirect("Dashboard.aspx");
                return;
            }

            // Ensure the Name column exists in AppUsers table
            EnsureNameColumnExists();

            if (!IsPostBack)
            {
                BindAdminGrid();
            }
        }

        protected void btnAddAdmin_Click(object sender, EventArgs e)
        {
            string pcno = txtAdminPCNO.Text.Trim();
            string name = txtAdminName.Text.Trim();

            if (string.IsNullOrEmpty(pcno) || string.IsNullOrEmpty(name))
            {
                ShowAdminMessage("PCNO and Name are required.", false);
                return;
            }

            try
            {
                // 1. Insert/Update in CompanyDB (hrdata.empdetails) so details are available on AD login
                string queryEmp = @"
                    INSERT INTO empdetails (PCNO, NAME, DESIGNATION, DIVNAME) 
                    VALUES (@PCNO, @Name, 'Administrator', 'AD-Admin')
                    ON DUPLICATE KEY UPDATE NAME=@Name";
                
                MySqlParameter[] paramsEmp = new MySqlParameter[] {
                    new MySqlParameter("@PCNO", pcno),
                    new MySqlParameter("@Name", name)
                };
                DBHelper.ExecuteNonQuery(DBHelper.GetCompanyDBConnection(), queryEmp, paramsEmp);

                // 2. Insert/Update in AttendanceDB (AppUsers)
                string queryUser = @"
                    INSERT INTO AppUsers (PCNO, Name, Role) 
                    VALUES (@PCNO, @Name, 1)
                    ON DUPLICATE KEY UPDATE Name = @Name, Role = 1";
                
                MySqlParameter[] paramsUser = new MySqlParameter[] {
                    new MySqlParameter("@PCNO", pcno),
                    new MySqlParameter("@Name", name)
                };
                DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), queryUser, paramsUser);

                ShowAdminMessage($"Admin user '{name}' (PCNO: {pcno}) has been successfully created/updated.", true);
                
                // Clear fields
                txtAdminPCNO.Text = "";
                txtAdminName.Text = "";

                // Rebind the admin grid
                BindAdminGrid();
            }
            catch (Exception ex)
            {
                ShowAdminMessage("Error: " + ex.Message, false);
            }
        }

        protected void gvAdminUsers_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName == "RevokeAdmin")
            {
                string targetPcno = e.CommandArgument.ToString();
                string currentPcno = Session["PCNO"] != null ? Session["PCNO"].ToString() : "";

                if (targetPcno == currentPcno)
                {
                    ShowGridMessage("You cannot revoke your own administrator access.", false);
                    return;
                }

                try
                {
                    // Downgrade the user's role to 0 in AppUsers
                    string query = "UPDATE AppUsers SET Role = 0 WHERE PCNO = @PCNO";
                    MySqlParameter[] mysqlParams = new MySqlParameter[] {
                        new MySqlParameter("@PCNO", targetPcno)
                    };
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), query, mysqlParams);

                    ShowGridMessage($"Administrator access for PCNO {targetPcno} has been successfully revoked.", true);
                    BindAdminGrid();
                }
                catch (Exception ex)
                {
                    ShowGridMessage("Error revoking administrator access: " + ex.Message, false);
                }
            }
        }

        private void BindAdminGrid()
        {
            try
            {
                lblGridMessage.Visible = false;
                string query = "SELECT PCNO, Name FROM AppUsers WHERE Role = 1";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetAttendanceDBConnection(), query);
                
                gvAdminUsers.DataSource = dt;
                gvAdminUsers.DataBind();
            }
            catch (Exception ex)
            {
                ShowGridMessage("Error loading administrators: " + ex.Message, false);
            }
        }

        private void EnsureNameColumnExists()
        {
            try
            {
                string checkQuery = @"
                    SELECT COUNT(*) 
                    FROM INFORMATION_SCHEMA.COLUMNS 
                    WHERE TABLE_SCHEMA = 'AttendanceDB' 
                      AND TABLE_NAME = 'AppUsers' 
                      AND COLUMN_NAME = 'Name'";
                
                object count = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), checkQuery);
                if (count != null && Convert.ToInt32(count) == 0)
                {
                    string alterQuery = "ALTER TABLE AppUsers ADD COLUMN Name VARCHAR(100)";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), alterQuery);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error verifying Name column in AppUsers: " + ex.Message);
            }
        }

        private void ShowAdminMessage(string msg, bool success)
        {
            lblAdminMessage.Text = msg;
            lblAdminMessage.CssClass = "alert " + (success ? "alert-success" : "alert-danger");
            lblAdminMessage.Visible = true;
        }

        private void ShowGridMessage(string msg, bool success)
        {
            lblGridMessage.Text = msg;
            lblGridMessage.CssClass = "alert " + (success ? "alert-success" : "alert-danger");
            lblGridMessage.Visible = true;
        }
    }
}
