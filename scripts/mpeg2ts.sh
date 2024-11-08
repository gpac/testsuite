#test mpeg2 TS

srcfile=$EXTERNAL_MEDIA_DIR/m2ts/TNT_MUX_R1_586MHz_10s.ts

test_begin "m2ts-dmx"
if [ $test_skip != 1 ] ; then
insfile=$TEMP_DIR/dump.txt
#inpect demuxed file in non-interleave mode (pid by pid), also dumps PCR
do_test "$GPAC -i $srcfile inspect:interleave=false:deep:pcr:log=$insfile" "inspect"
do_hash_test "$insfile" "inspect"
fi
test_end


test_begin "m2ts-mp4"
if [ $test_skip != 1 ] ; then
dstfile="$TEMP_DIR/mux.mp4"
#we don't set bitrate as 32 bits platforms rounding give slight different results
do_test "$GPAC -i $srcfile -o $dstfile:btrt=0" "mp4mux"
do_hash_test "$dstfile" "mp4mux"
fi
test_end

test_begin "m2ts-mp4-split"
if [ $test_skip != 1 ] ; then

#we don't set bitrate as 32 bits platforms rounding give slight different results
do_test "$GPAC -logs=app@debug -i $srcfile -o $TEMP_DIR/prog_\$ServiceID\$.mp4:btrt=0:SID=#ServiceID=" "mp4mux"

do_hash_test "$TEMP_DIR/prog_257.mp4" "prog_257"
do_hash_test "$TEMP_DIR/prog_260.mp4" "prog_260"
do_hash_test "$TEMP_DIR/prog_261.mp4" "prog_261"
do_hash_test "$TEMP_DIR/prog_262.mp4" "prog_262"
do_hash_test "$TEMP_DIR/prog_273.mp4" "prog_273"
do_hash_test "$TEMP_DIR/prog_374.mp4" "prog_374"

fi
test_end

test_begin "m2ts-split"
if [ $test_skip != 1 ] ; then

do_test "$GPAC -i $srcfile tssplit @#ServiceID= -o $TEMP_DIR/prog_\$GINC(10,2).ts" "tssplit"

do_hash_test "$TEMP_DIR/prog_10.ts" "prog_10"
do_hash_test "$TEMP_DIR/prog_12.ts" "prog_12"
do_hash_test "$TEMP_DIR/prog_14.ts" "prog_14"
do_hash_test "$TEMP_DIR/prog_16.ts" "prog_16"
do_hash_test "$TEMP_DIR/prog_18.ts" "prog_18"
do_hash_test "$TEMP_DIR/prog_20.ts" "prog_20"

fi
test_end

srcfile=$EXTERNAL_MEDIA_DIR/m2ts/paff.ts

test_begin "m2ts-paff"
if [ $test_skip != 1 ] ; then

insfile=$TEMP_DIR/dump.txt
#inpect demuxed file in non-interleave mode (pid by pid), also dumps PCR
do_test "$GPAC -i $srcfile inspect:interleave=false:deep:log=$insfile" "inspect"
do_hash_test "$insfile" "inspect"

#import with gpac
dstfile="$TEMP_DIR/test-gpac.mp4"
do_test "$GPAC -i $srcfile -o $dstfile" "import-gpac"
do_hash_test "$dstfile" "import-gpac"

#import with MP4Box
dstfile="$TEMP_DIR/test-mp4box.mp4"
do_test "$MP4BOX -add $srcfile -new $dstfile" "import-mp4box"
do_hash_test "$dstfile" "import-mp4box"

fi
test_end
