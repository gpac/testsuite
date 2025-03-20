#!/bin/sh

test_http()
{

test_begin "http-$1"

if [ $test_skip = 1 ] ; then
 return
fi

if [ $4 = 1 ] ; then
tmode="netx"
else
tmode="network"
fi

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $2 inspect:allp:deep:test=$tmode:interleave=false:log=$myinspect$3 -graph -stats -clean-cache"
do_hash_test $myinspect "inspect"

test_end

}

test_http "mp4-simple" "http://download.tsi.telecom-paristech.fr/gpac/gpac_test_suite/mp4/counter_video_360.mp4 --cache=disk" "" 0

test_http "mp4-seek" "http://download.tsi.telecom-paristech.fr/gpac/gpac_test_suite/mp4/counter_video_360.mp4 --cache=disk" ":dur=2.0:start=10" 0

test_http "aac-simple" "http://download.tsi.telecom-paristech.fr/gpac/gpac_test_suite/regression_tests/auxiliary_files/enst_audio.aac --cache=disk" "" 0

#we don't test seeking of raw formats, as depending on the network speed the raw media indexing will have 0 or more entries at the time the PLAY event is sent
#so file seeking may be ignored or not, resulting in different results

#test_http "aac-seek" "http://download.tsi.telecom-paristech.fr/gpac/gpac_test_suite/regression_tests/auxiliary_files/enst_audio.aac --cache=disk" ":dur=2.0:start=2" 0

# test MP4 with no cache
test_http "mp4-nocache" "http://download.tsi.telecom-paristech.fr/gpac/gpac_test_suite/mp4/counter_video_360.mp4:gpac:cache=none" "" 0

# test fMP4 with no cache - we force a small block size to avoid different behaviours in VMs resulting in HAS_SYNC property being sent at different times
test_http "fmp4-nocache" "http://download.tsi.telecom-paristech.fr/gpac/DASH_CONFORMANCE/TelecomParisTech/mp4-onDemand/mp4-onDemand-h264bl_low.mp4:gpac:cache=none:block_size=1024" "" 1
