$username = Read-Host
$password = Read-Host -AsSecureString
New-LocalUser -Name "$username" -Password $password -ErrorAction stop
Add-LocalGroupMember -Group "Utilisateurs" -Member "$username" -ErrorAction stop