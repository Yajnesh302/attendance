<%@ Page Title="Admin Management" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminManagement.aspx.cs" Inherits="AttendanceApp.AdminManagement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Admin Management
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .admin-container {
            margin-top: 10px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <h2>Admin Management</h2>
    <hr />
    
    <div class="row admin-container">
        <!-- Left column: Add New Admin User -->
        <div class="col-lg-6 mb-4">
            <div class="card shadow-sm border-0 rounded-lg h-100">
                <div class="card-header py-3 text-white" style="background: linear-gradient(180deg,#4f46e5 10%,#3730a3 100%);">
                    <h5 class="m-0 font-weight-bold"><i class="fas fa-user-shield mr-2"></i> Add New Admin User</h5>
                </div>
                <div class="card-body p-4 bg-white text-dark">
                    <asp:Label ID="lblAdminMessage" runat="server" Visible="false" CssClass="alert d-block mb-3" role="alert"></asp:Label>
                    
                    <div class="form-group mb-3">
                        <label class="form-label font-weight-bold text-gray-800">PCNO (Employee ID):</label>
                        <asp:TextBox ID="txtAdminPCNO" runat="server" CssClass="form-control" placeholder="e.g. 1004" required="required"></asp:TextBox>
                    </div>
                    <div class="form-group mb-4">
                        <label class="form-label font-weight-bold text-gray-800">Full Name:</label>
                        <asp:TextBox ID="txtAdminName" runat="server" CssClass="form-control" placeholder="e.g. Alice Smith" required="required"></asp:TextBox>
                    </div>
                    
                    <div class="text-right">
                        <asp:Button ID="btnAddAdmin" runat="server" Text="Create Admin User" CssClass="btn btn-primary px-4 py-2 font-weight-bold" OnClick="btnAddAdmin_Click" style="background-color: #4f46e5; border-color: #4f46e5; border-radius: 6px;" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Right column: Current Administrators -->
        <div class="col-lg-6 mb-4">
            <div class="card shadow-sm border-0 rounded-lg h-100">
                <div class="card-header py-3 text-white" style="background: linear-gradient(180deg,#4f46e5 10%,#3730a3 100%);">
                    <h5 class="m-0 font-weight-bold"><i class="fas fa-users-cog mr-2"></i> Current Administrators</h5>
                </div>
                <div class="card-body p-4 bg-white text-dark">
                    <asp:Label ID="lblGridMessage" runat="server" Visible="false" CssClass="alert d-block mb-3" role="alert"></asp:Label>
                    <div class="table-responsive">
                        <asp:GridView ID="gvAdminUsers" runat="server" AutoGenerateColumns="False" 
                                      CssClass="table table-bordered table-striped table-hover align-middle" 
                                      DataKeyNames="PCNO" OnRowCommand="gvAdminUsers_RowCommand" GridLines="None">
                            <Columns>
                                <asp:BoundField DataField="PCNO" HeaderText="PCNO" HeaderStyle-CssClass="text-gray-800 font-weight-bold" ItemStyle-CssClass="align-middle font-weight-bold" />
                                <asp:BoundField DataField="Name" HeaderText="Name" HeaderStyle-CssClass="text-gray-800 font-weight-bold" ItemStyle-CssClass="align-middle" NullDisplayText="N/A" />
                                <asp:TemplateField HeaderText="Actions" HeaderStyle-CssClass="text-gray-800 font-weight-bold text-center" ItemStyle-CssClass="text-center align-middle">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkRevoke" runat="server" CommandName="RevokeAdmin" 
                                                        CommandArgument='<%# Eval("PCNO") %>' 
                                                        CssClass="btn btn-danger btn-sm font-weight-bold text-white px-3 py-1"
                                                        OnClientClick="return confirm('Are you sure you want to revoke administrator access for this user?');"
                                                        style="border-radius: 4px;">
                                            <i class="fas fa-user-minus mr-1"></i> Revoke
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="text-center p-3 text-muted">
                                    No administrators found.
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
