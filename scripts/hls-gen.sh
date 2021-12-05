#!/bin/sh

test_begin "hls-gen-files"
if [ $test_skip != 1 ] ; then

$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac -new $TEMP_DIR/file.mp4 2> /dev/null

do_test "$MP4BOX -dash 1000 -profile dashavc264:live $TEMP_DIR/file.mp4#video $TEMP_DIR/file.mp4#audio -segment-name test-\$RepresentationID\$-\$Number%d\$ -out $TEMP_DIR/file.m3u8" "hls-gen"

do_hash_test "$TEMP_DIR/file.m3u8" "hls-master"
do_hash_test "$TEMP_DIR/file_1.m3u8" "hls-pl1"
do_hash_test "$TEMP_DIR/file_2.m3u8" "hls-pl2"

do_hash_test "$TEMP_DIR/test-1-.mp4" "hls-init1"
do_hash_test "$TEMP_DIR/test-2-.mp4" "hls-init2"

do_hash_test "$TEMP_DIR/test-1-10.m4s" "hls-seg1_10"
do_hash_test "$TEMP_DIR/test-2-10.m4s" "hls-seg2_10"

#check HLS playback
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.m3u8 inspect:deep:interleave=false:dur=2:log=$myinspect" "hls-play"
do_hash_test "$myinspect" "hls-play"

fi
test_end


test_begin "hls-gen-byteranges"
if [ $test_skip != 1 ] ; then

$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac -new $TEMP_DIR/file.mp4 2> /dev/null

#we also test the :dual option of the dasher to output both hls M3U8 and DASH MPD
do_test "$MP4BOX -dash 1000 -profile dashavc264:onDemand $TEMP_DIR/file.mp4#video $TEMP_DIR/file.mp4#audio -out $TEMP_DIR/file.m3u8:dual" "hls-gen"

do_hash_test "$TEMP_DIR/file.m3u8" "hls-master"
do_hash_test "$TEMP_DIR/file_1.m3u8" "hls-pl1"
do_hash_test "$TEMP_DIR/file_2.m3u8" "hls-pl2"

do_hash_test "$TEMP_DIR/file.mpd" "hls-mpd"

#check HLS playback
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.m3u8 inspect:deep:interleave=false:dur=2:log=$myinspect" "hls-play"
do_hash_test "$myinspect" "hls-play"

fi
test_end




test_begin "hls-gen-groups"
if [ $test_skip != 1 ] ; then

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:#Language=fra:#HLSGroup=AudioALT:#Representation=Soustitres -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:#Language=eng:#HLSGroup=AudioALT:#Representation=Subtitles -o $TEMP_DIR/file.m3u8" "hls-groups"

do_hash_test "$TEMP_DIR/file.m3u8" "hls-master"

fi
test_end

test_begin "hls-gen-ts"
if [ $test_skip != 1 ] ; then

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:#Language=fra:#Representation=Soustitres -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:#Language=eng:#Representation=Subtitles -o $TEMP_DIR/file.m3u8:muxtype=ts" "hls-m2ts"

do_hash_test "$TEMP_DIR/file.m3u8" "hls-master"

fi
test_end

test_begin "hls-gen-trick-intra-only"
if [ $test_skip != 1 ] ; then

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:FID=1 reframer:saps=1:FID=2 -o $TEMP_DIR/file.m3u8:dual:SID=1,2" "hls-trick-intra"

do_hash_test "$TEMP_DIR/file.m3u8" "hls-master"
do_hash_test "$TEMP_DIR/file_1.m3u8" "hls-pl1"
do_hash_test "$TEMP_DIR/file_2.m3u8" "hls-pl2"
do_hash_test "$TEMP_DIR/file.mpd" "hls-mpd"
do_hash_test "$TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash_track1_10.m4s" "seg10_reg"
do_hash_test "$TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash_track2_10.m4s" "seg10_intra"

fi
test_end

