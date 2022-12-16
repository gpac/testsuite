ttxt_test()
{
 test_begin "ttxtdec-$1"

 if [ $test_skip  = 1 ] ; then
  return
 fi

 srcfile=$2

 if [ $3 == 1 ] ; then
 srcfile=$TEMP_DIR/test.mp4
 $MP4BOX -add $2 -new $srcfile 2> /dev/null
 fi

 dump=$TEMP_DIR/dump.rgb

 #test source parsing and playback
 do_test "$GPAC -font-dirs=$EXTERNAL_MEDIA_DIR/fonts/ -rescan-fonts -i $srcfile compositor:osize=512x128:vfr @ -o $dump -graph" "srcplay"
 #don't hash content on 32 bits, fp precision leads to different results
 if [ $GPAC_OSTYPE != "lin32" ] ; then
  do_hash_test $dump "srcplay"
 fi

 do_play_test "dump" "$dump:size=512x128"

 test_end
}


#test srt
ttxt_test "srt" $MEDIA_DIR/auxiliary_files/subtitle.srt 0

#test ttxt
ttxt_test "ttxt" $MEDIA_DIR/auxiliary_files/subtitle.ttxt 0

#test ttxt
ttxt_test "tx3g" $MEDIA_DIR/auxiliary_files/subtitle.srt 1

#test webvtt
ttxt_test "vtt" $MEDIA_DIR/webvtt/simple.vtt:fontSize=80:color=cyan 0

#test ttml
ttxt_test "ttml" $MEDIA_DIR/ttml/ttml_samples.ttml 0

#test simple text
ttxt_test "stxt" "null:pck=HelloWorld:#CodecID=stxt" 0
#test simple text with tx3g output
ttxt_test "stxt-tx3g" "null:pck=HelloWorld:#CodecID=stxt:stxtmod=tx3g:stxtdur=2" 0
#test simple text with webvtt output
ttxt_test "stxt-vtt" "null:pck=HelloWorld:#CodecID=stxt:stxtmod=vtt:fontSize=80:color=cyan" 0


ttxt_clipframe()
{
 test_begin "ttxt-clip"

 if [ $test_skip  = 1 ] ; then
  return
 fi

 srcfile=$MEDIA_DIR/auxiliary_files/subtitle.srt
 dump=$TEMP_DIR/'dump_$Timescale$_$cts$_$dur$_$CropOrigin$_$OriginalSize$.png'

 #test srt->png dump using clipframe (compositor output clipped to visual bounds) and packet props in pid template
 #we don't load the compositor explicitly here, just set a default output size (for text rendering) and clipframe on output png
 do_test "$GPAC -font-dirs=$EXTERNAL_MEDIA_DIR/fonts/ -rescan-fonts -i $srcfile -o $dump:osize=hd:timescale=1000:clipframe" "dump"
 #don't hash content on 32 bits, fp precision leads to different results
 if [ $GPAC_OSTYPE != "lin32" ] ; then
  do_hash_test "$TEMP_DIR/dump_1000_5986_433_906x1059_1920x1080.png" "dump"
 fi

 test_end
}

ttxt_clipframe
