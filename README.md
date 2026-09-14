# Windows-AD-Bitlocker-key-to-Passwordstate
We all know it and we all hate it. Managing bitlocker keys is quiet the annoying thing to do. Even the key is directly pushed to the AD, you newer know if it really worked if you don´t check it afterwards. And looking it up in Microsofts amazing UI, well...
This is why I wrote this Powershell scripts that reads out the Bitlocker key from an Windows Active Directory and pushes it into Passwordstate. While doing so, it checks if all the PC´s in your AD actually have an Bitlocker key. The script will send an Email afterwards with its findings.

## Requirements
* Windows Server with Active Directory
* Passwordstate 9+
* SMTP Email-Server

## Setup
1. Log into your Passwordstate and add a new list for your bitlocker keys
2. Right click on the the new list and press "Edit Properties"
3. Click on "API Keys & Settings" and press "Generate Key"

4. Copy the Key, scroll down and Save!

5. Log into your Windows AD Server
6. Place the Script on the Server
7. Open it with the Editor.
