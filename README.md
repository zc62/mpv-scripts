# mpv-scripts
Scripts for [mpv](https://github.com/mpv-player/mpv)

## ~~autoloop.lua~~
~~Work on issue [mpv-player/mpv#5222](https://github.com/mpv-player/mpv/issues/5222).~~
~~Automatically loops files that are under a given duration (default 5 seconds).~~

Probably you would like to use [`auto-profiles.lua`](https://github.com/wiiaboo/mpv-scripts/blob/master/auto-profiles.lua), which is general-purpose and can achieve the same goal easily.

## screenshot-to-clipboard.js
Work on issue [mpv-player/mpv#5330](https://github.com/mpv-player/mpv/issues/5330).
Generates a temp screenshot file on desktop then copy to clipboard. (Windows only)

## save-sub-delay.lua
This script saves the sub-delay quantity for each file. When next time the file is opened, sub-delay is automatically restored.

## exit-fullscreen.lua
If you use `--keep-open=yes`, this script exits fullscreen mode when the playback reaches the end of file/playlist.
