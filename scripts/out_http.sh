#!/bin/sh

#note: the port used is 8080 since the testbot on linux will not allow 80

#increase run time for tests on VM
HTTP_SERVER_RUNFOR=6000

ORIG_GPAC="$GPAC"
ORIG_MP4BOX="$MP4BOX"
TESTSUF=""

test_http_server()
{
test_begin "http$TESTSUF-server"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC httpout:port=8080:quit:reqlog:rdirs=$MEDIA_DIR" "http-server" &
#sleep half a sec to make sure the server is up and running
sleep .5

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i http://127.0.0.1:8080/auxiliary_files/enst_audio.aac --cache=disk -clean-cache inspect:allp:deep:test=network:interleave=false:log=$myinspect$3 -graph -stats" "client-inspect"
do_hash_test $myinspect "inspect"
test_end

}


test_http_server_dlist()
{
test_begin "http$TESTSUF-server-dlist"
if [ $test_skip = 1 ] ; then
 return
fi

touch $TEMP_DIR/file.txt
mkdir -p $TEMP_DIR/mydir
touch $TEMP_DIR/mydir/other.txt

do_test "$GPAC httpout:port=8080:quit:dlist:rdirs=$TEMP_DIR" "http-server-dlist" &
#sleep half a sec to make sure the server is up and running
sleep .5

do_test "$MP4BOX -wget http://127.0.0.1:8080/ $TEMP_DIR/listing.txt" "mp4box-get"
found=`grep file.txt $TEMP_DIR/listing.txt`
if [ "$found" = "" ] ; then
	result="listing failed"
fi
found=`grep mydir $TEMP_DIR/listing.txt`
if [ "$found" = "" ] ; then
	result="listing failed"
fi

do_test "$GPAC httpout:port=8080:quit:dlist:rdirs=$TEMP_DIR" "http-server-dlist" &
sleep .5

do_test "$MP4BOX -wget http://127.0.0.1:8080/mydir/ $TEMP_DIR/listing2.txt" "mp4box-get2"
found=`grep other.txt $TEMP_DIR/listing2.txt`
if [ "$found" = "" ] ; then
	result="listing2 failed"
fi

test_end
}


test_http_server_sink()
{
test_begin "http$TESTSUF-server-sink"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_audio.aac -o http://127.0.0.1:8080/live.aac:gpac:hold -logs=http@debug" "http-sink" &
#sleep half a sec to make sure the server is up and running
sleep .5

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i http://127.0.0.1:8080/live.aac --cache=disk inspect:allp:deep:test=network:interleave=false:log=$myinspect$3 -logs=http@debug" "client-inspect"
do_hash_test $myinspect "inspect"

test_end
}




test_http_push()
{
test_begin "http$TESTSUF-push"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC httpout:port=8080:quit:wdir=$TEMP_DIR" "http-server-rec" &
#sleep half a sec to make sure the server is up and running
sleep .5

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_audio.aac -o http://127.0.0.1:8080/mydir/test.aac:gpac:hmode=push" "http-push"

wait

$DIFF $MEDIA_DIR/auxiliary_files/enst_audio.aac $TEMP_DIR/mydir/test.aac > /dev/null
rv=$?
if [ $rv != 0 ] ; then
  result="source and copied files differ"
fi

test_end
}

test_http_source()
{
test_begin "http$TESTSUF-source"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC httpout:port=8080:quit:hmode=source -o $TEMP_DIR/mydir/test.aac" "http-source" &
#sleep half a sec to make sure the server is up and running
sleep .5

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_audio.aac -o http://127.0.0.1:8080/test.aac:gpac:hmode=push" "http-push"

wait

$DIFF $MEDIA_DIR/auxiliary_files/enst_audio.aac $TEMP_DIR/mydir/test.aac > /dev/null
rv=$?
if [ $rv != 0 ] ; then
  result="source and copied files differ"
fi

test_end
}

