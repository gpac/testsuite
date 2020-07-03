import * as evg from 'evg'

/*
Specify this script to control from JS the session (path can be absolute or relative):
gpac -js=path/to/sess.js

Combined with rmt:
gpac -js=sess.js -rmt [your args]
*/
print("Hello GPAC !");

session.set_rmt_fun( (text)=> {
	print("rmt says " + text);
	session.rmt_send("yep !");
});

session.rmt_send("Loaded !");

session.prompt_input();
session.prompt_string(1);

let i=0;
for (i=1; i < args.length; i++) {
	if (args[i].startsWith("-f=") ) {
		let f = session.add_filter(args[i].substring(3));
		f.iname = 'f'+i;
		continue;
	}
}

let check_remove = 0;

let nb_called = 0;
//post a task to print status every second
session.post_task( ()=> {
 let all_connected = true;
  let remove_f = null;

 if (session.last_task) {
    print("we are done ");
    session.abort();
 	return false;
 }

 session.lock_filters(true);

 let count = session.nb_filters;
 print("Number of filters: " + count);

 let i;
 for (i=0; i<session.nb_filters; i++) {
 	let f = session.get_filter(i);
 	print("# f.name: " + f.name);
 	for(let propertyName in f) {
 		print("f." + propertyName + " : " + f[propertyName]);
 	}

/*
 	print("f.ID: " + f.ID);
 	print("f.type: " + f.type);
 	print("f.nb_in: " + f.nb_ipid);
 	print("f.nb_out: " + f.nb_opid);
 	print("f.status: " + f.status);
 	print("f.alias: " + f.alias);
 	print("f.dyn: " + f.dynamic);
 	print("f.args: " + f.args);
 	print("f.done: " + f.done);
 	print("f.pck_done: " + f.pck_done);
 	print("f.bytes_done: " + f.bytes_done);
 	print("f.time: " + f.time);
 	print("f.pck_sent: " + f.pck_sent);
 	print("f.pck_ifce_sent: " + f.pck_ifce_sent);
 	print("f.bytes_sent: " + f.bytes_sent);
 	print("f.class: " + f.class);
 	print("f.codec: " + f.codec);
 	print("f.streamtype: " + f.streamtype);
*/


 	if (f.nb_ipid) {
 		f.ipid_props(0, (name, type, val) => { print('ipid prop ' + name + ' type ' + type + ' val ' + val);})
 		print("source for pid is filter " + f.ipid_source(0).name);
 	}
 	if (f.nb_opid) f.opid_props(0, (name, type, val) => { print('opid prop ' + name + ' type ' + type + ' val ' + val);})

	if (!f.nb_opid && !f.nb_ipid) all_connected = false;


 	if (f.nb_ipid) {
 		print("source for pid is filter " + f.ipid_source(0).name);
		if (!f.nb_opid) {
			f.update("deep", "true");
	
			check_remove++;
			if (check_remove==1) {
				remove_f = f;
			}
		}
 	}


 	//get filter args and dump as JSON
 	let args = f.all_args();
 	print("" + args.length + " arguments: " + JSON.stringify(args) );
 	print("");

 	if (!f.nb_opid) {
//		f.update("vsync", "false");
//		if (nb_called==8) f.remove();
	} else {
		if (nb_called==1) {
//			f.insert("inspect:deep");
		}
	}
 } 

 if (remove_f) {
 	let f = remove_f.ipid_source(0);
 	print("will insert after " + f.name);
 	remove_f.remove();
 	f.insert("inspect");
 }


 session.lock_filters(false);
 nb_called++;
 return all_connected ? 1000 : 0;
});


