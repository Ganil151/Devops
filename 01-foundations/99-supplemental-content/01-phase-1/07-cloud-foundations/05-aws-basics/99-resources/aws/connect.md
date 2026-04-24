![[2019ServerStandard.png]]
![[instanceLab.png]]
![[instanceNetwork.png]]
![[instanceSucces.png]]


GSmash:
Account ID
440744252609


! aws account 
! learn how to set up on the priorities for step 
ec2-3-88-203-166.compute-1.amazonaws.com

Instance ID: 
i-0c4e66b3fe6ac6ed6

Public DNS:
ec2-3-83-157-141.compute-1.amazonaws.com

Password: 
FLSR-Admin: @QFMO-BUp*oumap;GYzzPE;F$K3tSOtn
FLSR-Client: sQgKH(mnkh8yW!vUz@%HMFZgTxA5nOMn

Username: 
Administrator

How to Add Port to Firewall:
New-NetFirewallRule -DisplayName "Finishline" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3389 -Profile Any -Enabled True | Out-Null

Verify displayName:
 Get-NetFirewallRule -DisplayName "Finishline"

Verify Port:
Get-NetFirewallRule | Where-Object {$_.LocalPort -eq 3389}

Test the Connection:
Test-NetConnection -ComputerName <EC2_Public_IP> -Port 3389

Test-NetConnection -ComputerName <target_IP_address> -Port <port_number> -InformationLevel Detailed

Test-NetConnection -ComputerName 3.138.204.136 -Port 3389 -InformationLevel Detailed



Test:
New-NetFirewallRule -DisplayName "Finishline (TCP)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3389 -Profile Any -Enabled True | Out-Null


Troubleshooting an RDP connection with EC2 Rescue Tool:
	![Link](https://youtu.be/WFsWQrm1qi0)