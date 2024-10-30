#!/bin/sh

test_begin "dash-stl-tpl"
if [ $test_skip  = 1 ] ; then
return
fi

#create input
$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:dur=10 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:dur=10 -new $TEMP_DIR/file.mp4 2> /dev/null

#dash twice the same input using STL, templates and bitstream switching
do_test "$GPAC -i $TEMP_DIR/file.mp4  -i $TEMP_DIR/file.mp4 -o $TEMP_DIR/live.mpd:profile=live:stl:template=segment_"'$RepresentationID$_$FS$_$Number$_$Init=init$' "dashing"

do_hash_test "$TEMP_DIR/live.mpd" "mpd"

test_end
