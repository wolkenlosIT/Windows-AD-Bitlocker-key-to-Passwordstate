 #Variables
$APIKey = "1234" # Passwordstate API key
$PasswordstateURL = "https://passwordstate.yourhomelab.lan:9119" # Passwortstate URL
$OUtoScan = "OU=Laptops,OU=Enduserdevices,DC=yourhomelab,DC=lan" # OU in your AD with you enduser devices
$ListID = "49" # list id of the Passwordstate Passwordlist you want to push the keys into
$username = ""
$bitlockerMissingCounter = 0
$mailflag = "1"     #set to 1 to active mail
$EmailTo = "administrator@yourhomelab.lan"       # Recipient email address
$EmailFrom = "bitlocker@yourhomelab.lan"     # Sender email address
$EmailSubj = "Bitlocker Keys missing"         # Letter Subject
$EmailBody = "The following computers have no Bitlocker key in the AD: `n  *******"            # And body
$EmailSmtpSrv = "smtp.yourhomelab.lan"  # your smtp relay server

#Begin Script

#Construct API URL for use later in script
$APIURL = $PasswordstateURL + "/api/passwords"
 

#Find Computerss in OU
$computers = (Get-ADComputer -Filter 'ObjectClass -eq "computer"' -SearchBase $OUtoScan).Name



 

#Cycle through the array and add each pc with bitlocker to Passwordstate
foreach ($computer in $computers)
{
        $pwid = ""
        $searchresult = ""
        $pwstateBitlocker = ""
        $pwstatePWID = ""
        $pw = ""

        #get bitlocker key from AD
        $objComputer = Get-ADComputer $computer
        $Bitlocker_Object = Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $objComputer.DistinguishedName -Properties 'msFVE-RecoveryPassword'
        $pw = ($Bitlocker_Object).'msFVE-RecoveryPassword'


            #check if bitlocker field is empty in AD
            if([string]::IsNullOrEmpty($pw))
            {
            $EmailBody = $EmailBody + "`n" + $computer
            $bitlockerMissingCounter = $bitlockerMissingCounter + 1
            }


            else
            {
                $PasswordstateUrlSearch = $PasswordstateURL+'/api/searchpasswords/'+$ListID+'?title='+$computer+'&PreventAuditing=true'
                $searchresult = Invoke-Restmethod -Method GET -Uri $PasswordstateUrlSearch -Header @{ "APIKey" = $APIKey } -ErrorAction SilentlyContinue
        
                if ($searchresult -eq "")
                {

                #JSON data for the object
                $Body = @{
                        PasswordListID = $ListID
                        Title = $computer
                        UserName = $username
                        password = $pw
                        APIKey = $APIKey
                        }
        
                # Convert Array to Json
                $jsonData = $Body | ConvertTo-Json

 

                #Add bitlocker to Passwordstate
                $result = Invoke-Restmethod -Method POST -Uri $APIURL -ContentType "application/json" -Body $jsonData

                }
                else
                {

                $pwstateBitlocker = ($searchresult).password
                $pwstatePWID = ($searchresult).PasswordID



                        if ($pwstateBitlocker -ne $pw)
                        {         
 


                            $Body = @{
                            PasswordListID = $ListID
                            PasswordID = $pwstatePWID
                            Title = $computer
                            UserName = $username
                            password = $pw
                            APIKey = $APIKey
                            }
        
                            # Convert Array to Json
                            $jsonData = $Body | ConvertTo-Json

 

                            #Update bitlocker in Passwordstate
                            $result = Invoke-Restmethod -Method PUT -Uri $APIURL -ContentType "application/json" -Body $jsonData

                        }

                 }

             }

}
#End cycle


#Begin clean up in Passwordstate of retired AD computer objects
        
        $searchresult = ""

        $PasswordstateUrlClean = $PasswordstateURL+'/api/passwords/'+$ListID+'?QueryAll&PreventAuditing=true'
        $cleanresult = Invoke-Restmethod -Method GET -Uri $PasswordstateUrlClean -Header @{ "APIKey" = $APIKey } #-ErrorAction SilentlyContinue

        $cleaner = ($cleanresult).Title

        $adcomputers = (Get-ADComputer -Filter 'ObjectClass -eq "computer"' -SearchBase $OUtoScan).Name     


       foreach ($clean in $cleaner)
       {
            

                   if ($adcomputers.Contains($clean) -eq $false)
                   {
                   $PasswordstateUrlSearch = $PasswordstateURL+'/api/searchpasswords/'+$ListID+'?title='+$clean+'&PreventAuditing=true'
                   $searchresult = Invoke-Restmethod -Method GET -Uri $PasswordstateUrlSearch -Header @{ "APIKey" = $APIKey } -ErrorAction SilentlyContinue
                   $delsearch = ($searchresult).PasswordID
                   
                   $PasswordstateUrlDelete = $PasswordstateURL+'/api/passwords/'+$delsearch+'?MoveToRecycleBin=false'
                   Invoke-Restmethod -Method Delete -Uri $PasswordstateUrlDelete -Header @{ "APIKey" = $APIKey }
                   }

       }
#End clean up

#Send mail if there is no bitlocker key for an AD object


if (($mailflag -eq "1") -and ($bitlockerMissingCounter -gt 0))
{
$EmailBody = $EmailBody + "`n  ******* `nAnzahl: " + $bitlockerMissingCounter
Send-MailMessage -To $EmailTo -From $EmailFrom -Subject $EmailSubj -Body $EmailBody -SmtpServer $EmailSmtpSrv
}
