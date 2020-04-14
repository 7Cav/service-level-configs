<p align="center"><img src="https://github.com/7Cav/service-level-configs/blob/master/media/S6_SLC_Logo.png"></p>

# About

Service Level Configs is a framework for configuration files and scripts that are in use to manage the 7th Cavalry Gameservers.
This monorepo is specifically for S3 and S6 Staff to use for any modifications for Gameserver Parameters, Game Mods, And other features.
Currently Work-In-Progress, Expect features to change.

## Getting Started
To utilize this Mono-Repository, we encourage you to download Github desktop and VScode.

For changes to Game Configurations the following is required.
1. You must be in a approved S3 or S6 Billet
2. Are apart of the 7Cav github organization

### Configurations:
Configurations are managed by using JSON. 
*JavaScript Object Notation* (JSON) is our way of storing the configurations for each server instance.

For more information about these types of files [Click Here](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Objects/JSON)

### Where to find Configurations:
To change the configuration of a given gameserver you will need to find the JSON file for it.<br></br>
The current convention is ``/<Server Name>/<Game Name>/<Gameserver Type>/<Gameserver Name .json>``<br></br>
*example:* ``service-level-configs/mtreck/arma3/public/tacticalrealism2.json``

Once you have located the json configuration file, you will need to either clone the repository or make changes via the github website.

## Editing JSON configs
JSON configurations will have the following formatting:

```json
{
    "server": {
        "env": {
            "SERVER_ID": "GameServer1",
            "SERVER_NAME": "DefaultGameServer",
            "IP_ADDRESS": "192.168.0.1",
            "PORT": "8080"
           }
         }
}
```
When editing our JSON configurations, keep in mind that there are Keys and Values. You will only be needed to edit values unless 
otherwise noted.

Keys:
```json
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
```json
{
"config": {
    "key0": "value",
    "key1": "I love the cav",
    "key2": "false"
  }
}
```
Here we have the values added to the keys. 

``"key0":`` = ``"value"``,
``"key1":`` = ``"I love the cav"``,
``"key2":`` = ``"false"``

Take note that the values can be boolean (true / false) or strings "this is a string of text"<br></br>
While this is simplifying the terminology its sufficent for editing these JSON configurations.

## Troubleshooting:
<p align="center"><img width=100% src="https://github.com/7Cav/service-level-configs/blob/master/media/TS_flow.png"></p>

## Further Documentation
For more detailed information, Check the Service-Level-Configs Wiki
