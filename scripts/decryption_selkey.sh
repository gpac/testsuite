#!/bin/sh

#test encryption and decryption of init segement and segment files
test_begin "decryption-selkey"
if [ $test_skip  = 1 ] ; then
 return
fi

src1="$TEMP_DIR/src1.mp4"
src2="$TEMP_DIR/src2.mp4"
mpdfile="$TEMP_DIR/dash/file.mpd"

#crypt src1
cfile="$TEMP_DIR/drm.xml"
echo '<?xml version="1.0" encoding="UTF-8" />
<GPACDRM type="CENC AES-CTR">
<CrypTrack IV_size="16" first_IV="0x0a610676cb88f302d10ac8bc66e039ed">
<key KID="0x279926496a7f5d25da69f2b3b2799a7f" value="0x5544694d47473326622665665a396b36"/>
</CrypTrack>
</GPACDRM>' > $cfile

do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_640x360_192kbps.264:dur=10 -crypt $cfile -new $src1" "crypt1"
do_hash_test "$src1" "cryp1"

#crypt src2 with SAME KID but different key value
echo '<?xml version="1.0" encoding="UTF-8" />
<GPACDRM type="CENC AES-CTR">
<CrypTrack IV_size="16" first_IV="0x0a610676cb88f302d10ac8bc66e039ed">
<key KID="0x279926496a7f5d25da69f2b3b2799a7f" value="0x5544694d47473326622665665a396b37"/>
</CrypTrack>
</GPACDRM>' > $cfile

do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_640x360_192kbps.264:dur=10 -crypt $cfile -new $src2" "crypt2"
do_hash_test "$src2" "cryp2"

#create a DRML.xml file for both keys with selection based on representation ID
echo '<?xml version="1.0" encoding="UTF-8" />
<GPACDRM type="CENC AES-CTR">
<CrypTrack>
<key KID="0x279926496a7f5d25da69f2b3b2799a7f" value="0x5544694d47473326622665665a396b36" rep="1"/>
<key KID="0x279926496a7f5d25da69f2b3b2799a7f" value="0x5544694d47473326622665665a396b37" rep="2"/>
</CrypTrack>
</GPACDRM>' > $cfile

do_test "$GPAC -i $src1 -i $src2 -o $mpdfile" "dash"

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -old-arch=0 --cfile=$cfile -i $mpdfile --auto_switch=1 inspect:deep:log=$myinspect" "inspect"
do_hash_test "$myinspect" "inspect"



test_end
