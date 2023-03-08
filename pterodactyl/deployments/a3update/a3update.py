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
import json
import os
import os.path
import re
import shutil
import threading
import time
from datetime import datetime
from glob import glob
from pathlib import Path

import requests

thread_local = threading.local()

# region Configuration / ENV

# Set variables for SteamCMD, Steam user, password, and GitHub mods URL
STEAM_CMD = "/home/container/steamcmd/steamcmd.sh"  # Alternatively "steamcmd" if package is installed
STEAM_USER = os.getenv("STEAM_USER")
STEAM_PASS = os.getenv("STEAM_PASS")
GITHUB_MODS_URL = os.getenv("GITHUB_MODS_URL")

# Set variables for Arma 3 server ID, server directory, and workshop ID
A3_SERVER_ID = "233780"
A3_SERVER_DIR = "/home/container"
A3_WORKSHOP_ID = "107410"

# Set variables for Arma 3 workshop and mods directories, and keys directory
A3_WORKSHOP_DIR = f"{A3_SERVER_DIR}/steamapps/workshop/content/{A3_WORKSHOP_ID}"
A3_MODS_DIR = "/home/container"
A3_KEYS_DIR = "/home/container/keys"

# Set variable for modpack path
MODPACK_PATH = "/home/container/modpack.html"

# Set regular expressions for update pattern and title pattern
UPDATE_PATTERN = re.compile(r"workshopAnnouncement.*?<p id=\"(\d+)\">", re.DOTALL)
TITLE_PATTERN = re.compile(
    r"(?<=<div class=\"workshopItemTitle\">)(.*?)(?=<\/div>)", re.DOTALL
)

# Set variable for workshop changelog URL
WORKSHOP_CHANGELOG_URL = "https://steamcommunity.com/sharedfiles/filedetails/changelog"

# Remove cache lock file if it exists
with contextlib.suppress(Exception):
    os.remove("/home/container/serverprofile/DataCache/cache_lock")

# endregion

# Set up a thread-local session for multi-threading support
thread_local = threading.local()


def get_session():
    """
    Returns a requests.Session object for thread testing.

    This function creates a new requests.Session object and attaches it to the
    current thread, using a thread-local variable. If a session object has
    already been created for the current thread, it returns that object instead
    of creating a new one.

    Returns:
        A requests.Session object.
    """
    if not hasattr(thread_local, "session"):
        thread_local.session = requests.Session()
    return thread_local.session


# Send a GET request to the GitHub mods URL and parse the response as JSON
response = requests.get(GITHUB_MODS_URL)
jsdata = json.loads(response.text)

# Extract the 'mods' list from the JSON data
MODS = jsdata.get("mods")


# region Functions


def log(msg):
    """
    Prints a message with a header and footer of equal length made of equal signs.

    Args:
        msg (str): The message to be logged.
    """
    header_footer = "=" * len(msg)  # Create a header and footer of equal length
    print(
        f"\n{header_footer}\n{msg}\n{header_footer}\n"
    )  # Print the header, message, and footer


def call_steamcmd(params):
    """
    Calls the SteamCMD executable with the specified parameters.

    Args:
        params (str): The parameters to be passed to SteamCMD.
    """
    os.system(
        f"{STEAM_CMD} {params}"
    )  # Execute the SteamCMD command with the specified parameters
    print("\n")  # Print a newline character after the command has completed


def update_server():
    """
    Updates the ArmA 3 server using SteamCMD.
    """
    # Create a list of SteamCMD parameters for updating the server
    steam_cmd_params = [
        "+force_install_dir",
        A3_SERVER_DIR,
        "+login",
        STEAM_USER,
        STEAM_PASS,
        "+app_update",
        A3_SERVER_ID,
        "validate",
        "+quit",
    ]

    # Join the list of parameters into a single string separated by spaces
    steam_cmd_str = " ".join(steam_cmd_params)

    call_steamcmd(steam_cmd_str)  # Call SteamCMD with the specified parameters


def is_mod_outdated(mod_id: int, path: str) -> bool:
    """
    Checks if a mod needs an update by comparing its modified date with its last updated date in the workshop.

    Args:
        mod_id (int): The ID of the mod to check.
        path (str): The path to the mod directory.

    Returns:
        bool: True if the mod needs an update, False otherwise.
    """
    mod_path = Path(path)

    # Check if the path exists
    if not mod_path.exists():
        print(f"[WARNING] Directory {path} does not exist")
        return True

    # Fetch the URL and get the match object if it exists
    try:
        response = requests.get(f"{WORKSHOP_CHANGELOG_URL}/{mod_id}")
        response.raise_for_status()
        match = UPDATE_PATTERN.search(response.text)
    except requests.exceptions.RequestException as e:
        print(f"[ERROR] An error occurred: {e}")
        return False

    if mod_path.is_dir() and match:
        created_at = datetime.fromtimestamp(mod_path.stat().st_mtime)
        updated_at = datetime.fromtimestamp(int(match.group(1)))
        # Debugging information
        print("[DEBUG] Workshop date", updated_at)
        print("[DEBUG] Modified date", created_at)
        return updated_at >= created_at
    else:
        print(f"[WARNING] {path} is not a directory")
        return False

    return False


def update_mods():

    for mod_name, mod_id in MODS.items():
        path = f"{A3_WORKSHOP_DIR}/{mod_id}"
        targetpath = f"{A3_SERVER_DIR}/{mod_name}"

        # Check if mod needs to be updated
        if os.path.isdir(path):

            if is_mod_outdated(mod_id, path):
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
                f" +force_install_dir {A3_SERVER_DIR}",
                +f" +login {STEAM_USER} {STEAM_PASS}",
                +f" +workshop_download_item {A3_WORKSHOP_ID} {mod_id} validate",
                +" +quit",
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


if __name__ == "__main__":
    log("Backing up RPT")
    save_rpt()
    log(f"Updating A3 server ({A3_SERVER_ID})")
    # update_server()
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
