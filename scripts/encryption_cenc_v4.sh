#!/bin/sh

# Check CENC v4 new feature flags and sample encryption signaling (https://github.com/gpac/gpac/pull/3562)
cenc_v4_test()
{
 test_begin "encryption-cenc-v4-$1"
 if [ "$test_skip" = 1 ]; then
  return
 fi

 src="$TEMP_DIR/cenc-v4-source.mp4"
 enc="$TEMP_DIR/cenc-v4-encrypted.mp4"
 dec="$TEMP_DIR/cenc-v4-decrypted.mp4"
 clear_raw="$TEMP_DIR/cenc-v4-clear.264"
 dec_raw="$TEMP_DIR/cenc-v4-decrypted.264"

 do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264:dur=2 -new $src" "import"
 do_test "$GPAC -i $src cecrypt:cfile=$MEDIA_DIR/encryption/$2 -o $enc:$3" "encrypt"
 do_hash_test "$enc" "encrypted"
 do_test "$MP4BOX -diso $enc" "dump"
 do_test "awk -v tenc=$4 -v senc_version=$5 -v senc_flags=$6 -v seig=$7 -f $RULES_DIR/cenc_v4_check.awk $TEMP_DIR/cenc-v4-encrypted_info.xml" "signaling"
 do_test "$MP4BOX -decrypt $enc -out $dec" "decrypt"
 do_hash_test "$dec" "decrypted"
 do_test "$MP4BOX -raw 1 $src -out $clear_raw" "extract-clear"
 do_hash_test "$clear_raw" "clear-samples"
 do_test "$MP4BOX -raw 1 $dec -out $dec_raw" "extract-decrypted"
 do_hash_test "$dec_raw" "decrypted-samples"
 do_test "cmp $clear_raw $dec_raw" "compare-samples"
 test_end
}

# Flag values cover subsamples, multiple keys, SENC/SAI, seig and slice headers.
# The control cases exercise legacy output when the options are disabled.
cenc_v4_test "legacy" ctr.xml "tenc_flags=false" 000000 0 2 no
cenc_v4_test "single" ctr.xml "tenc_flags" 000A59 0 2 no
cenc_v4_test "force-seig" ctr.xml "tenc_flags:force_seig" 000959 0 2 yes
cenc_v4_test "selective-legacy" ctr_rap.xml "tenc_flags:senc_v2=false" 000959 0 2 yes
cenc_v4_test "selective" ctr_rap.xml "tenc_flags:senc_v2" 000959 2 0 yes
cenc_v4_test "multikey-legacy" mkey_base.xml "tenc_flags:senc_v2=false" 000955 1 2 yes
cenc_v4_test "multikey" mkey_base.xml "tenc_flags:senc_v2" 000955 1 0 yes
cenc_v4_test "fragmented-force-seig" ctr.xml "frag:tenc_flags:force_seig" 000959 0 2 yes
cenc_v4_test "fragmented-selective" ctr_rap.xml "frag:tenc_flags:senc_v2" 000A59 2 0 yes
cenc_v4_test "fragmented-multikey" mkey_base.xml "frag:tenc_flags:senc_v2" 000955 1 0 yes
