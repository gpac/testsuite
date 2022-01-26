

iff_crypto_test()
{

test_begin "iff-crypt-$1"

if [ $test_skip  = 1 ] ; then
 return
fi

#cleanup everything in case we don't run with temp dir, otherwise we will get errors renaming files in -crypt
rm -f $TEMP_DIR/* 2> /dev/null
 
mp4="$TEMP_DIR/vid_cryp.mp4"
iff="$TEMP_DIR/img_src.heif"
decryp="$TEMP_DIR/img_decryp.heif"
recryp="$TEMP_DIR/img_recryp.heif"

#we could import only a single frame, but this tests import of cenc info (especially senc in selective modes) as well
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264 -crypt $2 -new $mp4" "make_src_crypt"
do_hash_test $mp4 "crypt-vid"

do_test "$MP4BOX -add-image $mp4:time=6 -new $iff" "add_crypted_img"
do_hash_test $iff "add_crypted_img"

#test filter decrypt / recrypt of items (throught MP4Box here, but the same would work with gpac -i SRC decrypt @ -o DST)
do_test "$MP4BOX -decrypt $2 $iff -out $decryp" "decrypt_imf"
do_hash_test $decryp "decrypt_imf"

#test filter decrypt / recrypt of items (throught MP4Box here, but the same would work with gpac -i SRC decrypt @ -o DST)
do_test "$MP4BOX -crypt $2 $decryp -out $recryp" "recrypt_imf"
do_hash_test $recryp "recrypt_imf"

#test -diso on encrypted items
do_test "$MP4BOX -diso $recryp" "diso"
do_hash_test $TEMP_DIR/img_recryp_info.xml "diso"


test_end

}

iff_crypto_all()
{

for drm in $MEDIA_DIR/encryption/*.xml ; do

case $drm in
*cbcs_const_roll* )
  continue ;;
*adobe* )
  continue ;;
*isma* )
  continue ;;
*clearbytes* )
  continue ;;
*forceclear* )
  continue ;;
*clear_stsd* )
  continue ;;
*piff* )
  continue ;;
*roll* )
  continue ;;
*rap* )
  continue ;;
*mkey* )
  continue ;;
*subs* )
  continue ;;
*hls_saes* )
  continue ;;
*tpl_* )
  continue ;;
esac

name=$(basename $drm)
name=${name%%.*}

iff_crypto_test "$name" $drm

done

}

iff_crypto_all

#iff_crypto_test "test" $MEDIA_DIR/encryption/ctr.xml


