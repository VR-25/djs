# Daily Job Scheduler (DJS)



---
## LEGAL

Copyright (c) 2019, VR25 (xda-developers.com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.



---
## DISCLAIMER

Always read/reread this reference prior to installing/upgrading this software.

While no cats have been harmed, the author assumes no responsibility for anything that might break due to the use/misuse of it.

To prevent fraud, do NOT mirror any link associated with this project; do NOT share builds (zips)! Share official links instead.



---
## DESCRIPTION

DJS runs scripts and/or commands on boot or at set HH:MM (e.g, 23:59).



---
## PREREQUISITES

- Android or Android based OS
- Any root solution (e.g., Magisk)
- Busybox (only if not rooted with Magisk)
- Terminal emulator (e.g., Termux)
- Text editor (optional)



---
## BUILDING AND/OR INSTALLING FROM SOURCE


### Dependencies

- git, wget, or curl
- zip


### Build Tarballs and Flashable Zips

1. Download the source code: `git clone https://github.com/VR-25/djs.git` or `wget  https://github.com/VR-25/djs/archive/$reference.tar.gz -O - | tar -xz` or `curl -L#  https://github.com/VR-25/djs/archive/$reference.tar.gz | tar -xz`
2. `cd djs*`
3. `sh build.sh` (or double-click `build.bat` on Windows 10, if you have Windows subsystem for Linux installed)


#### Notes

- build.sh automatically sets/corrects `id=*` in `*.sh` and `update-binary` files.

- The output files are (in `_builds/djs-$versionCode/`): `djs-$versionCode.zip`, `djs-$versionCode.tar.gz`, and `install-tarball.sh`.

- To update the local repo, run `git pull --force`.


### Install from Local Sources and GitHub

- `sh install-tarball.sh djs` installs the tarball (djs*gz) sitting next to it. The archive must be obtained from GitHub: https://github.com/VR-25/djs/archive/$reference.tar.gz ($reference examples: master, dev, 201908290).

- `sh install-current.sh` installs djs from the script's location.

- `sh install-latest.sh [-c|--changelog] [-f|--force] [-n|--non-interactive] [%install dir%] [reference]` downloads and installs djs from GitHub. e.g., `sh install-latest.sh dev`


#### Notes

- `install-current.sh` and `install-tarball.sh` take an optional parent installation path argument (e.g., sh install-current.sh /data - this will install djs to /data/djs/).

- `install-latest.sh` is a back-end to `djs --upgrade` (WIP).

- The order of arguments doesn't matter.

- The default parent installation paths, in order of priority, are: /data/data/mattecarra.djsapp/files/, /sbin/.magisk/modules/, /sbin/.core/img/ and /data/adb/.

- No argument/option is mandatory. The exception is `--non-interactive` for front-ends. Additionally, unofficially supported front-ends must specify the parent installation path.

- Recall that unlike the other two installers, `install-latest.sh` requires the installation path to be enclosed in `%` (e.g., sh install-latest.sh %/data% --non-interactive).

- The `--force` option (install-latest.sh) is meant for reinstallation and downgrading.

- `sh install-latest.sh --changelog --non-interactive` prints the version code (integer) and changelog URL (string) when an update is available. In interactive mode, it also asks the user whether they want to download and install the update.

- You may want to take a look at `NOTES/TIPS FOR FRONT-END DEVELOPERS > Exit Codes` below, too.



---
## SETUP


### Any Root Solution

Install/upgrade: unless Magisk is not installed, always install/upgrade from Magisk Manager or dedicated DJS front-end; apps such as EX Kernel Manager and FK Kernel Manager are also good options.

Uninstall: depending o the installed variant, you can run `su -c djs --uninstall` or flash `/sdcard/djs-uninstaller.zip` (both are universal), use Magisk Manager (app) or [Magisk Manager for Recovery Mode (utility)](https://github.com/VR-25/mm/), or clear the front-end app data. The flashable uninstaller works everywhere - Magisk Manager, kernel managers, TWRP, etc..


### Notes

DJS supports live upgrades - meaning, rebooting after installing/upgrading is unnecessary.

The daemon is automatically started right after installation.

For non-Magisk install, [busybox](https://duckduckgo.com/?q=busybox+android) binary is required. Additionally, `$installDir/djs/djs-init.sh` must be executed on `boot_completed` to initialize djs; without this, djs commands won't work.



---
## CONFIGURATION (/data/adb/djs-data/config.txt)

```
// This is a comment line

// This s used to determine whether config should be patched. Do NOT modify!
versionCode=201908180

// Schedule Examples

// Run on boot
// boot touch /data/I-was-born-on-boot; : --delete
// ": --delete" is optional; it means "delete the line/schedule after execution".

// Apply Advanced Charging Controller night settings at 22:00
//2200 acc 45 44 && acc --set applyOnPlug usb/current_max:500000

// Restore regular ACC settings at 6:00 (morning)
//0600 acc 80 70 && acc -s applyOnPlug 2000000; : --boot
// ": --boot" is optional; it lets this schedule run on boot as well (fail-safe).
```


---
## USAGE


If you feel uncomfortable with the command line, you can use a `text editor` to modify `/data/adb/djs-data/config.txt`. Changes to this file take effect almost instantly, and without a [daemon](https://en.wikipedia.org/wiki/Daemon_(computing)) restart.


### Terminal Commands

```
DJS Config Tool

Usage: djsc|djs-config OPTION ARGS

-a|--append 'LINE'
  e.g., djsc -a 2200 reboot -p

-d|--delete 'PATTERN' (all matching lines)
  e.g., djsc --delete 2200

-e|--edit EDITOR OPTS (fallback: nano -l|vim|vi)
  e.g., djs-config --edit vim

-l|--list 'PATTERN' (default ".", meaning "all lines")
  e.g., djsc -l '^boot'


DJS Daemon Management Commands

Start/restart: djsd
Stop: djsd.|djsd-stop
Status: djsd,|djsd-status


Print Version Code (integer)

djs-version


Notes
- All commands return either 0 (success/running) or 1 (failure/stopped).
- djsd-status prints the daemon's process ID (PID).
- Special shell characters (e.g., "|", ";", "&") must be quoted or escaped. For the sake of simplicity and consistency, single-quote all arguments as a whole (e.g., djsc -a '2200 reboot -p').
```


---
## NOTES/TIPS FOR FRONT-END DEVELOPERS


It's best to use full commands over short equivalents - e.g., `djs-config --list` instead of `djsc -l`. This makes your code more readable (less cryptic).

Use provided config descriptions for DJS settings in your app(s). Include additional information (trusted) where appropriate.


### Online DJS Install

```
1) Check whether DJS is installed (exit code 0)
which djsd > /dev/null

2) Download the installer (https://raw.githubusercontent.com/VR-25/djs/master/install-latest.sh)
- e.g., curl -#LO URL or wget -O install-latest.sh URL

3) Run "sh install-latest.sh" (installation progress is shown)
```

### Offline DJS Install

Refer to the `BUILDING AND/OR INSTALLING FROM SOURCE` section above.


### Officially Supported Front-ends

- ACC App (installDir=/data/data/mattecarra.djsapp/files/djs/)


### Exit Codes

0. True or success
1. False or general failure
3. Missing busybox binary
4. Not running as root
5. Update available
6. No update available
7. Installation path not found



---
## FREQUENTLY ASKED QUESTIONS (FAQ)


> How do I report issues?

Open issues on GitHub or contact the developer on Telegram/XDA (linked below). Always provide as much information as possible.



---
## LINKS

- [Donate](https://paypal.me/vr25xda/)
- [Facebook page](https://facebook.com/VR25-at-xda-developers-258150974794782/)
- [Git repository](https://github.com/VR-25/djs/)
- [Telegram channel](https://t.me/vr25_xda/)
- [Telegram profile](https://t.me/vr25xda/)



---
## LATEST CHANGES
**2021.02.10 (202102100)**
- Quick and dirty hack to get djs running on Android 11


**2019.10.18 (201910180)**
- `: --boot` and `: --delete` flags
- Attribute back-end files ownership to front-end app
- Automatically copy installation log to <front-end app data>/files/logs/
- Back-end can be upgraded from Magisk Manager, EX/FK Kernel Manager, and similar apps
- `bundle.sh` - bundler for front-end app
-  `djs-version`: prints `versionCode` (integer)
- Fixed schedule deletion and busybox handling issues
- Flashable uninstaller: `/sdcard/djs-uninstaller.zip`
- Major optimizations
- Prioritize `nano -l` for text editing
- Richer installation and initialization logs (/data/adb/djs-data/logs/)
- Updated `build.sh` and documentation
- Workaround for front-end autostart blockage (Magisk service.d script)

**2019.7.1 (201907010)**
- Ability to run commands/scripts on boot
- Enhanced efficiency and reliability
- Major optimizations
- More intuitive config and daemon management commands
- Updated documentation

**2019.4.4 (201904040)**
- Updated information (copyright, description & prerequisites)
