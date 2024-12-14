


test_begin "mp4box-mux"
if [ "$test_skip" = 1 ] ; then
return
fi

mp4file="$TEMP_DIR/test.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264 -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -new $mp4file" "add"
do_hash_test $mp4file "add"

tsfile="$TEMP_DIR/test.ts"
do_test "$MP4BOX -mux $tsfile:pcr_init=0:pes_pack=none $mp4file" "mux-ts"
do_hash_test $tsfile "mux-ts"


do_test "$MP4BOX -raw video $tsfile" "tsdump-video"
do_hash_test $TEMP_DIR/test.264 "tsdump-video"

do_test "$MP4BOX -raw 101 $tsfile" "tsdump-audio"
do_hash_test $TEMP_DIR/test.aac "tsdump-audio"


do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264:#MuxIndex=2 -i $MEDIA_DIR/auxiliary_files/enst_audio.aac:#MuxIndex=1 -o $mp4file" "add-idx"
do_hash_test $mp4file "add-idx"

#check if we have libavformat support, if so test ts->mkv and mp4->mkv
ffmx=`$GPAC -h ffmx 2>/dev/null | grep ffmx`
if [ -n "$ffmx" ] ; then
#we don't hash mkv, not bitexact depending on platforms - this is checked in ffmx.sh
do_test "$MP4BOX -mux $TEMP_DIR/test1.mkv $tsfile" "ts-mkv"

do_test "$MP4BOX -mux $TEMP_DIR/test2.mkv $mp4file" "mp4-mkv"

fi

iamf_mp4file="$TEMP_DIR/test-iamf.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/video_5s.ivf -add $MEDIA_DIR/auxiliary_files/audio_opus.iamf -new $iamf_mp4file" "add-iamf"
do_hash_test $iamf_mp4file "add-iamf"

test_end

