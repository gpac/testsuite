#!/bin/sh


my_test_with_hash ()
{
	do_test "$1" "$2"
	do_hash_test "$output" "$2"
}


test_begin "mp4box-ctlc"

if [ $test_skip = 1 ] ; then
	return
fi

source_file=$TEMP_DIR/file.mp4
output=$TEMP_DIR/output.mp4

$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264:dur=1 -add $MEDIA_DIR/auxiliary_files/enst_audio.aac:dur=1 -new $source_file 2> /dev/null

my_test_with_hash "$MP4BOX -ctlc 1=3 $source_file -out $output" "ctlc-track-default-flags"

rm $output 2> /dev/null
my_test_with_hash "$MP4BOX -ctlc 1=3:0 $source_file -out $output" "ctlc-track-flags-none"

rm $output 2> /dev/null
my_test_with_hash "$MP4BOX -ctlc 1=3:1 $source_file -out $output" "ctlc-track-flags-advertisement"

rm $output 2> /dev/null
my_test_with_hash "$MP4BOX -ctlc 2=3:2 $source_file -out $output" "ctlc-track-flags-immersive-audio"

rm $output 2> /dev/null
my_test_with_hash "$MP4BOX -ctlc 1=3:3 $source_file -out $output" "ctlc-track-flags-all"

rm $output 2> /dev/null
my_test_with_hash "$MP4BOX -ctlc all=3:3 $source_file -out $output" "ctlc-all-tracks"

rm $output 2> /dev/null
do_test "$MP4BOX -ctlc 1=3:1 $source_file -out $output" "ctlc-replace-setup"
my_test_with_hash "$MP4BOX -no-inplace -ctlc 1=7:2 $output" "ctlc-replace"

rm $output 2> /dev/null
do_test "$MP4BOX -ctlc 1=3:3 $source_file -out $output" "ctlc-track-rem-setup"
my_test_with_hash "$MP4BOX -no-inplace -ctlc-rem 1 $output" "ctlc-track-rem"

do_test "$MP4BOX -no-inplace -ctlc-rem 1 $output" "ctlc-track-rem-twice"
do_hash_test "$output" "ctlc-track-rem-twice"

rm $output 2> /dev/null
do_test "$MP4BOX -ctlc all=3:3 $source_file -out $output" "ctlc-all-rem-setup"
my_test_with_hash "$MP4BOX -no-inplace -ctlc-rem all $output" "ctlc-all-rem"

output=$TEMP_DIR/ctlc.mp4
do_test "$MP4BOX -ctlc 2=3 $source_file -out $output" "ctlc-dash-setup"
do_test "$MP4BOX -dash 1000 -profile onDemand $output -out $TEMP_DIR/ctlc.mpd" "ctlc-dash"
do_hash_test "$TEMP_DIR/ctlc_dashinit.mp4" "ctlc-dash-init"

test_end
