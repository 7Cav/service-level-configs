#Instance Configuration Training Server
$configPath = 'https://raw.githubusercontent.com/7Cav/service-level-configs/master/mtreck/squad/training/training.json'
$configJson = (New-Object System.Net.WebClient).DownloadString($configPath) | ConvertFrom-Json
#
$instanceId = $configJson.server.env.SERVER_ID
$serverName = $configJson.server.env.SERVER_NAME
$ipaddr = $configJson.server.env.IP_ADDRESS
$port = $configJson.server.env.PORT
$Qport = $configJson.server.env.QUERY_PORT
$random = $configJson.server.env.RANDOM
$FixedMaxPlayers = $configJson.server.env.MAX_PLAYERS
$TickRate = $configJson.server.env.FIXEDTICKRATE
$PreferPreProcessor = $configJson.server.env.CPU_AFFINITY
$Parameters = $configJson.server.env.PARAMETERS
$scripts = $configJson.server.env.SCRIPTS_REL_PATH
$configDir = $configJson.server.env.SQUAD_CONFIG_PATH
$steamCMDdir = $configJson.server.env.STEAM_BASE_PATH
$installDirWorkshop = $configJson.server.env.STEAM_WORKSHOP_PATH
$storePath = $configJson.server.env.STORE_PATH
$installDirSquaddirectory = $configJson.server.env.SQUAD_BASE_PATH
$steamUser = $env:STEAM_USER
$steamPass = $env:STEAM_PASS
# Join Paths and other
$storePath += "training"
$installDirWorkshop = "$storePath\$installDirWorkshop"
$ServiceName = "$instanceId"
$ServiceName += "Updater"

$configDir = "$configDir\$serverName"
$steamCMDdir += "steamcmd.exe"
$serverScripts = "$installDirSquaddirectory\$scripts"
# Remove existing symbolic links
#
Write-Output "Update has started: $(Get-Date) for Service $instanceId - $serverName"

#Stop Firedaemon Service
net stop $instanceId
Start-Sleep -s 5
Write-Output Start-Sleep -s 15

Write-Output "Starting SteamCMD Download and Validate Base Installation"
#login to steamcmd using env variables
$argumentListArray = "+login $steamUser $steamPass "
#update and validate squad base installation
$argumentListArray += "+force_install_dir $installDirSquaddirectory +app_update 393380 validate +quit"

Start-Process -FilePath $steamCMDdir -ArgumentList $argumentListArray -NoNewWindow -Wait

Write-Output "$serverScripts has yet to be assigned in the script"

# Instance parameters
$ipaddrparam = "MULTIHOME=$ipaddr"
$portparam = "Port=$port"
$Qportparam = "QueryPort=$Qport"
$Randomparam = "RANDOM=$random"
$FixedMaxplayersparam = "FIXEDMAXPLAYERS=$FixedMaxPlayers"
$FixedMaxTickRateparam = "FIXEDMAXTICKRATE=$TickRate"
$PreferPreProcessorparam = "PREFERPREPROCESSOR=$PreferPreProcessor"

$compileParams = "$ipaddrparam $portparam $Qportparam $Randomparam $FixedMaxplayersparam $FixedMaxTickRateparam $PreferPreProcessorparam $Parameters"
#[System.Environment]::SetEnvironmentVariable($serverName, $compileParams,[System.EnvironmentVariableTarget]::Machine)
Write-Output "Parameters: $compileParams"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name $serverName -Value $compileParams

Write-Output "Update has finished: $(Get-Date) for $serverName"
#Stop myself if service Firedaemon Service
net stop $ServiceName
[Environment]::Exit(66)