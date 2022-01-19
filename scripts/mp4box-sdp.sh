

test_begin "mp4box-sdp"
if [ "$test_skip" = 1 ] ; then
return
fi

mp4file="$TEMP_DIR/sdp.mp4"
do_test "$MP4BOX -fps 30 -add $MEDIA_DIR/auxiliary_files/counter.hvc -hint -add-sdp 'movie' -add-sdp 1001:'track' -new $mp4file" "sdp"
do_hash_test $mp4file "sdp"

mp4file="$TEMP_DIR/multi.mp4"
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/import/bear_audio.amr -multi 200 -hint -new $mp4file" "multi"
do_hash_test $mp4file "multi"

test_end


