#!/bin/sh

test_begin "dash-dynamic-utc"

if [ $test_skip  = 0 ] ; then

$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:dur=10 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:dur=10 -new $TEMP_DIR/file.mp4 2> /dev/null

do_test "$MP4BOX -dash-live 2000 -closest -subdur 2000 -profile live -mpd-refresh 10 -time-shift -1 -run-for 4000 $TEMP_DIR/file.mp4#video $TEMP_DIR/file.mp4#audio -out $TEMP_DIR/file.mpd" "dash-gen" &

sleep 1

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:deep:interleave=false:dur=2/1:log=$myinspect" "inspect"
do_hash_test $myinspect "inspect"


#wait for the end of the MP4Box
wait

#hash the final MPD (written as  static)
do_hash_test $TEMP_DIR/file.mpd "hash-mpd"

#hash 3rd segment of video and audio, making sure the tfdt is correct
do_hash_test $TEMP_DIR/file_dash_track1_2.m4s "hash-seg2-video"
do_hash_test $TEMP_DIR/file_dash_track2_2.m4s "hash-seg2-audio"

fi

test_end


