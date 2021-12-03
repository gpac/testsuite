#!/bin/sh

test_begin "hls-saes"
if [ $test_skip != 1 ] ; then

mp4file=$TEMP_DIR/file.mp4
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/hls_saes/saes.m3u8 reframer @ cdcrypt @ -o $mp4file" "hls-read"

do_hash_test $mp4file "hls-read"
fi
test_end



test_begin "hls-saes-gen"
if [ $test_skip != 1 ] ; then

infile=$TEMP_DIR/file.mp4
$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac -new $infile 2> /dev/null

mp4file=$TEMP_DIR/cfile.mp4
do_test "$MP4BOX -crypt $MEDIA_DIR/encryption/hls_saes.xml $infile -out $mp4file" "crypt-saes"
do_hash_test $mp4file "crypt-saes"

hlsfile=$TEMP_DIR/file.m3u8
do_test "$GPAC -i $mp4file::#HLSKey=urn:gpac:keys:value:5544694d47473326622665665a396b36::#Representation=1 -o $hlsfile --muxtype=ts --pes_pack=none" "hls-saes"
do_hash_test $TEMP_DIR/file_1.m3u8 "hls-saes"
do_hash_test $TEMP_DIR/cfile_dash9.ts "hls-seg9"


fi
test_end



