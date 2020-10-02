
/*
Specify this script to control from JS the session (path can be absolute or relative):
gpac -js=path/to/sess.js

Combined with rmt:
gpac -js=sess.js -rmt [your args]
*/
print("Hello GPAC !");

let all_filters = [];

session.set_new_filter_fun( (f) => {
		print("new filter " + f.name);
		f.iname = f.name;
		all_filters.push(f);
} ); 

session.set_del_filter_fun( (f) => {
	print("delete filter " + f.iname);
	let idx = all_filters.indexOf(f);
	if (idx>=0)
		all_filters.splice (idx, 1);
}); 


let custom = session.new_filter("MyTest");
custom.set_cap({id: "StreamType", value: "Video", in: true} );
custom.pids=[];
custom.configure_pid = function(pid)
{
	if (this.pids.indexOf(pid)>=0)
		return;

	this.pids.push(pid);
	let evt = new FilterEvent(GF_FEVT_PLAY);
	evt.start_range = 0.0;
	print(evt.start_range);
	pid.send_event(evt);
	print(GF_LOG_INFO, "PID" + pid.name + " configured");
}

custom.process = function(pid)
{
	this.pids.forEach(function(pid) {
	while (1) {
		let pck = pid.get_packet();
		if (!pck) break;
		print(GF_LOG_INFO, "PID" + pid.name + " got packet DTS " + pck.dts + " CTS " + pck.cts + " SAP " + pck.sap + " size " + pck.size);
		pid.drop_packet();
	}
	});
}


session.set_event_fun( (evt) => {
print("evt " + evt.name);
});

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
 return all_connected ? 500 : 0;
});


