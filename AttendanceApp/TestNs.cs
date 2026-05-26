using System;
using System.Reflection;
using System.Linq;

class Program
{
    static void Main()
    {
        var asm = Assembly.LoadFile(@"E:\attendence\AttendanceApp\packages\MySqlConnector.1.3.14\lib\net45\MySqlConnector.dll");
        var namespaces = asm.GetTypes().Select(t => t.Namespace).Distinct().ToList();
        foreach (var ns in namespaces)
        {
            Console.WriteLine(ns);
        }
    }
}
