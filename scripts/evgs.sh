
evgs_test ()
{
test_begin "evgs-$1"
if [ $test_skip  = 1 ] ; then
return
fi

dstfile=$TEMP_DIR/dump.mp4
do_test "$GPAC -blacklist=vtbdec,nvdec,ohevcdec,osvcdec -i $2 evgs$3 -o $dstfile:dur=1 -graph -stats" "scale"
do_hash_test $dstfile "scale"
test_end
}

evgs_test "no_ar" "$MEDIA_DIR/auxiliary_files/enst_video.h264" ":osize=320x240:keepar=off"
evgs_test "keep_ar" "$MEDIA_DIR/auxiliary_files/enst_video.h264" ":osize=320x256:keepar=full"
evgs_test "keep_ar_pad" "$MEDIA_DIR/auxiliary_files/enst_video.h264" ":osize=256x320:keepar=full:padclr=cyan"
evgs_test "keep_ar_osar" "$MEDIA_DIR/auxiliary_files/enst_video.h264" ":osize=256x256:keepar=full:osar=3/2"
evgs_test "keep_ar_isar_full" "$MEDIA_DIR/auxiliary_files/enst_video.h264:#SAR=3/2" ":osize=256x256:keepar=full"
evgs_test "keep_ar_isar_no" "$MEDIA_DIR/auxiliary_files/enst_video.h264:#SAR=3/2" ":osize=256x256:keepar=nosrc"

