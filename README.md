# Daily Job Scheduler (djs)
## Copyright (C) 2019, VR25 @ xda-developers
### License: GPL V3+
#### README.md



---
#### DISCLAIMER

This software is provided as is, in the hope that it will be useful, but without any warranty. Always read/reread this reference prior to installing/upgrading.
While no cats have been harmed, I assume no responsibility under anything which might go wrong due to the use/misuse of it.

A copy of the GNU General Public License, version 3 or newer ships with every build. Please, study it prior to using, modifying and/or sharing any part of this work.

To prevent fraud, DO NOT mirror any link associated with this project; DO NOT share ready-to-flash-builds (zips) on-line!



---
#### DESCRIPTION


*Syntax*

`djs [daily|once] [hour] [minute] ["command(s)"]`

`djs [cancel] [all|daily|once] [schedule name]`

`djs [cancel] [All|Daily|Once]`

`djs [info]`

`djs info daily`

`djs info once`


*Details*

Time must be in 24 hours format.

For any of the arguments, except `["command(s)"]`, one can use only the first letter, e.g., `djs d 23 00 "am start -n android/com.android.internal.app.ShutdownActivity"` — shutdown the system at 23:00, daily.

A schedule name has the format `[hour][minute]` , e.g., /data/media/djs/`2230` (runs daily), /dev/djs/`1218` (runs once).

Run `djs i` to see all schedules. An additional argument to this dictates whether only run-once or run-daily schedules should be shown.

`[All|Daily|Once]` refer to schedule types. e.g., `djs c A` — cancel all run-once and run-daily schedules; `djs c D` — cancel all daily schedules; `djs c O` — cancel all run-once schedules.

Daily schedules have two components — the run-once part and the run-daily part.
The command `djs cancel all <schedule name>` cancels both schedules (run-once and run-daily) — e.g., `djs c b 1230`.
To cancel only one of the schedules, run `djs cancel [once|daily] [schedule name]`.

Missed schedules have a 5 minutes grace period.



---
#### PRE-REQUISITES

- Magisk 17.0+
- Terminal emulator running as root (su)



---
#### SETUP STEPS

- Install
1. Flash the zip in Magisk Manager or custom recovery.
2. Reboot.

- Uninstall
1. Use Magisk Manager (app) or Magisk Manager for Recovery Mode (utility).
2. Reboot.
3. Remove `/data/media/0/djs/` (optional).



---
#### LINKS

- [Donate](https://paypal.me/vr25xda/)
- [Facebook page](https://facebook.com/VR25-at-xda-developers-258150974794782/)
- [Git repository](https://github.com/Magisk-Modules-Repo/djs/)
- [Telegram channel](https://t.me/vr25_xda/)
- [Telegram profile](https://t.me/vr25xda/)



---
#### LATEST CHANGES

**2019.2.27 (201902270)**
- Fixed: parameters being shifted earlier than they should.

**2019.2.24 (201902240)**
- Initial release
