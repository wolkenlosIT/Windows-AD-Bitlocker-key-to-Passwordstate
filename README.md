# Windows-AD-Bitlocker-key-to-Passwordstate
We all know it and we all hate it. Managing bitlocker keys is quiet the annoying thing to do. Even if the key is directly pushed to the AD, you newer know if it really worked if you don´t check it afterwards. And looking it up in Microsofts amazing UI, well...
This is why I wrote this Powershell scripts that reads out the Bitlocker key from an Windows Active Directory and pushes it into Passwordstate. While doing so, it checks if all the PC´s in your AD actually have an Bitlocker key. The script will send an Email afterwards with its findings. It will also clean up the password list and remove PCs that are no longer in the AD.

## Requirements
* Windows Server with Active Directory
* Passwordstate 9+
* SMTP Email-Server

## Setup
1. Log into your Passwordstate and add a new list for your bitlocker keys
2. Click on the list add press "Permalink". Look at the URL. There should be plid=YOUR_LIST_ID. Copy this id. We will need it later.
3. Right click on the the new list and press "Edit Properties"
4. Click on "API Keys & Settings" and press "Generate Key"
![APItoken](https://github.com/wolkenlosIT/Windows-AD-Bitlocker-key-to-Passwordstate/blob/main/pwstateapikey.jpg)
5. Copy the Key, scroll down and Save!

6. Log into your Windows AD Server
7. Place the Script on the Server
8. Open it with the Editor. You have to edit the following variables: $APIKey, $PasswordstateURL, $OUtoScan, $ListID, $EmailTo, $EmailFrom, $EmailSubj, $EmailBody, $EmailSmtpSrv
9. Save and close
10. The script should work now.

Optional
11. To make it run automatically open the the Task Scheduler and make the scheduler run the script how often you like.
The user running the script needs needs permission to read the Active Directory

