

test_begin "mp4box-hint-tight"
if [ "$test_skip" != 1 ] ; then

mp4file="$TEMP_DIR/udtamoov.mp4"

do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -add $MEDIA_DIR/auxiliary_files/enst_video.h264 -hint -tight -new $mp4file" "hint-tight"
do_hash_test $mp4file "hint-tight"

fi
test_end


test_begin "mp4box-hint-nooffset"
if [ "$test_skip" != 1 ] ; then

mp4file="$TEMP_DIR/udtamoov.mp4"

do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -hint -no-offset -new $mp4file" "hint"
do_hash_test $mp4file "hint"

fi
test_end


