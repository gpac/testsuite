
ffbsf_test ()
{

test_begin "ffbsf-$1"

if [ $test_skip  = 1 ] ; then
return
fi

dst=$TEMP_DIR/mux.mp4
do_test "$GPAC $2 -o $dst" "run"
do_hash_test $dst "run"

test_end
}

#check if we have libavfilter support
ffbsf=`$GPAC -h ffbsf 2>/dev/null | grep ffbsf`
if [ -n "$ffbsf" ] ; then

#h264 metadata bsf
ffbsf_test "avc" "-i $MEDIA_DIR/auxiliary_files/enst_video.h264 ffbsf:f=h264_metadata:video_full_range_flag=1"
#h264 metadata bsf along with aac (passthrough test)
ffbsf_test "avc-aac" "-i $MEDIA_DIR/auxiliary_files/enst_video.h264 -i $MEDIA_DIR/auxiliary_files/enst_audio.aac ffbsf:f=h264_metadata:video_full_range_flag=1"

#av1 metadata bsf - also test sub option reporting by adding h264_metadata
ffbsf_test "av1" "-i $MEDIA_DIR/auxiliary_files/video.av1 ffbsf:f=h264_metadata,av1_metadata:color_range=pc:video_full_range_flag=1"

#dual
pl=pl.txt
echo $MEDIA_DIR/auxiliary_files/enst_video.h264 > pl.txt
echo $MEDIA_DIR/auxiliary_files/video.av1 >> pl.txt

ffbsf_test "dual" "-i $pl ffbsf:f=h264_metadata,av1_metadata:color_range=pc:video_full_range_flag=1"

mv $pl $TEMP_DIR/$pl

fi
