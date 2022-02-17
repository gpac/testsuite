#!/bin/sh

test_begin "NHMLSubs"
if [ $test_skip != 1 ] ; then

nhml_ttml_file="$TEMP_DIR/nhml_ttml.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/ttml/ttml.nhml -new $nhml_ttml_file" "create-nhml_ttml"
do_hash_test $nhml_ttml_file "create-nhml_ttml"

test_end
fi



test_begin "NHMLSubsDesc"
if [ $test_skip != 1 ] ; then

nhml_subs="$TEMP_DIR/nhml_subs.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/xmlin4/nhml_subs.nhml -new $nhml_subs" "create-nhml"
do_hash_test $nhml_subs "create-nhml"

test_end
fi


test_sai_sgpd()
{
test_begin "NHML-$1"
if [ $test_skip == 1 ] ; then
return
fi

#create SAI/sgdp from nhml to mp4 regular
nhml="$TEMP_DIR/nhml.mp4"
do_test "$GPAC -i $2 -o $nhml" "nhml"
do_hash_test $nhml "nhml"

#create SAI/sgdp from nhml to fmp4
nhml_frag="$TEMP_DIR/nhml_frag.mp4"
do_test "$GPAC -i $2 -o $nhml_frag:frag" "nhml-frag"
do_hash_test $nhml_frag "nhml-frag"

#check SAI/sgdp merge from fragment
nhml_flat="$TEMP_DIR/nhml_flat.mp4"
do_test "$MP4BOX -inter 500 $nhml_frag -out $nhml_flat" "nhml-flat"
do_hash_test $nhml_flat "nhml-flat"

#check SAI/sgdp in track import
nhml_add="$TEMP_DIR/nhml_add.mp4"
do_test "$MP4BOX -add $nhml -new $nhml_add" "nhml-add"
do_hash_test $nhml_add "nhml-add"

#check SAI/sgdp from mp4dmx regular mode
myinspect="$TEMP_DIR/inspect.txt"
do_test "$GPAC -i $nhml inspect:deep:log=$myinspect" "nhml-inspect"
do_hash_test $myinspect "nhml-inspect"

#check SAI/sgdp from mp4dmx fragmented mode
myinspect="$TEMP_DIR/inspect_frag.txt"
do_test "$GPAC -i $nhml_frag inspect:deep:log=$myinspect" "nhml-inspect-frag"
do_hash_test $myinspect "nhml-inspect-frag"

#check properties
myinspect="$TEMP_DIR/inspect_raw.txt"
do_test "$GPAC -i $2 inspect:deep:log=$myinspect" "inspect-raw"
do_hash_test $myinspect "inspect-raw"

test_end
}

test_sai_sgpd "SAI" "$MEDIA_DIR/xmlin4/nhml_sai.nhml"
test_sai_sgpd "SGPD" "$MEDIA_DIR/xmlin4/nhml_sgpd.nhml"
test_sai_sgpd "ref" "$MEDIA_DIR/xmlin4/nhml_sgpd_ref.nhml"

