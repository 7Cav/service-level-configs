#Restart Public Server - Tactical Realism 1
Net Stop Arma3Tact1
Write-Output "Scheduled restart Started on: $(Get-Date)"
Write-Output "For Instance Arma3Tact1"
Start-Sleep -s 5
Net Start Arma3Tact1