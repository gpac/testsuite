#!/bin/sh

cmaf_test()
{
test_begin "cmaf-$1"
if [ $test_skip  = 1 ] ; then
return
fi

#build single file with B-frames and audio. We test
#cmfc, cmf2:  force splitting the input into different adaptation sets
#cmf2: remove edit lists from video track and use negctts
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_main_1280x720_512kbps.264 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac -new $TEMP_DIR/file.mp4" "dash-input-preparation"

do_test "$MP4BOX -dash 1000 -profile live $TEMP_DIR/file.mp4 -out $TEMP_DIR/file.mpd:cmaf=$1" "dash"
do_hash_test "$TEMP_DIR/file.mpd" "mpd"
do_hash_test "$TEMP_DIR/file_dash_track1_init.mp4" "init1"
do_hash_test "$TEMP_DIR/file_dash_track2_init.mp4" "init2"
do_hash_test "$TEMP_DIR/file_dash_track1_20.m4s" "seg1"
do_hash_test "$TEMP_DIR/file_dash_track2_20.m4s" "seg2"

test_end
}


cmaf_test "cmfc"
cmaf_test "cmf2"



cmaf_test_ttml()
{
test_begin "cmaf-ttml"
if [ $test_skip  = 1 ] ; then
return
fi

do_test "$MP4BOX -dash 1000 -profile live $MEDIA_DIR/ttml/ebu-ttd_sample.ttml -out $TEMP_DIR/file.mpd:cmaf=cmfc" "dash"
do_hash_test "$TEMP_DIR/file.mpd" "mpd"
do_hash_test "$TEMP_DIR/ebu-ttd_sample_dashinit.mp4" "init"
do_hash_test "$TEMP_DIR/ebu-ttd_sample_dash10.m4s" "seg"


test_end
}

cmaf_test_ttml
