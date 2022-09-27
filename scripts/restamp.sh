#!/bin/sh
test_restamp()
{
test_begin "restamp-$1"

if [ $test_skip  = 1 ] ; then
	return
fi

mp4file=$TEMP_DIR/res.mp4
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264 -i $MEDIA_DIR/auxiliary_files/enst_audio.aac restamp$2 -o $mp4file -graph -blacklist=vtbdec,nvdec,ohevcdec,osvcdec" "restamp"
do_hash_test "$mp4file" "restamp"

test_end
}
#shift everything
test_restamp "delay" ":delay=1/10"
#shift video only
test_restamp "vdelay" ":delay_v=5/10"
#shift audio only
test_restamp "adelay" ":delay_a=9/10"
#fps change tests
test_restamp "rate" ":fps=-2"
test_restamp "fps" ":fps=30000/1001:rawv=force"

