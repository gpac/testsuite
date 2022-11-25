import * as evg from 'evg'
import { Sys as sys } from 'gpaccore'

/*
Specify this script to control from JS the session (path can be absolute or relative):
gpac -js=path/to/sess.js

Combined with rmt:
gpac -js=sess.js -rmt [your args]
*/
print("Hello GPAC !");

let all_filters = [];

session.reporting(true);

session.set_rmt_fun( (text)=> {
	print("rmt says " + text);
	session.rmt_send("yep !");
});

session.rmt_send("Loaded !");
session.rmt_sampling = false;

session.set_new_filter_fun( (f) => {
		print("new filter " + f.name);
		f.iname = "JS"+f.name;
		all_filters.push(f);
} ); 

session.set_del_filter_fun( (f) => {
	print("delete filter " + f.iname);
	let idx = all_filters.indexOf(f);
	if (idx>=0)
		all_filters.splice (idx, 1);
}); 

session.set_event_fun( (evt) => {
	if (evt.type != GF_FEVT_USER) return 0;
	print("evt " + evt.name);
});


let i=0;
for (i=1; i < sys.args.length; i++) {
	if (sys.args[i].startsWith("-f=") ) {
		let f = session.add_filter(sys.args[i].substring(3));
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
 	if (f.is_destroyed()) continue;
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
 	if (f.nb_opid) {
 		f.opid_props(0, (name, type, val) => { print('opid prop ' + name + ' type ' + type + ' val ' + val);})
 		print("num dest for pid " + f.opid_sinks(0).length);
 	}

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

	let f_evt = new FilterEvent(GF_FEVT_USER);
	f_evt.ui_type = GF_EVENT_SET_CAPTION;
	f_evt.caption = "removed + insert";
	session.fire_event(f_evt);
 }
 //test args fetching on registry name
 print('vout args: ' + JSON.stringify(session.filter_args('vout') ) );
 print('ffenc args: ' + JSON.stringify(session.filter_args('ffenc:c=avc') ) );

 all_filters.forEach (f => {
 	if (!f.nb_opid) return;
	 print('Chain from ' + f.name + ' to PNG dump: ' + JSON.stringify(f.compute_link(0, 'dst=dump.png', true)) );
 });
 

 session.lock_filters(false);
 nb_called++;
 return all_connected ? 1000 : 0;
});


