# Source: https://developer.hashicorp.com/packer/docs/communicators/winrm
Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Ignore

# Don't set this before Set-ExecutionPolicy as it throws an error
$ErrorActionPreference = "stop"

# start WinRM service (necessary to use Remove-Item)
Start-Service WinRM

# Remove HTTP listener
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse

$hostname = hostname

# Create a self-signed certificate to let ssl work
$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "$hostname"
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

# WinRM
write-output "Setting up WinRM"

# Configure WinRM to allow unencrypted communication, and provide the
# self-signed cert to the WinRM listener.
cmd.exe /c winrm set "winrm/config/service" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/client" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/client/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{CredSSP="true"}'
cmd.exe /c winrm set "winrm/config/listener?Address=*+Transport=HTTPS" "@{Port=`"5986`";Hostname=`"$hostname`";CertificateThumbprint=`"$($Cert.Thumbprint)`"}"

# apply all changes and do a lot of config
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting
# SkipNetworkProfileCheck due to current network used
Enable-PSRemoting –SkipNetworkProfileCheck -Force

# Add firewall rule to allow WinRM on HTTP
New-NetFirewallRule -Displayname 'WinRM - Powershell remoting HTTPS-In' -Name 'WinRM - Powershell remoting HTTPS-In' -Profile Any -LocalPort 5986 -Protocol TCP

