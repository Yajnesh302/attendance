<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="default.aspx.cs" Inherits="TRAINING_FILEUPLOAD._default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <meta name="description" content="" />
    <meta name="author" content="" />

    <title>Training Material Upload Login</title>
    <!-- Custom fonts for this template-->
    <link href="static/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css" />
    <!-- Custom styles for this template-->
    <link href="static/css/sb-admin-2.min.css" rel="stylesheet" />
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
                                    <img src="http://www.lrde.com/ImageFiles/newlrdelogo.png" style="transform: scale(0.7)" alt="LRDE Logo">
                                </div>
                                <div class="col-lg-6">
                                    <div class="p-5">
                                        <div class="text-center">
                                            <h1 class="h4 text-gray-900 mb-4">Login!!!</h1>
                                        </div>
                                        <div class="user">
                                            <div class="form-group">
                                                <input class="form-control form-control-user"
                                                    id="userid" aria-describedby="emailHelp"
                                                    placeholder="Enter your Username..." runat="server" />
                                            </div>
                                            <div class="form-group">
                                                <input type="password" class="form-control form-control-user"
                                                    id="userpwd" placeholder="Password" runat="server" />
                                            </div>
                                            <%--<div class="form-group">
                                            <div class="custom-control custom-checkbox small">
                                                <input type="checkbox" class="custom-control-input" id="customCheck"/>
                                                <label class="custom-control-label" for="customCheck">Remember
                                                    Me</label>
                                            </div>
                                        </div>--%>
                                            <asp:Button ID="Login" CssClass="btn btn-primary btn-user btn-block" OnClick="Login_Click"  runat="server" Text="Login" />

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
        <!--
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
            $('#userid').focus();
        });
        </script>

        <script>
            <% if (!string.IsNullOrEmpty(JwtToken)) { %>
            // The C# backend has successfully retrieved the Session and generated a Token!
            localStorage.setItem('jwtToken', '<%= JwtToken %>');
            
            // DEBUG ALERT: Show the user what PC Number was retrieved from Active Directory
            alert("Success! Active Directory assigned you PC Number: <%= Session["PCNO"] %>\nYour Role is: <%= UserRole %>");
            
            // Redirect to appropriate page based on role
            <% if (UserRole == "admin") { %>
            window.location.replace('Admin_Upload');
            <% } else { %>
                window.location.replace('User');
            <% } %>
        <% } %>
        </script>


    </form>
</body>
</html>
