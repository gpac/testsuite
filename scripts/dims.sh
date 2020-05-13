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

#also try dims+compression
dstfile=$TEMP_DIR/dimz.mp4
do_test "$MP4BOX -add $MEDIA_DIR/svg/shapes-circle-01-t-compress.dml -new $dstfile" "dimz-import"
#cannot hash due to zlib not producing same results everywhere
if [ ! -f $dstfile ] ; then
result="SVGZ import not present"
fi

#and try playback of compressed dims
dumpfile=$TEMP_DIR/dump.png
do_test "$GPAC -i $dstfile -o $dumpfile" "dims-export"
#no hash test, just check the file is here
if [ ! -f $dumpfile ] ; then
result="SVG dump not present"
fi

test_end


