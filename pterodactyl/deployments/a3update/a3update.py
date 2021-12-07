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

import os
import os.path
import re
import shutil
import time
import requests
import json
import threading
import concurrent.futures


from datetime import datetime
from urllib import request


thread_local = threading.local()

# region Configuration / ENV
STEAM_CMD = "/home/container/steamcmd/steamcmd.sh"  # Alternatively "steamcmd" if package is installed
STEAM_USER = os.getenv('STEAM_USER')
STEAM_PASS = os.getenv('STEAM_PASS')
GITHUB_MODS = os.getenv('GITHUB_MODS_URL')

A3_SERVER_ID = "233780"
A3_SERVER_DIR = "/home/container"
A3_WORKSHOP_ID = "107410"

A3_WORKSHOP_DIR = "{}/steamapps/workshop/content/{}".format(A3_SERVER_DIR, A3_WORKSHOP_ID)
A3_MODS_DIR = "/home/container"
A3_KEYS_DIR = "/home/container/keys"

# MODPACK_NAME = "Modpack"
MODPACK_PATH = "/home/container/modpack.html"

UPDATE_PATTERN = re.compile(r"workshopAnnouncement.*?<p id=\"(\d+)\">", re.DOTALL)
TITLE_PATTERN = re.compile(r"(?<=<div class=\"workshopItemTitle\">)(.*?)(?=<\/div>)", re.DOTALL)
WORKSHOP_CHANGELOG_URL = "https://steamcommunity.com/sharedfiles/filedetails/changelog"

try:
    os.remove("/home/container/serverprofile/DataCache/cache_lock")
except:
    pass

# Thread Testing:
def get_session():
    if not hasattr(thread_local, "session"):
        thread_local.session = requests.Session()
    return thread_local.session

# endregion
# Grab json from github
response = requests.get(GITHUB_MODS)
jsdata = json.loads(response.text)
MODPACK_NAME = jsdata.get('modpack_name')
MODS = jsdata.get('mods')
SERVER_MODS = jsdata.get('server_mods')
OPTIONAL_MODS = jsdata.get('optional_mods')
DLC = jsdata.get('dlc')

#end json grab

# region Functions

def log(msg):
    print("")
    print("{{0:=<{}}}".format(len(msg)).format(""))
    print(msg)
    print("{{0:=<{}}}".format(len(msg)).format(""))


def call_steamcmd(params):
    os.system("{} {}".format(STEAM_CMD, params))
    print("")


#def update_server():
#    steam_cmd_params = " +login {} {}".format(STEAM_USER, STEAM_PASS)
#    steam_cmd_params += " +force_install_dir {}".format(A3_SERVER_DIR)
#    steam_cmd_params += " +app_update {} validate".format(A3_SERVER_ID)
#    steam_cmd_params += " +quit"
#
#    call_steamcmd(steam_cmd_params)


def mod_needs_update(mod_id, path):
    if os.path.isdir(path):
        response = request.urlopen("{}/{}".format(WORKSHOP_CHANGELOG_URL, mod_id)).read()
        response = response.decode("utf-8")
        match = UPDATE_PATTERN.search(response)

        if match:
            updated_at = datetime.fromtimestamp(int(match.group(1)))
            created_at = datetime.fromtimestamp(os.path.getmtime(path))
            print ('[DEBUG] Workshop date', datetime.fromtimestamp(int(match.group(1))))
            print ('[DEBUG] Modified date', datetime.fromtimestamp(os.path.getmtime(path)))
            return updated_at >= created_at

    return False

