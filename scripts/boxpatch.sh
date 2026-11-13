boxpatch_base_test()
{
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

dst="$TEMP_DIR/file.mpd"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264 --boxpatch=$MEDIA_DIR/boxpatch/box_add_frag.xml -o $dst" "add-frag"
do_hash_test $TEMP_DIR/enst_video_dashinit.mp4 "add-frag-moov"
do_hash_test $TEMP_DIR/enst_video_dash1.m4s "add-frag-moof"

test_end
}

boxpatch_base_test

test_begin "gpac-patch_box-star"
if [ $test_skip = 1 ] ; then
return
fi

#remove HDR boxes without naming the sample entry
for codec in av01 avc1; do
  if [ "$codec" = "av01" ]; then
    input="$MEDIA_DIR/auxiliary_files/video_5s.ivf"
  else
    input="$MEDIA_DIR/auxiliary_files/enst_video.h264"
  fi

patch="$TEMP_DIR/hdr-add.xml"
hdr="$TEMP_DIR/hdr-$codec.mp4"
dump="$TEMP_DIR/hdr-$codec.xml"
cat > "$patch" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<GPACBOXES>
<Box path="trak.mdia.minf.stbl.stsd.$codec">
<BS fcc="mdcv"/>
<BS value="0" bits="64"/><BS value="0" bits="64"/><BS value="0" bits="64"/>
</Box>
<Box path="trak.mdia.minf.stbl.stsd.$codec">
<BS fcc="clli"/><BS value="0" bits="32"/>
</Box>
</GPACBOXES>
EOF
do_test "$GPAC -i $input -o $hdr:boxpatch=$patch" "add-hdr-$codec"
do_hash_test "$hdr" "add-hdr-$codec"
do_test "$MP4BOX -diso $hdr -out $dump" "dump-hdr-$codec"
if [ "$(grep -c 'Type="mdcv"' "$dump")" != "1" ] || [ "$(grep -c 'Type="clli"' "$dump")" != "1" ]; then
  result="HDR setup failed for $codec"
fi

for mode in recursive sample-entry; do
  if [ "$mode" = "recursive" ]; then
    prefix="trak.*"
  else
    prefix="trak.mdia.minf.stbl.stsd.*"
  fi
  patch="$TEMP_DIR/hdr-remove.xml"
  dst="$TEMP_DIR/hdr-$codec-$mode.mp4"
  dump="$TEMP_DIR/hdr-$codec-$mode.xml"
  cat > "$patch" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<GPACBOXES>
<Box path="$prefix.mdcv"/>
<Box path="$prefix.clli"/>
</GPACBOXES>
EOF
  do_test "$GPAC -i $hdr -o $dst:boxpatch=$patch" "remove-hdr-$codec-$mode"
  do_hash_test "$dst" "remove-hdr-$codec-$mode"
  do_test "$MP4BOX -diso $dst -out $dump" "dump-hdr-$codec-$mode"
  if grep -qE 'Type="(mdcv|clli)"' "$dump" || ! grep -q "Type=\"$codec\"" "$dump" || ! grep -q 'Type="btrt"' "$dump"; then
  result="Wildcard HDR removal failed for $codec ($mode)"
  fi
  done

#rmhdr must produce the same output as the recursive box patch
dst="$TEMP_DIR/hdr-$codec-rmhdr.mp4"
do_test "$GPAC -i $hdr -o $dst:rmhdr" "rmhdr-$codec"
do_hash_test "$dst" "rmhdr-$codec"
done


test_end
