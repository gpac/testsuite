
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

#check if we have libavformat support
ffmx=`$GPAC -h ffmx 2>/dev/null | grep ffmx`
if [ -n "$ffmx" ] ; then

ffmx_test "mkv" "$MEDIA_DIR/auxiliary_files/enst_video.h264" ""
ffmx_test "ogg" "$EXTERNAL_MEDIA_DIR/import/dead_ogg.ogg -blacklist=oggmx" ":test=encode"
ffmx_test "webm" "$EXTERNAL_MEDIA_DIR/import/counter_1280_720_I_25_500k.ivf" ""

fi


test_begin "ffmx-reconf"
if [ $test_skip != 1 ] ; then

echo "$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1920x1080_768kbps.264" > pl.m3u
echo "$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264" >> pl.m3u

dstfile=$TEMP_DIR/mux.mkv
do_test "$GPAC -no-reassign=no -i pl.m3u -o $dstfile -graph -stats" "mux"
mv pl.m3u $TEMP_DIR

test_end
fi

test_begin "ffmx-mkv-sub"
if [ $test_skip != 1 ] ; then

dstfile=$TEMP_DIR/mux.mkv
do_test "$GPAC -no-reassign=no -i $MEDIA_DIR/auxiliary_files/subtitle.srt:webvtt:no_empty -o $dstfile -graph -stats" "mux"

dstfile2=$TEMP_DIR/remux.mp4
do_test "$GPAC -no-reassign=no -i $dstfile -o $dstfile2 -graph -stats" "remux"
do_hash_test $dstfile2 "remux"

test_end
fi

libsrt=`$GPAC -h protocols 2>/dev/null | grep srt:`

if [ -n "$libsrt" ] ; then

ffmx_proto_srt ()
{

test_begin "ffmx-proto-srt-$1"
if [ $test_skip = 1 ] ; then
return;
fi

srcf=$TEMP_DIR/src.$1
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc reframer:xs=0:xe=2 -o $srcf$2" "src"
do_hash_test "$srcf" "src"

do_test "$GPAC -i $srcf -o srt://127.0.0.1:9999\?mode=listener:gpac:proto:ext=$1 -graph" "srt-send" &
sleep .5

dstf=$TEMP_DIR/rec.$1
do_test "$GPAC -i srt://127.0.0.1:9999:gpac:proto -o $dstf -graph" "srt-recv"
wait

#we must have the same files
$DIFF $dstf $srcf > /dev/null
rv=$?
if [ $rv != 0 ] ; then
result="source and copied files differ"
fi


test_end
}

ffmx_proto_srt "ts" ":pcr_offset=100000"
ffmx_proto_srt "gsf" ""
ffmx_proto_srt "mp4" ":frag"

fi

