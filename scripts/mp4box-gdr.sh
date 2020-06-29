
if [ $EXTERNAL_MEDIA_AVAILABLE = 0 ] ; then
return
fi

test_begin "mp4box-gdr"
if [ $test_skip != 1 ] ; then

mp4file="$TEMP_DIR/base.mp4"
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_GDR_320x180_160kbps.264 -new $mp4file" "add"

do_hash_test $mp4file "add"

mpdfile="$TEMP_DIR/base.mpd"
do_test "$MP4BOX -sample-groups-traf -dash 2000 -profile onDemand $mp4file -out $mpdfile" "dash"
do_hash_test $mpdfile "dash-mpd"
do_hash_test $TEMP_DIR/base_dashinit.mp4 "dash-rep"


fi
test_end



test_begin "mp4box-forcesync"
if [ $test_skip != 1 ] ; then

mp4file="$TEMP_DIR/base.mp4"
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_openGOP_640x360_160kbps.264:forcesync -new $mp4file" "add"

do_hash_test $mp4file "add"

fi
test_end

