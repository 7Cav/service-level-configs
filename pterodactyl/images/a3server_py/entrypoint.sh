#!/bin/bash

# Copy from github.com/parkervcp/images
# Author: David Wolfe (Red-Thirten)
# Modifed by: Josh Edson (Sweetwater.I)
# Date: 4-17-21

# SteamCMD ID for the Arma 3 GAME (not server). Only used for Workshop mod downloads.
armaGameID=107410
# Color Codes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

cd /home/container
sleep 1

# Propaganda
#
echo -e "\t${CYAN}Sweetwater.I Presents${NC}"
echo -e "${YELLOW}77777777777777777777      CCCCCCCCCCCCC               AAA   VVVVVVVV           VVVVVVVV${NC}";
echo -e "${YELLOW}7::::::::::::::::::7   CCC::::::::::::C              A:::A  V::::::V           V::::::V${NC}";
echo -e "${YELLOW}7::::::::::::::::::7 CC:::::::::::::::C             A:::::A V::::::V           V::::::V${NC}";
echo -e "${YELLOW}777777777777:::::::7C:::::CCCCCCCC::::C            A:::::::AV::::::V           V::::::V${NC}";
echo -e "${YELLOW}           7::::::7C:::::C       CCCCCC           A:::::::::AV:::::V           V:::::V ${NC}";
echo -e "${YELLOW}          7::::::7C:::::C                        A:::::A:::::AV:::::V         V:::::V  ${NC}";
echo -e "${YELLOW}         7::::::7 C:::::C                       A:::::A A:::::AV:::::V       V:::::V   ${NC}";
echo -e "${YELLOW}        7::::::7  C:::::C                      A:::::A   A:::::AV:::::V     V:::::V    ${NC}";
echo -e "${YELLOW}       7::::::7   C:::::C                     A:::::A     A:::::AV:::::V   V:::::V     ${NC}";
echo -e "${YELLOW}      7::::::7    C:::::C                    A:::::AAAAAAAAA:::::AV:::::V V:::::V      ${NC}";
echo -e "${YELLOW}     7::::::7     C:::::C                   A:::::::::::::::::::::AV:::::V:::::V       ${NC}";
echo -e "${YELLOW}    7::::::7       C:::::C       CCCCCC    A:::::AAAAAAAAAAAAA:::::AV:::::::::V        ${NC}";
echo -e "${YELLOW}   7::::::7         C:::::CCCCCCCC::::C   A:::::A             A:::::AV:::::::V         ${NC}";
echo -e "${YELLOW}  7::::::7           CC:::::::::::::::C  A:::::A               A:::::AV:::::V          ${NC}";
echo -e "${YELLOW} 7::::::7              CCC::::::::::::C A:::::A                 A:::::AV:::V           ${NC}";
echo -e "${YELLOW}77777777                  CCCCCCCCCCCCCAAAAAAA                   AAAAAAAVVV            ${NC}";
echo -e "\n${CYAN}ARMA 3 PTERODACTYL EDITION - With Python Script${NC}";
#
# Exports
export GITHUB_MODS_URL=${GITHUB_JSON}
export STEAM_USER=${STEAM_USER}
export STEAM_PASS=${STEAM_PASS}

# Download Github File(s)
#
if [[ -n ${BASIC} ]] && [[ ! -f ./${BASIC} ]];
then
	echo -e "\n${YELLOW}STARTUP: Specified Basic Network Configuration file \"${CYAN}${BASIC}${YELLOW}\" is missing!${NC}"
	echo -e "\t${YELLOW}Downloading default file for use instead...${NC}"
	curl -sSL ${GITHUB_BASIC_URL} -o ./${BASIC}
fi

if [[ -n ${UPDATER} ]] && [[ ! -f ./${UPDATER} ]];
then
	echo -e "\n${YELLOW}STARTUP: Specified UPDATER file \"${CYAN}${UPDATER}${YELLOW}\" is missing!${NC}"
	echo -e "\t${YELLOW}Downloading default UPDATER file for use instead...${NC}"
	curl -sSL ${GITHUB_UPDATER_URL} -o ./${UPDATER}
fi

if [[ -n ${CONFIG} ]] && [[ ! -f ./${CONFIG} ]];
then
	echo -e "\n${YELLOW}STARTUP: Specified UPDATER file \"${CYAN}${CONFIG}${YELLOW}\" is missing!${NC}"
	echo -e "\t${YELLOW}Downloading default UPDATER file for use instead...${NC}"
	curl -sSL ${GITHUB_SERVER_CFG_URL} -o ./${CONFIG}
fi
#
# Define make mods lowercase function
ModsLowercase () {
	echo -e "\n${GREEN}STARTUP:${NC} Making mod ${CYAN}$1${NC} files/folders lowercase..."
	for SRC in `find ./$1 -depth`
	do
		DST=`dirname "${SRC}"`/`basename "${SRC}" | tr '[A-Z]' '[a-z]'`
		if [ "${SRC}" != "${DST}" ]
		then
			[ ! -e "${DST}" ] && mv -T "${SRC}" "${DST}"
		fi
	done
}

