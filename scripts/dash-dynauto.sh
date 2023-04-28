#!/bin/sh

test_begin "dash-dynauto"

if [ $test_skip  = 0 ] ; then

$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:dur=2 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:dur=2 -new $TEMP_DIR/file.mp4 2> /dev/null

do_test "$GPAC -i $TEMP_DIR/file.mp4 -o $TEMP_DIR/live.mpd:dual:dynauto" "dash-gen"

do_hash_test $TEMP_DIR/live.mpd "mpd"
do_hash_test $TEMP_DIR/live_1.m3u8 "hls"


fi

test_end


