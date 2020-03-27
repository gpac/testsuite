#!/bin/sh

test_begin "dash-xlink"

if [ $test_skip  = 1 ] ; then
return
fi

do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:dur=2 -new $TEMP_DIR/remote.mp4" "dash-input-preparation"

do_test "$MP4BOX -dash 1000 -profile live $TEMP_DIR/remote.mp4 -out $TEMP_DIR/remote.mpd" "dash-remote"
do_hash_test "$TEMP_DIR/remote.mpd" "mpd"

cp $TEMP_DIR/remote.mp4 $TEMP_DIR/main2.mp4
mv $TEMP_DIR/remote.mp4 $TEMP_DIR/main.mp4
do_test "$MP4BOX -dash 1000 -profile live $TEMP_DIR/main.mp4:period=1 :period=2:xlink=remote.mpd:pdur=2 $TEMP_DIR/main2.mp4:period=3 -out $TEMP_DIR/file.mpd" "dash-xlink"
do_hash_test "$TEMP_DIR/remote.mpd" "mpd"


myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:deep:interleave=false:dur=6/1:log=$myinspect" "inspect"
do_hash_test $myinspect "inspect"

test_end
