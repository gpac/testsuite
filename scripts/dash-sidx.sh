#!/bin/sh

sidx_test ()
{
test_begin "dash-sidx-$1"
if [ $test_skip  = 1 ] ; then
return
fi

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:#ClampDur=8 -o $TEMP_DIR/live.mpd:segdur=4:cdur=1$2" "dash"
do_hash_test "$TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash1.m4s" "seg1"
test_end

}

sidx_test "flat" ":subs_sidx=0"
sidx_test "hierarchical" ":subs_sidx=2"
sidx_test "daisy" ":subs_sidx=2:chain_sidx"
#test one frag per sidx hence two entries (one frag, one chained sidx)
sidx_test "daisy-one" ":subs_sidx=4:chain_sidx"
