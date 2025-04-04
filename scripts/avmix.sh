avmix_test()
{
name=$(basename $1)
name=${name%%.*}

test_begin "avmix-$name$2"

if [ $test_skip  = 1 ] ; then
 return
fi

skip_hash=0
is_gpu=0
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
 *gpu* )
  is_gpu=1;;
 *group_cam* )
  skip_hash=1;;
 *group_seq* )
  skip_hash=1;;
 *pl_reload_timer* )
  skip_hash=1;;
 *script* )
  skip_hash=1;;
 *seq_v_persp* )
  skip_hash=1;;
 *timer* )
  skip_hash=1;;
 *seq_av_swipe* )
  skip_hash=1;;
 *seq_mix* )
  skip_hash=1;;
 *seq_replace_a* )
  skip_hash=1;;
esac

#don't hash these on lin32, float precision is not exactly the same
if [ $GPAC_OSTYPE != "lin32" ] ; then
	skip_hash=0
fi


case $1 in
 #don't hash audio only, we don't have guarantee that frames will be of the same length
 *audio_only* )
  skip_hash=1;;

 *frame_alloc* | *seq_av_simple* | *seq_av_swipe* | *seq_av_xfade* | *group_seq* | *pl_reload_timer* | *script* | *seq_v_persp* | *seq_v_persp_wide* | *timer* )
  if [ $GPAC_CPU = "arm" ] ; then
    skip_hash=1
  fi
  ;;
esac

if [ $is_gpu = 0 ] ; then

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -blacklist=vtbdec,nvdec,ohevcdec,osvcdec,maddec,faad -font-dirs=$EXTERNAL_MEDIA_DIR/fonts/ -rescan-fonts avmix:pl=$1$3 inspect:deep:interleave=0$ins_ext:log=$myinspect" "run"

if [ $skip_hash != 1 ] ; then
do_hash_test $myinspect "run"
fi


else

dump=$TEMP_DIR/dump.rgb
do_test "$GPAC -blacklist=vtbdec,nvdec,ohevcdec,osvcdec -font-dirs=$EXTERNAL_MEDIA_DIR/fonts/ -rescan-fonts avmix:pl=$1 -o $dump" "run"
if [ ! -f $dump ] ; then
  result="no output"
fi



fi


do_play_test "play" "avmix:pl=$1" ""

test_end
}

for i in $MEDIA_DIR/avmix/*.json ; do
avmix_test $i "" ""
done


#audio tests
avmix_test $MEDIA_DIR/avmix/audio_only.json "-s32" ":afmt=s32"
avmix_test $MEDIA_DIR/avmix/audio_only.json "-flt" ":afmt=flt"
avmix_test $MEDIA_DIR/avmix/audio_only.json "-dbl" ":afmt=dbl"
