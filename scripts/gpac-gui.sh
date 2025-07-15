
single_test "$GPAC -gui -fs -runfor=2000" "gpac-gui"

echo "bla" > $TEMP_DIR/test.mp4
single_test "gpac -p=$gpac_profile -mem-track -for-test -no-reassign -gui -runfor=2000 $TEMP_DIR/test.mp4" "gpac-gui-urlerror"

single_test "$GPAC -gui -rmt -runfor=2000 -stats $MEDIA_DIR/auxiliary_files/sky.jpg" "gpac-gui-stats"

single_test "$GPAC -gui -for-test -gui-test http://download.tsi.telecom-paristech.fr/gpac/DASH_CONFORMANCE/TelecomParisTech/mp4-live-1s/mp4-live-1s-mpd-V-BS.mpd" "gpac-gui-dash"

single_test "$GPAC -cov -runfor=2000 -mp4c $MEDIA_DIR/bifs/bifs-3D-shapes-box.bt" "gpac-mp4c-nav3D"

single_test "$GPAC -cov -runfor=2000 -mp4c $MEDIA_DIR/bifs/bifs-2D-painting-material2D.bt" "gpac-mp4c-nav2D"

#we have a bif issue with openhevc decoder cleanup multiple instances, need to investigate
single_test "$GPAC -blacklist=vtbdec,nvdec,ohevcdec -runfor=2000 -mp4c http://download.tsi.telecom-paristech.fr/gpac/tests/live360mcts/demo/live360.mpd#VR" "gpac-mp4c-vrtiled"

single_test "$GPAC -blacklist=vtbdec,nvdec -runfor=1000 -mp4c mosaic://$MEDIA_DIR/auxiliary_files/count_video.cmp:$MEDIA_DIR/auxiliary_files/enst_video.h264" "gpac-mp4c-mosaic"

single_test "$GPAC -blacklist=vtbdec,nvdec -runfor=1000 --stereo=top -mp4c views://$MEDIA_DIR/auxiliary_files/count_video.cmp:$MEDIA_DIR/auxiliary_files/enst_video.h264" "gpac-mp4c-views"

single_test "$GPAC -blacklist=vtbdec,nvdec -runfor=1000 -mp4c $MEDIA_DIR/svg/udomjs.svg -update=alert('foo!');" "gpac-mp4c-svg-update"

single_test "$GPAC -h mp4c" "gpac-mp4c-help"

test_begin "gpac-mp4c-start"
if [ $test_skip = 0 ] ; then

#run import with regular MP4Box (no test, with progress) for coverage
do_test "MP4Box -add $MEDIA_DIR/auxiliary_files/enst_video.h264 -new $TEMP_DIR/file.mp4" "create"

do_test "$GPAC -for-test -no-save -size=100x100 -speed=2 -rtix=$TEMP_DIR/logs.txt -exit -start=6 -mp4c $TEMP_DIR/file.mp4 -cov" "play"

fi
test_end


test_begin "gpac-mp4c-start-ts"
if [ $test_skip = 0 ] ; then

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264 -o $TEMP_DIR/file.ts" "create"

do_test "$GPAC -for-test -no-save -size=100x100 -speed=2 -rtix=$TEMP_DIR/logs.txt -exit -start=6 -mp4c $TEMP_DIR/file.ts -cov -blacklist=vtbdec,nvdec" "play"

fi
test_end
