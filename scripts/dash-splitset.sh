#!/bin/sh

test_begin "dash-splitset"
if [ $test_skip  = 1 ] ; then
return
fi

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_640x360_192kbps.264 -o $TEMP_DIR/file.mpd:profile=live" "dash"
do_hash_test $TEMP_DIR/file.mpd "MPD"

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd:split_as inspect:allp:deep:interleave=false:dur=2/1:log=$myinspect" "inspect"
do_hash_test $myinspect "inspect"

test_end
