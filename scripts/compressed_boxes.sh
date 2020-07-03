#!/bin/sh
test_begin "comp-box"

 if [ $test_skip  = 1 ] ; then
  return
 fi

dstfile="$TEMP_DIR/comp.mp4"
do_test "$MP4BOX --compress=moov -add $MEDIA_DIR/auxiliary_files/count_video.cmp -new $dstfile" "comp"
#cannot test hash of zlib ...
#do_hash_test $dstfile "comp"

myinspect=$TEMP_DIR/comp-inspect.txt
do_test "$GPAC -i $dstfile inspect:deep:log=$myinspect" "comp-read"
do_hash_test $myinspect "comp-read"


dstfile="$TEMP_DIR/comp.mpd"
do_test "$GPAC --compress=all -i $MEDIA_DIR/auxiliary_files/count_video.cmp -o $dstfile:profile=onDemand" "dash"

#cannot test hash of zlib ...
#do_hash_test $TEMP_DIR/count_video_dashinit.mp4 "comp-dash"

myinspect=$TEMP_DIR/comp-dash-inspect.txt
do_test "$GPAC -i $dstfile inspect:deep:log=$myinspect" "comp-dash-read"
do_hash_test $myinspect "comp-dash-read"

test_end
