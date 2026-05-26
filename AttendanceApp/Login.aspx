<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="AttendanceApp.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <meta name="description" content="" />
    <meta name="author" content="" />

    <title>Attendance System Login</title>
    <!-- Custom fonts for this template-->
    <link href="Static/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css" />
    <!-- Custom styles for this template-->
    <link href="Static/css/sb-admin-2.min.css" rel="stylesheet" />
</head>
<body class="bg-gradient-primary">
    <form id="form1" runat="server">
        <div class="container" style="margin-top: 10%">

            <!-- Outer Row -->
            <div class="row justify-content-center">

                <div class="col-xl-10 col-lg-12 col-md-9">

                    <div class="card o-hidden border-0 shadow-lg my-5">
                        <div class="card-body p-0">
                            <!-- Nested Row within Card Body -->
                            <div class="row">
                                <div class="col-lg-6 d-none d-lg-block ">
                                    <img src="Static/Images/newlrdelogo.png" style="transform: scale(0.7)" alt="LRDE Logo" />
                                </div>
                                <div class="col-lg-6">
                                    <div class="p-5">
                                        <div class="text-center">
                                            <h1 class="h4 text-gray-900 mb-4">Login!!!</h1>
                                            <asp:Label ID="lblError" runat="server" CssClass="text-danger d-block mb-3" Visible="false"></asp:Label>
                                        </div>
                                        <div class="user">
                                            <div class="form-group">
                                                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control form-control-user" placeholder="Enter your Username..."></asp:TextBox>
                                            </div>
                                            <div class="form-group">
                                                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control form-control-user" TextMode="Password" placeholder="Password"></asp:TextBox>
                                            </div>
                                            <asp:Button ID="btnLogin" CssClass="btn btn-primary btn-user btn-block" OnClick="btnLogin_Click" runat="server" Text="Login" />

                                            <hr />

                                            <a href="http://www.lrde.com" class="btn btn-facebook btn-user btn-block">
                                                <i class="fas fa-home"></i>LRDE Home
                                            </a>
                                        </div>
                                        <hr />
                                        <div class="text-center">
                                            <p class="small" style="color:black">For any Help/Feedback please mail ITISG@(it-soft@lrde.com)</p>
                                        </div>

                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="text-center"><p class="small" style="color:black">Designed and Developed By D-KRM/ITISG</p></div>
                    </div>
                    
                </div>

            </div>
            

        </div>

        <!-- Bootstrap core JavaScript-->
        <script src="Static/jquery/jquery.min.js"></script>
        <script src="Static/bootstrap/js/bootstrap.bundle.min.js"></script>

        <!-- Core plugin JavaScript-->
        <script src="Static/jquery-easing/jquery.easing.min.js"></script>

        <!-- Custom scripts for all pages-->
        <script src="Static/js/sb-admin-2.min.js"></script>

        <!-- On Page load Username should be focused-->
        <script>
            $(document).ready(function () {
                $('#txtUsername').focus();

                $('#txtUsername').keypress(function (e) {
                    if (e.which == 13) {
                        e.preventDefault();
                        $('#txtPassword').focus();
                    }
                });
            });
        </script>
    </form>
</body>
</html>
