#!/bin/sh

test_begin "hls-saes"
if [ $test_skip != 1 ] ; then

#only decrypt support for now
mp4file=$TEMP_DIR/file.mp4
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/hls_saes/saes.m3u8 reframer @ cdcrypt @ -o $mp4file" "hls-read"

do_hash_test $mp4file "hls-read"
fi
test_end



