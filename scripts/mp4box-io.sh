hint_test ()
{
 tempfile=$1'.tmp'
 hintfile=$1'.hint'
 hintdump=$1'.xml'
 #hint media
 do_test "$MP4BOX -hint $1 -out $hintfile" "RTPHint"
if [ $do_hash != 0 ] ; then
 do_hash_test $hintfile "hint"
fi

#echo "test $1"
do_sdp_dump=0

case $1 in
*english*mp3* )
 do_sdp_dump=1;;
esac


if [ $do_sdp_dump != 0 ] ; then
 #check SDP+RTP packets
 do_test "$MP4BOX -drtp $hintfile -out $tempfile" "RTPDump"
 if [ $do_hash != 0 ] ; then
  do_hash_test "$tempfile" "drtp"
 fi
 #check SDP dump from isom
 do_test "$MP4BOX -sdp $hintfile -out $tempfile" "SDPDump"
 if [ $do_hash != 0 ] ; then
  do_hash_test "$tempfile" "sdp"
 fi
 do_test "$MP4BOX -info 65536 $hintfile" "HintInfo"
fi


#unhint media
do_test "$MP4BOX -unhint $hintfile" "RTPUnhint"
if [ $do_hash != 0 ] ; then
 do_hash_test $hintfile "unhint"
fi
}

#@mp4_test execute basics MP4Box tests on source file: -add, -info, -dts, -hint -drtp -sdp -unhint and MP4 Playback
mp4_test ()
{
 do_hint=1
 do_hash=1
 do_dnal=0
 no_btrt=0

 #ignore xlst & others, no hinting for images
 case $1 in
 *.xslt )
  return ;;
 *.ttxt )
  return ;;
 *.opus )
  do_dnal=1
  do_hint=0;;
 *.html* )
  return ;;
 *.xml* )
  return ;;
 *.bt )
  return ;;
 *.wrl )
  return ;;
 #only check the logo.png
 */logo.jpg )
  return ;;
 # mkv not supported in < 0.9.0
 *.mkv )
  return ;;
 *.ssa )
  return ;;
 *.jpg )
  do_hint=0 ;;
 *.jpeg )
  do_hint=0 ;;
 *.jp2 )
  do_hint=0 ;;
 *.mj2 )
  do_hint=0 ;;
 *.av1 )
  do_dnal=1
  do_hint=0
  ;;
 *.obu )
  do_dnal=1
  do_hint=0
  ;;
 *enstvid.ivf )
  do_hint=0 ;;
 *counter_1280_720_I_25_500k.ivf )
  do_hint=0 ;;
 *vp80-00-comprehensive-017.ivf )
  do_hint=0 ;;
 *.ivf )
  do_dnal=1
  do_hint=0
  ;;
 *.png )
  do_hint=0 ;;
 *.flac )
  do_hint=0 ;;
 *.mlp )
  do_hint=0 ;;

 *109.avi )
  do_hash=0
  no_btrt=1 ;;
  #mpg, ogg and avi import is broken in master, disable hash until we move to filters
 *.mpg | *.ogg | *.avi)
  do_hash=0 ;;
 *svc* )
  do_dnal=1;;
 *.avc | *.264 | *.h264 | *.hevc | *.hvc | *.265 | *.h265 | *.266 | *.h266 | *.vvc )
  do_dnal=1;;
 #no support for hinting or playback yet
 *.ismt )
  do_hint=0 ;;
 *.mhas )
  do_hint=0 ;;
 *.ac3 )
  do_hint=0 ;;
 *.eac3 )
  do_hint=0 ;;
 *.amr )
  no_btrt=1 ;;
 *.iamf )
  do_hint=0 ;;
 esac

 name=$(basename $1)
 test_begin "mp4box-io-$name"

 mp4file="$TEMP_DIR/$name.mp4"
 nalfile="$TEMP_DIR/nal.xml"
 tmp1="$TEMP_DIR/$name.1.tmp"
 tmp2="$TEMP_DIR/$name.2.tmp"

 if [ $test_skip  = 1 ] ; then
  return
 fi

 #test media
 do_test "$MP4BOX -info $1" "RawMediaInfo"
 #import media
 do_test "$MP4BOX -add $1 -new $mp4file" "MediaImport"

 if [ $do_hash != 0 ] ; then
  do_hash_test $mp4file "add"
 fi

 if [ $do_dnal != 0 ] ; then
  do_test "$MP4BOX -dnal 1 $mp4file -out $nalfile" "NALDump"
  do_hash_test $nalfile "NALDump"
 fi


 #all the tests below are run in parallel

 #test info - no hash on this one we usually change it a lot
 do_test "$MP4BOX -info $mp4file" "MediaInfo" &

 #test -diso
 do_test "$MP4BOX -diso $mp4file -out $tmp1" "XMLDump"
if [ $do_hash != 0 ] ; then
 do_hash_test $tmp1 "diso"
fi
 rm $tmp1 2> /dev/null &

 #test dts
 do_test "$MP4BOX -dts $mp4file -out $tmp2" "MediaTime"
if [ $do_hash != 0 ] ; then
 do_hash_test $tmp2 "dts"
fi
 rm $tmp2 2> /dev/null &


 if [ $do_hint != 0 ] ; then
  hint_test $mp4file &
 fi

 #also test the isobmf demuxer
 insopts=""
 if [ $no_btrt != 0 ] ; then
 insopts=":nobr"
 fi

 do_test "$GPAC -i $mp4file inspect$insopts:deep:dur=1:log=$TEMP_DIR/inspect.txt" "mp4-inspect"
 do_hash_test $TEMP_DIR/inspect.txt "mp4-inspect"

 test_end
}


mp4box_tests ()
{
 for src in $MEDIA_DIR/auxiliary_files/* ; do
  mp4_test $src
 done

 if [ $EXTERNAL_MEDIA_AVAILABLE = 0 ] ; then
  return
 fi

 for src in $EXTERNAL_MEDIA_DIR/import/* ; do
  mp4_test $src
 done

  mp4_test $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.ac3

  mp4_test $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.eac3

  mp4_test $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.mhas

  mp4_test $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.usac

  mp4_test $EXTERNAL_MEDIA_DIR/counter/counter_30s_1280x720p_I25_closedGOP_512kpbs.vvc


}

mp4box_tests

#mp4_test "auxiliary_files/enst_audio.aac"
#mp4_test $MEDIA_DIR/import/speedway.mj2

