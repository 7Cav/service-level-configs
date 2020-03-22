$config = "dev2.json"

$configJson = Get-Content -Raw -Path $config | ConvertFrom-Json
$instanceId = $configJson.server.env.SERVER_ID
$serverName = $configJson.server.env.SERVER_NAME
$modListJson = $configJson.mods
$serverModListJson = $configJson.servermods
$localModListJson = $configJson.localmods
$configDir = $configJson.server.env.ARMA_CONFIG_PATH
$steamCMDdir = $configJson.server.env.STEAM_BASE_PATH
$installDirWorkshop = $configJson.server.env.STEAM_WORKSHOP_PATH
$installDir = $configJson.server.env.ARMA_BASE_PATH
$installDirArmadirectory = $installDir
$localModDir = $configJson.server.env.LOCAL_MOD_PATH

$modListJson = $modListJson += $serverModListJson

Write-Output $serverModListJson
Write-Output "AND"
Write-Output $modListJson