## install required packages to install squad
apt update
apt -y --no-install-recommends install curl unzip libstdc++6 lib32gcc1 ca-certificates jq

## install steamcmd
cd /tmp
curl -sSL -o steamcmd.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz
mkdir -p /mnt/server/steam
tar -xzvf steamcmd.tar.gz -C /mnt/server/steam
cd /mnt/server/steam

## needs to be used for steamcmd to operate correctly
chown -R root:root /mnt
export HOME=/mnt/server

## install squad
./steamcmd.sh +login anonymous +force_install_dir /mnt/server +app_update ${SRCDS_APPID} +quit
mkdir -p /mnt/server/.steam/sdk32

## steam logins
STEAMLOGIN=${AUTH_STEAM_LOGIN}
STEAMPASS=${AUTH_STEAM_PASS}

## remove and install mods
steamwrkconfig=${SWMC}
SERVERAPP_ID=${SRCDS_SID}
if [ "$steamwrkconfig" = "\n" ]
then
echo "No Steam Workshop Configuration Provided"
else
echo "Steam Workshop Configuration Provided..."
SCRDS_WRKID=$(curl -s $steamwrkconfig | jq -r '.server.mods[].app')
echo "app ID $SCRDS_WRKID"
echo "server id $SERVERAPP_ID"
for MOD in $SCRDS_WRKID
do
echo "downloading workshop item $MOD ..."
./steamcmd.sh +login anonymous +workshop_download_item $SERVERAPP_ID $MOD +quit
rm -rf /mnt/server/SquadGame/Plugins/Mods/$MOD
mv /mnt/server/steam/steamapps/workshop/content/$SERVERAPP_ID/$MOD/* /mnt/server/SquadGame/Plugins/Mods/$MOD
echo "setup of $MOD complete"
done
fi

cp -v /mnt/server/steam/linux32/steamclient.so /mnt/server/.steam/sdk32/steamclient.so

chmod +x /mnt/server/SquadGame/Binaries/Linux/SquadGameServer