#!/bin/sh

test_rescale()
{
test_begin "mp4box-rescale-$1"

 if [ $test_skip  = 1 ] ; then
  return
 fi

src=$TEMP_DIR/src.mp4
output=$TEMP_DIR/cat.mp4
do_test "$MP4BOX -add $2 -new $src" "input"

do_test "$MP4BOX -cat $src:rescale=25000/1000  -cat $src:sampdur=1000/50000 -new $output" "cat_rescale"

do_hash_test $output "cat_rescale"

test_end

}

test_rescale "avc" "$MEDIA_DIR/auxiliary_files/enst_video.h264"
