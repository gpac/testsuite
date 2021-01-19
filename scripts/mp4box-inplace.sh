#!/bin/sh

test_rescale()
{
test_begin "mp4box-$1"

 if [ $test_skip  = 1 ] ; then
  return
 fi

#do not add tags for meta-only we need a moov for that
if [ "$3" == "1" ] ; then
tags=""
ext="heic"
else
tags="-itags artist=GPACTeam"
ext="mp4"
fi

#test inplace editing without padding
src=$TEMP_DIR/src.$ext
do_test "$MP4BOX $2 -new $src" "input"
do_hash_test $src "input"


#test inplace editing with padding
do_test "$MP4BOX -ab GPAC $tags $src" "retag"
do_hash_test $src "retag"

src=$TEMP_DIR/src_pad.$ext
do_test "$MP4BOX $2 -new $src -moovpad 1000" "input-pad"
do_hash_test $src "input-pad"

do_test "$MP4BOX -ab GPAC $tags $src" "retag-pad"
do_hash_test $src "retag-pad"

test_end

}

test_rescale "inplace-av-inter" "-add $MEDIA_DIR/auxiliary_files/enst_video.h264 -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -inter 500" 0
test_rescale "inplace-av-flat" "-add $MEDIA_DIR/auxiliary_files/enst_video.h264 -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -flat" 0
test_rescale "inplace-iff" "-add-image $MEDIA_DIR/auxiliary_files/enst_video.h264" 1
test_rescale "inplace-dual-inter" "-add-image $MEDIA_DIR/auxiliary_files/enst_video.h264 -add $MEDIA_DIR/auxiliary_files/enst_video.h264 -inter 500" 0
test_rescale "inplace-dual-flat" "-add $MEDIA_DIR/auxiliary_files/enst_video.h264 -add-image :ref -flat" 0
