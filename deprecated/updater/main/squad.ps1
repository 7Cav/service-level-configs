$ConfigPath = $args[0]
$AutoStart = $args[1]
$logs = $args[2]
$Nuke = $args[3]

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
$modListJson = $configJson.mods
# $scripts = $configJson.server.env.SCRIPTS_REL_PATH
$configDir = $configJson.server.env.SQUAD_CONFIG_PATH
$steamCMDdir = $configJson.server.env.STEAM_BASE_PATH
$installDirWorkshop = $configJson.server.env.STEAM_WORKSHOP_PATH
$storePath = $configJson.server.env.STORE_PATH
$installDirSquaddirectory = $configJson.server.env.SQUAD_BASE_PATH
$steamUser = $env:STEAM_USER
$steamPass = $env:STEAM_PASS
# Join Paths and other
$storePath += "$serverName"
$installDirWorkshop = "$storePath\$installDirWorkshop"
$ServiceName = "$instanceId"
$ServiceName += "Updater"

$configDir = "$configDir\$serverName"
$steamCMDdir += "steamcmd.exe"
# $serverScripts = "$installDirSquaddirectory\$scripts"
# Remove existing symbolic links
#
Write-Output "###"
Write-Output "Update has started: $(Get-Date) for Service $instanceId - $serverName"
Write-Output "###"
#Stop Firedaemon Service
Write-Output "[Notice] Stopping Instance for $instanceId"
Write-Output "[Notice] Error for stopping instance will occur if instance is not currently running"
net stop $instanceId
Start-Sleep -s 5
Write-Output "[Notice] Starting File Removal in \Mods Directory"
$dirp = Get-Item $installDirSquaddirectory\SquadGame\Plugins\Mods\*
foreach ($item in $dirp) {
    Remove-Item -Recurse -Force $item
    Write-Output "Removing $item from \Mods"
}

if ($Nuke -eq $True) {
    Write-Output "###"
    Write-Output "[Warning] -Nuke Parameter was used. all files related to this server instance will be wiped"
    Write-Output "###"
    $dirp = Get-Item $installDirSquaddirectory\*
    foreach ($item in $dirp) {
        Remove-Item -Recurse -Force $item
        Write-Output "Removing from Installation Directory: $item"
    }
    $dirS = Get-Item $installDirWorkshop
    foreach ($item in $dirS) {
        Remove-Item -Recurse -Force $item
        Write-Output "Removing from Store Directory: $item"
    }
}
Write-Output "###"
Write-Output "[Notice] Starting SteamCMD Download and Validate Base Installation"
Write-Output "###"
#login to steamcmd using env variables
$argumentListArray = "+login $steamUser $steamPass +force_install_dir " + $storePath + " "

foreach ($item in $modListJson) {
    $id = $item.app
    $name = $item.name
    if ($id -ne "") {
        $argumentListArray += "+workshop_download_item 393380 $id "
        Write-Output "Found Item_ID: $id ($name)"
    }
    else {
        Write-Output "Blank Workshop Item ID, Skipping"
    }
}
$argumentListArray += "+quit"
Start-Process -FilePath $steamCMDdir -ArgumentList $argumentListArray -NoNewWindow -Wait
Write-Output "###"
Write-Output "[Notice] End of Workshop Items Process"
Write-Output "###"
#update and validate squad base installation
$argumentListArray = "+login anonymous +force_install_dir $installDirSquaddirectory +app_update 403240 validate +quit"
Start-Process -FilePath $steamCMDdir -ArgumentList $argumentListArray -NoNewWindow -Wait
Write-Output "###"
Write-Output "[Notice] End of Base Installation Process"
Write-Output "###"
foreach ($item in $modListJson) {
    $id = $item.app
    $name = $item.name
    if ($id -ne "") {
        New-Item -ItemType Junction -Path "$installDirSquaddirectory\SquadGame\Plugins\Mods\$name" -Target $installDirWorkshop\$id     
        Write-Output "App ID $id added to plugins/mods"
    }
}
#download each item in steamcmd using the app id in the mod list array
Write-Output "[Notice] ServerScripts has yet to be assigned in the script"
if ($Logs -ne $True) {
    Write-Output "[Notice] -logs is being used"
    Write-Output "[Notice] log file management is not currently setup"
}
else {
    Write-Output "[Notice] log file management is not currently setup"
}
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
Write-Output "[Notice] Setting Command Line Parameters: $compileParams"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name $serverName -Value $compileParams

Write-Output "[Notice] Update has finished: $(Get-Date) for $serverName"
if ($AutoStart -eq $True) {
    net start $instanceId
    Write-Output "[Notice] -AutoStart is being used"
    Write-Output "[Notice] Starting $instanceId"
}
else {
    Write-Output "[Notice] -AutoStart was not set, exiting without starting server instance"
}
#Stop myself if service Firedaemon Service
Write-Output "End of Script"
net stop $ServiceName
[Environment]::Exit(66)