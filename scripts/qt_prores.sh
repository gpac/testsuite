
#@mp4_test execute basics MP4Box tests on source file: -add, -info, -dts, -hint -drtp -sdp -unhint and MP4 Playback
qt_prores_test ()
{

 name=$(basename $1)
 test_begin "qt-prores-$name"

 if [ $test_skip  = 1 ] ; then
  return
 fi
 mp4file="$TEMP_DIR/$name.mp4"
 mp4edit="$TEMP_DIR/qtedit.mp4"

 #test media
 do_test "$MP4BOX -info $1" "RawMediaInfo"

 myinspect=$TEMP_DIR/inspect.txt
 do_test "$GPAC -i $1 inspect:allp:deep:interleave=false:log=$myinspect -graph -stats"
 do_hash_test $myinspect "inspect"


 #import media
 do_test "$MP4BOX -add $1:asemode=v1-qt -no-iod -new $mp4file" "MediaImport"
 do_hash_test $mp4file "add"

 #remove media track media
 do_test "$MP4BOX -rem 1 $mp4file -out $mp4edit" "MediaEdit"
 do_hash_test $mp4edit "rem"

 #import media as mov, force bit depth to 32 and set color profile
 movfile="$TEMP_DIR/$name.mov"
 do_test "$MP4BOX -add $1:bitdepth=32:colr=nclc,1,1,1 -new $movfile" "MediaImportMoov"
 do_hash_test $movfile "addmov"

 #dump prores media
 prores="$TEMP_DIR/$name.prores"
 do_test "$MP4BOX -raw 1 $1 -out $prores" "ProResExport"
 do_hash_test $prores "export"

 #add prores media
 movfile="$TEMP_DIR/test.mov"
 do_test "$MP4BOX -add $prores -new $movfile" "ProResImport"
 do_hash_test $movfile "import"

 #add prores with rewind
 movfile="$TEMP_DIR/test2.mov"
 do_test "$GPAC -i $prores -o $movfile:speed=-1" "ProResRewindImport"
 do_hash_test $movfile "rewind_import"

 #test -dnal
 dmpfile="$TEMP_DIR/test.xml"
 do_test "$MP4BOX -dnal 1 $1 -out $dmpfile" "ProResInspect"
 do_hash_test $dmpfile "inspectDNAL"


 test_end
}



for src in $EXTERNAL_MEDIA_DIR/qt_prores/* ; do
 qt_prores_test $src
done


