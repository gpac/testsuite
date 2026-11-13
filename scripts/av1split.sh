
#test av1split and av1merge filters, simplified from hevcmerge and hevcsplit test

test_begin "av1-split-merge"
if [ $test_skip = 1 ] ; then
return
fi
#extract 720p tiled high quality source
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_1280_720_I_25_tiled_512k.obu  av1split -o $TEMP_DIR/high_\$CropOrigin\$.mp4" "split-qp20"
#extract 720p tiled low quality source
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_1280_720_I_25_tiled_128k.obu  av1split -o $TEMP_DIR/low_\$CropOrigin\$.mp4" "split-qp35"

#hash all our results
for i in $TEMP_DIR/*.mp4 ; do

name=$(basename $i)
name=${name%.*}
#name=${name#dump_*}

do_hash_test "$i" "$name"
do_play_test "play" "$i -blacklist=nvdec,vtbdec" ""

done

#merge a few tiles with absolute coords
do_test "$GPAC -i $TEMP_DIR/high_640x0.mp4:#CropOrigin=0x0 -i $TEMP_DIR/low_960x0.mp4:#CropOrigin=320x0 av1merge @ -o $TEMP_DIR/merge2.mp4" "merge-abspos"
do_hash_test "$TEMP_DIR/merge2.mp4" "merge-abspos"

#merge a few tiles with relative coords
do_test "$GPAC -i $TEMP_DIR/high_640x0.mp4:#CropOrigin=-1x0 -i $TEMP_DIR/low_960x0.mp4:#CropOrigin=0x0 av1merge @ -o $TEMP_DIR/merge3.mp4" "merge-relpos"
do_hash_test "$TEMP_DIR/merge3.mp4" "merge-relpos"

#merge all tiles from high
cropOrigins="0x0 0x384 320x0 320x384 640x0 640x384 960x0 960x384"

testarg="$GPAC " #the last character should be a space"
#simultaneous iteration over cropOrigins with $1, and SRDs with $j
for j in $cropOrigins; do
  testarg+="-i $TEMP_DIR/high_$j.mp4:#CropOrigin=$j " #the last character should be a space"
done

testarg1="$testarg av1merge @ -o $TEMP_DIR/merge_all_high.mp4 -graph"
do_test "$testarg1" "merge-all-high"
do_hash_test "$TEMP_DIR/merge_all_high.mp4" "merge-all-high"

test_end

