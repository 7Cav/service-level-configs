#Restart Private Servers - Training 1 - 4
Net Stop Arma3Training1
Net Stop Arma3Training2
Net Stop Arma3Training3
Net Stop Arma3Training4
Write-Output "Scheduled restart Started on: $(Get-Date)"
Write-Output "For Training Servers"
Start-Sleep -s 15
Net Start Arma3Tact1
Start-Sleep -s 5
Net Start Arma3Tact2
Start-Sleep -s 5
Net Start Arma3Tact3
Start-Sleep -s 5
Net Start Arma3Tact4