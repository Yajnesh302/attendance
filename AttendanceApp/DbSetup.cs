using System;
using System.IO;
using System.Data;
using MySqlConnector;

namespace AttendanceApp
{
    class DbSetup
    {
        static void Main(string[] args)
        {
            string connectionString = "Server=127.0.0.1;Port=33060;Uid=root;Pwd=;";
            string sqlScript = File.ReadAllText("db_setup.sql");

            using (MySqlConnection conn = new MySqlConnection(connectionString))
            {
                try
                {
                    conn.Open();
                    using (MySqlCommand cmd = new MySqlCommand(sqlScript, conn))
                    {
                        cmd.ExecuteNonQuery();
                        Console.WriteLine("Database setup executed successfully.");
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error: " + ex.Message);
                }
            }
        }
    }
}
