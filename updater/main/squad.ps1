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
$scripts = $configJson.server.env.SCRIPTS_REL_PATH
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
$serverScripts = "$installDirSquaddirectory\$scripts"
# Remove existing symbolic links
#
Write-Output "Update has started: $(Get-Date) for Service $instanceId - $serverName"

#Stop Firedaemon Service
net stop $instanceId
Start-Sleep -s 5
Write-Output Start-Sleep -s 15
$dirp = Get-Item $installDirSquaddirectory\SquadGame\Plugins\Mods\*
foreach($item in $dirp)
{
Remove-Item -Recurse -Force $item
Write-Output "Removing $item from \Mods"
}

if ($Nuke -eq $True) {
    Write-Output "!!!!!!!!!!"
    Write-Output "Warning, -Nuke Parameter was used. all files related to this server instance will be wiped"
    Write-Output "!!!!!!!!!!"
    $dirp = Get-Item $installDirSquaddirectory\*
    foreach ($item in $dirp)
    {
    Remove-Item -Recurse -Force $item
    Write-Output "Removing from Installation Directory: $item"
    }
    $dirS = Get-Item $installDirWorkshop
    foreach ($item in $dirS)
    {
    Remove-Item -Recurse -Force $item
    Write-Output "Removing from Store Directory: $item"
    }
}
Write-Output "Starting SteamCMD Download and Validate Base Installation"

#login to steamcmd using env variables
$argumentListArray = "+login $steamUser $steamPass +force_install_dir "+$storePath+" "

foreach($item in $modListJson) 
{
    $id = $item.app
    $name = $item.name
    if ($id -ne "")
    {
    $argumentListArray += "+workshop_download_item 393380 $id "
    Write-Output "Found Item_ID: $id ($name)"
    } else {
    Write-Output "Blank Workshop Item ID, Skipping"
    }
}
#update and validate squad base installation
$argumentListArray += "+force_install_dir $installDirSquaddirectory +app_update 393380 validate +quit"

Start-Process -FilePath $steamCMDdir -ArgumentList $argumentListArray -NoNewWindow -Wait

foreach($item in $modListJson) 
{
   $id = $item.app
   $name = $item.name
   if ($id -ne "")
   {
      New-Item -ItemType Junction -Path "$installDirSquaddirectory\SquadGame\Plugins\Mods\$name" -Target $installDirWorkshop\$id     
      Write-Output "App ID $id added to plugins/mods"
    }
}
#download each item in steamcmd using the app id in the mod list array
Write-Output "$serverScripts has yet to be assigned in the script"
if ($Logs -ne $True) {
    Write-Output "log file management is not currently setup"
}
else 
    {
Write-Output "log file management is not currently setup"
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
Write-Output "Parameters: $compileParams"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name $serverName -Value $compileParams

Write-Output "Update has finished: $(Get-Date) for $serverName"
if ($AutoStart -eq $True) {
    net start $instanceId
    Write-Output "Starting $instanceId"
    }
    else 
        {
    Write-Output "-AutoStart was not set, exiting without starting server instance"
    }
#Stop myself if service Firedaemon Service
net stop $ServiceName
[Environment]::Exit(66)