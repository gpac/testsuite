#!/bin/sh

test_flist()
{

test_begin "filelist-$1"

if [ $test_skip  = 1 ] ; then
return
fi

myinspect=$TEMP_DIR/inspect.txt

if [ $3 = 4 ] ; then

do_test "$GPAC $2 inspect:allp:deep:interleave=false:log=$myinspect:fmt=%pn%-%dts%-%cts%-%rap%-%size%%lf% -graph -stats -logs=app@debug" "inspect"
do_hash_test $myinspect "inspect"

else

do_test "$GPAC $2 inspect:allp:deep:interleave=false:log=$myinspect -graph -stats -logs=app@debug" "inspect"
do_hash_test $myinspect "inspect"

fi

if [ $3 = 1 ] ; then
dump=$TEMP_DIR/dump.rgb
do_test "$GPAC -no-reassign=0 $2 ffsws:osize=192x192:ofmt=rgb @ -o $dump -blacklist=nvdec,vtbdec" "dump"
do_hash_test $dump "dump"

do_play_test "dump" "$dump:size=192x192"

fi

if [ $3 = 2 ] ; then
dump=$TEMP_DIR/dump.mp4
do_test "$GPAC $2 -o $dump" "isom-dump"
do_hash_test $dump "isom-dump"

do_play_test "dump" "$dump"

fi

if [ $3 = 3 ] ; then
dump=$TEMP_DIR/dump.mpd
do_test "$GPAC $2 -o $dump -logs=dash@info" "dash-dump"
do_hash_test $dump "dash-dump"

do_play_test "dump" "$dump"

fi

test_end

}

test_flist "codecs" "flist:fdur=1/1:srcs=$MEDIA_DIR/auxiliary_files/logo.jpg,$MEDIA_DIR/auxiliary_files/logo.png" 0

#generate plist in current dir not in temp, since we put relative path in playlist
plist=pl_swap.m3u

echo "" > $plist
#check decoder swapping (flist->png->ffsws to flist->m4v->ffsws)
echo "$MEDIA_DIR/auxiliary_files/logo.png" >> $plist
echo "$MEDIA_DIR/auxiliary_files/count_video.cmp" >> $plist
#check decoder removal (flist->m4v->ffsws to flist->ffsws)
echo "$EXTERNAL_MEDIA_DIR/raw/raw.rgb:size=128x128" >> $plist
#check decoder insertion (flist->ffsws to flist->jpg->ffsws), with repeat of frame
echo "$MEDIA_DIR/auxiliary_files/sky.jpg" >> $plist

test_flist "filter-swap" "-i $plist" 1
mv $plist $TEMP_DIR


plist=pl_params.m3u
echo "" > $plist
#check decoder swapping (flist->png->ffsws to flist->m4v->ffsws)
echo "#repeat=24" >> $plist
echo "$MEDIA_DIR/auxiliary_files/logo.jpg" >> $plist

test_flist "params" "-i $plist:fdur=1/1" 0
mv $plist $TEMP_DIR

test_flist "enum" "flist:srcs=$MEDIA_DIR/auxiliary_files/\*.jpg:fsort=name" 0



plist=pl_filters.m3u
echo "" > $plist
echo "$MEDIA_DIR/auxiliary_files/enst_video.h264 @ reframer:saps=1" >> $plist

test_flist "filters" "-i $plist" 0
mv $plist $TEMP_DIR


plist=pl_filters-dual.m3u
echo "" > $plist
echo "$MEDIA_DIR/auxiliary_files/enst_video.h264 @ reframer:saps=1 @-1" >> $plist

test_flist "filters-dual" "-i $plist" 0
mv $plist $TEMP_DIR


plist=pl_splice.m3u

echo "#out=4 in=7" > $plist
echo "$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 && $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac" >> $plist
echo "$MEDIA_DIR/auxiliary_files/enst_video.h264 && $MEDIA_DIR/auxiliary_files/enst_audio.aac" >> $plist

