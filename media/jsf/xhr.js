import {XMLHttpRequest} from 'xhr'

filter.pids = [];

//metadata
filter.set_name("XHR");
filter.set_desc("JS XHR test");
filter.set_version("0.1beta");
filter.set_author("GPAC team");
filter.set_help("This filter provides a very simple javascript test for XHR");

filter.set_arg({name: "url", desc: "URL to get", type: GF_PROP_STRING} );
filter.set_arg({name: "sax", desc: "parse using sax", type: GF_PROP_BOOL, def: "false"} );


//just do an XHR and exit, no process/configure pid 
filter.initialize = function() {
 do_xhr();
}

function do_xhr()
{
 filter.xhr = new XMLHttpRequest();
 filter.xhr.responseType = "document";
 filter.xhr.onload = function()
 {
 	print('load status: ' + this.status);
 	if (! this.response) return;

 	let doc = this.response.documentElement;
 	if (!doc) return;
 	let reps = doc.getElementsByTagName('Representation');
 	print('nb reps: ' + reps.length ? reps.length : ' not found');

 };
 filter.xhr.onerror = function() {
  print(GF_LOG_ERROR, "Request failed");
};
filter.xhr.onreadystatechange = function() {
  print(`XHR state ${this.readyState}`);
  if (this.readyState != 4) return;

  print(`headers: ${this.getAllResponseHeaders()}`);
  let h = this.getResponseHeader('Server');

};

 if (filter.url) {
	 filter.xhr.open("GET", filter.url);
 } else {
	 filter.xhr.open("GET", "http://download.tsi.telecom-paristech.fr/gpac/DASH_CONFORMANCE/TelecomParisTech/mp4-live-1s/mp4-live-1s-mpd-AV-NBS.mpd");
 }
 filter.xhr.setRequestHeader("x-gpac-test", "some-cool-value");
 filter.xhr.setRequestHeader("x-gpac-test", "some-cool-value");
 filter.xhr.overrideMimeType('application/x-gpac');
 if (filter.sax) 
	 filter.xhr.responseType = "sax";

 filter.xhr.send();	

 if (filter.url && !filter.sax) {
	filter.xhr.wait(10);
	filter.xhr.abort();
 }
}

