
test_vui()
{

name=$(basename $1)
name=${name%.*}
test_begin "mp4box-vui-$name"

if [ "$test_skip" = 1 ] ; then
return
fi

mp4file="$TEMP_DIR/fullrange_on.mp4"
do_test "$MP4BOX -add $1:fullrange=on -new $mp4file" "add-fr-on"
do_hash_test $mp4file "add-fr-on"

mp4file="$TEMP_DIR/fullrange_off.mp4"
do_test "$MP4BOX -add $1:fullrange=off -new $mp4file" "add-fr-off"
do_hash_test $mp4file "add-fr-off"

mp4file="$TEMP_DIR/par_16_9.mp4"
do_test "$MP4BOX -add $1:par=w16:9 -new $mp4file" "set-sar"
do_hash_test $mp4file "set-sar"

test_end
}

test_vui $MEDIA_DIR/auxiliary_files/enst_video.h264
test_vui $MEDIA_DIR/auxiliary_files/counter.hvc
test_vui $EXTERNAL_MEDIA_DIR/counter/counter_30s_1280x720p_I25_closedGOP_512kpbs.vvc



