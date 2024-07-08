
test_inspect()
{
 name=$(basename $1)
 name=${name%.*}
 test_begin "inspect-$name$4"

if [ "$test_skip" = 1 ] ; then
 return
fi

inspect="$TEMP_DIR/inspect.xml"

do_test "$GPAC -i $1 inspect:deep:log=$inspect:analyze=on$2" "inspect"
do_hash_test $inspect "inspect"

if [ $3 != 0 ] ; then

inspect="$TEMP_DIR/inspect_bs.xml"
do_test "$GPAC -i $1 inspect:deep:log=$inspect:analyze=full$2" "inspect-bs"
do_hash_test $inspect "inspect-bs"
fi

mp4file=$TEMP_DIR/file.mp4
if [ $3 = 2 ] ; then
$MP4BOX -add $1 -new $mp4file 2> /dev/null
inspect="$TEMP_DIR/inspect_bs_mp4.xml"
do_test "$GPAC -i $mp4file inspect:deep:log=$inspect:analyze=full$2" "inspect-bs-mp4"
do_hash_test $inspect "inspect-bs-mp4"
else
$GPAC -i $1 -o $mp4file 2> /dev/null
fi

inspect="$TEMP_DIR/inspect_unframe.txt"
do_test "$GPAC -i $mp4file @$2 unframer @ inspect:deep:log=$inspect" "inspect-unframer"
do_hash_test $inspect "inspect-unframer"


test_end

}

test_inspect $MEDIA_DIR/auxiliary_files/count_video.cmp "" 0
test_inspect $MEDIA_DIR/auxiliary_files/count_english.mp3 "" 0
test_inspect $MEDIA_DIR/auxiliary_files/enst_video.h264 "" 2
test_inspect $MEDIA_DIR/auxiliary_files/enst_audio.aac "" 1
test_inspect $MEDIA_DIR/auxiliary_files/counter.hvc:refs "" 2
test_inspect $MEDIA_DIR/auxiliary_files/video.av1 "" 1
test_inspect $EXTERNAL_MEDIA_DIR/qt_prores/prores422.mov ":SID=#PID=11" 0
test_inspect $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.ac3 "" 1
test_inspect $MEDIA_DIR/auxiliary_files/enstvid.ivf "" 1
test_inspect $EXTERNAL_MEDIA_DIR/counter/counter_30s_1280x720p_I25_closedGOP_512kpbs.vvc:refs "" 2
test_inspect $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.mhas "" 2 "-mha"
test_inspect $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.mhas:mpha "" 1 "-mpha"
test_inspect $EXTERNAL_MEDIA_DIR/import/counter_english.mlp "" 0
test_inspect $EXTERNAL_MEDIA_DIR/import/dead.m1v "" 0
test_inspect $MEDIA_DIR/ttml/ebu-ttd_sample.ttml "" 1


test_begin "inspect-info"
if [ "$test_skip" != 1 ] ; then
inspect="$TEMP_DIR/inspect.txt"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/count_video.cmp inspect:deep:log=$inspect:info" "inspect"
do_hash_test $inspect "inspect"

fi
test_end


test_begin "inspect-fmt"
if [ "$test_skip" != 1 ] ; then
inspect="$TEMP_DIR/inspect.txt"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264 inspect:deep:log=$inspect:fmt=%ddts%%t%%dcts%%t%%ctso%%t%%frame%%t%%lp%%t%%depo%%t%%depf%%t%%red%%t%%ck%%t%%pcr%%t%%pid.ID%%t%%StreamType%%t%%data%%lf%" "inspect"
do_hash_test $inspect "inspect"

fi
test_end


test_begin "inspect-bsdbg"
if [ "$test_skip" != 1 ] ; then
inspect="$TEMP_DIR/inspect.txt"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264:bsdbg=full -logs=media@debug inspect:deep:full:analyze=on:log=$inspect" "inspect"
do_hash_test $inspect "inspect"

inspect="$TEMP_DIR/inspect_av1.txt"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/video.av1:bsdbg=full -logs=media@debug inspect:deep:full:analyze=on:log=$inspect" "inspect"
do_hash_test $inspect "inspect"

fi
test_end

