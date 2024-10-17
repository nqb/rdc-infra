# Configure WinRM for PSRemoting through HTTPS
Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Ignore

# Don't set this before Set-ExecutionPolicy as it throws an error
$ErrorActionPreference = "stop"

# start + do a lot of stuff
# see https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting
Enable-PSRemoting -SkipNetworkProfileCheck -Force

# Remove HTTP listener
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse

$hostname = hostname

# # Create a self-signed certificate to let ssl work
$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "$hostname"
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

Write-output "Configure WinRM to allow unencrypted communication through HTTPS"

# Hack to avoid next command to fail because network profile is public
Set-NetConnectionProfile -NetworkCategory Private

# Change WinRM config
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\Auth\CredSSP -Value $true

Set-Item -Path WSMan:\localhost\Client\Basic -Value $true
Set-Item -Path WSMan:\localhost\Client\AllowUnencrypted -Value $true

Set-WSManInstance -ResourceURI winrm/config/listener -SelectorSet @{address="*";transport="https"} -ValueSet @{Hostname="$hostname"}

# Switch back to public
Set-NetConnectionProfile -NetworkCategory Public

# Add firewall rule to allow WinRM on HTTPS
New-NetFirewallRule -Displayname 'WINRM-HTTPS-In-TCP-Any' -Name 'WINRM-HTTPS-In-TCP-Any' -Profile Any -LocalPort 5986 -Protocol TCP
