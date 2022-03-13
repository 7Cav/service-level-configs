<p align="center"><img src="https://github.com/7Cav/service-level-configs/blob/develop/media/S6_SLC_Logo_2.png"></p>

[![Valid Server Configs](https://github.com/7Cav/service-level-configs/actions/workflows/json-validate.yml/badge.svg)](https://github.com/7Cav/service-level-configs/actions/workflows/json-validate.yml)

# About

Service Level Configs is a framework for configuration files and scripts that are in use to manage the 7th Cavalry gameservers.
This is specifically for S3 and S6 Staff within the 7cav.us community to use for any modifications such as but not limited to,<br></br> 

* Gameserver startup parameters,
* Mods and or DLCs installed
* Miscellaneous configuration files
* Updater scripts
<br></br>
This is constantly a Work-In-Progress, expect features to change.

## Getting Started
To utilize this framework, If you do not have your own tools for working with github and json files we encourage you to download [Github desktop](https://desktop.github.com/) and [VScode](https://code.visualstudio.com/)<br></br>

For changes to Game Configurations the following is required.
1. You must be in a approved S3 or S6 Billet
2. Are apart of the 7Cav github organization

If you feel you should have access but currently do not, contact your CoC for information.

## JSON
Configurations are managed by using JSON.<br></br> 
*JavaScript Object Notation* (JSON) is our way of storing the configurations for each server instance.<br></br>
For more information about these types of files [Click Here](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Objects/JSON)

## Where is the modlist JSON?
To change the configuration of a given gameserver's modlist you will need to find the JSON file for it.<br></br>
The current convention is ``/<Server Name>/<Game Name>/<Gameserver Type>/<Gameserver Name/Modlist Name.json>``<br></br>
*example:* ``service-level-configs/novak/arma3/public/tacticalrealism2.json``<br></br>
Once you have located the json configuration file, you will need to either clone the repository or make changes via the github website.

## Editing JSON modlists
JSON modlists will have the following formatting:

```js
{
  "mods":{
        "@mod_name":"workshop_id",
        "@mod_name":"workshop_id"
    }
}
```
When editing our JSON configurations, keep in mind that there are Keys and Values. The items on the left of the colon are keys, the items to the right are values

Keys:
```js
{
"config": {
    "mykey": "",
    "mykey2": "",
    "yetanotherkey": ""
  }
}
```
As you can see in this example above, we have the ``"config":`` key and within config we have ``"mykey1":``,``"mykey2":``,``"yetanotherkey":``

Values:
```js
{
"config": {
    "key0": "value",
    "key1": "Killroywashere",
    "key2": "false"
  }
}
```
Here we have the values added to the keys. 

``"key0":`` = ``"value"``,
``"key1":`` = ``"Killroywashere"``,
``"key2":`` = ``"false"``

Take note that the values can be boolean (true / false) or strings "this is a string of text"<br></br>
Keys can be arrays such as ``"key": { }`` in which these can also contain multiple keys with values or even more nested arrays.<br></br>
*Example:* ``"key": { "keyA": { "Key1": "value" }, "keyB": { "Key2": "value" } }`` which gives you ``"key"`` with 4 keys inside nested arrays.

## Don't Forget the Comma!
A typical issue with editing JSON files is forgetting what the comma does for a given key and value within the JSON configurations.<br></br>
```js
{
    "server": {
        "env": {
            "SERVER_ID": "value",
            "SERVER_NAME": "value",
            "IP_ADDRESS": "value",
            "PORT": "value",
            "PARAMETERS": "value"
            },
        "cfg": {
            "Max_Bandwidth": "value",
            "Min_Bandwidth": "value",
            }
           }
}
```
The above is the correct formatting for json files.<br></br>
Note that the ``"SERVER_ID": "value",`` has a comma on the end of the value but the ``"PARAMETERS": "value"`` does not.<br></br>
This is because the ``"PARAMETERS": "value"`` is the last key within that array. the array being the key ``"env"``<br></br>
You can also note that ``"env":`` is also within the ``"server"`` array. This means that if its not the only Key within that array then you need to place a comma at the end of the ``}`` which indicates the end of that specific array.<br></br>
As shown above you can see that the ``}`` for ``"env":`` has a comma at the end of it as well, but the ``"cfg":`` and its ``}`` does not. You can think of the ``{`` as the start of a array and the ``}`` as the end of an array.

## Troubleshooting:
Contact S6 with any issues regarding changing or creating new modsets


## Further Documentation
For more detailed information, Check the [Service-Level-Configs Wiki](https://github.com/7Cav/service-level-configs/wiki)