def update_mods():

    for mod_name, mod_id in MODS.items():
        path = "{}/{}".format(A3_WORKSHOP_DIR, mod_id)
        targetpath = "{}/{}".format(A3_SERVER_DIR, mod_name)

        # Check if mod needs to be updated
        if os.path.isdir(path):
            
            if mod_needs_update(mod_id, path):
                # Delete existing folder so that we can verify whether the
                # download succeeded
                shutil.rmtree(path)
                if os.path.islink(targetpath):
                    os.unlink(targetpath)
            else:
                print("No update required for \"{}\" ({})... SKIPPING".format(mod_name, mod_id, path))
                continue

        # Keep trying until the download actually succeeded
        tries = 0
        while os.path.isdir(path) is False and tries < 10:
            log("Updating \"{}\" ({}) | {}".format(mod_name, mod_id, tries + 1))

            steam_cmd_params = " +login {} {}".format(STEAM_USER, STEAM_PASS)
            steam_cmd_params += " +force_install_dir {}".format(A3_SERVER_DIR)
            steam_cmd_params += " +workshop_download_item {} {} validate".format(
                A3_WORKSHOP_ID,
                mod_id
            )
            steam_cmd_params += " +quit"

            call_steamcmd(steam_cmd_params)

            # Sleep for a bit so that we can kill the script if needed
            time.sleep(5)

            tries = tries + 1

        if tries >= 10:
            log("!! Updating {} failed after {} tries !!".format(mod_name, tries))


def lowercase_workshop_dir():
    def rename_all(root, items):
        for name in items:
            try:
                os.rename(os.path.join(root, name), os.path.join(root, name.lower()))
            except OSError:
                pass
    for root, dirs, files in os.walk(A3_WORKSHOP_DIR, topdown=False):
        rename_all(root, dirs)
        rename_all(root, files)


def create_mod_symlinks():
    for mod_name, mod_id in MODS.items():
        link_path = "{}/{}".format(A3_MODS_DIR, mod_name)
        real_path = "{}/{}".format(A3_WORKSHOP_DIR, mod_id)

        if os.path.isdir(real_path):
            if not os.path.exists(link_path):
                #shutil.copytree(real_path, link_path)
                os.symlink(real_path, link_path)
                print("Creating symlink '{}'...".format(link_path))
        else:
            print("Mod '{}' does not exist! ({})".format(mod_name, real_path))


key_regex = re.compile(r'(key).*', re.I)


def copy_keys():
    # Check for broken symlinks
    for key in os.listdir(A3_KEYS_DIR):
        key_path = "{}/{}".format(A3_KEYS_DIR, key)
        if os.path.islink(key_path) and not os.path.exists(key_path):
            print("Removing outdated server key '{}'".format(key))
            os.remove(key_path)
    # Update/add new key symlinks
    for mod_name, mod_id in MODS.items():
        if mod_name not in SERVER_MODS:
            real_path = "{}/{}".format(A3_WORKSHOP_DIR, mod_id)
            if not os.path.isdir(real_path):
                print("Couldn't copy key for mod '{}', directory doesn't exist.".format(mod_name))
            else:
                dirlist = os.listdir(real_path)
                keyDirs = [x for x in dirlist if re.search(key_regex, x)]

                if keyDirs:
                    keyDir = keyDirs[0]
                    if os.path.isfile("{}/{}".format(real_path, keyDir)):
                        # Key is placed in root directory
                        key = keyDir
                        key_path = os.path.join(A3_KEYS_DIR, key)
                        if not os.path.exists(key_path):
                            print("Creating copy to key for mod '{}' ({})".format(mod_name, key))
                            shutil.copyfile(os.path.join(real_path, key), key_path)
                    else:
                        # Key is in a folder
                        for key in os.listdir(os.path.join(real_path, keyDir)):
                            real_key_path = os.path.join(real_path, keyDir, key)
                            key_path = os.path.join(A3_KEYS_DIR, key)
                            if not os.path.exists(key_path):
                                print("Creating copy to key for mod '{}' ({})".format(mod_name, key))
                                shutil.copyfile(real_key_path, key_path)
                else:
                    print("!! Couldn't find key folder for mod {} !!".format(mod_name))

# endregion
def print_launch_params():
    rel_path = os.path.relpath(A3_MODS_DIR, A3_SERVER_DIR)
    params = "-mod"
    for mod_name, mod_id in MODS.items():
        params += "{}/{}\;".format(rel_path, mod_name)
        
    print(params)

log("Updating mods")

try:
    update_mods()
except:
    print('error on mod update!!')

log("Converting uppercase files/folders to lowercase...")
lowercase_workshop_dir()

log("Creating symlinks...")
create_mod_symlinks()


log("Copying server keys...")
copy_keys()

#log("Generating modpack .html file...")
#try:
#    generate_preset()
#except:
#    print('error on generating preset file!!')

log('Generating parameters')
print_launch_params()

log("Done!")