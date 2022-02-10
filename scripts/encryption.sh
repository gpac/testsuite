

crypto_unit_test()
{

test_begin "encryption-$1"

if [ $test_skip  = 1 ] ; then
 return
fi

 #for coverage, test XML dump for isma
 dump_isma=0
 case $1 in
 *isma* )
  dump_isma=1;;
 esac
cryptfile="$TEMP_DIR/$1-crypted.mp4"
decryptfile="$TEMP_DIR/$1-decrypted.mp4"

do_test "$MP4BOX -crypt $2 -out $cryptfile $mp4file" "Encrypt"
do_hash_test $cryptfile "crypt"

do_test "$MP4BOX -decrypt $2 -out $decryptfile $cryptfile" "Decrypt"
do_hash_test $decryptfile "decrypt"

#compare hashes of source and decrypted
do_compare_file_hashes $mp4file $decryptfile
rv=$?

if [ $rv != 0 ] ; then
result="Hash is not the same between source content and decrypted content"
fi

if [ $dump_isma = 1 ] ; then
ismadump="$TEMP_DIR/isamdump.xml"
do_test "$MP4BOX -dcr $cryptfile -out $ismadump" "DumpIsma"

hintfile="$TEMP_DIR/$1-crypted_hint.mp4"
do_test "$MP4BOX -hint $cryptfile -out $hintfile" "HintIsma"

do_test "$MP4BOX -set-kms gpac:uri.isma $cryptfile -out $TEMP_DIR/isma_kms.mp4" "SetKMS"

fi

#do MP4Box -info
do_test "$MP4BOX -info $cryptfile" "INFO"

#do dash test
do_test "$MP4BOX -dash 4000 -profile live -out $TEMP_DIR/test.mpd $cryptfile" "DASH"

dashfile="$TEMP_DIR/$1-crypted_dashinit.mp4"
do_hash_test $dashfile "crypt-dash-init"

dashfile="$TEMP_DIR/$1-crypted_dash1.m4s"
do_hash_test $dashfile "crypt-dash-seg"

test_end

}

crypto_test_file()
{

for drm in $MEDIA_DIR/encryption/*.xml ; do

case $drm in
*cbcs_const_roll* )
  continue ;;
*hls_saes* )
  continue ;;
*mkey* )
  continue ;;
*subs* )
  continue ;;
*tpl_* )
  continue ;;
*roll_seg* )
  continue ;;
*roll_period* )
  continue ;;
esac

#vp9 only supports ctr for now
if [ $1 == "vp9" ] ; then
 case $drm in
 *cbc* )
 	continue ;;
 *adobe* )
 	continue ;;
 *isma* )
 	continue ;;
 *cens* )
 	continue ;;
 *clearbytes* )
 	continue ;;
 *forceclear* )
 	continue ;;
 *clear_stsd* )
 	continue ;;
 *roll_rap* )
 	continue ;;
 esac
elif [ $1 != "avc" ] ; then
 case $drm in
 *clearbytes* )
 	continue ;;
 *forceclear* )
 	continue ;;
 *clear_stsd* )
 	continue ;;
 *roll_rap* )
 	continue ;;
 esac
fi

name=$(basename $drm)
name=${name%%.*}

crypto_unit_test "$name-$1" $drm

done

}

mp4file="$TEMP_DIR/source_media.mp4"

#AVC
$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264 -new $mp4file 2> /dev/null
crypto_test_file "avc"

#AAC
$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -new $mp4file 2> /dev/null
crypto_test_file "aac"

#HEVC
$MP4BOX -add $MEDIA_DIR/auxiliary_files/counter.hvc -new $mp4file 2> /dev/null
crypto_test_file "hevc"

#AV1
$MP4BOX -add $MEDIA_DIR/auxiliary_files/video.av1 -new $mp4file 2> /dev/null
crypto_test_file "av1"

if [ $EXTERNAL_MEDIA_AVAILABLE = 0 ] ; then
 return
fi

#VVC
$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_1280x720p_I25_closedGOP_512kpbs.vvc:dur=2 -new $mp4file 2> /dev/null
crypto_test_file "vvc"

rm -f $mp4file 2> /dev/null


#test encryption of AVC with emul prev byte in non encrypted NAL
test_begin "encryption-avc-ebp"

$MP4BOX -crypt $MEDIA_DIR/encryption/cbcs.xml $EXTERNAL_MEDIA_DIR/misc/avc_sei_epb.mp4 -out $mp4file 2> /dev/null
do_hash_test $mp4file "crypt-avc-epb"
rm -f $mp4file 2> /dev/null

test_end

#AV1 with small tiles less than 16 bytes
$MP4BOX -add $EXTERNAL_MEDIA_DIR/import/obu_tiles4x2_grp4.av1 -new $mp4file 2> /dev/null
crypto_test_file "av1small"


#VP9, we only test CTR
$MP4BOX -add $EXTERNAL_MEDIA_DIR/import/counter_1280_720_I_25_500k.ivf -new $mp4file 2> /dev/null
crypto_test_file "vp9"


