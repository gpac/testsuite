#!/bin/sh


test_begin "hls"
if [ $test_skip != 1 ] ; then

m3u8file=$EXTERNAL_MEDIA_DIR/hls/index.m3u8
mpdfile=$EXTERNAL_MEDIA_DIR/hls/file1.mpd

do_test "$MP4BOX -mpd $m3u8file -out $mpdfile" "convert"
do_hash_test "$mpdfile" "convert"

mpdfile=$TEMP_DIR/file2.mpd
do_test "$MP4BOX -mpd $m3u8file -out $mpdfile" "convert-baseurl"
if [ $keep_temp_dir != 1 ] ; then
 do_hash_test "$mpdfile" "convert-baseurl"
else
echo "skipping hash, invalid when per-test temp dir is used"
fi

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $mpdfile inspect:allp:deep:interleave=false:log=$myinspect -stats -graph" "inspect"
do_hash_test $myinspect "inspect"

fi
test_end


test_hls_crypt()
{
test_begin "hls-crypt-$1"
if [ $test_skip != 1 ] ; then

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_640x360_192kbps.264:#ClampDur=6:#Bitrate=200k cecrypt:cfile=$MEDIA_DIR/encryption/$2 @ -o $TEMP_DIR/live.m3u8" "crypt"

do_hash_test $TEMP_DIR/live_1.m3u8 "playlist"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_640x360_192kbps_dashinit.mp4 "init"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_640x360_192kbps_dash1.m4s "seg1"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_640x360_192kbps_dash3.m4s "seg3"

fi
test_end
}

test_hls_crypt "cbcs" "cbcs_const.xml"
test_hls_crypt "cbcs-roll" "cbcs_const_roll.xml"

