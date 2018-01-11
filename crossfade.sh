#!/bin/bash

# Concatenate two videos. Fade both video in/out both video and audio.
# 
# Parameters clip1 clip2 fade xo
#
# clip1: first video clip
# clip2: second video clip
# fade: half fade duration
# xo: time offset in clip1 where clip2 starts

v0=$1
v1=$2

# half fade time
f=$3

# cross over time
xo=$4

x1=$((xo-f))
x3=$((xo+f))
echo "f=$f xo=$xo x1=$x1 x3=$x3"
ffmpeg -i $v0 -i $v1 -an \
-filter_complex \
"   [0:v]trim=start=0:end=${x1},setpts=PTS-STARTPTS[firstclip];
    [1:v]trim=start=${f},setpts=PTS-STARTPTS[secondclip];
    [0:v]trim=start=${x1}:end=${xo},setpts=PTS-STARTPTS[fadeoutsrc];
    [1:v]trim=start=0:end=${f},setpts=PTS-STARTPTS[fadeinsrc];
    [fadeinsrc]format=pix_fmts=yuva420p,      
                fade=t=in:st=0:d=1:alpha=1[fadein];
    [fadeoutsrc]format=pix_fmts=yuva420p,
                fade=t=out:st=0:d=1:alpha=1[fadeout];
    [fadein]fifo[fadeinfifo];
    [fadeout]fifo[fadeoutfifo];
    [fadeoutfifo][fadeinfifo]overlay[crossfade];
    [firstclip][crossfade][secondclip]concat=n=3[output];
    [0:a][1:a] acrossfade=d=1 [audio]
" \
-map "[output]" -map "[audio]" -strict -2 output.mp4

