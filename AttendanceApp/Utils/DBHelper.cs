using System;
using System.Configuration;
using System.Data;
using MySqlConnector;

namespace AttendanceApp.Utils
{
    public static class DBHelper
    {
        public static string GetCompanyDBConnection()
        {
            return ConfigurationManager.ConnectionStrings["CompanyDB"].ConnectionString;
        }

        public static string GetAttendanceDBConnection()
        {
            return ConfigurationManager.ConnectionStrings["AttendanceDB"].ConnectionString;
        }

        public static DataTable ExecuteQuery(string connectionString, string query, params MySqlParameter[] parameters)
        {
            DataTable dt = new DataTable();
            using (MySqlConnection conn = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    using (MySqlDataAdapter sda = new MySqlDataAdapter(cmd))
                    {
                        sda.Fill(dt);
                    }
                }
            }
            return dt;
        }

        public static int ExecuteNonQuery(string connectionString, string query, params MySqlParameter[] parameters)
        {
            int rowsAffected = 0;
            using (MySqlConnection conn = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    conn.Open();
                    rowsAffected = cmd.ExecuteNonQuery();
                }
            }
            return rowsAffected;
        }

        public static object ExecuteScalar(string connectionString, string query, params MySqlParameter[] parameters)
        {
            object result = null;
            using (MySqlConnection conn = new MySqlConnection(connectionString))
            {
                using (MySqlCommand cmd = new MySqlCommand(query, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }
                    conn.Open();
                    result = cmd.ExecuteScalar();
                }
            }
            return result;
        }
    }
}
