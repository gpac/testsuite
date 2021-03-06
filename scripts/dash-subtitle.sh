#!/bin/sh

test_begin "dash-subt"
if [ $test_skip  = 1 ] ; then
return
fi

do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/subtitle.srt -new $TEMP_DIR/file.mp4" "dash-input-preparation"

do_test "$MP4BOX -dash 1500 $TEMP_DIR/file.mp4 -profile live -out $TEMP_DIR/file.mpd" "dash-subt"

do_hash_test $TEMP_DIR/file.mpd "dash-subt-hash-mpd"
do_hash_test $TEMP_DIR/file_dash3.m4s "dash-seg3"

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:deep:interleave=false:log=$myinspect" "inspect"
do_hash_test $myinspect "inspect"

#do another test with smaller segment duration, to exercice spliting of samples over 3 or more segments
cp $TEMP_DIR/file.mp4 $TEMP_DIR/file2.mp4
do_test "$MP4BOX -dash 500 $TEMP_DIR/file2.mp4 -profile live -out $TEMP_DIR/file2.mpd" "dash-subt2"

do_hash_test $TEMP_DIR/file.mpd "dash-subt2-hash-mpd"
do_hash_test $TEMP_DIR/file2_dash10.m4s "dash-seg10"


test_end
