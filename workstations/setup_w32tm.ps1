Set-Service w32time -startuptype automatic
Start-Service w32time
w32tm /config /manualpeerlist:"time.windows.com" /syncfromflags:manual /reliable:YES /update
