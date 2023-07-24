

test_codec_skip()
{
test_begin "skip-codec"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc c=hevc:ccp:b=1m -o $TEMP_DIR/encode.mp4 -graph" "Encode"
do_hash_test "$TEMP_DIR/encode.mp4" "Encode"

test_end
}

test_codec_skip

test_crypt_skip()
{
test_begin "skip-encrypt"
if [ $test_skip = 1 ] ; then
 return
fi

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc  -i $MEDIA_DIR/auxiliary_files/enst_audio.aac cecrypt:cfile=$MEDIA_DIR/encryption/ctr.xml:ccp=hevc -o $TEMP_DIR/encrypt.mp4 -graph" "Encrypt"
do_hash_test "$TEMP_DIR/encrypt.mp4" "Encrypt"

test_end
}

test_crypt_skip