test_http_origin()
{
test_begin "http$TESTSUF-origin"
if [ $test_skip = 1 ] ; then
 return
fi
#make a 3sec input
$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac:dur=3.4 -new $TEMP_DIR/source.mp4 2> /dev/null
do_test "$GPAC -i $TEMP_DIR/source.mp4 reframer:rt=on @ -o http://127.0.0.1:8080/live.mpd:gpac:rdirs=$TEMP_DIR --sutc --cdur=0.1 --asto=0.9 --dmode=dynamic -logs=http@info -lu" "http-origin" &

#sleep to make sure the server is running, but not too long to make sure the client tunes on live edge at first set (otherwise hash will fail)
sleep 0.25

#inspect the first segment we get
myinspect=$TEMP_DIR/inspect.txt

do_test "$GPAC -i http://127.0.0.1:8080/live.mpd inspect:dur=1:allp:deep:test=network:interleave=false:log=$myinspect -logs=dash:http@debug:ncl -lu $opts" "dash-read"
do_hash_test $myinspect "inspect"

test_end
}


test_http_dashraw()
{
test_begin "http$TESTSUF-dashraw"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_audio.aac -o http://127.0.0.1:8080/file1.mpd:gpac:rdirs=$TEMP_DIR:muxtype=raw:sfile:profile=main" "http-origin"
do_hash_test $TEMP_DIR/file1.mpd "dash-sfile"

do_test "$GPAC -runfor=$HTTP_SERVER_RUNFOR httpout:port=8080:rdirs=$TEMP_DIR" "http-server" &

#sleep half a sec to make sure the server is up and running
sleep 0.5

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i http://127.0.0.1:8080/file1.mpd inspect:dur=2:allp:deep:test=network:interleave=false:log=$myinspect -logs=dash:http@debug -lu" "dash-read"
do_hash_test $myinspect "inspect"



do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_audio.aac -o http://127.0.0.1:8080/file2.mpd:gpac:rdirs=$TEMP_DIR:muxtype=raw" "http-origin"

do_hash_test $TEMP_DIR/file2.mpd "dash-tpl"

test_end
}


test_http_byteranges()
{
test_begin "http$TESTSUF-byteranges"
if [ $test_skip = 1 ] ; then
 return
fi
#make a 3sec dash
$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac:dur=3.0 -new $TEMP_DIR/source.mp4 2> /dev/null
$MP4BOX -dash 1000 -profile onDemand -out $TEMP_DIR/file.mpd $TEMP_DIR/source.mp4 2> /dev/null

do_test "$GPAC httpout:port=8080:rdirs=$TEMP_DIR -runfor=$HTTP_SERVER_RUNFOR -logs=dash:http@debug" "http-server" &
#sleep half a sec to make sure the server is up and running
sleep 0.5

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i http://127.0.0.1:8080/file.mpd inspect:allp:deep:test=network:interleave=false:log=$myinspect -logs=dash:http@debug -lu" "dash-read"
do_hash_test $myinspect "inspect"

test_end
}


test_http_dashpush_live()
{
test_begin "http$TESTSUF-dashpush$1"
if [ $test_skip = 1 ] ; then
 return
fi

$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -new $TEMP_DIR/source.mp4 2> /dev/null

do_test "$GPAC -runfor=$HTTP_SERVER_RUNFOR httpout:port=8080:wdir=$TEMP_DIR$4 --reqlog=PUT,DELETE" "http-server" &

#sleep half a sec to make sure the server is up and running
sleep .5

do_test "$MP4BOX -run-for 3000 -dash-live 1000 -subdur 1000 -profile live $TEMP_DIR/source.mp4 -out http://127.0.0.1:8080/live.$2:hmode=push$3 -logs=http@debug" "dash_push"

wait

if [ $5 = 1 ] ; then
do_hash_test $TEMP_DIR/source_dash3.m4s.1 "dash-seg3"
else
do_hash_test $TEMP_DIR/source_dash3.m4s "dash-seg3"
fi

if [ -f $TEMP_DIR/source_dash1.m4s ] ; then
 result="HTTP DELETE failed on segment 1"
fi

test_end
}


