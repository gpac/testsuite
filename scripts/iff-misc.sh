#!/bin/sh

SRCFILE=

test_av1_scal()
{
test_begin "iff-av1-scal"
 if [ $test_skip = 1 ] ; then
  return
 fi

#create a video heif with no items
src=$EXTERNAL_MEDIA_DIR/misc/tiger.obu_2.av1
iff_file="$TEMP_DIR/image.avif"
do_test "$MP4BOX -add-image $src -ab avif -new $iff_file" "create-iff"
do_hash_test $iff_file "create-iff"

test_end
}

test_av1_scal

