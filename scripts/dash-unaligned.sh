#!/bin/sh

test_begin "dash-unalign"
if [ $test_skip  = 1 ] ; then
return
fi

#create inputs, the second one is same as first but imported at 20 fps to change sync points alignment
$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:dur=10:fps=25 -new $TEMP_DIR/file_1.mp4 2> /dev/null
$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:dur=20:fps=20 -new $TEMP_DIR/file_2.mp4 2> /dev/null


#dash, forcing the 20fps input to be signaled as 25fps to be in the same adaptation set as the 25fps input, and use segment timeline:
#we must end up with 1 segment timeline per rep
do_test "$GPAC -i $TEMP_DIR/file_1.mp4 -i $TEMP_DIR/file_2.mp4:#FPS=25 -o $TEMP_DIR/file.mpd:profile=live:stl" "dash-unalign"

do_hash_test "$TEMP_DIR/file.mpd" "mpd"

test_end