test_http_dash_llhls_no_ct()
{
test_begin "http$TESTSUF-dash-llhls-noct"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC -runfor=$HTTP_SERVER_RUNFOR -i $MEDIA_DIR/auxiliary_files/counter.hvc -o http://localhost:8080/live.m3u8:gpac:segdur=4:cdur=1:profile=live:dmode=dynamic:rdirs=$TEMP_DIR:llhls=sf:cte=0:tsb=1"

do_hash_test $TEMP_DIR/counter_dash3.m4s.1 "dash-seg3-part1"
do_hash_test $TEMP_DIR/counter_dash3.m4s "dash-seg3"
if [ -f $TEMP_DIR/counter_dash1.m4s ] ; then
 result="HTTP DELETE failed on segment 1"
fi

if [ -f $TEMP_DIR/counter_dash1.m4s.1 ] ; then
 result="HTTP DELETE failed on segment 1 part 1"
fi

test_end
}

test_http_dashpush_vod()
{
test_begin "http$TESTSUF-dashpush-vod"
if [ $test_skip = 1 ] ; then
 return
fi

$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac:dur=4 -new $TEMP_DIR/source.mp4 2> /dev/null

do_test "$GPAC  -runfor=$HTTP_SERVER_RUNFOR httpout:port=8080:wdir=$TEMP_DIR -logs=http@debug" "http-server" &
#sleep half a sec to make sure the server is up and running
sleep .5

#we are in test mode which triggers vodcache=insert (no sidx patching), force vodcache=false to test on the fly patching of sidx
do_test "$MP4BOX -dash 1000 -profile onDemand $TEMP_DIR/source.mp4 -out http://127.0.0.1:8080/live.mpd:hmode=push:vodcache=on -logs=http@debug" "dash_push"

wait

do_hash_test $TEMP_DIR/source_dashinit.mp4 "dash-vod"

test_end
}


test_https_server()
{
test_begin "http"$TESTSUF"s-server"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC httpout:port=8080:quit:rdirs=$MEDIA_DIR:cert=$MEDIA_DIR/tls/localhost.crt:pkey=$MEDIA_DIR/tls/localhost.key" "https-server" &
#sleep half a sec to make sure the server is up and running
sleep .5

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i https://127.0.0.1:8080/auxiliary_files/enst_audio.aac -broken-cert --cache=disk inspect:allp:deep:test=network:interleave=false:log=$myinspect$3 -graph -stats" "client-inspect"
do_hash_test $myinspect "inspect"
test_end

}



test_http_server_push_pull()
{
test_begin "http$TESTSUF-server-push-pull"
if [ $test_skip = 1 ] ; then
 return
fi

tmp_aac=$TEMP_DIR/test.mp4
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac:dur=2 -new $tmp_aac" "make-input"

do_test "$GPAC -runfor=$HTTP_SERVER_RUNFOR httpout:port=8080:rdirs=$TEMP_DIR:wdir=$TEMP_DIR:reqlog=*" "http-server" &
#sleep to make sure the server is up and running
sleep .5

do_test "$GPAC -i $tmp_aac reframer:rt=on @ -o http://127.0.0.1:8080/live.mpd:hmode=push:dmode=dynamic" "dash-push" &
#sleep to make sure the push origin is running, but not too long to make sure the client tunes on live edge at first set (otherwise hash will fail)
sleep .3

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i http://127.0.0.1:8080/live.mpd inspect:dur=1:allp:deep:test=network:interleave=false:log=$myinspect" "client-inspect"
do_hash_test $myinspect "inspect"
test_end

}


test_http_server_mem()
{
test_begin "http$TESTSUF-server-mem-$1"
if [ $test_skip = 1 ] ; then
 return
fi

tmp_aac=$TEMP_DIR/test.mp4
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac:dur=3 -new $tmp_aac" "make-input"

do_test "$GPAC -i $tmp_aac reframer:rt=on @ -o http://127.0.0.1:8080/live.$2:rdirs=gmem:dmode=dynamic$3" "dash-mem" &
#sleep to make sure the push origin is running, but not too long to make sure the client tunes on live edge at first set (otherwise hash will fail)
sleep .3

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i http://127.0.0.1:8080/live.$2 inspect:dur=2:allp:deep:test=network:interleave=false:log=$myinspect" "play"
do_hash_test $myinspect "play"
test_end

}



