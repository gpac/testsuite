#!/bin/sh


dash_rawsubs_test()
{

test_begin "dash_rawsubs_$1_$2s"

if [ $test_skip  = 1 ] ; then
 return
fi

do_test "$GPAC -i $3 -o $TEMP_DIR/test.mpd:rawsub:segdur=$2:template=file" "dash"
do_hash_test "$TEMP_DIR/file1.$1" "seg1"
do_hash_test "$TEMP_DIR/file2.$1" "seg2"
do_hash_test "$TEMP_DIR/file5.$1" "seg5"
do_hash_test "$TEMP_DIR/file6.$1" "seg6"

test_end

}

src=$MEDIA_DIR/sparse/short4s.vtt

dash_rawsubs_test "vtt" "1" $MEDIA_DIR/sparse/short4s.vtt
dash_rawsubs_test "vtt" "4" $MEDIA_DIR/sparse/short4s.vtt
dash_rawsubs_test "ttml" "1" $MEDIA_DIR/sparse/short4s.ttml
dash_rawsubs_test "ttml" "4" $MEDIA_DIR/sparse/short4s.ttml


