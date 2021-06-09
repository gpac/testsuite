import * as evg from 'evg'
import { Sys as sys } from 'gpaccore'
import * as os from 'os'

/*
tests os.exec() and workers - inspired from QuickJS worker test
*/
print("Hello GPAC !");

let pid = 0;
let worker_done = 0;
let retry = 0;

session.set_event_fun( (evt) => {
	if (evt.type != GF_FEVT_USER) return 0;
	print("evt " + evt.name);
});


let check_remove = 0;

let nb_called = 0;
//post a task to print status every second
session.post_task( ()=> {
 let all_connected = true;
  let remove_f = null;

 if (!pid && worker_done && session.last_task) {
    print("we are done ");
 	return false;
 }
 if (pid) {
    //wait in non-blocking mode
	let res = os.waitpid(pid, os.WNOHANG);
	print('PID ' + pid + ' wait result ' + res);
	if (res[0] == pid) {
		print('child process dead');
		pid = 0;
	}
    //kill
	retry++;
	if (retry==6) {
		print('killing process');
		os.kill(pid, os.SIGTERM);
	}
 }
 if (!worker_done)
		print('waiting end of worker');

 return 200;
});



pid = os.exec(["gpac", "-i", "avgen", "inspect:deep"], {block: false});

var worker;

function assert(actual, expected, message) {
    if (arguments.length == 1)
        expected = true;

    if (actual === expected)
        return;

    if (actual !== null && expected !== null
    &&  typeof actual == 'object' && typeof expected == 'object'
    &&  actual.toString() === expected.toString())
        return;

    throw Error("assertion failed: got |" + actual + "|" +
                ", expected |" + expected + "|" +
                (message ? " (" + message + ")" : ""));
}


function test_worker()
{
    var counter;

    worker = new os.Worker("./worker_module.js");

    counter = 0;
    worker.onmessage = function (e) {
        var ev = e.data;
        print("recv", JSON.stringify(ev));
        switch(ev.type) {
        case "num":
            assert(ev.num, counter);
            counter++;
            if (counter == 10) {
                /* test SharedArrayBuffer modification */
                let sab = new SharedArrayBuffer(10);
                let buf = new Uint8Array(sab);
                worker.postMessage({ type: "sab", buf: buf });
            }
            break;
        case "sab_done":
            {
                let buf = ev.buf;
                /* check that the SharedArrayBuffer was modified */
                assert(buf[2], 10);
                worker.postMessage({ type: "abort" });
            }
            break;
        case "done":
            /* terminate */
            worker.onmessage = null;
            worker_done = true;
            print('worker done')
            break;
        }
    };
}


test_worker();
