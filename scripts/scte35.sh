# Testing SCTE35 raw binarization

test_begin "scte35-raw"

do_test "$GPAC -i $MEDIA_DIR/xmlin4/nhml_scte35_raw.nhml -o $TEMP_DIR/nhml-scte35-raw.mp4" "import"
do_hash_test $TEMP_DIR/nhml-scte35-raw.mp4 "import"

test_end


test_begin "scte35-complete"

do_test "$GPAC -i $MEDIA_DIR/xmlin4/nhml_scte35.nhml -o $TEMP_DIR/nhml-scte35-evte.mp4" "import"
do_hash_test $TEMP_DIR/nhml-scte35-evte.mp4 "import"

do_test "$MP4BOX -dxml $TEMP_DIR/nhml-scte35-evte.mp4" "dxml"
do_hash_test $TEMP_DIR/nhml-scte35-evte_dump.xml "dxml"

if [ $test_skip  = 1 ] ; then
return
fi

do_test "$GPAC -i $TEMP_DIR/nhml-scte35-evte.mp4 inspect:analyze=full:deep:props:log=$TEMP_DIR/scte35-inspect.txt" "inspect"
do_hash_test $TEMP_DIR/scte35-inspect.txt "inspect"

do_test "$GPAC -i $TEMP_DIR/nhml-scte35-evte.mp4 -o $TEMP_DIR/scte35.nhml:nhmlonly:payload" "nhml_w"
do_hash_test $TEMP_DIR/scte35.nhml "nhml_w"

test_end

