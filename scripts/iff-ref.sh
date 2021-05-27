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
do_test "$MP4BOX -add-image tk=1:samp=163 $iff_file -out $iff_self" "create-iff-self"
do_hash_test $iff_self "create-iff-self"

#create a heif with sample 163 as main sample, referencing the sample, not specifying the track (default to first video found)
iff_ref="$TEMP_DIR/img_ref.heic"
do_test "$MP4BOX -add-image ref:samp=163 $iff_file -out $iff_ref" "create-iff-ref"
do_hash_test $iff_ref "create-iff-ref"

#remux a heif with sample ref
iff_ref_remux="$TEMP_DIR/img_ref_remux.heic"
do_test "$MP4BOX -inter 500 $iff_ref -out $iff_ref_remux" "remux-iff-ref"
do_hash_test $iff_ref_remux "remux-iff-ref"


#remove track from a heif with sample ref
iff_ref_remtk="$TEMP_DIR/img_ref_remtk.heic"
do_test "$MP4BOX -rem 1 $iff_ref -out $iff_ref_remtk" "remux-iff-remtk"
do_hash_test $iff_ref_remtk "remux-iff-remtk"

#add item
iff_ref_add_cp="$TEMP_DIR/img_ref_add_copy.heic"
do_test "$MP4BOX -add-image it=1 $iff_ref_remtk -out $iff_ref_add_cp" "add-img-copy"
do_hash_test $iff_ref_add_cp "add-img-copy"

#add item ref
iff_ref_add_ref="$TEMP_DIR/img_ref_add_ref.heic"
do_test "$MP4BOX -add-image it=1:ref $iff_ref_remtk -out $iff_ref_add_ref" "add-img-ref"
do_hash_test $iff_ref_add_ref "add-img-ref"

#remove item ref
iff_ref_rem_ref="$TEMP_DIR/img_ref_rem_ref.heic"
do_test "$MP4BOX -rem-image 1 $iff_ref_add_ref -out $iff_ref_rem_ref" "rem-img-ref"
do_hash_test $iff_ref_rem_ref "rem-img-ref"

test_end
