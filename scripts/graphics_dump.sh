
graphics_test ()
{
 test_begin "graphics-$1"
 if [ $test_skip  = 1 ] ; then
  return
 fi

 dump_file=$TEMP_DIR/dump.png
 do_test "$GPAC -font-dirs=$EXTERNAL_MEDIA_DIR/fonts/ -rescan-fonts -i $2 -o $dump_file --osize=512x512 --noback" "dump-png"

#hash (2D) or test file presence
if [ $3 = 1 ] ; then
 do_hash_test "$dump_file" "dump-png"
else
 if [ ! -f $dump_file ] ; then
  result="PNG output not present"
 fi
fi

 dump_file=$TEMP_DIR/dump.jpg
 do_test "$GPAC -font-dirs=$EXTERNAL_MEDIA_DIR/fonts/ -rescan-fonts -i $2 -o $dump_file --osize=512x512" "dump-jpg"

#hash (2D) or test file presence
if [ $3 = 1 ] ; then
 do_hash_test "$dump_file" "dump-jpg"
else
 if [ ! -f $dump_file ] ; then
  result="JPG output not present"
 fi
fi

 test_end
}


graphics_test "bt2d-simple" "$MEDIA_DIR/bifs/bifs-2D-painting-material2D.bt" 1
graphics_test "bt2d-texture" "$MEDIA_DIR/bifs/bifs-2D-texturing-imagetexture-shapes.bt" 1

#cannot do hash tests for 3D, GPUs will give different results...
graphics_test "bt3d-simple" "$MEDIA_DIR/auxiliary_files/nefertiti.wrl" 0
graphics_test "bt3d-texture" "$MEDIA_DIR/bifs/bifs-3D-texturing-box.bt" 0
graphics_test "svg-simple" "$MEDIA_DIR/svg/Ghostscript_Tiger.svg" 1
