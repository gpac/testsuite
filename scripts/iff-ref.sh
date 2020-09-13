#!/bin/sh

SRCFILE=$MEDIA_DIR/auxiliary_files/enst_video.h264

test_begin "iff-ref"

 if [ $test_skip = 1 ] ; then
  return
 fi

#create a video heif with no items
iff_file="$TEMP_DIR/video.heic"
do_test "$MP4BOX -add $SRCFILE -ab heic -new $iff_file" "create-iff-video"
do_hash_test $iff_file "create-iff-video"

#create a heif with sample 163 as main sample, copying the sample
iff_self="$TEMP_DIR/img_self.heic"
do_test "$MP4BOX -add-image self:tk=1:samp=163 $iff_file -out $iff_self" "create-iff-self"
do_hash_test $iff_self "create-iff-self"

#create a heif with sample 163 as main sample, referencing the sample
iff_ref="$TEMP_DIR/img_ref.heic"
do_test "$MP4BOX -add-image ref:tk=1:samp=163 $iff_file -out $iff_ref" "create-iff-ref"
do_hash_test $iff_ref "create-iff-ref"

#remux a heif with sample ref
iff_ref_remux="$TEMP_DIR/img_ref_remux.heic"
do_test "$MP4BOX -inter 500 $iff_ref -out $iff_ref_remux" "remux-iff-ref"
do_hash_test $iff_ref_remux "remux-iff-ref"



test_end
