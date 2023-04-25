
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

 do_test "$MP4BOX -add $1 -new $mp4file --no_empty" "import"
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
ttml_test "$MEDIA_DIR/ttml/ebu-ttd_metrics.ttml:sopt:ttml_split=0" "single-sample" 0

ttml_test "$MEDIA_DIR/ttml/ttml_images.ttml:sopt:ttml_embed" "embed-sample" 1
ttml_test "$MEDIA_DIR/ttml/ttml_images_head.ttml:sopt:ttml_embed" "embed-head-sample" 1

ttml_test "$MEDIA_DIR/ttml/empty.ttml" "" 1



ttml_test "$MEDIA_DIR/ttml/ebu-ttd_sample.ttml:sopt:ttml_zero=T00:00:30.000" "zero" 1


ttml_test_cat  ()
{

 test_begin "ttml-cat"
 if [ $test_skip  = 1 ] ; then
  return
 fi

#note that the resulting file is not a valid TTML because we use two time-overlaping docs as source
#the tes is only intended to check ttml single doc mode from playlist for adding or dashing
src1=$MEDIA_DIR/ttml/ebu-ttd_sample.ttml
src2=$MEDIA_DIR/ttml/ebu-ttd_sample_span.ttml
pl=pl.m3u
mp4file=$TEMP_DIR/file.mp4

echo "$src1:ttml_split=0:ttml_dur=30" > $pl
echo "$src2:ttml_split=0:ttml_dur=20" >> $pl

do_test "$MP4BOX -add $pl -new $mp4file" "import"
do_hash_test $mp4file "import"

#dash using inband cues, each input in playlist resulting in a media segment
do_test "$MP4BOX -dash 1000 -profile onDemand -out $TEMP_DIR/vod.mpd $pl:sigcues" "dash-cues"
do_hash_test $TEMP_DIR/ebu-ttd_sample_dashinit.mp4 "dash"

mv $pl $TEMP_DIR

test_end
}


ttml_test_cat
