#!/bin/sh

#checks for dasher keep_segs option: segments and periods falling out of the timeshift buffer shall be kept on disk
#but no longer advertised in DASH/HLS manifests - cf gpac/gpac#4004

test_begin "dash-keep-segs"

if [ $test_skip  = 0 ] ; then

$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264:dur=5 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:dur=5 -new $TEMP_DIR/p1.mp4 2> /dev/null
$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264:dur=15 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:dur=15 -new $TEMP_DIR/p2.mp4 2> /dev/null

#two periods on the same PIDs (period switch through flist props) so that HLS playlists are continuous across periods
echo "#props=#Period=P1" > $TEMP_DIR/playlist.m3u
echo "p1.mp4" >> $TEMP_DIR/playlist.m3u
echo "#props=#Period=P2" >> $TEMP_DIR/playlist.m3u
echo "p2.mp4" >> $TEMP_DIR/playlist.m3u

#live profile with 2s timeshift and keep_segs: the first period fully expires while the second one is generated
#the final manifests shall only advertise the last segments of P2 (dynamic MPD is not hashed, it contains wall-clock dates)
do_test "$GPAC -i $TEMP_DIR/playlist.m3u -o $TEMP_DIR/live.mpd:dual:segdur=1:dmode=dynamic:tsb=2:keep_segs:stl" "dash"

do_hash_test $TEMP_DIR/live.m3u8 "hls-master"
do_hash_test $TEMP_DIR/live_1.m3u8 "hls-var1"
do_hash_test $TEMP_DIR/live_2.m3u8 "hls-var2"

#we cannot hash the dynamic MPD (wall-clock availabilityStartTime/publishTime), check the expired period is no longer advertised
nb_periods=`grep -c "<Period" $TEMP_DIR/live.mpd`
if [ "$nb_periods" != "1" ] ; then
	result="expired period still advertised in dynamic MPD"
fi

#expired segments shall still be present on disk
do_hash_test $TEMP_DIR/p1_dash_track1_0.m4s "p1-first-seg"

#same session but moving to static at end of stream: the final manifests shall advertise the complete history (both periods, all segments)
do_test "$GPAC -i $TEMP_DIR/playlist.m3u -o $TEMP_DIR/vod.mpd:dual:segdur=1:dmode=dynauto:tsb=2:keep_segs:stl" "dash-tostatic"

do_hash_test $TEMP_DIR/vod.mpd "static-mpd"
do_hash_test $TEMP_DIR/vod.m3u8 "static-hls-master"
do_hash_test $TEMP_DIR/vod_1.m3u8 "static-hls-var1"
do_hash_test $TEMP_DIR/vod_2.m3u8 "static-hls-var2"

fi

test_end
