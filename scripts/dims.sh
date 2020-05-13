test_begin "dims"
if [ $test_skip  = 1 ] ; then
return
fi

dstfile=$TEMP_DIR/dims.mp4
do_test "$MP4BOX -add $MEDIA_DIR/svg/shapes-circle-01-t.dml -new $dstfile" "dims-import"
do_hash_test $dstfile "dims-import"

do_test "$MP4BOX --dims -nhml 1 $dstfile" "dims-export"
do_hash_test $TEMP_DIR/dims_track1.nhml "dims-export"


#DIMS hinting is disabled by default in gpac, do not test

test_end


