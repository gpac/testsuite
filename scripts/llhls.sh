#!/bin/sh

#note: the port used is 8080 since the testbot on linux will not allow 80

#increase run time for tests on VM
HTTP_SERVER_RUNFOR=6000

source=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_640x360_192kbps.264
source2=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264

#check if we have nghttp2 support
h2_args=""
has_h2=`$GPAC -hx core 2>/dev/null | grep no-h2`
if [ -n "$has_h2" ] ; then
h2_args="$h2_args -no-h2"
fi


test_llhls_gen()
{
test_begin "llhls-modes"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC $h2_args -i $source:#ClampDur=4 -o $TEMP_DIR/live_br.m3u8:segdur=2:cdur=0.2:dmode=dynamic:llhls=br" "gen-br"
#linux 32 bits gives slightly different float values for PART-HOLD-BACK and PART-TARGET ...
if [ $GPAC_OSTYPE != "lin32" ] ; then
do_hash_test $TEMP_DIR/live_br_1.m3u8 "manifest-br"
fi

myinspect=$TEMP_DIR/inspect-br.txt
do_test "$GPAC $h2_args -i $TEMP_DIR/live_br.m3u8 inspect:deep:dur=1:log=$myinspect" "inspect-br"
do_hash_test $myinspect "inspect-br"

do_test "$GPAC $h2_args -i $source:#ClampDur=4 -o $TEMP_DIR/live_sf.m3u8:segdur=2:cdur=0.2:dmode=dynamic:llhls=sf" "gen-sf"

if [ $GPAC_OSTYPE != "lin32" ] ; then
do_hash_test $TEMP_DIR/live_sf_1.m3u8 "manifest-sf"
fi

myinspect=$TEMP_DIR/inspect-sf.txt
do_test "$GPAC $h2_args -i $TEMP_DIR/live_br.m3u8 inspect:deep:dur=1:log=$myinspect" "inspect-sf"
do_hash_test $myinspect "inspect-sf"

do_test "$GPAC $h2_args -i $source:#ClampDur=4 -o $TEMP_DIR/live_brsf.m3u8:segdur=2:cdur=0.2:dmode=dynamic:llhls=brsf" "gen-brsf"
do_hash_test $TEMP_DIR/live_brsf.m3u8 "manifest1-brsf"
if [ $GPAC_OSTYPE != "lin32" ] ; then
do_hash_test $TEMP_DIR/live_brsf_1.m3u8 "chilpl1-brsf"
fi
do_hash_test $TEMP_DIR/live_brsf_IF.m3u8 "manifest2-brsf"
if [ $GPAC_OSTYPE != "lin32" ] ; then
do_hash_test $TEMP_DIR/live_brsf_1_IF.m3u8 "chilpl2-brsf"
fi

myinspect=$TEMP_DIR/inspect-brsf-br.txt
do_test "$GPAC $h2_args -i $TEMP_DIR/live_brsf.m3u8 inspect:deep:dur=1:log=$myinspect" "inspect-brsf-br"
do_hash_test $myinspect "inspect-brsf-br"

myinspect=$TEMP_DIR/inspect-brsf-sf.txt
do_test "$GPAC $h2_args -i $TEMP_DIR/live_brsf_IF.m3u8 inspect:deep:dur=1:log=$myinspect" "inspect-brsf-sf"
do_hash_test $myinspect "inspect-brsf-sf"


do_test "$GPAC $h2_args -i $source:#ClampDur=4 -o $TEMP_DIR/live_br.m3u8:segdur=2:cdur=0.2:llhls=br:seg_sync=yes" "gen-br-sync"
#linux 32 bits gives slightly different float values for PART-HOLD-BACK and PART-TARGET ...
if [ $GPAC_OSTYPE != "lin32" ] ; then
do_hash_test $TEMP_DIR/live_br_1.m3u8 "manifest-br-sync"
fi

test_end

}

test_llhls_server()
{
test_begin "llhls-server-$1"
if [ $test_skip = 1 ] ; then
 return
fi

#run 6s (source is 30, we dashing only 6 but we need RT regulation for low latency check)
do_test "$GPAC $h2_args -runfor=8000 -i $source:#ClampDur=6 reframer:rt=on @ -o http://127.0.0.1:8080/live.m3u8:segdur=2:cdur=0.2:dmode=dynamic:rdirs=$TEMP_DIR:reqlog=GET:llhls=$2" "server" &
#sleep 500ms to make sure the server is up and running
sleep .5

#grab 4s of content, hash result
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC $h2_args -i http://127.0.0.1:8080/live.m3u8$3 inspect:deep:test=network:dur=4:log=$myinspect" "client"
do_hash_test $myinspect "inspect"

test_end
}


test_llhls_server_dual()
{
test_begin "llhls-server-dual-$1"
if [ $test_skip = 1 ] ; then
 return
fi

#run 6s (source is 30, we dashing only 6 but we need RT regulation for low latency check)
do_test "$GPAC $h2_args -runfor=8000 -i $source:#ClampDur=6:#Bitrate=200k  -i $source2:#ClampDur=6:#Bitrate=500k reframer:rt=on @ -o http://127.0.0.1:8080/live.m3u8:segdur=1:cdur=0.2:dmode=dynamic:rdirs=$TEMP_DIR:reqlog=GET$2" "server" &
#sleep 500ms to make sure the server is up and running
sleep .5

#grab 4s of content, hash result
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC $h2_args -i http://127.0.0.1:8080/live.m3u8$3 --auto_switch=1 inspect:deep:test=network:dur=4:fmt=%dts%-%cts%%lf%:log=$myinspect" "client"
do_hash_test $myinspect "inspect"

test_end
}


#test simple generation, no server
test_llhls_gen

#test low latency access using files for segment parts
test_llhls_server "files" "sf" ""

#test low latency access using byte ranges for segment parts, merging parts into a single open byte range
test_llhls_server "ranges" "br" ""

#test low latency access using byte ranges for segment parts, NOT merging parts
test_llhls_server "ranges-nomerge" "br" ":gpac:llhls_merge=no"

#test regular HLS+files, no low latency in 2 qualities with client switching quality every segment
test_llhls_server_dual "noll" "" ""

#test low latency access using files for segment parts, 2 qualities with client switching quality every segment
test_llhls_server_dual "sf" ":llhls=sf" ""

#test low latency access using byte ranges, merging parts into a single open byte range, 2 qualities with client switching quality every segment
test_llhls_server_dual "br" ":llhls=br" ""

#test low latency access using byte ranges, NOT merging parts, 2 qualities with client switching quality every segment
test_llhls_server_dual "br-nomerge" ":llhls=br" ":gpac:llhls_merge=no"
