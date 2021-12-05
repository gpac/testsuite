#!/bin/sh

test_begin "dash-ts"
if [ $test_skip != 1 ] ; then

do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac -new $TEMP_DIR/file.mp4" "ts-for-dash-input-preparation"

#force a PCR init to avoid random PCR init value
do_test "$GPAC -i $TEMP_DIR/file.mp4 -o $TEMP_DIR/file.ts:pcr_init=10000:pes_pack=none" "ts-for-dash-input"

do_test "$MP4BOX -dash 1000 -rap -single-file -segment-name myrep/ts-segment-single-f-\$RepresentationID\$ $TEMP_DIR/file.ts -out $TEMP_DIR/file1.mpd" "ts-dash-single-file"
do_hash_test $TEMP_DIR/file1.mpd "mpd-single"

myinspect=$TEMP_DIR/inspect_single.txt
do_test "$GPAC -i $TEMP_DIR/file1.mpd inspect:allp:deep:interleave=false:log=$myinspect"
do_hash_test $myinspect "inspect-single"

do_test "$MP4BOX -dash 1000 -rap -segment-name myrep/ts-segment-multiple-f-\$RepresentationID\$ $TEMP_DIR/file.ts -out $TEMP_DIR/file2.mpd" "ts-dash-multiple-file"
do_hash_test $TEMP_DIR/file2.mpd "mpd-multi"

myinspect=$TEMP_DIR/inspect_multi.txt
do_test "$GPAC -i $TEMP_DIR/file2.mpd inspect:allp:deep:interleave=false:log=$myinspect"
do_hash_test $myinspect "inspect-multi"

fi
test_end


test_begin "dash-ts-mux-live"
if [ $test_skip != 1 ] ; then

#force a PCR init to avoid random PCR init value
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:#Representation=1 -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:#Representation=1 -o $TEMP_DIR/file.mpd:segdur=4:muxtype=ts --pcr_init=10000 --pcr_init=pes_pack=none" "ts-dash"

#myinspect=$TEMP_DIR/inspect.txt
#do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:deep:interleave=false:log=$myinspect"
#do_hash_test $myinspect "inspect"

do_hash_test $TEMP_DIR/file.mpd "inspect-mpd"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash5.ts "inspect-seg"

fi
test_end

test_begin "dash-ts-mux-vod"
if [ $test_skip != 1 ] ; then

#force a PCR init to avoid random PCR init value
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:#Representation=1 -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:#Representation=1 -o $TEMP_DIR/file.mpd:segdur=4:muxtype=ts:profile=onDemand --pcr_init=10000 --pcr_init=pes_pack=none" "ts-dash"

#myinspect=$TEMP_DIR/inspect.txt
#do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:deep:interleave=false:log=$myinspect"
#do_hash_test $myinspect "inspect"

do_hash_test $TEMP_DIR/file.mpd "inspect-mpd"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash.ts "inspect-seg"

fi
test_end


test_begin "dash-ts-mux-sidx"
if [ $test_skip != 1 ] ; then

#force a PCR init to avoid random PCR init value
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:#Representation=1 -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:#Representation=1 -o $TEMP_DIR/file.mpd:segdur=4:muxtype=ts:profile=live:subs_sidx=5 --pcr_init=10000 --pcr_init=pes_pack=none" "ts-dash"

#myinspect=$TEMP_DIR/inspect.txt
#do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:deep:interleave=false:log=$myinspect"
#do_hash_test $myinspect "inspect"

do_hash_test $TEMP_DIR/file.mpd "inspect-mpd"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash5.ts "inspect-seg"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash5idx.idx "inspect-sidx"

fi
test_end

test_begin "dash-ts-split"
if [ $test_skip != 1 ] ; then

#force a PCR init to avoid random PCR init value
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac -o $TEMP_DIR/file.mpd:segdur=4:muxtype=ts:profile=live --pcr_init=10000 --pcr_init=pes_pack=none" "ts-dash"

#myinspect=$TEMP_DIR/inspect.txt
#do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:deep:interleave=false:log=$myinspect"
#do_hash_test $myinspect "inspect"

do_hash_test $TEMP_DIR/file.mpd "inspect-mpd"
do_hash_test $TEMP_DIR/counter_30s_audio_dash5.ts "inspect-seg-aud"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash5.ts "inspect-seg-vid"

fi
test_end

