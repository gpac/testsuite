
ffmx_test ()
{

test_begin "ffmx-$1"

if [ $test_skip  = 1 ] ; then
return
fi

dstfile=$TEMP_DIR/mux.$1
do_test "$GPAC -no-reassign=no -i $2 reframer @ -o $dstfile -graph -stats" "mux"
#not bit-exact across platforms, inspect

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC  -no-reassign=no -i $dstfile inspect:allp:deep:interleave=false:log=$myinspect$3"
do_hash_test $myinspect "inspect"

test_end
}

#check if we have libavfilter support
ffmx=`$GPAC -h filters 2>&1 | grep ffmx`
if [ -n "$ffmx" ] ; then

ffmx_test "mkv" "$MEDIA_DIR/auxiliary_files/enst_video.h264" ""
ffmx_test "ogg" "$EXTERNAL_MEDIA_DIR/import/dead_ogg.ogg" ":test=encode"
ffmx_test "webm" "$EXTERNAL_MEDIA_DIR/import/counter_1280_720_I_25_500k.ivf" ""

fi

