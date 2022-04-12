#check if we have libavformat support
ffmx=`$GPAC -h ffmx 2>/dev/null | grep ffmx`

txt_conv_test()
{
 test_begin "txtconv-$1"

 if [ $test_skip  = 1 ] ; then
  return
 fi

conf_fmts="srt ttxt vtt ttml"

for fmt in $conf_fmts ; do

 if [ "$1" == "$fmt" ] ; then
  continue
 fi

 txtfile="$TEMP_DIR/conv.$fmt"
 do_test "$GPAC -i $2 -o $txtfile" "$fmt"
 do_hash_test $txtfile "$fmt"

done

if [ -n "$ffmx" ] ; then
 dstfile="$TEMP_DIR/conv.mkv"
 do_test "$GPAC -i $2 -o $dstfile" "mkv"
 #not bit-exact across platforms, use inspect only
 #do_hash_test $dstfile "mkv"

 myinspect="$TEMP_DIR/inspect.txt"
 do_test "$GPAC -no-reassign=no -i $dstfile inspect:deep:log=$myinspect" "mkv-inspect"
 do_hash_test $myinspect "mkv-inspect"
fi


 test_end
}


#test srt
txt_conv_test "srt" $MEDIA_DIR/auxiliary_files/subtitle.srt

#test ssa
txt_conv_test "ssa" $MEDIA_DIR/auxiliary_files/subtitle.ssa

#test ttxt
txt_conv_test "ttxt" $MEDIA_DIR/auxiliary_files/subtitle.ttxt

#test ttxt
txt_conv_test "tx3g" $MEDIA_DIR/auxiliary_files/subtitle.srt

#test webvtt
txt_conv_test "vtt" $MEDIA_DIR/webvtt/simple.vtt

#test ttml
txt_conv_test "ttml" $MEDIA_DIR/ttml/ttml_samples.ttml
