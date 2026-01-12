After completing post-installation tasks on Windows Server 2019, one of the first steps that will be needed is to either promote your windows server as a domain controller or to add the server as a member server to an existing Active Directory Domain.

In this blog post, I will show you how to join Windows Server 2019 to an existing Windows Server 2019 Active Directory Domain. There are few things which you need to take care before you start joining the windows server 2019 to an existing AD Domain.

## **Requirements when Joining a Windows Server 2019 to the existing Domain:**

- Make sure that server is configured with static IP
- Make sure that server is configured with primary DNS servers IP address pointing to the domain controller
- Make sure server is able to resolve a domain name to IP address
- Check network connectivity between server and domain controller
- A user account and password on the domain with sufficient privilege to join a server to the domain.

You can also check out video on how to join server 2019 to an existing domain on youtube.

For this tutorial, I have two virtual machines in Oracle VM VirtualBox as below:

[![](https://4.bp.blogspot.com/-yQ4bA4rDYHU/XMRR_w-5ECI/AAAAAAAAAi4/lqxnvas8hJoHPf9UFGv-Jr0kj9RLARD9wCLcBGAs/s1600/VM%2Binformation.jpg)](https://4.bp.blogspot.com/-yQ4bA4rDYHU/XMRR_w-5ECI/AAAAAAAAAi4/lqxnvas8hJoHPf9UFGv-Jr0kj9RLARD9wCLcBGAs/s1600/VM%2Binformation.jpg)

1. On ws2k19-srv01, open server manager console. On the left side click on the **local server**. Now Click on a **workgroup** option. That will open the system properties dialog box.

[![](https://2.bp.blogspot.com/-IM2awejgjGA/XMRR-QDFsXI/AAAAAAAAAjI/RstMCjh0VkoEcTqe37XMozY-2NGRipYvACPcBGAYYCw/s1600/1%2B%25286%2529.png)](https://2.bp.blogspot.com/-IM2awejgjGA/XMRR-QDFsXI/AAAAAAAAAjI/RstMCjh0VkoEcTqe37XMozY-2NGRipYvACPcBGAYYCw/s1600/1%2B%25286%2529.png)

2. On system properties dialog box, Click on “**Change**” button.

[![](https://2.bp.blogspot.com/-oDCHW3Og3iA/XMRR_I25Z3I/AAAAAAAAAjE/ZeHoVN930i00a0SFVqQJnyhsuewRM87SACPcBGAYYCw/s1600/1%2B%25287%2529.png)](https://2.bp.blogspot.com/-oDCHW3Og3iA/XMRR_I25Z3I/AAAAAAAAAjE/ZeHoVN930i00a0SFVqQJnyhsuewRM87SACPcBGAYYCw/s1600/1%2B%25287%2529.png)

3. On Computer Name/Domain Change console, Under member of: select **domain**. Type name of your domain. (In our case it will be mylab.local). Once you ready, click on **OK** button.

[![](https://3.bp.blogspot.com/-7PoxqXdhZyI/XMRR_mwyIYI/AAAAAAAAAjQ/qd7Ib3wl1BgaRCHjpdWjnbn94CkcGfUugCPcBGAYYCw/s1600/1%2B%25288%2529.png)](https://3.bp.blogspot.com/-7PoxqXdhZyI/XMRR_mwyIYI/AAAAAAAAAjQ/qd7Ib3wl1BgaRCHjpdWjnbn94CkcGfUugCPcBGAYYCw/s1600/1%2B%25288%2529.png)

4. It will ask to supply user name and password to join this server to the mylab.local domain. In Active Directory, even standard user account has the privilege to join up to 10 computers to the domain. Here I am using **domain admin’s credential** to join this server to the domain. Click on the **OK** button.

[![](https://3.bp.blogspot.com/-Wiy4hfqRAUQ/XMRR_Z0PdMI/AAAAAAAAAjI/7vSQNACbvoIhfgl8rgg0EGuqAFHvFwYQwCPcBGAYYCw/s1600/1%2B%25289%2529.png)](https://3.bp.blogspot.com/-Wiy4hfqRAUQ/XMRR_Z0PdMI/AAAAAAAAAjI/7vSQNACbvoIhfgl8rgg0EGuqAFHvFwYQwCPcBGAYYCw/s1600/1%2B%25289%2529.png)

5. Once your server successfully joins to the domain, you will receive the message “Welcome to the mylab.local domain”. Click on **OK** button.

[![](https://3.bp.blogspot.com/-R_8QvO00JWA/XMRR7EBqXaI/AAAAAAAAAjQ/biM6qiO70twEJzGkhxXuhRYSZsewLZo-gCPcBGAYYCw/s1600/1%2B%252810%2529.png)](https://3.bp.blogspot.com/-R_8QvO00JWA/XMRR7EBqXaI/AAAAAAAAAjQ/biM6qiO70twEJzGkhxXuhRYSZsewLZo-gCPcBGAYYCw/s1600/1%2B%252810%2529.png)

6. It will ask to save your work before restarting the server. Click on **OK** button.

[![](https://1.bp.blogspot.com/-6fRcYu-QWV8/XMRR7Sr0iBI/AAAAAAAAAjE/RmQr1uC8vkA1w4iNfy8JRfD4ESO2yaQlQCPcBGAYYCw/s1600/1%2B%252811%2529.png)](https://1.bp.blogspot.com/-6fRcYu-QWV8/XMRR7Sr0iBI/AAAAAAAAAjE/RmQr1uC8vkA1w4iNfy8JRfD4ESO2yaQlQCPcBGAYYCw/s1600/1%2B%252811%2529.png)

7. Close all open console and click on “**Restart Now**” button to restart the server.

[![](https://3.bp.blogspot.com/-RC7pyJBmVgY/XMRR78P9XtI/AAAAAAAAAi8/CXGWpiIj1goREMNqxGvlLYoV4pDq1GC_QCPcBGAYYCw/s1600/1%2B%252812%2529.png)](https://3.bp.blogspot.com/-RC7pyJBmVgY/XMRR78P9XtI/AAAAAAAAAi8/CXGWpiIj1goREMNqxGvlLYoV4pDq1GC_QCPcBGAYYCw/s1600/1%2B%252812%2529.png)

8. After the restart, we are going to login to the member server with the credential of the domain administrator.

[![](https://2.bp.blogspot.com/-0ulXLbZRh1s/XMRR8eRvqSI/AAAAAAAAAjQ/NLmizSVYyD0SCbORK5BUIKuGMKOBfPLwwCPcBGAYYCw/s1600/1%2B%252813%2529.png)](https://2.bp.blogspot.com/-0ulXLbZRh1s/XMRR8eRvqSI/AAAAAAAAAjQ/NLmizSVYyD0SCbORK5BUIKuGMKOBfPLwwCPcBGAYYCw/s1600/1%2B%252813%2529.png)

9. Once you login to the server, open server manager console. Click on “**local server**“. Now you can see our windows server 2019 is part of **mylab.local** domain.

[![](https://4.bp.blogspot.com/-GFfpCRj8Cn0/XMRR8bum3hI/AAAAAAAAAi8/cocsOAPXDG8RJs8JarJXxX8ghjj9g-zMACPcBGAYYCw/s1600/1%2B%252814%2529.png)](https://4.bp.blogspot.com/-GFfpCRj8Cn0/XMRR8bum3hI/AAAAAAAAAi8/cocsOAPXDG8RJs8JarJXxX8ghjj9g-zMACPcBGAYYCw/s1600/1%2B%252814%2529.png)

[![](https://4.bp.blogspot.com/-IkJQsz1wYbc/XMRR8vOwMLI/AAAAAAAAAi8/bmkbYNahnmAYP4KulLHH7VNYFDj3EkPVgCPcBGAYYCw/s1600/1%2B%252815%2529.png)](https://4.bp.blogspot.com/-IkJQsz1wYbc/XMRR8vOwMLI/AAAAAAAAAi8/bmkbYNahnmAYP4KulLHH7VNYFDj3EkPVgCPcBGAYYCw/s1600/1%2B%252815%2529.png)

10. On ws2k19-dc01, Open “**Active Directory Users and Computers**” console from server manager console. Expand **mylab.local** domain, expand and click on “**Computers**” container.

Here you can see the computer account of the member server “**ws2k19-srv01**“.

[![](https://3.bp.blogspot.com/-BVWtcJfsPDs/XMRR9MP0i1I/AAAAAAAAAjE/VeKYFjzg_j0PqMGdwcGTR7zOIjior0F5QCPcBGAYYCw/s1600/1%2B%252816%2529.png)](https://3.bp.blogspot.com/-BVWtcJfsPDs/XMRR9MP0i1I/AAAAAAAAAjE/VeKYFjzg_j0PqMGdwcGTR7zOIjior0F5QCPcBGAYYCw/s1600/1%2B%252816%2529.png)