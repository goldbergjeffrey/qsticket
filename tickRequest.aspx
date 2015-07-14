<%@ Page Language="C#" AutoEventWireup="true" debug="true"%>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Threading.Tasks" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Security.Cryptography.X509Certificates" %>

<!--
====================================================================================
File: tickRequest.aspx
Developer: Jeff Goldberg
Created Date: 14-July-2015

Description:
tickRequest.aspx is an asp.net web page to demonstrate using the Qlik Sense Ticketing
API; a component of the Qlik Sense Proxy Service API (qps).  

WARNING!:
This code is intended for testing and demonstration purposes only.  It is not meant for
production environments.  In addition, the code is not supported by Qlik.

This code uses bootstrap for ui enhancement.  Bootstrap is delivered by urls.
If bootstrap CDN cannot be contacted, please download bootstrap (http://getbootstrap.com/)
and configure for this web page.

Change Log
Developer					Change Description						Modify Date
====================================================================================
Jeff Goldberg				Initial Release							14-July-2015


====================================================================================
====================================================================================
-->

<head>
	<meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
	<!-- Latest compiled and minified CSS -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">

	<!-- Optional theme -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css">

	<!-- Latest compiled and minified JavaScript -->
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script> 
</head>
<html>
<body>
<form runat="Server" id="MainForm" class="form-horizontal">
	<div class="container">
		<div class="jumbotron" style="width: 950px; margin-top: 10px;">
			<H1 class="text-center" style="margin-top: -10px;">Qlik Sense Ticket Example</H1>
			<div class="row">
				<div style="padding-bottom: 5px;" class="form-group col-md-5">
					<div>
						<label for="txtServer" class="control-label">Sense Server</label>
						<asp:TextBox id="txtServer" runat="server" width="250px" class="form-control">Enter Qlik Sense Server Name</asp:TextBox>
					</div>
					<div>
						<label for="txtServer" class="control-label">Virtual Proxy</label>
						<asp:TextBox id="txtVp" runat="server" width="250px" class="form-control">Enter Virtual Proxy Name</asp:TextBox>
					</div>
				</div>
				<div style="padding-bottom: 5px;" class="form-group col-md-5">
					<div>
						<label for="txtUserDirectory" class="control-label">User Directory</label>
						<asp:TextBox id="txtUserDirectory" runat="server" width="250px" class="form-control">Enter User Directory</asp:TextBox>
					</div>
					<div>
						<label for="txtUser" class="control-label">User Id</label>
						<asp:TextBox id="txtUser" runat="server" width="250px" class="form-control">Enter UserId</asp:TextBox>
					</div>
				</div>
			</div>
			<div class="row">
				<label for="tickResponse" class="control-label">Response from Server</label>
			</div>
			<div class="row form-inline" style="padding-bottom: 10px;">
					<asp:TextBox id="tickResponse" runat="server" class="form-control" style="width: 750px;"></asp:TextBox>
					<asp:Button id="btnGo" runat="server" Text="Get Ticket" onclick="Go_Button_Click" class="btn btn-primary" style="width: 100px"></asp:Button>		
			</div>
			<div class="row">
				<label for="theTicket" class="control-label">Redirect Url</label>
			</div>
			<div class="row form-inline">
					<asp:TextBox id="theTicket" runat="server" width="750px" class="form-control"></asp:TextBox>
					<asp:Button id="btnLaunch" runat="server" Text="Use Ticket" onclick="Launch_Button_Click" class="btn btn-success" style="width: 100px"></asp:Button>
			</div>
		</div>
	</div>
</form>
</body>
</html>

<script language="c#" runat="server">

        private string TicketRequest(string method, string server, string virtualProxy, string user, string userdirectory)
        {
			X509Certificate2 certificateFoo =null;

            // First locate the Qlik Sense certificate
			X509Store store = new X509Store(StoreName.My, StoreLocation.LocalMachine);
            store.Open(OpenFlags.ReadOnly);
            certificateFoo = store.Certificates.Cast<X509Certificate2>().FirstOrDefault(c => c.FriendlyName == "QlikClient");
			store.Close();
			//The following line is required because the root certificate for the above server certificate is self-signed.
			//Using a certificate from a trusted root certificate authority will allow this line to be removed.
            ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
            
			//Create URL to REST endpoint for tickets
            string url = "https://" + server + ":4243/qps/" + virtualProxy + "/ticket";

            //Create the HTTP Request and add required headers and content in Xrfkey
            string Xrfkey = "0123456789abcdef";
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url + "?Xrfkey=" + Xrfkey);
            // Add the method to authentication the user
            request.ClientCertificates.Add(certificateFoo);    
            request.Method = method;
            request.Accept = "application/json";
            request.Headers.Add("X-Qlik-Xrfkey", Xrfkey);

	        //The body message sent to the Qlik Sense Proxy api will add the session to Qlik Sense for authentication
            string body = "{ 'UserId':'" + user + "','UserDirectory':'" + userdirectory +"',";
			body+= "'Attributes': [],";
			body+= "}";
            byte[] bodyBytes = Encoding.UTF8.GetBytes(body);
            
            if (!string.IsNullOrEmpty(body))
            {
                request.ContentType = "application/json";
                request.ContentLength = bodyBytes.Length;
                Stream requestStream = request.GetRequestStream();
                requestStream.Write(bodyBytes, 0, bodyBytes.Length);
                requestStream.Close();
            }
                        
            // make the web request and return the content
            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
			Stream stream = response.GetResponseStream();
            return stream != null ? new StreamReader(stream).ReadToEnd() : string.Empty;
			
        }

	protected void Go_Button_Click(object sender, EventArgs e)
		{
			//Request a ticket
			string ticketresponse= TicketRequest("POST", txtServer.Text, txtVp.Text, txtUser.Text, txtUserDirectory.Text);
			tickResponse.Text = ticketresponse;
			//Parse the response
			string[] getTicket = ticketresponse.Split(new Char[] {','});
			string[] getTicketCode = getTicket[3].Split(new Char[] {':'});
			//Form the url to use the ticket
			theTicket.Text = "https://" + txtServer.Text + "/" + txtVp.Text + "/Hub?qlikTicket=" + getTicketCode[1].Trim(new Char[] {'"'});
		}
	
		protected void Launch_Button_Click(object sender, EventArgs e)
		{
			//Redirect to the Qlik Sense server url desired
			Response.Redirect(theTicket.Text);
		}

</script>