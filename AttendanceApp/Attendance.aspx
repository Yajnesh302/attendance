<%@ Page Title="Attendance" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Attendance.aspx.cs" Inherits="AttendanceApp.Attendance" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Attendance Management
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .controls {
            margin: 10px 0;
            background: #fff;
            padding: 10px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            display: flex;
            gap: 5px;
            align-items: center;
            flex-wrap: wrap;
        }
        .controls select, .controls input, .controls button {
            padding: 5px;
            font-size: 14px;
        }
        .wrapper {
            height: 65vh;
            overflow: auto;
            border: 1px solid #ccc;
            background: white;
            border-radius: 8px;
        }
        table.att-table {
            border-collapse: collapse;
            width: max-content;
            min-width: 100%;
        }
        .att-table th, .att-table td {
            border: 1px solid #ddd;
            padding: 4px;
            text-align: center;
            font-size: 14px;
            min-width: 40px;
            height: 50px;
            position: relative;
            vertical-align: top;
        }
        .att-table th {
            position: sticky;
            top: 0;
            background: #f0f2f5;
            z-index: 10;
        }
        .green { background: #d9f7be !important; }
        .red { background: #ffa39e !important; }
        .royal-blue { background: #4169E1 !important; color: white !important; }
        .light-yellow { background: #fff9c4 !important; }
        .gray { background: #e5e7eb !important; color: #666; }
        input.att {
            width: 35px;
            text-align: center;
            border: 1px solid #999;
            font-weight: bold;
            background: transparent;
            outline: none;
            font-size: 14px;
            margin-top: 2px;
        }
        .label-text {
            display: block;
            font-size: 11px;
            font-weight: bold;
            color: #333;
            margin-top: 1px;
        }
        select.leave-opt {
            position: absolute;
            bottom: 1px;
            left: 1px;
            width: calc(100% - 2px);
            font-size: 10px;
            padding: 0;
            height: 16px;
            box-sizing: border-box;
        }
        #ledger-pop {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: #111827;
            color: white;
            padding: 12px 18px;
            border-radius: 8px;
            display: none;
            z-index: 9999;
            font-size: 13px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
        }
        .btn-purple {
            background-color: #9333ea;
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
        }
        .btn-purple:hover {
            background-color: #7e22ce;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    
    <div id="ledger-pop"></div>

    <h2>Attendance Management</h2>
    
    <div class="controls">
        Year: <select id="yearSel"></select>
        Month: <select id="monthSel"></select>
        Cat: 
        <select id="catSel">
            <option>Skilled</option>
            <option>Semi-Skilled</option>
            <option>Unskilled</option>
        </select>
        
        Search: <input id="search" placeholder="ID/Name" style="width:100px" />
        
        Holiday: <input id="holidayInput" style="width:60px" placeholder="14,26" />
        <button type="button" onclick="applyHoliday()" style="background:#4169E1;color:white" class="btn btn-sm">Apply</button>
        <button type="button" onclick="removeHoliday()" style="background:red;color:white" class="btn btn-sm">Remove</button>
        <button type="button" onclick="globalAdjust()" class="btn-purple">Global Adjust</button>
        
        <button type="button" onclick="saveData()" style="background:#28a745;color:white" class="btn btn-sm">Save</button>
        <button type="button" onclick="fetchData()" style="background:#17a2b8;color:white" class="btn btn-sm">Refresh</button>
    </div>

    <div class="wrapper">
        <table class="att-table" id="attTable">
            <thead id="thead"></thead>
            <tbody id="tbody"></tbody>
        </table>
    </div>

    <script>
        let attendanceData = {};
        let prevAttendanceData = {};
        let employees = [];
        let isDirty = false;

        const yS = document.getElementById('yearSel');
        const mS = document.getElementById('monthSel');
        const cS = document.getElementById('catSel');
        const searchBox = document.getElementById('search');
        const tb = document.getElementById('tbody');
        const th = document.getElementById('thead');

        const currentYear = new Date().getFullYear();
        for (let y = currentYear - 2; y <= currentYear + 5; y++) {
            yS.innerHTML += `<option value="${y}">${y}</option>`;
        }

        ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"].forEach((m, i) => {
            mS.innerHTML += `<option value="${i}">${m}</option>`;
        });

        yS.value = currentYear;
        mS.value = new Date().getMonth();

        window.onbeforeunload = function() {
            if (isDirty) return "You have unsaved changes! Are you sure you want to leave?";
        };

        // Prevent enter key from triggering default button (Logout)
        document.addEventListener('keydown', function(event) {
            if (event.keyCode === 13 && event.target.tagName === 'INPUT') {
                event.preventDefault();
                return false;
            }
        });

        function handleFilterChange() {
            if (isDirty) {
                if (confirm("You have unsaved changes! Do you want to save them before changing the view?")) {
                    saveData();
                }
            }
            fetchData();
        }

        yS.onchange = mS.onchange = cS.onchange = handleFilterChange;
        searchBox.oninput = handleFilterChange;

        function showPop(msg) {
            const pop = document.getElementById("ledger-pop");
            pop.innerText = msg;
            pop.style.display = "block";
            clearTimeout(window.popTimer);
            window.popTimer = setTimeout(() => pop.style.display = "none", 2000);
        }

        function fetchData() {
            const req = {
                year: parseInt(yS.value),
                month: parseInt(mS.value),
                category: cS.value,
                search: searchBox.value
            };

            fetch('Attendance.aspx/GetData', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(req)
            }).then(r => r.json()).then(res => {
                const data = JSON.parse(res.d);
                employees = data.Employees;
                attendanceData = data.Attendance || {};
                prevAttendanceData = data.PrevAttendance || {};
                
                // Automatically run Saturday Cut calculations for all loaded employees on load
                employees.forEach(emp => {
                    attendanceData[emp.ID] = attendanceData[emp.ID] || {};
                    calcSat(emp.ID, true);
                });
                
                isDirty = false;
                render();
            }).catch(e => console.error(e));
        }

        function saveData() {
            const req = {
                year: parseInt(yS.value),
                month: parseInt(mS.value),
                category: cS.value,
                data: JSON.stringify(attendanceData)
            };

            fetch('Attendance.aspx/SaveData', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(req)
            }).then(r => r.json()).then(res => {
                isDirty = false;
                showPop("Saved Successfully");
            }).catch(e => {
                console.error(e);
                showPop("Error saving");
            });
        }

        function getRefDays(y, m) {
            let d = new Date(y, m, 0), arr = [];
            while (d.getDay() != 6) {
                if (d.getDay() != 0) {
                    arr.unshift(new Date(d));
                }
                d.setDate(d.getDate() - 1);
            }
            return arr;
        }

        function render() {
            const y = parseInt(yS.value);
            const m = parseInt(mS.value);
            const days = new Date(y, m + 1, 0).getDate();
            const refs = getRefDays(y, m);
            
            let head = `<tr><th>ID</th><th>Name</th>`;
            
            refs.forEach(d => {
                head += `<th class="gray">${String(d.getDate()).padStart(2, '0')}<br>${d.toLocaleDateString('en', { weekday: 'short' })}</th>`;
            });

            for (let i = 1; i <= days; i++) {
                let d = new Date(y, m, i);
                if (d.getDay() !== 0) { 
                    head += `<th>${String(i).padStart(2, '0')}<br>${d.toLocaleDateString('en', { weekday: 'short' })}</th>`;
                }
            }
            head += `<th>Present</th><th>Adj</th><th>Total</th></tr>`;
            th.innerHTML = head;

            let rows = "";
            employees.forEach((emp, empIdx) => {
                attendanceData[emp.ID] = attendanceData[emp.ID] || {};
                let count = 0;
                let maxTotal = 0;
                let r = `<tr data-empid="${emp.ID}"><td>${emp.ID}</td><td style="text-align:left;">${emp.Name}</td>`;

                refs.forEach(d => {
                    let prevDay = d.getDate();
                    let pCell = (prevAttendanceData[emp.ID] && prevAttendanceData[emp.ID][prevDay]) ? prevAttendanceData[emp.ID][prevDay] : { Val: null, Leave: "" };
                    let pVal = (pCell.Val === null || pCell.Val === undefined) ? "" : pCell.Val;
                    let pLabel = pCell.Leave ? `<span class="label-text" style="color:gray;">${pCell.Leave}</span>` : "";
                    
                    r += `<td class="gray"><input class="att" value="${pVal}" readonly tabindex="-1" style="color:gray;border-color:#ccc;">${pLabel}</td>`;
                });

                let halfCount = 0;
                for (let i = 1; i <= days; i++) {
                    if (attendanceData[emp.ID][i]?.Val === 0.5) halfCount++;
                }
                const halfPairExists = halfCount >= 2 && halfCount % 2 === 0;

                for (let i = 1; i <= days; i++) {
                    let d = new Date(y, m, i);
                    const cell = attendanceData[emp.ID][i] || { Val: null, Holiday: false, Leave: "" };
                    
                    if (d.getDay() === 0 && !cell.Holiday) continue;

                    let cls = "", drop = "", label = "";
                    let valToDisplay = (cell.Val === null || cell.Val === undefined) ? '' : cell.Val;

                    let readonlyAttr = "";
                    let dStr = `${y}-${String(m + 1).padStart(2, '0')}-${String(i).padStart(2, '0')}`;
                    let isOutOfBounds = (emp.JoinDate && dStr < emp.JoinDate) || (emp.ResignDate && dStr > emp.ResignDate);

                    if (!isOutOfBounds) maxTotal++;

                    if (isOutOfBounds) {
                        cls = "";
                        valToDisplay = "";
                        readonlyAttr = 'readonly tabindex="-1" style="background:#d1d5db; border:1px solid #9ca3af; cursor:not-allowed;"';
                    } else {
                        if (cell.Holiday) { 
                            cls = "royal-blue"; 
                            valToDisplay = "H";
                            count += 1;
                            readonlyAttr = 'readonly tabindex="-1" style="background:transparent; border:none;"';
                        }
                        else if (cell.Val === 1) { 
                            cls = "green"; 
                            count += 1; 
                        }
                        else if (cell.Val === 0.5) { 
                            cls = "light-yellow"; 
                            count += 0.5;
                        }
                        else if (cell.Val === 0) { 
                            if (cell.Leave === "Paid") {
                                cls = "green";
                                valToDisplay = "1";
                                count += 1;
                            } else {
                                cls = "red";
                            }
                            
                            if (halfPairExists && cell.Leave !== "Paid") {
                                cls = "light-yellow";
                            }
                            
                            if (d.getDay() !== 6) {
                                let opts = halfPairExists 
                                    ? `<option value="">0</option><option value="Paid" ${cell.Leave=="Paid"?"selected":""}>Paid</option>`
                                    : `<option></option><option ${cell.Leave=="Paid"?"selected":""}>Paid</option><option ${cell.Leave=="Unpaid"?"selected":""}>Unpaid</option>`;
                                drop = `<select class="leave-opt" onchange="setLeave('${emp.ID}', ${i}, this.value, event)">${opts}</select>`;
                            }
                        }

                        if (cell.Leave) {
                            label = `<span class="label-text">${cell.Leave}</span>`;
                        }

                        if (d.getDay() === 6) {
                            readonlyAttr = 'readonly tabindex="-1" style="background:#e5e7eb; color:#6b7280; border:1px solid #d1d5db; cursor:not-allowed;"';
                        }
                    }

                    r += `<td class="${cls}" data-day="${i}">
                            <input class="att" value="${valToDisplay}" oninput="setVal('${emp.ID}', ${i}, this.value, event)" ${readonlyAttr}>
                            ${label}
                            ${drop}
                          </td>`;
                }
                
                let adj = 0;
                if (attendanceData["GLOBAL"] && attendanceData["GLOBAL"][0]) {
                    adj = attendanceData["GLOBAL"][0].Val || 0;
                }
                
                r += `<td class="total-col fw-bold">${count}</td>
                      <td class="total-col">${(adj > 0 ? '+' : '') + (adj !== 0 ? adj : '-')}</td>
                      <td class="total-col text-primary fw-bold">${maxTotal}</td></tr>`;
                rows += r;
            });
            tb.innerHTML = rows;
        }

        function setLeave(id, day, val, event) {
            attendanceData[id][day].Leave = val;
            
            // Keep Val as 0 for both Paid and Unpaid so it saves properly as an absence
            // and the dropdown remains visible. updateRowUI will calculate the present days correctly.
            attendanceData[id][day].Val = 0;
            
            isDirty = true;
            calcSat(id);
            updateRowUI(event.target.closest("tr"), id);
        }

        function calcSat(id, isInitialLoad) {
            const y = parseInt(yS.value);
            const m = parseInt(mS.value);
            const days = new Date(y, m + 1, 0).getDate();
            const data = attendanceData[id];
            const emp = employees.find(e => e.ID === id) || {};

            let halfEntries = 0;
            Object.keys(data).forEach(d => {
                if (data[d]?.Val === 0.5) halfEntries++;
            });
            const halfPairExists = halfEntries >= 2 && halfEntries % 2 === 0;

            let satChanged = false;

            for (let i = 1; i <= days; i++) {
                let d = new Date(y, m, i);
                if (d.getDay() == 6) {
                    let ok = true;
                    for (let k = 1; k <= 5; k++) {
                        let c = new Date(d);
                        c.setDate(d.getDate() - k);

                        // Check employee JoinDate and ResignDate bounds
                        let cStr = `${c.getFullYear()}-${String(c.getMonth() + 1).padStart(2, '0')}-${String(c.getDate()).padStart(2, '0')}`;
                        if ((emp.JoinDate && cStr < emp.JoinDate) || (emp.ResignDate && cStr > emp.ResignDate)) {
                            continue; // Out of bounds, skip checking (ignored, does not penalize Saturday)
                        }

                        let v = null;
                        let l = "";
                        let isHol = false;
                        if (c.getMonth() == m) {
                            v = data[c.getDate()]?.Val;
                            l = data[c.getDate()]?.Leave;
                            isHol = data[c.getDate()]?.Holiday || false;
                        } else {
                            v = prevAttendanceData[id]?.[c.getDate()]?.Val;
                            l = prevAttendanceData[id]?.[c.getDate()]?.Leave;
                            isHol = prevAttendanceData[id]?.[c.getDate()]?.Holiday || false;
                        }
                        
                        let came = (v === 1) || (v === 0.5) || (l === "Paid") || (isHol === true);
                        if (!came) {
                            ok = false;
                            break;
                        }
                    }

                    let oldVal = data[i]?.Val;
                    if (!ok && !halfPairExists) {
                        if (!data[i]?.Holiday) {
                            data[i] = data[i] || {};
                            data[i].Val = 0;
                            data[i].AutoSat = true;
                            if (oldVal !== 0) { 
                                satChanged = true; 
                                if (!isInitialLoad) {
                                    showPop("Saturday Cut Applied");
                                    isDirty = true;
                                }
                            }
                        }
                    } else {
                        data[i] = data[i] || {};
                        data[i].Val = 1;
                        data[i].AutoSat = true;
                        if (oldVal !== 1) { 
                            satChanged = true; 
                            if (!isInitialLoad) {
                                isDirty = true;
                            }
                        }
                    }
                }
            }
            return satChanged;
        }

        function updateRowUI(tr, empID) {
            const emp = employees.find(e => e.ID === empID) || {};
            let count = 0;
            let maxTotal = 0;
            const y = parseInt(yS.value);
            const m = parseInt(mS.value);
            const days = new Date(y, m + 1, 0).getDate();
            const data = attendanceData[empID];
            
            let halfCount = 0;
            for (let i = 1; i <= days; i++) {
                if (data[i]?.Val === 0.5) halfCount++;
            }
            const halfPairExists = halfCount >= 2 && halfCount % 2 === 0;
            
            // First loop: calculate total count
            for (let i = 1; i <= days; i++) {
                const cell = data[i] || { Val: null, Holiday: false, Leave: "" };
                let d = new Date(y, m, i);
                
                let dStr = `${y}-${String(m + 1).padStart(2, '0')}-${String(i).padStart(2, '0')}`;
                if ((emp.JoinDate && dStr < emp.JoinDate) || (emp.ResignDate && dStr > emp.ResignDate)) {
                    continue;
                }
                
                if (d.getDay() === 0 && !cell.Holiday) continue;
                maxTotal++;

                if (cell.Holiday) count += 1;
                else if (cell.Val === 1) count += 1;
                else if (cell.Val === 0.5) count += 0.5;
                else if (cell.Val === 0) {
                    if (cell.Leave === "Paid") count += 1;
                }
            }
            
            let adj = (attendanceData["GLOBAL"] && attendanceData["GLOBAL"][0]) ? attendanceData["GLOBAL"][0].Val : 0;
            let cols = tr.querySelectorAll(".total-col");
            cols[0].innerText = count;
            cols[1].innerText = (adj > 0 ? '+' : '') + (adj !== 0 ? adj : '-');
            cols[2].innerText = maxTotal;

            for (let i = 1; i <= days; i++) {
                let d = new Date(y, m, i);
                const cell = data[i] || { Val: null, Holiday: false, Leave: "" };
                if (d.getDay() === 0 && !cell.Holiday) continue;
                
                const td = tr.querySelector(`td[data-day="${i}"]`);
                if (!td) continue;

                let cls = "", valToDisplay = cell.Val;
                let readonlyAttr = "";
                let dStr = `${y}-${String(m + 1).padStart(2, '0')}-${String(i).padStart(2, '0')}`;
                let isOutOfBounds = (emp.JoinDate && dStr < emp.JoinDate) || (emp.ResignDate && dStr > emp.ResignDate);
                
                if (isOutOfBounds) {
                    cls = "";
                    valToDisplay = "";
                    readonlyAttr = 'readonly tabindex="-1" style="background:#d1d5db; border:1px solid #9ca3af; cursor:not-allowed;"';
                } else {
                    if (cell.Holiday) { 
                        cls = "royal-blue"; 
                        valToDisplay = "H"; 
                        readonlyAttr = 'readonly tabindex="-1" style="background:transparent; border:none;"';
                    }
                    else if (cell.Val === 1) cls = "green";
                    else if (cell.Val === 0.5) cls = "light-yellow";
                    else if (cell.Val === 0) {
                        if (cell.Leave === "Paid") {
                            cls = "green";
                            valToDisplay = "1";
                        } else {
                            cls = halfPairExists ? "light-yellow" : "red";
                        }
                    }
                    
                    if (d.getDay() === 6) {
                        readonlyAttr = 'readonly tabindex="-1" style="background:#e5e7eb; color:#6b7280; border:1px solid #d1d5db; cursor:not-allowed;"';
                    }
                }
                
                td.className = cls;
                
                const inp = td.querySelector(".att");
                if (inp && document.activeElement !== inp) { 
                    inp.value = (valToDisplay === null || valToDisplay === undefined) ? "" : valToDisplay;
                    if (readonlyAttr.includes("readonly")) {
                        inp.setAttribute("readonly", "readonly");
                        inp.setAttribute("tabindex", "-1");
                    } else {
                        inp.removeAttribute("readonly");
                        inp.removeAttribute("tabindex");
                    }
                    inp.setAttribute("style", readonlyAttr.split('style="')[1]?.split('"')[0] || "");
                }

                let drop = td.querySelector(".leave-opt");
                if (cell.Val === 0 && d.getDay() !== 6 && !cell.Holiday) {
                    if (!drop) {
                        drop = document.createElement("select");
                        drop.className = "leave-opt";
                        drop.onchange = (e) => setLeave(empID, i, e.target.value, e);
                        td.appendChild(drop);
                    }
                    if (halfPairExists) {
                        drop.innerHTML = `<option value="">0</option><option value="Paid" ${cell.Leave=="Paid"?"selected":""}>Paid</option>`;
                    } else {
                        drop.innerHTML = `<option></option><option ${cell.Leave=="Paid"?"selected":""}>Paid</option><option ${cell.Leave=="Unpaid"?"selected":""}>Unpaid</option>`;
                    }
                } else {
                    if (drop) drop.remove();
                }

                let labelSpan = td.querySelector(".label-text");
                if (cell.Leave) {
                    if (!labelSpan) {
                        labelSpan = document.createElement("span");
                        labelSpan.className = "label-text";
                        td.appendChild(labelSpan);
                    }
                    labelSpan.innerText = cell.Leave;
                } else {
                    if (labelSpan) labelSpan.remove();
                }
            }
        }

        function setVal(id, day, v, event) {
            const y = parseInt(yS.value);
            const m = parseInt(mS.value);
            const d = new Date(y, m, day);
            if (d.getDay() === 6) {
                event.target.value = attendanceData[id]?.[day]?.Val !== null ? attendanceData[id][day].Val : "";
                return;
            }

            if (v !== "" && v !== "0" && v !== "1" && v !== "0.5" && v !== ".5") {
                if (v !== ".") event.target.value = "";
                return;
            }

            if (v === ".") return;

            let num = (v === "") ? null : Number(v);
            attendanceData[id][day] = attendanceData[id][day] || {};
            attendanceData[id][day].Val = num;
            
            isDirty = true;
            if (num !== 0 && attendanceData[id][day].Leave) attendanceData[id][day].Leave = "";

            calcSat(id);
            updateRowUI(event.target.closest("tr"), id);

            if (v !== "") {
                let currentTd = event.target.closest("td");
                let nextTd = currentTd.nextElementSibling;
                while (nextTd) {
                    let nextInp = nextTd.querySelector(".att");
                    if (nextInp && !nextInp.readOnly) { nextInp.focus(); nextInp.select(); break; }
                    nextTd = nextTd.nextElementSibling;
                }
            }
        }

        function applyHoliday() {
            const days = document.getElementById('holidayInput').value.split(',').map(Number);
            employees.forEach(emp => {
                days.forEach(d => {
                    if(d > 0 && d <= 31) {
                        attendanceData[emp.ID][d] = { Holiday: true, Val: null, Leave: "" };
                    }
                });
            });
            isDirty = true;
            render();
        }

        function removeHoliday() {
            const days = document.getElementById('holidayInput').value.split(',').map(Number);
            employees.forEach(emp => {
                days.forEach(d => {
                    if (d > 0 && d <= 31 && attendanceData[emp.ID]?.[d]?.Holiday) {
                        delete attendanceData[emp.ID][d];
                        isDirty = true;
                    }
                });
            });
            render();
        }

        function globalAdjust() {
            let current = 0;
            if (attendanceData["GLOBAL"] && attendanceData["GLOBAL"][0]) {
                current = attendanceData["GLOBAL"][0].Val || 0;
            }
            const val = prompt(`Global Adjustment\nCurrent: ${current}\n\nExamples:\n1\n-1\n0.5\n-0.5`);
            if (val === null) return;
            const num = Number(val);
            if (isNaN(num)) return;
            
            attendanceData["GLOBAL"] = attendanceData["GLOBAL"] || {};
            attendanceData["GLOBAL"][0] = { Val: num };
            isDirty = true;
            showPop(`Global Adjustment ${num > 0 ? '+' : ''}${num} Applied`);
            render();
        }

        setTimeout(fetchData, 100);
    </script>
</asp:Content>
