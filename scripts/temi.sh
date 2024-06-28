temi_pip_test ()
{

test_begin "temi-pip"
if [ $test_skip  = 1 ] ; then
return
fi

tsfile="$TEMP_DIR/test.ts"
mp4file="$TEMP_DIR/test.mp4"
pipfile="$TEMP_DIR/pip.mp4"
$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_main_1280x720_512kbps.264:dur=2 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:dur=2 -new $mp4file 2> /dev/null
$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_main_640x360_192kbps.264:dur=2 -new $pipfile 2> /dev/null

do_test "$GPAC -i $mp4file -o $tsfile:pcr_init=0:pes_pack=none:temi=#PV#$pipfile" "mux"
if [ $keep_temp_dir != 1 ] ; then
insp="$TEMP_DIR/inspect.txt"
do_test "$GPAC -i $tsfile  inspect:deep:interleave=false:log=$insp" "mux-inspect"
do_hash_test $insp "mux-inspect"
fi

do_test "$GPAC -blacklist=vtbdec,nvdec -i $tsfile compositor:fps=25:dur=1 @ -o $TEMP_DIR/dump.rgb @1 -o $TEMP_DIR/dump.pcm" "rip"
#we don't hash, due to load on test machine the first frame of the addon may come in at different time in tha base timeline -> different results
#do_hash_test $TEMP_DIR/dump.rgb "rip"

test_end
}


temi_pip_test


temi_scal_test ()
{

test_begin "temi-scal"
if [ $test_skip  = 1 ] ; then
return
fi

mp4file="$TEMP_DIR/dual.mp4"
base="$TEMP_DIR/base.mp4"
enh="$TEMP_DIR/enh.mp4"
tsfile="$TEMP_DIR/temi.ts"

do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/scalable/shvc.265:dur=10:svcmode=split:noedit -new $mp4file" "mksrc"

$MP4BOX -rem 2 $mp4file -out $base 2> /dev/null
$MP4BOX -rem 1 $mp4file -out $enh 2> /dev/null

do_test "$GPAC -i $base -o $tsfile:pcr_init=0:pes_pack=none:temi=#PV#$enh" "mux"

if [ $keep_temp_dir != 1 ] ; then
insp="$TEMP_DIR/inspect.txt"
do_test "$GPAC -i $tsfile  inspect:deep:interleave=false:log=$insp" "mux-inspect"
do_hash_test $insp "mux-inspect"
fi

insp=$TEMP_DIR/inspect.txt
#dump 3 seconds, should be enough for tune time of scalable addon
do_test "$GPAC -blacklist=vtbdec,nvdec compositor:fps=25:dur=3:src=$tsfile @ inspect:interleave=false:deep:log=$insp -graph" "inspect"
#do_hash_test $TEMP_DIR/dump.rgb "rip"
has_4k=`grep 3840 $insp`
if [ -z "$has_4k" ] ; then
result="switch failed"
fi


test_end
}


temi_scal_test
