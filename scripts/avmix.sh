avmix_test()
{
name=$(basename $1)
name=${name%%.*}

test_begin "avmix-$name"

if [ $test_skip  = 1 ] ; then
 return
fi

ins_ext=""
case $1 in
#for live tests using ports, i.e. fork(), we cannot guarantee the time between fork and first frame received nor the speed of transfer
# which might result in late frames hence not the same visual output
# we therefore generate the inspect with no crc
 *live_port_* )
  ins_ext=":test=nocrc";;
#live_start depends on loading speed time of source, we may have one or two extra frames before the source is loaded, so inspect with no crc
 *live_start* )
  ins_ext=":test=nocrc";;
esac

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -blacklist=vtbdec,nvdec,ohevcdec,osvcdec -font-dirs=$EXTERNAL_MEDIA_DIR/fonts/ -rescan-fonts avmix:pl=$1 inspect:deep:interleave=0$ins_ext:log=$myinspect" "run"

do_hash_test $myinspect "run"

do_play_test "play" "avmix:pl=$1" ""

test_end
}

for i in $MEDIA_DIR/avmix/*.json ; do
avmix_test $i
done

