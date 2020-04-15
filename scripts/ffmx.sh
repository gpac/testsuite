
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

if [ $1 = "mkv" ] || [ $1 = "webm" ] ; then
#we force FPS since some version old of libavformat do not expose FPS on webm/mkv
dstarg="$dstfile:#FPS=25"
else
dstarg="$dstfile"
fi

do_test "$GPAC  -no-reassign=no -i $dstarg inspect:allp:deep:interleave=false:log=$myinspect$3"
do_hash_test $myinspect "inspect"

test_end
}

#check if we have libavfilter support
ffmx=`$GPAC -h ffmx 2>/dev/null | grep ffmx`
if [ -n "$ffmx" ] ; then

ffmx_test "mkv" "$MEDIA_DIR/auxiliary_files/enst_video.h264" ""
ffmx_test "ogg" "$EXTERNAL_MEDIA_DIR/import/dead_ogg.ogg" ":test=encode"
ffmx_test "webm" "$EXTERNAL_MEDIA_DIR/import/counter_1280_720_I_25_500k.ivf" ""

fi

