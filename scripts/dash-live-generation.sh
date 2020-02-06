#!/bin/sh

#
# WARNING
#
#	Either remove the dash context at the end of the test or make sure you use different names
#	The temp dir is not cleaned until the end of the subscript!
#

test_begin "dash-live-generation"

if [ $test_skip  = 0 ] ; then

do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:dur=5 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:dur=5 -new $TEMP_DIR/file.mp4" "dash-input-preparation"

do_test "$MP4BOX -bs-switching single -mpd-refresh 10 -time-shift -1 -dash-ctx $TEMP_DIR/dash_ctx -run-for 4000 -dynamic -profile live -dash-live 2000  $TEMP_DIR/file.mp4#video $TEMP_DIR/file.mp4#audio -out $TEMP_DIR/file.mpd" "dash-live" &

sleep 1

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:deep:interleave=false:dur=2/1:log=$myinspect"
do_hash_test $myinspect "inspect"

fi

test_end

test_begin "dash-live-gen-segtime"

if [ $test_skip  = 0 ] ; then

do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:dur=10 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:dur=10 -new $TEMP_DIR/file.mp4" "dash-input-preparation"

do_test "$MP4BOX -segment-timeline -mpd-refresh 10 -time-shift 0 -dash-ctx $TEMP_DIR/dash_ctx2 -subdur 1000 -dynamic -profile live -dash 1000 $TEMP_DIR/file.mp4 -out $TEMP_DIR/file.mpd" "dash-live1"

sleep 1.5

do_test "$MP4BOX -segment-timeline -mpd-refresh 10 -time-shift 0 -dash-ctx $TEMP_DIR/dash_ctx2 -subdur 1000 -dynamic -profile live -dash 1000 $TEMP_DIR/file.mp4 -out $TEMP_DIR/file.mpd" "dash-live2"

sleep 1.5

do_test "$MP4BOX -segment-timeline -mpd-refresh 10 -time-shift 0 -dash-ctx $TEMP_DIR/dash_ctx2 -subdur 1000 -last-dynamic -profile live -dash 1000 $TEMP_DIR/file.mp4 -out $TEMP_DIR/file.mpd" "dash-live3"

do_hash_test $TEMP_DIR/file.mpd "mpd-final"
do_hash_test $TEMP_DIR/file_dash100.m4s "segment"

if [ -f "$TEMP_DIR/file_dash0.m4s" ] ; then
result="first_seg removal failed"
fi

fi

test_end
