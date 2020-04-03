

test_begin "gf-fileio"
if [ $test_skip != 1 ] ; then

do_test "$GPAC -ib $MEDIA_DIR/auxiliary_files/enst_video.h264 -ob $TEMP_DIR/file.mpd" "fio-dash"
do_hash_test $TEMP_DIR/file.mpd  "mpd"
do_hash_test $TEMP_DIR/enst_video_dashinit.mp4 "init"
do_hash_test $TEMP_DIR/enst_video_dash1.m4s  "seg1"

insp=$TEMP_DIR/inspect.txt
do_test "$GPAC -ib $TEMP_DIR/file.mpd inspect:deep:log=$insp" "fio-read"
do_hash_test $insp  "play"

fi
test_end
