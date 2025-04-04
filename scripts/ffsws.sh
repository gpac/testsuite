
ffsws_test ()
{

test_begin "ffsws-$1"

if [ $test_skip  = 1 ] ; then
return
fi

dstfile=$TEMP_DIR/dump.mp4
do_test "$GPAC -blacklist=vtbdec,nvdec,ohevcdec,osvcdec -i $2 ffsws$3 -o $dstfile:dur=1 -graph -stats" "scale"

#ffsws does not give the same result on arm than on x86
if [ "$GPAC_CPU" != "arm" ] ; then
do_hash_test $dstfile "scale"
fi
test_end
}

#check if we have libavformat support
ffsws=`$GPAC -h ffsws 2>/dev/null | grep ffsws`
if [ -n "$ffsws" ] ; then

ffsws_test "no_ar" "$MEDIA_DIR/auxiliary_files/enst_video.h264" ":osize=320x240:keepar=off"
ffsws_test "keep_ar" "$MEDIA_DIR/auxiliary_files/enst_video.h264" ":osize=320x256:keepar=full"
ffsws_test "keep_ar_pad" "$MEDIA_DIR/auxiliary_files/enst_video.h264" ":osize=256x320:keepar=full:padclr=cyan"
ffsws_test "keep_ar_osar" "$MEDIA_DIR/auxiliary_files/enst_video.h264" ":osize=256x256:keepar=full:osar=3/2"
ffsws_test "keep_ar_isar_full" "$MEDIA_DIR/auxiliary_files/enst_video.h264:#SAR=3/2" ":osize=256x256:keepar=full"
ffsws_test "keep_ar_isar_no" "$MEDIA_DIR/auxiliary_files/enst_video.h264:#SAR=3/2" ":osize=256x256:keepar=nosrc"

fi

