# QCDE-Server-Launcher

This is a bash script to assist in hosting several different types of QC:DE servers.  
  
If ran without arguments, you can use the text-based user interface  
to aid you through the process of setting up your server.  
  
You can also pass command line options to the utility which will bypass the  
user interface and launch the server using the settings passed to it.  

|Option         |Description                                            |
|---------------|-------------------------------------------------------|
|-e <engine>    |Choose the `engine` to use.                            |
|-g <gamemode>  |Choose the `game mode` to host.                        |
|-h             |Display usage info.                                    |
|-A             |Load and use the AeonDM map pack.                      |
|-N             |Load and use the NeonDM map pack.                      |
|-S             |Enable the StackLeft option.                           |
|-I             |Enable the ItemTimers option.                          |
|-U             |Enable the Unreal Tournament wepons add-on.            |

Supported values for options, that require arguments are:

|Option   |Argument                                                                                                                  |
|---------|--------------------------------------------------------------------------------------------------------------------------|
|Engine   |`Zandronum` or `Q-Zandronum`                                                                                              |
|Game mode|`FFA`, `TDM`, `Duel`, `Survival`, `ClanArena`, `InstaGib`,<br>`FreezeTag`, `LGPractice`, `Invasion`, `Dominatrix` or `CTF`|
