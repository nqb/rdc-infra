# Generate new cert for 10 years
$hostname = hostname
New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "$hostname" -NotAfter (Get-Date).AddYears(10)

# Display current WMan instance
Get-WSManInstance -ResourceURI winrm/config/listener -SelectorSet @{address="*";transport="https"}

# Remove WMan instance
Remove-WSManInstance -ResourceUri winrm/config/Listener -SelectorSet @{
    Address   = '*'
    Transport = 'https'
}

# Create new WSMan instance with new cert
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force
Set-WSManInstance -ResourceURI winrm/config/listener -SelectorSet @{address="*";transport="https"} -ValueSet @{Hostname="$hostname"}

# Display new WMan instance
Get-WSManInstance -ResourceURI winrm/config/listener -SelectorSet @{address="*";transport="https"}
