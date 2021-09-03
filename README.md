# Daily Job Scheduler (DJS)



- [DESCRIPTION](#description)
- [LICENSE](#license)
- [DISCLAIMER](#disclaimer)
- [WARNING](#warning)
- [DONATIONS](#donations)
- [PREREQUISITES](#prerequisites)
- [CONFIGURATION (/data/adb/vr25/djs-data/config.txt)](#configuration-dataadbvr25djs-dataconfigtxt)
- [USAGE](#usage)
  - [Terminal Commands](#terminal-commands)
- [NOTES/TIPS FOR FRONT-END DEVELOPERS](#notestips-for-front-end-developers)
  - [Basics](#basics)
  - [Initializing DJS](#initializing-djs)
- [FREQUENTLY ASKED QUESTIONS (FAQ)](#frequently-asked-questions-faq)
- [LINKS](#links)
- [LATEST CHANGES](#latest-changes)


---
## DESCRIPTION

DJS runs scripts and/or commands on boot or at set HH:MM (e.g, 23:59).
Any root solution is supported.
The installation is always "systemless", whether or not the system is rooted with Magisk.


---
## LICENSE

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
along with this program. If not, see <https://www.gnu.org/licenses/>.


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

Please, support the project with donations ([links](#links) at the bottom).
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
## CONFIGURATION (/data/adb/vr25/djs-data/config.txt)

```
# This is a comment line.
# All lines that do not match a schedule instruction are ignored, regardless of the '#'.

# This is used to determine whether this file should be patched. Do NOT modify!
versionCode=201908180

# Schedule Examples

# Run on boot
#boot touch /data/I-was-born-on-boot; : --delete
# ": --delete" is optional; it means "delete the schedule after execution" - effectively turning it into a one-time boot schedule.

# Apply Advanced Charging Controller night settings at 22:00
#2200 acc pc=45 rc=44 mcc=500000 mcv=3920

# Restore regular ACC settings at 6:00 (morning)
#0600 acc pc=75 rc=70 mcc= mcv=; : --boot
# ": --boot" is optional; it makes this schedule run on boot as well (e.g., as part of a fail-safe plan).
```

---
## USAGE


If you feel uncomfortable with the command line, use a `text editor` to modify `/data/adb/vr25/djs-data/config.txt`.
Changes to this file take effect almost instantly, and without a [daemon](https://en.wikipedia.org/wiki/Daemon_(computing)) restart.


### Terminal Commands

```
Config Management

Usage: djsc|djs-config OPTION ARGS

-a|--append 'LINE'
  e.g., djsc -a 2200 reboot -p

-d|--delete ['regex'] (deletes all matching lines)
  e.g., djsc --delete 2200

-e|--edit [cmd] (fallback cmd: nano -l|vim|vi)
  e.g., djs-config --edit vim

-l|--list ['regex'] (fallback regex: ".", matches all lines)
  e.g., djsc -l '^boot'

-L|--log [cmd] (fallback cmd: tail -F)
  e.g., djsc -L cat > /sdcard/djsd.log


Daemon Management

Start/restart: djsd|djs-daemon
Stop: djs.|djs-stop
Status: djs,|djs-status


Print Version Code (integer)

djsv
djs-version


Notes
- All commands return either 0 (success/running) or 1 (failure/stopped).
- djs-status prints the daemon's process ID (PID).
- Special shell characters (e.g., "|", ";", "&") must be quoted or escaped. For the sake of simplicity and consistency, single-quote all arguments as a whole (e.g., djsc -a '2200 reboot -p').
- PATH starts with /data/adb/vr25/bin:/dev/.vr25/busybox.
This means schedules don't require additional busybox setup.
The first directory holds user executables.
```

---
## NOTES/TIPS FOR FRONT-END DEVELOPERS


### Basics

DJS does not require Magisk.
Any root solution is fine.

Use `/dev/.vr25/djs/*` over regular commands.
These are guaranteed to be readily available after installation/upgrades.

It may be best to use long options over short equivalents - e.g., `/dev/.vr25/djs/djs-config --list`, instead of `/dev/.vr25/djs/djsc -l`.
This makes code more readable (less cryptic).

Include provided descriptions of DJS features/settings in your app(s).
Provide additional information (trusted) where appropriate.
Explain settings/concepts as clearly and with as few words as possible.


### Initializing DJS

DJS is automatically initialized after installation/upgrades.
It needs to be initialized on boot, too.
If it's installed as a Magisk module, this is done by Magisk itself.
Otherwise, the front-end should handle it as follows:
```
on boot_completed receiver and main activity
  if file /dev/.acca/started does NOT exist
    create it
      mkdir -p /dev/.acca
      touch /dev/.acca/started
    if accd is NOT running
      launch it
        /data/adb/vr25/djs/service.sh
    else
      do nothing
  else
    do nothing
```
`/dev/` is volatile - meaning, a reboot/shutdown clears `/dev/.acca/` and its contents.
That's exactly what we want.
Of course, `/dev/.acca/started` is just an example.
One can use any random path (e.g., `.myapp/initialized`), as long as it's under `/dev/` and does not conflict with preexisting data.
**WARNING**: do not play with preexisting /dev/ data!
Doing so may result in data loss and/or other undesired outcome.


---
## FREQUENTLY ASKED QUESTIONS (FAQ)


> How do I report issues?

Open issues on GitHub or contact the developer on Telegram/XDA (linked below).
Always provide as much information as possible.


> Where do I find daemon logs?

`/dev/.vr25/djs/djsd.log`


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


**v2021.8.23 (202108230)**

- -L|--log [cmd] (default cmd: tail -F), djsd generates verbose (/dev/.vr25/djs/djsd.log).
- General fixes
- Major optimizations
- Updated documentation: now with a table of contents and available in HTML format.


**v2021.8.26 (202108260)**

- Fixed daemon startup issue.
- Updated framework (it uses acc's) and documentation


**v2021.9.3 (202109030)**

- Fixed "boot schedules not working" (thanks, @rhayy)
- Updated config examples
