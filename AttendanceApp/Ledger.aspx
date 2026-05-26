<%@ Page Title="Leave Ledger" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Ledger.aspx.cs" Inherits="AttendanceApp.Ledger" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script src="Static/js/xlsx.full.min.js"></script>

    <div class="d-flex justify-content-between mb-3">
        <h2><i class="fas fa-book text-info mr-2"></i>Leave Ledger</h2>
    </div>

    <div class="panel mb-4">
        <div class="row align-items-center g-3">
            <div class="col-auto">
                <asp:DropDownList ID="ddlYear" runat="server" CssClass="form-control"></asp:DropDownList>
            </div>
            <div class="col-auto">
                <asp:DropDownList ID="ddlMonth" runat="server" CssClass="form-control">
                    <asp:ListItem Value="1">Jan</asp:ListItem>
                    <asp:ListItem Value="2">Feb</asp:ListItem>
                    <asp:ListItem Value="3">Mar</asp:ListItem>
                    <asp:ListItem Value="4">Apr</asp:ListItem>
                    <asp:ListItem Value="5">May</asp:ListItem>
                    <asp:ListItem Value="6">Jun</asp:ListItem>
                    <asp:ListItem Value="7">Jul</asp:ListItem>
                    <asp:ListItem Value="8">Aug</asp:ListItem>
                    <asp:ListItem Value="9">Sep</asp:ListItem>
                    <asp:ListItem Value="10">Oct</asp:ListItem>
                    <asp:ListItem Value="11">Nov</asp:ListItem>
                    <asp:ListItem Value="12">Dec</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-auto">
                <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control">
                    <asp:ListItem Value="All">All Categories</asp:ListItem>
                    <asp:ListItem>Skilled</asp:ListItem>
                    <asp:ListItem>Semi-Skilled</asp:ListItem>
                    <asp:ListItem>Unskilled</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-auto">
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search name / ID..."></asp:TextBox>
            </div>
            <div class="col-auto">
                <asp:Button ID="btnGenerate" runat="server" Text="Generate" CssClass="btn btn-primary" OnClick="btnGenerate_Click" />
            </div>
            <div class="col-auto">
                <button type="button" class="btn btn-outline-success" onclick="exportExcel()">Export</button>
            </div>
            <div class="col-auto">
                <button type="button" class="btn btn-outline-info" onclick="exportSummaryExcel()">Export Summary</button>
            </div>
        </div>
    </div>

    <div class="table-responsive bg-white rounded shadow-sm">
        <asp:GridView ID="gvLedger" runat="server" AutoGenerateColumns="False" CssClass="table table-hover table-custom mb-0" ClientIDMode="Static">
            <Columns>
                <asp:TemplateField HeaderText="S.No">
                    <ItemTemplate>
                        <%# Container.DataItemIndex + 1 %>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="ID" HeaderText="ID" />
                <asp:BoundField DataField="Name" HeaderText="Name" ItemStyle-Font-Bold="true" />
                <asp:BoundField DataField="Department" HeaderText="Dept" />
                <asp:BoundField DataField="Category" HeaderText="Category" />
                <asp:BoundField DataField="Opening" HeaderText="Opening" DataFormatString="{0:0.0}" />
                <asp:BoundField DataField="Paid" HeaderText="Paid (-)" ItemStyle-ForeColor="Red" />
                <asp:BoundField DataField="Half" HeaderText="Half" />
                <asp:BoundField DataField="Unpaid" HeaderText="Unpaid" />
                <asp:BoundField DataField="SatCut" HeaderText="Sat Cut" />
                <asp:BoundField DataField="Closing" HeaderText="Closing" DataFormatString="{0:0.0}" ItemStyle-CssClass="fw-bold bg-light" />
            </Columns>
        </asp:GridView>
    </div>

    <script>
        document.addEventListener('keydown', function(event) {
            if (event.keyCode === 13 && event.target.tagName === 'INPUT') {
                event.preventDefault();
                return false;
            }
        });

        function exportExcel() {
            if (typeof XLSX === "undefined") {
                alert("XLSX library not loaded");
                return;
            }
            let table = document.getElementById("gvLedger");
            if (!table) return alert("No data to export!");

            // Remove S.No column before export
            let exportTable = table.cloneNode(true);
            for(let i=0; i<exportTable.rows.length; i++) {
                exportTable.rows[i].deleteCell(0);
            }

            const wb = XLSX.utils.table_to_book(exportTable, {sheet:"Ledger"});
            XLSX.writeFile(wb, "Leave_Ledger.xlsx", { bookType: "xlsx", type: "binary" });
        }

        function exportSummaryExcel() {
            if (typeof XLSX === "undefined") {
                alert("XLSX library not loaded");
                return;
            }
            let table = document.getElementById("gvLedger");
            if (!table) return alert("No data to export!");

            let data = [];
            let rows = table.rows;
            // Start from 1 to skip header
            for(let i=1; i<rows.length; i++) {
                data.push({
                    Name: rows[i].cells[2].innerText,
                    Department: rows[i].cells[3].innerText,
                    Paid: rows[i].cells[6].innerText,
                    Unpaid: rows[i].cells[8].innerText,
                    "Sat Cut": rows[i].cells[9].innerText
                });
            }

            const ws = XLSX.utils.json_to_sheet(data);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "Summary");
            
            let mText = document.getElementById('<%= ddlMonth.ClientID %>').options[document.getElementById('<%= ddlMonth.ClientID %>').selectedIndex].text;
            XLSX.writeFile(wb, `Summary_${mText}.xlsx`, { bookType: "xlsx", type: "binary" });
        }
    </script>
</asp:Content>
