
IFCE="127.0.0.1"
ADDR="rtp://127.0.0.1:1234/:ifce=$IFCE"


rtp_test()
{
test_begin "rtp-m2ts$1"
if [ $test_skip  = 1 ] ; then
return
fi

#run client, inspecting only the first second
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -for-test -i $2 inspect:deep:allp:dur=1/1:log=$myinspect -stats -graph" "play" &

sleep 0.1
#run streamer for 2s and tso=100000 to avoid a rand() that might impact TS rounding differently (hence slightly different durations->different hashes)
do_test "$GPAC -runfor=2000 -i $MEDIA_DIR/auxiliary_files/enst_audio.aac -o $ADDR:ext=ts:tso=100000:loop=false -stats" "stream"

wait

do_hash_test $myinspect "stream-inspect"

test_end
}

rtp_test "" $ADDR
rtp_test "-udp" "udp://127.0.0.1:1234/:ifce=$IFCE --timeout=1000"

