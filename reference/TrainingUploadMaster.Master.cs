using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TRAINING_FILEUPLOAD
{
    public partial class TrainingUploadMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Prevent browser from caching protected pages (stops Back-button bypass after logout)
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetExpires(DateTime.Now.AddYears(-1));
            Response.AppendHeader("Pragma", "no-cache");

            if (Session["PCNO"] == null)
            {
                Response.Redirect("default");
            }
            if (Convert.ToInt32(Session["Result"]) == 1)
            {
                lblUserName.InnerText = "Administrator";
                myfw.Attributes["class"] = "fas fa-user-shield";
            }
        }
    }
}