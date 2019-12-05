

test_begin "gpac-patch_box"
if [ $test_skip = 1 ] ; then
return
fi

dst="$TEMP_DIR/root_add.mp4"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264 -o $dst:boxpatch=$MEDIA_DIR/boxpatch/box_add_root.xml" "add-root-box"
do_hash_test $dst "add-root-box"

dst="$TEMP_DIR/track_add.mp4"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264:#boxpatch=$MEDIA_DIR/boxpatch/box_add.xml -o $dst" "add-box"
do_hash_test $dst "add-box"

dst="$TEMP_DIR/track_add_inline.mp4"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264:#boxpatch=file@$MEDIA_DIR/boxpatch/box_add.xml -o $dst" "add-box-inline"
do_hash_test $dst "add-box-inline"

dst="$TEMP_DIR/item_add.mp4"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/sky.jpg:#ItemID=1 -o $dst:boxpatch=$MEDIA_DIR/boxpatch/box_add_item.xml" "add-item"
do_hash_test $dst "add-item"

dst="$TEMP_DIR/item_prop_add.mp4"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/sky.jpg:#ItemID=1 -o $dst:boxpatch=$MEDIA_DIR/boxpatch/box_add_item_prop.xml" "add-item-prop"
do_hash_test $dst "add-item-prop"

dst="$TEMP_DIR/item_prop_add2.mp4"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/sky.jpg:#ItemID=1:#boxpatch=$MEDIA_DIR/boxpatch/box_add_item_prop_no_item.xml -o $dst" "add-item-prop2"
do_hash_test $dst "add-item-prop2"


test_end



