test_begin "tilesplit"
if [ $test_skip != 1 ] ; then

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_1280_720_I_25_tiled_1mb.hevc tilesplit @ -o $TEMP_DIR/src.mp4" "all-tiles"
do_hash_test $TEMP_DIR/src.mp4 "all-tiles"

myinspect=$TEMP_DIR/inspect_all.txt
do_test "$GPAC -i $TEMP_DIR/src.mp4 tileagg @ inspect:allp:deep:interleave=false:log=$myinspect" "inspect-all"
do_hash_test $myinspect "inspect-all"

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_1280_720_I_25_tiled_1mb.hevc tilesplit:tiledrop=2,4,6 @ -o $TEMP_DIR/drop.mp4" "drop-tiles"
do_hash_test $TEMP_DIR/drop.mp4 "all-tiles"

myinspect=$TEMP_DIR/inspect_drop.txt
do_test "$GPAC -i $TEMP_DIR/drop.mp4 tileagg @ inspect:allp:deep:interleave=false:log=$myinspect" "inspect-drop"
do_hash_test $myinspect "inspect-drop"



do_test "$GPAC -old-arch=no -i $EXTERNAL_MEDIA_DIR/counter/counter_1280_720_I_25_tiled_1mb.hevc:#Bitrate=1m tilesplit @ -o $TEMP_DIR/live.mpd" "dash"
do_hash_test $TEMP_DIR/live.mpd "mpd"
do_hash_test $TEMP_DIR/counter_1280_720_I_25_tiled_1mb_dash_track1_init.mp4 "init"
do_hash_test $TEMP_DIR/counter_1280_720_I_25_tiled_1mb_dash_track1_20.m4s "seg20_base"
do_hash_test $TEMP_DIR/counter_1280_720_I_25_tiled_1mb_dash_track10_20.m4s "seg20_t10"

myinspect=$TEMP_DIR/inspect_dash.txt
do_test "$GPAC -i $TEMP_DIR/live.mpd tileagg @ inspect:allp:deep:interleave=false:log=$myinspect" "inspect-dash"
do_hash_test $myinspect "inspect-dash"

test_end
fi

