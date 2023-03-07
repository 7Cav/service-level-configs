#!/usr/bin/python3

# MIT License
#
# Copyright (c) 2017 Marcel de Vries
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import json
import os
import os.path
import re
import shutil
import threading
import time
from datetime import datetime
from urllib import request

import requests

thread_local = threading.local()

# region Configuration / ENV
STEAM_CMD = "/home/container/steamcmd/steamcmd.sh"  # Alternatively "steamcmd" if package is installed
STEAM_USER = os.getenv("STEAM_USER")
STEAM_PASS = os.getenv("STEAM_PASS")
GITHUB_MODS = os.getenv("GITHUB_MODS_URL")

SQUAD_SERVER_ID = "403240"
SQUAD_SERVER_DIR = "/home/container"
SQUAD_WORKSHOP_ID = "393380"

SQUAD_WORKSHOP_DIR = (
    f"{SQUAD_SERVER_DIR}/steamapps/workshop/content/{SQUAD_WORKSHOP_ID}"
)
SQUAD_MODS_DIR = "/home/container/SquadGame/Plugins/Mods"

UPDATE_PATTERN = re.compile(r"workshopAnnouncement.*?<p id=\"(\d+)\">", re.DOTALL)
TITLE_PATTERN = re.compile(
    r"(?<=<div class=\"workshopItemTitle\">)(.*?)(?=<\/div>)", re.DOTALL
)
WORKSHOP_CHANGELOG_URL = "https://steamcommunity.com/sharedfiles/filedetails/changelog"


# Thread Testing:
def get_session():
    if not hasattr(thread_local, "session"):
        thread_local.session = requests.Session()
    return thread_local.session


# endregion


# Grab json from github
response = requests.get(GITHUB_MODS)
jsdata = json.loads(response.text)
MODS = jsdata.get("mods")


# region Functions


def log(msg):
    print("")
    print("{{0:=<{}}}".format(len(msg)).format(""))
    print(msg)
    print("{{0:=<{}}}".format(len(msg)).format(""))


def call_steamcmd(params):
    os.system(f"{STEAM_CMD} {params}")
    print("")


def update_server():
    steam_cmd_params = (
        f" +force_install_dir {SQUAD_SERVER_DIR}"
        + f" +login {STEAM_USER} {STEAM_PASS}"
        + f" +app_update {SQUAD_SERVER_ID} validate"
        + " +quit"
    )
    call_steamcmd(steam_cmd_params)


def mod_needs_update(mod_id, path):
    if os.path.isdir(path):
        response = request.urlopen(f"{WORKSHOP_CHANGELOG_URL}/{mod_id}").read()
        response = response.decode("utf-8")
        if match := UPDATE_PATTERN.search(response):
            updated_at = datetime.fromtimestamp(int(match.group(1)))
            created_at = datetime.fromtimestamp(os.path.getmtime(path))
            print("[DEBUG] Workshop date", datetime.fromtimestamp(int(match.group(1))))
            print(
                "[DEBUG] Modified date", datetime.fromtimestamp(os.path.getmtime(path))
            )
            return updated_at >= created_at

    return False


def update_mods():

    for mod_name, mod_id in MODS.items():
        path = f"{SQUAD_WORKSHOP_DIR}/{mod_id}"
        targetpath = f"{SQUAD_MODS_DIR}/{mod_id}"

        # Check if mod needs to be updated
        if os.path.isdir(path):

            if mod_needs_update(mod_id, path):
                # Delete existing folder so that we can verify whether the
                # download succeeded
                shutil.rmtree(path)
                if os.path.islink(targetpath):
                    os.unlink(targetpath)
            else:
                print(f'No update required for "{mod_name}" ({mod_id})... SKIPPING')
                continue

        # Keep trying until the download actually succeeded
        tries = 0
        while os.path.isdir(path) is False and tries < 10:
            log(f'Updating "{mod_name}" ({mod_id}) | {tries + 1}')

            steam_cmd_params = (
                f" +force_install_dir {SQUAD_SERVER_DIR}"
                + f" +login {STEAM_USER} {STEAM_PASS}"
                + f" +workshop_download_item {SQUAD_WORKSHOP_ID} {mod_id} validate"
                + " +quit"
            )
            call_steamcmd(steam_cmd_params)

            # Sleep for a bit so that we can kill the script if needed
            time.sleep(5)

            tries += 1

        if tries >= 10:
            log(f"!! Updating {mod_name} failed after {tries} tries !!")


def create_mod_symlinks():
    for mod_name, mod_id in MODS.items():
        link_path = f"{SQUAD_MODS_DIR}/{mod_id}"
        real_path = f"{SQUAD_WORKSHOP_DIR}/{mod_id}"

        if os.path.isdir(real_path):
            if not os.path.exists(link_path):
                os.symlink(real_path, link_path)
                print(f"Creating symlink '{link_path}'...")
        else:
            print(f"Mod '{mod_name}' does not exist! ({real_path})")


# endregion


log(f"Updating Squad Server ({SQUAD_SERVER_ID})")

update_server()

log("Updating mods")

try:
    update_mods()
except Exception:
    print("Error on mod update!!")

log("Creating symlinks...")
create_mod_symlinks()

log("Done!")
