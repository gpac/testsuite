
test_inspect()
{
 name=$(basename $1)
 name=${name%.*}
 test_begin "inspect-$name"

if [ "$test_skip" = 1 ] ; then
 return
fi

inspect="$TEMP_DIR/inspect.xml"

do_test "$GPAC -i $1 inspect:deep:log=$inspect:analyze$2" "inspect"
do_hash_test $inspect "inspect"

test_end

}

test_inspect $MEDIA_DIR/auxiliary_files/count_video.cmp ""
test_inspect $MEDIA_DIR/auxiliary_files/count_english.mp3 ""
test_inspect $MEDIA_DIR/auxiliary_files/enst_video.h264 ""
test_inspect $MEDIA_DIR/auxiliary_files/counter.hvc ""
test_inspect $MEDIA_DIR/auxiliary_files/video.av1 ""
test_inspect $EXTERNAL_MEDIA_DIR/qt_prores/prores422.mov ":SID=#PID=11"

test_begin "inspect-info"
if [ "$test_skip" != 1 ] ; then
inspect="$TEMP_DIR/inspect.txt"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/count_video.cmp inspect:deep:log=$inspect:info" "inspect"
do_hash_test $inspect "inspect"

fi
test_end

