
test_begin "vtt-merge"
if [ $test_skip != 1 ] ; then

 mp4file=$TEMP_DIR/file.mp4
 vttfile=$TEMP_DIR/file.vtt
 do_test "$MP4BOX -add $MEDIA_DIR/webvtt/overlapping.vtt -new $mp4file" "vtt-to-mp4"
 do_test "$GPAC -i $mp4file -o $vttfile:merge" "vtt-merge"
 do_hash_test "$vttfile" "vtt-merge"
fi
test_end


test_begin "vtt-dump"
if [ $test_skip != 1 ] ; then

 mp4file=$TEMP_DIR/file.mp4
 vttfile=$TEMP_DIR/file.vtt
 srtfile=$TEMP_DIR/file.srt
 do_test "$MP4BOX -add $MEDIA_DIR/webvtt/elephants-dream-chapters-en.vtt -new $mp4file" "vtt-to-mp4"
 do_test "$MP4BOX -srt $mp4file -out $srtfile" "srt-extract"
 do_hash_test "$srtfile" "srt-extract"
 do_test "$MP4BOX -raw 1 $mp4file -out $vttfile" "vtt-extract"
 do_hash_test "$vttfile" "vtt-extract"

fi
test_end

