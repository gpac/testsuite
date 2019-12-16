import {XMLHttpRequest} from 'xhr'

filter.pids = [];

//metadata
filter.set_name("XHR");
filter.set_desc("JS XHR test");
filter.set_version("0.1beta");
filter.set_author("GPAC team");
filter.set_help("This filter provides a very simple javascript test for XHR");

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
 	let doc = this.response.documentElement;
 	if (!doc) return;
 	let reps = doc.getElementsByTagName('Representation');
 	print('nb reps: ' + reps ? reps.length : ' not found');

 };
 filter.xhr.onerror = function() {
  print(GF_LOG_ERROR, "Request failed");
};
filter.xhr.onreadystatechange = function() {
  print(`XHR state ${this.readyState}`);
  if (this.readyState != 4) return;

  print(`headers: ${this.getAllResponseHeaders()}`);

};
 filter.xhr.open("GET", "http://download.tsi.telecom-paristech.fr/gpac/DASH_CONFORMANCE/TelecomParisTech/mp4-live-1s/mp4-live-1s-mpd-AV-NBS.mpd");
 filter.xhr.send();	
}

