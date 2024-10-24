$driverPath = "C:\Windows\Setup\Scripts\hpygid24_v4.inf"
$driverName = "HP Envy Photo 6200 series PCL-3"
$printerName = "IMP001"
$printerPort = "172.16.71.191"
$printerPortName = "TCPPort:172.16.71.191"

if ($null -eq (Get-Printer -name $printerName)) {
    # Check if driver is not already installed
    if ($null -eq (Get-PrinterDriver -name $driverName -ErrorAction SilentlyContinue)) {
      # Add the driver to the Windows Driver Store
      pnputil.exe /a $driverPath

      # Install the driver
      Add-PrinterDriver -Name $driverName
    } else {
      Write-Warning "Printer driver already installed"
    }

    # Check if printerport doesn't exist
    if ($null -eq (Get-PrinterPort -name $printerPortName)) {
      # Add printerPort
      Add-PrinterPort -Name $printerPortName -PrinterHostAddress $printerPort
    } else {
      Write-Warning "Printer port with name $($printerPortName) already exists"
    }

    try {
      # Add the printer
      Add-Printer -Name $printerName -DriverName $driverName -PortName $printerPortName -ErrorAction stop
    } catch {
      Write-Host $_.Exception.Message -ForegroundColor Red
      break
    }

    Write-Host "Printer successfully installed" -ForegroundColor Green
} else {
 Write-Warning "Printer already installed"
}