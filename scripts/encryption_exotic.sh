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



#test encryption with master/leaf key
test_encrypt_template()
{
test_begin "encryption-template-$1"
if [ $test_skip  = 1 ] ; then
 return
fi

cfile=$TEMP_DIR/crypt.mp4
dfile=$TEMP_DIR/decrypt.mp4
ddfile=$TEMP_DIR/dashdecrypt.mp4
mfile=$TEMP_DIR/dash/live.mpd
cifile=$TEMP_DIR/dash/crypt_dashinit.mp4
cffile=$TEMP_DIR/dash/crypt_dash10.m4s

do_test "$GPAC -i $src cecrypt:cfile=$2 @ -o $cfile" "encrypt"
do_hash_test $cfile "encrypt"

do_test "$MP4BOX -dash 1000 -profile live -out $mfile $cfile" "dash"
do_hash_test $cifile "dash-init"
do_hash_test $cffile "dash-seg"

do_test "$MP4BOX -decrypt $cfile -out $dfile" "decrypt"
do_hash_test $dfile "decrypt"

#we need to inject dashin before cdcrypt as cdrypt only accept media pids and dashin only expose media pids caps as loaded filter
do_test "$GPAC -i $mfile dashin @ cdcrypt @ -o $ddfile" "dashdecrypt"
do_hash_test $ddfile "dashdecrypt"

test_end
}

test_encrypt_template "master-leaf" "$MEDIA_DIR/encryption/tpl_roll_master.xml"
test_encrypt_template "roll" "$MEDIA_DIR/encryption/tpl_roll.xml"



#test encryption with roll every 2 segments, 3 periods, middle one in clear
test_encrypt_seg_roll()
{
test_begin "encryption-roll-seg"
if [ $test_skip  = 1 ] ; then
 return
fi

dst=$TEMP_DIR/live.mpd
src=$TEMP_DIR/src.mp4
$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264:dur=5 -new $src 2> /dev/null

do_test "$GPAC -i $src:#Period=P1 -i $src:#Period=P2:#CryptInfo=clear -i $src:#Period=P3 dasher:gencues cecrypt:cfile=$MEDIA_DIR/encryption/roll_seg.xml -o $dst:template=\$Period\$_video_\$Number\$" "encrypt"
do_hash_test $dst "encrypt"

inspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $dst inspect:deep:log=$inspect" "inspect"
do_hash_test $inspect "inspect"


test_end
}

test_encrypt_seg_roll





#test encryption with 2 sample entries
test_encrypt_cenc_switch()
{
test_begin "encryption-cenc_switch"
if [ $test_skip  = 1 ] ; then
 return
fi

dst=$TEMP_DIR/enc.mp4
src=$TEMP_DIR/src.mp4
$MP4BOX -add $MEDIA_DIR/auxiliary_files/logo.png -cat $MEDIA_DIR/auxiliary_files/enst_video.h264 -new $src 2> /dev/null
do_hash_test $src "import"

do_test "$MP4BOX -crypt $MEDIA_DIR/encryption/ctr.xml $src -out $dst" "encrypt"
do_hash_test $dst "encrypt"

test_end
}

test_encrypt_cenc_switch



#test clearkey
test_clearkey()
{
test_begin "encryption-clearkey"
if [ $test_skip  = 1 ] ; then
 return
fi

#test decryption using one of dashif test files
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i https://media.axprod.net/TestVectors/v7-MultiDRM-SingleKey/Manifest_1080p_ClearKey.mpd -broken-cert dashin:debug_as=0:algo=none:start_with=min_q cdcrypt @ inspect:deep:dur=2:test=network:log=$myinspect -graph" "decrypt"
do_hash_test $myinspect "decrypt"


src=$MEDIA_DIR/auxiliary_files/counter.hvc
dst=$TEMP_DIR/live.mpd

#test encryption (just test setting of CKUrl prop)
do_test "$GPAC -i $src:#CKUrl=https://ck.gpac.io cecrypt:cfile=$MEDIA_DIR/encryption/ctr.xml -o $dst" "encrypt"
do_hash_test $dst "encrypt"


#test encryption (just test setting of ckurl option on dasher)
dst=$TEMP_DIR/live2.mpd
do_test "$GPAC -i $src cecrypt:cfile=$MEDIA_DIR/encryption/ctr.xml -o $dst::ckurl=https://ck.gpac.io" "encrypt2"
do_hash_test $dst "encrypt2"


test_end
}

test_clearkey
