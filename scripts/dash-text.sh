#!/bin/sh

test_begin "dash-text-empty"
if [ $test_skip  = 1 ] ; then
return
fi

do_test "$MP4BOX -profile live -dash 1000 $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac $MEDIA_DIR/auxiliary_files/subtitle.srt:webvtt -out $TEMP_DIR/live.mpd" "dash"

do_hash_test "$TEMP_DIR/live.mpd" "mpd"
#if everything is correct we have been generating empty segments for text until the end
do_hash_test "$TEMP_DIR/subtitle_dash30.m4s" "mpd"


myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/live.mpd inspect:allp:deep:interleave=false:log=$myinspect" "inspect"
do_hash_test $myinspect "inspect"

test_end
