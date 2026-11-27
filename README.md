# QCDE-Server-Launcher

A Bash-based launcher script for hosting different types of QC:Doom Edition servers on Linux.  
  
The launcher provides an interactive, text-based interface for configuring and starting servers, as well as command-line options for automated or unattended startup.  
  
## Features

- Interactive server setup
- Easily host multiple game modes - PvP and PvE
- Simple game file and map rotation configuration
- Switches for popular QC:DE add-ons, map packs and mutators
- Automatic detection of missing game files, with optional downloading
- Includes `tspg-get`, a utility to quickly download files hosted on TSPG
  
## Requirements

For this script to work correctly, the following dependencies are required:  
`bash`, `whiptail` and `wget`.
  
Additionally, the `Q-Zandronum` server has to be installed on the system.  
`git` is required, if you are following the recommended installation process.
  
## Installation

1. Install dependencies  
    - Debian/Ubuntu: `sudo apt install bash git whiptail wget`
    - Arch/Manjaro: `sudo pacman -S bash git libnewt wget`
    - Fedora/RHEL: `sudo dnf install bash git newt wget`
    - openSUSE: `sudo zypper install bash git newt wget`
    
2. Downloading the launcher  
```bash
cd ~
git clone https://github.com/kultasakaali/QCDE-Server-Launcher.git
```

3. Create symlinks  
To keep the cloned repository intact while still being able to run the scripts from anywhere, create symbolic links in `~/.local/bin` or another directory already included in your `$PATH`:
```bash
mkdir -p ~/.local/bin

ln -s "$(pwd)/qcde-server" ~/.local/bin/qcde-server
ln -s "$(pwd)/tspg-get" ~/.local/bin/tspg-get
```
You can now run the scripts simply by typing `qcde-server` or `tspg-get` in your terminal.  
If you do not wish to create symlinks, you can also use an alias.

## Updates
Using symlinks makes updating the launcher and its default configurations very simple.
```bash
cd QCDE-Server-Launcher
git pull
```
Please note that this method will not update or overwrite any of the configuration files in the configuration directory.  
This is done to protect your custom settings.  
  
If you haven't modified the default configuration, you can remove it to have the launcher copy the updated default configuration on its next run:
```bash
rm "${XDG_CONFIG_HOME:-$HOME/.config}/qcde-server/qcde-server.conf"
```

## Configuration
On the first run, `qcde-server_default.conf` is copied to:

- `~/.config/qcde-server/qcde-server.conf`, or
- `$XDG_CONFIG_HOME/qcde-server/qcde-server.conf`, if `$XDG_CONFIG_HOME` is defined.
  
You can edit this configuration to customize:
    - Engine executable locations
    - Mod files
    - Game file directories
    - Map rotations
  
> Note: Using the default game file directories is highly recommended. If you would like to keep your game files elsewhere, make sure to add those directories to your `~/.config/zandronum/zandronum.ini` under the `[IWADSearch.Directories]` and `[FileSearch.Directories]` sections. The launcher relies on these search paths and passes only file names to the engine without specifying their paths.
  
You can maintain multiple configuration files in the configuration directory. Use the `-c` command line option to load configurations other than the default one.
```bash
qcde-server -c qcde_3.0.conf
```
  
> Note: Configuration files are Bash scripts and are sourced by the launcher. Only use configuration files you trust.

## Usage

### Interactive mode
  
Simply start the launcher without command line arguments.  
The interface will guide you through the setup process, allowing you to select the engine, game mode, maps and monsters for PvE and additional switches.  
Before starting the server, you can review and edit the generated command line.  

### Command line mode

You can bypass the interactive interface by supplying command-line arguments.  
  
For example, to start a Q-Zandronum FFA server:
```bash
qcde-server -e Q-Zandronum -g FFA
```
  
Additional server arguments can be passed after `--`.  
These are passed directly to the server executable:
```bash
qcde-server -e Q-Zandronum -g FFA -- +sv_maxplayers 16 +sv_forcepassword true
```

## Command-line options

|Option           |Description                                            |
|-----------------|-------------------------------------------------------|
|`-c <config>`    |Specify a launcher configuration file to use.          |
|`-e <engine>`    |Choose the `engine` to use.                            |
|`-g <gamemode>`  |Choose the `game mode` to host.                        |
|`-h`             |Display usage info.                                    |
|`-A`             |Load and use the AeonDM map pack.                      |
|`-N`             |Load and use the NeonDM map pack.                      |
|`-S`             |Enable the StackLeft option.                           |
|`-I`             |Enable the ItemTimers option.                          |
|`-U`             |Enable the Unreal Tournament weapons add-on.           |

Supported values for options that require arguments are:

|Option   |Argument                                                                                                                  |
|---------|--------------------------------------------------------------------------------------------------------------------------|
|Engine   |`Zandronum` or `Q-Zandronum`                                                                                              |
|Game mode|`FFA`, `TDM`, `Duel`, `Survival`, `ClanArena`, `InstaGib`,<br>`FreezeTag`, `LGPractice`, `Invasion`, `Dominatrix` or `CTF`|
|Config   |Any non-default launcher configuration file should be placed in `~/.config/qcde-server` or `$XDG_CONFIG_HOME/qcde-server` |

## TSPG-GET

`tspg-get` is a small utility originally written by [Klaufir](https://github.com/klaufir216).  
It can be used to download files hosted on [The Sentinel's Playground](https://allfearthesentinel.com/).

### Usage

```bash
tspg-get <filename> [destination-directory]
```
If the destination is not specified, the script defaults to `~/.config/zandronum`.  
  
#### Notes:
    - Specify file names as they are uploaded to TSPG
    - Existing files will **not** be overwritten
    - If the destination directory doesn't exist, it will be created
