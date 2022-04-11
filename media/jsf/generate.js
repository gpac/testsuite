
filter.pids = [];

//metadata
filter.set_name("JSGen");
filter.set_desc("JS-based packet generator filter");
filter.set_version("0.1beta");
filter.set_author("GPAC team");
filter.set_help("This filter provides a very simple javascript text packet generator, mostly for test purposes of Javascrip filter bindings");

//exposed arguments
filter.set_arg({name: "str", desc: "string to send", type: GF_PROP_STRING, def: "GPAC JS Filter Packet"} );
filter.set_arg({name: "patch", desc: "insert patchbox on output pid", type: GF_PROP_BOOL, def: "false"} );
filter.max_pids = -1;

filter.set_cap({id: "StreamType", value: "Text", output: true});
filter.set_cap({id: "CodecID", value: "subs", output: true});

filter.my_shared_string = "Shared data test";

let boxpatch = '<?xml version="1.0" encoding="UTF-8" />\
<GPACBOXES>\
<Box path="trak.tkhd+">\
<BS fcc="GPAC"/>\
<BS value="2" bits="32"/>\
<BS value="1" bits="32"/>\
</Box>\
</GPACBOXES>';

filter.initialize = function() {
 print(GF_LOG_DEBUG, "Init at " + Date() + " nb pids " + this.pids.length);

 this.opid = this.new_pid();
 this.opid.set_prop("StreamType", "Text");
 this.opid.set_prop("CodecID", "subs");
 this.opid.set_prop("Timescale", "1000");
 this.opid.nb_pck = 0;

 this.opid.set_prop("DecoderConfig", "My Super Config");
 let ab = new ArrayBuffer(11);
 let abv = new Uint8Array(ab);
 for (let i=0; i<10; i++)
 	abv[i] = 48+i;
 
 this.opid.set_prop("DecoderConfig", ab);
 if (this.patch) {

   this.opid.set_prop("boxpatch", boxpatch, true);
 }

 }

filter.update_arg = function(name, val)
{
	print(GF_LOG_INFO, "Value " + name + " is " + val);
}

filter.process = function()
{
	if (!this.opid)
		return GF_EOS;

	if (this.opid.nb_pck>=100) {
 		this.opid.eos = true;
 		return;
	}
	this.opid.nb_pck++;
	
	let pck;
	if (this.opid.nb_pck<50) {
		pck = this.opid.new_packet(this.my_shared_string, true);
		this.my_shared_string += ".";
		pck.cts = 1000*this.opid.nb_pck;
	} else {
		pck = this.opid.new_packet("Packet number " + this.opid.nb_pck);
		pck.cts = 1000*this.opid.nb_pck;
		if (this.opid.nb_pck>90)
			pck.truncate(pck.size / 2);
		if (this.opid.nb_pck>80)
			pck.append("\nMore data at CTS " + pck.cts);
	}
	//first dts is 1 s, this tests edit lists
	pck.dts = 1000*this.opid.nb_pck;
	pck.dur = 1000;
	pck.sap = GF_FILTER_SAP_1;
	pck.set_prop("MyProp", "great", true);
	if (this.opid.nb_pck==100) {
		pck.discard();
	} else {
		pck.send();
	}
}

filter.remove_pid = function(pid)
{
}

