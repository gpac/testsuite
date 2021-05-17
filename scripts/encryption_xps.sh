#!/bin/sh

#test import of encrypted files, whether flat or fragmented.
encrypt_xps()
{
test_begin "encryption-$1"
if [ $test_skip  = 1 ] ; then
 return
fi

mp4file="$TEMP_DIR/src.mp4"

$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_640x360_192kbps.264:dur=10:xps_inband$2 -new $mp4file 2> /dev/null

crypt="$TEMP_DIR/ctr_cryp.mp4"
dcrypt="$TEMP_DIR/ctr_decryp.mp4"

do_test "$MP4BOX -crypt $MEDIA_DIR/encryption/ctr.xml $mp4file -out $crypt" "crypt-ctr"
do_hash_test $crypt "crypt-ctr"

do_test "$MP4BOX -decrypt $crypt -out $dcrypt" "decrypt-ctr"
do_hash_test $dcrypt "decrypt-ctr"

crypt="$TEMP_DIR/cbcs_cryp.mp4"
dcrypt="$TEMP_DIR/cbcs_decryp.mp4"

do_test "$MP4BOX -crypt $MEDIA_DIR/encryption/cbcs.xml $mp4file -out $crypt" "crypt-cbcs"
do_hash_test $crypt "crypt-cbcs"

do_test "$MP4BOX -decrypt $crypt -out $dcrypt" "decrypt-cbcs"
do_hash_test $dcrypt "decrypt-cbcs"


test_end
}


encrypt_xps "xps" ""
encrypt_xps "pps" ":dopt:pps_inband"
