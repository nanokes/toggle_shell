#!/bin/bash
exec 200>/tmp/toggle_shell.sh.lock
flock -n 200 || exit 0

WIN_CLASS="pinned-terminal"
POS_X=3544
POS_Y=2074
WIN_W=1596
WIN_H=786

WIDS=($(xdotool search --class "$WIN_CLASS"))

if [ ${#WIDS[@]} -gt 0 ]; then
    WID=${WIDS[-1]}
    wmctrl -i -a "$WID"
else
    gnome-terminal --class="$WIN_CLASS" &
    WID=$(xdotool search --sync --class "$WIN_CLASS" | tail -1)

    # Window decorations effect this pos data, so we gotta adjust
    eval $(xdotool getwindowgeometry --shell "$WID")
    read LEFT RIGHT TOP BOTTOM <<< $(xprop -id "$WID" _NET_FRAME_EXTENTS | awk -F'= ' '{print $2}' | tr -d ',')

    ADJ_Y=$((POS_Y - TOP))
    ADJ_H=$((WIN_H + TOP + BOTTOM))

    xdotool windowmove "$WID" $POS_X $ADJ_Y
    xdotool windowsize "$WID" $WIN_W $ADJ_H
fi
