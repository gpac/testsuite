#!/bin/sh

#note: the port used is 8080 since the testbot on linux will not allow 80

test_http_server()
{
test_begin "http-server"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC httpout:port=8080:quit:rdirs=$MEDIA_DIR" "http-server" &
sleep .1

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i http://localhost:8080/auxiliary_files/enst_audio.aac inspect:allp:deep:test=network:interleave=false:log=$myinspect$3 -graph -stats" "client-inspect"
do_hash_test $myinspect "inspect"
test_end

}


test_http_server_dlist()
{
test_begin "http-server-dlist"
if [ $test_skip = 1 ] ; then
 return
fi

touch $TEMP_DIR/file.txt
mkdir $TEMP_DIR/mydir
touch $TEMP_DIR/mydir/other.txt

do_test "$GPAC httpout:port=8080:quit:dlist:rdirs=$TEMP_DIR" "http-server-dlist" &
sleep .1

do_test "$MP4BOX -wget http://localhost:8080/ $TEMP_DIR/listing.txt" "mp4box-get"
found=`grep file.txt $TEMP_DIR/listing.txt`
if [ "$found" = "" ] ; then
	result="listing failed"
fi
found=`grep mydir $TEMP_DIR/listing.txt`
if [ "$found" = "" ] ; then
	result="listing failed"
fi

do_test "$GPAC httpout:port=8080:quit:dlist:rdirs=$TEMP_DIR" "http-server-dlist" &
sleep .1

do_test "$MP4BOX -wget http://localhost:8080/mydir/ $TEMP_DIR/listing2.txt" "mp4box-get2"
found=`grep other.txt $TEMP_DIR/listing2.txt`
if [ "$found" = "" ] ; then
	result="listing2 failed"
fi

test_end
}


test_http_server_sink()
{
test_begin "http-server-sink"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_audio.aac -o http://localhost:8080/live.aac:gpac:hold" "http-sink" &
sleep .1

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i http://localhost:8080/live.aac inspect:allp:deep:test=network:interleave=false:log=$myinspect$3 -logs=http@debug" "client-inspect"
do_hash_test $myinspect "inspect"

test_end
}




test_http_push()
{
test_begin "http-push"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC httpout:port=8080:quit:wdir=$TEMP_DIR" "http-server-rec" &
sleep .1

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_audio.aac -o http://localhost:8080/mydir/test.aac:gpac:hmode=push" "http-push"

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
test_begin "http-source"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC httpout:port=8080:quit:hmode=source -o $TEMP_DIR/mydir/test.aac" "http-source" &
sleep .1

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_audio.aac -o http://localhost:8080/test.aac:gpac:hmode=push" "http-push"

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
test_begin "http-origin"
if [ $test_skip = 1 ] ; then
 return
fi
#make a 3sec
$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac:dur=3.4 -new $TEMP_DIR/source.mp4 2> /dev/null
do_test "$GPAC -i $TEMP_DIR/source.mp4 reframer:rt=on @ -o http://localhost:8080/live.mpd:gpac:rdirs=$TEMP_DIR --cdur=0.1 --asto=0.9 --dmode=dynamic -logs=http@debug -lu" "http-origin" &
sleep 0.01

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i http://localhost:8080/live.mpd inspect:dur=2:allp:deep:test=network:interleave=false:log=$myinspect -logs=dash:http@debug -lu" "dash-read"
do_hash_test $myinspect "inspect"

test_end
}


test_http_dashraw()
{
test_begin "http-dashraw"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_audio.aac -o http://localhost:8080/file1.mpd:gpac:rdirs=$TEMP_DIR:muxtype=raw:sfile:profile=main" "http-origin"
do_hash_test $TEMP_DIR/file1.mpd "dash-sfile"

do_test "$GPAC -runfor=3 httpout:port=8080:rdirs=$TEMP_DIR" "http-server" &
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i http://localhost:8080/file1.mpd inspect:dur=2:allp:deep:test=network:interleave=false:log=$myinspect -logs=dash:http@debug -lu" "dash-read"
do_hash_test $myinspect "inspect"



do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_audio.aac -o http://localhost:8080/file2.mpd:gpac:rdirs=$TEMP_DIR:muxtype=raw" "http-origin"

do_hash_test $TEMP_DIR/file2.mpd "dash-tpl"

test_end
}

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

#test dash with raw format on http (for seg size messages)
test_http_dashraw