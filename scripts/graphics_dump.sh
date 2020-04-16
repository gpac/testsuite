
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


do_hash=1
#we don't have the same 2D renderer precision on 32 and 64 bits, disable hashes for linux 32
#note that we keep them for win32 since we run our tests on a 64 bit VM emuating 32 bit so no precision loss
if [ $GPAC_OSTYPE == "lin32" ] ; then
do_hash=0
fi

graphics_test "bt2d-simple" "$MEDIA_DIR/bifs/bifs-2D-painting-material2D.bt" $do_hash
graphics_test "bt2d-texture" "$MEDIA_DIR/bifs/bifs-2D-texturing-imagetexture-shapes.bt" $do_hash

#cannot do hash tests for 3D, GPUs will give different results...
graphics_test "bt3d-simple" "$MEDIA_DIR/auxiliary_files/nefertiti.wrl" 0
graphics_test "bt3d-texture" "$MEDIA_DIR/bifs/bifs-3D-texturing-box.bt" 0
graphics_test "svg-simple" "$MEDIA_DIR/svg/Ghostscript_Tiger.svg" $do_hash
