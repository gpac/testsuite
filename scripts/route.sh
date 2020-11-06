#!/bin/sh
inspectfilter="inspect:allp:deep:interleave=false:test=noprop:fmt=%dts%-%cts%-%sap%%lf%"

route_dashing ()
{

test_begin "route_dashing"
if [ $test_skip = 1 ] ; then
return
fi

#start receiver
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i route://225.1.1.0:6000 $inspectfilter:dur=1:log=$myinspect" "receive" &

#start sender, dash only 4s in dynamic MPD mode
src=$MEDIA_DIR/auxiliary_files/counter.hvc
do_test "$GPAC -i $src:#ClampDur=4 dasher:profile=live:dmode=dynamic @ -o route://225.1.1.0:6000/manifest.mpd" "send"

test_end
}




route_dash_filemode ()
{

test_begin "route_dash_filemode"
if [ $test_skip = 1 ] ; then
return
fi

#create dash
src=$MEDIA_DIR/auxiliary_files/counter.hvc
do_test "$GPAC -i $src:#ClampDur=4 -o $TEMP_DIR/live.mpd" "dash"

#start receiver
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i route://225.1.1.0:6000 $inspectfilter:dur=1:log=$myinspect" "receive" &

#start sender, reading from dash session
do_test "$GPAC -i $TEMP_DIR/live.mpd dashin:filemode @ -o route://225.1.1.0:6000/" "send"

test_end
}



route_dash_ll ()
{

test_begin "route_dash_ll"
if [ $test_skip = 1 ] ; then
return
fi

#start receiver
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i route://225.1.1.0:6000 $inspectfilter:dur=1:log=$myinspect -logs=dash@info" "receive" &

#start sender, dash only 4s in dynamic MPD mode
src=$MEDIA_DIR/auxiliary_files/counter.hvc
do_test "$GPAC -i $src:#ClampDur=4 dasher:profile=live:dmode=dynamic --cdur=0.2 --asto=0.8 @ -o route://225.1.1.0:6000/manifest.mpd:llmode -logs=route@debug" "send"

test_end
}


route_dash_ll_filemode ()
{

test_begin "route_dash_ll_filemode"
if [ $test_skip = 1 ] ; then
return
fi

#start sender from akamai LL
src=https://akamaibroadcasteruseast.akamaized.net/cmaf/live/657078/akasource/out.mpd
do_test "$GPAC -i $src dashin:filemode @ -o route://225.1.1.0:6000/:llmode:runfor=10000 -logs=route@debug" "send" &

sleep 1
#start receiver
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i route://225.1.1.0:6000 $inspectfilter:dur=1:log=$myinspect -logs=dash:route@info" "receive"


test_end
}


atsc_dashing ()
{

test_begin "route_atsc_dashing"
if [ $test_skip = 1 ] ; then
return
fi

#start receiver
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i atsc://:nbcached=3 $inspectfilter:dur=1:log=$myinspect -logs=route@debug" "receive" &

#start sender, dash only 4s in dynamic MPD mode
src=$MEDIA_DIR/auxiliary_files/counter.hvc
do_test "$GPAC -i $src:#ClampDur=6 dasher:profile=live:dmode=dynamic @ -o atsc://" "send"

test_end
}

atsc_dashing_rec ()
{

test_begin "route_atsc_dashing_rec"
if [ $test_skip = 1 ] ; then
return
fi

#start receiver
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -r -i atsc://:odir=$TEMP_DIR:max_segs=4:tsidbg=10" "receive" &

#start sender, dash only 4s in dynamic MPD mode
src=$MEDIA_DIR/auxiliary_files/counter.hvc
do_test "$GPAC -i $src:#ClampDur=6 dasher:profile=live:dmode=dynamic @ -o atsc://" "send"

test_end
}


route_dash_ll_filemode_push ()
{

test_begin "route_dash_ll_filemode_push"
if [ $test_skip = 1 ] ; then
return
fi

#start sender from akamai LL
src=https://akamaibroadcasteruseast.akamaized.net/cmaf/live/657078/akasource/out.mpd
do_test "$GPAC -i $src dashin:filemode @ -o route://225.1.1.0:6000/:llmode:runfor=10000 -logs=route@info" "send" &

#start HTTP server
do_test "$GPAC httpout:port=8080:rdirs=$TEMP_DIR:wdir=$TEMP_DIR:reqlog=PUT -runfor=8000 -req-timeout=10000" "server" &

#start receiver: get route MPD, open in filemode and push files to server using PUT
do_test "$GPAC -i route://225.1.1.0:6000 dashin:filemode @ -o http://127.0.0.1:8080/live.mpd --hmode=push -runfor=6000 -logs=route:dash@info" "receive"

wait

n=`ls -1f $TEMP_DIR/* | wc -l | tr -d ' '`
n=${n#0}
#we must have at least one mpd, 2 inits, 2 segment, and take into account dir listing (4 items)
if [ $n -lt 9 ] ; then
result="Session not correctly received"
fi

test_end
}


route_dashing
route_dash_filemode
route_dash_ll
route_dash_ll_filemode
atsc_dashing
atsc_dashing_rec
route_dash_ll_filemode_push

