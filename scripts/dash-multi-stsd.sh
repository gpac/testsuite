test_begin "dash-multi-stsd"

if [ $test_skip  = 1 ] ; then
return
fi

echo "#stop=5" > "pl.m3u"
echo "$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264" >> "pl.m3u"
echo "#stop=5" >> "pl.m3u"
echo "$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_openGOP_320x180_112kbps.264" >> "pl.m3u"

do_test "$GPAC -i pl.m3u -o $TEMP_DIR/src.mp4" "multi-stsd-input"

do_test "$MP4BOX -old-arch=0 -dash 1000 -profile live -out $TEMP_DIR/file.mpd $TEMP_DIR/src.mp4 --pswitch=stsd" "dash-multi-stsd"

do_hash_test $TEMP_DIR/file.mpd "mpd"
do_hash_test $TEMP_DIR/src_dashinit.mp4 "init"


myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:deep:interleave=false:log=$myinspect"
do_hash_test $myinspect "inspect"

mv "pl.m3u" $TEMP_DIR

test_end

