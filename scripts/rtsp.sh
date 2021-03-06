#test RTSP streaming server and client stacks - use port 8888 to avoid permission issues o test machines

PORT=8888
IP="127.0.0.1:$PORT"
MCASTIP="234.0.0.1"
IFCE="127.0.0.1"

rtsp_test_single ()
{

test_begin "rtsp-single-$1"
if [ $test_skip  = 1 ] ; then
return
fi

#start rtsp server
do_test "$GPAC -i $2 -o rtsp://$IP/testsession $3 -stats" "server-single" &

sleep 1

myinspect=$TEMP_DIR/inspect.txt

do_test "$GPAC -i rtsp://$IP/testsession inspect:deep:allp:dur=1/1:log=$myinspect $4 -stats -graph" "dump"

wait

do_hash_test $myinspect "dump-inspect"

test_end
}


rtsp_test_server ()
{

test_begin "rtsp-server-$1"
if [ $test_skip  = 1 ] ; then
return
fi

#start rtsp server
do_test "$GPAC -runfor=4000 rtspout:port=$PORT:runfor=1500:mounts=$MEDIA_DIR/auxiliary_files/ $3 -stats" "server" &

sleep 1

myinspect=$TEMP_DIR/inspect.txt

do_test "$GPAC -i $2 inspect:deep:allp:dur=1/1:interleave=false:log=$myinspect $4 -stats -graph" "dump"

wait

check_hash=1
#dynurl hash is not ok on linux due to rounding errors in TS recompute on 32 bits
if [ $GPAC_OSTYPE == "lin32" ] ; then
if [ $5 == 1 ] ; then
check_hash=0
fi
fi

if [ $check_hash == 1 ] ; then
do_hash_test $myinspect "dump-inspect"
fi

test_end
}


rtsp_test_single "regular" $MEDIA_DIR/auxiliary_files/enst_audio.aac " --tso=10000" ""
rtsp_test_single "interleave" $MEDIA_DIR/auxiliary_files/enst_audio.aac " --tso=10000" " --interleave"

rtsp_test_server "regular" "rtsp://$IP/enst_audio.aac" " --tso=10000" " " 0
rtsp_test_server "dynurl" "rtsp://$IP/@enst_audio.aac@enst_video.h264" " --tso=10000 --dynurl" "" 1
rtsp_test_server "mcast" "rtsp://$IP/enst_audio.aac" " --tso=10000 --mcast=mirror" " --force_mcast=$MCASTIP " 0

