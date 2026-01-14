[Django](https://www.djangoproject.com/) is a powerful tool that helps developers build websites quickly and easily using Python. This web framework allows you to manage the development process, including handling user accounts and making web applications more organized.

In short, Django is widely used because it facilitates and simplifies complex tasks and all kinds of web-based projects.

This is a comprehensive guide for you on how to install and set up the Django on CentOS 9 system. Also, read [How to Install Django on Debian 12](https://greenwebpage.com/community/how-to-install-django-on-debian-12/).

## **How to Install Django on CentOS 9?**

This article will focus on the following topics:

- How to Set Up Prerequisites for Django on CentOS 9?
- How to Install Django via “pip3” on CentOS 9?
- How to Create a Django Project on CentOS 9?
### **How to Set Up Prerequisites for Django on CentOS 9?**

Utilizing the following commands will install the necessary dependencies (i.e. Python3 and pip) for Django on your CentOS 9 machine.

**Step 1: Update the CentOS’s Cache Files**

First, ensure that your CentOS has the latest versions of the available packages. To do this, execute the command to refresh and update your CentOS package files:

| sudo dnf update |
| --------------- |

![](http://greenwebpage.com/community/wp-content/uploads/2024/06/word-image-11677-1.png)

This command will fetch and install the newest package files, libraries, and dependencies.

**Step 2: Install Python3 and Python3-pip**

The Django package requires python3 and python3-pip. To install these packages on your CentOS 9, run the mentioned-below command:

|sudo dnf install python3 python3-pip -y|
|---|

![](http://greenwebpage.com/community/wp-content/uploads/2024/06/word-image-11677-2.png)

![](http://greenwebpage.com/community/wp-content/uploads/2024/06/word-image-11677-3.png)

When the installation of Python 3 and Python 3-pip is complete, you will see a confirmation message (i.e. Complete!) on your CentOS terminal.

**Step 3: Verify Python 3 and pip installation**

Through the below command, you can check the installed version of Python3 and Python3-pip:

|python3 -V && pip3 -V|
|---|

![](http://greenwebpage.com/community/wp-content/uploads/2024/06/word-image-11677-4.png)

Currently, we have Python 3.9.19 and pip 21.3.1 on our CentOS 9 machine.

### **How to Install Django via “pip3” on CentOS 9?**

You can easily set up the Django package on your CentOS 9 via the “pip”. Here are the straightforward commands.

**Step 1: Install Django via “pip3”**

Upon successful installation of the required dependencies (i.e., Python 3 and pip), install the Django package using the following command:

|sudo pip3 install Django|
|---|

![](http://greenwebpage.com/community/wp-content/uploads/2024/06/word-image-11677-5.png) ![](http://greenwebpage.com/community/wp-content/uploads/2024/06/word-image-11677-6.png)

As mentioned above, the command installed Django on your CentOS 9 system using pip3.

**Step 2: Check Django Version**

The Django installation can be confirmed using the following version command:

|django-admin --version|
|---|

![](http://greenwebpage.com/community/wp-content/uploads/2024/06/word-image-11677-7.png)

If you see a version number such as 4.2.13, it confirms that Django has been installed on your CentOS 9 system.

### **How to Create a Django Project on CentOS 9?**

These stepwise commands will initiate and create a new Django project on your CentOS 9 system.

**Step 1: Create a Django project**

Once you have successfully installed the Django package, let’s create a new Django project, such as “greenWP”:

|django-admin startproject greenWP|
|---|

![](http://greenwebpage.com/community/wp-content/uploads/2024/06/word-image-11677-8.png)

You can specify any name of your choice for the Django project.

**Step 2: Initialize Django database migrations**

Next, navigate into your Django project directory (i.e. greenWP) and run the command to initialize database migrations:

|cd greenWP && python3 manage.py migrate|
|---|

![](http://greenwebpage.com/community/wp-content/uploads/2024/06/word-image-11677-9.png)

This command will apply all required migrations such as **admin**, **auth**, **contenttypes**, and **sessions**, for your Django project.

**Step 3: Create a superuser for Django Admin**

For managing the Django admin interface, create a superuser with the command:

|python3 manage.py createsuperuser|
|---|

![](http://greenwebpage.com/community/wp-content/uploads/2024/06/word-image-11677-10.png)

When the above command runs, it will ask you to provide a username, a valid email address, and a strong password for managing the Django admin interface.

**Step 4: Run the Django development server**

Finally, your Django development server is ready to start. Operate the command to initiate the Django development server:

|python3 manage.py runserver|
|---|

![](http://greenwebpage.com/community/wp-content/uploads/2024/06/word-image-11677-11.png)

The above command will provide the link to access the Django development server. For instance, the default server runs at “http://127.0.0.1:8000”.

**Step 5: Access your Django application**

To access your Django application, open your web browser and paste the server link, such as http://127.0.0.1:8000, to check if your Django application is running properly.

|127.0.0.1:8000|
|---|

![](http://greenwebpage.com/community/wp-content/uploads/2024/06/word-image-11677-12.png)
___
### Fix Issue's 
#### Allowed Host
```bash
nano settings.py 

# Fix 
ALLOWED_HOSTS = ["*"]
or 
# Pass in the project ip
ALLOWED_HOSTS = ['192.168.111.139', EMAIL ]
```

### **Option 1: Use Node.js 22 from AppStream (Recommended if you don't _need_ Node.js 16)**

This is often the simplest solution if you don't have a specific requirement for Node.js 16.

1. **Disable/Remove the NodeSource Repository:** You need to prevent your system from seeing the Node.js 16 package.
- **Find the repository file:** Look in `/etc/yum.repos.d/` (or `/etc/dnf/repos.d/` on some systems) for a file related to NodeSource, such as `nodesource-nodejs.repo` or similar.
- **Disable the repository:** The safest way to disable it is using `dnf config-manager`:
```bash
sudo dnf config-manager --set-disabled nodesource-nodejs
```
(Replace `nodesource-nodejs` with the actual ID of the NodeSource repository if it's different. You can find the repository ID by running `dnf repolist all` and looking for the NodeSource entry.)

Alternatively, you can edit the `.repo` file directly and change `enabled=1` to `enabled=0`.
```bash 
sudo dnf clean all
```
**Install `npm`:** Now try installing `npm` again. It should now only consider the Node.js 22.x.x provided by `appstream`.
```bash
sudo dnf install npm
```
Upgrade Nodejs
```bash
dnf module install nodejs:<stream>
```
For example, to install Node.js 18:
```bash
dnf module install nodejs:18/common
```

Install and Configure TailwindCss:  [[TailwindCss]]

