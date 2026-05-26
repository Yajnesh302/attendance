using Oracle.ManagedDataAccess.Client;
using System.DirectoryServices;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace TRAINING_FILEUPLOAD
{
    public partial class _default : System.Web.UI.Page
    {
        public string JwtToken { get; set; }
        public string  UserRole { get; set; }
        public int val { get; set; }
        public OracleConnection Connection
        {
            get
            {
                return new OracleConnection(Utils.DBDetails.ConnectionString);
            }
        }
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void Login_Click(object sender, EventArgs e)
        {
            string getPCNO = authenticate(userid.Value.Trim(), userpwd.Value.Trim());

            if (string.IsNullOrEmpty(getPCNO))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Invalid Username or Password');", true);
            }
            else
            {
                HttpContext.Current.Session["PCNO"] = getPCNO;
                HttpContext.Current.Session.Timeout = 1440;
                Session["PCNO"] = getPCNO;
                // Redirect to home
                Session["Result"] = Get_Role(getPCNO);
                val = Get_Role(getPCNO);
                if (val == 1)
                {
                    UserRole = "admin";
                }
                else
                {
                    UserRole = "user";
                }
                
                getNameDesig(Session["PCNO"].ToString());
                string pcno = Session["PCNO"] as string;
                JwtToken = GenerateJSONWebToken(pcno, UserRole);
            }
        }

        private string GenerateJSONWebToken(string username, string role)
        {
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(ConfigurationManager.AppSettings["JwtKey"]));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var claims = new[] {
                new Claim(ClaimTypes.Name, username),
                new Claim(ClaimTypes.Role, role)
            };

            var token = new JwtSecurityToken(
                ConfigurationManager.AppSettings["JwtIssuer"],
                ConfigurationManager.AppSettings["JwtAudience"],
                claims,
                expires: DateTime.Now.AddMinutes(120),
                signingCredentials: credentials);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        public void getNameDesig(string pcno)
        {
            OracleConnection dbConnection = null;

            using (dbConnection = Connection)
            {
                try
                {
                    dbConnection.Open();
                    OracleCommand cmd = new OracleCommand("SELECT name,designation,divname from hrdata.empdetails where pcno=" + pcno, dbConnection);
                    OracleDataReader rdr = cmd.ExecuteReader();

                    while (rdr.Read())
                    {
                        Session["NAME"] = rdr["NAME"].ToString();
                        Session["DESIGNATION"] = rdr["DESIGNATION"].ToString();
                        Session["DIVNAME"] = rdr["DIVNAME"].ToString();
                    }
                }
                catch (Exception)
                {
                    // Fallback if hrdata.empdetails doesn't exist locally
                    Session["NAME"] = "Local Test User";
                    Session["DESIGNATION"] = "Tester";
                    Session["DIVNAME"] = "Local Div";
                }
            }
        }

        private int Get_Role(string PCNO)
        {
            int result;

            OracleConnection dbConnection = null;
            using (dbConnection = Connection)
            {
                dbConnection.Open();
                // MySQL uses LIMIT 1 instead of ROWNUM = 1
                OracleCommand cmd = new OracleCommand("SELECT COALESCE((SELECT ROLE FROM TRAINING_CEP_USERS WHERE PCNO = " + PCNO + " LIMIT 1),0) AS ROLE FROM DUAL", dbConnection);
                object count = cmd.ExecuteScalar();
                result = Convert.ToInt32(count);
            }
            return result;
        }

        private string authenticate(string username, string password)
        {

            string pcno = null;
            // Updated back to the company's Active Directory LDAP address
            string strCommu = "LDAP://lrde.com/dc=lrde,dc=com";
            try
            {
                DirectoryEntry entry = new DirectoryEntry(strCommu, username, password);
                DirectorySearcher search = new DirectorySearcher(entry);
                search.Filter = "(SAMAccountName=" + username + ")";
                search.PropertiesToLoad.Add("bn");
                SearchResult result = search.FindOne();
                DirectoryEntry dsresult = result.GetDirectoryEntry();
                pcno = result != null ? dsresult.Properties["EmployeeID"][0].ToString() : null;
            }
            catch (Exception ex)
            {
                pcno = null;
            }

            return pcno;

        }
    }
}

