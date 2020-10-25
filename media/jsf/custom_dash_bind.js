import { Sys as sys } from 'gpaccore'

print("Hello GPAC !");

let all_filters = [];

//custom rate adaptation object
let dashin = {};
dashin.groups = [];

session.set_new_filter_fun( (f) => {
		print("new filter " + f.name);
		f.iname = "JS"+f.name;
		all_filters.push(f);

		//bind our custom rate adaptation !
		if (f.name == "dashin") {
			f.bind(dashin);
		}
} ); 

session.set_del_filter_fun( (f) => {
	print("delete filter " + f.iname);
	let idx = all_filters.indexOf(f);
	if (idx>=0)
		all_filters.splice (idx, 1);
}); 

dashin.rate_adaptation = function (group, base_group, force_lower_complexity, stats)
{
	print(`Getting called in custom algo ! group ${group} base_group ${base_group} force_lower_complexity ${force_lower_complexity}`);
	print('Stats: ' + JSON.stringify(stats));

	//always use lowest quality
	return 0;
}

dashin.new_group = function (group)
{
	print("New group: " + JSON.stringify(group));
	//remember the group (adaptation set in dash)
	this.groups.push(group);
}

dashin.period_reset = function (type)
{
	print("Period reset type " + type);
	if (!type)
		this.groups = [];
}

dashin.download_monitor = function (group_idx, stats)
{
	print("Group " + group_idx + " download stats: " + JSON.stringify(stats));
	return -1;
}

session.add_filter("src=https://download.tsi.telecom-paristech.fr/gpac/DASH_CONFORMANCE/TelecomParisTech/mp4-live-1s/mp4-live-1s-mpd-AV-BS.mpd");

session.add_filter("inspect:interleave=false:deep:dur=10");





