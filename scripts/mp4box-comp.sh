

test_comp()
{
test_begin "mp4box-comp"
if [ "$test_skip" = 1 ] ; then
return
fi

mp4file="$TEMP_DIR/base.mp4"
compfile="$TEMP_DIR/comp.mp4"
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264:dur=10 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:dur=10 -new -frag 1000 $mp4file" "add"

do_hash_test $mp4file "add"

do_test "$MP4BOX -comp moof=cmof $mp4file -out $compfile" "comp"
#zlib result not reliable across platforms/versions, commenting hash
#do_hash_test $compfile "comp"

do_test "$MP4BOX -topsize moof $mp4file" "comp"

mp4file="$TEMP_DIR/zmov.mp4"
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264:dur=10 -new -zmov $mp4file" "zmov"
#zlib result not reliable across platforms/versions, commenting hash
#do_hash_test $mp4file "zmov"
do_test "$MP4BOX -diso $mp4file" "zmov-diso"
do_hash_test "$TEMP_DIR/zmov_info.xml" "zmov-diso"

mp4file="$TEMP_DIR/xmov.mp4"
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264:dur=10 -new -xmov $mp4file" "xmov"
#zlib result not reliable across platforms/versions, commenting hash
#do_hash_test $mp4file "xmov"
do_test "$MP4BOX -diso $mp4file" "xmov-diso"
do_hash_test "$TEMP_DIR/xmov_info.xml" "xmov-diso"

mp4file="$TEMP_DIR/zmovqt.mov"
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264:dur=10 -new -zmov $mp4file" "zmovqt"
#zlib result not reliable across platforms/versions, commenting hash
#do_hash_test $mp4file "zmov"
do_test "$MP4BOX -diso $mp4file" "zmovqt-diso"
do_hash_test "$TEMP_DIR/zmovqt_info.xml" "zmovqt-diso"


test_end
}

test_comp


