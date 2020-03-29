#Instance Configuration devlopment 2 Server
$configPath = 'https://raw.githubusercontent.com/7Cav/service-level-configs/master/tarkas/arma3/training/test.json'
$configJson = (New-Object System.Net.WebClient).DownloadString($configPath) | ConvertFrom-Json
#
$getpath = Get-Location
$instanceId = $configJson.server.env.SERVER_ID
$serverName = $configJson.server.env.SERVER_NAME
$ipaddr = $configJson.server.env.IP_ADDRESS
$port = $configJson.server.env.PORT
$Parameters = $configJson.server.env.PARAMETERS
$modListJson = $configJson.mods
$scripts = $configJson.server.env.SCRIPTS_REL_PATH
$configDir = $configJson.server.env.ARMA_CONFIG_PATH
$steamCMDdir = $configJson.server.env.STEAM_BASE_PATH
$installDirWorkshop = $configJson.server.env.STEAM_WORKSHOP_PATH
$storePath = $configJson.server.env.STORE_PATH
$installDirArmadirectory = $configJson.server.env.ARMA_BASE_PATH
$localModDir = $configJson.server.env.LOCAL_MOD_PATH
$steamUser = $env:STEAM_USER
$steamPass = $env:STEAM_PASS
# Join Paths and other
$storePath += "$serverName"
$configDir = "$configDir\$serverName"
$steamCMDdir += "steamcmd.exe"
$serverScripts = "$installDirArmadirectory\$scripts"
# Remove existing symbolic links
#
#Start Transcript
Start-Transcript -path $getpath\update.log -IncludeInvocationHeader -Force
Write-Output "Update has started: $(Get-Date) for Service $instanceId - $serverName"

$dirp = Get-Item $installDirArmadirectory\@*
foreach($item in $dirp)
{
$item.Delete()
Write-Output "Removing Junction Point at $item"
}

#Stop Firedaemon Service
net stop $instanceId
Start-Sleep -s 5
Write-Output Start-Sleep -s 15

Write-Output "Starting SteamCMD Download and Validate Base Installation"
#login to steamcmd using env variables
$argumentListArray = "+login $steamUser $steamPass +force_install_dir "+$storePath+" "
#download each item in steamcmd using the app id in the mod list array
foreach($item in $modListJson) 
{
    $id = $item.app
    $name = $item.name
    $server = $item.server
    if ($id -ne "")
    {
    $argumentListArray += "+workshop_download_item 107410 $id "
    Write-Output "Found Item_ID: $id ($name) - Servermod = $server"
    }
}   
#update and validate arma 3 base installation
$argumentListArray += "+force_install_dir $installDirArmadirectory +app_update 233780 validate +quit"

Start-Process -FilePath $steamCMDdir -ArgumentList $argumentListArray -NoNewWindow -Wait

#copying keys and mods to dir from workshop
foreach($item in $modListJson) 
{
   $id = $item.app
   $name = $item.name
   $path = $localModDir
   if ($id -ne "")
   {
      New-Item -ItemType Junction -Path "$installDirArmadirectory\$name" -Target $installDirWorkshop\$id     
      copy-item $installDirWorkshop\$id\[kK]*\*.bikey $installDirArmadirectory\keys\ -force -recurse
      Write-Output "Copy Key $name" 
   }
   else
   {
      New-Item -ItemType Junction -Path "$installDirArmadirectory\$name" -Target "$path\$name"
      copy-item $installDirArmadirectory\$name\[kK]*\*.bikey $installDirArmadirectory\keys\ -force -recurse
      Write-Output "Copy Key $name"
   }
}

Write-Output "$serverScripts has yet to be assigned in the script"
# To Do,
# Add recursive copying of server side scripts
# Add automatic unlocks for mpmissions for backups and insession updating

# Instance Mods
$modparam = "-mod="
$modserverparam = "-servermod="
foreach($item in $modListJson)
{
    $name = $item.name
    $server = $item.server
    if ($server -ne "true")
    {
        $modparam += "$name;"
    }
    else
    {
        $modserverparam += "$name;"
    }
}
$modenv = "$modparam $modserverparam"

$ipaddrparam = "-ip=$ipaddr"
$portparam = "-port=$port"
$profilepath = "-profiles=$configDir\"
$armacfgpath = "-cfg=$configDir\arma3.cfg"
$armaconfigpath = "-config=$configDir\server.cfg"
$beconfigpath = "-bepath=$configDir\BattlEye\"
$nameparam = "-name=$serverName"

$compileParams = "$ipaddrparam $portparam $Parameters $nameparam $profilepath $armacfgpath $armaconfigpath $beconfigpath $modenv"
#[System.Environment]::SetEnvironmentVariable($serverName, $compileParams,[System.EnvironmentVariableTarget]::Machine)
Write-Output "Parameters: $compileParams"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name $serverName –Value $compileParams

#Removing logs after update
#Remove-Item $configDir\*.rpt 
#Remove-Item $configDir\*.log 
#Write-Output Remove-Item $configDir\*.rpt 
#Write-Output Remove-Item $configDir\*.log 

Write-Output "Update has finished: $(Get-Date) for $serverName"
#stopping transcript
Stop-Transcript
#Start Firedaemon Service
#net start $instanceId
exit