test_begin "dovi-cenc-dash"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/counter.hvc:dv-profile=5 -new $TEMP_DIR/dolby_vision_profile.mp4" "import-set-profile"
do_hash_test $TEMP_DIR/dolby_vision_profile.mp4 "profile"

do_test "$MP4BOX -dash 2000 $MEDIA_DIR/dolby_vision/dolby_vision_cenc.ismv -out $TEMP_DIR/dolby_vision_cenc_dash.mpd" "dashing"
do_hash_test $TEMP_DIR/dolby_vision_cenc_dashinit.mp4 "dash-seg"
do_hash_test $TEMP_DIR/dolby_vision_cenc_dash.mpd "dash-mpd"

test_end