# Check for old eggs
if [[ -z ${SERVER_BINARY} ]] || [[ -n ${MODS} ]];
then
	echo -e "\n${RED}STARTUP_ERR: Please contact your administrator/host for support, and give them the following message:${NC}\n"
	echo -e "\t${CYAN}Your Arma 3 Egg is outdated and no longer supported.${NC}"
	echo -e "\t${CYAN}Please download the latest version at the following link, and install it in your panel:${NC}"
	echo -e "\t${CYAN}https://github.com/parkervcp/eggs/tree/master/steamcmd_servers/arma${NC}\n"
	exit 1
fi

# Check for improper Steam account set
if [[ ${STEAM_USER} == "your_steam_username" ]] || [[ ${STEAM_USER} == "anonymous" ]];
then
	echo -e "\n${RED}STARTUP_ERR: Please contact your administrator/host for support, and give them the following message:${NC}\n"
	echo -e "\t${CYAN}Your Arma 3 Egg, or your client's server, is not configured with valid Steam credentials.${NC}"
	echo -e "\t${CYAN}Please visit the following link for more info:${NC}"
	echo -e "\t${CYAN}https://github.com/parkervcp/eggs/tree/master/steamcmd_servers/arma/arma3#installation-requirements${NC}\n"
	exit 1
fi

# Update dedicated server, if specified
if [[ ${UPDATE_SERVER} == "1" ]];
then
	echo -e "\n${GREEN}STARTUP:${NC} Checking for updates to game server with App ID: ${CYAN}${STEAMCMD_APPID}${NC}...\n"
	if [[ -f ./steam.txt ]];
	then
		echo -e "\n${GREEN}STARTUP:${NC} steam.txt found in root folder. Using to run SteamCMD script...\n"
		./steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${STEAMCMD_APPID} ${STEAMCMD_EXTRA_FLAGS} validate +runscript /home/container/steam.txt
	else
		./steamcmd/steamcmd.sh +login ${STEAM_USER} ${STEAM_PASS} +force_install_dir /home/container +app_update ${STEAMCMD_APPID} ${STEAMCMD_EXTRA_FLAGS} validate +quit
	fi
	echo -e "\n${GREEN}STARTUP: Game server update check complete!${NC}\n"
fi

# Download/Update specified Steam Workshop mods, if specified
if [[ ${UPDATE_WORKSHOP} == "1" ]];
then
	echo -e "\n${GREEN}STARTUP:${NC} Starting ARMA 3 Updater ${CYAN}$i${NC}...\n"
	python3 ${UPDATER}
	echo -e "\n${GREEN}STARTUP: END OF UPDATER RUNTIME ${NC}\n"
fi

# Make mods lowercase, if specified
if [[ ${MODS_LOWERCASE} == "1" ]];
then
	for i in $(echo ${MODIFICATIONS} | sed "s/;/ /g")
	do
		ModsLowercase $i
	done
	
	for i in $(echo ${SERVERMODS} | sed "s/;/ /g")
	do
		ModsLowercase $i
	done
fi

# Check if specified server binary exists. If null (legacy egg is being used), skips check.
if [[ ! -f ./${SERVER_BINARY} ]];
then
	echo -e "\n${RED}STARTUP_ERR: Specified server binary could not be found in files!${NC}"
	exit 1
fi

# $NSS_WRAPPER_PASSWD and $NSS_WRAPPER_GROUP have been set by the Dockerfile
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /passwd.template > ${NSS_WRAPPER_PASSWD}

if [[ ${SERVER_BINARY} == *"x64"* ]];
then
	export LD_PRELOAD=/libnss_wrapper_x64.so
else
	export LD_PRELOAD=/libnss_wrapper.so
fi

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`

# Start Headless Clients if applicable
if [[ ${HC_NUM} > 0 ]];
then
	echo -e "\n${GREEN}STARTUP:${NC} Starting ${CYAN}${HC_NUM}${NC} Headless Client(s)."
	for i in $(seq ${HC_NUM})
	do
		./${SERVER_BINARY} -client -connect=${HC_PORT} -port=${SERVER_PORT} -password="${HC_PASSWORD}" -profiles=./serverprofile -bepath=./battleye -mod="${MODIFICATIONS}${HC_OPTIONAL_MODS}" ${HC_STARTUP_PARAMS} > /dev/null 2>&1 &
		echo -e "${GREEN}STARTUP:${CYAN} Headless Client $i${NC} launched."
	done
fi

# Start the Server
echo -e "\n${GREEN}STARTUP:${NC} Starting server with the following startup command:"
echo -e "${CYAN}${MODIFIED_STARTUP}${NC}\n"
${MODIFIED_STARTUP} 2>&1 | tee ${LOG_FILE}

if [ $? -ne 0 ];
then
	echo -e "\n${RED}PTDL_CONTAINER_ERR: There was an error while attempting to run the start command.${NC}\n"
	exit 1
else
	if [[ ${HC_NUM} > 0 ]];
	then
		echo -e "\n${GREEN}SHUTDOWN:${NC} Stopping all headless clients...\n"
		kill $(jobs -p)
	fi
fi
