<%@ Page Title="Employee Master" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Employee.aspx.cs" Inherits="AttendanceApp.Employee" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Employee Master
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .grid {
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 20px;
            align-items: start;
        }
        .panel {
            background: white;
            padding: 15px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            margin-bottom: 15px;
        }
        .panel h3 { margin-top: 0; font-size: 1.25rem; }
        .table-custom th {
            background: #4f46e5;
            color: white;
        }
        .table-custom td {
            color: #111827; /* Darker text */
            font-weight: 500;
        }
        .panel {
            color: #111827; /* Darker text for manual entry / import */
        }
        .resigned-row { background: #7f1d1d !important; color: white !important; }
        .strike { text-decoration: line-through; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="d-flex justify-content-between mb-3">
        <h2>Employee Master</h2>
    </div>
    
    <asp:Label ID="lblMessage" runat="server" CssClass="alert d-block" Visible="false"></asp:Label>

    <div class="grid">
        <!-- LEFT PANEL -->
        <div>
            <div class="panel">
                <h3>Manual Entry</h3>
                <asp:TextBox ID="txtEmpID" runat="server" CssClass="form-control mb-2" placeholder="Employee ID"></asp:TextBox>
                <asp:TextBox ID="txtEmpName" runat="server" CssClass="form-control mb-2" placeholder="Employee Name"></asp:TextBox>
                
                <asp:DropDownList ID="ddlDept" runat="server" CssClass="form-control mb-2">
                    <asp:ListItem>D-ADMIN</asp:ListItem>
                    <asp:ListItem>D-AE</asp:ListItem>
                    <asp:ListItem>D-KRM</asp:ListItem>
                    <asp:ListItem>D-RAM</asp:ListItem>
                    <asp:ListItem>SECURITY</asp:ListItem>
                </asp:DropDownList>
                
                <asp:DropDownList ID="ddlCat" runat="server" CssClass="form-control mb-2">
                    <asp:ListItem>Skilled</asp:ListItem>
                    <asp:ListItem>Semi-Skilled</asp:ListItem>
                    <asp:ListItem>Unskilled</asp:ListItem>
                </asp:DropDownList>
                
                <asp:TextBox ID="txtJoinDate" runat="server" CssClass="form-control mb-2" TextMode="Date"></asp:TextBox>
                <asp:TextBox ID="txtLeaveBalance" runat="server" CssClass="form-control mb-3" placeholder="Leave Balance" TextMode="Number"></asp:TextBox>
                
                <asp:HiddenField ID="hfEditOldID" runat="server" Value="" />
                <div class="d-flex gap-2">
                    <asp:Button ID="btnAddEmployee" runat="server" Text="Add Employee" CssClass="btn btn-success flex-grow-1" OnClick="btnAddEmployee_Click" />
                    <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClick="btnCancelEdit_Click" Visible="false" formnovalidate="formnovalidate" />
                </div>
            </div>

            <div class="panel">
                <h3>Import CSV</h3>
                <asp:DropDownList ID="ddlImportCat" runat="server" CssClass="form-control mb-2">
                    <asp:ListItem>Skilled</asp:ListItem>
                    <asp:ListItem>Semi-Skilled</asp:ListItem>
                    <asp:ListItem>Unskilled</asp:ListItem>
                </asp:DropDownList>
                <asp:FileUpload ID="fileCSV" runat="server" CssClass="form-control mb-2" />
                <asp:Button ID="btnImport" runat="server" Text="Import" CssClass="btn btn-primary w-100" OnClick="btnImport_Click" />
                <small class="text-muted d-block mt-2">Format: id,name,department,join_date,leave_balance</small>
            </div>
        </div>

        <!-- RIGHT PANEL -->
        <div>
            <div class="panel mb-3 d-flex align-items-center justify-content-between">
                <div class="d-flex align-items-center">
                    <h3 class="mb-0 me-3">Filter</h3>
                    <asp:DropDownList ID="ddlFilter" runat="server" CssClass="form-control w-auto me-3" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged">
                        <asp:ListItem>All</asp:ListItem>
                        <asp:ListItem>Skilled</asp:ListItem>
                        <asp:ListItem>Semi-Skilled</asp:ListItem>
                        <asp:ListItem>Unskilled</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="d-flex align-items-center">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control me-2" placeholder="Search ID or Name..." onkeyup="filterEmployees()"></asp:TextBox>
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-outline-primary" OnClick="btnSearch_Click" />
                </div>
            </div>

            <div class="table-responsive bg-white rounded shadow-sm">
                <asp:GridView ID="gvEmployees" runat="server" AutoGenerateColumns="False" CssClass="table table-hover table-custom mb-0" DataKeyNames="ID" OnRowCommand="gvEmployees_RowCommand" OnRowDataBound="gvEmployees_RowDataBound" OnRowDeleting="gvEmployees_RowDeleting">
                    <Columns>
                        <asp:TemplateField HeaderText="S.No">
                            <ItemTemplate>
                                <%# Container.DataItemIndex + 1 %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="ID" HeaderText="ID" />
                        <asp:BoundField DataField="Name" HeaderText="Name" />
                        <asp:BoundField DataField="Department" HeaderText="Department" />
                        <asp:BoundField DataField="Category" HeaderText="Category" />
                        <asp:BoundField DataField="JoinDate" HeaderText="Join Date" DataFormatString="{0:dd-MM-yyyy}" />
                        <asp:BoundField DataField="LeaveBalance" HeaderText="Leave" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control form-control-sm" onchange="handleStatusChange(this)" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                                    <asp:ListItem Value="Active">Active</asp:ListItem>
                                    <asp:ListItem Value="Resigned">Resigned</asp:ListItem>
                                </asp:DropDownList>
                                <asp:HiddenField ID="hfEmpID" runat="server" Value='<%# Eval("ID") %>' />
                                <asp:HiddenField ID="hfStatus" runat="server" Value='<%# Eval("Status") %>' />
                                <asp:HiddenField ID="hfResignDate" runat="server" Value="" />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <div class="d-flex gap-2">
                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditEmp" CommandArgument='<%# Eval("ID") %>' CssClass="btn btn-sm btn-outline-primary">Edit</asp:LinkButton>
                                    <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteEmp" CommandArgument='<%# Eval("ID") %>' CssClass="btn btn-sm btn-outline-danger" OnClientClick="return confirm('Are you sure you want to completely delete this employee and their attendance history?');">Delete</asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
    
    <script>
        // Prevent enter key from triggering default button (Logout)
        document.addEventListener('keydown', function(event) {
            if (event.keyCode === 13 && event.target.tagName === 'INPUT') {
                event.preventDefault();
                return false;
            }
        });

        function filterEmployees() {
            var input = document.getElementById('<%= txtSearch.ClientID %>').value.toLowerCase();
            var rows = document.querySelectorAll('#<%= gvEmployees.ClientID %> tr:not(:first-child)');
            
            var sNo = 1;
            rows.forEach(function(row) {
                // columns: 0=S.No, 1=Actions, 2=ID, 3=Name
                var idCell = row.cells[2];
                var nameCell = row.cells[3];
                if (idCell && nameCell) {
                    var idText = idCell.textContent.toLowerCase();
                    var nameText = nameCell.textContent.toLowerCase();
                    if (idText.includes(input) || nameText.includes(input)) {
                        row.style.display = '';
                        row.cells[0].textContent = sNo++;
                    } else {
                        row.style.display = 'none';
                    }
                }
            });
        }

        function handleStatusChange(ddl) {
            var val = ddl.value;
            var row = ddl.closest('tr');
            var hfResignDate = row.querySelector('input[id*="hfResignDate"]');
            var hfStatus = row.querySelector('input[id*="hfStatus"]');
            
            if (val === 'Resigned') {
                var dateStr = prompt("Please enter the Resignation Date (YYYY-MM-DD):", new Date().toISOString().split('T')[0]);
                if (!dateStr) {
                    ddl.value = hfStatus.value || 'Active';
                    return;
                }
                hfResignDate.value = dateStr;
            } else {
                hfResignDate.value = "";
            }
            
            __doPostBack(ddl.name, '');
        }
    </script>
</asp:Content>
