ase_test()
{

test_begin "ase-$2"

if [ $test_skip  = 1 ] ; then
 return
fi

mp4file="$TEMP_DIR/$2.mp4"

do_test "$MP4BOX -add $1:asemode=$2 -new $mp4file" "import"
do_hash_test $mp4file "import"
$MP4BOX -diso $mp4file

test_end

}


ase_test "$EXTERNAL_MEDIA_DIR/import/aac_vbr_51_128k.aac" "v0-s" 
ase_test "$EXTERNAL_MEDIA_DIR/import/aac_vbr_51_128k.aac" "v0-2"

ase_test "$EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.ac3" "v0-bs"

ase_test "$EXTERNAL_MEDIA_DIR/import/aac_vbr_51_128k.aac" "v1"
ase_test "$EXTERNAL_MEDIA_DIR/import/aac_vbr_51_128k.aac" "v1-qt"
