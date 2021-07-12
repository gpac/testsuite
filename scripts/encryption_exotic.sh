#!/bin/sh

src=$EXTERNAL_MEDIA_DIR/counter/counter_1280_720_I_25_tiled_1mb.hevc

#test encryption and decryption of a subset of the subsamples
test_encrypt_subs()
{
test_begin "encryption-subs"
if [ $test_skip  = 1 ] ; then
 return
fi

cfile=$TEMP_DIR/crypt.mp4
dfile=$TEMP_DIR/decrypt.mp4

do_test "$GPAC -i $src cecrypt:cfile=$MEDIA_DIR/encryption/subs_ctr.xml @ -o $cfile" "encrypt"
do_hash_test $cfile "encrypt"

do_test "$MP4BOX -decrypt $cfile -out $dfile" "decrypt"
do_hash_test $dfile "decrypt"

test_end
}

test_encrypt_subs



#test encryption and decryption of a subset of the subsamples
test_encrypt_mkey()
{
test_begin "encryption-mkey-$1"
if [ $test_skip  = 1 ] ; then
 return
fi

cfile=$TEMP_DIR/crypt.mp4
dfile=$TEMP_DIR/decrypt.mp4

do_test "$GPAC -i $src cecrypt:cfile=$MEDIA_DIR/encryption/$2 @ -o $cfile" "encrypt"
do_hash_test $cfile "encrypt"

do_test "$MP4BOX -decrypt $cfile -out $dfile" "decrypt"
do_hash_test $dfile "decrypt"

#also test  mkey SAI senc dump
do_test "$MP4BOX -diso $dfile" "diso"
do_hash_test $TEMP_DIR/decrypt_info.xml "diso"

#and iff multikey import
cifile=$TEMP_DIR/crypt.heic
difile=$TEMP_DIR/decrypt.heic

do_test "$MP4BOX -add-image $cfile:samp=26 -new $cifile" "iff-mkey-import"
do_hash_test $cifile "iff-mkey-import"

do_test "$MP4BOX -decrypt $cifile -out $difile" "iff-mkey-decrypt"
do_hash_test $difile "iff-mkey-decrypt"


test_end
}

test_encrypt_mkey "base" "mkey_base.xml"
test_encrypt_mkey "roll" "mkey_roll.xml"
test_encrypt_mkey "subs" "mkey_subs.xml"



#test encryption with multiple sample desc
test_encrypt_multi_stsd()
{
test_begin "encryption-multi-stsd"
if [ $test_skip  = 1 ] ; then
 return
fi

cfile=$TEMP_DIR/crypt.mp4
dfile=$TEMP_DIR/decrypt.mp4
mfile=$TEMP_DIR/vod.mpd
cffile=$TEMP_DIR/crypt_dashinit.mp4

do_test "$GPAC -i $src cecrypt:cfile=$MEDIA_DIR/encryption/ctr_clear_stsd_after.xml @ -o $cfile" "encrypt"
do_hash_test $cfile "encrypt"

do_test "$MP4BOX -dash 1000 -profile onDemand -out $mfile $cfile" "dash"
do_hash_test $cffile "dash"


do_test "$MP4BOX -decrypt $cffile -out $dfile" "decrypt"
do_hash_test $dfile "decrypt"

test_end
}

test_encrypt_multi_stsd