test_http_auth ()
{

test_begin "http$TESTSUF-auth$1"
if [ $test_skip  = 1 ] ; then
return
fi

echo "[$MEDIA_DIR/auxiliary_files]" > $TEMP_DIR/rules.txt
echo "ru=gpac" >> $TEMP_DIR/rules.txt

#do NOT use $GPAC since it may be passed with no config
MYGPAC="gpac -for-test -mem-track"

do_test "$MYGPAC -creds=-gpac" "reset-creds"
do_test "$MYGPAC -creds=_gpac:password=gpac" "set-creds"
#start http server
do_test "$MYGPAC -runfor=$HTTP_SERVER_RUNFOR httpout:port=8080:rdirs=$TEMP_DIR/rules.txt -logs=http@info" "http-server" &
sleep .5

myinspect=$TEMP_DIR/inspect.txt
src="http://$2"
src+="127.0.0.1:8080/counter.hvc"
do_test "$MYGPAC -i $src --cache=disk inspect:deep:allp:dur=1/1:log=$myinspect -stats -graph" "dump"

if [ -n "$2" ] ; then
do_hash_test $myinspect "dump"
fi

wait

test_end
}



do_tests()
{

#test server mode
test_http_server
#test server mode directory listing
test_http_server_dlist
#test server sink mode (icecast-like)
test_http_server_sink
#test push mode on write server
test_http_push
#test push mode on source server
test_http_source
#test low latency push
test_http_origin

#test ondemand dash served (for byte ranges)
test_http_byteranges

#test dash with raw format on http (for seg size messages)
test_http_dashraw

#test live dash output to http with PUT and DELETE
test_http_dashpush_live "" "mpd" "" "" 0
test_http_dashpush_live "-hls" "m3u8" "" "" 0
test_http_dashpush_live "-llhls" "m3u8" ":llhls=sf:cdur=0.5" "" 0

#test no chunk transfer only for http1
if [ $1 = 0 ] ; then
test_http_dashpush_live "-llhls-no-ct" "m3u8" ":llhls=sf:cdur=0.5:cte=0" "" 1
test_http_dash_llhls_no_ct
fi

#test live dash output to http with PUT and byte range update for SIDX
test_http_dashpush_vod

#test https server only for http1 and http2 (always on for H3)
if [ $1 != 2 ] ; then
test_https_server
fi

#test http server + push instance + client
test_http_server_push_pull

test_http_server_mem "dash" "mpd" ""
test_http_server_mem "hls" "m3u8" ""
test_http_server_mem "hls-ll-sf" "m3u8" ":llhls=sf:cdur=0.5"

#test dash push with blocking IO only for http1 and http2 (always on for H3)
if [ $1 != 2 ] ; then
test_http_dashpush_live "-blockio-c" "mpd" "" ":blockio" 0
test_http_dashpush_live "-blockio-s" "mpd" ":blockio" "" 0
test_http_dashpush_live "-blockio-cs" "mpd" ":blockio" ":blockio" 0
fi

#same tests as h1 and h2
if [ $1 != 2 ] ; then
test_http_auth "" "gpac:gpac@"
test_http_auth "-none" ""
fi

}


#check if we have H2/h3 support
has_h2=`$GPAC -h bin 2>/dev/null | grep HAS_HTTP2`
has_h3=`$GPAC -h bin 2>/dev/null | grep HAS_NGTCP2`

h_mode=""
h2_mode=""
h3_mode=""

if [ -n "$has_h2" ] ; then
h_mode="-no-h2"
fi

if [ -n "$has_h3" ] ; then
base_mode="$base_mode -h3=no"
h2_mode="-h3=no"
h3_mode="-h3=only"
fi


GPAC="$ORIG_GPAC $h_mode"
TESTSUF=""

do_tests 0

if [ -n "$has_h2" ] ; then
GPAC="$ORIG_GPAC $h2_mode"
TESTSUF="2"

do_tests 1

fi

if [ -n "$has_h3" ] ; then

MP4BOX="$ORIG_MP4BOX $h3_mode --cert=$MEDIA_DIR/tls/localhost.crt --pkey=$MEDIA_DIR/tls/localhost.key"
GPAC="$ORIG_GPAC $h3_mode --cert=$MEDIA_DIR/tls/localhost.crt --pkey=$MEDIA_DIR/tls/localhost.key"
TESTSUF="3"

do_tests 2

fi

GPAC="$ORIG_GPAC"
MP4BOX="$ORIG_MP4BOX"
