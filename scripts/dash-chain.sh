#!/bin/sh

test_dash_chain()
{
test_begin "dash-chain"
if [ $test_skip  = 1 ] ; then
return
fi

do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:dur=2 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:dur=2 -new $TEMP_DIR/f1.mp4" "dash-input1"
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:dur=2:start=10 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:dur=2:start=10 -new $TEMP_DIR/f2.mp4" "dash-input1"

#create MPD with chain and fallback
do_test "$MP4BOX -dash 1000 -profile live $TEMP_DIR/f1.mp4#video $TEMP_DIR/f1.mp4#audio -out $TEMP_DIR/dash1/file.mpd --chain=../dash2/file.mpd --chain_fbk=../dash3/file.mpd" "dash-1"
do_test "$MP4BOX -dash 1000 -profile live $TEMP_DIR/f2.mp4#video $TEMP_DIR/f2.mp4#audio -out $TEMP_DIR/dash2/file.mpd" "dash-2"

do_hash_test "$TEMP_DIR/dash1/file.mpd" "mpd1"
do_hash_test "$TEMP_DIR/dash2/file.mpd" "mpd2"

#first run, chain is ok
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/dash1/file.mpd inspect:allp:deep:interleave=false:log=$myinspect" "inspect"
do_hash_test $myinspect "inspect"


#second run run, chain is not present but fallback is
mv "$TEMP_DIR/dash2" "$TEMP_DIR/dash3"
myinspect=$TEMP_DIR/inspect_fbk.txt
do_test "$GPAC -i $TEMP_DIR/dash1/file.mpd inspect:allp:deep:interleave=false:log=$myinspect" "inspect-fbk"
do_hash_test $myinspect "inspect-fbk"

test_end
}

test_dash_chain
