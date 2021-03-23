#!/bin/sh

test_inplace()
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

test_inplace "inplace-av-inter" "-add $MEDIA_DIR/auxiliary_files/enst_video.h264 -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -inter 500" 0
test_inplace "inplace-av-flat" "-add $MEDIA_DIR/auxiliary_files/enst_video.h264 -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -flat" 0
test_inplace "inplace-iff" "-add-image $MEDIA_DIR/auxiliary_files/enst_video.h264" 1
test_inplace "inplace-dual-inter" "-add-image $MEDIA_DIR/auxiliary_files/enst_video.h264 -add $MEDIA_DIR/auxiliary_files/enst_video.h264 -inter 500" 0
test_inplace "inplace-dual-flat" "-add $MEDIA_DIR/auxiliary_files/enst_video.h264 -add-image :ref -flat" 0


test_inplace_meta_ref()
{
test_begin "mp4box-inplace-iff-ref"

 if [ $test_skip  = 1 ] ; then
  return
 fi

#test inplace editing without padding
src=$TEMP_DIR/src.heic
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 -new $src" "input"
do_hash_test $src "input"

#test inplace editing
dst=$TEMP_DIR/img_ref1.heic
cp $src $dst

do_test "$MP4BOX -add-image ref:samp=1 $dst" "add-ref-samp1"
do_hash_test $src "add-ref-samp1"

dst2=$TEMP_DIR/img_ref2.heic
cp $dst $dst2
do_test "$MP4BOX -add-image ref:samp=251 $dst2" "add-ref-samp2"
do_hash_test $src "add-ref-samp2"

test_end

}

test_inplace_meta_ref

