test_begin "ac4-package"

if [ $test_skip != 1 ] ; then

# prepare source mp4 with ac4 track
mp4file="$TEMP_DIR/ac4.mp4"

do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/import/atsc3_test_audio.ac4 -new $mp4file" "Import"

#do dash ondemand profile test
do_test "$MP4BOX -dash 4000 -profile onDemand -out $TEMP_DIR/test.mpd:dual $mp4file" "DASH-HLS"

do_hash_test "$TEMP_DIR/test.mpd" "dash-mpd"
do_hash_test "$TEMP_DIR/test.m3u8" "hls-m3u8"
do_hash_test "$TEMP_DIR/test_1.m3u8" "hls-m3u8-variant"
do_hash_test "$TEMP_DIR/ac4_dashinit.mp4" "dash-init"

# do CENC test
cryptfile="$TEMP_DIR/ac4-crypted.mp4"
decryptfile="$TEMP_DIR/ac4-decrypted.mp4"
cryptconfig="$MEDIA_DIR/encryption/cbcs_const.xml"

do_test "$MP4BOX -crypt $cryptconfig -out $cryptfile $mp4file" "Encrypt"
do_hash_test $cryptfile "crypt"

do_test "$MP4BOX -decrypt $cryptconfig -out $decryptfile $cryptfile" "Decrypt"
do_hash_test $decryptfile "decrypt"

#compare hashes of source and decrypted
do_compare_file_hashes $mp4file $decryptfile
rv=$?

if [ $rv != 0 ] ; then
result="Hash is not the same between source content and decrypted content"
fi

#do MP4Box -info
do_test "$MP4BOX -info $cryptfile" "Info-encrypted"

#do dash test live profile on encrypted
do_test "$MP4BOX -dash 4000 -profile live -out $TEMP_DIR/test_cenc.mpd:dual $cryptfile" "DASH-HLS-encrypted"

do_hash_test "$TEMP_DIR/test_cenc.mpd" "dash-mpd-encrypted"
do_hash_test "$TEMP_DIR/test_cenc.m3u8" "hls-m3u8-encrypted"
do_hash_test "$TEMP_DIR/test_cenc_1.m3u8" "hls-m3u8-variant-encrypted"
do_hash_test "$TEMP_DIR/ac4-crypted_dashinit.mp4" "dash-init-encrypted"
do_hash_test "$TEMP_DIR/ac4-crypted_dash1.m4s" "dash-seg-encrypted"


fi
test_end
