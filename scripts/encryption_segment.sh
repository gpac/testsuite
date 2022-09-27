#!/bin/sh

#test encryption and decryption of init segement and segment files
test_begin "encryption-segment"
if [ $test_skip  = 1 ] ; then
 return
fi

mp4file="$TEMP_DIR/source.mp4"
mpdfile="$TEMP_DIR/file.mpd"

$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_640x360_192kbps.264:dur=10 -new $mp4file 2> /dev/null

$MP4BOX -dash 5000 -frag 1000 -out $mpdfile $mp4file -profile live 2> /dev/null

do_test "$MP4BOX -crypt $MEDIA_DIR/encryption/ctr.xml $TEMP_DIR/source_dashinit.mp4 -out $TEMP_DIR/dst_dashinit.mp4" "crypt-init"
do_hash_test "$TEMP_DIR/dst_dashinit.mp4" "crypt-init"

do_test "$MP4BOX -crypt $MEDIA_DIR/encryption/ctr.xml -init-seg $TEMP_DIR/source_dashinit.mp4 $TEMP_DIR/source_dash1.m4s -out $TEMP_DIR/dst_dash1.m4s" "crypt-seg1"
do_hash_test "$TEMP_DIR/dst_dash1.m4s" "crypt-seg1"

do_test "$MP4BOX -crypt $MEDIA_DIR/encryption/ctr.xml -init-seg $TEMP_DIR/source_dashinit.mp4 $TEMP_DIR/source_dash2.m4s -out $TEMP_DIR/dst_dash2.m4s" "crypt-seg2"
do_hash_test "$TEMP_DIR/dst_dash2.m4s" "crypt-seg2"

do_test "$MP4BOX -diso -init-seg $TEMP_DIR/source_dashinit.mp4 $TEMP_DIR/source_dash2.m4s" "diso-seg2"
do_hash_test "$TEMP_DIR/source_dash2_info.xml" "diso-seg2"

do_test "$MP4BOX -diso -init-seg $TEMP_DIR/dst_dashinit.mp4 $TEMP_DIR/dst_dash2.m4s" "diso-crypt-seg2"
do_hash_test "$TEMP_DIR/dst_dash2_info.xml" "diso-crypt-seg2"

do_test "$MP4BOX -decrypt $MEDIA_DIR/encryption/ctr.xml $TEMP_DIR/dst_dashinit.mp4 -out $TEMP_DIR/decrypt_dashinit.mp4" "decrypt-init"
do_hash_test "$TEMP_DIR/decrypt_dashinit.mp4" "decrypt-init"

do_test "$MP4BOX -decrypt $MEDIA_DIR/encryption/ctr.xml -init-seg $TEMP_DIR/dst_dashinit.mp4 $TEMP_DIR/dst_dash1.m4s -out $TEMP_DIR/decrypt_dash1.m4s" "decrypt-seg1"
do_hash_test "$TEMP_DIR/decrypt_dash1.m4s" "decrypt-seg1"

#same as above (decrypt init segment and produce init seg) using gpac
do_test "$GPAC -i $TEMP_DIR/dst_dashinit.mp4 cdcrypt:cfile=$MEDIA_DIR/encryption/ctr.xml -o $TEMP_DIR/decrypt_dashinit2.mp4:frag:cmfc" "decrypt-init2"
do_hash_test "$TEMP_DIR/decrypt_dashinit2.mp4" "decrypt-init2"

#same as above (decrypt second segment and output as segment) using gpac
do_test "$GPAC  --initseg=$TEMP_DIR/dst_dashinit.mp4 -i $TEMP_DIR/dst_dash2.m4s cdcrypt:cfile=$MEDIA_DIR/encryption/ctr.xml -o $TEMP_DIR/decrypt_dash2.m4s:frag:cmfc:noinit" "decrypt-seg2"
do_hash_test "$TEMP_DIR/decrypt_dash2.m4s" "decrypt-seg2"

test_end
