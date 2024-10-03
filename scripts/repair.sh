#!/bin/bash


PORT=8080
localhost=127.0.0.1
myinspect=$TEMP_DIR/inspect.txt
repair_dir="$MEDIA_DIR/repair"
HTTP_SERVER_RUNFOR=6000


function test_full_repair_one_packet_dropped() 
{
    test_begin "repair-full-one-packet-dropped"
    if [ $test_skip = 1 ] ; then
        return
    fi

    #start http server
    do_test "$GPAC -runfor=$HTTP_SERVER_RUNFOR httpout:port=$PORT:rdirs=$repair_dir/short_dash_session:reqlog=GET" &
    sleep 0.5
    #start route session with full repair and one packet dropped
    do_test "$GPAC -i route://234.1.1.1:1234/live.mpd:repair=full::repair_urls=http://$localhost:$PORT/ -netcap=src=$repair_dir/short_route.gpc,nrt,[s=20] inspect:dur=1:allp:deep:test=network:interleave=false:log=$myinspect"
    do_hash_test $myinspect "inspect"
    #kill http server, no need to wait for it to finish
    test_force_end
}



do_tests() 
{
    test_full_repair_one_packet_dropped
}


do_tests