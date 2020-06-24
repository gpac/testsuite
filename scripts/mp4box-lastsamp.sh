

test_begin "mp4box-lastsampdur"
if [ $test_skip = 1 ] ; then
return
fi

mp4file="$TEMP_DIR/base.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/count_video.cmp:lastsampdur=1/2 -new $mp4file" "add"

do_hash_test $mp4file "add"

test_end



