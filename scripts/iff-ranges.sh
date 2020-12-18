#!/bin/sh

SRCFILE=$MEDIA_DIR/auxiliary_files/counter.hvc

test_begin "iff-ranges"

 if [ $test_skip = 1 ] ; then
  return
 fi

#create a heif with all saps from source as items
iff_file="$TEMP_DIR/images-all.heic"
do_test "$MP4BOX -add-image $SRCFILE:time=-1 -ab heic -new $iff_file" "iff-all"
do_hash_test $iff_file "iff-all"


#create a heif with all saps from 2 to 20 from source as items
iff_file="$TEMP_DIR/images-range.heic"
do_test "$MP4BOX -add-image $SRCFILE:time=2-9 -ab heic -new $iff_file" "iff-range"
do_hash_test $iff_file "iff-range"

#create a heif with saps every 4 s from source as items
iff_file="$TEMP_DIR/images-all-step.heic"
do_test "$MP4BOX -add-image $SRCFILE:time=-1/4 -ab heic -new $iff_file" "iff-all-step"
do_hash_test $iff_file "iff-all-step"

#create a heif with saps from 3 to 20, every 4 s from source as items
iff_file="$TEMP_DIR/images-range-step.heic"
do_test "$MP4BOX -add-image $SRCFILE:time=2-8/3 -ab heic -new $iff_file" "iff-range-step"
do_hash_test $iff_file "iff-range-step"


test_end
