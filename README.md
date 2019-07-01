# Daily Job Scheduler (djs)



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

- Any root solution
- Terminal emulator
- Text editor (optional)



---
## BUILDING FROM SOURCE


Dependencies

- curl (optional)
- git
- zip


Steps

1. `git clone https://github.com/VR-25/djs.git`
2. `cd djs`
3. `sh build.sh` (or double-click `build.bat` on Windows, if you have Windows subsystem for Linux installed)


Notes

- The output file is _builds/djs-$versionCode.zip.

- By default, `build.sh` auto-updates the [update-binary](https://raw.githubusercontent.com/topjohnwu/Magisk/master/scripts/module_installer.sh). To skip this, run `sh build.sh f` (or `buildf.bat` on Windows).

- To update the local repo, run `git pull -f`.

- To install/upgrade straight from source, refer to the next section.



---
## INSTALL/UNINSTALL


### Magisk 18.2+

Install/upgrade: flash live (e.g., from Magisk Manager) or from custom recovery (e.g., TWRP).

Uninstall: use Magisk Manager (app) or [Magisk Manager for Recovery Mode (utility)](https://github.com/VR-25/mm/).


### Any Root Solution (Advanced)

Install/upgrade: extract `djs-*.zip`, run `su`, then execute `sh /path/to/extracted/install-current.sh`.

Uninstall: for Magisk install, use Magisk Manager (app); else, run `su -c rm -rf /data/adb/djs/`.


### Notes

DJS supports live upgrades - meaning, rebooting after installing/upgrading is unnecessary.

The demon is automatically started after installation.

For non-Magisk install, `/data/adb/djs/djs-init.sh` must be executed on boot to initialize djs. Without this, djs commands won't work. Additionally, if your system lacks executables such as `awk` and `grep`, [busybox](https://duckduckgo.com/?q=busybox+android) or similar binary must be installed prior to installing djs.



---
## CONFIGURATION (/sdcard/djs/djs.conf)

```
# This is used to determine whether config should be patched. Do NOT modify!
versionCode=XXXXXXXXX


# Schedule formats and types

# boot <commands>
boot touch /sdcard/booted-successfully; touch /sdcard/try-it
boot sh /sdcard/my-script.sh

# HHMM <commands>
2200 reboot -p # Auto-shutdown daily at 22:00
2100 sh /sdcard/my-script.sh
```


---
## USAGE


If you feel uncomfortable with the command line, you can use a `text editor` to modify `/sdcard/djs/djs.conf`. Changes to this file take effect almost instantly, and without a [daemon](https://en.wikipedia.org/wiki/Daemon_(computing)) restart.


### Terminal Commands

```
DJS Config Tool

Usage: djsc|djs-config OPTION ARGS

-a|--append "LINE"
  e.g., djsc -a 2200 reboot -p

-d|--delete "PATTERN" (all matching lines)
  e.g., djsc --delete 2200

-e|--edit EDITOR OPTS (fallback: vim|vi|nano)
  e.g., djs-config --edit nano -l

-l|--list "PATTERN" (default ".", meaning "all lines")
  e.g., djsc -l "^boot"


DJS Daemon Management Commands

Start/restart: djsd

Stop: djsd.|djsd-stop

Status: djsd,|djsd-status


Notes
- All commands return either 0 (success/running) or 1 (failure/stopped).
- djsd-status prints the daemon's process ID (PID).
- Special shell characters (e.g., "|", ";", "&") must be quoted or escaped. For consistency, just quote all arguments (e.g., djsc -a "2200 reboot -p").
```


---
## NOTES/TIPS FOR FRONT-END DEVELOPERS


It's best to use full commands over short equivalents - e.g., `djs-config --append "LINE"` instead of `djsc -a "LINE"`. This makes your code more readable (less cryptic).

Use provided config descriptions for djs settings in your app(s). Include additional information (trusted) where appropriate.


### Online djs Install

- The installer must run as root (obviously).
- Log: /sbin/.djs/install-stderr.log
```
1) Check whether djs is installed (exit code 0)
which djsd > /dev/null

2) Download the installer (https://raw.githubusercontent.com/VR-25/djs/master/install-latest.sh)
- e.g., curl -#L [URL] > [output file] (progress is shown)

3) Run "sh [installer]" (progress is shown)
```

### Offline djs Install

Refer to [SETUP > Any Root Solution (Advanced)](https://github.com/VR-25/djs/tree/master#any-root-solution-advanced) and [SETUP > Notes ](https://github.com/VR-25/djs/tree/master#notes).



---
## FREQUENTLY ASKED QUESTIONS (FAQ)


- How do I report issues?

A: Open issues on GitHub or contact the developer on Telegram/XDA (linked below). Always provide as much information as possible.



---
## LINKS

- [Donate](https://paypal.me/vr25xda/)
- [Facebook page](https://facebook.com/VR25-at-xda-developers-258150974794782/)
- [Git repository](https://github.com/VR-25/djs/)
- [Telegram channel](https://t.me/vr25_xda/)
- [Telegram group](https://t.me/djs_magisk/)



---
## LATEST CHANGES

**2019.7.1 (201907010)**
- Ability to run commands/scripts on boot
- Enhanced efficiency and reliability
- Major optimizations
- More intuitive config and daemon management commands
- Updated documentation

**2019.4.4 (201904040)**
- Updated information (copyright, description & prerequisites)

**2019.4.1 (201904010)**
- Fixed: awk not found
- Magisk 19 support
- Major optimizations
- Updated debugging and building tools
- Updated documentation