test_flist "splice" "-i $plist" 2
mv $plist $TEMP_DIR


plist=pl_splice_keep.m3u

echo "#out=4 in=+4 keep props=#Period=Main" > $plist
echo "$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 && $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac" >> $plist
echo "#props=#Period=Splice:#Language=fr-FR" >> $plist
echo "$MEDIA_DIR/auxiliary_files/enst_video.h264 && $MEDIA_DIR/auxiliary_files/enst_audio.aac" >> $plist

test_flist "splice-keep" "-i $plist" 3
mv $plist $TEMP_DIR


plist=pl_splice_mark.m3u

echo "#out=4 in=7 mark props=#Period=main sprops=#xlink=http://foo.bar/" > $plist
echo "$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 && $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac" >> $plist

test_flist "splice-mark" "-i $plist" 3
mv $plist $TEMP_DIR


plist=pl_start.m3u

echo "#start=4" > $plist
echo "$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 && $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac" >> $plist

test_flist "start" "-i $plist" 0
mv $plist $TEMP_DIR

plist=pl_splice_start.m3u

echo "#out=8 in=12 start=4" > $plist
echo "$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 && $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac" >> $plist
echo "$MEDIA_DIR/auxiliary_files/enst_video.h264 && $MEDIA_DIR/auxiliary_files/enst_audio.aac" >> $plist

test_flist "splice-start" "-i $plist" 2
mv $plist $TEMP_DIR


#Raw audio tests, only do inspect on timing, no crc nor decoded payload hases

#raw audio, same config
plist=pl_splice_ra.m3u
echo "#raw out=2 in=4" > $plist
echo "$MEDIA_DIR/auxiliary_files/enst_audio.aac" >> $plist
echo "$MEDIA_DIR/auxiliary_files/enst_audio.aac" >> $plist

test_flist "splice-raw" "-i $plist" 4
mv $plist $TEMP_DIR

#raw audio, same config, mark only
plist=pl_splice_ra_mark.m3u
echo "#raw out=2 in=4 mark" > $plist
echo "$MEDIA_DIR/auxiliary_files/enst_audio.aac" >> $plist

test_flist "splice-raw-mark" "-i $plist" 4
mv $plist $TEMP_DIR

#raw audio, same config, keep
plist=pl_splice_ra_keep.m3u
echo "#raw out=2 in=4 keep" > $plist
echo "$MEDIA_DIR/auxiliary_files/enst_audio.aac" >> $plist
echo "$MEDIA_DIR/auxiliary_files/enst_audio.aac" >> $plist

test_flist "splice-raw-keep" "-i $plist" 4
mv $plist $TEMP_DIR




#raw audio, 2 configs
plist=pl_splice_ra_2sr.m3u
echo "#raw out=2 in=4" > $plist
echo "$MEDIA_DIR/auxiliary_files/enst_audio.aac" >> $plist
echo "$MEDIA_DIR/auxiliary_files/count_english.mp3" >> $plist

test_flist "splice-raw-2sr" "-i $plist" 4
mv $plist $TEMP_DIR

#raw audio, 2 config, keep
plist=pl_splice_ra_2sr_keep.m3u
echo "#raw out=2 in=4 keep" > $plist
echo "$MEDIA_DIR/auxiliary_files/enst_audio.aac" >> $plist
echo "$MEDIA_DIR/auxiliary_files/count_english.mp3" >> $plist

test_flist "splice-raw-2sr-keep" "-i $plist" 4
mv $plist $TEMP_DIR


plist=pl_error.m3u
echo "http://gpac.io/dummy" >> $plist

single_test "$GPAC -i $plist inspect" "filelist-load-error"
mv $plist $TEMP_DIR


plist=pl_loop.m3u
echo "" > $plist
echo "$MEDIA_DIR/auxiliary_files/enst_video.h264" >> $plist

test_flist "loop" "--floop=1 -i $plist" 0
mv $plist $TEMP_DIR
