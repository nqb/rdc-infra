write-output "Timezone"
Get-Timezone

write-output "NTP config"
w32tm /query /status

write-output "Get activation state"
Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | 
where { $_.PartialProductKey } | select Description, LicenseStatus

write-output "Get local user"
Get-LocalUser

write-output "Get Network connection profile"
Get-NetConnectionProfile
