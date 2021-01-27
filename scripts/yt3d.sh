#this tests a web radio, exercising icy meta skip and chunk transfer

test_begin "yt3d"
if [ $test_skip  = 1 ] ; then
return
fi

mp4file=$TEMP_DIR/file.mp4
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc:#Projection=2 -o $mp4file" "create"
do_hash_test $mp4file "create"

mp4file=$TEMP_DIR/file2.mp4
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/counter.hvc:sopt:#Projection=2 -new $mp4file" "create2"
do_hash_test $mp4file "create2"

test_end

