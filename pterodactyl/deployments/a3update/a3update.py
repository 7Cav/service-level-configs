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

import contextlib
import os
import os.path
import re
import shutil
import time
import requests
import json
import threading

from glob import glob
from datetime import datetime
from urllib import request


thread_local = threading.local()

# region Configuration / ENV
STEAM_CMD = "/home/container/steamcmd/steamcmd.sh"  # Alternatively "steamcmd" if package is installed
STEAM_USER = os.getenv("STEAM_USER")
STEAM_PASS = os.getenv("STEAM_PASS")
GITHUB_MODS = os.getenv("GITHUB_MODS_URL")

A3_SERVER_ID = "233780"
A3_SERVER_DIR = "/home/container"
A3_WORKSHOP_ID = "107410"

A3_WORKSHOP_DIR = f"{A3_SERVER_DIR}/steamapps/workshop/content/{A3_WORKSHOP_ID}"
A3_MODS_DIR = "/home/container"
A3_KEYS_DIR = "/home/container/keys"

# MODPACK_NAME = "Modpack"
MODPACK_PATH = "/home/container/modpack.html"

UPDATE_PATTERN = re.compile(r"workshopAnnouncement.*?<p id=\"(\d+)\">", re.DOTALL)
TITLE_PATTERN = re.compile(
    r"(?<=<div class=\"workshopItemTitle\">)(.*?)(?=<\/div>)", re.DOTALL
)
WORKSHOP_CHANGELOG_URL = "https://steamcommunity.com/sharedfiles/filedetails/changelog"

with contextlib.suppress(Exception):
    os.remove("/home/container/serverprofile/DataCache/cache_lock")


# Thread Testing:
def get_session():
    if not hasattr(thread_local, "session"):
        thread_local.session = requests.Session()
    return thread_local.session


# endregion
# Grab json from github
response = requests.get(GITHUB_MODS)
jsdata = json.loads(response.text)
# MODPACK_NAME = jsdata.get('modpack_name')
MODS = jsdata.get("mods")
# SERVER_MODS = jsdata.get('server_mods')
# OPTIONAL_MODS = jsdata.get('optional_mods')
# DLC = jsdata.get('dlc')

# end json grab

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
        f" +force_install_dir {A3_SERVER_DIR}"
        + f" +login {STEAM_USER} {STEAM_PASS}"
        + f" +app_update {A3_SERVER_ID} validate"
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
        path = f"{A3_WORKSHOP_DIR}/{mod_id}"
        targetpath = f"{A3_SERVER_DIR}/{mod_name}"

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
                f" +force_install_dir {A3_SERVER_DIR}"
                + f" +login {STEAM_USER} {STEAM_PASS}"
                + f" +workshop_download_item {A3_WORKSHOP_ID} {mod_id} validate"
                + " +quit"
            )

            call_steamcmd(steam_cmd_params)

            # Sleep for a bit so that we can kill the script if needed
            time.sleep(5)

            tries += 1

        if tries >= 10:
            log(f"!! Updating {mod_name} failed after {tries} tries !!")


def lowercase_workshop_dir():
    def rename_all(root, items):
        for name in items:
            with contextlib.suppress(OSError):
                os.rename(os.path.join(root, name), os.path.join(root, name.lower()))

    for root, dirs, files in os.walk(A3_WORKSHOP_DIR, topdown=False):
        rename_all(root, dirs)
        rename_all(root, files)


def create_mod_symlinks():
    for mod_name, mod_id in MODS.items():
        link_path = f"{A3_MODS_DIR}/{mod_name}"
        real_path = f"{A3_WORKSHOP_DIR}/{mod_id}"

        if os.path.isdir(real_path):
            if not os.path.exists(link_path):
                # shutil.copytree(real_path, link_path)
                os.symlink(real_path, link_path)
                print(f"Creating symlink '{link_path}'...")
        else:
            print(f"Mod '{mod_name}' does not exist! ({real_path})")


key_regex = re.compile(r"(key).*", re.I)


def copy_keys():
    # Check for broken symlinks
    for key in os.listdir(A3_KEYS_DIR):
        key_path = f"{A3_KEYS_DIR}/{key}"
        if os.path.islink(key_path) and not os.path.exists(key_path):
            print(f"Removing outdated server key '{key}'")
            os.remove(key_path)
    # Update/add new key symlinks
    for mod_name, mod_id in MODS.items():
        # if mod_name not in SERVER_MODS:
        real_path = f"{A3_WORKSHOP_DIR}/{mod_id}"
        if not os.path.isdir(real_path):
            print(f"Couldn't copy key for mod '{mod_name}', directory doesn't exist.")
        else:
            dirlist = os.listdir(real_path)
            if keyDirs := [x for x in dirlist if re.search(key_regex, x)]:
                keyDir = keyDirs[0]
                if os.path.isfile(f"{real_path}/{keyDir}"):
                    # Key is placed in root directory
                    key = keyDir
                    key_path = os.path.join(A3_KEYS_DIR, key)
                    if not os.path.exists(key_path):
                        print(f"Creating copy to key for mod '{mod_name}' ({key})")
                        shutil.copyfile(os.path.join(real_path, key), key_path)
                else:
                    # Key is in a folder
                    for key in os.listdir(os.path.join(real_path, keyDir)):
                        real_key_path = os.path.join(real_path, keyDir, key)
                        key_path = os.path.join(A3_KEYS_DIR, key)
                        if not os.path.exists(key_path):
                            print(f"Creating copy to key for mod '{mod_name}' ({key})")
                            shutil.copyfile(real_key_path, key_path)
            else:
                print(f"!! Couldn't find key folder for mod {mod_name} !!")


def save_rpt():
    path = "/home/container/"
    try:
        rpt3 = glob(os.path.join(path, "RPT_3_*"))[0]
        os.remove(rpt3)
        log("Removing RPT3")
    except IndexError:
        log("RPT_3 Not Found - Skipping")
    try:
        rpt2 = glob(os.path.join(path, "RPT_2_*"))[0]
        new_name = rpt2.replace("RPT_2_", "RPT_3_")
        os.rename(rpt2, new_name)
        log("Moving RPT_2 to RPT_3")
    except IndexError:
        log("RPT_2 Not Found - Skipping")

    try:
        rpt1 = glob(os.path.join(path, "RPT_1_*"))[0]
        new_name = rpt1.replace("RPT_1_", "RPT_2_")
        os.rename(rpt1, new_name)
        log("Moving RPT_1 to RPT_2")
    except IndexError:
        log("RPT_1 Not Found - Skipping")
    try:
        os.rename("/home/container/RPT.log", time.strftime("RPT_1_%Y%m%d%H%M%S.log"))
        log("Backing up RPT.log to RPT_1")
    except Exception:
        log("No RPT.log Found - Skipping")


# endregion


log("Backing up RPT")
save_rpt()

log(f"Updating A3 server ({A3_SERVER_ID})")

update_server()

log("Updating mods")

try:
    update_mods()
except Exception:
    print("error on mod update!!")

log("Converting uppercase files/folders to lowercase...")
lowercase_workshop_dir()

log("Creating symlinks...")
create_mod_symlinks()


log("Copying server keys...")
copy_keys()

log("Done!")
