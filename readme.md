<h2>Description</h2>
tickRequest.aspx is an asp.net web page to demonstrate using the Qlik Sense Ticketing
API; a component of the Qlik Sense Proxy Service API (qps).  

<strong>WARNING!</strong>
This code is intended for testing and demonstration purposes only.  It is not meant for
production environments.  In addition, the code is not supported by Qlik.

This code uses bootstrap for ui enhancement.  Bootstrap is delivered by urls.
If bootstrap CDN cannot be contacted, please download bootstrap (http://getbootstrap.com/)
and configure for this web page.

<h2>Configuration</h2>
The qps requires https to provide ticket information to the browser.  This demonstration uses the QlikClient certificate supplied during Qlik Sense installation to secure connectivity.  It is possible to use the server certificate as well, but in both cases the certificate must include the private key.

Install the certificate to the Personal folder under the Local Machine certificate store of the web server the aspx page will be hosted.
From the certificates snap-in right click the installed certificate and select Manage Private Keys.  Add the application pool account used to host the web page (e.g. IIS AppPool\DefaultAppPool) to the list of users and click Apply.

It is now possible to test the code.

To see this example in action, follow these video links:
1) [IIS Configuration for qsTicket](https://drive.google.com/open?id=0BxBEVQthCb29ek52R2pCZ3ZOX00)
2) [qsTicket example](https://drive.google.com/open?id=0BxBEVQthCb29VGhoNlN6NEpXa1E)
