test_prft()
{
  test_begin "prft-$1"

  if [ "$test_skip" = 1 ] ; then
    return
  fi

  mp4file="$TEMP_DIR/out.mp4"

  do_test "$GPAC -i $MEDIA_DIR/xmlin4/nhml_ntp.nhml mp4mx:frag:$2 @ -o $mp4file" "prft"
  do_hash_test $mp4file "prft"

  test_end
}

#test prft box addition
test_prft "avc" "prft=sender"
test_prft "both-avc" "prft=both"
