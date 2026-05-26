using System;
using System.Data;
using System.Web;
using System.Web.Security;
using AttendanceApp.Utils;
using MySqlConnector;
namespace AttendanceApp
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (User.Identity.IsAuthenticated)
                {
                    Response.Redirect("Dashboard.aspx");
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(username))
            {
                ShowError("Username is required.");
                return;
            }

            string pcno = null;

            try
            {
                pcno = ADHelper.AuthenticateAndGetPCNO(username, password);
            }
            catch (Exception ex)
            {
                ShowError("AD Error: " + ex.Message);
                return;
            }

            if (string.IsNullOrEmpty(pcno))
            {
                ShowError("Invalid credentials or user not found in AD.");
                return;
            }

            // Fetch Role from AttendanceDB
            int role = 0; // Default is user
            try
            {
                string queryRole = "SELECT Role FROM AppUsers WHERE PCNO = @PCNO LIMIT 1";
                object res = DBHelper.ExecuteScalar(DBHelper.GetAttendanceDBConnection(), queryRole, new MySqlParameter("@PCNO", pcno));
                if (res != null && res != DBNull.Value)
                {
                    role = Convert.ToInt32(res);
                }
            }
            catch (Exception ex)
            {
                // Default to user on error
                System.Diagnostics.Debug.WriteLine(ex.Message);
            }

            // Fetch Division from CompanyDB
            string division = "";
            string name = "User";
            string designation = "";
            try
            {
                string queryDiv = "SELECT NAME, DESIGNATION, DIVNAME FROM hrdata.empdetails WHERE PCNO = @PCNO LIMIT 1";
                DataTable dt = DBHelper.ExecuteQuery(DBHelper.GetCompanyDBConnection(), queryDiv, new MySqlParameter("@PCNO", pcno));
                if (dt.Rows.Count > 0)
                {
                    name = dt.Rows[0]["NAME"].ToString();
                    designation = dt.Rows[0]["DESIGNATION"].ToString();
                    division = dt.Rows[0]["DIVNAME"].ToString();
                }
            }
            catch (Exception ex)
            {
                // Fallback division for testing
                division = "DKRM/TEST";
                designation = "Administrator";
                System.Diagnostics.Debug.WriteLine(ex.Message);
            }

            // Extract prefix (e.g., DKRM from DKRM/ITISG)
            string divPrefix = division;
            if (division.Contains("/"))
            {
                divPrefix = division.Split('/')[0].Trim();
            }

            // Store in Session
            Session["PCNO"] = pcno;
            Session["Role"] = role; // 1 for Admin, 0 for User
            Session["Division"] = divPrefix;
            Session["Name"] = name;
            Session["Designation"] = designation;

            if (role == 1)
            {
                try
                {
                    string updateNameQuery = @"
                        INSERT INTO AppUsers (PCNO, Name, Role) 
                        VALUES (@PCNO, @Name, 1)
                        ON DUPLICATE KEY UPDATE Name = @Name, Role = 1";
                    DBHelper.ExecuteNonQuery(DBHelper.GetAttendanceDBConnection(), updateNameQuery,
                        new MySqlParameter("@PCNO", pcno),
                        new MySqlParameter("@Name", name));
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error updating admin name on login: " + ex.Message);
                }
            }

            FormsAuthentication.SetAuthCookie(pcno, false);
            Response.Redirect("Dashboard.aspx");
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            lblError.Visible = true;
        }
    }
}
