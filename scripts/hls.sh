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
