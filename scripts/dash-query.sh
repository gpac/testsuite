#!/bin/sh

test_begin "dash-query"
if [ $test_skip  = 1 ] ; then
return
fi

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 -o $TEMP_DIR/live.mpd:profile=live:query=test=1&foo=1" "option"
do_hash_test "$TEMP_DIR/live.mpd" "option-mpd"

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:#ASQuery=test=1 -o $TEMP_DIR/live.mpd:profile=live" "prop"
do_hash_test "$TEMP_DIR/live.mpd" "prop-mpd"

test_end
