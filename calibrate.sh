#!/bin/bash
WIN_CLASS="pinned-terminal"
WIN_W=1600
WIN_H=800
MARGIN_BOTTOM=40  # adjust if panel overlaps

WIDS=($(xdotool search --class "$WIN_CLASS"))

if [ ${#WIDS[@]} -gt 0 ]; then
    WID=${WIDS[-1]}
    wmctrl -i -a "$WID"
else
    gnome-terminal --class="$WIN_CLASS" &
    sleep 0.8

    NEW_WIDS=($(xdotool search --class "$WIN_CLASS"))
    WID=${NEW_WIDS[-1]}

    # Resize first, then measure what we actually got
    xdotool windowsize "$WID" $WIN_W $WIN_H
    sleep 0.2
    eval $(xdotool getwindowgeometry --shell "$WID")
    ACTUAL_W=$WIDTH
    ACTUAL_H=$HEIGHT

    # Get logical desktop size in the SAME coordinate space xdotool uses for windowmove
    read LOG_W LOG_H <<< $(xdotool getdisplaygeometry)

    X=$((LOG_W - ACTUAL_W))
    Y=$((LOG_H - ACTUAL_H - MARGIN_BOTTOM))

    xdotool windowmove "$WID" $X $Y
    REQ_X=$X
    REQ_Y=$Y

    # Verify and report back what actually happened
    sleep 0.2
    eval $(xdotool getwindowgeometry --shell "$WID")
    echo "Requested: X=$REQ_X Y=$REQ_Y"
    echo "Actual position: X=$X Y=$Y W=$WIDTH H=$HEIGHT"
    echo "Logical desktop: ${LOG_W}x${LOG_H}"
fi

eval $(xdotool getwindowgeometry --shell "$WID")

cat <<EOF

# Copy-paste into your main script:
POS_X=$X
POS_Y=$Y
WIN_W=$WIDTH
WIN_H=$HEIGHT
EOF
