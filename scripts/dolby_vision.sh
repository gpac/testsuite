test_begin "dovi-cenc-dash"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$MP4BOX -for-test -dash 2000 1135909523.ismv" 2> /dev/null
do_hash_test $TEMP_DIR/1135909523_dashinit.mp4 "dump-dash-seg"
do_hash_test $TEMP_DIR/1135909523_dash.mpd "dump-dash-mpd"

test_end