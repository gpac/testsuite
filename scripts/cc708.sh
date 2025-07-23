ccdec_test ()
{

test_begin "ccdec-$1"
if [ $test_skip  = 1 ] ; then
return
fi

myres=$TEMP_DIR/dump.vtt
do_test "$GPAC -i $2 ccdec:agg=$3 -o $myres" "vtt"
do_hash_test $myres "vtt"

myres=$TEMP_DIR/dump.ttml
do_test "$GPAC -i $2 ccdec:agg=$3 -o $myres" "ttml"
do_hash_test $myres "ttml"

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $2 inspect:deep:analyze=on:log=$myinspect" "inspect"
do_hash_test $myinspect "inspect"

test_end
}

ccenc_test ()
{

test_begin "ccenc-$1"
if [ $test_skip  = 1 ] ; then
return
fi

myres=$TEMP_DIR/dump.$1
do_test "$GPAC -i $2 -i $3 ccenc -o $myres" "encode"
do_hash_test $myres "encode"

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $myres inspect:deep:analyze=on:log=$myinspect" "inspect"
do_hash_test $myinspect "inspect"

test_end
}

mp4file="$TEMP_DIR/test.mp4"
$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264 -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -new $mp4file 2> /dev/null

ccdec_test "avc" "$EXTERNAL_MEDIA_DIR/cc_708/cc1.mp4" "none"
ccdec_test "avc-word" "$EXTERNAL_MEDIA_DIR/cc_708/cc1.mp4" "word"
ccdec_test "m2v" "$EXTERNAL_MEDIA_DIR/cc_708/cc2.mp4" "none"

ccenc_test "avc" "$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264" "$MEDIA_DIR/auxiliary_files/subtitle.srt"
ccenc_test "hevc" "$EXTERNAL_MEDIA_DIR/counter/counter_1280_720_I_25_tiled_500kb.hevc" "$MEDIA_DIR/auxiliary_files/subtitle.srt"
ccenc_test "mp4" $mp4file "$MEDIA_DIR/auxiliary_files/subtitle.srt"
