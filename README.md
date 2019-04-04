# Daily Job Scheduler (djs)



---
## LEGAL

Copyright (C) 2019, VR25 @ xda-developers

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

`djs` is a scheduling utility for commands and scripts.



---
## PREREQUISITES

- Magisk 17-19
- Terminal emulator running as root (su)



---
## SETUP

- Install
1. Flash live (e.g., from Magisk Manager) or from custom recovery (e.g., TWRP).

- Uninstall
1. Use Magisk Manager (app) or Magisk Manager for Recovery Mode (utility).



---
## USAGE


*Syntax*

`djs [daily|once] [hour] [minute] ["command(s)"]`

`djs [cancel] [all|daily|once] [schedule name]`

`djs [cancel] [All|Daily|Once]`

`djs [info]`

`djs info daily`

`djs info once`


*Details*

Time must be in 24 hours format.

For any of the arguments, except `["command(s)"]`, one can use only the first letter, e.g., `djs d 23 00 "reboot -p"` — shutdown the system at 23:00, daily.

A schedule name has the format `[hour][minute]` , e.g., /data/media/djs/`2230` (runs daily), /dev/djs/`1218` (runs once).

Run `djs i` to see all schedules. An additional argument to this dictates whether only run-once or run-daily schedules should be shown.

`[All|Daily|Once]` refer to schedule types. e.g., `djs c A` — cancel all run-once and run-daily schedules; `djs c D` — cancel all daily schedules; `djs c O` — cancel all run-once schedules.

Daily schedules have two components — the run-once part and the run-daily part.
The command `djs cancel all <schedule name>` cancels both schedules (run-once and run-daily) — e.g., `djs c b 1230`.
To cancel only one of the schedules, run `djs cancel [once|daily] [schedule name]`.

Missed schedules have a 5 minutes grace period.



---
## LINKS

- [Donate](https://paypal.me/vr25xda/)
- [Facebook page](https://facebook.com/VR25-at-xda-developers-258150974794782/)
- [Git repository](https://github.com/Magisk-Modules-Repo/djs/)
- [Telegram channel](https://t.me/vr25_xda/)
- [Telegram profile](https://t.me/vr25xda/)



---
## LATEST CHANGES

**2019.4.4 (201904040)**
- Updated information (copyright, module description and prerequisites)

**2019.4.1 (201904010)**
- Fixed `awk not found`.
- Magisk 19 support
- Major optimizations
- Updated debugging and building tools
- Updated documentation

**2019.2.27 (201902270)**
- Fixed: parameters being shifted earlier than they should.
