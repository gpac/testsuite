filename=""

test_split()
{

test_begin "bssplit-$1"

if [ "$test_skip" = 1 ] ; then
return
fi

fext="${filename##*.}"
splitfile="$TEMP_DIR/scal_split.mp4"
aggfile="$TEMP_DIR/scal_agg.mp4"

#split input
do_test "$GPAC -i $filename bssplit$2 @ -o $splitfile" "split"
do_hash_test $splitfile "split"

#aggregate split file
do_test "$GPAC -i $splitfile bsagg @ -o $aggfile" "agg"
do_hash_test $aggfile "agg"

if [ "$3" == 1 ] ; then

#dump aggregate file, import source and aggregate and compare hashes
mp4file1="$TEMP_DIR/reimport1.mp4"
$GPAC -i $filename -o $mp4file1 2> /dev/null

#we cannot use directly -i mp4 rfnalu @ -o rmx in this case because this will potentially trigger decoder reconfig
#depending on split pattern (layer, tid) and rfnalu may dispatch the same decoder config with different PS order
mp4file2="$TEMP_DIR/reimport2.mp4"
tmpfile="$TEMP_DIR/dump.$fext"
$GPAC -i $aggfile -o $tmpfile 2> /dev/null
$GPAC -i $tmpfile -o $mp4file2 2> /dev/null

$DIFF $mp4file1 $mp4file2 > /dev/null
rv=$?
if [ $rv != 0 ] ; then
  result="source and reagg files differ"
fi

fi

test_end
}

filename="$MEDIA_DIR/dolby_vision/dolby_vision_cenc.ismv"
test_split "dv-rpu" "" 0

if [ $EXTERNAL_MEDIA_AVAILABLE = 0 ] ; then
  return
fi

filename="$EXTERNAL_MEDIA_DIR/scalable/svc.264"
test_split "svc-layers" "" 1
test_split "svc-all" ":ltid=all" 1
test_split "svc-cust" ":ltid=0.1,0.2,1.0" 1
test_split "svc-alltid" ":ltid=.1,.2,.3" 1

filename="$EXTERNAL_MEDIA_DIR/scalable/shvc.265"
test_split "shvc-layers" "" 1
test_split "shvc-all" ":ltid=all" 1
test_split "shvc-cust" ":ltid=0.1,0.2" 1
test_split "shvc-alltid" ":ltid=.1,.2" 1


filename="$EXTERNAL_MEDIA_DIR/counter/counter_30s_320x180p_I25_closedGOP_128kpbs.vvc"
test_split "vvc" "" 0

#for coverage
single_test "$GPAC -i $MEDIA_DIR/auxiliary_files/logo.jpg bssplit inspect -graph" "bssplit-passthrough"
single_test "$GPAC -i $MEDIA_DIR/auxiliary_files/logo.jpg bsagg inspect -graph" "bsagg-passthrough"
