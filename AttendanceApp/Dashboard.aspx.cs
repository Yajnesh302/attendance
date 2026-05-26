using System;
using AttendanceApp.Utils;

namespace AttendanceApp
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                int role = Convert.ToInt32(Session["Role"] ?? 0);
                
                // Hide admin specific sections for non-admin users
                if (role != 1)
                {
                    phAdmin_Emp.Visible = false;
                    phAdmin_Calc.Visible = false;
                    phAdmin_AdminMgmt.Visible = false;
                }
            }
        }
    }
}
