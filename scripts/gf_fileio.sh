

test_begin "gf-fileio"
if [ $test_skip != 1 ] ; then

do_test "$GPAC -ib $MEDIA_DIR/auxiliary_files/counter.hvc -ob $TEMP_DIR/file.mpd" "fio-dash"
do_hash_test $TEMP_DIR/file.mpd  "mpd"
do_hash_test $TEMP_DIR/counter_dashinit.mp4 "init"
do_hash_test $TEMP_DIR/counter_dash1.m4s  "seg1"

#inspect using a gfio input file and a gfio output log 
insp=$TEMP_DIR/inspect.txt
do_test "$GPAC -ib $TEMP_DIR/file.mpd inspect:deep:log=@gfo://$insp" "fio-read"
do_hash_test $insp  "play"

fi
test_end

#check if we have libavformat support
ffmx=`$GPAC -h ffmx 2>/dev/null | grep ffmx`
if [ -n "$ffmx" ] ; then

test_begin "gf-fileio-mkv"
if [ $test_skip != 1 ] ; then
do_test "$GPAC -ib $MEDIA_DIR/auxiliary_files/enst_video.h264 -ob $TEMP_DIR/file.mkv" "mkv-mux"

if [ ! -f $TEMP_DIR/file.mkv ] ; then
result="Decoding output not present"
fi

do_test "$GPAC -ib $TEMP_DIR/file.mkv:gfreg=ffdmx -ob $TEMP_DIR/dump.264" "mkv-demux"
do_hash_test $TEMP_DIR/dump.264 "mkv-demux"

fi
test_end

fi

