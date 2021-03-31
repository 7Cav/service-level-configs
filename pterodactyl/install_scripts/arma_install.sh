#!/bin/bash
apt -y update
apt -y --no-install-recommends install curl lib32gcc1 ca-certificates

## I think I know what I'm doing. And that extremely dangerous.

## download and install steamcmd
cd /tmp
mkdir -p /mnt/server/steamcmd
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd
cd /mnt/server/steamcmd

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server

## install game using steamcmd
./steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /mnt/server +app_update ${STEAMCMD_APPID} ${STEAMCMD_EXTRA_FLAGS} validate +quit

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so

## ARMA III specific setup
cd /mnt/server/

mkdir -p "/mnt/server/.local/share/Arma 3" "/mnt/server/.local/share/Arma 3 - Other Profiles"

## TO-DO Need to cycle to specific scripts via github - Sweetwater

[[ -f basic.cfg ]] || curl -sSLO https://raw.githubusercontent.com/parkervcp/eggs/master/steamcmd_servers/arma/arma3/egg-arma3-config/basic.cfg
[[ -f server.cfg ]] || curl -sSLO https://raw.githubusercontent.com/parkervcp/eggs/master/steamcmd_servers/arma/arma3/egg-arma3-config/server.cfg
chmod 755 basic.cfg server.cfg