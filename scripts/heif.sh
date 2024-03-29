
#in this test we use the reframer filter to keep only SAP type 1 from source in target PICT media track
test_begin "heif-pict-filter"

 if [ $test_skip != 1 ] ; then

heif_file="$TEMP_DIR/file.heic"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/counter.hvc:hdlr=pict:@@reframer:saps=1 -ab heic -new $heif_file" "create-heif"

do_hash_test $heif_file "create-heif"

fi


test_end

#in this test we use the reframer filter to keep only SAP type 1 from source in target items, converting each sample to an item
test_begin "heif-items-filter"

 if [ $test_skip != 1 ] ; then

heif_file="$TEMP_DIR/file.heic"
#time=-1 will use all samples in the track to create the items
do_test "$MP4BOX -add-image $MEDIA_DIR/auxiliary_files/counter.hvc:time=-1:@@reframer:saps=1 -ab heic -new $heif_file" "create-heif"

do_hash_test $heif_file "create-heif"

# -let's have some fun and extract the items (we don't transcode here, to do so use .png or .jpg extensions)
do_test "$GPAC -i $heif_file -o $TEMP_DIR/item_\$ItemID\$.hvc" "dump-heif-items"

do_hash_test $TEMP_DIR/item_1.hvc "dump-item1"
do_hash_test $TEMP_DIR/item_10.hvc "dump-item10"

dump_file="$TEMP_DIR/dump.hvc"
do_test "$MP4BOX -dump-item 1:path=$dump_file $heif_file" "dump-mp4box"
do_hash_test $dump_file "dump-mp4box"


# -let's have some fun and extract the items as track (we don't transcode here, to do so use .png or .jpg extensions)
#:itt will be inherited by the mp4dmx filter and will build a single track from all items, using each item as a sample
#:split will be inherited by the writegen filter to force writing signaling file per frame
do_test "$GPAC -i $heif_file:itt -o $TEMP_DIR/itt_\$num\$.hvc:split" "dump-heif-items-itt"
do_hash_test $TEMP_DIR/itt_1.hvc "dump-itt1"
do_hash_test $TEMP_DIR/itt_10.hvc "dump-itt10"


# -let's have some fun and extract all the items as a single track
#:itt will be inherited by the mp4dmx filter and will build a single track from all items, using each item as a sample
do_test "$GPAC -i $heif_file:itt -o $TEMP_DIR/itt_track.hvc" "dump-heif-track"
do_hash_test $TEMP_DIR/itt_track.hvc "dump-itt_track"


fi


test_end


# test unci in heiv
test_begin "heif-unci"
if [ $test_skip != 1 ] ; then

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/sky.jpg:#ItemID=1 reframer:raw=v:copy -o $TEMP_DIR/unci.heif" "heif"
do_hash_test $TEMP_DIR/unci.heif "heif"


fi
test_end
