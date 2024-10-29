#!/bin/bash

PORT=8080
localhost=127.0.0.1
HTTP_SERVER_RUNFOR=5000

function test_full_repair_one_packet_dropped() 
{
    test_begin "repair-full-one-packet-dropped"
    if [ $test_skip = 1 ] ; then
        return
    fi

    if [ $# -lt 1 ] ; then
        echo "Usage: test_full_repair_one_packet_dropped <list_packets_to_drop>"
        return
    fi

    mkdir -p $TEMP_DIR/dash_session
    myinspect_refs=$TEMP_DIR/inspect_refs.txt
    mp4_file=$TEMP_DIR/counter.mp4
    route_capture=$TEMP_DIR/route.gpc

    
    #convert hvc file into mp4 file with refs
    do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc:refs -o $TEMP_DIR/counter.mp4" "hvc-to-mp4-convert" 

    if [ ! -f $TEMP_DIR/counter.mp4 ]; then
        result="hvc to mp4 conversion failed"
    fi

    do_hash_test $mp4_file "mp4_file"


    do_test "$GPAC -i $TEMP_DIR/counter.mp4 inspect:dur=1:allp:deep:test=network:interleave=false:log=$myinspect_refs"
    do_hash_test $myinspect_refs "inspect_refs"


    #generate dash session
    do_test "$GPAC -i $TEMP_DIR/counter.mp4 -o $TEMP_DIR/dash_session/live.mpd" "session-dash-generation"
    do_test "$GPAC -i $TEMP_DIR/dash_session/live.mpd dashin:forward=mani -o route://234.1.1.1:1234/live.mpd -netcap=dst=$route_capture" "gpc-capture-generation"

    #start http server
    do_test "$GPAC -runfor=$HTTP_SERVER_RUNFOR httpout:port=$PORT:rdirs=$TEMP_DIR/dash_session:reqlog=GET"  "http-repair-server" &
    sleep 0.5

    for packet_to_drop in "$@"; do
        #start route session with full repair and one packet dropped
        myinspect_drop_packet=$TEMP_DIR/inspect_drop_packet_${packet_to_drop}.txt
        received_mp4_file_rec=$TEMP_DIR/counter_rec_${packet_to_drop}.mp4

        do_test "$GPAC -i route://234.1.1.1:1234/live.mpd:repair=full::repair_urls=http://$localhost:$PORT/ -netcap=src=$TEMP_DIR/route.gpc,nrt,[s=$packet_to_drop] 
                            inspect:dur=1:allp:deep:test=network:interleave=false:log=${myinspect_drop_packet} -o $TEMP_DIR/counter_rec_${packet_to_drop}.mp4" "drop-packet-${packet_to_drop}"

        do_hash_test $received_mp4_file_rec "mp4_file_rec_${packet_to_drop}"
        do_hash_test $myinspect_drop_packet "inspect_drop_packet_${packet_to_drop}"
    done

    test_end
}



do_tests() 
{
    test_full_repair_one_packet_dropped 20 40 60 80 100
}


do_tests