#!/bin/sh

if ! command -v websocat >/dev/null 2>&1
then
    echo "websocat absent, not running rmtws tests"
    return
fi



test_begin "rmtws-js"

if [ $test_skip  = 1 ] ; then
	return
fi

do_test "$GPAC -js=$MEDIA_DIR/rmtws/mirror.js  -logs=rmtws@info  avgen reframer:rt=on inspect:deep" "rmtws-js-gpac" &
sleep .5

WSINPUT="JAVASCRIPT"

MIRROR="$( echo $WSINPUT | websocat ws://localhost:6363 )"

if [  "$MIRROR" != "$WSINPUT" ]; then
    result="mirror failed - received $MIRROR"
fi

test_end
