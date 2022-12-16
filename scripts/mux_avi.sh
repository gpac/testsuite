
test_avimx()
{

test_begin "mux-avi-$1"
if [ $test_skip  = 1 ] ; then
return
fi

dstfile="$TEMP_DIR/test.avi"
if [ $3 != 0 ] ; then
srcfile=$MEDIA_DIR/auxiliary_files/count_video.cmp
else
#issue with current ffmpeg with our old cmp test file on windows...
srcfile=$MEDIA_DIR/auxiliary_files/enst_video.h264
fi

do_test "$GPAC -i $srcfile -i $MEDIA_DIR/auxiliary_files/count_english.mp3 $2 -o $dstfile" "mux"
if [ $3 != 0 ] ; then

#avilib does not always give the same binary output, we cannot hash the result but we hash the inspect of the file
#do_hash_test $dstfile "mux"

do_test "$MP4BOX -raw video $dstfile" "aviraw-video"
do_hash_test $TEMP_DIR/test.cmp "aviraw-video"
do_test "$MP4BOX -raw audio $dstfile" "aviraw-audio"
do_hash_test $TEMP_DIR/test.mp2 "aviraw-audio"
fi

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $dstfile inspect:allp:fmt=%cts%-%size%%lf%:interleave=false:log=$myinspect -graph -stats" "inspect"
do_hash_test $myinspect "inspect"

if [ $3 != 0 ] ; then
myinspect=$TEMP_DIR/inspect_seek.txt
do_test "$GPAC -i $dstfile inspect:allp:fmt=%cts%-%size%%lf%:interleave=false:log=$myinspect:start=5 -graph -stats" "inspect-seek"
do_hash_test $myinspect "inspect-seek"
fi

test_end

}

test_avimx "compressed" "" 1
test_avimx "compressed-opendml" "--opendml_size=8000" 1
#don't hash uncompressed file
test_avimx "uncompressed" "-blacklist=vtbdec,nvdec reframer:raw=av @" 0
