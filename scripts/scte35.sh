# Testing SCTE35 raw binarization

scte35_raw()
{
test_begin "scte35-raw"
if [ $test_skip  = 1 ] ; then
return
fi

do_test "$GPAC -i $MEDIA_DIR/xmlin4/nhml_scte35.nhml -o $TEMP_DIR/nhml-scte35.mp4" "import-mp4"
do_hash_test $TEMP_DIR/nhml-scte35.mp4 "import-mp4"

test_end
}


scte35_ts()
{

test_begin "scte35-ts"
if [ $test_skip  = 1 ] ; then
return
fi

# we need a video track since SCTE35 is attached to video packet as a property
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264 -i $MEDIA_DIR/xmlin4/nhml_scte35.nhml -o $TEMP_DIR/nhml-scte35.ts" "import-ts"
do_hash_test $TEMP_DIR/nhml-scte35.ts "import-ts"

do_test "$GPAC -i $TEMP_DIR/nhml-scte35.ts -o $TEMP_DIR/nhml-scte35-evte.mp4" "import-mp4"
do_hash_test $TEMP_DIR/nhml-scte35-evte.mp4 "import-mp4"

do_test "$MP4BOX -dxml $TEMP_DIR/nhml-scte35-evte.mp4" "dxml"
do_hash_test $TEMP_DIR/nhml-scte35-evte_dump.xml "dxml"

test_end

}


scte35_complete()
{

test_begin "scte35-complete"
if [ $test_skip  = 1 ] ; then
return
fi

do_test "$GPAC -i $MEDIA_DIR/xmlin4/nhml_scte35.nhml -o $TEMP_DIR/nhml-scte35-evte.mp4" "import"
do_hash_test $TEMP_DIR/nhml-scte35-evte.mp4 "import"

do_test "$MP4BOX -dxml $TEMP_DIR/nhml-scte35-evte.mp4" "dxml"
do_hash_test $TEMP_DIR/nhml-scte35-evte_dump.xml "dxml"

do_test "$GPAC -i $TEMP_DIR/nhml-scte35-evte.mp4 inspect:analyze=full:deep:props:log=$TEMP_DIR/scte35-inspect.txt" "inspect"
do_hash_test $TEMP_DIR/scte35-inspect.txt "inspect"

do_test "$GPAC -i $TEMP_DIR/nhml-scte35-evte.mp4 -o $TEMP_DIR/scte35.nhml:nhmlonly:payload" "nhml_w"
do_hash_test $TEMP_DIR/scte35.nhml "nhml_w"

test_end

}


scte35_dasher()
{

test_begin "scte35-dasher"
if [ $test_skip  = 1 ] ; then
 return
fi

if [ $EXTERNAL_MEDIA_AVAILABLE = 0 ] ; then
 return
fi

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/scte35/scte35-simple.ts -o $TEMP_DIR/scte35-oob.mpd:segdur=1:scte35=xml+bin" "mpd-outband"
do_hash_test $TEMP_DIR/scte35-oob.mpd "mpd-outband"

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/scte35/scte35-simple.ts -o $TEMP_DIR/scte35-ib.mpd:segdur=1:scte35=inband" "mpd-inband"
do_hash_test $TEMP_DIR/scte35-ib.mpd "mpd-inband"

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/scte35/scte35-simple.ts -o $TEMP_DIR/scte35-all.mpd:segdur=1:scte35=all" "mpd-all"
do_hash_test $TEMP_DIR/scte35-all.mpd "mpd-all"

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/scte35/scte35-simple.ts -o $TEMP_DIR/scte35-none.mpd:segdur=1:scte35=none" "mpd-none"
do_hash_test $TEMP_DIR/scte35-none.mpd "mpd-none"

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/scte35/scte35-simple.ts -o $TEMP_DIR/scte35.m3u8:segdur=1:tsb=-1" "hls-simple"
do_hash_test $TEMP_DIR/scte35_1.m3u8 "hls-simple"

#multiple events embedded in the same segment
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/scte35/scte35-simple.ts -o $TEMP_DIR/scte35.m3u8:segdur=6:tsb=-1" "hls-multi"
do_hash_test $TEMP_DIR/scte35_1.m3u8 "hls-multi"

test_end

}



scte35_raw
scte35_ts
scte35_complete
scte35_dasher

