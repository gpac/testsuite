netcap_udp ()
{

test_begin "netcap-udp"
if [ $test_skip  = 1 ] ; then
return
fi

dumpfile="$TEMP_DIR/dump.gpc"

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264 -o udp://234.0.0.1:1234/:ext=ts:pcr_init=0:pes_pack=none -netcap=dst=$dumpfile" "dump"
#we cannot hash the capture file due to capture timestamps

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i udp://234.0.0.1:1234/ inspect:deep:log=$myinspect -netcap=src=$dumpfile,nrt" "inspect"
do_hash_test $myinspect "inspect"

test_end
}

netcap_udp


netcap_rtp ()
{

test_begin "netcap-rtp"
if [ $test_skip  = 1 ] ; then
return
fi

dumpfile="$TEMP_DIR/dump.gpc"

$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264:dur=2 -new $TEMP_DIR/src.mp4 2> /dev/null

do_test "$GPAC -i $TEMP_DIR/src.mp4 -o session.sdp:loop=false:tso=100000 -netcap=dst=$dumpfile" "dump"
#we cannot hash the capture file due to capture timestamps

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i session.sdp inspect:deep:log=$myinspect -netcap=src=$dumpfile,nrt" "inspect"
do_hash_test $myinspect "inspect"

test_end
}

netcap_rtp


netcap_route ()
{

test_begin "netcap-route"
if [ $test_skip  = 1 ] ; then
return
fi

dumpfile="$TEMP_DIR/dump.gpc"

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc:#ClampDur=4 -o route://234.0.0.1:1234/live.mpd -netcap=dst=$dumpfile" "dump"
#we cannot hash the capture file due to capture timestamps

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i route://234.0.0.1:1234/live.mpd inspect:deep:log=$myinspect -netcap=src=$dumpfile,nrt" "inspect"
do_hash_test $myinspect "inspect"

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i route://234.0.0.1:1234/live.mpd:gcache=false -o $TEMP_DIR/rip/\$File\$:dynext -netcap=src=$dumpfile,nrt" "rip"

n=`ls -1f $TEMP_DIR/rip/* | wc -l | tr -d ' '`
n=${n#0}
if [ "$n" != 6 ] ; then
result="Wrong file count $n (expected 6)"
fi


test_end
}

netcap_route

