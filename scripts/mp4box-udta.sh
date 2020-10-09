

test_begin "mp4box-udta"
if [ "$test_skip" = 1 ] ; then
return
fi

mp4file="$TEMP_DIR/udtamoov.mp4"
binfile="$TEMP_DIR/dumpmoov.jpg"

do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/logo.png -udta 0:type=GPAC:src=$MEDIA_DIR/auxiliary_files/logo.jpg -new $mp4file" "udta-moov"
do_hash_test $mp4file "udta-moov"

do_test "$MP4BOX -dump-udta GPAC $mp4file -out $binfile" "udta-moov-dump"
do_hash_test $binfile "udta-moov-dump"

do_test "$MP4BOX -udta 0:type=GPAC:src= $mp4file" "udta-moov-rem"
do_hash_test $mp4file "udta-moov-rem"

mp4file="$TEMP_DIR/udtatrack.mp4"
binfile="$TEMP_DIR/dumptrack.bin"

do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/logo.png -udta 1:type=GPAC:src=base64,dGVzdA== -new $mp4file" "udta-track"
do_hash_test $mp4file "udta-track"

do_test "$MP4BOX -dump-udta 1:GPAC $mp4file -out $binfile" "udta-track-dump"
do_hash_test $binfile "udta-track-dump"

mp4file="$TEMP_DIR/udtatrack2.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/logo.png -udta 1:type=GPAC:box=$TEMP_DIR/udtatrack.mp4 -new $mp4file" "udta-box-track"
do_hash_test $mp4file "udta-box-track"


mp4file="$TEMP_DIR/udtatrackstr.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -udta 1:type=name:str=My_Super_Name -new $mp4file" "udta-track-str"
do_hash_test $mp4file "udta-track-str"

test_end


