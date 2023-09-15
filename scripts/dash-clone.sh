#!/bin/sh

test_dash_clone()
{
test_begin "dash-clone"
if [ $test_skip  = 1 ] ; then
return
fi

#test dasher output cloning to 2 subdirs
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc dasher:cmfc:cdur=0.5 -o $TEMP_DIR/dash1/live.mpd  -o $TEMP_DIR/dash2/live.mpd" "dash-clone"
do_hash_test "$TEMP_DIR/dash1/live.mpd" "mpd1"
do_hash_test "$TEMP_DIR/dash2/live.mpd" "mpd2"

$DIFF $TEMP_DIR/dash1/counter_dash1.m4s $TEMP_DIR/dash2/counter_dash1.m4s > /dev/null
rv=$?
if [ $rv != 0 ] ; then
  result="cloned files differ"
fi


#same test with route clone - use 2s only and dynauto mode to force moving to static MPD at end (for hash)
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc  reframer:xs=0:xe=2 dasher:cmfc:cdur=0.5:dynauto -o $TEMP_DIR/dash3/live.mpd  -o route://234.0.0.1:1234/live.mpd" "route-clone"
do_hash_test "$TEMP_DIR/dash3/live.mpd" "mpd-route"

#same test with HLS and http clone
rm -rf $TEMP_DIR/hls2 2> /dev/null
mkdir $TEMP_DIR/hls2
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc dasher:cmfc:cdur=0.5:mname=m3u8 -o $TEMP_DIR/hls1/live.m3u8  -o http://127.0.0.1:8080/live.m3u8:rdirs=$TEMP_DIR/hls2" "hls-clone"
do_hash_test "$TEMP_DIR/hls1/live.m3u8" "hls1"

$DIFF $TEMP_DIR/hls1/live_1.m3u8 $TEMP_DIR/hls2/live_1.m3u8 > /dev/null
rv=$?
if [ $rv != 0 ] ; then
  result="cloned files differ"
fi

$DIFF $TEMP_DIR/hls1/counter_dash1.m4s $TEMP_DIR/hls2/counter_dash1.m4s > /dev/null
rv=$?
if [ $rv != 0 ] ; then
  result="cloned files differ"
fi


#same test with HLS in raw mode
rm -rf $TEMP_DIR/hls2 2> /dev/null
mkdir $TEMP_DIR/hls2
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc dasher:cmfc:cdur=0.5:mname=m3u8:muxtype=raw -o $TEMP_DIR/hls3/live.m3u8 -o $TEMP_DIR/hls4/live.m3u8" "raw-clone"
do_hash_test "$TEMP_DIR/hls3/live_1.m3u8" "raw1"

$DIFF $TEMP_DIR/hls3/live_1.m3u8 $TEMP_DIR/hls4/live_1.m3u8 > /dev/null
rv=$?
if [ $rv != 0 ] ; then
  result="cloned files differ"
fi



test_end
}

test_dash_clone
