
pyth=""
if [ -x "$(command -v python)" ]; then
pyth="python"
elif [ -x "$(command -v Python)" ]; then
pyth="Python"
elif [ -x "$(command -v python3)" ]; then
pyth="python3"
elif [ -x "$(command -v Python3)" ]; then
pyth="Python3"
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

 rm $testfile 2> /dev/null

 test_end
}


#extract GPAC root, assuming we are checked out as submodule of root repo
cur_path=`pwd`
cd $rel_main_dir
cd ..
path=`pwd`
cd $cur_path

#test all bifs
for i in $MEDIA_DIR/python/*.py ; do
py_test $i
done
