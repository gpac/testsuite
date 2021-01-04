
ttml_test  ()
{
 name=$(basename $1)
 name=${name%.*}

 test_begin "ttml-$name"
 if [ $test_skip  = 1 ] ; then
  return
 fi

 mp4file=$TEMP_DIR/$name.mp4

 do_test "$MP4BOX -add $1 -new $mp4file" "import"
 do_hash_test $mp4file "import"

 test_end
}


ttml_test "$MEDIA_DIR/ttml/ebu-ttd_prefix.ttml"
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_sample_invalid_mixed_namespaces.ttml"
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_sample_span.ttml"
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_sample.ttml"
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_timing_contiguous.ttml"
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_timing_non-contiguous.ttml"
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_timing_overlapping.ttml"
ttml_test "$MEDIA_DIR/ttml/ttml_samples.ttml"
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_regions.ttml"
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_timing_overlapping_inv.ttml"
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_metrics.ttml"



