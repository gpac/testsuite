# Test Event Track (evte) raw binarization

evte_raw()
{
test_begin "evte-raw"
if [ $test_skip  = 1 ] ; then
return
fi

do_test "$GPAC -i $MEDIA_DIR/xmlin4/nhml_evte.nhml -o $TEMP_DIR/nhml-evte.mp4" "import-mp4"
do_hash_test $TEMP_DIR/nhml-evte.mp4 "import-mp4"

do_test "$GPAC -i $TEMP_DIR/nhml-evte.mp4 -o $TEMP_DIR/nhml-evte.mpd" "mpd"
do_hash_test $TEMP_DIR/nhml-evte.mpd "mpd"

test_end
}

evte_raw
