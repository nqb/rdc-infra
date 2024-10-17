$glpi_agent_ver = "1.1.0"
$firefoxesr_ver = "128.3.1"
$thunderbird_ver = "115.12.2"
$element_ver = "1.11.80"

Write-Output "Install latest version of Chocolatey"
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

Write-Output "Install GLPI agent $glpi_agent_ver and send FIRST inventory"
choco install glpi-agent -y --version $glpi_agent_ver --install-arguments="SERVER=https://glpi.rennesducompost.fr/ TAG=InstalledByChocolatey RUNNOW=1"

Write-Output "Install Firefox ESR $firefoxesr_ver"
choco install firefoxesr -y --version $firefoxesr_ver

Write-Output "Install Thunderbird $thunderbird_ver"
choco install thunderbird -y --version $thunderbird_ver

Write-Output "Install Element $element_ver"
choco install element -y --version $element_ver

Write-Output "Install latest version of common softwares"
choco install vlc 7zip okular pdfsam libreoffice-still -y