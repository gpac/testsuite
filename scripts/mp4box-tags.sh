

test_begin "mp4box-tags"
if [ "$test_skip" != 1 ] ; then

mp4file="$TEMP_DIR/test.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -new $mp4file -itags cover=$MEDIA_DIR/auxiliary_files/logo.png:genre=Game" "create"
do_hash_test $mp4file "create"

do_test "$MP4BOX -info $mp4file" "info"

covfile="$TEMP_DIR/test.png"
do_test "$MP4BOX -dump-cover $mp4file -out $covfile" "dumpcover"
do_hash_test $covfile "dumpcover"

fi
test_end


test_begin "mp4box-tags-file"
if [ "$test_skip" != 1 ] ; then

tags=$TEMP_DIR/tags.txt
echo "artist=GPAC" > $tags
echo "lyrics=Some lyrics " >> $tags
echo "  on  " >> $tags
echo "multiple" >> $tags
echo "" >> $tags
echo "lines" >> $tags
echo "cust=Custom Tag" >> $tags

mp4file="$TEMP_DIR/test.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -new $mp4file -itags $tags" "create"
do_hash_test $mp4file "create"

fi
test_end

