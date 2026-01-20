HOW TO CHANGE THE MAC ADDRESS IN KALI LINUX USING MACCHANGER?

When you are anonymizing your system for penetration testing there are a number of steps you follow. At some point, you also change or fake your mac address so your original device network card’s hardware MAC address is hidden. To do so you can use a tool

macchanger

which is already present in Kali Linux. If you are using a penetrating testing distro like a parrot or kali it is already present in it, so right now we will give priority to only penetration testing operating systems as the majority of users is there only. But still, if you need you can clone the repo from GitHub you can use this link of

macchangerChange the Mac Address in Kali Linux Using Macchanger

Change random mac address:

First lets change network card’s hardware MAC address to a random address. First, we will find the MAC address of the

eth0

network interface. To do this we execute macchanger with an option -s and an argument eth0.

macchanger -s eth0
Now the network interface you are about to change a MAC address should be turned off before changing the mac address. Use

ifconfig command

to turn off your network interface:

ifconfig eth0 down
Now we can change the MAC address of the hardware by using the command

macchanger -r eth0
Once you have executed the command you can finally turn your network interface up

ifconfig eth0 up
Now you can display your MAC by using:

macchanger -s eth0
Change specific MAC address:

You can use MAC changer to change MAC of your choice follow the commands

~ ifconfig eth0 down
~ macchanger -m 00:d0:70:00:20:69 eth0
~ ifconfig eth0 up
~ macchanger -s eth0

Follow the same sequence as we did for random change, the only difference is that this time you have your specific MAC address with you. Use -l option to find a MAC address prefix of a specific hardware vendor:

~macchanger -l
