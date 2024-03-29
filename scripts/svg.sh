
svg_test()
{

 name=$(basename $1)
 name=${name%.*}
 do_hash=1
 uitest="svg-tests-ui.xml"

 #start our test, specifying all hash names we will check
 test_begin "svg-$name"
 if [ $test_skip  = 1 ] ; then
  return
 fi

 dump_size=192x192

nojs=":nojs"
waitfonts=""
 case $name in
 *video* )
  do_hash=0
  ;;
 *udomjs* )
  nojs=""
  ;;
 *animvalues* )
  nojs=""
  ;;
 *fonts-overview-201-t* )
  waitfonts="-wait-fonts"
  ;;
 *anchor* )
  nojs=""
  uitest="svg-tests-ui-anchor.xml"
  dump_size=480x360
  ;;
 esac

# hash do not work on linux due to rounding errors of floats -> different rasterization
if [ $GPAC_OSTYPE == "lin32" ] ; then
  do_hash=0
fi

 RGB_DUMP="$TEMP_DIR/dump.rgb"
 PCM_DUMP="$TEMP_DIR/dump.pcm"

 #for the time being we don't check hashes nor use same size/dur for our tests. We will redo the UI tests once finaizing filters branch
 dump_dur=5


 #note that we force using a GNU Free Font SANS to make sure we always use the same font on all platforms
do_test "$GPAC -font-dirs=$EXTERNAL_MEDIA_DIR/fonts/ -rescan-fonts -cfg=validator:mode=play -cfg=validator:trace=$RULES_DIR/$uitest -blacklist=vtbdec,nvdec -i $1 compositor$nojs:osize=$dump_size:vfr:dur=$dump_dur:asr=44100:ach=2$compopt @ -o $RGB_DUMP @1 -o $PCM_DUMP $waitfonts" "dump"

 v_args=""
 if [ -f $RGB_DUMP ] ; then

  if [ $do_hash = 1 ] ; then
   do_hash_test_bin "$RGB_DUMP" "dump"
  fi
  v_args="$RGB_DUMP:size=$dump_size"
 else
  result="no output"
 fi

 a_args=""
 if [ -f $PCM_DUMP ] ; then
  a_args="$PCM_DUMP:sr=44100:ch=2"
 fi

 do_play_test "$2-play" "$v_args" "$a_args"
stat_file=$TEMP_DIR/stats.xml
 do_test "$MP4BOX -nstat $1 -out $stat_file" "stats"


test_end

}


#test all bifs
for i in $MEDIA_DIR/svg/*.svg ; do
svg_test $i
done


