
ttml_test  ()
{

if [ -z $2 ] ; then
 name=$(basename $1)
 name=${name%.*}
else
 name=$2
fi

 test_begin "ttml-$name"
 if [ $test_skip  = 1 ] ; then
  return
 fi

 mp4file=$TEMP_DIR/$name.mp4

 do_test "$MP4BOX -add $1 -new $mp4file" "import"
 do_hash_test $mp4file "import"

if [ $3 == 1 ] ; then
 rm $TEMP_DIR/test.xml 2> /dev/null
 do_test "$MP4BOX -raw $1 $mp4file -out $TEMP_DIR/test.xml" "export"
 do_hash_test $TEMP_DIR/test.xml "export"

fi

 test_end
}


ttml_test "$MEDIA_DIR/ttml/ebu-ttd_prefix.ttml" "" 0
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_sample_invalid_mixed_namespaces.ttml" "" 0
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_sample_span.ttml" "" 0
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_sample.ttml" "" 1
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_timing_contiguous.ttml" "" 0
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_timing_non-contiguous.ttml" "" 0
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_timing_overlapping.ttml" "" 0
ttml_test "$MEDIA_DIR/ttml/ttml_samples.ttml" "" 0
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_regions.ttml" "" 0
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_timing_overlapping_inv.ttml" "" 0
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_metrics.ttml" "" 1
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_metrics.ttml:sopt:ttml_single" "single-sample" 0

ttml_test "$MEDIA_DIR/ttml/ttml_images.ttml:sopt:ttml_embed" "embed-sample" 1
ttml_test "$MEDIA_DIR/ttml/ttml_images_head.ttml:sopt:ttml_embed" "embed-head-sample" 1



ttml_test "$MEDIA_DIR/ttml/ebu-ttd_sample.ttml:sopt:ttml_zero=T00:00:30.000" "zero" 1
