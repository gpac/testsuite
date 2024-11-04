
pyth=""
if [ -x "$(command -v python3)" ]; then
pyth="python3"
elif [ -x "$(command -v Python3)" ]; then
pyth="Python3"
elif [ -x "$(command -v python)" ]; then
pyth="python"
elif [ -x "$(command -v Python)" ]; then
pyth="Python"
fi

if [ $platform = "Darwin" ]  && [ -x "$(command -v python3.9)" ] ; then
pyth="python3.9"
fi

if [ -z $pyth ] ; then
echo "Python not available!"
return
fi

py_test()
{
 name=$(basename $1)
 name=${name%.*}

 test_begin "python-$name"
 if [ $test_skip  = 1 ] ; then
  return
 fi

 testfile=temp_$name.py
 rm $testfile 2> /dev/null
 #inject path to our libgpac.py, it is not installed as system or user module
 echo "import sys" > $testfile
 echo "sys.path.append('$path/share/python')" >> $testfile
 #append test file
 echo "" >> $testfile
 cat $1 >> $testfile

 do_test "$pyth $testfile" "run"

if [ "$name" == "fileio" ] ; then

if [ -d $LOCAL_OUT_DIR/temp/py_fileio ] ; then

do_hash_test $LOCAL_OUT_DIR/temp/py_fileio/inspect-sf.txt "read"
do_hash_test $LOCAL_OUT_DIR/temp/py_fileio/record.mp4 "record"
do_hash_test $LOCAL_OUT_DIR/temp/py_fileio/dash/live.mpd "dash-mpd"
do_hash_test $LOCAL_OUT_DIR/temp/py_fileio/dash/counter_dashinit.mp4 "dash-init"
do_hash_test $LOCAL_OUT_DIR/temp/py_fileio/dash/counter_dash8.m4s "dash-seg8"
do_hash_test $LOCAL_OUT_DIR/temp/py_fileio/inspect-dash.txt "read-dash"

else
echo "NumPy not present, skipping hashes"
fi

fi

mv $testfile $TEMP_DIR/

test_end
}


#extract GPAC root, assuming we are checked out as submodule of root repo
cur_path=`pwd`
cd $rel_main_dir
cd ..
path=`pwd`
if [[ $(uname -s) == "CYGWIN_NT"* ]] && [ -x "$(command -v cygpath)" ]; then
	path="$(cygpath -m $path)"
fi
cd $cur_path

#test all python
for i in $MEDIA_DIR/python/*.py ; do
py_test $i
done
