cc_test ()
{

test_begin "cc-$1"
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

mp4file="$TEMP_DIR/test.mp4"

$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264 -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -new $mp4file 2> /dev/null


cc_test "avc" "$EXTERNAL_MEDIA_DIR/cc_708/cc1.mp4" "none"
cc_test "avc-word" "$EXTERNAL_MEDIA_DIR/cc_708/cc1.mp4" "word"

cc_test "m2v" "$EXTERNAL_MEDIA_DIR/cc_708/cc2.mp4" "none"

