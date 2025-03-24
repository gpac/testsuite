#!/bin/sh
#
# Notes
#
# As mcast may be quite unreliable on VMs, most tests should be done using pcap recording and playback. This also allows hashing received data
#


proto="route"

#what we dump
inspectfilter="inspect:allp:deep:interleave=false:test=noprop:fmt=%dts%-%cts%-%sap%%lf%:hdr=0"

#amount of source we dash
CLAMP=":#ClampDur=2"



route_dashing ()
{
test_begin $proto"_dashing$1"
if [ $test_skip = 1 ] ; then
return
fi

#sender
src=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_main_320x180_128kbps.264
do_test "$GPAC -i $src$CLAMP dasher:profile=live:dmode=dynamic$2 @ -o $proto://225.1.1.0:6000/manifest.mpd -netcap=dst=$TEMP_DIR/dump.pcap" "send"

#receiver
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $proto://225.1.1.0:6000 $inspectfilter:dur=1:log=$myinspect -netcap=src=$TEMP_DIR/dump.pcap" "receive"
do_hash_test $myinspect "receive"

test_end
}


route_dash_filemode ()
{

test_begin $proto"_dash_filemode$1"
if [ $test_skip = 1 ] ; then
return
fi

#create dash
src=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_main_320x180_128kbps.264
do_test "$GPAC -i $src$CLAMP -o $TEMP_DIR/live.$2$3" "dash"

#sender, reading from dash session
do_test "$GPAC -i $TEMP_DIR/live.$2 dashin:forward=file @ -o $proto://225.1.1.0:6000/$4 -netcap=dst=$TEMP_DIR/dump.pcap" "send"

#receiver
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $proto://225.1.1.0:6000 $inspectfilter:dur=1:log=$myinspect -netcap=src=$TEMP_DIR/dump.pcap -logs=route@info" "receive"
do_hash_test $myinspect "receive"


test_end
}



route_dash_ll ()
{

test_begin $proto"_dash_ll"
if [ $test_skip = 1 ] ; then
return
fi

#sender
src=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_main_320x180_128kbps.264
do_test "$GPAC -i $src$CLAMP dasher:profile=live:dmode=dynamic --cdur=0.2 --asto=0.8 @ -o $proto://225.1.1.0:6000/manifest.mpd:llmode -netcap=dst=$TEMP_DIR/dump.pcap" "send"

#receiver
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $proto://225.1.1.0:6000 $inspectfilter:dur=1:log=$myinspect -logs=dash@info -netcap=src=$TEMP_DIR/dump.pcap" "receive"
do_hash_test $myinspect "receive"

test_end
}


route_dash_ll_filemode ()
{

test_begin $proto"_dash_ll_filemode"
if [ $test_skip = 1 ] ; then
return
fi

#sender from akamai LL
src=https://akamaibroadcasteruseast.akamaized.net/cmaf/live/657078/akasource/out.mpd
do_test "$GPAC -i $src dashin:forward=file @ -o $proto://225.1.1.0:6000/:llmode:runfor=4000:NCID=1 -netcap=id=1,dst=$TEMP_DIR/dump.pcap" "send"

#receiver
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $proto://225.1.1.0:6000 $inspectfilter:dur=1:log=$myinspect -logs=dash:route@info -netcap=src=$TEMP_DIR/dump.pcap" "receive"

#check we have received something
if [ ! -s $myinspect ]; then
result="Session not correctly received"
fi

test_end
}


atsc_dashing ()
{

test_begin "route_atsc_dashing"
if [ $test_skip = 1 ] ; then
return
fi

#sender
src=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_main_320x180_128kbps.264
do_test "$GPAC -i $src$CLAMP dasher:profile=live:dmode=dynamic @ -o atsc:// -netcap=dst=$TEMP_DIR/dump.pcap" "send"


#receiver
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i atsc://:tunein=1:nbcached=3 $inspectfilter:dur=1:log=$myinspect -netcap=src=$TEMP_DIR/dump.pcap -logs=route@info" "receive"
do_hash_test $myinspect "receive"

test_end
}

