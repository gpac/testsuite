#!/bin/sh

test_begin "dash-gen-manifest"
if [ $test_skip != 1 ] ; then

do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_640x360_192kbps.264 -new $TEMP_DIR/source.mp4" "import"

do_test "$MP4BOX -dash 2000 -profile onDemand $TEMP_DIR/source.mp4 -out $TEMP_DIR/test.mpd" "dash"

do_test "$GPAC -i $TEMP_DIR/source_dashinit.mp4 -o $TEMP_DIR/gen-vod.mpd:sigfrag:profile=onDemand" "gen-ondemand"
do_hash_test "$TEMP_DIR/gen-vod.mpd" "gen-ondemand"

do_test "$GPAC -i $TEMP_DIR/source_dashinit.mp4 -o $TEMP_DIR/gen-main.mpd:sigfrag:profile=main" "gen-main"
do_hash_test "$TEMP_DIR/gen-main.mpd" "gen-main"

do_test "$GPAC -i $TEMP_DIR/source_dashinit.mp4 -o $TEMP_DIR/gen-hls.m3u8:sigfrag" "gen-hls"
do_hash_test "$TEMP_DIR/gen-hls.m3u8" "gen-hls-master"
do_hash_test "$TEMP_DIR/gen-hls_1.m3u8" "gen-hls-subpl"

fi
test_end

test_begin "dash-gen-manifest-live"
if [ $test_skip != 1 ] ; then

do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_640x360_192kbps.264 -new $TEMP_DIR/source.mp4" "import"

do_test "$MP4BOX -dash 2000 -profile live $TEMP_DIR/source.mp4 -out $TEMP_DIR/test.mpd" "dash"

plist=$TEMP_DIR/input.txt
echo "source_dashinit.mp4:sigfrag" > $plist
echo "source_dash1.m4s" >> $plist
echo "source_dash2.m4s" >> $plist
echo "source_dash3.m4s" >> $plist
echo "source_dash4.m4s" >> $plist
echo "source_dash5.m4s" >> $plist
echo "source_dash6.m4s" >> $plist
echo "source_dash7.m4s" >> $plist
echo "source_dash8.m4s" >> $plist
echo "source_dash9.m4s" >> $plist

do_test "$GPAC -i $plist -o $TEMP_DIR/gen-main.mpd:sigfrag" "gen-main"
do_hash_test "$TEMP_DIR/gen-main.mpd" "gen-main"

do_test "$GPAC -i $plist -o $TEMP_DIR/gen-live.mpd:sigfrag:profile=live:template=\$XInit=source_dashinit\$source_dash\$Number\$" "gen-live"
do_hash_test "$TEMP_DIR/gen-live.mpd" "gen-live"

do_test "$GPAC -i $plist -o $TEMP_DIR/gen-hls.m3u8:sigfrag" "gen-hls"
do_hash_test "$TEMP_DIR/gen-hls.m3u8" "gen-hls-master"
do_hash_test "$TEMP_DIR/gen-hls_1.m3u8" "gen-hls-subpl"

fi
test_end

