
test_bsrw()
{

test_begin "bsrw-$1"

if [ "$test_skip" = 1 ] ; then
return
fi

mp4file="$TEMP_DIR/setsar.mp4"

do_test "$GPAC -i $2 bsrw$3 @ -o $mp4file" "bswr"
do_hash_test $mp4file "bswr"

test_end
}

#sar rewrite tests
test_bsrw "sar-avc" $MEDIA_DIR/auxiliary_files/enst_video.h264 ":sar=16/9"
test_bsrw "sar-hevc" $MEDIA_DIR/auxiliary_files/counter.hvc ":sar=16/9"
test_bsrw "sar-m4v" $MEDIA_DIR/auxiliary_files/count_video.cmp ":sar=4/3:m4vpl=90"
#AVC profile rewrite tests
test_bsrw "prof-avc" $MEDIA_DIR/auxiliary_files/enst_video.h264 ":prof=90:pcomp=3:lev=10"
#AVC and HEVC SEI removal tests
test_bsrw "nosei-avc" $MEDIA_DIR/auxiliary_files/enst_video.h264 ":rmsei"
test_bsrw "nosei-hevc" $MEDIA_DIR/auxiliary_files/counter.hvc ":rmsei"


if [ $EXTERNAL_MEDIA_AVAILABLE = 0 ] ; then
  return
fi

#SAR rewrite on prores, test clrp/txchar and mxcoef with integer values
test_bsrw "sar-prores" "$EXTERNAL_MEDIA_DIR/qt_prores/prores422.mov#video" ":sar=16/9:clrp=2:txchar=3:mxcoef=2"

test_bsrw "sar-vvc" $EXTERNAL_MEDIA_DIR/counter/counter_30s_1280x720p_I25_closedGOP_512kpbs.vvc ":sar=16/9"
test_bsrw "nosei-vvc" $EXTERNAL_MEDIA_DIR/counter/counter_30s_1280x720p_I25_closedGOP_512kpbs.vvc ":rmsei"

#test SEI filtering
test_bsrw "sei-whitelist" $MEDIA_DIR/auxiliary_files/counter.hvc ":seis=5"
test_bsrw "sei-blacklist" $MEDIA_DIR/auxiliary_files/counter.hvc ":rmsei:seis=5"
test_bsrw "sei-blacklist-single" $EXTERNAL_MEDIA_DIR/counter/counter_30s_1280x720p_I25_closedGOP_512kpbs.vvc ":rmsei:seis=5"
