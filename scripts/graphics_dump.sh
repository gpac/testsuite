
graphics_test ()
{
 test_begin "graphics-$1"
 if [ $test_skip  = 1 ] ; then
  return
 fi

 dump_file=$TEMP_DIR/dump.png
 do_test "$GPAC -font-dirs=$EXTERNAL_MEDIA_DIR/fonts/ -rescan-fonts -i $2 -o $dump_file --osize=512x512 --noback" "dump-png"
 do_hash_test "$dump_file" "dump-png"

 dump_file=$TEMP_DIR/dump.jpg
 do_test "$GPAC -font-dirs=$EXTERNAL_MEDIA_DIR/fonts/ -rescan-fonts -i $2 -o $dump_file --osize=512x512" "dump-jpg"
 do_hash_test "$dump_file" "dump-jpg"

 test_end
}


graphics_test "bt2d-simple" "$MEDIA_DIR/bifs/bifs-2D-painting-material2D.bt"
graphics_test "bt2d-texture" "$MEDIA_DIR/bifs/bifs-2D-texturing-imagetexture-shapes.bt"
graphics_test "bt3d-simple" "$MEDIA_DIR/auxiliary_files/nefertiti.wrl"
graphics_test "bt3d-texture" "$MEDIA_DIR/bifs/bifs-3D-texturing-box.bt"
graphics_test "svg-simple" "$MEDIA_DIR/svg/Ghostscript_Tiger.svg"
