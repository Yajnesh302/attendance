<%@ Page Title="Calculation" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Calculation.aspx.cs" Inherits="AttendanceApp.Calculation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Calculation
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="Static/js/xlsx.full.min.js"></script>
    <style>
        .controls { background: #fff; padding: 12px; margin-bottom: 20px; border-radius: 6px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .table-calc { width: 100%; border-collapse: collapse; background: #fff; }
        .table-calc th { background: #2f5597; color: #fff; padding: 8px; text-align: center; }
        .table-calc td { border: 1px solid #ddd; padding: 6px; text-align: center; }
        .summary { margin-top: 20px; background: #fff; padding: 15px; border-radius: 6px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .name-col { text-align: left !important; padding-left: 10px; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <h2>Salary Calculation</h2>
    
    <div class="controls d-flex flex-wrap align-items-center gap-2">
        <label>Year:</label>
        <select id="year" class="form-select form-select-sm w-auto"></select>
        
        <label>Month:</label>
        <select id="month" class="form-select form-select-sm w-auto"></select>
        
        <label>Category:</label>
        <select id="category" class="form-select form-select-sm w-auto">
            <option>Skilled</option>
            <option>Semi-Skilled</option>
            <option>Unskilled</option>
        </select>
        
        <label>Wage:</label>
        <input type="number" id="wage" class="form-control form-control-sm" style="width: 100px;" />
        
        <button type="button" class="btn btn-primary btn-sm" onclick="saveWage()">Save Wage</button>
        <button type="button" class="btn btn-success btn-sm" onclick="render()">Load & Calculate</button>
        <button type="button" class="btn btn-warning btn-sm" onclick="exportFull()">Export Excel</button>
    </div>

    <div id="result"></div>

    <script>
        const year = document.getElementById("year");
        const month = document.getElementById("month");
        const category = document.getElementById("category");
        const wage = document.getElementById("wage");
        const result = document.getElementById("result");
        let calcData = [];

        for(let y=2020; y<=2100; y++) year.innerHTML+=`<option>${y}</option>`;
        ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"].forEach((m, i) => {
            month.innerHTML += `<option value="${i}">${m}</option>`;
        });

        year.value = new Date().getFullYear();
        month.value = new Date().getMonth();

        function render() {
            const req = {
                year: parseInt(year.value),
                month: parseInt(month.value),
                category: category.value,
                wage: parseFloat(wage.value) || 0
            };

            fetch('Calculation.aspx/GetCalculationData', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(req)
            }).then(r => r.json()).then(res => {
                calcData = JSON.parse(res.d);
                if (calcData.length > 0 && req.wage === 0) {
                    wage.value = calcData[0].WageRate;
                }
                drawTable();
            }).catch(e => console.error(e));
        }

        function drawTable() {
            if (calcData.length === 0) {
                result.innerHTML = "<h4>No records found</h4>";
                return;
            }

            let totalDays = 0, totalAmount = 0;
            let html = `<table class="table-calc"><tr><th>ID</th><th>Name</th><th>Dept</th><th>Present</th><th>Final</th><th>Edit</th><th>Amount</th></tr>`;

            calcData.forEach(emp => {
                totalDays += emp.Final;
                totalAmount += emp.Amount;
                html += `<tr>
                    <td>${emp.ID}</td>
                    <td class="name-col">${emp.Name}</td>
                    <td>${emp.Department}</td>
                    <td>${emp.Present}</td>
                    <td>${emp.Final}</td>
                    <td><button class="btn btn-sm btn-secondary" onclick="editOverride('${emp.ID}')">Edit</button></td>
                    <td>${emp.Amount.toFixed(2)}</td>
                </tr>`;
            });

            html += `<tr style="background:#d9ead3;font-weight:bold;">
                <td colspan="4">Total</td>
                <td>${totalDays}</td><td></td>
                <td>${totalAmount.toFixed(2)}</td>
            </tr></table>`;
            
            html += `<div class="summary">
                Subtotal: ${totalAmount.toFixed(2)}<br>
                Service (3.85%): ${(totalAmount * 0.0385).toFixed(2)}<br>
                GST (18%): ${(totalAmount * 0.18).toFixed(2)}<br>
                <b>Total: ${(totalAmount * 1.2185).toFixed(2)}</b>
            </div>`;

            result.innerHTML = html;
        }

        function saveWage() {
            const req = {
                year: parseInt(year.value),
                month: parseInt(month.value),
                category: category.value,
                wage: parseFloat(wage.value) || 0
            };
            fetch('Calculation.aspx/SaveWage', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(req)
            }).then(r => r.json()).then(() => alert("Saved Wage")).catch(e => console.error(e));
        }

        function editOverride(id) {
            const val = prompt("Enter final days (override):");
            if (val === null) return;
            
            const req = {
                year: parseInt(year.value),
                month: parseInt(month.value),
                category: category.value,
                empId: id,
                finalDays: parseFloat(val) || 0
            };

            fetch('Calculation.aspx/SaveOverride', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(req)
            }).then(r => r.json()).then(() => render()).catch(e => console.error(e));
        }

        function exportFull() {
            if (calcData.length === 0) return alert("No data to export");
            const data = calcData.map(e => ({
                ID: e.ID, Name: e.Name, Department: e.Department,
                Present: e.Present, FinalDays: e.Final, Amount: e.Amount
            }));
            const ws = XLSX.utils.json_to_sheet(data);
            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "Full Report");
            XLSX.writeFile(wb, "Full_Report.xlsx");
        }
    </script>
</asp:Content>
