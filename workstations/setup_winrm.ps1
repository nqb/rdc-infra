# Source: https://developer.hashicorp.com/packer/docs/communicators/winrm
Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Ignore

# Don't set this before Set-ExecutionPolicy as it throws an error
$ErrorActionPreference = "stop"

# start + do a lot of stuff
# see https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting
Enable-PSRemoting –SkipNetworkProfileCheck -Force

# Remove HTTP listener
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse

$hostname = hostname

# # Create a self-signed certificate to let ssl work
$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "$hostname"
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

write-output "Configure WinRM to allow unencrypted communication through HTTPS"

# Hack to avoid next command to fail because network profile is public
Set-NetConnectionProfile -NetworkCategory Private

cmd.exe /c winrm set "winrm/config/service" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/client" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/client/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{CredSSP="true"}'
cmd.exe /c winrm set "winrm/config/listener?Address=*+Transport=HTTPS" "@{Port=`"5986`";Hostname=`"$hostname`";CertificateThumbprint=`"$($Cert.Thumbprint)`"}"

# Switch back to public
Set-NetConnectionProfile -NetworkCategory Public

# Add firewall rule to allow WinRM on HTTPS
New-NetFirewallRule -Displayname 'WINRM-HTTPS-In-TCP-Any' -Name 'WINRM-HTTPS-In-TCP-Any' -Profile Any -LocalPort 5986 -Protocol TCP

