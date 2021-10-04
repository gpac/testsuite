#!/bin/sh

test_begin "y4m"

if [ $test_skip = 1 ] ; then
return
fi

dst_file=$TEMP_DIR/dump.y4m
inspect_file=$TEMP_DIR/inspect.txt

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264 -o $dst_file -blacklist=vtbdec,nvdec,ohevcdec"  "writer"
do_hash_test "$dst_file" "writer"

do_test "$GPAC -i $dst_file inspect:deep:log=$inspect_file"  "reader"
do_hash_test "$inspect_file" "inspect"


test_end
