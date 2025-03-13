#test RTSP streaming server and client stacks - use port 8888 to avoid permission issues o test machines

PORT=8888
IP="127.0.0.1:$PORT"
MCASTIP="234.0.0.1"
IFCE="127.0.0.1"
ORIG_GPAC="$GPAC"
GPAC="$GPAC -broken-cert"

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

do_test "$GPAC -i $4://$IP/testsession inspect:deep:allp:dur=1/1:log=$myinspect $5 -stats -graph" "dump"

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

if [ $5 == 2 ] ; then
check_hash=0
fi


if [ $check_hash == 1 ] ; then
do_hash_test $myinspect "dump-inspect"
fi

test_end
}


rtsp_test_single "regular" $MEDIA_DIR/auxiliary_files/enst_audio.aac "--tso=10000" "rtsp" ""
rtsp_test_single "interleave" $MEDIA_DIR/auxiliary_files/enst_audio.aac "--tso=10000" "rtsp" "--transport=tcp"
rtsp_test_single "tunnel" $MEDIA_DIR/auxiliary_files/enst_audio.aac "--tso=10000" "rtsph" ""

rtsp_test_server "regular" "rtsp://$IP/enst_audio.aac" " --tso=10000" " " 0
rtsp_test_server "dynurl" "rtsp://$IP/@enst_audio.aac@enst_video.h264" " --tso=10000 --dynurl" "" 1
rtsp_test_server "mcast" "rtsp://$IP/enst_audio.aac" " --tso=10000 --mcast=mirror" " --force_mcast=$MCASTIP " 0


rtsp_test_server_error ()
{

test_begin "rtsp-server-error"
if [ $test_skip  = 1 ] ; then
return
fi

#start rtsp server
do_test "$GPAC -runfor=4000 rtspout:port=$PORT:mounts=$MEDIA_DIR/auxiliary_files/ --dynurl -stats" "server" &
sleep 1

do_test "$GPAC -i rtsp://$IP/?http://localhost/dummy inspect:deep:allp:dur=1/1 -stats -graph" "dump"

wait
test_end
}

rtsp_test_server_error


rtsp_test_auth ()
{

test_begin "rtsp-server-$1"
if [ $test_skip  = 1 ] ; then
return
fi

echo "[$MEDIA_DIR/auxiliary_files]" > $TEMP_DIR/rules.txt
echo "ru=gpac" >> $TEMP_DIR/rules.txt

#do NOT use $GPAC since it may be passed with no config
MYGPAC="gpac -for-test -mem-track"

$MYGPAC -creds=-gpac 2&> /dev/null

do_test "$MYGPAC -creds=_gpac:password=gpac" "set-creds"
#start rtsp server
do_test "$MYGPAC -runfor=4000 rtspout:port=$PORT:mounts=$TEMP_DIR/rules.txt:runfor=3000 --tso=10000 -logs=rtp@info" "server" &
sleep 1

myinspect=$TEMP_DIR/inspect.txt

do_test "$MYGPAC -i rtsp://$2$IP/counter.hvc inspect:deep:allp:dur=1/1:log=$myinspect -stats -graph -logs=rtp@info" "dump"

if [ -n "$2" ] ; then
do_hash_test $myinspect "dump-inspect"
fi

wait

test_end
}

rtsp_test_auth "auth" "gpac:gpac@"

rtsp_test_auth "auth-none" ""



test_rtsps_server()
{
test_begin "rtsp-server-$1"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC rtspout$2:mounts=$MEDIA_DIR:cert=$MEDIA_DIR/tls/localhost.crt:pkey=$MEDIA_DIR/tls/localhost.key:runfor=3000 --tso=10000" "rtsps-server" &
sleep .5

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $3/auxiliary_files/enst_audio.aac inspect:allp:deep:dur=1/1:test=network:interleave=false:log=$myinspect -graph -stats" "rtsps-client"
do_hash_test $myinspect "rtsps-client"
test_end

}

test_rtsps_server "tls" ":port=8554" "rtsps://127.0.0.1:8554"
test_rtsps_server "https-tunnel" ":port=8443" "rtsph://127.0.0.1:8443"


rtsp_test_m2ts ()
{

test_begin "rtsp-server-m2ts"
if [ $test_skip  = 1 ] ; then
return
fi

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_audio.aac -o $TEMP_DIR/src.ts" "tsmux"

#start rtsp server
do_test "$GPAC -runfor=2000 rtspout:port=$PORT:runfor=1500:mounts=$TEMP_DIR/ -logs=rtp@info" "server" &

sleep 0.5

myinspect=$TEMP_DIR/inspect.txt

do_test "$GPAC -i rtsp://127.0.0.1:$PORT/src.ts inspect:deep:allp:dur=1/1:log=$myinspect $4  -logs=rtp@info" "dump"

wait
do_hash_test $myinspect "dump-inspect"

test_end
}

rtsp_test_m2ts

GPAC="$ORIG_GPAC"
