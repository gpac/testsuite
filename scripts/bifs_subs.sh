

test_begin "bifs-subs"

 if [ $test_skip  = 1 ] ; then
  return
 fi

src=$MEDIA_DIR/bifs/bifs_subs.bt
dst=$TEMP_DIR/test.mp4

do_test "$MP4BOX -mp4 $src -out $dst" "bt2mp4"
do_hash_test $dst "bt2mp4"

do_test "$MP4BOX -bt $dst" "mp42bt"
do_hash_test $TEMP_DIR/test.mp4 "mp42bt"

#test conversion tx3g->stxt
dst2=$TEMP_DIR/test_strtxt.mp4
do_test "$GPAC -i $dst:strtxt reframer @ -o $dst2" "strtxt"
do_hash_test $dst2 "strtxt"

test_end