atsc_dashing_rec ()
{

test_begin "route_atsc_dashing_rec"
if [ $test_skip = 1 ] ; then
return
fi

#sender
src=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_main_320x180_128kbps.264
do_test "$GPAC -i $src$CLAMP dasher:profile=live:dmode=dynamic @ -o atsc:// -netcap=dst=$TEMP_DIR/dump.pcap" "send"

#receiver
do_test "$GPAC -r -i atsc://:odir=$TEMP_DIR:max_segs=4:tsidbg=10 -netcap=src=$TEMP_DIR/dump.pcap" "receive"

do_hash_test $TEMP_DIR/service1/counter_30s_I25_main_320x180_128kbps_dashinit.mp4 "receive-init"
do_hash_test $TEMP_DIR/service1/counter_30s_I25_main_320x180_128kbps_dash1.m4s "receive-seg"

#don't hash MPD, availability start time will change at each test
if [ ! -f $TEMP_DIR/service1/live.mpd ] ; then
result="Missing MPD"
fi

test_end
}


route_dash_ll_filemode_push ()
{

test_begin $proto"_dash_ll_filemode_push"
if [ $test_skip = 1 ] ; then
return
fi

#start sender from akamai LL
src=https://akamaibroadcasteruseast.akamaized.net/cmaf/live/657078/akasource/out.mpd
do_test "$GPAC -i $src dashin:forward=file @ -o $proto://225.1.1.0:6000/:llmode:runfor=4000 -logs=route@info" "send" &

#start HTTP server
do_test "$GPAC httpout:port=8080:rdirs=$TEMP_DIR:wdir=$TEMP_DIR:reqlog=PUT -runfor=4000 -req-timeout=10000" "server" &

#start receiver: get route MPD, open in filemode and push files to server using PUT
do_test "$GPAC -i $proto://225.1.1.0:6000/:max_segs=10 dashin:forward=file @ -o http://127.0.0.1:8080/live.mpd --hmode=push -runfor=3000 -req-timeout=2000 -logs=route:dash@info" "receive"

wait

n=`ls -1f $TEMP_DIR/* | wc -l | tr -d ' '`
n=${n#0}
#we must have at least one mpd, 2 inits, 2 segment, and take into account dir listing (4 items)
if [ $n -lt 9 ] ; then
result="Session not correctly received"
fi

test_end
}

route_files ()
{

test_begin $proto"_files"
if [ $test_skip = 1 ] ; then
return
fi

#sender
src=$MEDIA_DIR/auxiliary_files/logo.png
do_test "$GPAC -i $src @ -o $proto://225.1.1.0:6000/:runfor=1000 -logs=route@info -netcap=dst=$TEMP_DIR/dump.pcap" "send"

#receiver
do_test "$GPAC -i $proto://225.1.1.0:6000/:gcache=false fout:dst=$TEMP_DIR/\$num\$:dynext=true -netcap=src=$TEMP_DIR/dump.pcap" "receive"

$DIFF $MEDIA_DIR/auxiliary_files/logo.png $TEMP_DIR/0.png > /dev/null
rv=$?
if [ $rv != 0 ] ; then
  result="source and recieved files differ"
fi

test_end
}


route_dash_stl ()
{

test_begin $proto"_dash_stl"
if [ $test_skip = 1 ] ; then
return
fi

#sender
src=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_main_320x180_128kbps.264
do_test "$GPAC -i $src$CLAMP dasher:profile=live:dmode=dynamic:template=seg_\$Time\$:stl @ -o $proto://225.1.1.0:6000/manifest.mpd -netcap=dst=$TEMP_DIR/dump.pcap -logs=route@info" "send"

#receiver
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $proto://225.1.1.0:6000 $inspectfilter:dur=1:log=$myinspect -netcap=src=$TEMP_DIR/dump.pcap" "receive"
do_hash_test $myinspect "receive"


test_end
}


atsc_dashing
atsc_dashing_rec

protos="route mabr"
for i in $protos ; do
	proto=$i

	route_dashing "" ""
	route_dash_filemode "" "mpd" "" ""
	route_dash_filemode "-hls" "m3u8" ":muxtype=ts" ""
	route_dash_ll
	route_dash_ll_filemode
	route_dash_ll_filemode_push
	route_files
	route_dash_stl

done



proto=mabr
route_dash_filemode "-inband" "mpd" "" ":use_inband"
route_dash_filemode "-inband-hls" "m3u8" "" ":use_inband"
route_dashing "_dual" ":dual:mname=live.m3u8"

