<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="AttendanceApp.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Dashboard
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        .card-custom {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            text-align: center;
            cursor: pointer;
            transition: transform 0.2s;
            text-decoration: none;
            color: #333;
            display: block;
        }
        .card-custom:hover {
            transform: translateY(-5px);
            color: #4f46e5;
            text-decoration: none;
        }
        .card-custom h3 {
            margin: 10px 0;
            font-size: 1.5rem;
        }
        .card-custom p {
            color: #666;
            margin-bottom: 0;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <h2>HR Dashboard</h2>
    <hr />
    
    <div class="dashboard-grid">
        <asp:PlaceHolder ID="phAdmin_Emp" runat="server">
            <a href="Employee.aspx" class="card-custom">
                <i class="fas fa-users fa-3x mb-3 text-primary"></i>
                <h3>Employee</h3>
                <p>Manage employees</p>
            </a>
        </asp:PlaceHolder>

        <a href="Attendance.aspx" class="card-custom">
            <i class="fas fa-calendar-check fa-3x mb-3 text-success"></i>
            <h3>Attendance</h3>
            <p>Mark attendance</p>
        </a>

        <a href="Ledger.aspx" class="card-custom">
            <i class="fas fa-book fa-3x mb-3 text-info"></i>
            <h3>Ledger</h3>
            <p>Leave tracking</p>
        </a>

        <asp:PlaceHolder ID="phAdmin_Calc" runat="server">
            <a href="Calculation.aspx" class="card-custom">
                <i class="fas fa-calculator fa-3x mb-3 text-warning"></i>
                <h3>Calculation</h3>
                <p>Salary processing</p>
            </a>
            
            <a href="#" class="card-custom">
                <i class="fas fa-file-alt fa-3x mb-3 text-secondary"></i>
                <h3>Documents</h3>
                <p>Manage employee documents</p>
            </a>
        </asp:PlaceHolder>

        <asp:PlaceHolder ID="phAdmin_AdminMgmt" runat="server">
            <a href="AdminManagement.aspx" class="card-custom">
                <i class="fas fa-user-shield fa-3x mb-3 text-danger"></i>
                <h3>Admin Management</h3>
                <p>Configure administrators</p>
            </a>
        </asp:PlaceHolder>
    </div>
</asp:Content>
