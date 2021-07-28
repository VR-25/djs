# Daily Job Scheduler (DJS)


---
## DESCRIPTION

DJS runs scripts and/or commands on boot or at set HH:MM (e.g, 23:59).
Any root solution is supported.
The installation is always "systemless", whether or not the system is rooted with Magisk.


---
## LEGAL

Copyright (C) 2019-2021, VR25

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

To prevent fraud, do NOT mirror any link associated with this project; do NOT share builds (tarballs/zips)! Share official links instead.


---
## WARNING

The author assumes no responsibility under anything that might break due to the use/misuse of this software.
By choosing to use/misuse it, you agree to do so at your own risk!


---
## DONATIONS

Please, support the project with donations (`## LINKS` at the bottom).
As the project gets bigger and more popular, the need for coffee goes up as well.


---
## PREREQUISITES

- Android or Android based OS
- Any root solution (e.g., [Magisk](https://github.com/topjohnwu/Magisk/))
- [Busybox\*](https://github.com/search?o=desc&q=busybox+android&s=updated&type=Repositories/) (only if not rooted with Magisk)
- Non-Magisk users can enable djs auto-start by running /data/adb/vr25/djs/service.sh, a copy of, or a link to it - with init.d or an app that emulates it.
- Terminal emulator
- Text editor (optional)

\* A busybox binary can simply be placed in /data/adb/vr25/bin/.
Permissions (0700) are set automatically, as needed.
Precedence: /data/adb/vr25/bin/busybox > Magisk's busybox > system's busybox

Other executables or static binaries can also be placed in /data/adb/vr25/bin/ (with proper permissions) instead of being installed system-wide.


---
## CONFIGURATION (/data/adb/djs-data/config.txt)

```
// This is a comment line

// This is used to determine whether config should be patched. Do NOT modify!
versionCode=201908180

// Schedule Examples

// Run on boot
// boot touch /data/I-was-born-on-boot; : --delete
// ": --delete" is optional; it means "delete the schedule after execution" - effectively turning it into a one-time boot schedule.

// Apply Advanced Charging Controller night settings at 22:00
//2200 acc 45 44 && acc --set applyOnPlug usb/current_max:500000

// Restore regular ACC settings at 6:00 (morning)
//0600 acc 80 70 && acc -s applyOnPlug 2000000; : --boot
// ": --boot" is optional; it lets this schedule run on boot as well (fail-safe).
```

---
## USAGE


If you feel uncomfortable with the command line, use a `text editor` to modify `/data/adb/djs-data/config.txt`.
Changes to this file take effect almost instantly, and without a [daemon](https://en.wikipedia.org/wiki/Daemon_(computing)) restart.


### Terminal Commands

```
Config Management

Usage: djsc|djs-config OPTION ARGS

-a|--append 'LINE'
  e.g., djsc -a 2200 reboot -p

-d|--delete 'PATTERN' (all matching lines)
  e.g., djsc --delete 2200

-e|--edit EDITOR OPTS (fallback: nano -l|vim|vi)
  e.g., djs-config --edit vim

-l|--list 'PATTERN' (default ".", meaning "all lines")
  e.g., djsc -l '^boot'


Daemon Management

Start/restart: djsd|djs-daemon
Stop: djsd.|djsd-stop
Status: djsd,|djsd-status


Print Version Code (integer)

djsv
djs-version


Notes
- All commands return either 0 (success/running) or 1 (failure/stopped).
- djsd-status prints the daemon's process ID (PID).
- Special shell characters (e.g., "|", ";", "&") must be quoted or escaped. For the sake of simplicity and consistency, single-quote all arguments as a whole (e.g., djsc -a '2200 reboot -p').
```

---
## NOTES/TIPS FOR FRONT-END DEVELOPERS

Use `/dev/.vr25/djs/*` over regular commands.
These are guaranteed to be readily available after installation/initialization.

It may be best to use long options over short equivalents - e.g., `/dev/.vr25/djs/djs-config --list`, instead of `/dev/.vr25/djs/djsc -l`.
This makes code more readable (less cryptic).

Include provided descriptions of DJS features/settings in your app(s).
Provide additional information (trusted) where appropriate.
Explain settings/concepts as clearly and with as few words as possible.


---
## FREQUENTLY ASKED QUESTIONS (FAQ)


> How do I report issues?

Open issues on GitHub or contact the developer on Telegram/XDA (linked below). Always provide as much information as possible.


---
## LINKS

- [Facebook page](https://facebook.com/VR25-at-xda-developers-258150974794782/)
- [Git repository](https://github.com/VR-25/djs/)
- [Liberapay](https://liberapay.com/VR25/)
- [Patreon](https://patreon.com/vr25/)
- [PayPal](https://paypal.me/vr25xda/)
- [Telegram channel](https://t.me/vr25_xda/)
- [Telegram profile](https://t.me/vr25xda/)


---
## LATEST CHANGES


**2019.7.1 (201907010)**

- Ability to run commands/scripts on boot
- Enhanced efficiency and reliability
- Major optimizations
- More intuitive config and daemon management commands
- Updated documentation


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


**2021.7.28 (202107280)**

- Fixed issues.
- Major refactoring
- Updated framework and documentation.
