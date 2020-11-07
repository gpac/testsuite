
#test hevcsplit and hevcmerge filters

test_begin "hevc-split-merge"
if [ $test_skip = 1 ] ; then
return
fi
#extract 720p tiled source
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_1280_720_I_25_tiled_qp20.hevc  hevcsplit:FID=1 -o $TEMP_DIR/high_\$CropOrigin\$.hvc:SID=1#CropOrigin=*" "split-qp20"
#extract 360p tiled source
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_640_360_I_25_tiled_qp30.hevc  hevcsplit:FID=1 -o $TEMP_DIR/low_\$CropOrigin\$.hvc:SID=1#CropOrigin=*" "split-qp30"

#hash all our results
for i in $TEMP_DIR/*.hvc ; do

name=$(basename $i)
name=${name%.*}
#name=${name#dump_*}

do_hash_test "$i" "$name"
do_play_test "play" "$i -blacklist=nvdec,vtbdec" ""

done

#commenting the following tests, as the result is scheduling dependent: no positionning of tiles is given, the grid will select the first column on the first declared pid
#which may be low or high res ...
#
##merge a shuffled tiles combination
#do_test "$GPAC -i $TEMP_DIR/high_0x0.hvc -i $TEMP_DIR/low_0x0.hvc -i $TEMP_DIR/high_832x0.hvc -i $TEMP_DIR/low_384x0.hvc -i $TEMP_DIR/high_384x256.hvc -i $TEMP_DIR/low_192x128.hvc hevcmerge @ -o $TEMP_DIR/merge0.hvc" "merge-6shuffledtiles"
#do_hash_test "$TEMP_DIR/merge0.hvc" "merge-6shuffledtiles"
#
##merge a few tiles
#do_test "$GPAC -i $TEMP_DIR/high_0x256.hvc -i $TEMP_DIR/high_832x512.hvc  -i $TEMP_DIR/low_0x256.hvc -i $TEMP_DIR/low_384x0.hvc hevcmerge @ -o $TEMP_DIR/merge1.hvc" "merge-4tiles"
#do_hash_test "$TEMP_DIR/merge1.hvc" "merge-4tiles"

#merge a few tiles with absolute coords
do_test "$GPAC -i $TEMP_DIR/high_832x512.hvc:#CropOrigin=192x256 -i $TEMP_DIR/low_192x128.hvc:#CropOrigin=0x0 hevcmerge @ -o $TEMP_DIR/merge2.hvc" "merge-abspos"
do_hash_test "$TEMP_DIR/merge2.hvc" "merge-abspos"

#merge a few tiles with relative coords
do_test "$GPAC -i $TEMP_DIR/high_832x512.hvc:#CropOrigin=-1x0 -i $TEMP_DIR/low_192x128.hvc:#CropOrigin=0x0 hevcmerge @ -o $TEMP_DIR/merge3.hvc" "merge-relpos"
do_hash_test "$TEMP_DIR/merge3.hvc" "merge-relpos"

#merge a few tiles with SRD features
myinspect=$TEMP_DIR/inspect_3tiles.txt
do_test "$GPAC -i $TEMP_DIR/low_0x0.hvc:#CropOrigin=0x0:#SRDRef=640x360:#SRD=0x0x192x128 -i $TEMP_DIR/low_192x128.hvc:#CropOrigin=192x128:#SRDRef=640x360:#SRD=192x128x192x104 -i $TEMP_DIR/high_832x512.hvc:#CropOrigin=832x512:#SRDRef=1280x720:#SRD=832x512x448x208 hevcmerge @ inspect:test=network:allp:deep:interleave=false:log=$myinspect" "merge-SRD-3tiles"
do_hash_test $myinspect "merge-SRD-3tiles"

#merge all tiles with SRD features
cropOrigins="0x0 0x128 0x256 192x0 192x128 192x256 384x0 384x128 384x256"
SRDs="0x0x192x128 0x128x192x104 0x256x192x128 192x0x192x128 192x128x192x104 192x256x192x128 384x0x256x128 384x128x256x104 384x256x256x128"

testarg="$GPAC " #the last character should be a space"
#simultaneous iteration over cropOrigins with $1, and SRDs with $j
set -- $cropOrigins
for j in $SRDs; do
  testarg+="-i $TEMP_DIR/low_$1.hvc:#CropOrigin=$1:#SRDRef=640x360:#SRD=$j " #the last character should be a space"
  shift
done

myinspect=$TEMP_DIR/inspect_all_low.txt
#TODO: the following command is better. However when the output is doubled, one for inspect filter the other for displaying the video, an issue appears repeating the inspect filter.
#testarg+="hevcmerge  @ inspect:allp:deep:interleave=false:log=$myinspect @1 -o $TEMP_DIR/merge4.hvc -graph"

testarg1="$testarg hevcmerge @ -o $TEMP_DIR/merge_all_low.hvc -graph"
do_test "$testarg1" "merge-all-low"
do_hash_test "$TEMP_DIR/merge_all_low.hvc" "merge-all-low"

testarg2="$testarg hevcmerge @ inspect:test=network:allp:deep:interleave=false:log=$myinspect -graph"
do_test "$testarg2" "merge-all-low-inspect"
do_hash_test $myinspect "merge-all-low-inspect"

test_end

