#!/bin/sh

if [ $EXTERNAL_MEDIA_AVAILABLE = 0 ] ; then
 return
fi

test_begin "dash-mux-ondemand"
if [ $test_skip  = 1 ] ; then
return
fi

do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac -new $TEMP_DIR/file.mp4" "dash-input-preparation"

do_test "$MP4BOX -dash 1000 -profile onDemand $TEMP_DIR/file.mp4 -out $TEMP_DIR/file.mpd" "basic-dash-mux-ondemand"

#commented on filters as master and filters diverge here on small details - to uncomment once we merge
#do_hash_test $TEMP_DIR/file.mpd "mpd"
do_hash_test $TEMP_DIR/file_dashinit.mp4 "seg"

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:deep:interleave=false:log=$myinspect"
do_hash_test $myinspect "inspect"

test_end
