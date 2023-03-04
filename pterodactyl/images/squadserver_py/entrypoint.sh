#!/bin/bash

# Copy from github.com/parkervcp/images
# Author: David Wolfe (Red-Thirten)
# Modifed by: Josh Edson (Sweetwater.I)
# Ported to Squad by Sypolt.R
# Date: 03MAR23

cd /home/container
sleep 1

# Color Codes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Propaganda
echo -e "${GREEN}      ::::::::  :::   ::: :::::::::   ::::::::  :::    :::::::::::     ::::::::: ${NC}";
echo -e "${GREEN}    :+:    :+: :+:   :+: :+:    :+: :+:    :+: :+:        :+:         :+:    :+: ${NC}";
echo -e "${GREEN}   +:+         +:+ +:+  +:+    +:+ +:+    +:+ +:+        +:+         +:+    +:+  ${NC}";
echo -e "${GREEN}  +#++:++#++   +#++:   +#++:++#+  +#+    +:+ +#+        +#+         +#++:++#:    ${NC}";
echo -e "${GREEN}        +#+    +#+    +#+        +#+    +#+ +#+        +#+         +#+    +#+    ${NC}";
echo -e "${GREEN}#+#    #+#    #+#    #+#        #+#    #+# #+#        #+#     #+# #+#    #+#     ${NC}";
echo -e "${GREEN}########     ###    ###         ########  ########## ###     ### ###    ###      ${NC}";
echo -e "${CYAN}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~PRESENTS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${NC}";
echo -e "${YELLOW}77777777777777777777     CCCCCCCCCCCCC              AAA  VVVVVVVV           VVVVVVVV${NC}";
echo -e "${YELLOW}7::::::::::::::::::7  CCC::::::::::::C             A:::A V::::::V           V::::::V${NC}";
echo -e "${YELLOW}7::::::::::::::::::7CC:::::::::::::::C            A:::::AV::::::V           V::::::V${NC}";
echo -e "${YELLOW}777777777777:::::::C:::::CCCCCCCC::::C           A:::::::V::::::V           V::::::V${NC}";
echo -e "${YELLOW}           7::::::C:::::C       CCCCCC          A:::::::::V:::::V           V:::::V ${NC}";
echo -e "${YELLOW}          7::::::C:::::C                       A:::::A:::::V:::::V         V:::::V  ${NC}";
echo -e "${YELLOW}         7::::::7C:::::C                      A:::::A A:::::V:::::V       V:::::V   ${NC}";
echo -e "${YELLOW}        7::::::7 C:::::C                     A:::::A   A:::::V:::::V     V:::::V    ${NC}";
echo -e "${YELLOW}       7::::::7  C:::::C                    A:::::A     A:::::V:::::V   V:::::V     ${NC}";
echo -e "${YELLOW}      7::::::7   C:::::C                   A:::::AAAAAAAAA:::::V:::::V V:::::V      ${NC}";
echo -e "${YELLOW}     7::::::7    C:::::C                  A:::::::::::::::::::::V:::::V:::::V       ${NC}";
echo -e "${YELLOW}    7::::::7      C:::::C       CCCCCC   A:::::AAAAAAAAAAAAA:::::V:::::::::V        ${NC}";
echo -e "${YELLOW}   7::::::7        C:::::CCCCCCCC::::C  A:::::A             A:::::V:::::::V         ${NC}";
echo -e "${YELLOW}  7::::::7          CC:::::::::::::::C A:::::A               A:::::V:::::V          ${NC}";
echo -e "${YELLOW} 7::::::7             CCC::::::::::::CA:::::A                 A:::::V:::V           ${NC}";
echo -e "${YELLOW}77777777                 CCCCCCCCCCCCAAAAAAA                   AAAAAAVVV            ${NC}";

export GITHUB_MODS_URL=${GITHUB_JSON}
export STEAM_USER=${AUTH_STEAM_LOGIN}
export STEAM_PASS=${AUTH_STEAM_PASS}

# Download Github File(s)
#

if [[ -n ${UPDATER} ]] && [[ ! -f ./${UPDATER} ]];
then
    echo -e "\n${YELLOW}STARTUP: Specified UPDATER file \"${CYAN}${UPDATER}${YELLOW}\" is missing!${NC}"
    echo -e "\t${YELLOW}Downloading default UPDATER file for use instead...${NC}"
    curl -sSL ${GITHUB_UPDATER_URL} -o ./${UPDATER}
fi

# Download/Update specified Steam Workshop mods, if specified
if [[ ${UPDATE_WORKSHOP} == "1" ]];
then
    echo -e "\n${GREEN}STARTUP:${NC} Starting ARMA 3 Updater ${CYAN}$i${NC}...\n"
    python3 ${UPDATER}
    echo -e "\n${GREEN}STARTUP: END OF UPDATER RUNTIME ${NC}\n"
fi

# $NSS_WRAPPER_PASSWD and $NSS_WRAPPER_GROUP have been set by the Dockerfile
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /passwd.template > ${NSS_WRAPPER_PASSWD}

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`

# Start the Server
echo -e "\n${GREEN}STARTUP:${NC} Starting server with the following startup command:"
echo -e "${CYAN}${MODIFIED_STARTUP}${NC}\n"
${MODIFIED_STARTUP} 2>&1 | tee ${LOG_FILE}

if [ $? -ne 0 ];
then
    echo -e "\n${RED}PTDL_CONTAINER_ERR: There was an error while attempting to run the start command.${NC}\n"
    exit 1
fi
