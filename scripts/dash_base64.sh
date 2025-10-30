#!/bin/sh


test_begin "dash-base64"
if [ $test_skip != 1 ] ; then

src=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264
do_test "$MP4BOX -dash 1000 -profile live -out $TEMP_DIR/file.mpd:dual:base64 $src" "dash"

do_hash_test $TEMP_DIR/file.mpd "mpd"
do_hash_test $TEMP_DIR/file_1.m3u8 "m3u8"

myinspect=$TEMP_DIR/inspect_dash.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:deep:log=$myinspect" "inspect-dash"
do_hash_test $myinspect "inspect-dash"

myinspect=$TEMP_DIR/inspect_hms.txt
do_test "$GPAC -i $TEMP_DIR/file.m3u8 inspect:deep:log=$myinspect" "inspect-hls"
do_hash_test $myinspect "inspect-hls"

fi
test_end


