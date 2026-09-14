# Windows-AD-Bitlocker-key-to-Passwordstate
We all know it and we all hate it. Managing bitlocker keys is quiet the annoying thing to do. Even the key is directly pushed to the AD, you newer know if it really worked if you don´t check it afterwards. And looking it up in Microsofts amazing UI, well...
This is why I wrote this Powershell scripts that reads out the Bitlocker key from an Windows Active Directory and pushes it into Passwordstate. While doing so, it checks if all the PC´s in your AD actually have an Bitlocker key. The script will send an Email afterwards with its findings.

## Requirements
* Windows Server with Active Directory
* Passwordstate 9+
* SMTP Email-Server

## Setup
