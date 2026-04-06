One of the best features that make Windows server to shine in the Enterprise sphere is Active Directory. This single Sign-on product that seamlessly and easily integrates with most of Microsoft products makes user management among other tasks quite easy and fun. This guide is about how to install Active Directory Domain Services on a newly installed Windows server 2019.

### Step 1: Open Server Manager

Hit “Windows” key on your keyboard and type “Server Manager” to search for the application. Once it is open as illustrated by the figure below, let us now proceed to the next step of installing Active Directory Domain Services.

### Step 2: Add Roles and Features

Right-click on “Manage” on the “Server Manager” window and choose “Add Roles and Features“. This will open the “Add Roles and Features Wizard” which ushers us to the part where we install Active Directory Domain Services. Click on next.
![[Dashboard.jpeg]]
![[beforeYouBegin.jpeg]]
### Step 3: Installation Type

On the “Installation Type”, leave “Role-based or feature-based installation” radio button selected and click on next.
![[SelectInstallType.jpeg]]

### Step 4: Server Selection
On this stage titled “Select destination server“, select the server you are to install AD DS and click next. I am going to choose my local server.
![[SelectDServer.jpeg]]
### Step 5: Server Roles
The previous step will lead you to the next page as shown below. Here, you will see many options with square checklist box against them. As you can guess, we are going to choose “Active Directory Domain Services“.
![[SelectServerRoles.jpeg]]
### Step 6: Add Features
Immediately you choose that option, a new part comes up. On the page, just click on “Add Features” tab and hit “Next“
![[AddFeaures.jpeg]]

### Step 7: Select Features
On the next page after Step 6 titled “Select features“, just hit “Next” to lead you to installations of AD DS.
![[SeletFeatures.jpeg]]
### Step 8: AD DS
As shown below, you will be presented with the next page titled “Active Directory Domain Services“. Here, click on “Next“
![[DomainService.jpeg]]
### Step 9: Confirm your selections
The next page is about Confirming what you need to install before actually installing them. If you are sure about what you have chosen, click on install. You can optionally choose the option that restarts the server whenever required. Click on close once it is done.
![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C5612AQGaMr-EWLk6oA/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1626282100869?e=2147483647&v=beta&t=8KwQNzj13GgzicgZ50sKHp2A-r6aaTdWdhYoVp_ErtE)

### Step 10: Promote to Domain Controller

After you have finished installing Active Directory Domain Services, the last step is to promote it to a Domain Controller. Go over to Server Manager where you will notice a yellow exclamation notification beside the “Manage” tab as shown below. Click on it and choose “Promote this server to a domain controller“

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C5612AQFfN5Jpkxbihg/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1626282124425?e=2147483647&v=beta&t=jD-FogwjpC5cCqQtzIKk-ugSf3Ok-LImvtyThRBU8uc)

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C5612AQE6MA5SyW4krw/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1626282133482?e=2147483647&v=beta&t=03wjNCFKUu521hoUfR6cW6MpGOPhwXnSQH0Kc1hl_r0)

### Step 11: Add a new Forest

A new window titled “Active Directory Domain Services Configuration Wizard” as shown below will pop up. We are going to Add a new Forest but in case you would wish to do something different in this Step, you are free to choose the other options. Add your organization’s root domain name. Click on “Next” after you pick your choice.

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C5612AQHpTfKjS_a0gg/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1626282163473?e=2147483647&v=beta&t=-LO_xIzuJATyTf9RbgD9842x-lpVUbwq_9kbHCxDXag)

### Step 12: Domain Controller Options

On the Domain Controller options, leave the defaults checked and input your password. After that, click “Next“.

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C5612AQGo6IlO50VNXA/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1626282181903?e=2147483647&v=beta&t=4HRflvQlXmzp_ajXjKCJ_bTwJJfRFv8Gc25qSYd_GWo)

### Step 13: DNS Options

On the next page ( DNS Options ), you will probably see an error on top with the words “A delegation for this DNS server cannot be created because the authoritative parent zone nameserver cannot be found”. Ignore it and click “Next“

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C5612AQGnglmVKzrcSQ/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1626282202803?e=2147483647&v=beta&t=yj-tAODs0zKndkVNA4rsy1yv_1RellMzCYmknsWDk9A)

### Step 14: NetBIOS domain name

On the next page, leave the NetBIOS domain name as default or you can change it as long as it is not longer than 15 characters. Click “Next” after that.

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C5612AQFkN7X7dJtyrw/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1626282221026?e=2147483647&v=beta&t=tv11SzMZHvrMbNenbXSKCoJeYLcm2-L4_Tywr6Ox6bA)

### Step 15: Paths

Leave paths as default and click “Next” as shown below.

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C5612AQEe-71TPVUKzg/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1626282243048?e=2147483647&v=beta&t=Z4ak3WYzVQaATH9PRBFL2RsCUnditOcRxoqSxBUD9qo)

### Step 16: Review Selections

In this step, the server allows you to review what you have done so far. If you are good with the selections you have done. Hit “Next“.

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C5612AQGFWJ_E3YqCSg/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1626282265274?e=2147483647&v=beta&t=p5xISX3TlqbO8rXrqmkwN1azUIBGEfGlkOosQ-QGyS8)

### Step 17: Prerequisites Check

In this step prerequisites will be validated before Active Directory Domain Services is installed. If you get any errors here, please look at it and fix anything in the previous steps. If all is okay, click “Install“.

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C5612AQHkUGVJmSJohw/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1626282288984?e=2147483647&v=beta&t=lnjD1GoEZR5fg_Y2ELyOCsc-LQ_G__d6rFeDrkP5sZ4)

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C5612AQGVlAN5h0rHFQ/article-inline_image-shrink_400_744/article-inline_image-shrink_400_744/0/1626282402634?e=2147483647&v=beta&t=X9tci6KXvcpNu5MpSQ6BAPPI22RrhblJRHQLDMDBlzg)

After that, the Server will reboot and you can then log into the Domain with the credentials you set in Step 12 as shown below:

![No alt text provided for this image](https://media.licdn.com/dms/image/v2/C5612AQF50zWObJlebA/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1626282451546?e=2147483647&v=beta&t=Ck0cVVsGgztsc0l8pHNLPdCwx6KA-Uj1wZdBM7bw6_Y)