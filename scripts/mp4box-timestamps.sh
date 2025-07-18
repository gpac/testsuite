#!/bin/sh

test_begin "mp4box-timestamps"

 if [ $test_skip  = 1 ] ; then
  return
 fi

do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264 -new $TEMP_DIR/file.mp4" "import"

timesrc=$TEMP_DIR/times_1.txt
$GPAC -i $TEMP_DIR/file.mp4 inspect:deep:fmt='%cts%%lf%':hdr=0:noprop > $timesrc
do_test "$MP4BOX -add $TEMP_DIR/file.mp4:times=$timesrc -new $TEMP_DIR/file1.mp4" "times_cts"
do_hash_test "$TEMP_DIR/file1.mp4" "times_cts"

timesrc=$TEMP_DIR/times_2.txt
$GPAC -i $TEMP_DIR/file.mp4 inspect:deep:fmt='%dts% %cts%%lf%':hdr=0:noprop > $timesrc
do_test "$MP4BOX -add $TEMP_DIR/file.mp4:times=$timesrc -new $TEMP_DIR/file2.mp4" "times_dts_cts"
do_hash_test "$TEMP_DIR/file2.mp4" "times_dts_cts"


test_end
