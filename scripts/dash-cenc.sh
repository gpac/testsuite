#!/bin/sh

test_begin "dash-cenc"
if [ $test_skip  = 1 ] ; then
return
fi

do_test "$MP4BOX -crypt $MEDIA_DIR/encryption/cbc.xml -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac -new $TEMP_DIR/file.mp4" "dash-input-playready-encrypt"

do_test "$MP4BOX -dash 1000 -profile dashavc264:live $TEMP_DIR/file.mp4#video $TEMP_DIR/file.mp4#audio -out $TEMP_DIR/file.mpd" "dashing-cenc-playready"

do_hash_test $TEMP_DIR/file.mpd "mpd"

do_hash_test $TEMP_DIR/file_dash_track1_init.mp4 "init"
do_hash_test $TEMP_DIR/file_dash_track2_init.mp4 "init2"

do_hash_test $TEMP_DIR/file_dash_track1_10.m4s "seg"
do_hash_test $TEMP_DIR/file_dash_track2_10.m4s "seg2"

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:deep:interleave=false:log=$myinspect -graph -stats"
do_hash_test $myinspect "inspect"

do_test "$MP4BOX -dash 1000 -pssh m -profile dashavc264:live $TEMP_DIR/file.mp4#video $TEMP_DIR/file.mp4#audio -out $TEMP_DIR/file2.mpd" "dashing-cenc-pssh-mpd"
do_hash_test $TEMP_DIR/file2.mpd "pssh-mpd"


do_test "$MP4BOX -dash 1000 -sdtp-traf both -cp-location both -profile live $TEMP_DIR/file.mp4#video -out $TEMP_DIR/file3.mpd" "dashing-cenc-cploc"
do_hash_test $TEMP_DIR/file3.mpd "pssh-cploc"


test_end

